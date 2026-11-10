import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

type Delivery = {
  id: string; status: 'pending' | 'delivered'; deliverer: string | null; fee: string; delivered_at: string | null; delivered_by: string | null;
  order_id: string; order_number: string; workspace_id: string; order_source?: string; placed_at: string; currency: string;
  total: string; paid: string; owed: string; customer: { name: string | null; phone: string | null; address: string | null } | null;
};
const seed = (): Delivery[] => [
  { id: 'del_1', status: 'pending', deliverer: 'Bố', fee: '15000.0', delivered_at: null, delivered_by: null, order_id: 'order_1', order_number: 'P00001', workspace_id: 'ws_1', order_source: 'zalo', placed_at: '2026-11-10T02:00:00Z', currency: 'VND', total: '165000.0', paid: '0.0', owed: '165000.0', customer: { name: 'Chị Hoa', phone: '0901 234 567', address: '12 Lê Lợi, Quận 1' } },
  { id: 'del_2', status: 'pending', deliverer: null, fee: '0.0', delivered_at: null, delivered_by: null, order_id: 'order_2', order_number: 'P00002', workspace_id: 'ws_2', placed_at: '2026-11-10T03:00:00Z', currency: 'VND', total: '90000.0', paid: '90000.0', owed: '0.0', customer: null },
  { id: 'del_3', status: 'delivered', deliverer: 'Lan', fee: '0.0', delivered_at: '2026-11-10T04:00:00Z', delivered_by: 'staff_lan', order_id: 'order_3', order_number: 'P00003', workspace_id: 'ws_3', placed_at: '2026-11-10T01:00:00Z', currency: 'VND', total: '50000.0', paid: '50000.0', owed: '0.0', customer: null },
];

async function install(page: Page, options: { capabilities?: string[]; delivery?: boolean } = {}) {
  const deliveries = seed();
  const state = { lists: [] as Record<string, string>[], writes: [] as { path: string; body: Record<string, unknown> }[], refuse: '' };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, { capabilities: options.capabilities ?? ['pos.shift.open'], features: { delivery: options.delivery ?? true } }) });
    if (path === '/pos/deliveries') {
      const params = Object.fromEntries(url.searchParams.entries()); state.lists.push(params);
      const rows = deliveries.filter((row) => row.status === (params.status ?? 'pending'));
      return route.fulfill({ json: { data: rows, meta: pageMeta(rows.length, 1, Number(params.limit || 25)) } });
    }
    const change = /^\/pos\/deliveries\/([^/]+)\/(deliver|reopen)$/.exec(path);
    if (change) {
      state.writes.push({ path, body: request.postDataJSON() });
      if (state.refuse === change[1]) return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Not placed.', details: { reason: 'delivery_not_placed' } } } });
      const row = deliveries.find((item) => item.id === change[1])!;
      row.status = change[2] === 'deliver' ? 'delivered' : 'pending';
      row.delivered_at = row.status === 'delivered' ? '2026-11-10T05:00:00Z' : null;
      return route.fulfill({ json: { data: row } });
    }
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}
const MENU = /^(Open actions|Mở menu thao tác)$/;
async function act(page: Page, row: string, item: string) {
  await page.getByRole('row').filter({ hasText: row }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: item, exact: true }).click();
}

test('pending deliveries are handed over and put back from the row menu', async ({ page }, testInfo) => {
  const state = await install(page);
  await page.goto('/store_1/deliveries');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đơn cần giao');
  const table = page.getByRole('table');
  await expect(table.getByRole('row')).toHaveCount(3);
  expect(state.lists.at(-1)).toMatchObject({ branch_id: 'branch_main', status: 'pending', page: '1', limit: '100' });
  const hoa = table.getByRole('row').filter({ hasText: 'P00001' });
  await expect(hoa).toContainText('Zalo');
  await expect(hoa).toContainText('12 Lê Lợi, Quận 1');
  await expect(hoa).toContainText('Bố');
  await expect(hoa).toContainText('Còn nợ 165.000');
  await expect(hoa.getByRole('link', { name: '0901 234 567' })).toHaveAttribute('href', 'tel:0901234567');
  await expect(table.getByRole('row').filter({ hasText: 'P00002' })).toContainText('Đã trả đủ');
  await page.screenshot({ path: testInfo.outputPath('deliveries.png'), fullPage: true });
  await page.goto('/store_1/deliveries?search=L%C3%AA%20L%E1%BB%A3i');
  await expect(table.getByRole('row')).toHaveCount(2);
  await expect(table).toContainText('P00001');
  await page.goto('/store_1/deliveries?search=0909');
  await expect(page.getByText('Không còn đơn nào chờ giao.')).toBeVisible();
  await page.goto('/store_1/deliveries');
  await expect(table.getByRole('row')).toHaveCount(3);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);

  await act(page, 'P00001', 'Đã giao');
  await expect(page.getByRole('status').filter({ hasText: 'Đơn P00001 đã giao.' })).toBeVisible();
  await expect(table.getByRole('row')).toHaveCount(2);
  expect(state.writes.at(-1)?.path).toBe('/pos/deliveries/del_1/deliver');
  expect(typeof state.writes.at(-1)?.body.idempotency_key).toBe('string');

  state.refuse = 'del_2';
  await act(page, 'P00002', 'Đã giao');
  await expect(page.getByRole('alert')).toHaveText('Đơn này chưa hoàn tất nên chưa giao được.');
  await expect(table.getByRole('row').filter({ hasText: 'P00002' })).toHaveCount(1);

  await page.getByLabel('Lọc đơn giao', { exact: true }).click();
  await page.getByRole('option', { name: 'Đã giao hôm nay', exact: true }).click();
  await expect(page).toHaveURL(/status=delivered/);
  await expect(table.getByRole('row')).toHaveCount(3);
  expect(state.lists.at(-1)).toMatchObject({ status: 'delivered' });
  await act(page, 'P00001', 'Chưa giao');
  await expect(page.getByRole('status').filter({ hasText: 'Đơn P00001 trở lại chờ giao.' })).toBeVisible();
  await expect(table.getByRole('row')).toHaveCount(2);
  expect(state.writes.at(-1)?.path).toBe('/pos/deliveries/del_1/reopen');
  await act(page, 'P00003', 'Xem đơn');
  await expect(page).toHaveURL(/\/store_1\/orders\/order_3$/);
});

test('with delivery switched off the list stays reachable with a note but leaves the sidebar', async ({ page }, testInfo) => {
  await install(page, { delivery: false });
  await page.goto('/store_1/deliveries');
  await expect(page.getByRole('note')).toContainText('Giao hàng đang tắt ở chi nhánh.');
  await expect(page.getByRole('table').getByRole('row')).toHaveCount(3);
  if (testInfo.project.name === 'desktop') {
    await page.getByRole('link', { name: 'Bán hàng' }).first().click();
    await expect(page).toHaveURL(/\/store_1\/orders/);
    await expect(page.locator('[data-sidebar="sidebar"]').first().getByRole('link', { name: 'Đơn cần giao' })).toHaveCount(0);
  }
});

test('staff who neither sell nor collect cannot open deliveries', async ({ page }) => {
  const state = await install(page, { capabilities: ['pos.report.read'] });
  await page.goto('/store_1/deliveries');
  await expect(page.getByRole('heading', { name: 'Không có quyền truy cập', exact: true })).toBeVisible();
  expect(state.lists).toEqual([]);
});
