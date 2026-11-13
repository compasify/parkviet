import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';

// Presentation fixtures only, not grants of real API privileges.
type Mode = 'owner' | 'manager';
async function install(page: Page, mode: Mode = 'owner', modules: Record<string, boolean> = { 'retail.measured': true }) {
  const branch = { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null, business_day_cutoff: '04:00', profile_key: 'khac' };
  const methods = [
    { id: 'pospm_cash', code: 'cash', name: 'Tiền mặt', kind: 'cash', payment_method_id: null, status: 'active', position: 0 },
    { id: 'pospm_bank', code: 'bank', name: 'Chuyển khoản', kind: 'bank_manual', payment_method_id: null, status: 'active', position: 1 },
    { id: 'pospm_qr', code: 'qr', name: 'VietQR cũ', kind: 'vietqr', payment_method_id: null, status: 'disabled', position: 2 },
  ];
  const formats = [
    { id: 'poslabel_1', branch_ids: ['branch_main'], name: 'Cân quầy thịt', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g', price_tolerance: '0.0', version: 1, status: 'active' },
    { id: 'poslabel_2', branch_ids: [], name: 'Tem giá rau', prefix: '22', kind: 'price', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: null, price_tolerance: '500.0', version: 1, status: 'active' },
  ];
  const templates = [
    { id: 'postpl_sale', document_type: 'sale', name: 'Phiếu bán mặc định', paper: '80mm', status: 'active', is_default: true },
    { id: 'postpl_k58', document_type: 'sale', name: 'Bán hàng K58', paper: '58mm', status: 'active', is_default: false },
  ];
  const state = { writes: [] as { method: string; path: string; body: unknown }[], customized: false, enabled: ['pospm_cash', 'pospm_bank'], assigned: ['poslabel_1'], sale: null as string | null };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', ''); const method = request.method();
    const body = method === 'GET' || method === 'DELETE' ? null : request.postDataJSON();
    if (method !== 'GET') state.writes.push({ method, path, body });
    const selected = url.searchParams.get('branch_id');
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Quản trị Hiền' }, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: { read: mode === 'owner', write: mode === 'owner' }, capabilities: mode === 'manager' && selected === 'branch_main' ? ['pos.topology.manage'] : [], branches: [branch], registers: [], modules, selection: { branch_id: selected, register_id: null }, onboarding: { required: false, can_setup: mode === 'owner' } } });
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }] } });
    if (path === '/pos/branches/branch_main/payment_methods') {
      if (method === 'PUT') { const ids = (body as { payment_method_ids: string[] | null }).payment_method_ids; state.customized = ids !== null; state.enabled = ids ?? ['pospm_cash', 'pospm_bank']; }
      return route.fulfill({ json: { data: { branch_id: 'branch_main', customized: state.customized, payment_methods: methods.map((m) => ({ ...m, enabled: m.status === 'active' && state.enabled.includes(m.id) })) } } });
    }
    if (path === '/pos/label_formats') return route.fulfill({ json: { data: formats, meta: { next: null } } });
    if (path === '/pos/branches/branch_main/label_formats') {
      if (method === 'PUT') state.assigned = (body as { label_format_ids: string[] }).label_format_ids;
      return route.fulfill({ json: { data: formats.filter((f) => state.assigned.includes(f.id)), meta: { next: null } } });
    }
    if (path === '/pos/receipt_templates') return route.fulfill({ json: { data: templates.map((tpl) => ({ ...tpl, current_version: 1, version: 1, config: {}, updated_by: null, created_at: '2026-11-01T00:00:00Z', updated_at: '2026-11-01T00:00:00Z' })) } });
    if (path === '/pos/branches/branch_main/receipt_templates') {
      if (method === 'PUT') state.sale = (body as { templates: { sale?: string | null } }).templates.sale ?? null;
      const chosen = templates.find((tpl) => tpl.id === state.sale) ?? null;
      return route.fulfill({ json: { data: { branch_id: 'branch_main', templates: [{ document_type: 'sale', receipt_template: chosen, effective_template: chosen ?? templates[0], uses_store_default: !chosen }] } } });
    }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  await installDashboardShell(page, { authenticated: true, read: mode === 'owner', write: mode === 'owner' });
  return state;
}
const tabs = (page: Page) => page.getByRole('tablist').getByRole('tab');

test('a branch row opens its page with every tab and the selection follows the branch', async ({ page }, testInfo) => {
  await install(page); await page.goto('/store_1/branches');
  await page.getByRole('table').getByRole('button', { name: /^Siêu thị Hiền/ }).click();
  await expect(page).toHaveURL(/\/store_1\/branches\/branch_main\?.*branch=branch_main/);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Siêu thị Hiền');
  await expect(tabs(page)).toHaveText(['Tổng quan', 'Quầy', 'Nhân viên & quyền', 'Hàng bán', 'Chức năng', 'Thanh toán', 'In ấn', 'Bếp & bar', 'Nền tảng giao hàng', 'Phần cứng']);
  await expect(page.getByText('Kho hàng trung tâm', { exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Sửa thông tin', exact: true })).toBeEnabled();
  await page.screenshot({ path: testInfo.outputPath('branch-overview.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});

test('old branch-setting URLs open the matching tab of the selected branch', async ({ page }) => {
  await install(page);
  for (const [from, to] of [['registers', '/registers'], ['staff', '/staff'], ['products', '/products'], ['features', '/features'], ['label-formats', '/features'], ['business-model', '']]) {
    await page.goto(`/store_1/${from}`);
    await expect(page).toHaveURL(new RegExp(`/store_1/branches/branch_main${to}(?:\\?|$)`));
  }
  await page.goto('/store_1/branches/branch_main/business-model'); await expect(page).toHaveURL(/\/store_1\/branches\/branch_main(?:\?|$)/);
  await page.goto('/store_1/branches/branch_main/label-formats'); await expect(page).toHaveURL(/\/store_1\/branches\/branch_main\/features(?:\?|$)/);
});

test('a branch manager reaches only the branch-management tabs of their branch', async ({ page }) => {
  const state = await install(page, 'manager'); await page.goto('/store_1/features?branch=branch_main');
  await expect(page).toHaveURL(/\/store_1\/branches\/branch_main\/features/);
  await expect(tabs(page)).toHaveText(['Tổng quan', 'Chức năng', 'Nền tảng giao hàng', 'Phần cứng']);
  await expect(page.getByRole('button', { name: 'Sửa thông tin', exact: true })).toHaveCount(0);
  await expect(page.getByRole('group', { name: 'Mẫu tem cân' })).toHaveCount(0);
  await page.goto('/store_1/branches/branch_main/payments?branch=branch_main');
  await expect(page.getByRole('heading', { name: 'Không có quyền truy cập', exact: true })).toBeVisible();
  expect(state.writes).toEqual([]);
});

test('payments tab picks methods or returns to every active method', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/branches/branch_main/payments');
  const all = page.getByRole('checkbox', { name: 'Dùng tất cả phương thức đang bật', exact: true });
  await expect(all).toBeChecked(); await expect(page.getByRole('checkbox', { name: 'Chuyển khoản', exact: true })).toBeDisabled();
  await expect(page.getByRole('checkbox', { name: 'VietQR cũ', exact: true })).not.toBeChecked();
  await all.uncheck(); await page.getByRole('checkbox', { name: 'Chuyển khoản', exact: true }).uncheck(); await page.getByRole('checkbox', { name: 'Tiền mặt', exact: true }).uncheck();
  await expect(page.getByText('Chi nhánh cần ít nhất một phương thức thanh toán.')).toBeVisible(); await expect(page.getByRole('button', { name: 'Lưu', exact: true })).toBeDisabled();
  await page.getByRole('checkbox', { name: 'Tiền mặt', exact: true }).check(); await page.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã lưu' })).toBeVisible();
  expect(state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/branches/branch_main/payment_methods', body: { payment_method_ids: ['pospm_cash'] } });
  await all.check(); await page.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect.poll(() => state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/branches/branch_main/payment_methods', body: { payment_method_ids: null } });
});

test('printing tab chooses a template per document or the store default', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/branches/branch_main/printing');
  const sale = page.getByRole('combobox', { name: 'Phiếu bán hàng', exact: true });
  await expect(sale).toContainText('Mặc định cửa hàng (Phiếu bán mặc định)');
  await sale.click(); await page.getByRole('option', { name: 'Bán hàng K58', exact: true }).click();
  await page.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect.poll(() => state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/branches/branch_main/receipt_templates', body: { templates: { sale: 'postpl_k58' } } });
  await sale.click(); await page.getByRole('option', { name: 'Mặc định cửa hàng (Phiếu bán mặc định)', exact: true }).click();
  await page.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect.poll(() => state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/branches/branch_main/receipt_templates', body: { templates: { sale: null } } });
});

test('features tab assigns shared scale label formats while measured goods are on', async ({ page }) => {
  const state = await install(page); await page.goto('/store_1/branches/branch_main/features');
  const formats = page.getByRole('group', { name: 'Mẫu tem cân' });
  await expect(formats.getByRole('checkbox', { name: 'Cân quầy thịt', exact: true })).toBeChecked();
  await formats.getByRole('checkbox', { name: 'Tem giá rau', exact: true }).check();
  await page.getByRole('region', { name: 'Mẫu tem cân' }).getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect.poll(() => state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/branches/branch_main/label_formats', body: { label_format_ids: ['poslabel_1', 'poslabel_2'] } });
});

test('features tab hides label formats when measured goods are off', async ({ page }) => {
  await install(page, 'owner', { 'retail.measured': false }); await page.goto('/store_1/branches/branch_main/features');
  await expect(page.getByRole('heading', { name: 'Chức năng chi nhánh', exact: true })).toBeVisible();
  await expect(page.getByRole('group', { name: 'Mẫu tem cân' })).toHaveCount(0);
});
