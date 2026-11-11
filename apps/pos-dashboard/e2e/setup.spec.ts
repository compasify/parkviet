import { expect, type Page, test } from '@playwright/test';
import { BUSINESS_PROFILES, profileOf } from './support/business-profiles';
import { installDashboardShell } from './support/dashboard';
import { randomUUID } from 'node:crypto';
import { liveExpect, liveStoreApi, requireLiveOnboarding } from './support/live-onboarding';

function world() { return { canSetup: true, lose: 0, branches: [] as Array<Record<string, unknown>>, locations: [{ id: 'sloc_main', name: 'Kho chính', active: true }, { id: 'sloc_other', name: 'Kho phụ', active: true }, { id: 'sloc_old', name: 'Kho cũ', active: false }], posts: [] as Array<{ key: string | null; body: Record<string, unknown> }>, results: new Map<string, { data: unknown }>() }; }
async function install(page: Page, state: ReturnType<typeof world>, redirect = false) {
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Chủ cửa hàng' }, store: { id: 'store_1', name: 'Cửa hàng mới', currency: 'VND', timezone: 'Asia/Ho_Chi_Minh' }, administration: { read: true, write: state.canSetup }, capabilities: [], branches: state.branches, registers: [], selection: { branch_id: url.searchParams.get('branch_id'), register_id: null }, onboarding: { required: !state.branches.length, can_setup: state.canSetup } } });
    if (path === '/pos/business_profiles') return route.fulfill({ json: { data: BUSINESS_PROFILES } });
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: state.locations, meta: { next: null } } });
    if (path === '/pos/context/branches' || path === '/pos/branches') return route.fulfill({ json: { data: state.branches, meta: { next: null } } });
    if (path === '/pos/onboarding' && request.method() === 'POST') {
      const key = request.headers()['idempotency-key'] ?? null;
      const body = request.postDataJSON() as Record<string, unknown>;
      state.posts.push({ key, body });
      if (!key) return route.fulfill({ status: 422, json: { error: { code: 'parameter_invalid', message: 'An idempotency key is required.' } } });
      if (!state.results.has(key)) {
        if (state.branches.length) return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'This store is already set up.', details: { reason: 'already_onboarded' } } } });
        const branch = { id: 'branch_new', ...(body.branch as object), status: 'active', profile_key: body.profile_key };
        state.branches.push(branch);
        state.results.set(key, { data: { branch, register: body.register ? { id: 'register_new', branch_id: branch.id, ...(body.register as object) } : null, store_profile: { profile_key: body.profile_key }, modules: Object.fromEntries((profileOf(String(body.profile_key))?.modules ?? []).map((name) => [name, true])) } });
      }
      if (state.lose > 0) { state.lose -= 1; return route.abort('timedout'); }
      return route.fulfill({ status: 201, json: state.results.get(key) });
    }
    return route.fulfill({ json: { data: [], meta: { next: null } } });
  });
  await installDashboardShell(page, { authenticated: true, write: state.canSetup });
  await page.goto(redirect ? '/store_1' : '/store_1/setup');
}
const next = (page: Page) => page.getByRole('button', { name: 'Tiếp tục', exact: true }).click();
const step = (page: Page, name: string) => page.getByRole('heading', { level: 2, name: new RegExp(`${name.replace(/[?.*+()[\]\\]/g, '\\$&')}$`) });
async function chooseLocation(page: Page, name = 'Kho chính') { await page.getByRole('combobox', { name: 'Kho bán hàng', exact: true }).click(); await page.getByRole('option', { name, exact: true }).click(); }
async function toSummary(page: Page, profile = 'Thời trang') {
  await page.getByRole('radio', { name: profile, exact: true }).check(); await next(page); await next(page);
  await page.getByLabel('Tên chi nhánh', { exact: true }).fill('Cửa hàng Hoa'); await chooseLocation(page); await next(page); await next(page);
}

test('empty store redirects to five-step setup; pharmacy defaults and risky opt-in produce one command', async ({ page }) => {
  const state = world(); await install(page, state, true);
  await expect(page).toHaveURL(/\/store_1\/setup/);
  await expect(page.getByRole('radiogroup', { name: /Bạn kinh doanh gì/ }).getByRole('radio')).toHaveCount(19);
  await expect(page.getByRole('group', { name: 'Bán buôn, bán lẻ' }).getByRole('radio')).toHaveCount(13);
  await expect(page.getByRole('group', { name: 'Ăn uống, giải trí' }).getByRole('radio')).toHaveCount(6);
  await page.getByRole('radio', { name: 'Nhà thuốc', exact: true }).check(); await next(page);
  await expect(step(page, 'Có bán sỉ không?')).toBeFocused();
  await expect(page.getByRole('radio', { name: 'Không bán sỉ', exact: true })).toBeChecked(); await next(page);
  await page.getByLabel('Tên chi nhánh', { exact: true }).fill('Nhà thuốc Minh Châu');
  await expect(page.getByLabel('Mã chi nhánh', { exact: true })).toHaveValue('nha-thuoc-minh-chau');
  await chooseLocation(page); await expect(page.getByRole('checkbox', { name: /Cấp cho tôi toàn quyền/ })).toBeChecked(); await next(page);
  await expect(page.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toHaveValue('7');
  await expect(page.getByRole('combobox', { name: 'Chọn lô khi bán', exact: false })).toContainText('FEFO');
  const usual = page.getByRole('group', { name: 'Ngành này thường dùng' });
  for (const name of ['Kho truy xuất (serial/lô)', 'Trả hàng', 'Hoàn tiền']) await expect(usual.getByRole('checkbox', { name, exact: true })).not.toBeChecked();
  await next(page); expect(state.posts).toHaveLength(0);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click();
  await expect(page).not.toHaveURL(/\/setup/);
  expect(state.posts).toHaveLength(1); expect(state.posts[0].key).toMatch(/^[0-9a-f-]{36}$/);
  expect(state.posts[0].body).toEqual({ profile_key: 'nha_thuoc', wholesale: false, interests: [], branch: { name: 'Nhà thuốc Minh Châu', code: 'nha-thuoc-minh-chau', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'sloc_main', return_window_days: 7, lot_selection: 'fefo' }, register: { name: 'Quầy 1' }, grant_self: true, features: [] });
  expect(state.branches).toHaveLength(1);
});

test('lost onboarding result locks answers and closing until same-key same-body recheck', async ({ page }) => {
  const state = world(); state.lose = 3; await install(page, state); await toSummary(page);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click();
  const checking = page.getByRole('status').filter({ hasText: 'Đang kiểm tra kết quả' });
  await expect(checking).toBeVisible({ timeout: 20_000 });
  await expect(page.getByRole('button', { name: 'Quay lại', exact: true })).toBeDisabled();
  await expect(page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last()).toBeDisabled();
  await page.keyboard.press('Escape'); await expect(checking).toBeVisible();
  await checking.getByRole('button', { name: 'Kiểm tra lại', exact: true }).click();
  await expect(page).not.toHaveURL(/\/setup/);
  expect(new Set(state.posts.map((post) => post.key)).size).toBe(1);
  expect(new Set(state.posts.map((post) => JSON.stringify(post.body))).size).toBe(1);
  expect(state.branches).toHaveLength(1);
});

test('coming-soon interest never creates food branch; wholesale, optional register and risky feature are explicit', async ({ page }) => {
  const state = world(); await install(page, state);
  await page.getByRole('radio', { name: 'Karaoke, Bida', exact: true }).check(); await next(page);
  await expect(page.getByRole('alert')).toContainText('Chọn một ngành POS đang hỗ trợ');
  await page.getByRole('button', { name: 'Không', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bạn quan tâm Karaoke, Bida' })).toBeVisible();
  await page.getByRole('radio', { name: 'Khác', exact: true }).check();
  await next(page); await page.getByRole('radio', { name: 'Có bán sỉ', exact: true }).check(); await next(page);
  await page.getByLabel('Tên chi nhánh', { exact: true }).fill('Tạp hóa Bến Xe'); await chooseLocation(page);
  await page.getByLabel('Tên quầy đầu tiên (không bắt buộc)').fill(''); await page.getByRole('checkbox', { name: /Cấp cho tôi toàn quyền/ }).uncheck(); await next(page);
  await page.getByRole('checkbox', { name: 'Bán ghi nợ', exact: true }).check(); await next(page);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click(); await expect(page).not.toHaveURL(/\/setup/);
  expect(state.posts[0].body).toMatchObject({ profile_key: 'khac', wholesale: true, interests: ['karaoke_bida'], grant_self: false, features: ['credit'] });
  expect(state.posts[0].body).not.toHaveProperty('register');
});

test('food shop adds the shop step: stations, menu taxes and kitchen send trigger go out in the same command', async ({ page }) => {
  const state = world(); await install(page, state);
  await page.getByRole('radio', { name: 'Cafe, Trà sữa', exact: true }).check(); await next(page); await next(page);
  await page.getByLabel('Tên chi nhánh', { exact: true }).fill('Cafe Hồ Gươm'); await chooseLocation(page); await next(page);
  await expect(step(page, 'Xem trước')).toBeVisible();
  await expect(page.getByText('Màn bán hàng mở thẳng lưới thực đơn.', { exact: true })).toBeVisible();
  await next(page); await expect(step(page, 'Thiết lập quán')).toBeVisible();
  const shop = page.getByTestId('setup-shop');
  await expect(shop.getByLabel('Tên khu 1', { exact: true })).toHaveValue('Bếp');
  await expect(shop.getByLabel('Tên khu 2', { exact: true })).toHaveValue('Quầy pha chế');
  await shop.getByLabel('Tên khu 2', { exact: true }).fill('bếp'); await next(page);
  await expect(page.getByRole('alert')).toContainText('Hai khu bếp không được trùng tên.');
  await shop.getByLabel('Tên khu 2', { exact: true }).fill('Quầy trà sữa');
  await shop.getByRole('button', { name: 'Thêm khu', exact: true }).click();
  await expect(shop.getByLabel('Tên khu 3', { exact: true })).toHaveValue('Khu 3');
  await shop.getByRole('button', { name: 'Bỏ', exact: true }).last().click();
  await expect(shop.getByLabel('Tên khu 3', { exact: true })).toHaveCount(0);
  await page.getByRole('combobox', { name: 'Gửi món xuống bếp', exact: true }).click();
  await page.getByRole('option', { name: 'Khi thu ngân bấm Gửi bếp', exact: true }).click();
  await next(page); expect(state.posts).toHaveLength(0);
  await expect(page.getByText('Đồ ăn, đồ uống: Đồ ăn, đồ uống (8%) · Rượu, bia: Thuế suất thường (10%)', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click();
  await expect(page).toHaveURL(/\/store_1\/branches\/branch_new\/hardware/);
  expect(state.posts).toHaveLength(1);
  expect(state.posts[0].body).toMatchObject({
    profile_key: 'cafe_tra_sua',
    branch: { name: 'Cafe Hồ Gươm', stock_location_id: 'sloc_main' },
    fnb_setup: { stations: [{ name: 'Bếp', kind: 'prep' }, { name: 'Quầy trà sữa', kind: 'bar' }], tax_categories: { food: 'vat_food', alcohol: 'vat_special' }, kitchen_send_trigger: 'manual' },
  });
});

test('retail setup sends no shop step', async ({ page }) => {
  const state = world(); await install(page, state); await toSummary(page);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click(); await expect(page).not.toHaveURL(/\/setup/);
  expect(state.posts[0].body).not.toHaveProperty('fnb_setup');
});

test('missing active stock location blocks branch step; reloading a sole new location selects it', async ({ page }) => {
  const state = world(); state.locations = [{ id: 'old', name: 'Kho cũ', active: false }]; await install(page, state);
  await page.getByRole('radio', { name: 'Mỹ phẩm', exact: true }).check(); await next(page); await next(page);
  await page.getByLabel('Tên chi nhánh', { exact: true }).fill('Mỹ phẩm Lan'); await next(page);
  await expect(step(page, 'Chi nhánh đầu tiên')).toBeVisible();
  const blocker = page.getByRole('alert').filter({ hasText: 'Cửa hàng chưa có kho hàng' }).first(); await expect(blocker).toBeVisible();
  state.locations.push({ id: 'new', name: 'Kho mới', active: true }); await blocker.getByRole('button', { name: 'Tải lại danh sách kho' }).click();
  await expect(page.getByRole('combobox', { name: 'Kho bán hàng', exact: true })).toHaveText('Kho mới'); await next(page); await expect(step(page, 'Xem trước')).toBeVisible();
  expect(state.posts).toEqual([]);
});

test('no setup permission shows guidance without writable wizard', async ({ page }) => {
  const state = world(); state.canSetup = false; await install(page, state);
  await expect(page.getByText('Nhờ quản trị cửa hàng thiết lập POS.', { exact: true })).toBeVisible();
  await expect(page.getByRole('radio')).toHaveCount(0); expect(state.posts).toEqual([]);
});

test('keyboard industry selection and Enter advance with focused step heading', async ({ page }) => {
  const state = world(); await install(page, state);
  const first = page.getByRole('radio', { name: 'Tạp hóa & Siêu thị', exact: true }); await first.focus(); await page.keyboard.press('Space');
  for (let index = 0; index < 5; index += 1) await page.keyboard.press('ArrowDown');
  await expect(page.getByRole('radio', { name: 'Nhà thuốc', exact: true })).toBeChecked();
  await page.keyboard.press('Enter'); await expect(step(page, 'Có bán sỉ không?')).toBeFocused();
});

test('completed setup never offers a second wizard', async ({ page }) => {
  const state = world(); state.branches.push({ id: 'existing', name: 'Đã thiết lập', code: 'existing', status: 'active', timezone: 'UTC', profile_key: 'khac' });
  await install(page, state);
  await expect(page.getByRole('status').filter({ hasText: 'Cửa hàng đã được thiết lập' })).toBeVisible();
  await expect(page.getByRole('radio')).toHaveCount(0); expect(state.posts).toEqual([]);
});

test.describe('real API onboarding', () => {
  type Created = { data: { branch: { id: string; name: string; profile_key: string }; register: { id: string; name: string } | null; membership: { capabilities: string[] } | null; modules: Record<string, boolean>; features: Record<string, boolean>; store_profile: { profile_key: string; interests: string[] } } };
  type Context = { capabilities: string[]; onboarding: { required: boolean; can_setup: boolean } };
  async function loginOwner(page: Page, owner: { email: string; password: string }, storeId: string) {
    await page.addInitScript(() => localStorage.setItem('spree-admin-locale', 'vi'));
    await page.goto('/login'); await page.getByLabel('Email', { exact: true }).fill(owner.email);
    await page.getByLabel('Mật khẩu', { exact: true }).fill(owner.password);
    await page.getByRole('button', { name: 'Đăng nhập', exact: true }).click();
    await liveExpect(page).not.toHaveURL(/\/login/);
    await page.goto(`/${storeId}/setup`);
  }

  test('pharmacy creates one branch, replays its result, refuses another setup, and keeps feature defaults opt-in', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'A store is set up only once; desktop only');
    test.setTimeout(180_000);
    const fixture = requireLiveOnboarding(1); const store = fixture.stores[0];
    const api = await liveStoreApi(request, fixture, store.store_id);
    await loginOwner(page, fixture.owner, store.store_id);
    await page.getByRole('radio', { name: 'Nhà thuốc', exact: true }).check(); await next(page); await next(page);
    const name = `Nhà thuốc Dashboard ${fixture.tag}`;
    await page.getByLabel('Tên chi nhánh', { exact: true }).fill(name);
    await liveExpect(page.getByRole('combobox', { name: 'Kho bán hàng', exact: true })).toContainText(store.stock_location_name);
    await next(page); await page.getByRole('checkbox', { name: 'Trả hàng', exact: true }).check(); await next(page);
    const posted = page.waitForRequest((sent) => sent.url().endsWith('/pos/onboarding') && sent.method() === 'POST');
    const answered = page.waitForResponse((response) => response.url().endsWith('/pos/onboarding') && response.request().method() === 'POST');
    await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click();
    const response = await answered; const created = await response.json() as Created;
    liveExpect(response.status(), JSON.stringify(created)).toBe(201);
    const sent = await posted; const key = sent.headers()['idempotency-key']; const body = sent.postDataJSON() as Record<string, unknown>;
    liveExpect(key).toMatch(/^[0-9a-f-]{36}$/);
    liveExpect(body).toMatchObject({ profile_key: 'nha_thuoc', grant_self: true, features: ['returns'], register: { name: 'Quầy 1' } });
    liveExpect(created.data.branch).toMatchObject({ name, profile_key: 'nha_thuoc' });
    liveExpect(created.data.membership?.capabilities).toContain('pos.shift.open');
    liveExpect(created.data.modules).toEqual({ 'retail.units': true, 'retail.measured': false, 'retail.traceability': true, 'fnb.menu': false, 'fnb.recipes': false, 'fnb.kitchen': false, 'fnb.order_number': false, 'fnb.cup_label': false, 'fnb.delivery_platforms': false });
    liveExpect(created.data.features.returns).toBe(true); liveExpect(created.data.features.refunds).toBe(false);
    await liveExpect(page).not.toHaveURL(/\/setup/);
    const replay = await api.send<Created>('POST', '/pos/onboarding', body, key);
    liveExpect(replay.status).toBe(201); liveExpect(replay.body).toEqual(created);
    const again = await api.send<{ error: { details: { reason: string } } }>('POST', '/pos/onboarding', { ...body, branch: { ...(body.branch as object), code: `second-${fixture.tag}` } }, randomUUID());
    liveExpect(again.status).toBe(409); liveExpect(again.body.error.details.reason).toBe('already_onboarded');
    liveExpect((await api.get<{ data: unknown[] }>('/pos/context/branches')).body.data).toHaveLength(1);
    const flags = await api.get<{ data: { switches: Record<string, { store: boolean; branch_override: boolean | null }> } }>('/pos/feature_flags', { branch_id: created.data.branch.id });
    liveExpect(flags.body.data.switches.returns).toMatchObject({ store: true, branch_override: null });
    liveExpect(flags.body.data.switches.refunds).toMatchObject({ store: false, branch_override: null });
    liveExpect((await api.get<Context>('/pos/context')).body.onboarding).toEqual({ required: false, can_setup: true });
    await page.goto(`/${store.store_id}/setup`); await liveExpect(page.getByRole('radio')).toHaveCount(0);
  });

  test('self-grant off creates no membership and completed setup stays closed', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'A store is set up only once; desktop only');
    test.setTimeout(180_000);
    const fixture = requireLiveOnboarding(2); const store = fixture.stores[1];
    const api = await liveStoreApi(request, fixture, store.store_id);
    await loginOwner(page, fixture.owner, store.store_id);
    await page.getByRole('radio', { name: 'Thời trang', exact: true }).check(); await next(page); await next(page);
    await page.getByLabel('Tên chi nhánh', { exact: true }).fill(`Thời trang Dashboard ${fixture.tag}`);
    await liveExpect(page.getByRole('combobox', { name: 'Kho bán hàng', exact: true })).toContainText(store.stock_location_name);
    await page.getByRole('checkbox', { name: /Cấp cho tôi toàn quyền/ }).uncheck(); await next(page); await next(page);
    const answered = page.waitForResponse((response) => response.url().endsWith('/pos/onboarding') && response.request().method() === 'POST');
    await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).last().click();
    const response = await answered; const created = await response.json() as Created;
    liveExpect(response.status()).toBe(201); liveExpect(created.data.membership).toBeNull();
    liveExpect(created.data.modules).toEqual({ 'retail.units': false, 'retail.measured': false, 'retail.traceability': false, 'fnb.menu': false, 'fnb.recipes': false, 'fnb.kitchen': false, 'fnb.order_number': false, 'fnb.cup_label': false, 'fnb.delivery_platforms': false });
    liveExpect(Object.values(created.data.features).every((on) => on === false)).toBe(true);
    const context = await api.get<Context>('/pos/context', { branch_id: created.data.branch.id });
    liveExpect([...context.body.capabilities].sort()).toEqual(['pos.topology.manage', 'pos.topology.read']);
    liveExpect(context.body.onboarding).toEqual({ required: false, can_setup: true });
    await liveExpect(page).not.toHaveURL(/\/setup/); await page.goto(`/${store.store_id}/setup`);
    await liveExpect(page.getByRole('radio')).toHaveCount(0);
  });
});
