import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { installRetailApi, login, newWorld, postsOf, type World } from './support/retail-api';

// Selling from the menu at the quick counter: dish tiles, the options panel,
// one more of the same, changing a line's options, sold-out items and the
// time-of-day price. The fixture prices lines the way the server does; the
// client never sends a price.
// Presentation fixtures only: no real account privileges.

const MENU_ON = { 'fnb.menu': true };

async function open(page: Page, world: World) {
  await installRetailApi(page, world);
  await login(page);
  // The counter opens the first guest's ticket by itself.
  await expect(ticket(page)).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(1);
  await expect(page.getByRole('list', { name: 'Thực đơn' })).toBeVisible();
}

const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu quầy' });
const tile = (page: Page, name: string) =>
  page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name, exact: true });
const lines = (page: Page) => ticket(page).locator('.ticket-line');
const sheetId = (world: World) => [...world.sheets.keys()][0];

async function addTea(page: Page, topping: string) {
  await tile(page, 'Trà sữa').click();
  const panel = page.getByRole('region', { name: 'Trà sữa' });
  // Sugar is required and starts on its default, so the add button is ready.
  await expect(panel.getByRole('radio', { name: '100% đường' })).toBeChecked();
  await panel.getByRole('button', { name: `Tăng số lượng ${topping}` }).click();
  await panel.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(panel).toHaveCount(0);
}

test('two cups with different toppings are two lines, priced with their options', async ({ page }) => {
  const world = newWorld({ modules: MENU_ON, menu: teaMenu() });
  await open(page, world);
  await addTea(page, 'Trân châu');
  await addTea(page, 'Thạch');
  await expect(lines(page)).toHaveCount(2);
  await expect(lines(page).nth(0)).toContainText('Trân châu');
  await expect(lines(page).nth(0)).toContainText('35.000 ₫');
  await expect(lines(page).nth(1)).toContainText('Thạch');
  await expect(lines(page).nth(1)).toContainText('34.000 ₫');
  const bodies = postsOf(world, 'items').map((write) => write.body);
  expect(bodies.every((body) => !('price_override' in body) && !('price' in body))).toBe(true);
});

test('one more cup with the same options joins the same line', async ({ page }) => {
  const world = newWorld({ modules: MENU_ON, menu: teaMenu() });
  await open(page, world);
  await addTea(page, 'Trân châu');
  await expect(lines(page)).toHaveCount(1);
  await addTea(page, 'Trân châu');
  await expect(lines(page)).toHaveCount(1);
  await expect(lines(page).first().locator('.ticket-line-qty')).toHaveText('2');
  await expect(lines(page).first()).toContainText('70.000 ₫');
  const last = postsOf(world, 'items').at(-1)?.body;
  expect(last).toMatchObject({ merge: true, modifiers: [{ option_id: 'posmodopt_full', quantity: 1 }, { option_id: 'posmodopt_pearl', quantity: 1 }] });
});

test('changing the options of a line reprices it and joins a line with the same options', async ({ page }) => {
  const world = newWorld({ modules: MENU_ON, menu: teaMenu() });
  await open(page, world);
  await addTea(page, 'Trân châu');
  await addTea(page, 'Thạch');
  await expect(lines(page)).toHaveCount(2);
  await lines(page).nth(1).getByRole('button', { name: /Trà sữa/ }).click();
  await lines(page).nth(1).getByRole('button', { name: 'Ghi chú', exact: true }).click();
  const sheet = page.getByRole('dialog', { name: 'Trà sữa' });
  await sheet.getByRole('button', { name: 'Giảm số lượng Thạch' }).click();
  await sheet.getByRole('button', { name: 'Tăng số lượng Trân châu' }).click();
  await sheet.getByRole('button', { name: 'Lưu tùy chọn' }).click();
  await expect(sheet).toHaveCount(0);
  await expect(lines(page)).toHaveCount(1);
  await expect(lines(page).first()).toContainText('70.000 ₫');
  const patch = postsOf(world, 'item.modifiers').at(-1);
  expect(patch?.path).toMatch(new RegExp(`/items/sl_${sheetId(world)}_2/modifiers$`));
  expect(patch?.body).toMatchObject({ modifiers: [{ option_id: 'posmodopt_full', quantity: 1 }, { option_id: 'posmodopt_pearl', quantity: 1 }] });
  expect('price' in (patch?.body ?? {})).toBe(false);
});

test('a sold-out item cannot be added', async ({ page }) => {
  const menu = teaMenu();
  menu.soldOut.add('posmenuitem_flan');
  const world = newWorld({ modules: MENU_ON, menu });
  await open(page, world);
  const flan = page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan · Hết món' });
  await expect(flan).toBeDisabled();
  await expect(flan).toContainText('Hết món');
  expect(postsOf(world, 'items')).toHaveLength(0);
});

test('the time-of-day price shows on the tile and is the price of the line', async ({ page }) => {
  const world = newWorld({ modules: MENU_ON, menu: teaMenu() });
  await open(page, world);
  const peach = tile(page, 'Trà đào');
  await expect(peach).toContainText('25.000 ₫');
  await expect(peach).toContainText('Giá theo giờ');
  // Nothing to choose: one tap adds it, a second tap adds one more.
  await peach.click();
  await expect(lines(page)).toHaveCount(1);
  await expect(lines(page).first()).toContainText('25.000 ₫');
  await peach.click();
  await expect(lines(page)).toHaveCount(1);
  await expect(lines(page).first()).toContainText('50.000 ₫');
});
