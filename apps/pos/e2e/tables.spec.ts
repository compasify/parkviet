import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, login, newWorld, serialize, type World } from './support/retail-api';

// A table at a restaurant from seating to paying: the floor shows each table
// with its state written out, seating guests opens a dine-in order held by
// this page, the first pre-bill is recorded and printed, a second one needs a
// manager's approval, and once the order is paid the table is free again.
// Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.postpay': true };
const TABLES = [
  { id: 'posres_1', name: 'Bàn 1', x: 0, y: 0 },
  { id: 'posres_2', name: 'Bàn 2', x: 3, y: 0 },
];

type Recorded = { opens: Array<Record<string, unknown>>; prebills: Array<Record<string, unknown>>; approvals: Array<Record<string, unknown>> };

function tableOrders(world: World, tableId: string) {
  return [...world.sheets.values()].filter(
    (sheet) => sheet.table?.id === tableId && (sheet.status === 'editing' || sheet.status === 'parked'),
  );
}

function board(world: World, prebilled: Set<string>) {
  return {
    branch_id: 'br_1',
    server_now: '2026-11-11T05:00:00Z',
    areas: [{ id: 'posarea_1', name: 'Tầng 1', position: 0, floor_width: 12, floor_height: 8 }],
    resources: TABLES.map((table) => {
      const orders = tableOrders(world, table.id);
      const total = orders.reduce((sum, sheet) => sum + Number(serialize(world, sheet).totals.total), 0);
      const state = orders.length === 0
        ? 'available'
        : orders.some((sheet) => prebilled.has(sheet.id)) ? 'prebilled' : 'occupied';
      return {
        ...table, area_id: 'posarea_1', kind: 'table', capacity: 4, shape: 'rect', w: 2, h: 2, rotation: 0,
        manual_status: 'available', state,
        guest_count: orders.length ? (orders[0].table?.guests ?? null) : null,
        seated_minutes: orders.length ? 5 : null,
        subtotal: orders.length ? `${total}.0` : null,
        currency: orders.length ? 'VND' : null,
        payment_requested: false, edited_after_prebill: false,
        orders: orders.map((sheet) => ({
          id: sheet.id, table_label: sheet.table?.label ?? null, guest_count: sheet.table?.guests ?? null,
          total: serialize(world, sheet).totals.total, revision: sheet.revision, operational_status: sheet.status,
          payment_requested: false, prebilled: prebilled.has(sheet.id), edited_after_prebill: false,
          pending_kitchen_items: 0,
        })),
      };
    }),
  };
}

// The table endpoints, on top of the retail fixture that keeps the orders.
async function installTables(page: Page, world: World): Promise<Recorded> {
  const recorded: Recorded = { opens: [], prebills: [], approvals: [] };
  const prebilled = new Set<string>();
  let sequence = 0;
  const answers = new Map<string, { status: number; json: unknown }>();
  const reply = (route: Route, key: string, answer: () => { status: number; json: unknown }) => {
    const stored = key ? answers.get(key) : undefined;
    const result = stored ?? answer();
    if (key && !stored && result.status < 300) answers.set(key, result);
    return route.fulfill({ status: result.status, json: result.json });
  };
  await page.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({ json: { data: board(world, prebilled) } }),
  );
  await page.route('**/api/v3/admin/pos/tables/*/open', (route) => {
    const request = route.request();
    const body = request.postDataJSON() as Record<string, unknown>;
    const tableId = new URL(request.url()).pathname.split('/').at(-2) ?? '';
    const table = TABLES.find((row) => row.id === tableId);
    return reply(route, request.headers()['idempotency-key'] ?? '', () => {
      recorded.opens.push(body);
      if (!table) return { status: 404, json: { error: { code: 'missing', message: 'missing' } } };
      if (tableOrders(world, tableId).length > 0 && body.add_order !== true)
        return { status: 409, json: { error: { code: 'conflict', message: 'Occupied.', details: { reason: 'table_occupied' } } } };
      const sheet = addSheet(world, `ws_t${world.sheets.size + 1}`, {
        editor: String(body.editor_id),
        table: { id: table.id, name: table.name, label: null, guests: typeof body.guest_count === 'number' ? body.guest_count : null },
      });
      return { status: 201, json: { data: serialize(world, sheet) } };
    });
  });
  await page.route('**/api/v3/admin/pos/workspaces/*/prebill', (route) => {
    const request = route.request();
    const body = request.postDataJSON() as Record<string, unknown>;
    const workspaceId = new URL(request.url()).pathname.split('/').at(-2) ?? '';
    return reply(route, request.headers()['idempotency-key'] ?? '', () => {
      recorded.prebills.push(body);
      if (prebilled.has(workspaceId) && !body.approval_id)
        return {
          status: 409,
          json: { error: { code: 'conflict', message: 'Approval required.', details: { reason: 'approval_required', action: 'workspace.reprint_prebill' } } },
        };
      prebilled.add(workspaceId);
      sequence += 1;
      return {
        status: 201,
        json: {
          data: {
            prebill: {
              id: `posprebill_${sequence}`, sequence, revision: 1, status: 'current', total: '15000.0', currency: 'VND',
              staff_id: 'stf_1', approval_id: body.approval_id ?? null, printed_at: '2026-11-11T05:00:00Z',
            },
          },
        },
      };
    });
  });
  await page.route('**/api/v3/admin/pos/approvals', (route) => {
    const body = route.request().postDataJSON() as Record<string, unknown>;
    recorded.approvals.push(body);
    return route.fulfill({
      status: 201,
      json: { data: { id: `posapproval_${recorded.approvals.length}`, action: body.action_name, status: 'active' } },
    });
  });
  return recorded;
}

async function stubPrint(page: Page) {
  await page.addInitScript(() => {
    (window as unknown as { printed: number }).printed = 0;
    window.print = () => {
      (window as unknown as { printed: number }).printed += 1;
    };
  });
}

const printed = (page: Page) => page.evaluate(() => (window as unknown as { printed: number }).printed);
const tableBoard = (page: Page) => page.getByRole('region', { name: 'Bảng bàn' });
const tile = (page: Page, name: string) => tableBoard(page).locator('.board-tile', { hasText: name });

test('a table is seated, ordered, pre-billed, paid and free again', async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.approval.grant'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'table_grid' } },
    menu: teaMenu(),
  });
  await stubPrint(page);
  await installRetailApi(page, world);
  const recorded = await installTables(page, world);
  await login(page);

  // The sale opens on the table board, with no invoice tabs, basket or
  // checkout; each state is written beside its colour.
  await expect(tableBoard(page)).toBeVisible();
  await expect(page).toHaveURL(/view=board/);
  await expect(page.getByRole('tablist')).toHaveCount(0);
  await expect(page.locator('#pos-basket, #pos-checkout')).toHaveCount(0);
  await expect(tile(page, 'Bàn 1')).toHaveAttribute('aria-label', 'Bàn 1 · Trống');
  await expect(tile(page, 'Bàn 2')).toContainText('Trống');
  await expect(tableBoard(page).getByRole('button', { name: 'Trống 2', exact: true })).toBeVisible();

  // A free table asks for the guests right under its tile; Escape closes it.
  await tile(page, 'Bàn 1').click();
  const seat = page.getByRole('dialog', { name: 'Bàn 1' });
  await expect(seat).toContainText('Mở Bàn 1');
  await page.keyboard.press('Escape');
  await expect(seat).toHaveCount(0);
  await tile(page, 'Bàn 1').click();
  await seat.getByRole('button', { name: '3', exact: true }).click();
  await seat.getByRole('button', { name: '2', exact: true }).click();
  await seat.getByRole('button', { name: 'Mở bàn · 2 khách' }).click();
  expect(recorded.opens).toEqual([expect.objectContaining({ branch_id: 'br_1', guest_count: 2 })]);
  await expect(page).toHaveURL(/view=order/);
  expect(typeof recorded.opens[0].editor_id).toBe('string');

  // The new order opens for ordering, its ticket headed by the table.
  const ticket = page.getByRole('complementary', { name: 'Phiếu bàn' });
  await expect(ticket.locator('.ticket-header')).toContainText('Bàn 1');
  await expect(ticket.locator('.ticket-header')).toContainText('2 khách');
  const menu = page.getByRole('list', { name: 'Thực đơn' });
  await menu.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect(ticket.locator('.ticket-line')).toHaveCount(1);

  // The first pre-bill is recorded, then printed.
  await ticket.getByRole('button', { name: 'In tạm tính' }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toContainText('TẠM TÍNH – CHƯA THANH TOÁN');
  await dialog.getByRole('button', { name: 'In phiếu tạm tính' }).click();
  await expect.poll(() => printed(page)).toBe(1);
  expect(recorded.prebills).toHaveLength(1);
  expect(recorded.prebills[0].approval_id).toBeUndefined();

  // Printing it again needs an approval; a manager at the order grants it here.
  await dialog.getByRole('button', { name: 'In phiếu tạm tính' }).click();
  await expect(dialog).toContainText('In lại cần quản lý duyệt');
  expect(await printed(page)).toBe(1);
  await dialog.getByRole('button', { name: 'Duyệt và in lại' }).click();
  await expect.poll(() => printed(page)).toBe(2);
  expect(recorded.approvals).toEqual([
    expect.objectContaining({ action_name: 'workspace.reprint_prebill', requester_id: 'stf_1', workspace_id: 'ws_t1' }),
  ]);
  expect(recorded.prebills.at(-1)?.approval_id).toBe('posapproval_1');
  await dialog.getByRole('button', { name: 'Đóng' }).click();
  await expect(dialog).toHaveCount(0);

  // On the board the table shows its pre-bill.
  await ticket.getByRole('button', { name: 'Về bảng bàn', exact: true }).click();
  await expect(tile(page, 'Bàn 1')).toHaveAttribute('data-tone', 'prebilled');
  await expect(tile(page, 'Bàn 1')).toContainText('Đã in tạm tính');
  await expect(tile(page, 'Bàn 1')).toContainText('15.000 ₫');
  await expect(tile(page, 'Bàn 1')).toContainText('5′');
  // Tapping the table with its one order goes straight back to it.
  await tile(page, 'Bàn 1').click();
  await expect(ticket.locator('.ticket-header')).toContainText('Bàn 1');

  // Paid in cash on the payment screen, the order closes, the board comes
  // back and the table is free again.
  await ticket.getByRole('button', { name: /^Thanh toán/ }).click();
  await expect(page).toHaveURL(/view=pay/);
  const pay = page.locator('.pay-screen');
  await pay.getByRole('button', { name: 'Đúng 15.000' }).click();
  await pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.status).toBe('completed');
  await expect(page).toHaveURL(/view=board/);
  await expect(tile(page, 'Bàn 1')).toHaveAttribute('aria-label', 'Bàn 1 · Trống');
});

test('the floor plan is remembered on this device and draws the tables of the area', async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'table_grid' } },
    menu: teaMenu(),
  });
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await installTables(page, world);
  await login(page);
  await expect(tableBoard(page).locator('.table-board-grid')).toBeVisible();
  await tableBoard(page).getByRole('button', { name: 'Sơ đồ', exact: true }).click();
  const plan = tableBoard(page).getByRole('group', { name: 'Tầng 1' });
  await expect(plan.locator('.board-tile')).toHaveCount(2);
  expect(await page.evaluate(() => localStorage.getItem('parkviet-pos:table-surface'))).toBe('floor_plan');
  // A reload keeps the board, which comes back as a plan.
  await page.reload();
  await expect(tableBoard(page).getByRole('group', { name: 'Tầng 1' })).toBeVisible();
});
