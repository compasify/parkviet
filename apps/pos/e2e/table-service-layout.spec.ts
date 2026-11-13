import { type BrowserContext, expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import {
  addLine,
  addSheet,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  type World,
} from './support/retail-api';

// A table served from the board to its payment: the table opens on its
// order, a dish goes to the kitchen and the screen returns to the board;
// "Thanh toán" opens the payment over the whole screen with the VietQR for
// what is due already shown, the bank's notification lets "Hoàn tất · in
// hóa đơn" finish, and the board comes back with the invoice printing.
// Cash taken in part asks the next QR for the rest; "← Đơn" lets the
// waiting QR go; a reload on the payment reopens it on the same QR.
// Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.kitchen': true };

function tableWorld(): World {
  return newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
    vietqr: true,
  });
}

// The board of one table seated with order ws_t1.
async function routeBoard(context: BrowserContext) {
  await context.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: '2026-11-11T05:00:00Z',
          areas: [],
          resources: [
            {
              id: 'posres_1', name: 'Bàn 1', state: 'occupied', guest_count: 2, seated_minutes: 3,
              subtotal: '0.0', currency: 'VND', orders: [{ id: 'ws_t1', total: '0.0', guest_count: 2 }],
            },
          ],
        },
      },
    }),
  );
}

// The sale receipt the invoice prints, and the prints it records.
async function routeReceipt(context: BrowserContext) {
  const prints: Array<Record<string, unknown>> = [];
  const receipt = () => ({
    id: 'posreceipt_T1',
    source_type: 'sale',
    number: 'HD-0001',
    branch_id: 'br_1',
    issued_at: '2026-11-11T05:10:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: prints.length > 0,
    copy_count: Math.max(prints.length - 1, 0),
    document: { title: 'PHIẾU BÁN HÀNG', currency: 'VND', lines: [], totals: { item_total: '15000', total: '15000' } },
  });
  await context.route('**/pos/receipts/lookup?*', (route) => route.fulfill({ json: { data: receipt() } }));
  await context.route('**/pos/receipts/posreceipt_T1/prints', (route) => {
    prints.push((route.request().postDataJSON() ?? {}) as Record<string, unknown>);
    return route.fulfill({
      status: 201,
      json: {
        data: {
          print: { id: `posprint_${prints.length}`, copy: prints.length > 1, copy_number: prints.length - 1, label: null, printed_at: '2026-11-11T05:10:00Z' },
          receipt: receipt(),
        },
      },
    });
  });
  await context.addInitScript(() => {
    window.print = () => {
      const seen = window as unknown as { printed?: number };
      seen.printed = (seen.printed ?? 0) + 1;
    };
  });
  return prints;
}

const payScreen = (page: Page) => page.locator('.pay-screen');

// Paying takes the order's editing lease; after a reload the page is a new
// editor, so its own old lease is taken over.
async function holdLease(page: Page, takeover = false) {
  await page.getByRole('button', { name: takeover ? 'Tiếp quản quyền sửa' : 'Nhận quyền sửa', exact: true }).click();
  await expect(page.getByText('Chỉ xem. Chưa nhận quyền sửa.')).toHaveCount(0);
}
const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu bàn' });
const tile = (page: Page) => page.locator('.board-tile', { hasText: 'Bàn 1' });
const attempts = (world: World, kind: string, status: string) =>
  world.sheets.get('ws_t1')?.attempts.filter((item) => item.kind === kind && item.status === status) ?? [];
const prepares = (world: World) => world.writes.filter((write) => write.family === 'tender.prepare');

test('a table goes from the board to the kitchen and back, then pays by VietQR shown at once', async ({
  context,
}) => {
  const world = tableWorld();
  addSheet(world, 'ws_t1', { table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 } });
  await installRetailApi(context, world);
  await routeBoard(context);
  const prints = await routeReceipt(context);
  const page = await context.newPage();
  await login(page);

  // The board opens the table's order; a dish goes to the kitchen and back to the board.
  await tile(page).click();
  await page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);
  await ticket(page).getByRole('button', { name: 'Gửi bếp (1)', exact: true }).click();
  await expect(page).toHaveURL(/view=board/);
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(1);

  // Back on the order, "Thanh toán" opens the payment over the whole screen.
  await tile(page).click();
  await ticket(page).getByRole('button', { name: /^Thanh toán/ }).click();
  await expect(page).toHaveURL(/view=pay/);
  const pay = payScreen(page);
  await expect(page.getByRole('complementary', { name: 'Phiếu bàn' })).toHaveCount(0);
  await holdLease(page);
  await expect(pay.getByRole('complementary', { name: 'Hóa đơn' })).toContainText('Bánh flan');
  await expect(pay.locator('.pay-bill-total')).toContainText('15.000 ₫');
  await expect(pay.locator('.pay-due')).toContainText('Cần thu15.000 ₫');
  await expect(pay.locator('.pay-due-left')).toContainText('15.000 ₫');

  // The QR for what is due shows without a click, waiting for the bank.
  const qr = pay.getByRole('region', { name: 'VietQR' });
  await expect(qr.getByRole('img', { name: 'Mã VietQR để quét bằng ứng dụng ngân hàng' })).toBeVisible();
  await expect(qr.locator('.pay-qr-amount')).toHaveText('15.000 ₫');
  await expect(qr.getByRole('status')).toContainText('Chờ chuyển khoản, tự khớp khi tiền về');
  expect(prepares(world).map((write) => [write.body.payment_method_id, write.body.amount])).toEqual([
    ['posmethod-vietqr', '15000'],
  ]);
  // Cash, its notes and the keypad sit beside it; the bill's tools are in the foot.
  const cash = pay.getByRole('region', { name: 'Tiền mặt' });
  await expect(cash.getByRole('button', { name: 'Đúng 15.000' })).toBeVisible();
  await expect(cash.getByRole('button', { name: '20.000', exact: true })).toBeVisible();
  for (const tool of ['Chia đều', 'Tách theo món', 'Tách theo ghế', 'In tạm tính'])
    await expect(pay.locator('.pay-foot')).toContainText(tool);
  const finish = pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' });
  await expect(finish).toBeDisabled();

  // The bank reports the transfer: finishing confirms it, completes and hands over.
  world.vietqrReceived?.add(attempts(world, 'vietqr', 'prepared')[0].id);
  await expect(qr.getByRole('status')).toContainText('Ngân hàng đã báo nhận tiền', { timeout: 10_000 });
  await expect(finish).toBeEnabled();
  await finish.click();
  await expect.poll(() => world.sheets.get('ws_t1')?.status).toBe('completed');
  const confirm = world.writes.find((write) => write.family === 'tender.confirm');
  expect(confirm?.body.evidence_kind).toBe('vietqr_webhook');
  await expect.poll(() => world.sheets.get('ws_t1')?.handedOver).toBe(true);

  // The board comes back with the invoice printing over it.
  await expect(page).toHaveURL(/view=board/);
  await expect(page.getByRole('region', { name: 'Bảng bàn' })).toBeVisible();
  const receipt = page.getByRole('dialog');
  await expect(receipt).toContainText('HD-0001');
  await expect.poll(() => prints.length).toBe(1);
});

test('part in cash asks the next QR for the rest; "← Đơn" lets the QR go; a reload stays on the payment', async ({
  context,
}) => {
  const world = tableWorld();
  const sheet = addSheet(world, 'ws_t1', {
    table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 },
  });
  addLine(world, sheet, 'v_flan', 2);
  await installRetailApi(context, world);
  await routeBoard(context);
  await routeReceipt(context);
  const page = await context.newPage();
  await login(page);
  await tile(page).click();
  await ticket(page).getByRole('button', { name: /^Thanh toán/ }).click();
  await holdLease(page);
  const pay = payScreen(page);
  const qr = pay.getByRole('region', { name: 'VietQR' });
  const qrImage = qr.getByRole('img', { name: 'Mã VietQR để quét bằng ứng dụng ngân hàng' });
  await expect(qrImage).toBeVisible();
  await expect(qr.locator('.pay-qr-amount')).toHaveText('30.000 ₫');

  // Back to the order: the waiting QR goes, and the order may change again.
  await pay.getByRole('button', { name: 'Về đơn để gọi thêm món' }).click();
  await expect(page).toHaveURL(/view=order/);
  await expect.poll(() => attempts(world, 'vietqr', 'canceled').length).toBe(1);
  await expect(
    page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true }),
  ).toBeEnabled();

  // Paying again asks for a new QR; 10.000 in cash leaves 20.000 for it.
  await ticket(page).getByRole('button', { name: /^Thanh toán/ }).click();
  await expect(qrImage).toBeVisible();
  await expect(qr.locator('.pay-qr-amount')).toHaveText('30.000 ₫');
  const cash = pay.getByRole('region', { name: 'Tiền mặt' });
  for (const key of ['1', '0', '000']) await cash.getByRole('button', { name: key, exact: true }).click();
  await expect(cash.getByLabel('Khách đưa')).toHaveValue('10.000');
  await expect(pay.locator('.pay-due-left')).toContainText('20.000 ₫');
  await pay.getByRole('button', { name: 'Thu 10.000 ₫ tiền mặt' }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.allocated).toBe(10000);
  await expect.poll(() => prepares(world).length).toBe(4);
  await expect(qrImage).toBeVisible();
  await expect(qr.locator('.pay-qr-amount')).toHaveText('20.000 ₫');
  expect(prepares(world).map((write) => [write.body.payment_method_id, write.body.amount])).toEqual([
    ['posmethod-vietqr', '30000'],
    ['posmethod-vietqr', '30000'],
    ['posmethod-cash', '10000'],
    ['posmethod-vietqr', '20000'],
  ]);
  expect(attempts(world, 'vietqr', 'canceled')).toHaveLength(2);

  // A reload reopens the payment of the order on the same QR.
  await expect(page).toHaveURL(/order=R100.*view=pay|view=pay.*order=R100/);
  await page.reload();
  await holdLease(page, true);
  await expect(qrImage).toBeVisible();
  await expect(qr.locator('.pay-qr-amount')).toHaveText('20.000 ₫');
  await expect(pay.locator('.pay-due-left')).toContainText('20.000 ₫');
  expect(prepares(world)).toHaveLength(4);

  // The rest in cash: the exact note finishes, and the board comes back.
  await cash.getByRole('button', { name: 'Đúng 20.000' }).click();
  await pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.status).toBe('completed');
  expect(world.sheets.get('ws_t1')?.allocated).toBe(30000);
  await expect(page).toHaveURL(/view=board/);
  await expect(page.getByRole('dialog')).toContainText('HD-0001');
});
