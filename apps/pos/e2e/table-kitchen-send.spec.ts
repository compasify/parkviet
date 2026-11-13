import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, newWorld, tab } from './support/retail-api';

// Two tabs serve one table at once. Neither holds the order, yet both add
// dishes without a 409; one tab's taps on the same dish land on one line, and
// "Báo bếp" sends what the kitchen has not heard yet, once. A sent dish then
// comes back only through the void dialog, with a reason and an approval.
// Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.kitchen': true };

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
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
  });
  // Another device holds the order's lease.
  addSheet(world, 'ws_t1', {
    editor: 'another-device',
    table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 },
  });
  await installRetailApi(context, world);
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

  const waiter = await context.newPage();
  const cashier = await context.newPage();
  for (const page of [waiter, cashier]) {
    await login(page);
    // The sale opens on the table board; the table's one order opens on a tap.
    await page.locator('.board-tile', { hasText: 'Bàn 1' }).click();
    await tab(page, 'ws_t1').click();
    await expect(page.getByRole('list', { name: 'Thực đơn' })).toBeVisible();
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

  // "Báo bếp" counts the three dishes the kitchen has not heard about.
  await expect(cashier.locator('.basket-lines tr')).toHaveCount(2);
  const send = cashier.getByRole('button', { name: /Báo bếp/ });
  await expect(send).toContainText('3');
  await send.click();
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(1);
  expect(world.sheets.get('ws_t1')?.kitchenSends?.[0].items).toBe(3);
  await expect(cashier.locator('.basket-line-kitchen').first()).toContainText('Đã báo bếp ×');
  // Each line shows what the kitchen does with it, as the waiter's phone does.
  await expect(cashier.getByTestId('line-kitchen-states').first()).toContainText('Mới');
  await expect(send).toBeDisabled();

  // The waiter's tab learns of the send; nothing is left to send there.
  await waiter.reload();
  await tab(waiter, 'ws_t1').click();
  await expect(waiter.getByRole('button', { name: /Báo bếp/ })).toBeDisabled();
  expect(world.writes.filter((write) => write.family === 'kitchen.send')).toHaveLength(1);

  // A sent dish comes back only through the void dialog: a reason, and an
  // approval for someone who may not void.
  await cashier.getByRole('button', { name: 'Giảm số lượng Bánh flan' }).click();
  const dialog = cashier.getByRole('dialog', { name: 'Hủy món đã báo bếp: Bánh flan' });
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole('radio', { name: 'Khách đổi ý' })).toBeChecked();
  await expect(dialog.getByLabel('Mã duyệt của quản lý')).toBeVisible();
  await expect(dialog.getByRole('button', { name: /^Hủy 1 món$/ })).toBeDisabled();
  await dialog.getByRole('button', { name: 'Không hủy', exact: true }).click();
  await expect(dialog).toHaveCount(0);
});
