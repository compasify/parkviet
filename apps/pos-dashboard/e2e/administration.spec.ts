import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';

// Presentation fixtures only, not grants of real API privileges.
async function install(page: Page, access = { read: true, write: true }) {
  const staff = [
    { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' },
    { id: 'staff_lan', full_name: 'Nguyễn Thị Lan', email: 'lan@example.test' },
    { id: 'staff_an', full_name: 'Trần Văn An', email: 'an@example.test' },
  ];
  const branches = [{ id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null as string | null, receiving_note: 'Nhận hàng tại cửa sau' }];
  const registers = [{ id: 'register_1', branch_id: 'branch_main', name: 'Quầy tầng một', code: 'q1', status: 'active' }];
  const memberships = [
    { id: 'membership_admin', staff_id: 'staff_admin', branch_id: 'branch_main', staff: staff[0], capabilities: ['pos.topology.recover'], status: 'active' },
    { id: 'membership_lan', staff_id: 'staff_lan', branch_id: 'branch_main', staff: staff[1], capabilities: ['pos.shift.open', 'pos.payment.collect'], status: 'active' },
  ];
  const state = { writes: [] as { method: string; path: string; body: Record<string, unknown> }[], staffPages: [] as number[], failOptions: false, failSave: false };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') return route.fulfill({ json: { staff: staff[0], store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: access, capabilities: [], branches, registers: [], shift: null, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null } } });
    if (path === '/pos/configuration/staff') {
      if (state.failOptions) return route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
      const number = Number(url.searchParams.get('page')); state.staffPages.push(number);
      return route.fulfill({ json: { data: number === 1 ? staff.slice(0, 2) : staff.slice(2), meta: { next: number === 1 ? 2 : null } } });
    }
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }, { id: 'stock_returns', name: 'Kho tiếp nhận hàng', active: true }] } });
    const resource = path.split('/')[2];
    const rows = resource === 'branches' ? branches : resource === 'registers' ? registers : resource === 'memberships' ? memberships : null;
    if (rows && request.method() === 'GET') return route.fulfill({ json: { data: rows } });
    if (rows && request.method() !== 'GET') {
      const body = request.postDataJSON(); state.writes.push({ method: request.method(), path, body });
      if (state.failSave) return route.fulfill({ status: 422, json: { error: { code: 'validation_error', message: 'Code has already been taken', details: { code: ['has already been taken'] } } } });
      const row = rows.find((item) => item.id === path.split('/')[3]);
      if (path.endsWith('/disable') || path.endsWith('/enable')) { if (row) row.status = path.endsWith('/disable') ? 'disabled' : 'active'; }
      else if (request.method() === 'PATCH' && row) Object.assign(row, body);
      else (rows as unknown[]).push({ id: `${resource}_new`, status: 'active', ...body, ...(resource === 'memberships' ? { staff: staff.find((user) => user.id === body.staff_id) } : {}) });
      return route.fulfill({ json: { data: row ?? {} } });
    }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  await installDashboardShell(page, { ...access, authenticated: true });
  return { state, branches, registers, memberships };
}
async function open(page: Page, path = 'branches') { await page.goto(`/store_1/${path}`); }
async function select(page: Page, label: string, option: string) { await page.getByRole('dialog').getByLabel(label, { exact: true }).click(); await page.getByRole('option', { name: option, exact: true }).click(); }
// Spree's own strings are English under the dev server, which pre-bundles the
// framework without its locale files; the production build carries both.
const MENU = /^(Open actions|Mở menu thao tác)$/;
async function act(page: Page, row: string, item: string) { await page.getByRole('row').filter({ hasText: row }).getByRole('button', { name: MENU }).click(); await page.getByRole('menuitem', { name: item, exact: true }).click(); }
async function confirm(page: Page, action: string) { await page.getByRole('dialog').last().getByRole('button', { name: action, exact: true }).click(); }

test('store authority without a selling membership lists warehouses and every staff page', async ({ page }, testInfo) => {
  const { state } = await install(page); await open(page);
  await expect(page.getByRole('table')).toContainText('Kho hàng trung tâm');
  await page.getByRole('row').filter({ hasText: 'Siêu thị Hiền' }).getByRole('button', { name: MENU }).click();
  await expect(page.getByRole('menuitem')).toHaveText(['Chỉnh sửa', 'Ngừng hoạt động']);
  await page.keyboard.press('Escape');
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toBeEnabled();
  expect(state.staffPages).toEqual(expect.arrayContaining([1, 2])); expect(state.writes).toEqual([]);
  await page.screenshot({ path: testInfo.outputPath('administration-branches.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});
test('branch and register creation, editing, disabling and recovery preserve payloads', async ({ page }) => {
  const { state } = await install(page); await open(page);
  await act(page, 'Siêu thị Hiền', 'Chỉnh sửa');
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Siêu thị Hiền · Trung tâm'); await select(page, 'Kho nhận hàng', 'Kho tiếp nhận hàng');
  await dialog.getByLabel('Ghi chú nhận hàng').fill('Gọi trước khi nhận hàng'); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog).toHaveCount(0);
  expect(state.writes[0]).toMatchObject({ method: 'PATCH', path: '/pos/branches/branch_main', body: { receiving_stock_location_id: 'stock_returns', receiving_note: 'Gọi trước khi nhận hàng' } });
  await page.getByRole('button', { name: 'Thêm chi nhánh', exact: true }).click(); await dialog.getByLabel('Tên hiển thị').fill('Chi nhánh Quận 3'); await dialog.getByLabel('Mã', { exact: true }).fill('q3'); await select(page, 'Kho bán hàng', 'Kho hàng trung tâm'); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(page.getByRole('table')).toContainText('Chi nhánh Quận 3');
  await open(page, 'branches/branch_main/registers'); const table = page.getByRole('table');
  await page.getByRole('button', { name: 'Thêm quầy', exact: true }).click(); await expect(dialog.getByLabel('Chi nhánh', { exact: true })).toBeDisabled(); await dialog.getByLabel('Tên hiển thị').fill('Quầy tầng hai'); await dialog.getByLabel('Mã', { exact: true }).fill('q2'); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(table).toContainText('Quầy tầng hai');
  expect(state.writes.at(-1)).toMatchObject({ method: 'POST', path: '/pos/registers', body: { branch_id: 'branch_main', name: 'Quầy tầng hai', code: 'q2' } });
  await act(page, 'Quầy tầng một', 'Chỉnh sửa'); await dialog.getByLabel('Tên hiển thị').fill('Quầy ưu tiên'); await expect(dialog.getByLabel('Chi nhánh', { exact: true })).toBeDisabled(); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  const row = table.getByRole('row').filter({ hasText: 'Quầy ưu tiên' }); await act(page, 'Quầy ưu tiên', 'Ngừng hoạt động'); await confirm(page, 'Ngừng hoạt động'); await expect(row).toContainText('đã ngừng');
  await act(page, 'Quầy ưu tiên', 'Kích hoạt lại'); await confirm(page, 'Kích hoạt lại'); await expect(row).toContainText('đang dùng');
});
test('staff permissions expose 30 capabilities, confirm sensitive changes and exclude existing memberships', async ({ page }) => {
  const { state, memberships } = await install(page); await open(page, 'branches/branch_main/staff');
  await act(page, 'Nguyễn Thị Lan', 'Chỉnh sửa'); const dialog = page.getByRole('dialog');
  await expect(dialog.getByRole('group', { name: 'Quyền tại chi nhánh', exact: true }).getByRole('checkbox')).toHaveCount(37);
  await dialog.getByRole('checkbox', { name: 'Áp dụng giảm giá', exact: true }).check(); await dialog.getByRole('checkbox', { name: 'Đổi giá bán', exact: true }).check(); await expect(dialog.getByRole('button', { name: 'Lưu', exact: true })).toBeDisabled();
  await dialog.getByRole('checkbox', { name: 'Tôi xác nhận', exact: false }).check(); await expect(dialog).toContainText('lan@example.test'); expect(await dialog.evaluate((element) => element.scrollWidth <= element.clientWidth)).toBe(true);
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog).toHaveCount(0);
  expect(state.writes[0]).toEqual({ method: 'PATCH', path: '/pos/memberships/membership_lan', body: { capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.discount.apply', 'pos.price.override'], staff_role_id: null } }); expect(memberships).toHaveLength(2);
  await open(page, 'branches/branch_main/staff?search=lan%40example.test'); await expect(page.getByRole('table').getByRole('row')).toHaveCount(2);
  await page.getByRole('button', { name: 'Cấp quyền nhân viên', exact: true }).click(); await expect(dialog.getByLabel('Chi nhánh', { exact: true })).toBeDisabled(); await dialog.getByLabel('Nhân viên', { exact: true }).click();
  await expect(page.getByRole('option')).toHaveText(['Chọn nhân viên', 'Trần Văn An · an@example.test']); await page.getByRole('option', { name: 'Trần Văn An · an@example.test', exact: true }).click(); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog).toHaveCount(0);
  expect(state.writes[1]).toMatchObject({ method: 'POST', path: '/pos/memberships', body: { branch_id: 'branch_main', staff_id: 'staff_an', capabilities: ['pos.shift.open'] } });
});
test('cashiers cannot enter administration and issue no topology requests', async ({ page }) => {
  const { state } = await install(page, { read: false, write: false }); await open(page);
  await expect(page.getByText('Tài khoản chưa có quyền xem hoặc quản trị', { exact: false })).toBeVisible(); await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toHaveCount(0); expect(state.staffPages).toEqual([]); expect(state.writes).toEqual([]);
});
test('read-only administration cannot write', async ({ page }) => {
  const { state } = await install(page, { read: true, write: false }); await open(page); await expect(page.getByText('Chỉ xem', { exact: true })).toBeVisible(); await page.getByRole('table').getByRole('button', { name: /^Siêu thị Hiền/ }).click(); await expect(page).toHaveURL(/\/store_1\/branches\/branch_main(?:\?|$)/); await expect(page.getByRole('tab', { name: 'Hàng bán', exact: true })).toBeVisible(); await expect(page.getByRole('button', { name: 'Sửa thông tin', exact: true })).toHaveCount(0); expect(state.writes).toEqual([]);
});
test('422 retains draft and field errors; failed option loads block editing', async ({ page }) => {
  const { state } = await install(page); await open(page); await act(page, 'Siêu thị Hiền', 'Chỉnh sửa'); const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Tên chưa lưu'); state.failSave = true; await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog.getByRole('alert').last()).toContainText('Code has already been taken'); await expect(dialog.getByLabel('Tên hiển thị')).toHaveValue('Tên chưa lưu'); await expect(dialog.getByLabel('Mã', { exact: true })).toHaveAttribute('aria-invalid', 'true');
  await dialog.getByRole('button', { name: 'Hủy', exact: true }).click(); await confirm(page, 'Đóng'); state.failOptions = true; await page.reload(); await expect(page.getByText('Không tải được đầy đủ dữ liệu cấu hình.', { exact: false })).toBeVisible(); await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toBeDisabled();
});
