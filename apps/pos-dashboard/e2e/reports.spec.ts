import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { posContext } from './support/pos-context';

type Row = Record<string, unknown>;
const ROWS: Record<string, Row[]> = {
  sales: [{ order_number: 'R100', sold_at: '2026-11-06T17:30:00Z', business_date: '2026-11-07', order_source: 'zalo', register: 'Q1', cashier: 'Lan', item_total: '250000.0', adjustment_total: '0.0', total: '250000.0', currency: 'VND' }],
  returns: [{ return_id: 'RT1', order_number: 'R090', returned_at: '2026-11-07T03:00:00Z', receiver: 'Lan', entitlement_total: '50000.0', credit_note_amount: '0.0', refund_entitlement: '50000.0', currency: 'VND' }],
  receipts: [{ received_at: '2026-11-06T13:30:00Z', booked_at: '2026-11-07T02:00:00Z', kind: 'bank_manual', source: 'unsolicited', custody: 'drawer', received_net: '70000.0', currency: 'VND', cashier: 'Hà' }],
  cashbook: [{ at: '2026-11-07T02:00:00Z', register: 'Q1', cashier: 'Lan', category: 'safe_drop', amount: '-30000.0', running_expected: '70000.0', reason: 'Nộp két', currency: 'VND' }],
  receivables: [],
  closures: [{ closed_at: '2026-11-06T14:00:00Z', register: 'Q1', cashier: 'Mai', expected: '0.0', counted: '100000.0', variance: '100000.0', reason: 'Thừa', approver: 'Hà', reconciled: '0.0', currency: 'VND' }],
};
const SHIFT_LINES = [
  { shift_id: 'sh_1', register: 'Q1', cashier: 'Lan', status: 'open', opened_at: '2026-11-07T01:00:00Z', opening_float: '50000.0', expected: '70000.0', counted: null, variance: null },
  { shift_id: 'sh_s1', register: 'Q2', cashier: 'Mai', status: 'closed', opened_at: '2026-11-06T01:00:00Z', opening_float: '0.0', expected: '0.0', counted: '100000.0', variance: '100000.0' },
];
const exportRow = (id: string, type: string, status: string, expires = '2099-01-01T00:00:00Z') => ({
  id, branch_id: 'branch_main', report_type: type, filters: { from: '2026-11-07', to: '2026-11-07' }, status, row_count: 1,
  error_message: null, expires_at: expires, completed_at: '2026-11-07T10:00:01Z', created_at: '2026-11-07T10:00:00Z',
});

async function install(page: Page, options: { capabilities: string[]; features?: Record<string, boolean> }) {
  const state = {
    reports: [] as { type: string; params: Record<string, string> }[],
    writes: [] as { path: string; body: Row; key: string | null }[],
  };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, options) });
    const report = /^\/pos\/reports\/(\w+)$/.exec(path);
    if (report) {
      const type = report[1];
      const params = Object.fromEntries(url.searchParams.entries());
      state.reports.push({ type, params });
      const shiftPage = Number(params.shift_page ?? '1');
      const rows = type === 'sales' && params.section === 'returns' ? ROWS.returns : (ROWS[type] ?? []);
      const summary =
        type === 'sales'
          ? { orders: 1, sales_total: '250000.0', net_sales: '250000.0', by_source: [{ order_source: 'zalo', orders: 1, sales_total: '250000.0', owed: '0.0' }] }
          : type === 'cashbook'
            ? { shifts: [SHIFT_LINES[shiftPage - 1]], shift_count: 2, shift_page: shiftPage, shift_pages: 2 }
            : {};
      return route.fulfill({
        json: {
          data: rows,
          meta: { report: type, page: 1, pages: 1, count: rows.length, limit: Number(params.limit), scope: 'branch', timezone: 'Asia/Ho_Chi_Minh', from: params.from ?? null, to: params.to ?? null, summary },
        },
      });
    }
    if (path === '/pos/exports' && request.method() === 'GET') {
      const made = state.writes.some((write) => write.path === '/pos/exports');
      return route.fulfill({
        json: { data: made ? [exportRow('posexport_1', 'sales', 'ready'), exportRow('posexport_2', 'closures', 'ready'), exportRow('posexport_3', 'cashbook', 'expired', '2026-10-02T10:00:00Z')] : [] },
      });
    }
    if (request.method() === 'POST') state.writes.push({ path, body: request.postDataJSON() ?? {}, key: request.headers()['idempotency-key'] ?? null });
    if (path === '/pos/exports') return route.fulfill({ status: 202, json: { data: exportRow('posexport_1', 'sales', 'queued') } });
    if (path === '/pos/exports/posexport_1/download_link')
      return route.fulfill({ json: { data: { id: 'posexport_1', url: '/api/v3/admin/pos/export_files/signed-token', filename: 'sales-q1.csv', expires_at: '2099-01-01T00:00:00Z' } } });
    if (path === '/pos/exports/posexport_2/download_link')
      return route.fulfill({ status: 410, json: { error: { code: 'export_expired', message: 'This export has expired.' } } });
    if (path === '/pos/export_files/signed-token')
      return route.fulfill({ headers: { 'Content-Type': 'text/csv; charset=utf-8', 'Content-Disposition': 'attachment; filename="sales-q1.csv"' }, body: 'order_number,total\nR100,250000.0\n' });
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [] } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}

const lastReport = (state: { reports: { type: string; params: Record<string, string> }[] }, type: string) =>
  [...state.reports].reverse().find((row) => row.type === type)?.params;

test('reports keep sales, receipts and drawer cash apart and export a CSV', async ({ page }, testInfo) => {
  const state = await install(page, { capabilities: ['pos.shift.open', 'pos.report.read', 'pos.report.export'] });
  await page.goto('/store_1/reports');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Báo cáo');
  const table = page.getByRole('table').last();
  await expect(table).toContainText('R100');
  await expect(table).toContainText('07/11/2026');
  await expect(table).toContainText('Zalo');
  await expect(page.getByRole('status').filter({ hasText: 'Cả chi nhánh' })).toBeVisible();
  await expect(page.getByLabel('Tổng hợp')).toContainText('250.000 ₫');
  await expect(page.getByRole('table', { name: 'Theo nguồn đơn' })).toContainText('Zalo');
  expect(lastReport(state, 'sales')).toMatchObject({ branch_id: 'branch_main', page: '1', limit: '50' });
  expect(lastReport(state, 'sales')?.from).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  await page.screenshot({ path: testInfo.outputPath('reports-sales.png'), fullPage: true });

  // The returns section of sales has its own columns.
  await page.getByRole('combobox', { name: 'Phần' }).click();
  await page.getByRole('option', { name: 'Trả hàng' }).click();
  await expect(page.getByRole('table').last()).toContainText('RT1');
  expect(lastReport(state, 'sales')).toMatchObject({ section: 'returns' });

  // A range preset and "mine" travel with the tabs; the section does not.
  await page.getByRole('button', { name: '7 ngày' }).click();
  await expect(page.getByRole('button', { name: '7 ngày' })).toHaveAttribute('aria-pressed', 'true');
  await page.getByText('Chỉ ca của tôi').click();
  await expect.poll(() => lastReport(state, 'sales')?.cashier_id).toBe('staff_admin');

  await page.getByRole('link', { name: 'Thực thu' }).click();
  await expect(page).toHaveURL(/\/store_1\/reports\/receipts/);
  await expect(page.getByRole('table').last()).toContainText('Ngoài luồng');
  await expect(page.getByRole('table').last()).toContainText('Chuyển khoản');
  expect(lastReport(state, 'receipts')).toMatchObject({ cashier_id: 'staff_admin' });
  expect(lastReport(state, 'receipts')?.section).toBeUndefined();

  await page.getByRole('link', { name: 'Tiền mặt trong két' }).click();
  const shifts = page.getByRole('table', { name: 'Tóm tắt theo ca' });
  await expect(shifts).toContainText('Lan');
  await expect(shifts).toContainText('Chưa đếm');
  await page.getByRole('navigation', { name: 'Trang tóm tắt ca' }).getByRole('button', { name: 'Trang sau' }).click();
  await expect(shifts).toContainText('Thừa 100.000 ₫');
  expect(lastReport(state, 'cashbook')).toMatchObject({ shift_page: '2' });
  await expect(page.getByRole('table').last()).toContainText('Nộp két sắt');

  // Shifts seen in the cashbook become a filter.
  await page.getByRole('combobox', { name: 'Ca', exact: true }).click();
  await page.getByRole('option', { name: /^Mai · Q2/ }).click();
  await expect.poll(() => lastReport(state, 'cashbook')?.shift_id).toBe('sh_s1');

  await page.locator('#main-content').getByRole('link', { name: 'Công nợ', exact: true }).click();
  await expect(page.getByLabel('Từ ngày')).toHaveCount(0);
  await expect(page.getByText('Không có dữ liệu cho bộ lọc này.')).toBeVisible();
  expect(lastReport(state, 'receivables')?.from).toBeUndefined();

  await page.getByRole('link', { name: 'Đóng ca' }).click();
  await expect(page.getByRole('table').last()).toContainText('Thừa 100.000 ₫');

  await page.getByRole('link', { name: 'Doanh số' }).click();
  await page.getByRole('button', { name: 'Xuất CSV' }).click();
  await expect(page.getByText('Đã nhận yêu cầu xuất')).toBeVisible();
  const exported = state.writes.find((write) => write.path === '/pos/exports');
  expect(exported?.body).toMatchObject({ branch_id: 'branch_main', report_type: 'sales' });
  expect(exported?.key).toBeTruthy();
  expect(Object.keys(exported?.body.filters as Record<string, string>).sort()).toEqual(['cashier_id', 'from', 'shift_id', 'to']);

  const list = page.getByRole('list', { name: 'File xuất của bạn' });
  await expect(list.getByRole('listitem')).toHaveCount(3);
  await expect(list.getByRole('listitem').filter({ hasText: 'Đã hết hạn' }).getByRole('button')).toHaveCount(0);
  const download = page.waitForEvent('download');
  await list.getByRole('listitem').filter({ hasText: 'Doanh số' }).getByRole('button', { name: 'Tải về' }).click();
  expect((await download).suggestedFilename()).toBe('sales-q1.csv');
  await list.getByRole('listitem').filter({ hasText: 'Đóng ca' }).getByRole('button', { name: 'Tải về' }).click();
  await expect(page.getByText('Bản xuất đã hết hạn, hãy tạo lại')).toBeVisible();
});

test('an invalid range asks nothing and exports switched off keep the button disabled', async ({ page }) => {
  const state = await install(page, {
    capabilities: ['pos.shift.open', 'pos.report.read', 'pos.report.export'],
    features: { exports: false },
  });
  await page.goto('/store_1/reports/receipts?from=2026-11-10&to=2026-11-01');
  await expect(page.getByRole('alert').filter({ hasText: 'Khoảng ngày không hợp lệ' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Xuất CSV' })).toBeDisabled();
  await expect(page.getByRole('note')).toContainText('Xuất CSV chưa được bật');
  expect(state.reports.filter((row) => row.type === 'receipts')).toHaveLength(0);
});

test('a reader without export rights sees no exports', async ({ page }) => {
  await install(page, { capabilities: ['pos.shift.open', 'pos.report.read'] });
  await page.goto('/store_1/reports/closures');
  await expect(page.getByRole('table').last()).toContainText('Mai');
  await expect(page.getByRole('button', { name: 'Xuất CSV' })).toHaveCount(0);
  await expect(page.getByRole('list', { name: 'File xuất của bạn' })).toHaveCount(0);
});
