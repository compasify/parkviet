import { expect, test } from '@playwright/test';
import { goToMenuPage } from './support/menu';
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

  await openMenuLink(page, 'Ca & két');
  const move = page.getByRole('button', { name: 'Thu/chi tiền mặt' });
  await expect(move).toBeDisabled();
  await expect(move).toHaveAccessibleDescription(/Thu\/chi tiền mặt trong két chưa được bật/);
  await expect(page.getByRole('button', { name: 'Đóng ca', exact: true })).toBeEnabled();

  // Work that is already started stays reachable whatever the switches say.
  await goToMenuPage(page, 'Khoản thu cần chú ý');
  await expect(page.locator('.header-title')).toHaveText('Cần chú ý');
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

test('a store administrator switches the store default; a branch switch only turns a feature off', async ({ page }) => {
  const world = newWorld();
  world.flags = allOff();
  world.administration = { read: true, write: true };
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await page.goto('/settings/branches/br_1/features');
  const row = page.getByRole('list', { name: 'Danh sách chức năng' }).locator('[data-feature="credit"]');
  await expect(row).toContainText('Tắt (cửa hàng chưa bật)');

  await row.getByRole('button', { name: 'Bật Bán ghi nợ cho cả cửa hàng' }).click();
  const save = row.getByRole('button', { name: 'Lưu thay đổi' });
  await expect(save).toBeDisabled();
  await expect(row.getByLabel('Lý do (bắt buộc)')).toBeFocused();
  await row.getByLabel('Lý do (bắt buộc)').fill('Đã duyệt mở bán ghi nợ');
  await save.click();
  await expect(page.getByText('Đã bật Bán ghi nợ cho cửa hàng.')).toBeVisible();
  await expect(row.locator('.status-tag')).toHaveText('Đang bật');

  await row.getByRole('button', { name: 'Tắt tại chi nhánh này' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Tạm dừng do kiểm kê');
  await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(row.locator('.status-tag')).toHaveText('Tắt tại chi nhánh');
  await expect(row).toContainText('Chi nhánh: đã tắt riêng');
  await row.getByRole('button', { name: 'Bỏ tắt tại chi nhánh' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Kiểm kê xong');
  await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(row.locator('.status-tag')).toHaveText('Đang bật');

  expect(world.flags.writes).toEqual([
    { feature: 'credit', enabled: true, reason: 'Đã duyệt mở bán ghi nợ' },
    { feature: 'credit', branch_id: 'br_1', enabled: false, reason: 'Tạm dừng do kiểm kê' },
    { feature: 'credit', branch_id: 'br_1', enabled: null, reason: 'Kiểm kê xong' },
  ]);
});

test('a branch manager without store rights can only switch features off at the selected branch, not back on', async ({ page }) => {
  const world = newWorld({ capabilities: [...FULL_CASHIER, 'pos.topology.manage'] });
  world.flags = allOn();
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await openMenuLink(page, 'Chức năng chi nhánh');
  await expect(page.getByText('Bạn có thể tắt chức năng tại chi nhánh này', { exact: false })).toBeVisible();
  const row = page.getByRole('list', { name: 'Danh sách chức năng' }).getByRole('listitem').filter({ hasText: 'Xuất CSV báo cáo' });
  await expect(row.getByRole('button', { name: /cho cả cửa hàng/ })).toHaveCount(0);
  await row.getByRole('button', { name: 'Tắt tại chi nhánh này' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Chưa duyệt xuất dữ liệu');
  await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(row.locator('.status-tag')).toHaveText('Tắt tại chi nhánh');
  // Turning it back on is a store decision: no button for the branch manager.
  await expect(row.getByRole('button')).toHaveCount(0);
  expect(world.flags.writes.map((write) => [write.branch_id, write.enabled])).toEqual([['br_1', false]]);
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
  await openMenuLink(page, 'Công nợ khách hàng');
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
