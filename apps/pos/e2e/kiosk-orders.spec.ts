import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import {
  addLine,
  addSheet,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  serialize,
  type World,
} from './support/retail-api';

// Orders self-ordering kiosks left for the counter, in the cashier's tray: a
// badge counts them, "Thu tiền" takes one onto the cashier's shift and opens
// it on the quick counter's ticket, and an abandoned one can be canceled. Presentation
// fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, 'fnb.order_number': true, 'fnb.kiosk': true };

type Kiosk = { orders: Record<string, unknown>[]; calls: { action: string; body: Record<string, unknown> }[] };

function kioskOrder(id: string, callNumber: number, abandoned: boolean) {
  return {
    id,
    order_id: `or_${id}`,
    order_number: `R${callNumber}00`,
    call_number: callNumber,
    status: 'parked',
    register: { id: 'reg_kiosk', name: 'Kiosk sảnh' },
    total: '50000.0',
    currency: 'VND',
    item_count: 2,
    opened_at: '2026-11-12T10:00:00.000+07:00',
    waiting_since: new Date(Date.now() - (abandoned ? 45 : 3) * 60_000).toISOString(),
    abandoned,
  };
}

async function installKioskApi(page: Page, world: World, kiosk: Kiosk) {
  await page.route('**/api/v3/admin/pos/kiosk_orders**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    if (path === '/pos/kiosk_orders') return route.fulfill({ json: { data: kiosk.orders } });
    const command = /^\/pos\/kiosk_orders\/([^/]+)\/(take|cancel)$/.exec(path);
    if (!command) return route.fallback();
    const body = request.postDataJSON() as Record<string, unknown>;
    kiosk.calls.push({ action: command[2], body });
    kiosk.orders = kiosk.orders.filter((row) => row.id !== command[1]);
    if (command[2] === 'cancel')
      return route.fulfill({ json: { data: { id: command[1], operational_status: 'canceled' } } });
    const sheet = addSheet(world, command[1], { editor: String(body.editor_id), orderNumber: 4 });
    addLine(world, sheet, world.products[0].variantId, 2);
    return route.fulfill({ json: { data: serialize(world, sheet) } });
  });
}

test('takes a kiosk order to the cashier and cancels an abandoned one', async ({ page }) => {
  const world = newWorld({ modules: MODULES, menu: teaMenu(), capabilities: FULL_CASHIER });
  const kiosk: Kiosk = {
    orders: [kioskOrder('posws_kiosk1', 4, false), kioskOrder('posws_kiosk2', 3, true)],
    calls: [],
  };
  await installRetailApi(page, world);
  await installKioskApi(page, world, kiosk);
  await login(page);

  await expect(page.getByTestId('kiosk-tray-badge')).toContainText('2 đang chờ');
  await page.getByTestId('kiosk-tray-toggle').click();

  const fresh = page.getByTestId('kiosk-order-posws_kiosk1');
  await expect(fresh).toContainText('Số 4');
  await expect(fresh).toContainText('Kiosk sảnh');
  await expect(page.getByTestId('kiosk-cancel-posws_kiosk1')).toHaveCount(0);

  const abandoned = page.getByTestId('kiosk-order-posws_kiosk2');
  await expect(abandoned).toContainText('khách có thể đã bỏ đi');
  await page.getByTestId('kiosk-cancel-posws_kiosk2').click();
  await expect(abandoned).toHaveCount(0);

  await page.getByTestId('kiosk-take-posws_kiosk1').click();
  // Taken, it is the order on the counter's ticket.
  const ticket = page.getByRole('complementary', { name: 'Phiếu quầy' });
  await expect(ticket.getByTestId('call-number')).toHaveText('Số gọi 4');
  await expect(ticket.locator('.ticket-line')).toHaveCount(1);
  await expect(page.getByText('Không có đơn kiosk nào chờ thu tiền.')).toBeVisible();

  expect(kiosk.calls.map((call) => call.action)).toEqual(['cancel', 'take']);
  const take = kiosk.calls[1].body;
  expect(typeof take.editor_id).toBe('string');
  expect(typeof take.idempotency_key).toBe('string');
});
