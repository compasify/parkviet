import { expect, test } from '@playwright/test';
import {
  addLine,
  addSheet,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  serialize,
} from './support/retail-api';

// A table booked by phone: a cash deposit, the guest arrives and is seated,
// the order is taken and the deposit comes off the bill before the rest is
// paid in cash. The deposit is never a sale of its own.
// Presentation fixtures only: no real account privileges.

const MODULES = { resources: true, 'fnb.tables': true, 'fnb.reservations': true };
const TABLE = { id: 'posres_1', name: 'Bàn 1', kind: 'table', area_id: 'posarea_1' };

test('book, take a deposit, seat the guest and pay with the deposit taken off', async ({ context }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.reservation.manage'],
    modules: MODULES,
  });
  await installRetailApi(context, world);
  await context.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: new Date().toISOString(),
          areas: [],
          resources: [{ ...TABLE, capacity: 4, state: 'available', orders: [] }],
        },
      },
    }),
  );

  const day = new Date();
  day.setHours(0, 0, 0, 0);
  const bookings: Array<Record<string, unknown>> = [];
  const posts: string[] = [];
  const deposit = {
    id: 'posresdep_1',
    kind: 'cash',
    amount: '50000.0',
    currency: 'VND',
    status: 'held',
    available: '50000.0',
    received_at: new Date().toISOString(),
    resolved_at: null,
    resolution_order_id: null,
  };
  await context.route('**/api/v3/admin/pos/reservations**', async (route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    if (request.method() === 'GET' && path === '/pos/reservations/availability')
      return route.fulfill({ json: { data: [{ ...TABLE, capacity: 4 }] } });
    if (request.method() === 'GET')
      return route.fulfill({ json: { data: bookings, meta: { from: day.toISOString() } } });
    const body = request.postDataJSON() as Record<string, unknown>;
    posts.push(path);
    if (path === '/pos/reservations') {
      const booking = {
        id: 'posresv_1',
        branch_id: 'br_1',
        status: 'booked',
        source: body.source,
        guest_name: body.guest_name,
        phone: body.phone ?? null,
        party_size: body.party_size,
        note: null,
        starts_at: body.starts_at,
        ends_at: new Date(Date.parse(String(body.starts_at)) + 120 * 60_000).toISOString(),
        revision: 1,
        workspace_id: null,
        resources: [TABLE],
        deposits: [],
        deposit_held: '0.0',
      };
      bookings.push(booking);
      return route.fulfill({ status: 201, json: { data: booking } });
    }
    const booking = bookings[0];
    if (path === '/pos/reservations/posresv_1/deposits') {
      expect(body).toMatchObject({ kind: 'cash', amount: '50000' });
      Object.assign(booking, { deposits: [deposit], deposit_held: '50000.0', revision: 2 });
      return route.fulfill({ status: 201, json: { data: booking } });
    }
    if (path === '/pos/reservations/posresv_1/seat') {
      const sheet = addSheet(world, 'ws_r1', {
        table: { id: TABLE.id, name: TABLE.name, label: null, guests: 3 },
      });
      addLine(world, sheet, 'v_rice', 2);
      Object.assign(booking, { status: 'seated', workspace_id: 'ws_r1', revision: 3 });
      sheet.reservation = {
        id: 'posresv_1',
        guest_name: booking.guest_name,
        party_size: booking.party_size,
        status: 'seated',
        revision: 3,
        deposit_held: '50000.0',
        deposits: [{ id: deposit.id, kind: 'cash', amount: deposit.amount, status: 'held', available: '50000.0' }],
      };
      return route.fulfill({ json: { data: { reservation: booking, workspace: serialize(world, sheet) } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
  });
  // The held deposit goes towards the bill: money already received, no new sale.
  await context.route('**/api/v3/admin/pos/workspaces/ws_r1/deposits/apply', (route) => {
    const sheet = world.sheets.get('ws_r1');
    if (!sheet) return route.fulfill({ status: 404, json: {} });
    posts.push('deposits/apply');
    sheet.allocated += 50000;
    sheet.revision += 1;
    sheet.reservation = {
      ...sheet.reservation,
      status: 'seated',
      deposits: [{ id: deposit.id, kind: 'cash', amount: deposit.amount, status: 'applied', available: '0.0' }],
    };
    return route.fulfill({ json: { data: serialize(world, sheet) } });
  });

  const page = await context.newPage();
  await login(page);
  // The account menu offers the page (in a new tab from the sale screen).
  await expect(page.locator('a[href$="/reservations"]')).toHaveCount(1);
  await page.goto('/reservations');
  await expect(page.getByRole('heading', { name: 'Đặt bàn', exact: true, level: 1 })).toBeVisible();

  const form = page.getByRole('form', { name: 'Đặt bàn mới' });
  await form.getByLabel('Tên khách').fill('Chị Mai');
  await form.getByLabel('Số khách').fill('3');
  await expect(form.getByLabel('Bàn')).toHaveValue('posres_1');
  await form.getByRole('button', { name: 'Giữ bàn' }).click();
  await expect(form.getByText('Đã giữ bàn cho khách.')).toBeVisible();

  const list = page.getByRole('list', { name: 'Danh sách đặt bàn' });
  await expect(list.getByText(/Chị Mai/)).toBeVisible();
  await expect(page.locator('.reservation-block')).toContainText('Chị Mai (3)');

  await list.getByRole('button', { name: 'Nhận cọc' }).click();
  const depositForm = page.getByRole('form', { name: 'Nhận cọc' });
  await depositForm.getByLabel('Số tiền cọc').fill('50000');
  await depositForm.getByRole('button', { name: 'Ghi nhận cọc' }).click();
  await expect(list.getByText(/Tiền cọc: 50\.000/)).toBeVisible();

  await list.getByRole('button', { name: 'Khách đã đến' }).click();
  await expect(page).toHaveURL(/order=ws_r1/);
  // The seated table opens on its ticket; the deposit is taken off on the payment screen.
  await page.getByRole('complementary', { name: 'Phiếu bàn' }).getByRole('button', { name: /^Thanh toán/ }).click();
  const pay = page.locator('.pay-screen');
  await expect(pay.locator('.pay-bill')).toContainText('Bàn 1');
  const claim = page.getByRole('button', { name: 'Nhận quyền sửa', exact: true });
  if (await claim.isVisible().catch(() => false)) await claim.click();

  const note = pay.locator('.reservation-deposit-note');
  await expect(note).toContainText('Chị Mai');
  await note.getByRole('button', { name: /Trừ cọc 50\.000/ }).click();
  await expect(note).toContainText('Tiền cọc đã được trừ vào hóa đơn.');

  // 200 000 for the rice, 50 000 already in: the cash pays the rest.
  await expect(pay.locator('.pay-due-left')).toContainText('150.000 ₫');
  await pay.getByLabel('Khách đưa').fill('150.000');
  await pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' }).click();
  await expect.poll(() => world.sheets.get('ws_r1')?.status).toBe('completed');
  expect(world.sheets.get('ws_r1')?.allocated).toBe(200000);
  expect(posts).toEqual([
    '/pos/reservations',
    '/pos/reservations/posresv_1/deposits',
    '/pos/reservations/posresv_1/seat',
    'deposits/apply',
  ]);
});
