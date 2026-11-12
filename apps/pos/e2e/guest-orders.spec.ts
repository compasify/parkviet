import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { FULL_CASHIER, installRetailApi, login, newWorld } from './support/retail-api';

// Guests' orders from the table QR in the counter's tray: a badge counts what
// waits, staff accept one order and reject another with a reason, and close a
// call for staff. Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.qr_order': true };

type Guests = {
  orders: Record<string, unknown>[];
  requests: Record<string, unknown>[];
  calls: { action: string; body: Record<string, unknown> }[];
};

function guestOrder(id: string, table: string, name: string) {
  return {
    id,
    branch_id: 'br_1',
    workspace_id: `ws_${id}`,
    resource_id: `res_${id}`,
    table_name: table,
    area_id: 'area_1',
    status: 'pending',
    automatic: false,
    items: [
      {
        variant_id: 'v_tea',
        name,
        size: null,
        quantity: 2,
        unit_price: '25000.0',
        amount: '50000.0',
        note: 'ít đá',
        modifiers: [{ option_id: 'opt_1', name: 'Trân châu', quantity: 1 }],
      },
    ],
    quoted_total: '50000.0',
    currency: 'VND',
    item_count: 2,
    reject_reason: null,
    created_at: '2026-11-12T10:00:00.000+07:00',
  };
}

async function installGuestApi(page: Page, guests: Guests) {
  await page.route('**/api/v3/admin/pos/guest_**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    const page1 = (rows: unknown[]) => ({ data: rows, meta: { page: 1, pages: 1, count: rows.length } });
    if (path === '/pos/guest_orders') return route.fulfill({ json: page1(guests.orders) });
    if (path === '/pos/guest_requests') return route.fulfill({ json: page1(guests.requests) });
    const order = /^\/pos\/guest_orders\/([^/]+)\/(accept|reject)$/.exec(path);
    if (order) {
      guests.calls.push({ action: order[2], body: request.postDataJSON() as Record<string, unknown> });
      guests.orders = guests.orders.filter((row) => row.id !== order[1]);
      return route.fulfill({ json: { data: { id: order[1], status: order[2] === 'accept' ? 'accepted' : 'rejected' } } });
    }
    const done = /^\/pos\/guest_requests\/([^/]+)\/done$/.exec(path);
    if (done) {
      guests.calls.push({ action: 'done', body: request.postDataJSON() as Record<string, unknown> });
      guests.requests = [];
      return route.fulfill({ json: { data: { id: done[1], status: 'done' } } });
    }
    return route.fallback();
  });
}

test('accepts and rejects guest QR orders and closes a call for staff', async ({ page }) => {
  const world = newWorld({
    modules: MODULES,
    menu: teaMenu(),
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.guest_order.decide'],
  });
  const guests: Guests = {
    orders: [guestOrder('posguestorder_1', 'Bàn 4', 'Trà đào'), guestOrder('posguestorder_2', 'Bàn 7', 'Bánh flan')],
    requests: [
      {
        id: 'posguestreq_1',
        branch_id: 'br_1',
        resource_id: 'res_9',
        table_name: 'Bàn 9',
        area_id: 'area_1',
        workspace_id: 'ws_9',
        kind: 'call_staff',
        status: 'open',
        handled_by_name: null,
        handled_at: null,
        created_at: '2026-11-12T10:01:00.000+07:00',
      },
    ],
    calls: [],
  };
  await installRetailApi(page, world);
  await installGuestApi(page, guests);
  await login(page);

  await expect(page.getByTestId('guest-tray-badge')).toContainText('3 đang chờ');
  await page.getByTestId('guest-tray-toggle').click();

  const first = page.getByTestId('guest-order-posguestorder_1');
  await expect(first).toContainText('Bàn 4');
  await expect(first).toContainText('2 × Trà đào · Trân châu · ít đá');
  await page.getByTestId('guest-accept-posguestorder_1').click();
  await expect(first).toHaveCount(0);

  await page.getByTestId('guest-reject-posguestorder_2').click();
  const form = page.getByTestId('guest-reject-form');
  await expect(form.getByTestId('guest-reject-confirm')).toBeDisabled();
  await form.getByRole('button', { name: 'Món đã hết' }).click();
  await form.getByTestId('guest-reject-confirm').click();
  await expect(form).toHaveCount(0);
  await expect(page.getByTestId('guest-order-posguestorder_2')).toHaveCount(0);

  const call = page.getByTestId('guest-request-posguestreq_1');
  await expect(call).toContainText('Bàn 9 · Gọi phục vụ');
  await call.getByRole('button', { name: 'Đã xử lý' }).click();
  await expect(page.getByText('Không có đơn hay yêu cầu nào từ khách đang chờ.')).toBeVisible();

  expect(guests.calls.map((row) => row.action)).toEqual(['accept', 'reject', 'done']);
  expect(guests.calls[1].body).toMatchObject({ reason: 'Món đã hết' });
  for (const row of guests.calls) expect(row.body.idempotency_key).toEqual(expect.any(String));
});
