import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

// A resolver settles what GrabFood paid: picks the completed orders, corrects
// the commission the platform actually kept, records the payout reference,
// and the platform report shows the order as settled.
// Presentation fixtures only: no real account privileges.

const order = (id: string, ref: string, gross: string, commission: string) => ({
  id, workspace_id: `ws_${id}`, order_id: `order_${id}`, order_number: 3, business_date: '2026-11-11', platform: 'grabfood',
  platform_order_ref: ref, pickup_code: 'A12', status: 'completed', gross_amount: gross, commission_rate: '25.0',
  commission_amount: commission, net_amount: String(Number(gross) - Number(commission)) + '.0', currency: 'VND',
  entered_at: '2026-11-11T03:00:00Z', ready_at: null, completed_at: '2026-11-11T03:20:00Z', canceled_at: null,
  cancel_reason: null, settled_at: null as string | null, settlement_reference: null as string | null, items: [],
});

async function install(page: Page) {
  const orders = [order('posplatorder_1', 'GF-1001', '80000.0', '20000.0'), order('posplatorder_2', 'GF-1002', '60000.0', '15000.0')];
  const state = { lists: [] as Record<string, string>[], settles: [] as Record<string, unknown>[] };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') {
      const context = posContext(url, { capabilities: ['pos.payment.resolve', 'pos.report.read'] });
      return route.fulfill({ json: { ...context, modules: { 'fnb.menu': true, 'fnb.delivery_platforms': true } } });
    }
    if (path === '/pos/platform_orders') {
      const params = Object.fromEntries(url.searchParams.entries()); state.lists.push(params);
      const rows = orders.filter((row) => row.settled_at === null && (!params.platform || row.platform === params.platform));
      return route.fulfill({ json: { data: rows, meta: pageMeta(rows.length, 1, 50) } });
    }
    if (path === '/pos/platform_orders/settle') {
      const body = request.postDataJSON() as { reference: string; orders: { id: string; commission_amount?: string }[] };
      state.settles.push(body);
      const settled = body.orders.map((row) => {
        const target = orders.find((item) => item.id === row.id)!;
        if (row.commission_amount) target.commission_amount = `${row.commission_amount}.0`;
        target.settled_at = '2026-11-12T02:00:00Z';
        target.settlement_reference = body.reference;
        return target;
      });
      return route.fulfill({ json: { data: settled } });
    }
    if (path === '/pos/reports/platforms') {
      const settled = orders.filter((row) => row.settled_at);
      const row = { business_date: '2026-11-11', platform: 'grabfood', orders: 2, gross: '140000.0', commission: '33000.0', net: '107000.0',
        unsettled: settled.length ? '45000.0' : '105000.0', commission_estimated: settled.length ? '15000.0' : '35000.0', commission_actual: settled.length ? '18000.0' : '0.0' };
      return route.fulfill({ json: { data: [row], meta: { ...pageMeta(1, 1, 50), scope: 'branch', timezone: 'Asia/Ho_Chi_Minh', from: '2026-11-11', to: '2026-11-11', summary: { orders: 2 } } } });
    }
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}

test('settles a GrabFood payout at the actual commission and the report shows what is left', async ({ page }) => {
  const state = await install(page);
  await page.goto('/store_1/platform-settlement');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đối soát nền tảng');
  const table = page.getByTestId('platform-settlement-table');
  await expect(table.getByRole('row')).toHaveCount(3);
  expect(state.lists.at(-1)).toMatchObject({ branch_id: 'branch_main', status: 'unsettled' });

  await page.getByLabel('Chọn đơn GF-1001').check();
  await page.getByLabel('Phí thực tế của đơn GF-1001').fill('18000');
  await page.getByLabel('Mã thanh toán của nền tảng').fill('GRAB-0311');
  await page.getByTestId('platform-settle').click();
  await expect(page.getByText('Đã đối soát 1 đơn.')).toBeVisible();
  expect(state.settles).toEqual([
    { branch_id: 'branch_main', reference: 'GRAB-0311', orders: [{ id: 'posplatorder_1', commission_amount: '18000' }] },
  ]);
  await expect(table.getByRole('row')).toHaveCount(2);
  await expect(table).toContainText('GF-1002');

  await page.goto('/store_1/reports/platforms');
  const report = page.getByRole('table').first();
  await expect(report).toContainText('GrabFood');
  await expect(report).toContainText('45.000');
  await expect(report).toContainText('18.000');
});
