import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, installRetailApi, login, newWorld, openTab, serialize, type World } from './support/retail-api';

// Counter service: two orders sold with call numbers, the guest's name on the
// first, the counter's pickup queue and the customer display's call board as
// the kitchen works: preparing, ready (bumped), handed over.
// Presentation fixtures only: no real account privileges.

const COUNTER = { 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true };

type Order = { number: number; workspaceId: string; guest: string | null; status: 'preparing' | 'ready' | 'served' };

type Kitchen = { orders: Order[]; serves: string[]; guestNames: { workspaceId: string; name: string }[] };

function board(kitchen: Kitchen, withIds: boolean) {
  const row = (order: Order) => (withIds ? { number: order.number, workspace_id: order.workspaceId } : { number: order.number });
  return {
    preparing: kitchen.orders.filter((order) => order.status === 'preparing').map(row),
    ready: kitchen.orders
      .filter((order) => order.status === 'ready')
      .map((order) => ({ ...row(order), guest_name: order.guest, ready_at: '2026-11-11T10:05:00.000+07:00' })),
  };
}

// The counter-service endpoints, on top of the retail fixture.
async function installCounterApi(page: Page, world: World, kitchen: Kitchen) {
  await page.route('**/api/v3/admin/pos/**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    const guest = /^\/pos\/workspaces\/([^/]+)\/guest_name$/.exec(path);
    if (guest && request.method() === 'POST') {
      const sheet = world.sheets.get(guest[1]);
      if (!sheet) return route.fulfill({ status: 404, json: {} });
      const name = String((request.postDataJSON() as { guest_name?: string }).guest_name ?? '');
      kitchen.guestNames.push({ workspaceId: sheet.id, name });
      sheet.guestName = name || null;
      sheet.revision += 1;
      const order = kitchen.orders.find((row) => row.workspaceId === sheet.id);
      if (order) order.guest = sheet.guestName;
      return route.fulfill({ json: { data: serialize(world, sheet) } });
    }
    if (path === '/pos/kitchen/orders') return route.fulfill({ json: { data: board(kitchen, true) } });
    const serve = /^\/pos\/kitchen\/orders\/([^/]+)\/serve$/.exec(path);
    if (serve) {
      kitchen.serves.push(serve[1]);
      const order = kitchen.orders.find((row) => row.workspaceId === serve[1]);
      if (order?.status === 'ready') order.status = 'served';
      return route.fulfill({ json: { data: { workspace_id: serve[1], tickets: [] } } });
    }
    return route.fallback();
  });
}

let sequence = 0;
async function installDisplay(page: Page, kitchen: Kitchen) {
  await page.route('**/api/v3/pos_display/**', async (route: Route) => {
    const path = new URL(route.request().url()).pathname;
    if (path.endsWith('/pair')) return route.fulfill({ json: { data: { token: 'tok-1', session_id: 'posdisplay_1' } } });
    if (path.endsWith('/ack')) return route.fulfill({ json: { data: { generation: 1 } } });
    sequence += 1;
    return route.fulfill({
      json: {
        data: {
          session_id: 'posdisplay_1',
          generation: 1,
          sequence,
          issued_at: new Date().toISOString(),
          lease_id: 'lease-1',
          freshness_ttl_seconds: 15,
          token_expires_at: '2099-01-01T00:00:00Z',
          branch_name: 'Chi nhánh 1',
          state: 'call_board',
          order: null,
          payment: null,
          ...board(kitchen, false),
        },
      },
    });
  });
}

test('call numbers move from preparing to ready to handed over at the counter and on the call board', async ({
  page,
  context,
}) => {
  const world = newWorld({ modules: COUNTER, menu: teaMenu() });
  // Both orders were sold and sent; the kitchen is making them.
  addSheet(world, 'ws_1', { orderNumber: 1 });
  addSheet(world, 'ws_2', { orderNumber: 2 });
  const kitchen: Kitchen = {
    orders: [
      { number: 1, workspaceId: 'ws_1', guest: null, status: 'preparing' },
      { number: 2, workspaceId: 'ws_2', guest: null, status: 'preparing' },
    ],
    serves: [],
    guestNames: [],
  };
  await installRetailApi(page, world);
  await installCounterApi(page, world, kitchen);
  await login(page);
  await openTab(page, 'ws_1');

  // The call number on the tab and above the basket; the guest gives a name.
  await expect(page.locator('[data-workspace-id="ws_1"] [data-testid="tab-call-number"]')).toHaveText('Số 1');
  await expect(page.getByTestId('call-number')).toContainText('Số gọi 1');
  await page.getByTestId('guest-name').fill('  Lan ');
  await page.getByTestId('guest-name').press('Enter');
  await expect.poll(() => kitchen.guestNames.at(-1)).toEqual({ workspaceId: 'ws_1', name: 'Lan' });
  await expect(page.getByTestId('call-number')).toContainText('Lan');

  // The customer display, paired to the call board.
  const screen = await context.newPage();
  await installDisplay(screen, kitchen);
  await screen.goto('/display');
  await screen.getByLabel('Mã kết nối').fill('abcd-2345');
  await screen.getByRole('button', { name: 'Kết nối', exact: true }).click();
  await expect(screen.getByTestId('call-board-preparing')).toHaveText(/1\s*2/);
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(0);

  // The pickup queue: both numbers are being made.
  const toggle = page.getByTestId('pickup-toggle');
  await toggle.click();
  await expect(page.getByTestId('pickup-preparing').locator('li')).toHaveText(['1', '2']);

  // The kitchen bumps order 1: ready, with the guest's name, flashing on the board.
  kitchen.orders[0].status = 'ready';
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(1, { timeout: 5_000 });
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toContainText('1');
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toContainText('Lan');
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toHaveClass(/call-board-new/);
  await expect(screen.getByTestId('call-board-preparing').locator('li')).toHaveText(['2']);

  // The queue reads again when reopened; "Đã giao" hands order 1 over.
  await toggle.click();
  await toggle.click();
  await expect(page.getByTestId('pickup-ready').locator('li')).toHaveCount(1);
  await expect(page.getByTestId('pickup-ready')).toContainText('Lan');
  await page.getByRole('button', { name: 'Đã giao số 1' }).click();
  await expect.poll(() => kitchen.serves).toEqual(['ws_1']);
  await expect(page.getByTestId('pickup-ready')).toHaveCount(0);
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(0, { timeout: 5_000 });
  await expect(screen.getByTestId('call-board-preparing').locator('li')).toHaveText(['2']);
});
