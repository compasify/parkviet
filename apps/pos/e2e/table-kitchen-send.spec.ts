import { type BrowserContext, expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, newWorld, type World } from './support/retail-api';

// Two tabs serve one table at once. Neither holds the order, yet both add
// dishes without a 409; one tab's taps on the same dish land on one line, and
// "Gửi bếp (n)" on the table ticket sends what the kitchen has not heard yet,
// once, and goes back to the board. A sent dish then comes back only through
// the void dialog, with a reason and an approval. "Gửi & ở lại" sends and
// stays on the order, where the ticket groups the dishes by send.
// Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.kitchen': true };

const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu bàn' });

function tableWorld(): World {
  return newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
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

async function login(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.header-user')).toHaveText('Lan');
}

test('two tabs add to one table without the lease, then send the difference to the kitchen', async ({
  context,
}) => {
  const world = tableWorld();
  // Another device holds the order's lease.
  addSheet(world, 'ws_t1', {
    editor: 'another-device',
    table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 },
  });
  await installRetailApi(context, world);
  await routeBoard(context);

  const waiter = await context.newPage();
  const cashier = await context.newPage();
  for (const page of [waiter, cashier]) {
    await login(page);
    // The sale opens on the table board; the table's one order opens on a tap.
    await page.locator('.board-tile', { hasText: 'Bàn 1' }).click();
    await expect(page.getByRole('list', { name: 'Thực đơn' })).toBeVisible();
    await expect(ticket(page)).toContainText('Bàn 1');
  }

  // The waiter taps the flan twice; the cashier adds a peach tea meanwhile.
  const waiterMenu = waiter.getByRole('list', { name: 'Thực đơn' });
  await waiterMenu.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.lines.length).toBe(1);
  await waiterMenu.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.lines[0]?.quantity).toBe(2);
  await cashier
    .getByRole('list', { name: 'Thực đơn' })
    .getByRole('button', { name: 'Trà đào', exact: true })
    .click();
  await expect.poll(() => world.sheets.get('ws_t1')?.lines.length).toBe(2);
  expect(world.conflicts).toBe(0);
  expect(world.writes.filter((write) => write.family === 'items')).toHaveLength(0);
  const appends = world.writes.filter((write) => write.family === 'items.append');
  expect(appends).toHaveLength(3);
  for (const write of appends) expect(write.body).not.toHaveProperty('expected_revision');
  // Each tab is its own batch: the waiter's two taps share one, the cashier's is another.
  expect(new Set(appends.map((write) => write.body.append_batch_id)).size).toBe(2);

  // "Gửi bếp (n)" counts the three dishes the kitchen has not heard about,
  // all of them new on the ticket.
  await expect(ticket(cashier).locator('.ticket-line')).toHaveCount(2);
  await expect(
    ticket(cashier).getByRole('region', { name: 'MỚI · chưa gửi bếp · 3 món' }),
  ).toBeVisible();
  const send = ticket(cashier).getByRole('button', { name: /^Gửi bếp/ });
  await expect(send).toHaveText('Gửi bếp (3)');
  await send.click();
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(1);
  expect(world.sheets.get('ws_t1')?.kitchenSends?.[0].items).toBe(3);
  // The send goes back to the board and says what it sent.
  await expect(cashier).toHaveURL(/view=board/);
  await expect(cashier.getByRole('status').filter({ hasText: 'Đã gửi 3 món' })).toBeVisible();

  // Back on the order, the dishes are the first send's, locked, with what
  // the kitchen does with them, as the waiter's phone shows.
  await cashier.locator('.board-tile', { hasText: 'Bàn 1' }).click();
  const round = ticket(cashier).getByRole('region', { name: /^Lượt 1 · \d\d:\d\d · Lan$/ });
  await expect(round.locator('.ticket-line')).toHaveCount(2);
  await expect(round.locator('.ticket-line').first()).toContainText('Đã gửi');
  await expect(round.locator('.ticket-line-lock')).toHaveCount(2);
  await expect(send).toHaveText('Gửi bếp (0)');
  await expect(send).toBeDisabled();

  // The waiter's tab learns of the send; nothing is left to send there.
  await waiter.reload();
  await expect(ticket(waiter).getByRole('button', { name: /^Gửi bếp/ })).toBeDisabled();
  expect(world.writes.filter((write) => write.family === 'kitchen.send')).toHaveLength(1);

  // A sent dish comes back only through the void dialog: a reason, and an
  // approval for someone who may not void.
  await round.getByRole('button', { name: /Bánh flan/ }).click();
  await round.getByRole('button', { name: 'Hủy món', exact: true }).click();
  const dialog = cashier.getByRole('dialog', { name: 'Hủy món đã báo bếp: Bánh flan' });
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole('radio', { name: 'Khách đổi ý' })).toBeChecked();
  await expect(dialog.getByLabel('Mã duyệt của quản lý')).toBeVisible();
  await expect(dialog.getByRole('button', { name: /^Hủy 1 món$/ })).toBeDisabled();
  await dialog.getByRole('button', { name: 'Không hủy', exact: true }).click();
  await expect(dialog).toHaveCount(0);
});

test('"Gửi & ở lại" sends and stays; a held course waits; "Gửi bếp" then goes back to the board', async ({
  context,
}) => {
  const world = tableWorld();
  addSheet(world, 'ws_t1', { table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 } });
  await installRetailApi(context, world);
  await routeBoard(context);
  const page = await context.newPage();
  await login(page);
  await page.locator('.board-tile', { hasText: 'Bàn 1' }).click();
  const menu = page.getByRole('list', { name: 'Thực đơn' });
  const order = ticket(page);

  // Two dishes, sent while staying on the order.
  await menu.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await menu.getByRole('button', { name: 'Trà đào', exact: true }).click();
  await expect(order.locator('.ticket-line')).toHaveCount(2);
  await order.getByRole('button', { name: 'Gửi & ở lại', exact: true }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(1);
  await expect(page.getByRole('status').filter({ hasText: 'Đã gửi 2 món' })).toBeVisible();
  await expect(page).toHaveURL(/view=order/);
  await expect(menu).toBeVisible();
  await expect(order.getByRole('region', { name: /^Lượt 1 · / })).toBeVisible();

  // A dish held for its course waits apart and is not counted for the kitchen.
  const hold = order.getByRole('button', { name: 'Giữ món', exact: true });
  await hold.click();
  await expect(hold).toHaveAttribute('aria-pressed', 'true');
  await expect(order.locator('.ticket-placement')).toContainText('Món chính · giữ chờ gọi');
  await menu.getByRole('button', { name: 'Bánh flan', exact: true }).click();
  const held = order.getByRole('region', { name: 'Đang giữ · chờ gọi món ra' });
  await expect(held.locator('.ticket-line')).toContainText('Chờ gọi');
  await expect(held.getByRole('button', { name: 'Gọi món ra', exact: true })).toBeVisible();
  await expect(order.getByRole('button', { name: /^Gửi bếp/ })).toHaveText('Gửi bếp (0)');
  const append = world.writes.filter((write) => write.family === 'items.append').at(-1);
  expect((append?.body.items as Array<Record<string, unknown>>)[0]).toMatchObject({
    course: 2,
    hold: true,
  });
  await hold.click();
  await expect(hold).toHaveAttribute('aria-pressed', 'false');

  // A new dish goes on top; "Gửi bếp (1)" sends only it and goes back to the board.
  await menu.getByRole('button', { name: 'Trà đào', exact: true }).click();
  await expect(order.locator('.ticket-group').first()).toHaveAttribute(
    'aria-label',
    'MỚI · chưa gửi bếp · 1 món',
  );
  await order.getByRole('button', { name: 'Gửi bếp (1)', exact: true }).click();
  await expect(page).toHaveURL(/view=board/);
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(2);
  expect(world.sheets.get('ws_t1')?.kitchenSends?.[1].items).toBe(1);
  await expect(page.getByRole('status').filter({ hasText: 'Đã gửi 1 món' })).toBeVisible();

  // The sends read newest first, the held course still waiting above them.
  await page.locator('.board-tile', { hasText: 'Bàn 1' }).click();
  await expect(order.locator('.ticket-group')).toHaveCount(3);
  const labels = await order
    .locator('.ticket-group')
    .evaluateAll((rows) => rows.map((row) => row.getAttribute('aria-label')?.split(' · ')[0]));
  expect(labels).toEqual(['Đang giữ', 'Lượt 2', 'Lượt 1']);
});
