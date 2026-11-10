import { expect, test } from '@playwright/test';
import { openUserMenu } from './support/menu';
import { addLine, addSheet, FULL_CASHIER, installRetailApi, login, newWorld, openTab } from './support/retail-api';

test('the header menu opens pages in a new tab from the sale screen, so the invoice keeps its place', async ({
  page,
  context,
}) => {
  const world = newWorld();
  const sheet = addSheet(world, 'ws_1');
  addLine(world, sheet, 'v_rice', 1);
  await installRetailApi(context, world);
  await login(page);
  await openTab(page, 'ws_1');
  const saleUrl = page.url();

  const menu = await openUserMenu(page);
  await expect(menu.getByRole('button', { name: 'Đăng xuất' })).toBeVisible();
  const shift = menu.getByRole('link', { name: 'Ca của tôi', exact: true });
  await expect(shift).toHaveAttribute('target', '_blank');

  const popup = context.waitForEvent('page');
  await shift.click();
  const second = await popup;
  await expect(second.getByRole('heading', { name: 'Ca của tôi', level: 1 })).toBeVisible();
  // Off the sale screen the menu navigates in place.
  await expect(
    (await openUserMenu(second)).getByRole('link', { name: 'Hóa đơn', exact: true }),
  ).not.toHaveAttribute('target', '_blank');

  // The sale tab never left the invoice.
  await expect(page.locator('.user-menu')).not.toHaveAttribute('open');
  expect(page.url()).toBe(saleUrl);
  await expect(page.locator('[role="tab"][data-workspace-id="ws_1"]')).toHaveAttribute('aria-selected', 'true');
});

// Administration lives in the POS dashboard app, which signs in on its own:
// the menu links there in a new tab and never carries the sale session.
test('administration entry points open the POS dashboard for the current store and branch', async ({ page }) => {
  const admin = newWorld();
  admin.administration = { read: true, write: true };
  addSheet(admin, 'ws_1');
  await installRetailApi(page, admin);
  await login(page);
  const menu = await openUserMenu(page);
  const settings = menu.getByRole('link', { name: 'Cấu hình', exact: true });
  await expect(settings).toHaveAttribute('href', /^https?:\/\/[^/]+(\/[^?#]*)?\/store_1(\?branch=br_1)?$/);
  await expect(settings).toHaveAttribute('target', '_blank');
  await expect(settings).not.toHaveAttribute('href', /token|session/i);
  await expect(menu.getByRole('link', { name: 'Chức năng chi nhánh', exact: true })).toHaveCount(0);

  // Pages off the sale screen offer the same link in their navigation.
  await page.goto('/shifts');
  const nav = page.getByRole('navigation', { name: 'Điều hướng POS' });
  await expect(nav.getByRole('link', { name: 'Cấu hình', exact: true })).toHaveAttribute('target', '_blank');
});

test('a branch manager reaches the feature switches of the selected branch', async ({ page }) => {
  const manager = newWorld({ capabilities: [...FULL_CASHIER, 'pos.topology.manage'] });
  addSheet(manager, 'ws_1');
  await installRetailApi(page, manager);
  await login(page);
  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Chức năng chi nhánh', exact: true })).toHaveAttribute(
    'href',
    /^https?:\/\/[^/]+(\/[^?#]*)?\/store_1\/features\?branch=br_1$/,
  );
  await expect(menu.getByRole('link', { name: 'Cấu hình', exact: true })).toHaveCount(0);
});

test('a cashier sees no administration link', async ({ page }) => {
  const cashier = newWorld();
  addSheet(cashier, 'ws_1');
  await installRetailApi(page, cashier);
  await login(page);
  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Ca của tôi', exact: true })).toBeVisible();
  await expect(menu.getByRole('link', { name: /Cấu hình|Chức năng chi nhánh/ })).toHaveCount(0);
});

// Back office lives in the POS dashboard: the counter keeps only selling,
// returns, receipts, its own shift and debt collection.
test('back-office pages open in the POS dashboard from the "Quản trị" group', async ({ page }) => {
  const cashier = newWorld();
  addSheet(cashier, 'ws_1');
  await installRetailApi(page, cashier);
  await login(page);
  const menu = await openUserMenu(page);
  const group = menu.locator('.user-menu-group').filter({ hasText: 'Quản trị' });
  for (const [name, path] of [
    ['Đơn hàng', 'orders'],
    ['Sổ tiền đã nhận / nghĩa vụ', 'funds'],
    ['Khoản thu cần chú ý', 'funds/attention'],
    ['Công nợ khách hàng', 'receivables'],
    ['Báo cáo', 'reports'],
  ] as const) {
    const link = group.getByRole('link', { name, exact: true });
    await expect(link).toHaveAttribute(
      'href',
      new RegExp(`^https?://[^/]+(/[^?#]*)?/store_1/${path}\\?branch=br_1$`),
    );
    await expect(link).toHaveAttribute('target', '_blank');
  }
  for (const name of ['Trả / đổi hàng', 'Hóa đơn', 'Ca của tôi', 'Thu nợ'])
    await expect(menu.getByRole('link', { name, exact: true })).not.toHaveAttribute('href', /store_1/);
});
