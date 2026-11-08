import { expect, test } from '@playwright/test';
import {
  addLine,
  addSheet,
  displaySession,
  effects,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openMenuLink,
  openTab,
  type World,
} from './support/retail-api';

// With every risky feature switched off, work that was already started must
// still finish: each recovery path below runs once and has its effect.

const MANAGER_AT_COUNTER = [
  ...FULL_CASHIER,
  'pos.approval.grant',
  'pos.credit.manage',
  'pos.report.export',
];

// A sold, handed-over order with a cash receipt of 300.000 ₫.
function soldOrder(world: World) {
  const sold = addSheet(world, 'ws_sold', {
    status: 'completed',
    orderId: 'or_ws_sold',
    allocated: 300000,
    handedOver: true,
  });
  addLine(world, sold, 'v_rice', 3);
  world.orders.set('or_ws_sold', { id: 'or_ws_sold', number: sold.number, workspaceId: sold.id, placedAt: '2026-11-07T03:00:00Z' });
  world.funds.push({ id: 'posfunds_1', allocationId: 'posalloc_1', workspaceId: sold.id, kind: 'cash', amount: 300000, refunded: 0, reserved: 0, reference: null });
  return sold;
}

function prepared(world: World, id: string, saleLineId: string, status: 'ready' | 'received', refund: number) {
  world.returns.push({
    id, number: `RET-${id}`, orderId: 'or_ws_sold', status, creditNote: 0, refund, exchangeId: null,
    lines: [{ saleLineId, name: 'Gạo ST25', quantity: 1, condition: 'resellable', value: 100000 }],
  });
}

test('every recovery path finishes with every feature switched off', async ({ page }) => {
  test.setTimeout(120_000);
  const world = newWorld({ capabilities: MANAGER_AT_COUNTER });
  world.flags = { store: {}, branch: {}, writes: [] };
  const sold = soldOrder(world);
  const saleLine = sold.lines[0].saleLineId;
  prepared(world, 'posreturn_a', saleLine, 'ready', 100000);
  prepared(world, 'posreturn_b', saleLine, 'ready', 100000);
  prepared(world, 'posreturn_c', saleLine, 'received', 100000);
  world.funds[0].reserved = 60000;
  world.refunds.push(
    { id: 'posrefund_pay', returnId: 'posreturn_c', allocationId: 'posalloc_1', method: 'cash', status: 'reserved', amount: 10000 },
    { id: 'posrefund_cancel', returnId: 'posreturn_c', allocationId: 'posalloc_1', method: 'cash', status: 'reserved', amount: 20000, approved: false },
    { id: 'posrefund_unknown', returnId: 'posreturn_c', allocationId: 'posalloc_1', method: 'bank_manual', status: 'unknown', amount: 30000 },
  );
  const shown = addSheet(world, 'ws_shown');
  addLine(world, shown, 'v_water', 1);
  world.display = displaySession({ generation: 3, pinned_workspace_id: 'ws_shown', pinned_order_number: shown.number });
  world.exports.push({
    id: 'posexport_old', branch_id: 'br_1', report_type: 'sales', filters: { from: '2026-11-06', to: '2026-11-06' },
    status: 'ready', row_count: 1, error_message: null, expires_at: '2099-01-01T00:00:00Z',
    completed_at: '2026-11-06T10:00:01Z', created_at: '2026-11-06T10:00:00Z',
  });
  world.cashRequests.push({
    id: 'poscashreq_7', branch_id: 'br_1', shift_id: 'sh_7', kind: 'safe_drop', status: 'requested', amount: '200000.0',
    currency: 'VND', reason: 'Nộp két giữa ca', evidence_reference: 'TUI-9', requester_id: 'stf_3', requester_name: 'Mai',
    confirmer_id: null, confirmer_name: null, cash_movement_id: null, resolution_note: null,
    created_at: '2026-11-07T03:00:00Z', resolved_at: null,
  });
  world.creditRequests.push({
    id: 'poscreditreq_1', branch_id: 'br_1', workspace_id: 'ws_9', order_number: 'R900',
    customer: { id: 'poscustomer_1', name: 'Chị Lan' }, requester: { id: 'stf_3', name: 'Thu ngân Mai' },
    amount: '250000.0', currency: 'VND', workspace_revision: 4, status: 'pending', reason: null,
    created_at: '2026-11-07T03:00:00Z', decided_at: null, approval_id: null, approval_active: false,
  });
  await installRetailApi(page, world);
  await login(page);

  // A prepared return is received, another canceled.
  await page.goto('/returns?returnId=posreturn_a');
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  await expect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();
  await page.goto('/returns?returnId=posreturn_b');
  await page.getByLabel('Lý do hủy').fill('Khách không trả nữa');
  await page.getByRole('button', { name: 'Hủy phiếu trả' }).click();
  await expect.poll(() => world.returns.find((row) => row.id === 'posreturn_b')?.status).toBe('canceled');

  // Refunds already requested: paid out, canceled, recorded as not made.
  await page.goto('/returns?returnId=posreturn_c');
  const refunds = page.getByRole('region', { name: 'Hoàn tiền' });
  await expect(refunds).toContainText('Yêu cầu hoàn tiền mới chưa được bật cho chi nhánh này');
  await expect(refunds.getByRole('button', { name: 'Yêu cầu hoàn tiền' })).toHaveCount(0);
  await refunds.getByRole('listitem').filter({ hasText: '10.000' }).getByRole('button', { name: 'Xác nhận chi' }).click();
  const payout = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
  await payout.getByRole('checkbox').check();
  await payout.getByRole('button', { name: 'Xác nhận đã chi' }).click();
  await expect(payout).toHaveCount(0);
  const cancelRow = refunds.getByRole('listitem').filter({ hasText: '20.000' });
  await cancelRow.getByRole('button', { name: 'Hủy yêu cầu' }).click();
  await cancelRow.getByLabel('Lý do hủy').fill('Khách nhận đổi hàng');
  await cancelRow.getByRole('button', { name: 'Xác nhận hủy' }).click();
  const unknownRow = refunds.getByRole('listitem').filter({ hasText: '30.000' });
  await unknownRow.getByRole('button', { name: 'Không thực hiện (có chứng từ)' }).click();
  await unknownRow.getByLabel(/Chứng từ không chi/).fill('Sao kê 07/11 không có lệnh');
  await unknownRow.getByRole('button', { name: 'Ghi nhận không thực hiện' }).click();
  await expect.poll(() => world.refunds.map((row) => row.status)).toEqual(['confirmed', 'canceled', 'failed']);
  // No exchange can be opened, and the page says why.
  await expect(page.getByText('Đổi hàng chưa được bật cho chi nhánh này', { exact: false })).toBeVisible();

  // The customer display still showing an order is cleared and disconnected.
  await page.goto('/');
  await openTab(page, 'ws_shown');
  const display = page.getByRole('region', { name: 'Màn hình khách' });
  await display.getByRole('button', { name: 'Xóa màn hình khách' }).click();
  await expect.poll(() => (world.display ? world.display.pinned_workspace_id : 'gone')).toBeNull();
  await display.getByText('Thiết bị màn hình').click();
  await expect(display.getByRole('button', { name: 'Mở cửa sổ màn hình khách' })).toBeVisible();
  await expect(display.getByRole('button', { name: 'Tạo mã kết nối thiết bị khác' })).toHaveCount(0);
  await display.getByRole('button', { name: 'Ngắt kết nối' }).click();
  await expect.poll(() => world.display).toBeNull();

  // A colleague's safe drop is confirmed; an existing export is downloaded.
  await openMenuLink(page, 'Ca & két');
  const requests = page.getByRole('region', { name: 'Thu/chi két chờ xác nhận' });
  await requests.getByRole('button', { name: 'Xác nhận' }).click();
  await expect.poll(() => world.cashRequests[0].status).toBe('confirmed');
  await openMenuLink(page, 'Báo cáo');
  await expect(page.getByRole('button', { name: 'Xuất CSV' })).toBeDisabled();
  await page.getByRole('list', { name: 'File xuất của bạn' }).getByRole('button', { name: 'Tải về' }).click();
  await expect.poll(() => world.downloads).toEqual(['posexport_old']);

  // Credit requests can still be declined, but not approved.
  await openMenuLink(page, 'Duyệt');
  const credit = page.getByRole('list', { name: 'Duyệt ghi nợ' }).getByRole('listitem').filter({ hasText: 'R900' });
  const approve = credit.getByRole('button', { name: 'Duyệt ghi nợ' });
  await expect(approve).toBeDisabled();
  await expect(approve).toHaveAccessibleDescription(/Bán ghi nợ chưa được bật cho chi nhánh này/);
  await expect(credit.getByRole('button', { name: 'Từ chối' })).toBeEnabled();

  for (const [family, count] of [
    ['return.receive', 1],
    ['return.cancel', 1],
    ['refund.confirm', 1],
    ['refund.resolve', 2],
    ['display.clear', 1],
    ['display.revoke', 1],
    ['cash.request', 1],
  ] as const)
    expect(effects(world, family), family).toBe(count);
  expect(world.restocks).toHaveLength(1);
  // Nothing new was started.
  for (const family of ['return.prepare', 'refund.request', 'exchange', 'display.pin', 'display.bind', 'export.create', 'credit.request'] as const)
    expect(effects(world, family), family).toBe(0);
  expect(world.writes.filter((write) => !write.key && !write.family.startsWith('display.'))).toEqual([]);
});

test('a command recorded before the switch-off answers from its receipt afterwards', async ({ page }) => {
  const world = newWorld();
  world.flags = { store: { returns: true }, branch: {}, writes: [] };
  soldOrder(world);
  await installRetailApi(page, world);
  await login(page);
  await page.goto('/returns?orderId=or_ws_sold');
  await page.getByLabel('Gạo ST25', { exact: true }).fill('1');
  await page.getByRole('button', { name: 'Xem trước' }).click();
  await page.getByLabel('Lý do trả').fill('Khách đổi ý');
  // The server records the return; every answer is lost on the way back.
  world.faults.set('return.prepare', { lose: 3 });
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await expect(page.getByRole('alert')).toHaveText(/đang kiểm tra kết quả/, { timeout: 15_000 });
  expect(effects(world, 'return.prepare')).toBe(1);

  // A manager switches returns off meanwhile. The same command is not new:
  // the browser finds its receipt, and a replay of the key returns the result.
  world.flags.branch.returns = false;
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await expect(page.getByRole('heading', { name: /Phiếu RET\d+/ })).toBeVisible();
  const sent = world.writes.find((write) => write.family === 'return.prepare');
  // Sent from the page so it goes through the same (mocked) API.
  const post = (key: string, body: unknown) =>
    page.evaluate(
      async ({ key, body }) => {
        const response = await fetch('/api/v3/admin/pos/returns', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Idempotency-Key': key },
          body: JSON.stringify(body),
        });
        return { status: response.status, json: await response.json() };
      },
      { key, body },
    );
  const replay = await post(sent?.key ?? '', sent?.body);
  expect(replay.status).toBe(201);
  expect(replay.json.data.id).toBe(world.returns[0].id);
  expect(effects(world, 'return.prepare')).toBe(1);
  // The same key with another payload is refused, as the server does.
  const altered = await post(sent?.key ?? '', { ...sent?.body, reason: 'Khác' });
  expect(altered.status).toBe(409);
  expect(altered.json.error.message).toBe('Idempotency key was reused with a different payload.');
  // A new return with another key is refused while the switch is off.
  const fresh = await post('fresh-key', { ...sent?.body, idempotency_key: 'fresh-key' });
  expect(fresh.status).toBe(409);
  expect(fresh.json.error.details).toMatchObject({ reason: 'feature_disabled', feature: 'returns' });
  // And a command without any key is not accepted at all.
  const keyless = await page.evaluate(async () => (await fetch('/api/v3/admin/pos/returns', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{}' })).status);
  expect(keyless).toBe(422);
});

test('an opening balance whose answer was lost can be checked again after traceability is switched off', async ({ page }) => {
  const world = newWorld({ capabilities: [...FULL_CASHIER, 'pos.inventory.manage', 'pos.inventory.trace'] });
  world.flags = { store: { traceability: true }, branch: {}, writes: [] };
  await installRetailApi(page, world);
  await login(page);
  await openMenuLink(page, 'Truy xuất tồn kho');
  await page.getByRole('button', { name: 'Khai báo tồn đầu kỳ Điện thoại A' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('textbox', { name: /Danh sách serial/ }).fill('SN-1\nSN-2\nSN-3\nSN-4\n');
  world.faults.set('inventory.opening', { lose: 3 });
  await dialog.getByRole('button', { name: 'Lưu tồn đầu kỳ' }).click();
  await expect(dialog.getByRole('status')).toBeVisible({ timeout: 15_000 });
  expect(effects(world, 'inventory.opening')).toBe(1);
  await dialog.getByRole('button', { name: 'Không', exact: true }).click();

  // Traceability goes off; the opening button disappears, the check stays.
  world.flags.branch.traceability = false;
  await page.reload();
  await expect(page.getByText('chưa được bật cho chi nhánh này', { exact: false }).first()).toBeVisible();
  await expect(page.getByRole('button', { name: 'Khai báo tồn đầu kỳ Điện thoại A' })).toHaveCount(0);
  await page.getByRole('button', { name: 'Kiểm tra lại lần khai báo tồn đầu kỳ của Điện thoại A' }).click();
  await expect(page.getByText('Đã khai báo tồn đầu kỳ', { exact: false })).toBeVisible();
  expect(effects(world, 'inventory.opening')).toBe(1);
  await expect(page.getByRole('button', { name: /Kiểm tra lại lần khai báo/ })).toHaveCount(0);
});
