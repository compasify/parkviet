import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';

// Presentation fixtures only, not grants of real API privileges.
async function install(page: Page, access = { read: true, write: true }) {
  const branch = { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main' };
  const methods = [
    { id: 'pospm_cash', code: 'cash', name: 'Tiền mặt', kind: 'cash', payment_method_id: null, status: 'active', position: 0 },
    { id: 'pospm_bank', code: 'bank', name: 'Chuyển khoản', kind: 'bank_manual', payment_method_id: null, status: 'active', position: 1 },
  ];
  const units = [
    { id: 'posunit_item', code: 'item', name: 'Cái', dimension: 'count', base_code: 'item', factor_to_base: 1, sale_precision: 0, version: 1, status: 'active' },
    { id: 'posunit_chai', code: 'chai', name: 'Chai', dimension: 'count', base_code: 'chai', factor_to_base: 1, sale_precision: 0, version: 1, status: 'active' },
    { id: 'posunit_g', code: 'g', name: 'Gram', dimension: 'mass', base_code: 'g', factor_to_base: 1, sale_precision: 0, version: 1, status: 'active' },
  ];
  const roles = [{ id: 'posrole_cashier', name: 'Thu ngân', capabilities: ['pos.shift.open', 'pos.payment.collect'], status: 'active', membership_count: 2 }];
  const state = { writes: [] as { method: string; path: string; body: unknown }[] };
  const conflict = (reason: string) => ({ status: 409, json: { error: { code: 'conflict', message: 'Refused.', details: { reason } } } });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', ''); const method = request.method();
    const body = method === 'GET' || method === 'DELETE' ? null : (request.postDataJSON() as Record<string, unknown>);
    if (method !== 'GET') state.writes.push({ method, path, body });
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Quản trị Hiền' }, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: access, capabilities: [], branches: [branch], registers: [], selection: { branch_id: url.searchParams.get('branch_id'), register_id: null } } });
    if (path === '/pos/payment_methods' && method === 'GET') return route.fulfill({ json: { data: methods } });
    if (path === '/pos/payment_methods') { const row = { id: 'pospm_new', code: 'momo', status: 'active', payment_method_id: null, position: 2, ...body }; methods.push(row as (typeof methods)[number]); return route.fulfill({ status: 201, json: { data: row } }); }
    const method_ = /^\/pos\/payment_methods\/([^/]+)$/.exec(path);
    if (method_) {
      const row = methods.find((m) => m.id === method_[1]);
      if (method === 'DELETE') return route.fulfill(conflict('payment_method_in_use'));
      if (row?.kind === 'cash' && body?.status === 'disabled') return route.fulfill(conflict('last_cash_method'));
      Object.assign(row ?? {}, body); return route.fulfill({ json: { data: row } });
    }
    if (path === '/pos/units' && method === 'GET') return route.fulfill({ json: { data: units } });
    if (path === '/pos/units') { const row = { id: 'posunit_new', version: 1, status: 'active', ...body }; units.push(row as (typeof units)[number]); return route.fulfill({ status: 201, json: { data: row } }); }
    if (/^\/pos\/units\/[^/]+\/disable$/.test(path)) return route.fulfill(conflict('unit_in_use'));
    if (path === '/pos/staff_roles' && method === 'GET') return route.fulfill({ json: { data: roles, meta: { next: null } } });
    if (path === '/pos/staff_roles') { const row = { id: 'posrole_new', status: 'active', membership_count: 0, ...body }; roles.push(row as (typeof roles)[number]); return route.fulfill({ status: 201, json: { data: row } }); }
    if (/^\/pos\/staff_roles\/[^/]+$/.test(path)) return route.fulfill(conflict('staff_role_in_use'));
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  await installDashboardShell(page, { authenticated: true, ...access });
  return state;
}
// Spree's own strings are English under the dev server, which pre-bundles the
// framework without its locale files; the production build carries both.
const MENU = /^(Open actions|Mở menu thao tác)$/;
async function act(page: Page, row: string, item: string) { await page.getByRole('row', { name: row }).getByRole('button', { name: MENU }).click(); await page.getByRole('menuitem', { name: item, exact: true }).click(); }
async function confirm(page: Page, action: string) { await page.getByRole('dialog').last().getByRole('button', { name: action, exact: true }).click(); }
async function select(page: Page, label: string, option: string) { await page.getByRole('dialog').getByLabel(label, { exact: true }).click(); await page.getByRole('option', { name: option, exact: true }).click(); }

test('the configuration group lists store master data and keeps branch settings on the branch page', async ({ page }, testInfo) => {
  await install(page); await page.goto('/store_1/payment-methods');
  // The phone drawer is closed until opened; the tablet sidebar is already docked.
  if (testInfo.project.name === 'mobile') await page.getByRole('button', { name: 'Toggle Sidebar' }).click();
  const sidebar = page.locator('[data-sidebar="sidebar"]').first();
  for (const name of ['Chi nhánh', 'Mẫu in', 'Phương thức thanh toán', 'Đơn vị tính', 'Nhóm quyền', 'Mẫu tem cân']) await expect(sidebar.getByRole('link', { name, exact: true })).toBeVisible();
  for (const name of ['Quầy bán hàng', 'Nhân viên & quyền', 'Hàng bán tại chi nhánh', 'Chức năng chi nhánh', 'Mô hình kinh doanh']) await expect(sidebar.getByRole('link', { name, exact: true })).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'Cài đặt cửa hàng', exact: true })).toBeVisible();
});

test('payment methods are created, refused as the last cash method and never deleted once used', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/payment-methods'); const table = page.getByRole('table');
  await expect(table).toContainText('Chuyển khoản');
  await page.getByRole('button', { name: 'Thêm phương thức', exact: true }).click(); const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Ví MoMo'); await dialog.getByLabel('Mã', { exact: true }).fill('momo'); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog).toHaveCount(0);
  expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/payment_methods', body: { kind: 'bank_manual', code: 'momo', name: 'Ví MoMo' } });
  await act(page, 'Tiền mặt', 'Ngừng hoạt động'); await confirm(page, 'Ngừng hoạt động');
  await expect(page.getByRole('alert')).toHaveText('Cửa hàng cần ít nhất một phương thức tiền mặt đang dùng.');
  await act(page, 'Chuyển khoản bank', 'Xóa'); await confirm(page, 'Xóa');
  await expect(page.getByRole('alert')).toHaveText('Phương thức này đã được dùng để thanh toán; hãy ngừng hoạt động thay vì xóa.');
});

test('units convert to a base unit of their dimension and refuse disabling while in use', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/units');
  await page.getByRole('button', { name: 'Thêm đơn vị', exact: true }).click(); const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Thùng 24'); await dialog.getByLabel('Mã', { exact: true }).fill('thung24');
  await select(page, 'Quy đổi về', 'Chai (chai)'); await dialog.getByLabel('Hệ số quy đổi').fill('24'); await dialog.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(dialog).toHaveCount(0);
  expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/units', body: { code: 'thung24', name: 'Thùng 24', dimension: 'count', base_code: 'chai', factor_to_base: 24, sale_precision: 0 } });
  await act(page, 'Gram', 'Ngừng hoạt động'); await confirm(page, 'Ngừng hoạt động');
  await expect(page.getByRole('alert')).toHaveText('Đơn vị đang được hàng hóa hoặc mẫu tem dùng nên chưa thể ngừng.');
});

test('staff roles group capabilities, confirm sensitive grants and refuse deleting a role in use', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/staff-roles');
  await page.getByRole('button', { name: 'Thêm nhóm quyền', exact: true }).click(); const dialog = page.getByRole('dialog');
  await expect(dialog.getByRole('group', { name: 'Bán hàng', exact: true }).getByRole('checkbox')).toHaveCount(6);
  await dialog.getByLabel('Tên hiển thị').fill('Quản lý ca'); await dialog.getByRole('checkbox', { name: 'Thu/chi tiền mặt trong két', exact: true }).check();
  const save = dialog.getByRole('button', { name: 'Lưu', exact: true }); await expect(save).toBeDisabled();
  await dialog.getByRole('checkbox', { name: 'Tôi xác nhận', exact: false }).check(); await save.click(); await expect(dialog).toHaveCount(0);
  expect(state.writes.at(-1)).toMatchObject({ method: 'POST', path: '/pos/staff_roles', body: { name: 'Quản lý ca', capabilities: ['pos.cash.move'] } });
  await act(page, 'Thu ngân', 'Xóa'); await confirm(page, 'Xóa');
  await expect(page.getByRole('alert')).toHaveText('Nhóm quyền đang được gán cho nhân viên nên chưa thể ngừng hoặc xóa.');
});

test('read-only administrators see master data without write actions', async ({ page }) => {
  const state = await install(page, { read: true, write: false });
  for (const path of ['payment-methods', 'units', 'staff-roles']) {
    await page.goto(`/store_1/${path}`); await expect(page.getByText('Chỉ xem', { exact: true })).toBeVisible();
    await expect(page.getByRole('table').getByRole('row').nth(1)).toBeVisible();
  }
  expect(state.writes).toEqual([]);
});
