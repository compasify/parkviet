import { expect, type Page, test } from '@playwright/test';
import { liveApi, liveEnableFeatures, liveExpect, liveLogin, liveNewDraft, requireLive, restoreLiveFeatures } from './support/live';
import {
  addSheet,
  completeAndHandOver,
  installRetailApi,
  login,
  newWorld,
  OTHER_LABEL,
  openTab,
  payCash,
  scan,
  WEIGHT_LABEL,
} from './support/retail-api';

async function addSerials(page: Page, search: string, serials: string[]) {
  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill(search);
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  await page.locator('details.catalog-advanced summary').first().click();
  const form = page.locator('.add-item-form');
  await form.getByRole('textbox', { name: /^Serial/ }).fill(`${serials.join('\n')}\n`);
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
}

test('weighed labels, serials and FEFO lots keep their provenance through sale, handover and a partial return', async ({ page }) => {
  const world = newWorld({ capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.return.process'] });
  const sheet = addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
  const basket = page.locator('.basket-lines');

  // Two weighings of the same pork are two lines, each priced from its own label.
  await scan(page, WEIGHT_LABEL, OTHER_LABEL);
  await expect.poll(() => sheet.lines.map((line) => line.label?.base)).toEqual([500, 300]);
  expect(new Set(sheet.lines.map((line) => line.label?.eventId)).size).toBe(2);

  await addSerials(page, 'DT-1', ['SN-1', 'SN-2']);
  await expect(basket).toContainText('Serial: SN-1 · đang giữ');
  await expect(basket).toContainText('Serial: SN-2 · đang giữ');

  // Three yogurts: FEFO plans the two near-expiry pots of L-01 first.
  await scan(page, '8930000000035', '8930000000035', '8930000000035');
  await expect.poll(() => sheet.lines.at(-1)?.quantity).toBe(3);
  await expect(basket).toContainText('Dự kiến lô L-01');

  // 60.000 + 36.000 + 2 × 2.500.000 + 3 × 50.000
  await payCash(page, '5.246.000');
  expect(sheet.lines.at(-1)?.lots).toEqual([
    { code: 'L-01', expiry: '2026-11-20', quantity: 2 },
    { code: 'L-02', expiry: '2027-03-01', quantity: 1 },
  ]);
  await completeAndHandOver(page);
  expect(world.stockMoves.map((move) => [move.variantId, move.quantity])).toEqual([
    ['v_pork', 500],
    ['v_pork', 300],
    ['v_phone', 2],
    ['v_yogurt', 3],
  ]);
  expect(world.serialStock.has('SN-1') || world.serialStock.has('SN-2')).toBe(false);

  // Partial return: 200 g of the first package, serial SN-2 and the L-02 pot.
  await page.goto(`/returns?orderId=${sheet.orderId}`);
  const [firstPork, , phone, yogurt] = sheet.lines;
  await page.locator(`#return-qty-${firstPork.saleLineId}`).fill('200');
  await page.getByRole('group', { name: 'Serial trả lại của Điện thoại A' }).getByLabel('SN-2').check();
  await page.getByLabel('Tình trạng Điện thoại A').selectOption('resellable');
  await page.getByLabel('Sữa chua', { exact: true }).fill('1');
  await page.getByLabel('Lô trả về của Sữa chua').selectOption('L-02');
  await page.getByLabel('Tình trạng Sữa chua').selectOption('resellable');
  await page.getByRole('button', { name: 'Xem trước' }).click();
  const preview = page.getByRole('region', { name: 'Xem trước giá trị trả' });
  await expect(preview).toContainText('Nhận lại: SN-2');
  // 200 g × 120 + 2.500.000 + 50.000
  await expect(preview).toContainText('2.574.000 ₫');
  await page.getByLabel('Lý do trả').fill('Khách đổi ý');
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  await expect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();

  expect(world.returns[0].lines).toEqual([
    expect.objectContaining({ saleLineId: firstPork.saleLineId, quantity: 200, value: 24000 }),
    expect.objectContaining({ saleLineId: phone.saleLineId, quantity: 1, serials: ['SN-2'], value: 2500000 }),
    expect.objectContaining({ saleLineId: yogurt.saleLineId, quantity: 1, lot: 'L-02', value: 50000 }),
  ]);
  expect(world.restocks.map((row) => [row.saleLineId, row.quantity])).toEqual([
    [firstPork.saleLineId, 200],
    [phone.saleLineId, 1],
    [yogurt.saleLineId, 1],
  ]);
  expect(world.serialStock.has('SN-2')).toBe(true);
  expect(world.serialStock.has('SN-1')).toBe(false);

  // What is left to return stays per line and per unit: the second package is
  // untouched and SN-2 cannot come back twice.
  await page.goto(`/returns?orderId=${sheet.orderId}`);
  await expect(page.getByRole('group', { name: 'Serial trả lại của Điện thoại A' }).getByRole('checkbox')).toHaveCount(1);
  await expect(page.getByRole('group', { name: 'Serial trả lại của Điện thoại A' })).toContainText('SN-1');
});

function ean13(body: string) {
  const sum = [...body].reduce((total, digit, index) => total + Number(digit) * (index % 2 === 0 ? 1 : 3), 0);
  return `${body}${(10 - (sum % 10)) % 10}`;
}

test.describe('real API', () => {
  test.afterEach(async ({ request }) => restoreLiveFeatures(request));
  test('weighed label, serials and lots: sale, handover and partial return keep provenance', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'Enrollment is one-time per fixture; desktop only');
    test.setTimeout(240_000);
    const fixture = requireLive();
    await liveEnableFeatures(request, fixture, ['traceability', 'returns']);
    const { pork, phone, yogurt } = fixture.products;
    const manager = await liveApi(request, fixture, 'manager');
    const branch = fixture.branch_id;
    const serials = [`SN-${fixture.tag}-1`, `SN-${fixture.tag}-2`, `SN-${fixture.tag}-3`];

    // Configure the goods as a manager would: a scale label format, kg/g for
    // pork with its label code, and opening balances for serial and lot stock.
    const format = await manager.send('POST', `/pos/branches/${branch}/label_formats`, {
      name: 'Cân điện tử', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g',
    });
    liveExpect([201, 409], JSON.stringify(format.body)).toContain(format.status);
    const units = [
      { variant_id: pork.variant_id, sale_unit: 'kg', base_unit: 'g', price_unit: 'kg', label_code: fixture.label_code },
      { variant_id: phone.variant_id, sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'serial' },
      { variant_id: yogurt.variant_id, sale_unit: 'item', base_unit: 'item', price_unit: 'item', tracked_mode: 'lot' },
    ];
    for (const unit of units) {
      const result = await manager.send('PUT', '/pos/units/variant', { branch_id: branch, ...unit });
      liveExpect(result.status, JSON.stringify(result.body)).toBe(200);
    }
    for (const opening of [
      { variant_id: phone.variant_id, serials },
      { variant_id: yogurt.variant_id, lots: [{ lot_code: `L1-${fixture.tag}`, expiry_on: '2027-01-31', quantity: 2 }, { lot_code: `L2-${fixture.tag}`, expiry_on: '2027-06-30', quantity: 10 }] },
    ]) {
      const result = await manager.send('POST', '/pos/inventory/opening_balances', { branch_id: branch, ...opening });
      liveExpect([200, 201, 409], JSON.stringify(result.body)).toContain(result.status);
    }

    await liveLogin(page, fixture);
    const draft = await liveNewDraft(page);
    const cashier = await liveApi(request, fixture, 'cashier');
    await scan(page, ean13(`21${fixture.label_code}00500`));
    await addSerials(page, phone.name.split(' ')[0], serials.slice(0, 2));
    await scan(page, yogurt.barcode, yogurt.barcode, yogurt.barcode);
    type Line = { sale_line_id: string; name: string; quantity: number; base_quantity?: number; amount: string; trace?: { allocations: Array<{ serial: string | null; lot_code: string | null; quantity: number }> } | null };
    type Detail = { data: { order_id: string; line_items: Line[]; totals: { total: string } } };
    await liveExpect
      .poll(async () => (await cashier.get<Detail>(`/pos/workspaces/${draft.id}`)).data.line_items.map((line) => line.base_quantity ?? line.quantity), { timeout: 30_000 })
      .toEqual([500, 2, 3]);
    const total = (await cashier.get<Detail>(`/pos/workspaces/${draft.id}`)).data.totals.total;
    await payCash(page, String(Number.parseInt(total, 10)), 30_000);
    await completeAndHandOver(page, 30_000);
    const sold = (await cashier.get<Detail>(`/pos/workspaces/${draft.id}`)).data;
    const lotLine = sold.line_items[2];
    liveExpect(lotLine.trace?.allocations.map((row) => [row.lot_code, row.quantity])).toEqual([[`L1-${fixture.tag}`, 2], [`L2-${fixture.tag}`, 1]]);

    await page.goto(`/returns?orderId=${sold.order_id}`);
    await page.locator(`#return-qty-${sold.line_items[0].sale_line_id}`).fill('200');
    await page.getByRole('group', { name: `Serial trả lại của ${phone.name}` }).getByLabel(serials[1]).check();
    await page.getByLabel(`Tình trạng ${phone.name}`).selectOption('resellable');
    await page.getByLabel(yogurt.name, { exact: true }).fill('1');
    await page.getByLabel(`Lô trả về của ${yogurt.name}`).selectOption(`L2-${fixture.tag}`);
    await page.getByLabel(`Tình trạng ${yogurt.name}`).selectOption('resellable');
    await page.getByRole('button', { name: 'Xem trước' }).click();
    await page.getByLabel('Lý do trả').fill('Kiểm thử e2e thật');
    await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
    await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
    await liveExpect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();
    const returnId = new URL(page.url()).searchParams.get('returnId') ?? '';
    type ReturnBody = { data: { lines: Array<{ sale_line_id: string; quantity: number; restocked_quantity: number }> } };
    const received = (await cashier.get<ReturnBody>(`/pos/returns/${returnId}`)).data;
    liveExpect(received.lines.map((line) => [line.sale_line_id, line.quantity, line.restocked_quantity])).toEqual([
      [sold.line_items[0].sale_line_id, 200, 200],
      [sold.line_items[1].sale_line_id, 1, 1],
      [sold.line_items[2].sale_line_id, 1, 1],
    ]);
  });
});
