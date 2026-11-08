import { expect, test } from '@playwright/test';
import { openUserMenu } from './support/menu';
import { addLine, addSheet, installRetailApi, login, newWorld, openTab } from './support/retail-api';

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
  const orders = menu.getByRole('link', { name: 'Đơn hàng', exact: true });
  await expect(orders).toHaveAttribute('target', '_blank');

  const popup = context.waitForEvent('page');
  await orders.click();
  const second = await popup;
  await expect(second.getByRole('heading', { name: 'Đơn hàng', level: 1 })).toBeVisible();
  // Off the sale screen the menu navigates in place.
  await expect(
    (await openUserMenu(second)).getByRole('link', { name: 'Báo cáo', exact: true }),
  ).not.toHaveAttribute('target', '_blank');

  // The sale tab never left the invoice.
  await expect(page.locator('.user-menu')).not.toHaveAttribute('open');
  expect(page.url()).toBe(saleUrl);
  await expect(page.locator('[role="tab"][data-workspace-id="ws_1"]')).toHaveAttribute('aria-selected', 'true');
});
