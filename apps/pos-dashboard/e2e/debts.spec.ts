import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

const account = {
  credit_account_id: 'ca_1', currency: 'VND', customer: { id: 'cus_1', name: 'Chị Hoa', phone: '0901 234 567', address: '12 Lê Lợi' },
  orders: 2, credit_limit: '5000000.0', account_status: 'active', balance: '700000.0', overdue: '200000.0', current: '500000.0',
  days_1_30: '200000.0', days_31_60: '0.0', days_61_90: '0.0', days_over_90: '0.0', oldest_placed_at: '2026-10-01T03:00:00Z',
  days_owed: 40, days_overdue: 10, last_reminded_at: null,
  open_orders: [{ order_id: 'ord_1', order_number: 'R100', placed_at: '2026-10-01T03:00:00Z', due_on: '2026-10-31', balance: '200000.0' }],
  pay_later: null,
};
const masked = { ...account, credit_account_id: 'ca_2', customer: { id: 'cus_2', name: 'Anh Nam', phone: '•••• 789', address: null }, overdue: '0.0', days_overdue: 0 };
const debt = (id: string, number: string, overdue: boolean) => ({
  order_id: id, order_number: number, workspace_id: `ws_${id}`, credit_account_id: 'ca_1', customer: account.customer, currency: 'VND',
  original_total: '500000.0', paid_at_sale: '100000.0', debt: '400000.0', credit_notes: '0.0', collected: '50000.0', refunds: '0.0',
  balance: '350000.0', due_on: '2026-10-31', overdue, days_overdue: overdue ? 10 : 0, aging: overdue ? 'days_1_30' : 'current', placed_at: '2026-10-01T03:00:00Z',
});
const creditAccount = {
  id: 'ca_1', customer_id: 'cus_1', customer_name: 'Chị Hoa', customer_phone: '0901 234 567', status: 'active', currency: 'VND',
  credit_limit: '5000000.0', due_days: 30, open_debt: '700000.0', reserved: '0.0', available: '4300000.0',
};
const creditRequest = {
  id: 'cr_1', branch_id: 'branch_main', workspace_id: 'ws_9', order_number: 'P0009', customer: { id: 'cus_1', name: 'Chị Hoa' },
  requester: { id: 'staff_lan', name: 'Lan' }, amount: '300000.0', currency: 'VND', workspace_revision: 3, status: 'pending', reason: null,
  created_at: '2026-11-10T02:00:00Z', decided_at: null, approval_id: null, approval_active: false,
};
const pendingReturn = {
  id: 'ret_1', branch_id: 'branch_main', sale_branch_id: 'branch_main', order_id: 'ord_5', order_number: 'P0005', return_number: 'TH0001',
  requester_id: 'staff_lan', requester_name: 'Lan', status: 'pending_approval', entitlement_status: 'pending', reason: 'Hàng lỗi',
  cross_branch: false, out_of_window: true, damaged: false, requires_approval: true, revision: 1, approval: null, currency: 'VND',
  entitlement_total: '150000.0', credit_note_amount: '0.0', refund_entitlement: '150000.0', refund_requested: '0.0', refunded: '0.0',
  created_at: '2026-11-10T02:00:00Z', received_at: null,
};

type Write = { path: string; method: string; body: Record<string, unknown>; key: string | null };
async function install(page: Page, capabilities: string[], features: Record<string, boolean> = { credit: true }) {
  const state = { writes: [] as Write[], lists: [] as { path: string; params: Record<string, string> }[] };
  const accounts = [{ ...creditAccount }];
  await page.addInitScript(() => {
    // Reminders fall back to the clipboard where no share sheet exists.
    Object.defineProperty(navigator, 'share', { value: undefined, configurable: true });
    Object.defineProperty(navigator, 'clipboard', { value: { writeText: async (text: string) => { (window as unknown as { copied: string }).copied = text; } }, configurable: true });
  });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    const params = Object.fromEntries(url.searchParams.entries());
    if (request.method() !== 'GET') state.writes.push({ path, method: request.method(), body: request.postDataJSON() ?? {}, key: request.headers()['idempotency-key'] ?? null });
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, { capabilities, features }) });
    if (path === '/pos/receivables/customers') {
      return route.fulfill({ json: { data: [account, masked], meta: { count: 2, totals: { balance: '1400000.0', overdue: '200000.0', current: '1200000.0', days_1_30: '200000.0', days_31_60: '0.0', days_61_90: '0.0', days_over_90: '0.0' } } } });
    }
    if (path === '/pos/receivables') {
      state.lists.push({ path, params });
      const rows = [debt('ord_1', 'R100', true), debt('ord_2', 'R101', false)];
      return route.fulfill({ json: { data: rows, meta: pageMeta(rows.length, 1, Number(params.limit || 25)) } });
    }
    if (path === '/pos/receivables/customers/ca_1/remind') return route.fulfill({ json: { data: { credit_account_id: 'ca_1', last_reminded_at: '2026-11-10T05:00:00Z' } } });
    if (path === '/pos/credit_accounts' && request.method() === 'GET') return route.fulfill({ json: { data: accounts, meta: pageMeta(accounts.length) } });
    if (path === '/pos/credit_accounts') {
      const created = { ...creditAccount, id: 'ca_3', customer_id: 'cus_3', customer_name: 'Cô Mai', customer_phone: null, credit_limit: '2000000.0', due_days: 15 };
      accounts.push(created);
      return route.fulfill({ json: { data: created } });
    }
    if (path === '/pos/customers') return route.fulfill({ json: { data: [{ id: 'cus_3', name: 'Cô Mai', phone: null }], meta: pageMeta(1) } });
    if (path === '/pos/credit_requests') return route.fulfill({ json: { data: [creditRequest], meta: pageMeta(1) } });
    if (path === '/pos/credit_requests/cr_1/approve') return route.fulfill({ json: { data: { ...creditRequest, status: 'approved', approval_active: true } } });
    if (path === '/pos/returns') return route.fulfill({ json: { data: [pendingReturn], meta: pageMeta(1) } });
    if (path === '/pos/returns/ret_1/cancel') return route.fulfill({ json: { data: { ...pendingReturn, status: 'canceled' } } });
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}
const MENU = /^(Open actions|Mở menu thao tác)$/;

test('a collector reads who owes, opens a customer and copies a reminder', async ({ page }, testInfo) => {
  const state = await install(page, ['pos.payment.collect']);
  await page.goto('/store_1/receivables');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Công nợ phải thu');
  await expect(page.getByLabel('Tuổi nợ')).toContainText('200.000');
  const table = page.getByRole('table');
  await expect(table.getByRole('row').filter({ hasText: 'Anh Nam' })).toContainText('•••• 789');
  await page.screenshot({ path: testInfo.outputPath('receivables.png'), fullPage: true });

  await table.getByRole('row').filter({ hasText: 'Chị Hoa' }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Xem khách nợ' }).click();
  const sheet = page.getByRole('dialog');
  await expect(sheet.getByRole('link', { name: '0901 234 567' })).toHaveAttribute('href', 'tel:0901234567');
  await expect(sheet).toContainText('R100');
  expect(state.lists.at(-1)?.params).toMatchObject({ branch_id: 'branch_main', customer_id: 'cus_1', status: 'open' });
  await sheet.getByRole('button', { name: 'Chép tin nhắc nợ' }).click();
  await expect(sheet.getByRole('status')).toContainText('Đã chép tin nhắn');
  expect(await page.evaluate(() => (window as unknown as { copied: string }).copied)).toContain('R100');
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/receivables/customers/ca_1/remind', body: { branch_id: 'branch_main', via: 'copy' } });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});

test('the debts tab filters orders by status on the server', async ({ page }) => {
  const state = await install(page, ['pos.payment.collect']);
  await page.goto('/store_1/receivables/orders?status=overdue');
  await expect(page.getByRole('table').getByRole('row').filter({ hasText: 'R100' })).toBeVisible();
  expect(state.lists.at(-1)?.params).toMatchObject({ status: 'overdue', page: '1' });
});

test('a credit manager opens a credit account for a customer', async ({ page }) => {
  const state = await install(page, ['pos.credit.manage', 'pos.payment.collect']);
  await page.goto('/store_1/credit-accounts');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Tài khoản nợ');
  await page.getByRole('button', { name: 'Mở tài khoản công nợ' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tìm khách theo tên hoặc số điện thoại').fill('Mai');
  await dialog.getByRole('button', { name: /Cô Mai/ }).click();
  await dialog.getByLabel('Hạn mức').fill('2000000');
  await dialog.getByLabel('Số ngày nợ').fill('15');
  await dialog.getByRole('button', { name: 'Mở tài khoản công nợ' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Cô Mai' })).toBeVisible();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/credit_accounts', method: 'POST', body: { branch_id: 'branch_main', customer_id: 'cus_3', credit_limit: '2000000', due_days: 15 } });
  expect(typeof state.writes.at(-1)?.body.idempotency_key).toBe('string');
});

test('an approver approves a credit sale and rejects a return with a reason', async ({ page }, testInfo) => {
  const state = await install(page, ['pos.approval.grant', 'pos.credit.manage']);
  await page.goto('/store_1/credit-approvals');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Duyệt cho nợ');
  // Closing-count variances are decided on the shifts screen, not here.
  await expect(page.getByRole('region', { name: 'Duyệt chênh lệch đóng ca' })).toHaveCount(0);
  await page.screenshot({ path: testInfo.outputPath('credit-approvals.png'), fullPage: true });

  const credit = page.getByRole('region', { name: 'Duyệt ghi nợ' });
  await credit.getByRole('row').filter({ hasText: 'P0009' }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Duyệt ghi nợ' }).click();
  await expect(credit.getByRole('status')).toContainText('P0009');
  expect(state.writes.at(-1)?.path).toBe('/pos/credit_requests/cr_1/approve');

  const returns = page.getByRole('region', { name: 'Trả hàng và hoàn tiền' });
  await returns.getByRole('row').filter({ hasText: 'TH0001' }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Từ chối' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('textbox').fill('Quá hạn đổi trả');
  await dialog.getByRole('button', { name: 'Từ chối' }).click();
  await expect(returns.getByRole('status')).toContainText('TH0001');
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/returns/ret_1/cancel', body: { reason: 'Quá hạn đổi trả' } });
});

test('cashiers cannot open credit accounts or approvals', async ({ page }) => {
  await install(page, ['pos.shift.open', 'pos.payment.collect']);
  await page.goto('/store_1/credit-accounts');
  await expect(page.getByRole('alert')).toContainText('Không có quyền truy cập');
  await page.goto('/store_1/credit-approvals');
  await expect(page.getByRole('alert')).toContainText('Không có quyền truy cập');
});
