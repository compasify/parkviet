import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, installRetailApi, login, newWorld, serialize, type World } from './support/retail-api';

// Counter service: two orders sold with call numbers wait in the quick
// counter's strip, the first opens on the ticket with its number and takes
// the guest's name, and the customer display's call board follows the
// kitchen: preparing, ready (bumped), handed over. The cashier's screen has
// no pickup queue; the call board is where guests watch their number.
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

test('call numbers show on the ticket and move from preparing to ready to handed over on the call board', async ({
  page,
  context,
}) => {
  const world = newWorld({ modules: COUNTER, menu: teaMenu() });
  // Both orders were sold and sent; the kitchen is making them.
  addSheet(world, 'ws_c1', { orderNumber: 1 });
  addSheet(world, 'ws_c2', { orderNumber: 2 });
  const kitchen: Kitchen = {
    orders: [
      { number: 1, workspaceId: 'ws_c1', guest: null, status: 'preparing' },
      { number: 2, workspaceId: 'ws_c2', guest: null, status: 'preparing' },
    ],
    serves: [],
    guestNames: [],
  };
  await installRetailApi(page, world);
  await installCounterApi(page, world, kitchen);
  await login(page);

  // Both orders wait in the strip by their numbers; the first opens on the ticket.
  const strip = page.getByRole('list', { name: 'Đơn đang giữ' });
  await expect(strip.locator('[data-workspace-id="ws_c1"]')).toContainText('Số 1');
  await expect(strip.locator('[data-workspace-id="ws_c2"]')).toContainText('Số 2');
  await strip.locator('[data-workspace-id="ws_c1"]').click();
  await expect(page.getByTestId('call-number')).toHaveText('Số gọi 1');
  await expect(strip.locator('[data-workspace-id="ws_c1"]')).toHaveCount(0);
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await page.getByTestId('guest-name').fill('  Lan ');
  await page.getByTestId('guest-name').press('Enter');
  await expect.poll(() => kitchen.guestNames.at(-1)).toEqual({ workspaceId: 'ws_c1', name: 'Lan' });
  await expect(page.getByTestId('call-number')).toContainText('Lan');

  // The customer display, paired to the call board.
  const screen = await context.newPage();
  await installDisplay(screen, kitchen);
  await screen.goto('/display');
  await screen.getByLabel('Mã kết nối').fill('abcd-2345');
  await screen.getByRole('button', { name: 'Kết nối', exact: true }).click();
  await expect(screen.getByTestId('call-board-preparing')).toHaveText(/1\s*2/);
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(0);

  // The cashier's screen keeps to selling: no pickup queue beside the ticket.
  await expect(page.getByTestId('pickup-toggle')).toHaveCount(0);

  // The kitchen bumps order 1: ready, with the guest's name, flashing on the board.
  kitchen.orders[0].status = 'ready';
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(1, { timeout: 5_000 });
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toContainText('1');
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toContainText('Lan');
  await expect(screen.getByTestId('call-board-ready').locator('li').first()).toHaveClass(/call-board-new/);
  await expect(screen.getByTestId('call-board-preparing').locator('li')).toHaveText(['2']);

  // The kitchen hands order 1 over: it leaves the board.
  kitchen.orders[0].status = 'served';
  await expect(screen.getByTestId('call-board-ready').locator('li')).toHaveCount(0, { timeout: 5_000 });
  await expect(screen.getByTestId('call-board-preparing').locator('li')).toHaveText(['2']);
});
