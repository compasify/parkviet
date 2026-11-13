import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

async function install(page: Page, capabilities: string[], features: Record<string, boolean> = { delivery: true }) {
  const requests: { path: string; params: Record<string, string> }[] = [];
  await page.route('**/api/v3/admin/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const params = Object.fromEntries(url.searchParams.entries());
    if (path.startsWith('/pos/')) requests.push({ path, params });
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, { capabilities, features }) });
    if (path === '/pos/received_funds')
      return route.fulfill({ json: { data: [
        { id: 'funds_1', status: 'attention', available: '0.0' },
        { id: 'funds_2', status: 'allocated', available: '50000.0' },
        { id: 'funds_3', status: 'allocated', available: '0.0' },
      ], meta: pageMeta(3, 1, 100) } });
    if (path === '/pos/credit_requests')
      return route.fulfill({ json: { data: [{ id: 'cr_1', status: 'pending' }, { id: 'cr_2', status: 'approved' }], meta: pageMeta(2, 1, 100) } });
    if (path === '/pos/cash_movement_requests')
      return route.fulfill({ json: { data: [{ id: 'cm_1', requester_id: 'staff_admin' }, { id: 'cm_2', requester_id: 'staff_lan' }, { id: 'cm_3', requester_id: 'staff_minh' }], meta: pageMeta(3, 1, 100) } });
    if (path === '/pos/shift_closures/open')
      return route.fulfill({ json: { data: [{ id: 'shift_1' }, { id: 'shift_2' }], meta: { count: 2 } } });
    if (path === '/pos/deliveries') return route.fulfill({ json: { data: [], meta: pageMeta(4, 1, 1) } });
    if (path === '/pos/orders') return route.fulfill({ json: { data: [], meta: pageMeta(1, 1, 1) } });
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return requests;
}
const card = (page: Page, name: string) => page.getByRole('list', { name: 'Việc cần xử lý' }).getByLabel(name, { exact: true });

test('a branch manager sees every attention item with its count and links', async ({ page }, testInfo) => {
  const requests = await install(page, ['pos.payment.resolve', 'pos.approval.grant', 'pos.credit.manage', 'pos.topology.recover', 'pos.shift.open']);
  await page.goto('/store_1');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Việc cần xử lý');
  await expect(card(page, 'Khoản thu cần chú ý').getByTestId('attention-count')).toHaveText('2');
  await expect(card(page, 'Duyệt ghi nợ').getByTestId('attention-count')).toHaveText('1');
  await expect(card(page, 'Thu/chi két chờ xác nhận').getByTestId('attention-count')).toHaveText('2');
  await expect(card(page, 'Ca đang mở').getByTestId('attention-count')).toHaveText('2');
  await expect(card(page, 'Đơn chờ giao').getByTestId('attention-count')).toHaveText('4');
  await expect(card(page, 'Hoàn tiền chưa xong').getByTestId('attention-count')).toHaveText('1');
  await expect(card(page, 'Khoản thu cần chú ý').getByRole('link', { name: 'Xem' })).toHaveAttribute('href', '/store_1/funds/attention');
  await expect(card(page, 'Thu/chi két chờ xác nhận').getByRole('link', { name: 'Xem' })).toHaveAttribute('href', '/store_1/shifts');
  await expect(card(page, 'Ca đang mở').getByRole('link', { name: 'Xem' })).toHaveAttribute('href', '/store_1/shifts');
  expect(requests.find((r) => r.path === '/pos/cash_movement_requests')?.params).toMatchObject({ branch_id: 'branch_main', status: 'requested' });
  expect(requests.find((r) => r.path === '/pos/deliveries')?.params).toMatchObject({ branch_id: 'branch_main', status: 'pending' });
  expect(requests.find((r) => r.path === '/pos/orders')?.params).toMatchObject({ status: 'refund_pending' });
  await page.screenshot({ path: testInfo.outputPath('home.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  if (testInfo.project.name === 'desktop') {
    const sidebar = page.locator('[data-sidebar="sidebar"]').first();
    const counter = sidebar.getByRole('link', { name: 'POS' });
    const attention = sidebar.getByRole('link', { name: 'Việc cần xử lý' });
    await expect(counter).toBeVisible();
    await expect(counter).toHaveAttribute('href', 'http://localhost:5175/?store=store_1&branch=branch_main');
    await expect(counter).toHaveAttribute('target', '_blank');
    await expect(attention).toBeVisible();
    expect((await counter.boundingBox())!.y).toBeLessThan((await attention.boundingBox())!.y);
    await expect(sidebar.getByRole('link', { name: 'Bán hàng' })).toHaveAttribute('href', '/store_1/orders');
    await expect(sidebar.getByRole('link', { name: 'Tiền', exact: true })).toHaveAttribute('href', '/store_1/funds');
    await expect(sidebar.getByRole('link', { name: 'Thiết lập' })).toHaveAttribute('href', '/store_1/devices');
  }
  await card(page, 'Đơn chờ giao').getByRole('link', { name: 'Xem' }).click();
  await expect(page).toHaveURL(/\/store_1\/deliveries/);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Đơn cần giao');
});

test('items follow the reader capabilities at the branch', async ({ page }) => {
  const requests = await install(page, ['pos.report.read']);
  await page.goto('/store_1');
  const list = page.getByRole('list', { name: 'Việc cần xử lý' });
  await expect(card(page, 'Hoàn tiền chưa xong').getByTestId('attention-count')).toHaveText('1');
  await expect(list.getByRole('listitem')).toHaveCount(1);
  await card(page, 'Hoàn tiền chưa xong').getByRole('link', { name: 'Xem' }).click();
  await expect(page).toHaveURL(/\/store_1\/orders\?status=refund_pending/);
  expect(requests.some((r) => ['/pos/received_funds', '/pos/credit_requests', '/pos/cash_movement_requests', '/pos/shift_closures/open', '/pos/deliveries'].includes(r.path))).toBe(false);
});

test('a store user without branch membership has nothing to handle', async ({ page }) => {
  await install(page, []);
  await page.goto('/store_1');
  await expect(page.getByText('Bạn không có việc nào cần xử lý ở chi nhánh này.')).toBeVisible();
});
