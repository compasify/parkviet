import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, installRetailApi, login, newWorld, openTab, postsOf, type World } from './support/retail-api';

// The first food & drink businesses as the cashier sees them: the branch's
// profile and modules pick the selling surface (the menu at the quick
// counter), a cafe sale groups identical cups, and a retail branch of the
// same store keeps the catalogue. Kitchen
// screens, print jobs, ingredient stock and taxes are checked on the server.
// Presentation fixtures only: no real account privileges.

type Profile = NonNullable<World['profile']>;

const WAVE_ONE: Array<{ key: string; modules: Record<string, boolean> }> = [
  {
    key: 'cafe_tra_sua',
    modules: { 'retail.units': true, 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true, 'fnb.cup_label': true, 'fnb.recipes': true, 'fnb.delivery_platforms': true },
  },
  {
    key: 'quan_an',
    modules: { 'retail.units': true, 'retail.measured': true, 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true, 'fnb.recipes': true, 'fnb.delivery_platforms': true },
  },
  { key: 'cang_tin_tram_dung', modules: { 'retail.units': true, 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true } },
];

const profile = (key: string, display: Profile['display']): Profile => ({ key, version: 1, display });

async function open(page: Page, world: World) {
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
}

// The menu without tables sells at the quick counter: one ticket, no tabs.
async function openQuick(page: Page, world: World) {
  await installRetailApi(page, world);
  await login(page);
  await expect(ticket(page)).toBeVisible();
  await expect(page.getByRole('tablist')).toHaveCount(0);
}

const menuGrid = (page: Page) => page.getByRole('list', { name: 'Thực đơn' });
const search = (page: Page) => page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' });
const tile = (page: Page, name: string) => menuGrid(page).getByRole('button', { name, exact: true });
const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu quầy' });
const lines = (page: Page) => ticket(page).locator('.ticket-line');

async function addTea(page: Page, topping: string) {
  await tile(page, 'Trà sữa').click();
  const panel = page.getByRole('region', { name: 'Trà sữa' });
  await panel.getByRole('button', { name: `Tăng số lượng ${topping}` }).click();
  await panel.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(panel).toHaveCount(0);
}

for (const row of WAVE_ONE) {
  test(`${row.key} opens selling on the menu grid`, async ({ page }) => {
    const world = newWorld({ modules: row.modules, profile: profile(row.key, { surface: 'menu_grid' }), menu: teaMenu() });
    await openQuick(page, world);
    await expect(menuGrid(page)).toBeVisible();
    await expect(tile(page, 'Bánh flan')).toBeVisible();
    await expect(search(page)).toHaveCount(0);
  });
}

test('a cafe sale of three cups, two alike, is two lines priced by the server rules', async ({ page }) => {
  const world = newWorld({ modules: WAVE_ONE[0].modules, profile: profile('cafe_tra_sua', { surface: 'menu_grid' }), menu: teaMenu() });
  await openQuick(page, world);
  await addTea(page, 'Trân châu');
  await lines(page).first().getByRole('button', { name: /Trà sữa/ }).click();
  await lines(page).first().getByRole('button', { name: 'Thêm ly giống vậy' }).click();
  await expect(lines(page).first().locator('.ticket-line-qty')).toHaveText('2');
  await addTea(page, 'Thạch');
  await expect(lines(page)).toHaveCount(2);
  await expect(lines(page).nth(0)).toContainText('70.000 ₫');
  await expect(lines(page).nth(1)).toContainText('34.000 ₫');
  const bodies = postsOf(world, 'items').map((write) => write.body);
  expect(bodies.every((body) => !('price_override' in body) && !('price' in body))).toBe(true);
});

test('a profile that keeps the catalogue sells from search even with the menu on', async ({ page }) => {
  const world = newWorld({ modules: WAVE_ONE[2].modules, profile: profile('cang_tin_tram_dung', { surface: 'catalog' }), menu: teaMenu() });
  await open(page, world);
  await expect(search(page)).toBeVisible();
  await expect(menuGrid(page)).toHaveCount(0);
});

test('a retail branch of the same store keeps the catalogue and no menu', async ({ page }) => {
  const world = newWorld({
    modules: { 'retail.units': true, 'retail.measured': true, 'retail.traceability': true, 'fnb.menu': false, 'fnb.kitchen': false },
    profile: profile('tap_hoa_sieu_thi', { catalog_view: 'list' }),
    menu: teaMenu(),
  });
  const menuReads: string[] = [];
  page.on('request', (request) => {
    if (/\/api\/v3\/admin\/pos\/menu/.test(request.url())) menuReads.push(request.url());
  });
  await open(page, world);
  await expect(search(page)).toBeVisible();
  await expect(menuGrid(page)).toHaveCount(0);
  expect(menuReads).toEqual([]);
});