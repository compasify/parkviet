import { type BrowserContext, expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addLine, addSheet, FULL_CASHIER, installRetailApi, login, newWorld, postsOf, type World } from './support/retail-api';

// A bar works from its open orders: the named tabs and the orders at the
// tables sit left of the drinks and the ticket, the search has the focus and
// finds a guest without accents, a tab opens with only the guest's name,
// "Gửi" sends and stays on the tab, and a tab opened before midnight is still
// there after it. A table whose guests asked for the bill is green in the
// list and says so. The floor plan is one tap away and an occupied table
// opens its order; paying it comes back to the tabs. A tablet folds the list
// into a modal drawer. Presentation fixtures only: no real account privileges.

const BAR_MODULES = {
  resources: true,
  'fnb.menu': true,
  'fnb.kitchen': true,
  'fnb.tables': true,
  'fnb.postpay': true,
  'fnb.bottle_keep': true,
};

function barWorld(): World {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: BAR_MODULES,
    profile: { key: 'bar_pub_club', version: 2, display: { surface: 'tab_list' } },
    menu: teaMenu(),
  });
  // Opened at 23:30 the evening before (Asia/Saigon), still open after midnight.
  addSheet(world, 'ws_tuan', { tabName: 'Anh Tuấn', openedAt: '2026-11-11T16:30:00Z' });
  // The order at the VIP table, whose guests asked for the bill.
  const vip = addSheet(world, 'ws_abc', {
    table: { id: 'posres_vip1', name: 'VIP 1', label: null, guests: 12 },
    openedAt: '2026-11-11T13:45:00Z',
    minimumSpend: { minimum: '3000000', amount: '2950000', waived: false },
    drinkCredit: { total: '200000', used: '50000', remaining: '150000' },
  });
  addLine(world, vip, 'v_water', 10);
  return world;
}

// The VIP floor: one table, seated with its order while that is open.
async function routeBoard(target: Page | BrowserContext, world: World) {
  await target.route('**/api/v3/admin/pos/resource_board**', (route) => {
    const open = world.sheets.get('ws_abc')?.status !== 'completed';
    return route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: '2026-11-11T18:00:00Z',
          areas: [{ id: 'posarea_1', name: 'Tầng VIP', position: 0, floor_width: 1200, floor_height: 800 }],
          resources: [
            {
              id: 'posres_vip1', area_id: 'posarea_1', name: 'VIP 1',
              state: open ? 'payment_requested' : 'available',
              guest_count: open ? 12 : null, seated_minutes: open ? 255 : null,
              subtotal: open ? '50000.0' : null, currency: 'VND', payment_requested: open,
              orders: open
                ? [{
                    id: 'ws_abc', total: '50000.0', guest_count: 12, payment_requested: true,
                    unsent_kitchen_items: 0, opened_at: '2026-11-11T13:45:00Z',
                  }]
                : [],
            },
          ],
        },
      },
    });
  });
}

async function openBar(page: Page, world = barWorld()) {
  await installRetailApi(page, world);
  await routeBoard(page, world);
  await login(page);
  return world;
}

const tabColumn = (page: Page) => page.locator('.tab-column');
const tabRow = (page: Page, name: string) => tabColumn(page).locator('.tab-row', { hasText: name });
const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu bàn' });
const menuTile = (page: Page, name: string) =>
  page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name, exact: true });

test.describe('beside the menu', () => {
  test.skip(({ viewport }) => (viewport?.width ?? 0) <= 1100, 'the tabs fold into a drawer');

  test('a tab opens by name, takes two drinks, sends and stays; another is found without accents', async ({
    page,
  }) => {
    const world = await openBar(page);

    // The open tabs and table orders, the menu and an empty ticket, with the
    // search ready.
    await expect(page.getByRole('region', { name: 'Tab đang mở' })).toBeVisible();
    const search = tabColumn(page).getByRole('searchbox', { name: 'Tìm tab' });
    await expect(search).toBeFocused();
    await expect(page).toHaveURL(/view=order/);
    await expect(menuTile(page, 'Bánh flan')).toBeVisible();
    await expect(ticket(page)).toContainText('Chưa chọn tab.');
    // The tab opened before midnight is still listed, at its opening time.
    await expect(tabRow(page, 'Anh Tuấn')).toContainText('23:30');
    await expect(tabRow(page, 'Anh Tuấn')).not.toHaveClass(/tab-row-payment/);
    // The table that asked for the bill is green and says so.
    await expect(tabRow(page, 'VIP 1')).toHaveClass(/tab-row-payment/);
    await expect(tabRow(page, 'VIP 1')).toContainText('Tầng VIP · 20:45');
    await expect(tabRow(page, 'VIP 1')).toContainText('Gọi thanh toán');

    // Nobody called Lan: "Mở tab" opens a tab with the name typed.
    await search.fill('lan');
    await expect(tabColumn(page).getByRole('status')).toHaveText('Không có tab nào khớp.');
    await tabColumn(page).getByRole('button', { name: 'Mở tab' }).click();
    await expect.poll(() => postsOf(world, 'workspace.create').length).toBe(1);
    expect(postsOf(world, 'workspace.create')[0].body).toMatchObject({ service_mode: 'tab', tab_name: 'lan' });
    await expect(ticket(page).locator('.ticket-name > span')).toHaveText('lan');
    await expect(tabRow(page, 'lan')).toHaveAttribute('aria-current', 'true');
    await expect(search).toBeFocused();

    // Two drinks, then one send that stays on the tab.
    await menuTile(page, 'Bánh flan').click();
    await menuTile(page, 'Trà đào').click();
    await expect(ticket(page).locator('.ticket-line')).toHaveCount(2);
    await expect(tabRow(page, 'lan')).toContainText('2 chưa gửi');
    await expect(ticket(page).getByRole('button', { name: 'Gửi & ở lại' })).toHaveCount(0);
    await ticket(page).getByRole('button', { name: 'Gửi (2)', exact: true }).click();
    await expect.poll(() => postsOf(world, 'kitchen.send').length).toBe(1);
    await expect(page.getByRole('status').filter({ hasText: 'Đã gửi 2 món' })).toBeVisible();
    await expect(page).toHaveURL(/view=order/);
    await expect(ticket(page).locator('.ticket-name > span')).toHaveText('lan');
    await expect(ticket(page).getByRole('button', { name: 'Gửi (0)', exact: true })).toBeDisabled();
    await expect(tabRow(page, 'lan')).not.toContainText('chưa gửi');

    // "tuan" finds Anh Tuấn; one tap shows the tab, the search keeps the focus.
    await search.fill('tuan');
    await expect(tabColumn(page).locator('.tab-row')).toHaveCount(1);
    await tabRow(page, 'Anh Tuấn').click();
    await expect(ticket(page).locator('.ticket-name > span')).toHaveText('Anh Tuấn');
    await expect(search).toBeFocused();

    // The table's row opens the table's order on the ticket.
    await search.fill('vip');
    await tabRow(page, 'VIP 1').click();
    await expect(tabRow(page, 'VIP 1')).toHaveAttribute('aria-current', 'true');
    await expect(ticket(page).locator('.ticket-name')).toContainText('VIP 1');
  });

  test('opening a tab under a name already open picks that tab', async ({ page }) => {
    const world = await openBar(page);
    const search = tabColumn(page).getByRole('searchbox', { name: 'Tìm tab' });
    await search.fill('anh tuấn');
    await tabColumn(page).getByRole('button', { name: 'Mở tab' }).click();
    await expect(tabColumn(page).getByRole('alert')).toContainText('đã có tab đang mở');
    await expect(tabRow(page, 'Anh Tuấn')).toHaveAttribute('aria-current', 'true');
    await expect(ticket(page).locator('.ticket-name > span')).toHaveText('Anh Tuấn');
    expect(postsOf(world, 'workspace.create')).toHaveLength(1);
  });

  test('the floor plan opens a table’s order; paying it returns to the tabs', async ({ context }) => {
    const world = barWorld();
    await installRetailApi(context, world);
    await routeBoard(context, world);
    const page = await context.newPage();
    await login(page);

    // One tap to the floor plan and back.
    await tabColumn(page).getByRole('button', { name: 'Sơ đồ bàn' }).click();
    await expect(page.getByRole('region', { name: 'Bảng bàn' })).toBeVisible();
    await page.getByRole('button', { name: 'Tab đang mở' }).click();
    await expect(tabColumn(page)).toBeVisible();
    await tabColumn(page).getByRole('button', { name: 'Sơ đồ bàn' }).click();

    // The occupied VIP table opens its order beside the open tabs.
    await page.locator('.board-tile', { hasText: 'VIP 1' }).click();
    await expect(page).toHaveURL(/view=order/);
    await expect(tabRow(page, 'VIP 1')).toHaveAttribute('aria-current', 'true');
    await expect(ticket(page).locator('.ticket-name')).toContainText('VIP 1');

    // A table order is paid, not closed as a tab: the minimum spend fee, the
    // drink credit and a tip.
    await ticket(page).getByRole('button', { name: /^Thanh toán/ }).click();
    await expect(page).toHaveURL(/view=pay/);
    await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
    const pay = page.locator('.pay-screen');
    await expect(pay.locator('.minimum-spend-line')).toContainText('Phụ thu mức tối thiểu');
    await expect(pay.locator('.minimum-spend-line')).toContainText('2.950.000');
    await expect(pay.locator('.drink-credit-line')).toContainText('150.000');
    const cash = pay.getByRole('region', { name: 'Tiền mặt' });
    await cash.getByLabel('Tip').fill('20.000');
    await cash.getByRole('button', { name: 'Đúng 70.000' }).click();
    await pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' }).click();
    await expect.poll(() => world.sheets.get('ws_abc')?.status).toBe('completed');
    expect(postsOf(world, 'tender.confirm').at(-1)?.body).toMatchObject({ handed_amount: '70000', tip_amount: '20000' });

    // Back on the open tabs once the change is given (these fixtures keep the
    // tip in the change), the paid table gone and nothing picked.
    await page.getByRole('alert').filter({ hasText: 'Tiền thừa' }).getByRole('button', { name: 'Tab đang mở' }).click();
    await expect(page).toHaveURL(/view=order/);
    await expect(tabColumn(page)).toBeVisible();
    await expect(tabRow(page, 'VIP 1')).toHaveCount(0);
    await expect(ticket(page)).toContainText('Chưa chọn tab.');
  });

  test('on 1366px the drinks lose columns, not size, beside the 240px tabs', async ({ page }) => {
    await page.setViewportSize({ width: 1366, height: 768 });
    await openBar(page);
    await expect(menuTile(page, 'Bánh flan')).toBeVisible();
    const column = await tabColumn(page).boundingBox();
    expect(column?.width).toBe(240);
    const tile = await menuTile(page, 'Bánh flan').boundingBox();
    expect(tile?.width ?? 0).toBeGreaterThanOrEqual(138);
  });
});

test.describe('on a tablet', () => {
  test.skip(({ viewport }) => (viewport?.width ?? 0) > 1100, 'the tabs sit beside the menu');

  test('the tabs fold into a modal drawer that picks a row and closes', async ({ page }) => {
    await openBar(page);

    await expect(tabColumn(page)).toBeHidden();
    const toggle = page.getByRole('button', { name: /^Tab đang mở/ });
    // One tab and one table order.
    await expect(toggle).toContainText('2');

    // Escape closes the drawer and gives the focus back to its button.
    await toggle.click();
    const drawer = page.getByRole('dialog', { name: 'Tab đang mở' });
    await expect(drawer).toBeVisible();
    await expect(drawer).toHaveAttribute('aria-modal', 'true');
    await expect(toggle).toHaveAttribute('aria-expanded', 'true');
    const search = drawer.getByRole('searchbox', { name: 'Tìm tab' });
    await expect(search).toBeFocused();
    await page.keyboard.press('Escape');
    await expect(drawer).toBeHidden();
    await expect(toggle).toBeFocused();

    // Tab stays inside the open drawer.
    await toggle.click();
    await expect(search).toBeFocused();
    for (let step = 0; step < 6; step += 1) await page.keyboard.press('Tab');
    expect(await drawer.evaluate((element) => element.contains(document.activeElement))).toBe(true);

    await search.fill('vip');
    await tabRow(page, 'VIP 1').click();
    await expect(drawer).toBeHidden();
    await expect(ticket(page).locator('.ticket-name')).toContainText('VIP 1');
    await expect(menuTile(page, 'Bánh flan')).toBeVisible();
  });

  test('under a finger the drawer opens without popping the keyboard', async ({ page }) => {
    // A touch screen: the pointer is coarse.
    await page.addInitScript(() => {
      const original = window.matchMedia.bind(window);
      window.matchMedia = (query: string) =>
        query === '(pointer: coarse)' ? ({ ...original(query), matches: true } as MediaQueryList) : original(query);
    });
    await openBar(page);

    await page.getByRole('button', { name: /^Tab đang mở/ }).click();
    const drawer = page.getByRole('dialog', { name: 'Tab đang mở' });
    await expect(drawer).toBeFocused();
    await expect(drawer.getByRole('searchbox', { name: 'Tìm tab' })).not.toBeFocused();
  });
});
