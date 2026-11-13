import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { FULL_CASHIER, installRetailApi, login, newWorld, type World } from './support/retail-api';

// The table-service businesses as the cashier's counter sees them: a
// restaurant opens on its table board drawn as the floor plan, a bar on table
// tiles, an eatery that answered "we serve tables" on the board too, and one
// that did not on the menu alone. A table whose waiter asked for the bill
// says so on the board. Waiter phones, kitchen screens, the service charge
// and taxes are checked on the server and in the staff app.
// Presentation fixtures only: no real account privileges.

type Profile = NonNullable<World['profile']>;
type Display = Profile['display'];

const TABLE_MODULES = { 'fnb.menu': true, 'fnb.kitchen': true, resources: true, 'fnb.tables': true, 'fnb.postpay': true, 'fnb.service_charge': true };
const EATERY = { 'retail.units': true, 'retail.measured': true, 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true };

const profile = (key: string, display: Display): Profile => ({ key, version: 2, display });

function table(id: string, name: string, x: number, state: string) {
  return {
    id, name, area_id: 'posarea_1', kind: 'table', capacity: 4, shape: 'rect', x, y: 0, w: 2, h: 2, rotation: 0,
    manual_status: 'available', state,
    guest_count: state === 'available' ? null : 4,
    seated_minutes: state === 'available' ? null : 20,
    subtotal: state === 'available' ? null : '140000.0',
    currency: state === 'available' ? null : 'VND',
    payment_requested: state === 'payment_requested', edited_after_prebill: false,
    orders: state === 'available'
      ? []
      : [{
          id: `ws_${id}`, table_label: null, guest_count: 4, total: '154000.0', revision: 3, operational_status: 'editing',
          payment_requested: state === 'payment_requested', prebilled: false, edited_after_prebill: false, pending_kitchen_items: 0,
        }],
  };
}

async function open(page: Page, world: World) {
  await installRetailApi(page, world);
  await page.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: '2026-11-12T05:00:00Z',
          areas: [{ id: 'posarea_1', name: 'Tầng 1', position: 0, floor_width: 12, floor_height: 8 }],
          resources: [table('posres_1', 'Bàn 1', 0, 'available'), table('posres_5', 'Bàn 5', 4, 'payment_requested')],
        },
      },
    }),
  );
  await login(page);
}

const board = (page: Page) => page.getByRole('region', { name: 'Bảng bàn' });
const tile = (page: Page, name: string) => board(page).locator('.board-tile', { hasText: name });
const menuGrid = (page: Page) => page.getByRole('list', { name: 'Thực đơn' });

const SURFACES: Array<{ key: string; display: Display; shown: 'plan' | 'tiles' }> = [
  { key: 'nha_hang', display: { surface: 'floor_plan' }, shown: 'plan' },
  { key: 'bar_pub_club', display: { surface: 'table_grid' }, shown: 'tiles' },
];

for (const row of SURFACES) {
  test(`${row.key} opens on the ${row.shown === 'plan' ? 'floor plan' : 'table tiles'}`, async ({ page }) => {
    const world = newWorld({ capabilities: [...FULL_CASHIER, 'pos.table.serve'], modules: TABLE_MODULES, profile: profile(row.key, row.display), menu: teaMenu() });
    await open(page, world);
    await expect(board(page)).toBeVisible();
    if (row.shown === 'plan') {
      await expect(board(page).getByRole('group', { name: 'Tầng 1' })).toBeVisible();
    } else {
      await expect(board(page).locator('.table-board-grid')).toBeVisible();
      await expect(board(page).getByRole('group', { name: 'Tầng 1' })).toHaveCount(0);
    }
    await expect(tile(page, 'Bàn 1')).toHaveAttribute('aria-label', 'Bàn 1 · Trống');
  });
}

test('an eatery that serves tables opens on its table board, as tiles, with takeaway first', async ({ page }) => {
  const modules = { ...EATERY, resources: true, 'fnb.tables': true, 'fnb.postpay': true };
  const world = newWorld({ capabilities: [...FULL_CASHIER, 'pos.table.serve'], modules, profile: profile('quan_an', { surface: 'menu_grid' }), menu: teaMenu() });
  await open(page, world);
  await expect(board(page).locator('.table-board-grid')).toBeVisible();
  await expect(menuGrid(page)).toHaveCount(0);
  await expect(board(page).locator('.board-tile').first()).toContainText('Mang về');
  await expect(tile(page, 'Bàn 1')).toHaveAttribute('aria-label', 'Bàn 1 · Trống');
});
test('an eatery that does not serve tables sells from the menu, with no floor', async ({ page }) => {
  const world = newWorld({ modules: EATERY, profile: profile('quan_an', { surface: 'menu_grid' }), menu: teaMenu() });
  const boardReads: string[] = [];
  page.on('request', (request) => {
    if (/\/pos\/resource_board/.test(request.url())) boardReads.push(request.url());
  });
  await open(page, world);
  await expect(menuGrid(page)).toBeVisible();
  await expect(board(page)).toHaveCount(0);
  await expect(page.locator('.table-floor')).toHaveCount(0);
  expect(boardReads).toEqual([]);
});

test('the table whose waiter asked for the bill says so on the board and needs attention', async ({ page }) => {
  const world = newWorld({ capabilities: [...FULL_CASHIER, 'pos.table.serve'], modules: TABLE_MODULES, profile: profile('nha_hang', { surface: 'floor_plan' }), menu: teaMenu() });
  await open(page, world);
  await expect(tile(page, 'Bàn 5')).toHaveAttribute('aria-label', 'Bàn 5 · Gọi thanh toán');
  await expect(tile(page, 'Bàn 5')).toHaveAttribute('data-tone', 'payment');
  await board(page).getByRole('button', { name: 'Cần xử lý 1', exact: true }).click();
  await expect(board(page).locator('.board-tile[data-table-id]')).toHaveCount(1);
  await expect(tile(page, 'Bàn 5')).toBeVisible();
});
