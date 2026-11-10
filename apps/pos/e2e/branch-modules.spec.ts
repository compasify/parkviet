import { expect, type Page, test } from '@playwright/test';
import { goToMenuPage, openUserMenu } from './support/menu';
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
const TRACE_NOTE = 'Chi nhánh chưa bật chức năng Serial, lô, hạn dùng';

async function addSerials(page: Page, search: string, serials: string[]) {
  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill(search);
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  await page.locator('details.catalog-advanced summary').first().click();
  const form = page.locator('.add-item-form');
  await form.getByRole('textbox', { name: /^Serial/ }).fill(`${serials.join('\n')}\n`);
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
}

test('traceability off hides the stock page and tracking setup, and a tracked SKU still sells by serial', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': false } });
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);

  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Ca & két', exact: true })).toBeVisible();
  await expect(menu.getByRole('link', { name: 'Truy xuất tồn kho', exact: true })).toHaveCount(0);
  await page.keyboard.press('Escape');

  // The sale screen is untouched: the serial field is there and the sale completes.
  await openTab(page, 'ws_1');
  await addSerials(page, 'DT-1', ['SN-1']);
  await expect(page.locator('.basket-lines')).toContainText('Serial: SN-1 · đang giữ');
  await payCash(page, '2.500.000');
  await completeAndHandOver(page);
  expect(world.serialStock.has('SN-1')).toBe(false);

  // The page itself still opens by URL and says why setup is missing.
  await page.goto('/inventory');
  await expect(page.getByRole('heading', { name: 'Truy xuất tồn kho', level: 1 })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: TRACE_NOTE })).toBeVisible();
  await expect(page.getByRole('table', { name: 'Mặt hàng theo dõi' })).toContainText('Điện thoại A');
  await expect(page.getByRole('button', { name: /^Khai báo tồn đầu kỳ/ })).toHaveCount(0);
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toHaveCount(0);
});

test('traceability off keeps receiving reachable while the store still tracks SKUs, without opening balances', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': true } });
  await installRetailApi(page, world);
  await login(page);
  await goToMenuPage(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('heading', { name: 'Truy xuất tồn kho', level: 1 })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: TRACE_NOTE })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Chuyển kho', exact: true })).toBeVisible();
  await expect(page.getByRole('table', { name: 'Mặt hàng theo dõi' })).toContainText('Điện thoại A');
  await expect(page.getByRole('button', { name: /^Khai báo tồn đầu kỳ/ })).toHaveCount(0);
});

test('a server without modules hides nothing: stock page, receiving and opening balances stay', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER });
  await installRetailApi(page, world);
  await login(page);
  await goToMenuPage(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Khai báo tồn đầu kỳ Điện thoại A', exact: true })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: 'Chi nhánh chưa bật chức năng' })).toHaveCount(0);
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
