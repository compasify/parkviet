import { expect, test } from '@playwright/test';
import { goToMenuPage, openUserMenu } from './support/menu';
import {
  addLine,
  addSheet,
  FEATURES,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openMenuLink,
  openTab,
} from './support/retail-api';

const allOff = () => ({ store: {}, branch: {}, writes: [] as Array<Record<string, unknown>> });
const allOn = () => ({ ...allOff(), store: Object.fromEntries(FEATURES.map((feature) => [feature, true])) });

test('switched-off features disable their entry points with a reason; recovery pages stay open', async ({ page }) => {
  const world = newWorld();
  world.flags = allOff();
  const sheet = addSheet(world, 'ws_1', { customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' } });
  addLine(world, sheet, 'v_rice', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');

  const credit = page.locator('.payment-panel').getByRole('button', { name: 'Ghi nợ', exact: true });
  await expect(credit).toBeDisabled();
  await expect(credit).toHaveAccessibleDescription(/Bán ghi nợ chưa được bật cho chi nhánh này/);
  const display = page.getByRole('region', { name: 'Màn hình khách' });
  await expect(display).toContainText('Màn hình khách chưa được bật cho chi nhánh này');
  await expect(display.getByRole('button', { name: 'Kết nối màn hình khách' })).toHaveCount(0);
  // Plain cash sales are not behind a flag.
  await expect(page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true })).toBeEnabled();

  await openMenuLink(page, 'Trả / đổi hàng');
  await expect(page.getByText('Chức năng này chưa được bật cho chi nhánh này')).toBeVisible();
  await expect(page.getByText('Trả hàng chưa được bật cho chi nhánh này', { exact: false })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Tìm đơn' })).toHaveCount(0);

  await openMenuLink(page, 'Ca của tôi');
  const move = page.getByRole('button', { name: 'Thu/chi tiền mặt' });
  await expect(move).toBeDisabled();
  await expect(move).toHaveAccessibleDescription(/Thu\/chi tiền mặt trong két chưa được bật/);
  await expect(page.getByRole('button', { name: 'Đóng ca', exact: true })).toBeEnabled();

  // Work that is already started stays reachable whatever the switches say.
  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Khoản thu cần chú ý', exact: true })).toHaveAttribute(
    'href',
    /\/store_1\/funds\/attention\?branch=br_1$/,
  );
  await goToMenuPage(page, 'Hóa đơn');
  await expect(page.locator('.header-title')).toHaveText('Hóa đơn');
});

test('a feature switched off while the page is open is refused in Vietnamese and its entry point closes', async ({ page }) => {
  const world = newWorld();
  world.flags = allOn();
  const sheet = addSheet(world, 'ws_1', { customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' } });
  addLine(world, sheet, 'v_rice', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
  const credit = page.locator('.payment-panel').getByRole('button', { name: 'Ghi nợ', exact: true });
  await expect(credit).toBeEnabled();

  // A manager switches credit off at the branch in another session.
  world.flags.branch.credit = false;
  await credit.click();
  // The refusal reloads the context: the dialog closes and the entry explains why.
  await expect(credit).toBeDisabled();
  await expect(credit).toHaveAccessibleDescription(/Bán ghi nợ chưa được bật cho chi nhánh này/);
  await expect(page.getByRole('dialog', { name: 'Ghi nợ cho khách' })).toHaveCount(0);
  expect(world.writes.filter((write) => write.family === 'credit.request')).toHaveLength(1);
  expect(sheet.creditRequested).toBe(false);
});

test('money is not taken on an order whose shift is not open; cash refunds and collections hint and leave the refusal to the server', async ({ page }) => {
  const world = newWorld();
  const old = addSheet(world, 'ws_old', { shiftId: 'sh_closed' });
  addLine(world, old, 'v_rice', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_old');
  const panel = page.locator('.payment-panel');
  await expect(panel.getByText('Ca của đơn này không còn mở hoặc không phải ca của bạn', { exact: false })).toBeVisible();
  const pay = panel.getByRole('button', { name: 'Thanh toán', exact: true });
  await expect(pay).toBeDisabled();
  await expect(pay).toHaveAccessibleDescription(/Ca của đơn này không còn mở/);
  expect(world.writes.filter((write) => write.family === 'tender.prepare')).toEqual([]);

  // A sold order with a reserved cash refund, after the cashier's shift closed.
  const sold = addSheet(world, 'ws_sold', { status: 'completed', orderId: 'or_ws_sold', allocated: 100000, handedOver: true });
  addLine(world, sold, 'v_rice', 1);
  world.orders.set('or_ws_sold', { id: 'or_ws_sold', number: sold.number, workspaceId: sold.id, placedAt: '2026-11-07T03:00:00Z' });
  world.funds.push({ id: 'posfunds_1', allocationId: 'posalloc_1', workspaceId: sold.id, kind: 'cash', amount: 100000, refunded: 0, reserved: 100000, reference: null });
  world.returns.push({ id: 'posreturn_1', number: 'RET1', orderId: 'or_ws_sold', status: 'received', creditNote: 0, refund: 100000, exchangeId: null,
    lines: [{ saleLineId: sold.lines[0].saleLineId, name: 'Gạo ST25', quantity: 1, condition: 'resellable', value: 100000 }] });
  world.refunds.push({ id: 'posrefund_1', returnId: 'posreturn_1', allocationId: 'posalloc_1', method: 'cash', status: 'reserved', amount: 100000 });
  world.shift.open = false;
  await page.goto('/returns?returnId=posreturn_1');
  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  const payout = refund.getByRole('button', { name: 'Xác nhận chi' });
  // The cashier may own an open shift at another register: the page hints,
  // the server decides and its refusal is explained.
  await expect(payout).toBeEnabled();
  await expect(payout).toHaveAccessibleDescription(/Quầy đang chọn không có ca mở của bạn/);
  await payout.click();
  const dialog = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
  await dialog.getByRole('checkbox').check();
  await dialog.getByRole('button', { name: 'Xác nhận đã chi' }).click();
  await expect(dialog.getByRole('alert')).toHaveText('Chi tiền mặt cần ca đang mở của chính bạn tại chi nhánh này.');
  expect(world.refunds[0].status).toBe('reserved');
  await page.keyboard.press('Escape');
  await expect(refund).toContainText('Chờ chi');

  // Debt collections are booked on the collector's own open shift too.
  world.debts.push({ orderId: 'or_ws_sold', number: sold.number, workspaceId: sold.id, debt: 50000, collected: 0 });
  await openMenuLink(page, 'Thu nợ');
  await page.getByRole('button', { name: /Chị Lan/ }).click();
  const collect = page.getByRole('button', { name: 'Thu nợ' });
  await expect(collect).toBeEnabled();
  await expect(collect).toHaveAccessibleDescription(/Quầy đang chọn không có ca mở của bạn/);
  await collect.click();
  const collection = page.getByRole('dialog');
  await collection.getByLabel('Số tiền thu').fill('50.000');
  await collection.getByLabel('Khách đưa').fill('50.000');
  await collection.getByRole('button', { name: 'Ghi nhận thu nợ' }).click();
  await expect(collection.getByRole('alert')).toHaveText('Mở ca của bạn tại chi nhánh trước khi thu tiền.');
  expect(world.collections).toEqual([]);
});
