import { expect, type Page, test } from '@playwright/test';
import { openUserMenu } from './support/menu';
import {
  addSheet,
  completeAndHandOver,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openTab,
  payCash,
} from './support/retail-api';

// Branch modules on the selling side: a module that is off hides its setup
// entry points only. Selling, receipts and returns never change. Branch
// settings per module are covered by the POS dashboard's own suite.
// Presentation fixtures only: no real account privileges.

const TRACE_OFF = { 'retail.units': true, 'retail.measured': true, 'retail.traceability': false };
const KEEPER = [...FULL_CASHIER, 'pos.inventory.manage'];

async function addSerials(page: Page, search: string, serials: string[]) {
  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill(search);
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  await page.locator('details.catalog-advanced summary').first().click();
  const form = page.locator('.add-item-form');
  await form.getByRole('textbox', { name: /^Serial/ }).fill(`${serials.join('\n')}\n`);
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
}

test('traceability off hides the stock link, and a tracked SKU still sells by serial', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': false } });
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);

  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Ca của tôi', exact: true })).toBeVisible();
  await expect(menu.getByRole('link', { name: 'Truy xuất tồn kho', exact: true })).toHaveCount(0);
  await page.keyboard.press('Escape');

  // The sale screen is untouched: the serial field is there and the sale completes.
  await openTab(page, 'ws_1');
  await addSerials(page, 'DT-1', ['SN-1']);
  await expect(page.locator('.basket-lines')).toContainText('Serial: SN-1 · đang giữ');
  await payCash(page, '2.500.000');
  await completeAndHandOver(page);
  expect(world.serialStock.has('SN-1')).toBe(false);
});

// The stock page lives in the POS dashboard; the menu links there.
const INVENTORY_LINK = /^https?:\/\/[^/]+(\/[^?#]*)?\/store_1\/inventory\?branch=br_1$/;

test('traceability off keeps the stock link while the store still tracks SKUs', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': true } });
  await installRetailApi(page, world);
  await login(page);
  const menu = await openUserMenu(page);
  const link = menu.getByRole('link', { name: 'Truy xuất tồn kho', exact: true });
  await expect(link).toHaveAttribute('href', INVENTORY_LINK);
  await expect(link).toHaveAttribute('target', '_blank');
});

test('a server without modules hides nothing: the stock link stays', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER });
  await installRetailApi(page, world);
  await login(page);
  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Truy xuất tồn kho', exact: true })).toHaveAttribute(
    'href',
    INVENTORY_LINK,
  );
});

for (const [profile, view, other] of [
  ['nha_thuoc', 'list', 'cards'],
  ['thoi_trang', 'cards', 'list'],
] as const) {
  test(`a ${profile} branch opens the catalogue as ${view}, and the cashier's choice stays`, async ({ page }) => {
    const world = newWorld({
      modules: { 'retail.units': true, 'retail.traceability': true },
      profile: { key: profile, version: 1, display: { catalog_view: view } },
    });
    addSheet(world, 'ws_1');
    await installRetailApi(page, world);
    await login(page);
    await openTab(page, 'ws_1');
    await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill('Gạo');
    await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
    const results = page.getByRole('list', { name: 'Kết quả tìm hàng' });
    await expect(results).toHaveClass(new RegExp(`catalog-results--${view}`));
    await expect(page.getByRole('button', { name: view === 'list' ? 'Danh sách' : 'Thẻ', exact: true })).toHaveAttribute(
      'aria-pressed',
      'true',
    );
    await page.getByRole('button', { name: other === 'list' ? 'Danh sách' : 'Thẻ', exact: true }).click();
    await expect(results).toHaveClass(new RegExp(`catalog-results--${other}`));
  });
}
