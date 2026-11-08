import { expect, type Page, test } from '@playwright/test';
import { BUSINESS_PROFILES, profileOf } from './support/business-profiles';

// Branch business model (plan 261108-1830, phase 4): the branch's industry
// profile with a diff before any change (D7: defaults unticked), module
// switches with a reason (D5: turning one off never changes selling), and the
// store's main profile. Presentation fixtures only: no real account privileges.

type Write = { method: string; path: string; body: Record<string, unknown> | null };
const staff = { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' };
const DEPENDS: Record<string, string[]> = { 'retail.measured': ['retail.units'] };
const IN_USE: Record<string, Record<string, number>> = {
  'retail.traceability': { tracked_variants: 12, open_lots: 30, serials_in_stock: 0 },
  'retail.measured': { measured_variants: 4, labelled_variants: 4, label_formats: 1 },
  'retail.units': { converted_variants: 0 },
};

type ModelWorld = {
  admin: boolean;
  branch: Record<string, unknown> & { id: string; name: string; profile_key: string };
  modules: Record<string, boolean>;
  settings: Array<Record<string, unknown>>;
  storeProfile: { id: string; profile_key: string; wholesale: boolean; interests: string[]; updated_at: string };
  writes: Write[];
  previews: string[];
  reads: { modules: number; context: number };
  // Another person moves the branch to this profile just before the next PUT.
  movedMeanwhile: string | null;
};

function newModelWorld(extra: Partial<ModelWorld> = {}): ModelWorld {
  return {
    admin: true,
    branch: {
      id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh',
      stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null,
      return_window_days: null, lot_selection: 'cashier_pick', adjustment_approval_threshold: null,
      variance_threshold: null, profile_key: 'khac', profile_version: 1,
    },
    modules: { 'retail.units': true, 'retail.measured': true, 'retail.traceability': true },
    settings: [
      { module: 'retail.units', enabled: true, branch_id: 'branch_main', reason: 'backfill', changed_by_name: null, changed_at: '2026-11-08T12:00:00Z' },
    ],
    storeProfile: { id: 'posstoreprof_1', profile_key: 'khac', wholesale: false, interests: [], updated_at: '2026-11-08T12:00:00Z' },
    writes: [],
    previews: [],
    reads: { modules: 0, context: 0 },
    movedMeanwhile: null,
    ...extra,
  };
}

const page1 = (data: unknown[]) => ({ data, meta: { page: 1, pages: 1, count: data.length, next: null } });
const conflict = (reason: string, message: string, details: Record<string, unknown> = {}) => ({
  status: 409,
  json: { error: { code: 'conflict', message, details: { reason, ...details } } },
});

async function installModelApi(page: Page, world: ModelWorld) {
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    const body = method === 'GET' ? null : ((request.postDataJSON() ?? {}) as Record<string, unknown>);
    if (method !== 'GET' && !/\/auth\//.test(path)) world.writes.push({ method, path, body });
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/auth/logout') return route.fulfill({ json: {} });
    if (path === '/me') return route.fulfill({ json: { user: staff } });
    const branch = world.branch;
    if (path === '/pos/context') {
      world.reads.context += 1;
      const selected = url.searchParams.get('branch_id') === branch.id;
      return route.fulfill({
        json: {
          staff, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND', timezone: 'Asia/Ho_Chi_Minh' },
          administration: { read: world.admin, write: world.admin },
          capabilities: selected && !world.admin ? ['pos.topology.manage', 'pos.shift.open'] : [],
          modules: selected ? world.modules : {}, module_usage: { 'retail.traceability': false },
          profile: selected ? { key: branch.profile_key, version: 1, display: profileOf(branch.profile_key)?.display ?? {} } : null,
          onboarding: { required: false, can_setup: world.admin },
          branches: [branch], registers: [], shift: null,
          selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
        },
      });
    }
    if (path === '/pos/context/branches') return route.fulfill({ json: page1([branch]) });
    if (path === '/pos/business_profiles') return route.fulfill({ json: { data: BUSINESS_PROFILES } });
    if (path === '/pos/branches' && method === 'GET') return route.fulfill({ json: page1([branch]) });
    if (path === '/pos/branches' && method === 'POST')
      return route.fulfill({ status: 201, json: { data: { id: 'branch_new', status: 'active', ...body } } });
    if (path === '/pos/configuration/locations')
      return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }], meta: { next: null } } });
    if (path === '/pos/store_profile' && method === 'GET') return route.fulfill({ json: { data: world.storeProfile } });
    if (path === '/pos/store_profile' && method === 'PUT') {
      world.storeProfile = {
        ...world.storeProfile, profile_key: String(body?.profile_key), wholesale: body?.wholesale === true,
        interests: (body?.interests as string[]) ?? [], updated_at: '2026-11-09T10:00:00Z',
      };
      return route.fulfill({ json: { data: world.storeProfile } });
    }
    if (path === `/pos/branches/${branch.id}/modules`) {
      world.reads.modules += 1;
      return route.fulfill({ json: { data: { branch_id: branch.id, modules: world.modules, settings: world.settings } } });
    }
    const moduleSwitch = new RegExp(`^/pos/branches/${branch.id}/modules/([^/]+)$`).exec(path);
    if (moduleSwitch && method === 'PUT') {
      const key = decodeURIComponent(moduleSwitch[1]);
      const enabled = body?.enabled === true;
      if (!String(body?.reason ?? '').trim()) return route.fulfill(conflict('reason_required', 'A reason is required.'));
      const requiredBy = Object.entries(DEPENDS).filter(([other, needs]) => needs.includes(key) && world.modules[other]).map(([other]) => other);
      if (!enabled && requiredBy.length)
        return route.fulfill(conflict('module_required_by', 'Needed by another module.', { module: key, required_by: requiredBy }));
      const also = enabled ? (DEPENDS[key] ?? []).filter((needed) => !world.modules[needed]) : [];
      for (const item of [key, ...also]) world.modules[item] = enabled;
      world.settings = [
        ...world.settings.filter((row) => row.module !== key),
        { module: key, enabled, branch_id: branch.id, reason: body?.reason, changed_by_name: staff.full_name, changed_at: '2026-11-09T10:00:00Z' },
      ];
      return route.fulfill({ json: { data: { branch_id: branch.id, module: key, enabled, changed: true, also_enabled: also, modules: world.modules } } });
    }
    if (path === `/pos/branches/${branch.id}/profile/preview` && method === 'POST') {
      const target = profileOf(String(body?.profile_key));
      if (!target || target.status !== 'available') return route.fulfill(conflict('profile_unavailable', 'Unavailable.'));
      world.previews.push(branch.profile_key);
      const on = Object.keys(world.modules).filter((key) => world.modules[key]);
      const disable = on.filter((key) => !target.modules.includes(key));
      return route.fulfill({
        json: {
          data: {
            branch_id: branch.id, from: branch.profile_key, to: target.key, profile_version: 1,
            modules: { enable: target.modules.filter((key) => !on.includes(key)), disable, in_use: Object.fromEntries(disable.map((key) => [key, IN_USE[key]])) },
            defaults: Object.entries(target.branch_defaults)
              .filter(([field, value]) => branch[field] !== value)
              .map(([field, value]) => ({ field, current: branch[field] ?? null, profile: value })),
            sample_units: target.sample_units, recommended_features: target.recommended_features,
          },
        },
      });
    }
    if (path === `/pos/branches/${branch.id}/profile` && method === 'PUT') {
      if (world.movedMeanwhile) {
        branch.profile_key = world.movedMeanwhile;
        world.movedMeanwhile = null;
      }
      if (body?.expected_profile_key !== branch.profile_key)
        return route.fulfill(conflict('profile_conflict', 'The branch profile changed.', { current_profile_key: branch.profile_key }));
      const target = profileOf(String(body?.profile_key));
      if (!target) return route.fulfill(conflict('profile_unknown', 'Unknown.'));
      const enabled: string[] = [];
      const disabled: string[] = [];
      if (body?.apply_modules === true)
        for (const key of Object.keys(world.modules)) {
          const next = target.modules.includes(key);
          if (next !== world.modules[key]) (next ? enabled : disabled).push(key);
          world.modules[key] = next;
        }
      const defaults = ((body?.apply_defaults as string[]) ?? []).map((field) => {
        const change = { field, from: branch[field] ?? null, to: (target.branch_defaults as Record<string, unknown>)[field] };
        branch[field] = change.to;
        return change;
      });
      branch.profile_key = target.key;
      return route.fulfill({ json: { data: { branch, modules: world.modules, applied: { modules: { enabled, disabled }, defaults, sample_units: target.sample_units } } } });
    }
    if (path === '/pos/feature_flags') return route.fulfill({ json: { data: { branch_id: branch.id, features: {}, switches: {}, settings: [] } } });
    if (method !== 'GET') return route.fulfill({ status: 404, json: { error: { code: 'not_found', message: `Not mocked: ${method} ${path}` } } });
    return route.fulfill({ json: page1([]) });
  });
}

async function signInAsAdmin(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('admin@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập quản trị', exact: true }).click();
  await expect(page).toHaveURL(/\/settings$/);
}

async function openModel(page: Page) {
  await page.getByRole('link', { name: 'Mô hình kinh doanh của chi nhánh Siêu thị Hiền', exact: true }).click();
  await expect(page).toHaveURL(/\/settings\/branches\/branch_main\/business-model$/);
  await expect(page.getByRole('heading', { level: 1, name: 'Mô hình kinh doanh · Siêu thị Hiền' })).toBeVisible();
}

// The same targeted checks as accessibility.spec.ts (no audit library installed).
async function unnamedControls(page: Page) {
  return page.evaluate(() => {
    const visible = (element: Element) => {
      const box = (element as HTMLElement).getBoundingClientRect();
      return box.width > 0 && box.height > 0 && getComputedStyle(element).visibility !== 'hidden';
    };
    const name = (element: Element) => {
      const labelled = element.getAttribute('aria-labelledby');
      if (labelled) return labelled.split(' ').map((id) => document.getElementById(id)?.textContent ?? '').join(' ').trim();
      if (element.getAttribute('aria-label')) return element.getAttribute('aria-label')?.trim();
      const id = element.getAttribute('id');
      const forLabel = id ? document.querySelector(`label[for="${CSS.escape(id)}"]`) : null;
      return (
        forLabel?.textContent?.trim() ||
        element.closest('label')?.textContent?.trim() ||
        (element instanceof HTMLButtonElement || element.tagName === 'A' || element.tagName === 'SUMMARY' ? element.textContent?.trim() : '') ||
        element.getAttribute('title')?.trim() ||
        (element as HTMLInputElement).placeholder?.trim() ||
        ''
      );
    };
    return [...document.querySelectorAll('button, a[href], input:not([type="hidden"]), select, textarea, summary, [role="tab"]')]
      .filter(visible)
      .filter((element) => !name(element))
      .map((element) => element.outerHTML.slice(0, 160));
  });
}

const modulesList = (page: Page) => page.getByRole('list', { name: 'Danh sách chức năng của chi nhánh' });
const moduleRow = (page: Page, key: string) => modulesList(page).locator(`li[data-module="${key}"]`);
const sections = (page: Page) => page.getByRole('navigation', { name: 'Cấu hình chi nhánh' });

test('moving a branch from Other to Fashion shows the diff, applies no default unless ticked and hides the module setup', async ({ page }) => {
  const world = newModelWorld();
  await installModelApi(page, world);
  await signInAsAdmin(page);
  await openModel(page);

  await expect(page.locator('.business-model-profile strong')).toHaveText('Khác');
  await expect(modulesList(page).getByRole('listitem')).toHaveCount(3);
  await expect(modulesList(page).locator('.status-tag')).toHaveText(['Đang bật', 'Đang bật', 'Đang bật']);
  await expect(sections(page).getByRole('link', { name: 'Mẫu tem cân', exact: true })).toBeVisible();
  await expect(sections(page).getByRole('link', { name: 'Mô hình kinh doanh', exact: true })).toHaveAttribute('aria-current', 'page');

  await page.getByLabel('Ngành mới').selectOption({ label: 'Thời trang' });
  await page.getByRole('button', { name: 'Xem thay đổi', exact: true }).click();
  const diff = page.getByRole('region', { name: 'Thay đổi khi chuyển sang Thời trang' });
  await expect(diff).toBeVisible();
  const off = diff.locator('li[data-change="disable"]');
  await expect(off).toHaveCount(3);
  await expect(diff.locator('li[data-change="enable"]')).toHaveCount(0);
  await expect(diff.locator('li[data-module="retail.traceability"]')).toContainText(
    'Đang dùng ở chi nhánh: 12 SKU theo dõi serial/lô, 30 lô còn hàng.',
  );
  await expect(diff.locator('li[data-module="retail.measured"]')).toContainText('4 SKU bán theo cân, 4 SKU có mã tem cân, 1 mẫu tem cân');
  await expect(diff.locator('li[data-module="retail.units"]')).toContainText('Chưa có cấu hình nào của chức năng này ở chi nhánh.');
  // D5, as the plan words it.
  await expect(diff.getByRole('note')).toContainText('Việc bán SKU đã cấu hình không đổi; chỉ ẩn màn cấu hình.');
  await expect(diff.getByRole('checkbox', { name: /Bật \/ tắt chức năng theo ngành mới/ })).toBeChecked();
  // D7: each differing default has its own box, unticked.
  const window = diff.getByRole('checkbox', { name: 'Áp giá trị của ngành mới cho Số ngày cho phép trả hàng', exact: true });
  await expect(window).not.toBeChecked();
  await expect(diff.locator('li[data-field="return_window_days"]')).toContainText('Hiện tại: để trống · Ngành mới: 7 ngày');
  await expect(diff).toContainText('Không thêm đơn vị nào');
  await expect(diff).toContainText('Ngành này thường dùng (đang tắt): Trả hàng, Hoàn tiền, Đổi hàng, Chuyển khoản VietQR.');
  expect(await unnamedControls(page)).toEqual([]);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);

  const apply = page.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true });
  await expect(apply).toBeDisabled();
  await page.getByRole('form', { name: 'Xác nhận chuyển sang Thời trang' }).getByLabel('Lý do (bắt buộc)').fill('Chuyển sang bán quần áo');
  const contextReads = world.reads.context;
  const moduleReads = world.reads.modules;
  await apply.click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã chuyển chi nhánh sang ngành Thời trang.' })).toBeVisible();
  expect(world.writes.at(-1)).toEqual({
    method: 'PUT',
    path: '/pos/branches/branch_main/profile',
    body: { profile_key: 'thoi_trang', expected_profile_key: 'khac', apply_modules: true, apply_defaults: [], reason: 'Chuyển sang bán quần áo' },
  });
  // Nothing ticked: the branch settings are as they were.
  expect(world.branch.return_window_days).toBeNull();
  expect(world.branch.lot_selection).toBe('cashier_pick');

  // Context and module reads are refreshed: the setup entry points of the three modules are gone.
  await expect(page.locator('.business-model-profile strong')).toHaveText('Thời trang');
  await expect(modulesList(page).locator('.status-tag')).toHaveText(['Đang tắt', 'Đang tắt', 'Đang tắt']);
  await expect(sections(page).getByRole('link', { name: 'Mẫu tem cân', exact: true })).toHaveCount(0);
  expect(world.reads.context).toBeGreaterThan(contextReads);
  expect(world.reads.modules).toBeGreaterThan(moduleReads);
  await sections(page).getByRole('link', { name: 'Về cấu hình' }).click();
  await expect(page.getByRole('link', { name: 'Hàng bán tại chi nhánh Siêu thị Hiền', exact: true })).toBeVisible();
  await expect(page.getByRole('link', { name: 'Mẫu tem cân Siêu thị Hiền', exact: true })).toHaveCount(0);
});

test('a change made elsewhere meanwhile reloads the diff; the next attempt sends the new expected profile', async ({ page }) => {
  const world = newModelWorld();
  await installModelApi(page, world);
  await signInAsAdmin(page);
  await openModel(page);
  await page.getByLabel('Ngành mới').selectOption({ label: 'Thời trang' });
  await page.getByRole('button', { name: 'Xem thay đổi', exact: true }).click();
  await page.getByRole('form', { name: 'Xác nhận chuyển sang Thời trang' }).getByLabel('Lý do (bắt buộc)').fill('Đổi ngành');
  world.movedMeanwhile = 'nha_thuoc';
  await page.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true }).click();

  await expect(page.getByRole('alert')).toHaveText('Chi nhánh vừa được đổi ngành ở nơi khác. Đã tải lại thay đổi; xem lại rồi xác nhận.');
  await expect(page.getByText('Chuyển từ Nhà thuốc sang Thời trang:')).toBeVisible();
  expect(world.previews).toEqual(['khac', 'nha_thuoc']);
  const diff = page.getByRole('region', { name: 'Thay đổi khi chuyển sang Thời trang' });
  const window = diff.getByRole('checkbox', { name: 'Áp giá trị của ngành mới cho Số ngày cho phép trả hàng', exact: true });
  await expect(window).not.toBeChecked();
  await expect(page.getByRole('form', { name: 'Xác nhận chuyển sang Thời trang' }).getByLabel('Lý do (bắt buộc)')).toHaveValue('Đổi ngành');

  // Ticked by hand, this default alone is applied.
  await window.check();
  await page.getByRole('button', { name: 'Chuyển sang Thời trang', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã chuyển chi nhánh sang ngành Thời trang.' })).toBeVisible();
  const puts = world.writes.filter((write) => write.path === '/pos/branches/branch_main/profile');
  expect(puts.map((write) => write.body?.expected_profile_key)).toEqual(['khac', 'nha_thuoc']);
  expect(puts[1].body).toMatchObject({ apply_defaults: ['return_window_days'] });
  expect(world.branch.return_window_days).toBe(7);
  expect(world.branch.lot_selection).toBe('cashier_pick');
});

test('module switches take a reason, say what else turns on, and keep a needed module on', async ({ page }) => {
  const world = newModelWorld();
  await installModelApi(page, world);
  await signInAsAdmin(page);
  await openModel(page);

  // Unit conversion is needed by scale labels: it cannot be switched off first.
  await expect(moduleRow(page, 'retail.units').getByRole('button', { name: 'Tắt Quy đổi đơn vị', exact: true })).toBeDisabled();
  await expect(moduleRow(page, 'retail.units')).toContainText('Đang được Hàng cân, tem cân cần; tắt chức năng đó trước.');
  await expect(moduleRow(page, 'retail.units')).toContainText('Đổi lần cuối: — · ');

  await moduleRow(page, 'retail.measured').getByRole('button', { name: 'Tắt Hàng cân, tem cân', exact: true }).click();
  const offForm = page.getByRole('form', { name: 'Đổi Hàng cân, tem cân' });
  await expect(offForm).toContainText('việc bán SKU đã cấu hình không đổi; chỉ ẩn màn cấu hình và chặn thiết lập mới');
  await expect(offForm.getByRole('button', { name: 'Lưu thay đổi' })).toBeDisabled();
  await offForm.getByLabel('Lý do (bắt buộc)').fill('Không bán hàng cân');
  const contextReads = world.reads.context;
  await offForm.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã tắt Hàng cân, tem cân.' })).toBeVisible();
  expect(world.writes.at(-1)).toEqual({
    method: 'PUT', path: '/pos/branches/branch_main/modules/retail.measured', body: { enabled: false, reason: 'Không bán hàng cân' },
  });
  await expect(moduleRow(page, 'retail.measured').locator('.status-tag')).toHaveText('Đang tắt');
  await expect(moduleRow(page, 'retail.measured')).toContainText('Quản trị Hiền');
  expect(world.reads.context).toBeGreaterThan(contextReads);

  await moduleRow(page, 'retail.units').getByRole('button', { name: 'Tắt Quy đổi đơn vị', exact: true }).click();
  await page.getByRole('form', { name: 'Đổi Quy đổi đơn vị' }).getByLabel('Lý do (bắt buộc)').fill('Không quy đổi');
  await page.getByRole('form', { name: 'Đổi Quy đổi đơn vị' }).getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(moduleRow(page, 'retail.units').locator('.status-tag')).toHaveText('Đang tắt');

  // Turning scale labels back on says beforehand that unit conversion comes with it.
  await moduleRow(page, 'retail.measured').getByRole('button', { name: 'Bật Hàng cân, tem cân', exact: true }).click();
  const onForm = page.getByRole('form', { name: 'Đổi Hàng cân, tem cân' });
  await expect(onForm).toContainText('Chức năng này cần Quy đổi đơn vị, nên Quy đổi đơn vị cũng sẽ được bật.');
  await onForm.getByLabel('Lý do (bắt buộc)').fill('Bán lại hàng cân');
  await onForm.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã bật Hàng cân, tem cân, kèm Quy đổi đơn vị.' })).toBeVisible();
  await expect(modulesList(page).locator('.status-tag')).toHaveText(['Đang bật', 'Đang bật', 'Đang bật']);
  await expect(sections(page).getByRole('link', { name: 'Mẫu tem cân', exact: true })).toBeVisible();
});

test("the store's main profile is saved with a reason and a new branch starts from it, defaults filled in", async ({ page }) => {
  const world = newModelWorld();
  await installModelApi(page, world);
  await signInAsAdmin(page);
  await openModel(page);

  const store = page.getByRole('region', { name: 'Hồ sơ chính của cửa hàng' });
  const save = store.getByRole('button', { name: 'Lưu hồ sơ cửa hàng' });
  await expect(store.getByLabel('Ngành mặc định cho chi nhánh mới')).toHaveValue('khac');
  // Only available profiles are defaults; "coming soon" ones are interests.
  await expect(store.getByLabel('Ngành mặc định cho chi nhánh mới').locator('option')).toHaveCount(13);
  await expect(store.getByRole('group', { name: 'Ngành "Sắp hỗ trợ" đang quan tâm' }).getByRole('checkbox')).toHaveCount(6);
  await store.getByLabel('Ngành mặc định cho chi nhánh mới').selectOption({ label: 'Nhà thuốc' });
  await store.getByRole('checkbox', { name: /Có bán sỉ/ }).check();
  await store.getByRole('checkbox', { name: 'Cafe, Trà sữa' }).check();
  await expect(save).toBeDisabled();
  await store.getByLabel('Lý do (bắt buộc)').fill('Mở thêm nhà thuốc');
  await save.click();
  await expect(store.getByRole('status')).toHaveText('Đã lưu hồ sơ chính của cửa hàng.');
  expect(world.writes.at(-1)).toEqual({
    method: 'PUT', path: '/pos/store_profile',
    body: { profile_key: 'nha_thuoc', wholesale: true, interests: ['cafe_tra_sua'], reason: 'Mở thêm nhà thuốc' },
  });
  // The existing branch keeps its own profile.
  await expect(page.locator('.business-model-profile strong')).toHaveText('Khác');

  await sections(page).getByRole('link', { name: 'Về cấu hình' }).click();
  await page.getByRole('button', { name: 'Thêm chi nhánh', exact: true }).click();
  const editor = page.getByRole('dialog');
  const profile = editor.getByLabel('Ngành của chi nhánh');
  await expect(profile).toHaveValue('nha_thuoc');
  await expect(editor.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toHaveValue('7');
  await expect(profile.locator('option')).toHaveCount(13);
  await profile.selectOption({ label: 'Hoa & Quà tặng' });
  await expect(editor.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toHaveValue('');
  await profile.selectOption({ label: 'Nhà thuốc' });
  await expect(editor.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toHaveValue('7');
  await editor.getByLabel('Tên hiển thị', { exact: true }).fill('Nhà thuốc Quận 3');
  await editor.getByRole('textbox', { name: 'Mã', exact: true }).fill('q3');
  await editor.getByRole('combobox', { name: 'Kho bán hàng' }).selectOption('stock_main');
  await editor.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(editor).toHaveCount(0);
  expect(world.writes.at(-1)).toMatchObject({
    method: 'POST', path: '/pos/branches',
    body: { name: 'Nhà thuốc Quận 3', code: 'q3', profile_key: 'nha_thuoc', return_window_days: 7, lot_selection: 'fefo' },
  });
});

test('a branch manager switches modules of the own branch but does not change its industry or the store profile', async ({ page }) => {
  const world = newModelWorld({ admin: false });
  await installModelApi(page, world);
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('admin@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.pos-context-details summary')).toContainText('Siêu thị Hiền');

  await page.goto('/settings/branches/branch_main/business-model');
  await expect(page.getByRole('heading', { level: 1, name: 'Mô hình kinh doanh · Siêu thị Hiền' })).toBeVisible();
  await expect(page.locator('.business-model-profile strong')).toHaveText('Khác');
  await expect(page.getByLabel('Ngành mới')).toHaveCount(0);
  await expect(page.getByRole('region', { name: 'Hồ sơ chính của cửa hàng' })).toHaveCount(0);
  await moduleRow(page, 'retail.traceability').getByRole('button', { name: 'Tắt Serial, lô, hạn dùng', exact: true }).click();
  await page.getByLabel('Lý do (bắt buộc)').fill('Không bán hàng theo lô');
  await page.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(moduleRow(page, 'retail.traceability').locator('.status-tag')).toHaveText('Đang tắt');
  expect(world.writes.at(-1)).toMatchObject({ path: '/pos/branches/branch_main/modules/retail.traceability', body: { enabled: false } });
  expect(await unnamedControls(page)).toEqual([]);
});
