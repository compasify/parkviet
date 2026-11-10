import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

const number = (i: number) => `P${String(i).padStart(5, '0')}`;
const rows = Array.from({ length: 30 }, (_, index) => {
  const i = index + 1;
  return {
    id: `order_${i}`, number: number(i), workspace_id: `ws_${i}`, order_source: i === 2 ? 'facebook' : 'counter',
    placed_at: `2026-11-${String(10 - (i % 9)).padStart(2, '0')}T03:00:00Z`,
    register: i % 2 ? 'Quầy 1' : 'Quầy 2', cashier: i % 3 ? 'Lan' : 'Minh', cashier_id: i % 3 ? 'staff_lan' : 'staff_minh',
    customer: i === 1 ? { id: 'cust_1', name: 'Chị Hoa', phone: '0901234567' } : null,
    currency: 'VND', total: '150000.0', paid: i === 3 ? '100000.0' : '150000.0', debt: i === 3 ? '50000.0' : null,
    returned: i === 1, refund_pending: i === 1,
  };
});
const detail = {
  ...rows[0], sale_branch_id: 'branch_main',
  totals: { original_total: '150000.0', item_total: '150000.0', discount_total: '0.0', tax_total: '0.0' },
  lines: [{
    sale_line_id: 'sl_1', name: 'Gạo ST25', sku: 'ST25-5KG', sale_quantity: '2.0', sale_unit: 'túi', base_quantity: 2, base_unit: 'túi',
    unit_price: '75000.0', lot_code: null, serial_codes: [],
    original: { total: '150000.0', net: '150000.0', tax: '0.0', discount: '0.0', gross: '150000.0' },
    returned_quantity: 1, posted_quantity: 1, returnable_quantity: 1, handed_over: true, entitlement_used: '75000.0', entitlement_reserved: '0.0',
  }],
  entitlement: { used: '75000.0', reserved: '0.0', credit_notes: '0.0', refund_entitlement: '75000.0' },
  receipts: [{ allocation_id: 'al_1', funds_id: 'funds_1', kind: 'cash', status: 'active', amount: '150000.0', refunded: '0.0', refund_reserved: '75000.0', refundable: '150000.0', collection: false, reference: null, received_at: '2026-11-09T03:00:00Z' }],
  refunds: [], credit: null, exchanges: [],
  returns: [{ id: 'ret_1', return_number: 'TH00001', status: 'received', entitlement_total: '75000.0', refunded: '0.0', refund_requested: '75000.0' }],
  stock: { location_id: 'stock_main', fulfillments: [], restocked_quantity: 1, damaged_quantity: 0, discrepancies: [{ id: 'gap_1', sku: 'ST25-5KG', name: 'Gạo ST25', needed: 2, on_hand: 1, status: 'open', checked_at: '2026-11-09T03:00:00Z' }] },
  timeline: [{ id: 'tl_1', at: '2026-11-09T03:00:00Z', kind: 'placed', amount: '150000.0' }, { id: 'tl_2', at: '2026-11-09T04:00:00Z', kind: 'return_received', amount: '75000.0', reference: 'TH00001' }],
};

async function install(page: Page, capabilities = ['pos.shift.open', 'pos.payment.resolve']) {
  const order = structuredClone(detail);
  const state = { lists: [] as Record<string, string>[], writes: [] as { path: string; body: Record<string, unknown> }[], reconcileFails: true };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, { capabilities }) });
    if (path === '/pos/orders') {
      const params = Object.fromEntries(url.searchParams.entries()); state.lists.push(params);
      const matching = rows.filter((row) =>
        (!params.number || row.number.includes(params.number.toUpperCase())) &&
        (!params.register_id || row.register === (params.register_id === 'reg_1' ? 'Quầy 1' : 'Quầy 2')) &&
        (!params.cashier_id || row.cashier_id === params.cashier_id) &&
        (params.status !== 'debt' || row.debt) && (params.status !== 'refund_pending' || row.refund_pending));
      const page = Number(params.page || 1); const limit = Number(params.limit || 25);
      return route.fulfill({ json: { data: matching.slice((page - 1) * limit, page * limit), meta: pageMeta(matching.length, page, limit) } });
    }
    if (path === '/pos/orders/order_1') {
      expect(url.searchParams.get('branch_id')).toBe('branch_main');
      return route.fulfill({ json: { data: order } });
    }
    if (path === '/pos/orders/order_1/reconcile_handover') {
      state.writes.push({ path, body: request.postDataJSON() });
      if (state.reconcileFails) { state.reconcileFails = false; return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Retry.', details: { reason: 'retry' } } } }); }
      order.stock.discrepancies[0].status = 'resolved';
      return route.fulfill({ json: { data: { stock_discrepancies: [] } } });
    }
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}
async function choose(page: Page, label: string, option: string) {
  await page.getByLabel(label, { exact: true }).click();
  await page.getByRole('option', { name: option, exact: true }).click();
}
const filters = (rules: { field: string; operator: string; value: string }[]) =>
  `filters=${encodeURIComponent(JSON.stringify(rules.map((rule, i) => ({ id: `f${i}`, ...rule }))))}`;

test('order history pages, searches and filters on the server', async ({ page }, testInfo) => {
  const state = await install(page);
  await page.goto('/store_1/orders');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đơn hàng');
  await expect(page.getByText(/^1–25 (of|trong số) 30$/)).toBeVisible();
  expect(state.lists.at(-1)).toMatchObject({ branch_id: 'branch_main', status: 'all', page: '1', limit: '25' });
  await expect(page.getByText('Chị Hoa')).toBeVisible();
  await expect(page.getByText('Nợ 50.000', { exact: false }).first()).toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('orders.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);

  await page.goto('/store_1/orders?page=2');
  await expect(page.getByText(/^26–30 (of|trong số) 30$/)).toBeVisible();
  expect(state.lists.at(-1)).toMatchObject({ page: '2' });

  await page.goto('/store_1/orders?search=00012');
  await expect(page.getByText(/^1–1 (of|trong số) 1$/)).toBeVisible();
  expect(state.lists.at(-1)).toMatchObject({ number: '00012', page: '1' });

  await page.goto(`/store_1/orders?${filters([{ field: 'placed_at', operator: 'gteq', value: '2026-11-01' }, { field: 'placed_at', operator: 'lteq', value: '2026-11-08' }])}`);
  await expect.poll(() => state.lists.at(-1)).toMatchObject({ from: '2026-11-01', to: '2026-11-08' });

  await page.goto('/store_1/orders');
  await choose(page, 'Trạng thái', 'Còn nợ');
  await expect(page).toHaveURL(/status=debt/);
  await expect(page.getByText(/^1–\d+ (of|trong số) \d+$/)).toBeVisible();
  expect(state.lists.at(-1)).toMatchObject({ status: 'debt', page: '1' });
  await choose(page, 'Trạng thái', 'Mọi trạng thái');
  await choose(page, 'Quầy', 'Quầy 2');
  await expect.poll(() => state.lists.at(-1)?.register_id).toBe('reg_2');
  await choose(page, 'Thu ngân', 'Minh');
  await expect.poll(() => state.lists.at(-1)?.cashier_id).toBe('staff_minh');
});

test('order detail shows money, lines, returns and timeline and reconciles a short handover', async ({ page }, testInfo) => {
  const state = await install(page);
  await page.goto('/store_1/orders');
  await page.getByRole('button', { name: /^P00001/ }).click();
  await expect(page).toHaveURL(/\/store_1\/orders\/order_1$/);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đơn P00001');
  await expect(page.getByText('Gạo ST25').first()).toBeVisible();
  await expect(page.getByText('1 đã ghi · 0 đang giữ (túi)')).toBeVisible();
  await expect(page.getByRole('list', { name: 'Phiếu trả' })).toContainText('TH00001');
  await expect(page.getByRole('list', { name: 'Phiếu trả' })).toContainText('Đã nhận hàng');
  await expect(page.getByRole('list', { name: 'Diễn biến' })).toContainText('Nhận hàng trả TH00001');
  await expect(page.getByText('Chị Hoa')).toBeVisible();
  await expect(page.getByRole('link', { name: 'Trả / đổi hàng' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: /In|Mở hóa đơn/ })).toHaveCount(0);
  await page.screenshot({ path: testInfo.outputPath('order-detail.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);

  const reconcile = page.getByRole('button', { name: 'Giao lại sau đối soát kho' });
  await reconcile.click();
  await expect(page.getByRole('alert')).toHaveText('Một phiếu trả khác của cùng hàng vừa thay đổi; thử lại.');
  await reconcile.click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã giao hàng và trừ kho đúng một lần.' })).toBeVisible();
  await expect(reconcile).toHaveCount(0);
  expect(state.writes).toHaveLength(2);
  expect(typeof state.writes[0].body.idempotency_key).toBe('string');
  expect(state.writes[0].body.idempotency_key).not.toBe(state.writes[1].body.idempotency_key);
});

test('staff without payment resolve read the order but cannot reconcile; non-members are refused', async ({ page }) => {
  await install(page, ['pos.shift.open']);
  await page.goto('/store_1/orders/order_1');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đơn P00001');
  await expect(page.getByText('Thiếu tồn khi giao — cần đối soát kho')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Giao lại sau đối soát kho' })).toHaveCount(0);
  await page.unrouteAll({ behavior: 'ignoreErrors' });
  await install(page, []);
  await page.goto('/store_1/orders');
  await expect(page.getByRole('heading', { name: 'Không có quyền truy cập', exact: true })).toBeVisible();
});
