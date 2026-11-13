import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import {
  addLine,
  addSheet,
  FEATURES,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openTab,
} from './support/retail-api';

// Targeted checks in place of an automated audit library (none is installed):
// names for every control, keyboard-only use, focus kept inside dialogs, and
// layouts that survive 200% zoom and a 375px phone.

test.beforeEach(({}, testInfo) => {
  test.skip(testInfo.project.name !== 'desktop', 'Each check sets its own viewport');
});

async function sale(page: Page, flags = false) {
  const world = newWorld();
  if (flags) world.flags = { store: Object.fromEntries(FEATURES.map((feature) => [feature, true])), branch: {}, writes: [] };
  const sheet = addSheet(world, 'ws_1', { customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' } });
  addLine(world, sheet, 'v_rice', 2);
  addSheet(world, 'ws_2');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
  return world;
}

// Visible controls a screen reader would announce without a name.
async function unnamedControls(page: Page, scope = 'body') {
  return page.evaluate((selector) => {
    const root = document.querySelector(selector) ?? document.body;
    const visible = (element: Element) => {
      const box = (element as HTMLElement).getBoundingClientRect();
      const style = getComputedStyle(element);
      return box.width > 0 && box.height > 0 && style.visibility !== 'hidden';
    };
    const name = (element: Element) => {
      const labelled = element.getAttribute('aria-labelledby');
      if (labelled)
        return labelled.split(' ').map((id) => document.getElementById(id)?.textContent ?? '').join(' ').trim();
      if (element.getAttribute('aria-label')) return element.getAttribute('aria-label')?.trim();
      const id = element.getAttribute('id');
      const forLabel = id ? document.querySelector(`label[for="${CSS.escape(id)}"]`) : null;
      const wrapping = element.closest('label');
      return (
        forLabel?.textContent?.trim() ||
        wrapping?.textContent?.trim() ||
        (element instanceof HTMLButtonElement || element.tagName === 'A' || element.tagName === 'SUMMARY'
          ? element.textContent?.trim()
          : '') ||
        element.getAttribute('title')?.trim() ||
        (element as HTMLInputElement).placeholder?.trim() ||
        ''
      );
    };
    return [...root.querySelectorAll('button, a[href], input:not([type="hidden"]), select, textarea, summary, [role="tab"]')]
      .filter(visible)
      .filter((element) => !name(element))
      .map((element) => element.outerHTML.slice(0, 160));
  }, scope);
}

async function noHorizontalScroll(page: Page) {
  return page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1);
}

test('every control on the sale screen and the payment dialog has a name', async ({ page }) => {
  await sale(page, true);
  expect(await unnamedControls(page)).toEqual([]);
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
  expect(await unnamedControls(page, '[role="dialog"]')).toEqual([]);
  await page.keyboard.press('Escape');
});

test('every control on the table board, the order and the full-screen payment has a name', async ({ page }) => {
  await page.setViewportSize({ width: 1366, height: 768 });
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.kitchen': true },
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
    vietqr: true,
  });
  addLine(world, addSheet(world, 'ws_t1', { table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 } }), 'v_flan', 1);
  await installRetailApi(page, world);
  await page.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: {
        data: {
          branch_id: 'br_1',
          server_now: '2026-11-11T05:00:00Z',
          areas: [],
          resources: [
            { id: 'posres_1', name: 'Bàn 1', state: 'occupied', guest_count: 2, seated_minutes: 3, subtotal: '15000.0',
              currency: 'VND', orders: [{ id: 'ws_t1', total: '15000.0', guest_count: 2 }] },
            { id: 'posres_2', name: 'Bàn 2', state: 'available', orders: [] },
          ],
        },
      },
    }),
  );
  await login(page);
  const board = page.getByRole('region', { name: 'Bảng bàn' });
  await expect(board.locator('.board-tile', { hasText: 'Bàn 1' })).toBeVisible();
  expect(await unnamedControls(page)).toEqual([]);

  await board.locator('.board-tile', { hasText: 'Bàn 1' }).click();
  await expect(page.getByRole('list', { name: 'Thực đơn' })).toBeVisible();
  expect(await unnamedControls(page)).toEqual([]);
  await page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Trà sữa', exact: true }).click();
  await expect(page.getByRole('region', { name: 'Trà sữa' })).toBeVisible();
  expect(await unnamedControls(page)).toEqual([]);
  await page.getByRole('region', { name: 'Trà sữa' }).getByRole('button', { name: 'Thêm vào đơn' }).click();

  await page.getByRole('complementary', { name: 'Phiếu bàn' }).getByRole('button', { name: /^Thanh toán/ }).click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.locator('.pay-screen').getByRole('img', { name: 'Mã VietQR để quét bằng ứng dụng ngân hàng' })).toBeVisible();
  expect(await unnamedControls(page, '.pay-screen')).toEqual([]);
});

test('keyboard only: skip link to the search, payment dialog keeps focus inside and returns it', async ({ page }) => {
  await sale(page);
  // Start from the top of the document, as after loading the page.
  await page.locator('body').evaluate((body) => {
    body.setAttribute('tabindex', '-1');
    body.focus();
    body.removeAttribute('tabindex');
  });
  await page.keyboard.press('Tab');
  const skip = page.getByRole('link', { name: 'Đến khu vực tìm hàng' });
  await expect(skip).toBeFocused();
  await page.keyboard.press('Enter');
  await expect(page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' })).toBeFocused();

  const pay = page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true });
  await pay.focus();
  await page.keyboard.press('Enter');
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Khách đưa')).toBeFocused();
  for (let step = 0; step < 25; step += 1) {
    await page.keyboard.press(step % 5 === 4 ? 'Shift+Tab' : 'Tab');
    expect(await dialog.evaluate((element) => element.contains(document.activeElement))).toBe(true);
  }
  // Closing keeps the prepared tender and gives focus back to where it was.
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  await expect(page.locator('.payment-panel').getByRole('button', { name: 'Tiếp tục thanh toán' })).toBeFocused();
});

test('200% zoom (640px of layout): no sideways scroll and the payment controls stay reachable', async ({ page }) => {
  await page.setViewportSize({ width: 640, height: 400 });
  await sale(page);
  expect(await noHorizontalScroll(page)).toBe(true);
  for (const name of ['Tạo khách nhanh', 'Thanh toán', 'Ghi nợ']) {
    const control = page.getByRole('button', { name, exact: true }).first();
    await control.scrollIntoViewIfNeeded();
    await expect(control).toBeInViewport();
  }
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  const finish = dialog.getByRole('button', { name: 'Kết thúc', exact: true });
  await finish.scrollIntoViewIfNeeded();
  await expect(finish).toBeInViewport();
  expect(await noHorizontalScroll(page)).toBe(true);
});

test('375px phone: sale and payment fit the width', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 667 });
  await sale(page, true);
  expect(await noHorizontalScroll(page)).toBe(true);
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Khách đưa')).toBeVisible();
  const box = await dialog.boundingBox();
  expect(box && box.x >= 0 && box.x + box.width <= 376).toBe(true);
  await page.keyboard.press('Escape');
});
