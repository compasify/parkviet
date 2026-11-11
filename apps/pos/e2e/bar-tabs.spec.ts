import { expect, type Page, test } from '@playwright/test';
import { addLine, addSheet, FULL_CASHIER, installRetailApi, login, newWorld, openTab, postsOf, type World } from './support/retail-api';

// A bar's counter: it opens on the open tabs with the search ready, a tab is
// opened with only the guest's name, the VIP table's minimum spend fee and the
// drink credit show in the checkout, and a cash payment takes a tip on top.
// The tip ledger, sharing and the bar report are checked on the server.
// Presentation fixtures only: no real account privileges.

const BAR_MODULES = { resources: true, 'fnb.tables': true, 'fnb.postpay': true, 'fnb.bottle_keep': true };

function barWorld(): World {
  return newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: BAR_MODULES,
    profile: { key: 'bar_pub_club', version: 2, display: { surface: 'tab_list' } },
  });
}

const tabList = (page: Page) => page.getByRole('region', { name: 'Tab đang mở' });

test('the bar opens on its open tabs, finds one by name and opens a new one with only a name', async ({ page }) => {
  const world = barWorld();
  addSheet(world, 'ws_nam', { tabName: 'Anh Nam' });
  await installRetailApi(page, world);
  await login(page);

  const list = tabList(page);
  const search = list.getByRole('searchbox', { name: 'Tìm tab' });
  await expect(search).toBeFocused();
  await expect(list.getByRole('button', { name: 'Anh Nam' })).toBeVisible();

  await search.fill('lan');
  await expect(list.getByRole('status')).toHaveText('Không có tab nào khớp.');
  await list.getByRole('button', { name: 'Mở tab' }).click();

  await expect.poll(() => postsOf(world, 'workspace.create').length).toBe(1);
  expect(postsOf(world, 'workspace.create')[0].body).toMatchObject({ service_mode: 'tab', tab_name: 'lan' });
});

test('a tab shows the minimum spend fee and drink credit, and cash takes a tip on top', async ({ page }) => {
  const world = barWorld();
  const vip = addSheet(world, 'ws_vip', {
    tabName: 'Bàn VIP 1',
    minimumSpend: { minimum: '3000000', amount: '2950000', waived: false },
    drinkCredit: { total: '200000', used: '50000', remaining: '150000' },
  });
  addLine(world, vip, 'v_water', 10);
  await installRetailApi(page, world);
  await login(page);

  await tabList(page).getByRole('button', { name: 'Bàn VIP 1' }).click();
  await openTab(page, 'ws_vip');
  await expect(page.locator('[role="tab"][data-workspace-id="ws_vip"]')).toContainText('Bàn VIP 1');

  const checkout = page.getByRole('complementary', { name: 'Thông tin thanh toán' });
  await expect(checkout.locator('.minimum-spend-line')).toContainText('Phụ thu mức tối thiểu');
  await expect(checkout.locator('.minimum-spend-line')).toContainText('2.950.000');
  await expect(checkout.locator('.drink-credit-line')).toContainText('150.000');

  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tip').fill('20.000');
  await expect(dialog).toContainText('Thu cả tip: 70.000');
  await dialog.getByLabel('Khách đưa').fill('60.000');
  await expect(dialog).toContainText('Khách đưa chưa đủ');
  await dialog.getByLabel('Khách đưa').fill('100.000');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog).toHaveCount(0);

  const confirm = postsOf(world, 'tender.confirm').at(-1);
  expect(confirm?.body).toMatchObject({ handed_amount: '100000', tip_amount: '20000' });
});
