import { expect, type Page, test } from '@playwright/test';
import { BUSINESS_PROFILES, profileOf, withComingSoon } from './support/business-profiles';
import { installDashboardShell } from './support/dashboard';

// Port of the configuration scenarios from POS. Selling scenarios intentionally
// stay in apps/pos: changing modules must never change existing SKU sales.
function world() {
  return {
    branch: { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', profile_key: 'khac', return_window_days: null as number | null, lot_selection: 'cashier_pick' },
    modules: { 'retail.units': true, 'retail.measured': true, 'retail.traceability': true } as Record<string, boolean>,
    stored: { profile_key: 'khac', wholesale: false, interests: [] as string[] },
    writes: [] as Array<{ path: string; body: Record<string, unknown> }>,
    previews: [] as string[], moved: '', read: true, write: true, manager: false,
    profiles: BUSINESS_PROFILES,
  };
}
async function install(page: Page, state: ReturnType<typeof world>, target = '/store_1/branches/branch_main') {
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const body = request.method() === 'GET' ? {} : request.postDataJSON() as Record<string, unknown>;
    const branch = state.branch;
    const ok = (data: unknown) => route.fulfill({ json: { data } });
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Quản trị Hiền' }, store: { id: 'store_1', name: branch.name, currency: 'VND', timezone: branch.timezone }, administration: { read: state.read, write: state.write }, branches: [branch], registers: [], selection: { branch_id: url.searchParams.get('branch_id'), register_id: null }, capabilities: state.manager && url.searchParams.get('branch_id') === branch.id ? ['pos.topology.manage'] : [], profile: { key: branch.profile_key, version: 1 }, onboarding: { required: false, can_setup: state.write } } });
    if (request.method() !== 'GET') state.writes.push({ path, body });
    if (path === '/pos/business_profiles') return ok(state.profiles);
    if (path === '/pos/branches' || path === '/pos/context/branches') return ok([branch]);
    if (path === '/pos/branches/branch_main/modules') return ok({ branch_id: branch.id, modules: state.modules, settings: [{ module: 'retail.units', enabled: true, reason: 'backfill', changed_at: '2026-11-08T12:00:00Z', changed_by_name: null }] });
    if (path === '/pos/store_profile') {
      if (request.method() === 'PUT') state.stored = { profile_key: String(body.profile_key), wholesale: body.wholesale === true, interests: body.interests as string[] };
      return ok(state.stored);
    }
    if (path.endsWith('/profile/preview')) {
      const target = profileOf(String(body.profile_key));
      if (!target) return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'The profile is unavailable.', details: { reason: 'profile_unavailable' } } } });
      state.previews.push(branch.profile_key);
      const disable = Object.keys(state.modules).filter((key) => state.modules[key] && !target.modules.includes(key));
      return ok({ branch_id: branch.id, from: branch.profile_key, to: target.key, modules: { enable: target.modules.filter((key) => !state.modules[key]), disable, in_use: { 'retail.traceability': { tracked_variants: 12, open_lots: 30 }, 'retail.measured': { measured_variants: 4, labelled_variants: 4, label_formats: 1 } } }, defaults: [{ field: 'return_window_days', current: branch.return_window_days, profile: 7 }], sample_units: target.sample_units, recommended_features: target.recommended_features });
    }
    if (path === '/pos/branches/branch_main/profile') {
      if (state.moved) { branch.profile_key = state.moved; state.moved = ''; }
      if (body.expected_profile_key !== branch.profile_key) return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'The branch profile changed elsewhere.', details: { reason: 'profile_conflict' } } } });
      branch.profile_key = String(body.profile_key);
      if (body.apply_modules) for (const key of Object.keys(state.modules)) state.modules[key] = profileOf(branch.profile_key)?.modules.includes(key) ?? false;
      if ((body.apply_defaults as string[]).includes('return_window_days')) branch.return_window_days = 7;
      return ok({ branch, modules: state.modules });
    }
    if (path.includes('/modules/') && request.method() === 'PUT') {
      const key = decodeURIComponent(path.split('/').at(-1) ?? '');
      const also = key === 'retail.measured' && body.enabled && !state.modules['retail.units'] ? ['retail.units'] : [];
      state.modules[key] = body.enabled === true;
      for (const item of also) state.modules[item] = true;
      return ok({ module: key, enabled: body.enabled, modules: state.modules, also_enabled: also });
    }
    return ok([]);
  });
  await installDashboardShell(page, { authenticated: true, read: state.read, write: state.write });
  await page.goto(target);
}
async function choose(page: Page, label: string, option: string) {
  await page.getByRole('combobox', { name: label, exact: true }).click();
  await page.getByRole('option', { name: option, exact: true }).click();
}
const row = (page: Page, key: string) => page.locator(`li[data-module="${key}"]`).filter({ has: page.getByRole('button') });

test('profile diff preserves in-use warnings, defaults opt-in, reason and expected profile', async ({ page }) => {
  const state = world(); await install(page, state);
  await choose(page, 'Ngành mới', 'Thời trang');
  await page.getByRole('button', { name: 'Xem thay đổi', exact: true }).click();
  const diff = page.getByRole('region', { name: 'Thay đổi khi chuyển sang Thời trang' });
  await expect(diff.locator('li[data-change="disable"]')).toHaveCount(3);
  await expect(diff.locator('[data-module="retail.traceability"]')).toContainText('12 SKU');
  await expect(diff.getByRole('note')).toContainText('Việc bán SKU đã cấu hình không đổi');
  await expect(diff.getByRole('checkbox', { name: /Bật \/ tắt chức năng theo ngành mới/ })).toBeChecked();
  await expect(diff.getByRole('checkbox', { name: /Áp giá trị của ngành mới/ })).not.toBeChecked();
  const form = page.getByRole('form', { name: 'Xác nhận chuyển sang Thời trang' });
  await expect(form.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true })).toBeDisabled();
  await form.getByLabel('Lý do (bắt buộc)').fill('Chuyển ngành');
  await form.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã chuyển chi nhánh' })).toBeVisible();
  expect(state.writes.filter((item) => item.path.endsWith('/profile')).at(-1)?.body).toEqual({ profile_key: 'thoi_trang', expected_profile_key: 'khac', apply_modules: true, apply_defaults: [], reason: 'Chuyển ngành' });
  expect(state.branch.return_window_days).toBeNull();
});

test('profile conflict reloads diff and requires confirmation of freshly unticked defaults', async ({ page }) => {
  const state = world(); await install(page, state);
  await choose(page, 'Ngành mới', 'Thời trang'); await page.getByRole('button', { name: 'Xem thay đổi', exact: true }).click();
  await page.getByRole('form', { name: 'Xác nhận chuyển sang Thời trang' }).getByLabel('Lý do (bắt buộc)').fill('Đổi ngành');
  state.moved = 'nha_thuoc';
  await page.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true }).click();
  await expect(page.getByRole('alert')).toContainText('Chi nhánh vừa được đổi ngành');
  await expect(page.getByText('Chuyển từ Nhà thuốc sang Thời trang:')).toBeVisible();
  expect(state.previews).toEqual(['khac', 'nha_thuoc']);
  const setting = page.getByRole('checkbox', { name: /Áp giá trị của ngành mới cho Số ngày/ });
  await expect(setting).not.toBeChecked(); await setting.check();
  await page.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã chuyển chi nhánh' })).toBeVisible();
  expect(state.writes.filter((item) => item.path.endsWith('/profile')).map((item) => item.body.expected_profile_key)).toEqual(['khac', 'nha_thuoc']);
  expect(state.branch.return_window_days).toBe(7);
});

test('module dependency is blocked, disable needs reason, enable confirms dependent modules', async ({ page }) => {
  const state = world(); await install(page, state);
  await expect(row(page, 'retail.units').getByRole('button', { name: 'Tắt Quy đổi đơn vị', exact: true })).toBeDisabled();
  for (const [key, name] of [['retail.measured', 'Hàng cân, tem cân'], ['retail.units', 'Quy đổi đơn vị']]) {
    await row(page, key).getByRole('button', { name: `Tắt ${name}`, exact: true }).click();
    const form = page.getByRole('form', { name: `Đổi ${name}`, exact: true });
    await expect(form.getByRole('button', { name: 'Lưu thay đổi' })).toBeDisabled();
    await form.getByLabel('Lý do (bắt buộc)').fill('Tạm ngừng'); await form.getByRole('button', { name: 'Lưu thay đổi' }).click();
    await expect(row(page, key)).toContainText('Đang tắt');
  }
  await row(page, 'retail.measured').getByRole('button', { name: 'Bật Hàng cân, tem cân', exact: true }).click();
  const form = page.getByRole('form', { name: 'Đổi Hàng cân, tem cân' });
  await expect(form).toContainText('Quy đổi đơn vị cũng sẽ được bật');
  await form.getByLabel('Lý do (bắt buộc)').fill('Bán lại hàng cân'); await form.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã bật Hàng cân, tem cân, kèm Quy đổi đơn vị.' })).toBeVisible();
  expect(state.modules['retail.units']).toBe(true);
});

test('store main profile stores wholesale and coming-soon interests without changing existing branch', async ({ page }) => {
  // A profile not open yet is recorded as an interest.
  const state = world(); state.profiles = withComingSoon('karaoke_bida'); await install(page, state, '/store_1/settings/business-model');
  const section = page.getByRole('region', { name: 'Hồ sơ chính của cửa hàng' });
  await choose(page, 'Ngành mặc định cho chi nhánh mới', 'Nhà thuốc');
  await section.getByRole('checkbox', { name: /Có bán sỉ/ }).check();
  await section.getByRole('checkbox', { name: 'Karaoke, Bida', exact: true }).check();
  await expect(section.getByRole('button', { name: 'Lưu hồ sơ cửa hàng' })).toBeDisabled();
  await section.getByLabel('Lý do (bắt buộc)').fill('Mở nhà thuốc');
  await section.getByRole('button', { name: 'Lưu hồ sơ cửa hàng' }).click();
  await expect(section.getByRole('status')).toBeVisible();
  expect(state.stored).toEqual({ profile_key: 'nha_thuoc', wholesale: true, interests: ['karaoke_bida'] });
  expect(state.branch.profile_key).toBe('khac');
});

for (const manager of [true, false]) test(manager ? 'branch manager can switch own modules but not industry/store profile' : 'read-only administrator sees no write actions', async ({ page }) => {
  const state = world(); state.write = false; state.read = !manager; state.manager = manager;
  await install(page, state);
  await expect(page.getByRole('list', { name: 'Danh sách chức năng của chi nhánh' })).toBeVisible();
  await expect(page.getByRole('combobox', { name: 'Ngành mới' })).toHaveCount(0);
  await expect(page.getByRole('region', { name: 'Hồ sơ chính của cửa hàng' })).toHaveCount(0);
  const off = row(page, 'retail.traceability').getByRole('button', { name: 'Tắt Serial, lô, hạn dùng', exact: true });
  if (manager) { await off.click(); await page.getByLabel('Lý do (bắt buộc)').fill('Không bán hàng theo lô'); await page.getByRole('button', { name: 'Lưu thay đổi' }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã tắt Serial' })).toBeVisible(); }
  else { await expect(off).toHaveCount(0); expect(state.writes).toEqual([]); }
});
