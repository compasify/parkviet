import { type BrowserContext, expect, type Page, test } from '@playwright/test';
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

// The board is the first screen: "Cần xử lý" keeps the tables someone should
// go to, a free table opens with its guests, a plain dish adds in one tap and
// a dish with options only once its required group is chosen. "Gửi & ở lại"
// stays on the order, a course held back is called out from the course view,
// a reload stays on the order and "Gửi bếp (n)" goes back to the board.
//
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

const FLOOR = [
  { id: 'posres_1', name: 'Bàn 1' },
  { id: 'posres_2', name: 'Bàn 2' },
  { id: 'posres_3', name: 'Bàn 3' },
];

// A board drawn from the orders of the fixture, one table asking for its
// bill, and the command that seats guests at a free table.
async function routeFloor(context: BrowserContext, world: World, askingForBill: string) {
  const opens: Array<Record<string, unknown>> = [];
  const answers = new Map<string, unknown>();
  await context.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: '2026-11-11T05:00:00Z',
          areas: [],
          resources: FLOOR.map((table) => {
            const orders = [...world.sheets.values()]
              .filter((sheet) => sheet.table?.id === table.id && sheet.status === 'editing')
              .map((sheet) => serialize(world, sheet));
            const asked = table.id === askingForBill && orders.length > 0;
            const subtotal = orders.reduce((sum, order) => sum + Number(order.totals.total), 0);
            return {
              ...table,
              state: orders.length === 0 ? 'available' : asked ? 'payment_requested' : 'occupied',
              guest_count: orders[0]?.guest_count ?? null,
              seated_minutes: orders.length ? 12 : null,
              subtotal: orders.length ? `${subtotal}.0` : null,
              currency: orders.length ? 'VND' : null,
              payment_requested: asked,
              orders: orders.map((order) => ({
                id: order.id,
                total: order.totals.total,
                guest_count: order.guest_count,
                payment_requested: asked,
                unsent_kitchen_items: order.line_items.reduce(
                  (sum, line) => sum + Number(line.pending_kitchen_quantity ?? 0),
                  0,
                ),
              })),
            };
          }),
        },
      },
    }),
  );
  await context.route('**/api/v3/admin/pos/tables/*/open', (route) => {
    const request = route.request();
    const key = request.headers()['idempotency-key'] ?? '';
    if (!answers.has(key)) {
      const body = request.postDataJSON() as Record<string, unknown>;
      opens.push(body);
      const table = FLOOR.find((row) => request.url().includes(`/tables/${row.id}/open`));
      if (!table)
        return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
      const sheet = addSheet(world, `ws_${table.id}`, {
        editor: String(body.editor_id),
        table: { ...table, label: null, guests: typeof body.guest_count === 'number' ? body.guest_count : null },
      });
      answers.set(key, { data: serialize(world, sheet) });
    }
    return route.fulfill({ status: 201, json: answers.get(key) });
  });
  return opens;
}

test('the board opens a free table with its guests; dishes go to the kitchen by send, stay and course', async ({
  context,
}) => {
  const menu = teaMenu();
  // No sugar is picked for the guest: the required group must be chosen.
  menu.groups[0].options[1].default = false;
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu,
  });
  const asking = addSheet(world, 'ws_t2', { table: { id: 'posres_2', name: 'Bàn 2', label: null, guests: 4 } });
  addLine(world, asking, 'v_flan', 1);
  const serving = addSheet(world, 'ws_t3', { table: { id: 'posres_3', name: 'Bàn 3', label: null, guests: 2 } });
  addLine(world, serving, 'v_peach', 1);
  await installRetailApi(context, world);
  const opens = await routeFloor(context, world, 'posres_2');
  const page = await context.newPage();
  await login(page);

  // The sale opens on the board; each tile has its tone.
  const board = page.getByRole('region', { name: 'Bảng bàn' });
  await expect(board).toBeVisible();
  await expect(page).toHaveURL(/view=board/);
  const tileOf = (name: string) => board.locator('.board-tile', { hasText: name });
  await expect(tileOf('Bàn 1')).toHaveAttribute('data-tone', 'free');
  await expect(tileOf('Bàn 2')).toHaveAttribute('data-tone', 'payment');
  await expect(tileOf('Bàn 3')).toHaveAttribute('data-tone', 'serving');

  // "Cần xử lý" keeps only the table asking for its bill.
  await board.getByRole('button', { name: 'Cần xử lý 1', exact: true }).click();
  await expect(board.locator('.board-tile[data-table-id]')).toHaveCount(1);
  await expect(tileOf('Bàn 2')).toBeVisible();
  await board.getByRole('button', { name: 'Tất cả 3', exact: true }).click();
  await expect(board.locator('.board-tile[data-table-id]')).toHaveCount(3);

  // A free table opens with its guests on its order.
  await tileOf('Bàn 1').click();
  const seat = page.getByRole('dialog', { name: 'Bàn 1' });
  await seat.getByRole('button', { name: '3', exact: true }).click();
  await seat.getByRole('button', { name: 'Mở bàn · 3 khách' }).click();
  await expect(page).toHaveURL(/view=order/);
  expect(opens).toEqual([expect.objectContaining({ guest_count: 3 })]);
  const order = ticket(page);
  await expect(order.locator('.ticket-header')).toContainText('Bàn 1');
  await expect(order.locator('.ticket-header')).toContainText('3 khách');

  // A plain dish adds in one tap; one with options waits for its required group.
  const grid = page.getByRole('list', { name: 'Thực đơn' });
  await grid.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect(order.locator('.ticket-line')).toHaveCount(1);
  await grid.getByRole('button', { name: 'Trà sữa', exact: true }).click();
  const panel = page.getByRole('region', { name: 'Trà sữa' });
  await expect(grid).toHaveCount(0);
  await expect(panel.getByRole('button', { name: 'Chọn Đường để thêm' })).toBeDisabled();
  await panel.getByRole('radio', { name: '50% đường' }).click();
  await panel.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(panel).toHaveCount(0);
  await expect(order.locator('.ticket-line')).toHaveCount(2);

  // "Gửi & ở lại" sends both and stays on the order.
  await order.getByRole('button', { name: 'Gửi & ở lại', exact: true }).click();
  await expect.poll(() => world.sheets.get('ws_posres_1')?.kitchenSends?.length).toBe(1);
  await expect(page).toHaveURL(/view=order/);
  await expect(grid).toBeVisible();

  // By course: a dish held for the main course waits until it is called out.
  await order.getByRole('button', { name: 'Course', exact: true }).click();
  await expect(order.getByRole('region', { name: 'Không theo course' })).toBeVisible();
  const hold = order.getByRole('button', { name: 'Giữ món', exact: true });
  await hold.click();
  await grid.getByRole('button', { name: 'Trà đào', exact: true }).click();
  const main = order.getByRole('region', { name: 'Món chính · đang giữ' });
  await expect(main.locator('.ticket-line')).toHaveCount(1);
  await expect(order.getByRole('button', { name: /^Gửi bếp/ })).toHaveText('Gửi bếp (0)');
  await main.getByRole('button', { name: 'Gọi món ra', exact: true }).click();
  await expect(order.getByRole('region', { name: /^Món chính · đã gọi / })).toBeVisible();
  expect(world.sheets.get('ws_posres_1')?.kitchenSends?.map((send) => send.items)).toEqual([2, 1]);
  await hold.click();
  await expect(hold).toHaveAttribute('aria-pressed', 'false');

  // A reload stays on the order of the table.
  await page.reload();
  await expect(page).toHaveURL(/view=order/);
  await expect(order.locator('.ticket-header')).toContainText('Bàn 1');
  await expect(order.locator('.ticket-line')).toHaveCount(3);

  // One more dish: "Gửi bếp (1)" sends it and goes back to the board.
  await grid.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await order.getByRole('button', { name: 'Gửi bếp (1)', exact: true }).click();
  await expect(page).toHaveURL(/view=board/);
  await expect.poll(() => world.sheets.get('ws_posres_1')?.kitchenSends?.length).toBe(3);
  await expect(tileOf('Bàn 1')).toHaveAttribute('data-tone', 'serving');
});
