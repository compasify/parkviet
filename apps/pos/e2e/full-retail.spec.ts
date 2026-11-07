import { expect, test } from '@playwright/test';
import { liveApi, liveEnableFeatures, liveExpect, liveLogin, liveNewDraft, requireLive, restoreLiveFeatures } from './support/live';
import {
  addLine,
  addSheet,
  completeAndHandOver,
  effects,
  installRetailApi,
  login,
  newWorld,
  openMenuLink,
  openTab,
  payCash,
  scan,
  setNetwork,
  sheetTotal,
  tab,
} from './support/retail-api';

test('three orders at once: bank waits, cash completes, scans keep landing on their own order', async ({ page }) => {
  const world = newWorld();
  const a = addSheet(world, 'ws_a');
  addLine(world, a, 'v_rice', 2);
  const b = addSheet(world, 'ws_b');
  addLine(world, b, 'v_water', 3);
  addSheet(world, 'ws_c');
  await installRetailApi(page, world);
  await login(page);

  // A: the customer pays by transfer; the cashier leaves it waiting.
  await openTab(page, 'ws_a');
  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Để chờ, bán đơn khác' }).click();
  await expect(dialog).toHaveCount(0);
  expect(a.attempts.map((attempt) => [attempt.kind, attempt.status])).toEqual([['bank_manual', 'prepared']]);

  // B: cash with change, completed and handed over.
  await openTab(page, 'ws_b');
  await payCash(page, '20.000');
  await panel.getByRole('button', { name: 'Hoàn tất đơn' }).click();
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible();
  expect(b.status).toBe('completed');
  expect(world.drawer).toBe(15000);
  expect(b.changeDue).toBe(5000);

  // C: scanning lands on C only, and focus stays with the sale.
  await openTab(page, 'ws_c');
  await scan(page, '8930000000011', '8930000000028', '8930000000028');
  await expect.poll(() => world.sheets.get('ws_c')?.lines.map((line) => [line.variantId, line.quantity])).toEqual([
    ['v_rice', 1],
    ['v_water', 2],
  ]);
  await expect(tab(page, 'ws_c')).toHaveAttribute('aria-selected', 'true');
  expect(a.lines.map((line) => line.quantity)).toEqual([2]);
  expect(a.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);
  expect(effects(world, 'tender.confirm')).toBe(1);
  expect(sheetTotal(world, a)).toBe(200000);
});

test('a full day: credit sale, collection, return with cash refund, exchange, then a balanced close', async ({ page }) => {
  const world = newWorld();
  const pending = addSheet(world, 'ws_bank');
  addLine(world, pending, 'v_water', 2);
  const credit = addSheet(world, 'ws_credit', { customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' } });
  addLine(world, credit, 'v_rice', 5);
  const cash = addSheet(world, 'ws_cash');
  addLine(world, cash, 'v_rice', 3);
  await installRetailApi(page, world);
  await login(page);
  const panel = page.locator('.payment-panel');
  const dialog = page.getByRole('dialog');

  // A transfer is prepared and left waiting while other customers are served.
  await openTab(page, 'ws_bank');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByRole('button', { name: 'Để chờ, bán đơn khác' }).click();

  // Credit sale: 300k cash now, 200k on manager-approved credit.
  await openTab(page, 'ws_credit');
  await panel.getByLabel('Tiền mặt').fill('300.000');
  await payCash(page, '300.000');
  await panel.getByRole('button', { name: 'Ghi nợ', exact: true }).click();
  const creditDialog = page.getByRole('dialog', { name: 'Ghi nợ cho khách' });
  await expect(creditDialog).toContainText('200.000 ₫');
  await expect.poll(() => credit.creditRequested).toBe(true);
  credit.creditApproved = true;
  // The dialog rechecks the approval on its own.
  await expect(creditDialog).toContainText('Quản lý Hà', { timeout: 15_000 });
  await creditDialog.getByRole('button', { name: 'Hoàn tất & ghi nợ' }).click();
  await expect(creditDialog).toHaveCount(0);
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible();
  expect(credit.debt).toBe(200000);

  // Cash sale of three bags, completed and handed over.
  await openTab(page, 'ws_cash');
  await payCash(page, '300.000');
  await completeAndHandOver(page);
  expect(world.drawer).toBe(600000);

  // The customer brings 150k against the debt.
  await openMenuLink(page, 'Công nợ khách hàng');
  await page.getByRole('button', { name: /Chị Lan/ }).click();
  await page.getByRole('button', { name: 'Thu nợ' }).click();
  await dialog.getByLabel('Số tiền thu').fill('150.000');
  await dialog.getByLabel('Khách đưa').fill('150.000');
  await dialog.getByRole('button', { name: 'Ghi nhận thu nợ' }).click();
  await expect(dialog).toContainText('Đã ghi nhận thu 150.000 ₫.');
  await dialog.locator('.payment-popup-actions').getByRole('button', { name: 'Đóng' }).click();
  expect(world.debts.map((row) => [row.number, row.debt, row.collected])).toEqual([[credit.number, 200000, 150000]]);

  // One bag comes back: return, cash refund, then an exchange order.
  await openMenuLink(page, 'Đơn hàng');
  await page.getByRole('list', { name: 'Danh sách đơn hàng' }).getByRole('button', { name: new RegExp(cash.number) }).click();
  await page.getByRole('region', { name: 'Chi tiết đơn' }).getByRole('link', { name: 'Trả / đổi hàng' }).click();
  await page.getByLabel('Gạo ST25', { exact: true }).fill('1');
  await page.getByRole('button', { name: 'Xem trước' }).click();
  await expect(page.getByRole('region', { name: 'Xem trước giá trị trả' })).toContainText('100.000 ₫');
  await page.getByLabel('Lý do trả').fill('Khách đổi ý');
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  await expect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();
  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  await expect(refund.getByLabel('Số tiền hoàn')).toHaveValue('100.000');
  await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
  await refund.getByRole('button', { name: 'Xác nhận chi' }).click();
  const payout = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
  await payout.getByLabel(/đếm và đưa khách đủ 100.000 ₫/).check();
  await payout.getByRole('button', { name: 'Xác nhận đã chi' }).click();
  await expect(payout).toHaveCount(0);
  await expect(refund).toContainText('Đã chi');
  await page.getByRole('button', { name: 'Đổi hàng: mở đơn bán mới' }).click();
  await expect(page.getByText(/Đã mở đơn đổi R\d+\./)).toBeVisible();
  expect(world.restocks).toEqual([expect.objectContaining({ quantity: 1 })]);
  expect(world.drawer).toBe(650000);

  // The waiting transfer arrives; that order completes before the close.
  await page.getByRole('button', { name: 'Mở màn hình bán' }).click();
  await openTab(page, 'ws_bank');
  await panel.getByRole('button', { name: 'Tiếp tục thanh toán' }).click();
  await dialog.getByLabel('Mã tham chiếu giao dịch').fill('FT2611070001');
  await dialog.getByLabel('Tài khoản nhận').fill('VCB-0011');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  await completeAndHandOver(page);

  // Blind count of exactly the cash the day's effects put in the drawer.
  await openMenuLink(page, 'Ca & két');
  await page.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  const close = page.getByRole('dialog', { name: 'Đóng ca' });
  await close.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();
  await expect(close).not.toContainText('650.000');
  await close.getByLabel('Tổng tiền mặt đếm được').fill('650.000');
  await close.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
  await expect(close.locator('.variance')).toHaveAttribute('data-variance', 'even');
  await close.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  await expect(close).toContainText('Đã đóng ca');

  expect(world.shift.open).toBe(false);
  for (const family of ['tender.confirm', 'complete', 'handover', 'collection', 'return.prepare', 'return.receive', 'refund.request', 'refund.confirm', 'exchange', 'shift.close'] as const)
    expect(new Set(world.writes.filter((write) => write.family === family).map((write) => write.key)).size, family).toBe(effects(world, family));
  expect(effects(world, 'handover')).toBe(3);
  expect(world.stockMoves.map((move) => [move.workspaceId, move.quantity])).toEqual([
    ['ws_credit', 5],
    ['ws_cash', 3],
    ['ws_bank', 2],
  ]);
});

test('reload, network flapping, an expired session and logout lose no order and take no money twice', async ({ page, context }) => {
  test.setTimeout(120_000);
  const world = newWorld();
  const waiting = addSheet(world, 'ws_wait');
  addLine(world, waiting, 'v_rice', 1);
  const selling = addSheet(world, 'ws_sell');
  addLine(world, selling, 'v_water', 2);
  await installRetailApi(page, world);
  await login(page);
  const panel = page.locator('.payment-panel');
  const dialog = page.getByRole('dialog');

  await openTab(page, 'ws_wait');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByRole('button', { name: 'Để chờ, bán đơn khác' }).click();
  await openTab(page, 'ws_sell');

  // Reload: both orders and the waiting transfer come back from the server.
  await page.reload();
  await expect(tab(page, 'ws_wait')).toBeVisible();
  await expect(tab(page, 'ws_sell')).toBeVisible();
  expect(waiting.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);

  // The network drops while the cash is being recorded, then comes back.
  await openTab(page, 'ws_sell');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByLabel('Khách đưa').fill('10.000');
  await setNetwork(context, world, false);
  await expect(page.getByText('Mất kết nối. Thao tác ghi đang bị khóa trên màn hình này.')).toBeVisible();
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await page.waitForTimeout(1_000);
  expect(effects(world, 'tender.confirm')).toBe(0);
  await setNetwork(context, world, true);
  await setNetwork(context, world, false);
  await setNetwork(context, world, true);
  await expect(page.getByText('Mất kết nối. Thao tác ghi đang bị khóa trên màn hình này.')).toHaveCount(0);
  await expect(async () => {
    const finish = dialog.getByRole('button', { name: 'Kết thúc', exact: true });
    if (await finish.isVisible()) await finish.click({ timeout: 2_000 });
    await expect(dialog).toHaveCount(0, { timeout: 3_000 });
  }).toPass({ timeout: 30_000 });
  expect(effects(world, 'tender.confirm')).toBe(1);
  expect(world.drawer).toBe(10000);

  // The session expires: the next command sends the cashier to sign in, and
  // nothing on the server is lost or repeated.
  world.sessionExpired = true;
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  await expect(page.getByLabel('Email nhân viên')).toBeVisible({ timeout: 15_000 });
  await login(page);
  await expect(tab(page, 'ws_wait')).toBeVisible();
  expect(effects(world, 'workspace.create')).toBe(0);
  await expect(page.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toHaveCount(0);
  expect(selling.lines.map((line) => line.quantity)).toEqual([2]);
  expect(waiting.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);

  // Logout and back in: the orders were never stored only in the browser.
  page.on('dialog', (prompt) => void prompt.accept());
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('button', { name: 'Đăng xuất' }).click();
  await expect(page.getByLabel('Email nhân viên')).toBeVisible();
  await login(page);
  await expect(tab(page, 'ws_wait')).toBeVisible();
  await expect(tab(page, 'ws_sell')).toBeVisible();
  expect(effects(world, 'tender.confirm')).toBe(1);
  expect(effects(world, 'tender.prepare')).toBe(2);
});

test.describe('real API', () => {
  test.afterEach(async ({ request }) => restoreLiveFeatures(request));
  test('sale with change, partial return, cash refund and a balanced blind close', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'One live journey per run: it closes the fixture shift');
    test.setTimeout(180_000);
    const fixture = requireLive();
    await liveEnableFeatures(request, fixture, ['returns', 'refunds']);
    const rice = fixture.products.rice;
    await liveLogin(page, fixture);
    const cashier = await liveApi(request, fixture, 'cashier');
    const draft = await liveNewDraft(page);

    await scan(page, rice.barcode, rice.barcode);
    const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
    await liveExpect(basket.locator('td.basket-index')).toHaveCount(1, { timeout: 15_000 });
    await liveExpect(page.getByRole('spinbutton', { name: `Số lượng ${rice.name}` })).toHaveValue('2');
    await payCash(page, '250.000', 30_000);
    await completeAndHandOver(page, 30_000);

    type Detail = { data: { order_id: string; financial: { allocated: string; change_due: string } } };
    const workspace = (await cashier.get<Detail>(`/pos/workspaces/${draft.id}`)).data;
    liveExpect(Number(workspace.financial.allocated)).toBe(2 * rice.price);
    liveExpect(Number(workspace.financial.change_due)).toBe(250000 - 2 * rice.price);

    type Orders = { data: Array<{ number: string; workspace_id: string; paid: string }> };
    const orders = (await cashier.get<Orders>('/pos/orders', { branch_id: fixture.branch_id })).data;
    const sold = orders.find((row) => row.workspace_id === draft.id);
    liveExpect(sold, 'the sale is in the branch order history').toBeTruthy();
    liveExpect(Number(sold?.paid)).toBe(2 * rice.price);
    await openMenuLink(page, 'Đơn hàng');
    await page
      .getByRole('list', { name: 'Danh sách đơn hàng' })
      .getByRole('button', { name: new RegExp(sold?.number ?? 'missing') })
      .click();
    await page.getByRole('region', { name: 'Chi tiết đơn' }).getByRole('link', { name: 'Trả / đổi hàng' }).click();
    await page.getByLabel(rice.name, { exact: true }).fill('1');
    await page.getByRole('button', { name: 'Xem trước' }).click();
    await page.getByLabel('Lý do trả').fill('Kiểm thử e2e thật');
    await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
    await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
    await liveExpect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible({ timeout: 15_000 });
    const refund = page.getByRole('region', { name: 'Hoàn tiền' });
    await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
    await liveExpect(refund.getByRole('button', { name: 'Xác nhận chi' })).toBeVisible({ timeout: 15_000 });
    // A second person approves when the branch policy asks for one.
    const returnId = new URL(page.url()).searchParams.get('returnId') ?? '';
    type ReturnBody = { data: { refund_requests: Array<{ id: string; approval: { status: string } | null }> } };
    const current = (await cashier.get<ReturnBody>(`/pos/returns/${returnId}`)).data;
    const pending = current.refund_requests.find((row) => row.approval?.status !== 'active');
    if (pending) {
      const manager = await liveApi(request, fixture, 'manager');
      const approved = await manager.send('POST', `/pos/refund_requests/${pending.id}/approve`, {});
      liveExpect(approved.status, JSON.stringify(approved.body)).toBeLessThan(300);
      await page.reload();
    }
    await refund.getByRole('button', { name: 'Xác nhận chi' }).click();
    const payout = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
    await payout.getByRole('checkbox').check();
    await payout.getByRole('button', { name: 'Xác nhận đã chi' }).click();
    await liveExpect(refund).toContainText('Đã chi', { timeout: 15_000 });

    // Blind count. A fresh fixture holds one bag's price; a fixture reused by
    // earlier live runs holds more, so the count is redone with the expected
    // cash the server reveals after the first count (every count is audited).
    await openMenuLink(page, 'Ca & két');
    await page.getByRole('button', { name: 'Đóng ca', exact: true }).click();
    const close = page.getByRole('dialog', { name: 'Đóng ca' });
    await close.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();
    await close.getByLabel('Tổng tiền mặt đếm được').fill(String(rice.price));
    await close.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
    type Context = { shift: { id: string } | null };
    const shift = (await cashier.get<Context>('/pos/context', { branch_id: fixture.branch_id, register_id: fixture.register_id })).shift;
    type Closure = { data: { count: { expected: string | null } } };
    await liveExpect
      .poll(async () => (await cashier.get<Closure>(`/pos/shifts/${shift?.id}/closure`)).data.count.expected)
      .not.toBeNull();
    const expected = Number.parseInt((await cashier.get<Closure>(`/pos/shifts/${shift?.id}/closure`)).data.count.expected ?? '0', 10);
    if (expected !== rice.price) {
      await close.getByRole('button', { name: 'Đếm lại' }).click();
      await close.getByLabel('Tổng tiền mặt đếm được').fill(String(expected));
      await close.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
    }
    await liveExpect(close.locator('.variance')).toHaveAttribute('data-variance', 'even', { timeout: 15_000 });
    await close.getByRole('button', { name: 'Đóng ca', exact: true }).click();
    await liveExpect(close).toContainText('Đã đóng ca', { timeout: 15_000 });
  });
});
