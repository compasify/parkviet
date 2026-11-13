import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { installRetailApi, login, newWorld, serialize, type World } from './support/retail-api';

// A cafe sells at the quick counter: the menu beside one ticket and no
// invoice tabs. A cup with options goes on the ticket, F1 takes the exact
// amount in cash, the paid call number shows at the head of an empty ticket
// and the next guest's order gets the next number; a note the guest hands
// over leaves the change. An order put on hold waits in the strip and opens
// again. Takeaway is one tap, the GrabFood chip enters a platform order and
// F2 opens the payment on its VietQR. With dishes the kitchen has not had,
// F1 opens the payment screen, which sends them before the cash is taken.
// Presentation fixtures only: no real account privileges.

const CAFE = {
  'retail.units': true,
  'fnb.menu': true,
  'fnb.order_number': true,
  'fnb.cup_label': true,
  'fnb.recipes': true,
  'fnb.delivery_platforms': true,
};

function cafeWorld(vietqr = false, modules: Record<string, boolean> = {}): World {
  return newWorld({
    modules: { ...CAFE, ...modules },
    profile: { key: 'cafe_tra_sua', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
    vietqr,
  });
}

// What the retail fixture leaves to the cafe: the guest's name, the call
// number given as the order completes, and the delivery platforms.
async function installCafeApi(page: Page, world: World) {
  let next = 1;
  await page.route('**/api/v3/admin/pos/**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    const guest = /^\/pos\/workspaces\/([^/]+)\/guest_name$/.exec(path);
    if (guest && request.method() === 'POST') {
      const sheet = world.sheets.get(guest[1]);
      if (!sheet) return route.fulfill({ status: 404, json: {} });
      sheet.guestName = String((request.postDataJSON() as { guest_name?: string }).guest_name ?? '') || null;
      sheet.revision += 1;
      return route.fulfill({ json: { data: serialize(world, sheet) } });
    }
    const complete = /^\/pos\/workspaces\/([^/]+)\/complete$/.exec(path);
    if (complete && request.method() === 'POST') {
      const sheet = world.sheets.get(complete[1]);
      if (sheet && sheet.orderNumber == null) sheet.orderNumber = next++;
    }
    if (path === '/pos/platform_settings')
      return route.fulfill({
        json: {
          data: {
            module_enabled: true,
            platforms: [
              { platform: 'grabfood', status: 'active', commission_rate: '25.0', updated_at: null },
              { platform: 'shopeefood', status: 'disabled', commission_rate: '0.0', updated_at: null },
            ],
          },
        },
      });
    if (path === '/pos/platform_orders' && request.method() === 'GET')
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    return route.fallback();
  });
}

const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu quầy' });
const menu = (page: Page) => page.getByRole('list', { name: 'Thực đơn' });
const dish = (page: Page, name: string) => menu(page).getByRole('button', { name, exact: true });
const prepares = (world: World) => world.writes.filter((write) => write.family === 'tender.prepare');

async function openCounter(page: Page, world: World) {
  await installRetailApi(page, world);
  await installCafeApi(page, world);
  await login(page);
  // The first guest's ticket opens by itself: no tabs, no table board.
  await expect(ticket(page)).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(1);
  await expect(ticket(page).getByText('Chưa gọi món nào. Chạm món bên trái để thêm.')).toBeVisible();
  await expect(page.getByRole('tablist')).toHaveCount(0);
}

test('a cup with options paid by F1 leaves an empty ticket, and the next order gets the next number', async ({
  page,
}) => {
  const world = cafeWorld();
  await openCounter(page, world);
  const first = [...world.sheets.values()][0];
  await expect(ticket(page).getByTestId('call-number')).toHaveText('Số gọi có khi thanh toán');

  // Takeaway in one tap; the cup with its options; the guest's name for the cup label.
  await ticket(page).getByRole('button', { name: 'Mang đi', exact: true }).click();
  await expect(ticket(page).getByRole('button', { name: 'Mang đi', exact: true })).toHaveAttribute('aria-pressed', 'true');
  expect(first.serviceMode).toBe('takeaway');
  await dish(page, 'Trà sữa').click();
  const panel = page.getByRole('region', { name: 'Trà sữa' });
  await panel.getByRole('radio', { name: '50% đường' }).click();
  await panel.getByRole('button', { name: 'Tăng số lượng Trân châu' }).click();
  await panel.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);
  await expect(ticket(page).locator('.ticket-line')).toContainText('Trân châu');
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('35.000 ₫');
  await ticket(page).getByTestId('guest-name').fill('Lan');
  await ticket(page).getByTestId('guest-name').press('Enter');
  await expect.poll(() => first.guestName).toBe('Lan');

  // F1 typed in the dish search is the search's: nothing is paid. The search
  // answering the next keys shows the F1 press was handled already; a cash
  // payment started by it would show on the cash button.
  const searchBox = page.getByRole('searchbox', { name: 'Tìm món hoặc gõ mã' });
  const cash = ticket(page).getByRole('button', { name: /^Tiền mặt đủ/ });
  await searchBox.focus();
  await page.keyboard.press('F1');
  await searchBox.pressSequentially('flan');
  await expect(dish(page, 'Trà sữa')).toHaveCount(0);
  await expect(cash).toBeEnabled();
  expect(prepares(world)).toHaveLength(0);
  expect(first.status).toBe('editing');
  await searchBox.fill('');
  await expect(dish(page, 'Trà sữa')).toBeVisible();

  // Out of the field, F1 takes the exact amount in cash and completes.
  await searchBox.blur();
  await page.keyboard.press('F1');
  await expect.poll(() => first.status).toBe('completed');
  expect(first.allocated).toBe(35000);
  expect(prepares(world).map((write) => [write.body.payment_method_id, write.body.amount])).toEqual([
    ['posmethod-cash', '35000'],
  ]);
  expect(world.writes.find((write) => write.family === 'tender.confirm')?.body.handed_amount).toBe('35000');
  await expect.poll(() => first.handedOver).toBe(true);

  // The paid number stays at the head of an empty ticket for the next guest.
  await expect(ticket(page).getByTestId('quick-done')).toContainText('Số gọi 1');
  await expect.poll(() => world.sheets.size).toBe(2);
  await expect(ticket(page).getByText('Chưa gọi món nào. Chạm món bên trái để thêm.')).toBeVisible();
  const second = [...world.sheets.values()][1];

  // F1 while a cup's options are open belongs to the options: nothing is paid.
  await dish(page, 'Bánh flan').click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');
  await dish(page, 'Trà sữa').click();
  const options = page.getByRole('region', { name: 'Trà sữa' });
  await page.keyboard.press('F1');
  await options.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('45.000 ₫');
  expect(second.status).toBe('editing');
  expect(prepares(world)).toHaveLength(1);

  // The next guest hands over a note: the change shows with the next number.
  await ticket(page).getByRole('button', { name: 'Khách đưa 50.000' }).click();
  await expect.poll(() => second.status).toBe('completed');
  expect(world.writes.filter((write) => write.family === 'tender.confirm').at(-1)?.body.handed_amount).toBe('50000');
  const done = ticket(page).getByTestId('quick-done');
  await expect(done).toContainText('Số gọi 2');
  await expect(done).toContainText('Tiền thừa: 5.000 ₫');
  await expect.poll(() => world.sheets.size).toBe(3);
});

test('an order put on hold waits in the strip and opens again', async ({ page }) => {
  const world = cafeWorld();
  await openCounter(page, world);
  const held = [...world.sheets.values()][0];
  await expect(ticket(page).getByRole('button', { name: 'Giữ đơn' })).toBeDisabled();
  await dish(page, 'Bánh flan').click();
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);

  // Held: a new empty ticket, and the order in the strip above the menu.
  await ticket(page).getByRole('button', { name: 'Giữ đơn' }).click();
  await expect.poll(() => world.sheets.size).toBe(2);
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(0);
  const strip = page.getByRole('list', { name: 'Đơn đang giữ' });
  const chip = strip.locator(`[data-workspace-id="${held.id}"]`);
  await expect(chip).toContainText(held.number);
  await expect(chip).toContainText('15.000');

  // A guest already waiting takes the blank ticket; the held one opens on a tap.
  await chip.click();
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);
  await expect(ticket(page).locator('.ticket-line')).toContainText('Bánh flan');
  await expect(strip).toHaveCount(0);
  expect(world.sheets.size).toBe(2);
});

test('the GrabFood chip enters a platform order and F2 opens the payment on its VietQR', async ({ page }) => {
  const world = cafeWorld(true);
  await openCounter(page, world);

  // The platform chip opens the platform order entry with GrabFood picked.
  await ticket(page).getByRole('button', { name: 'GrabFood', exact: true }).click();
  const form = page.getByTestId('platform-order-form');
  await expect(form.locator('[data-platform="grabfood"]')).toHaveAttribute('aria-pressed', 'true');
  await form.getByRole('button', { name: 'Đóng' }).first().click();
  await expect(form).toHaveCount(0);

  // F2 takes the full payment screen with the QR for what is due.
  await dish(page, 'Bánh flan').click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');
  await page.keyboard.press('F2');
  await expect(page).toHaveURL(/view=pay/);
  const qr = page.locator('.pay-screen').getByRole('region', { name: 'VietQR' });
  await expect(qr.locator('.pay-qr-amount')).toHaveText('15.000 ₫');
  await expect
    .poll(() => prepares(world).map((write) => [write.body.payment_method_id, write.body.amount]))
    .toEqual([['posmethod-vietqr', '15000']]);

  // Back to the ticket: the waiting QR goes, the order is as it was.
  await page.getByRole('button', { name: 'Về đơn để gọi thêm món' }).click();
  await expect(page).toHaveURL(/view=order/);
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);
});

test('F1 with dishes the kitchen has not had opens the payment screen, which sends them first', async ({ page }) => {
  const world = cafeWorld(false, { 'fnb.kitchen': true });
  await openCounter(page, world);
  const order = [...world.sheets.values()][0];
  await dish(page, 'Bánh flan').click();
  await expect(ticket(page).getByRole('button', { name: 'Gửi bếp (1)', exact: true })).toBeEnabled();

  // No cash is taken for an order the kitchen could no longer get.
  await page.keyboard.press('F1');
  await expect(page).toHaveURL(/view=pay/);
  const unsent = page.locator('.pay-unsent');
  await expect(unsent).toContainText('Có món chưa gửi bếp');
  expect(prepares(world)).toHaveLength(0);
  expect(order.status).toBe('editing');
  await unsent.getByRole('button', { name: 'Gửi bếp (1)', exact: true }).click();
  await expect.poll(() => order.kitchenSends?.length).toBe(1);
  await expect(unsent).toHaveCount(0);

  // Back on the ticket, sent: the note buttons take the cash on the spot.
  await page.getByRole('button', { name: 'Về đơn để gọi thêm món' }).click();
  await expect(page).toHaveURL(/view=order/);
  await ticket(page).getByRole('button', { name: 'Khách đưa 20.000' }).click();
  await expect.poll(() => order.status).toBe('completed');
  await expect(ticket(page).getByTestId('quick-done')).toContainText('Tiền thừa: 5.000 ₫');
});
