import { expect, type Locator, test } from '@playwright/test';
import { liveApi, liveExpect, liveLogin, liveNewDraft, requireLive, restoreLiveFeatures } from './support/live';
import {
  addLine,
  addSheet,
  completeAndHandOver,
  effects,
  type Family,
  installRetailApi,
  keylessWrites,
  keysOf,
  login,
  newWorld,
  openMenuLink,
  openTab,
  postsOf,
  product,
  scan,
  tab,
  type World,
} from './support/retail-api';

// The client retries a keyed command twice on a network error, so a response
// is lost three times in a row before the page has to recover on its own.
function loseNext(world: World, family: Family) {
  world.faults.set(family, { lose: 3 });
}

function exactlyOnce(world: World, family: Family) {
  expect(effects(world, family), `${family} effects`).toBe(1);
  expect(keysOf(world, family).size, `${family} keys`).toBe(1);
  expect([...keysOf(world, family)].every(Boolean), `${family} sent without a key`).toBe(true);
  expect(keylessWrites(world).filter((write) => !['display.bind', 'display.pairing', 'display.revoke'].includes(write.family))).toEqual([]);
}

// Presses the action again whenever the page offers it (its own retries gave
// up) until the success marker shows; a recovered command answers from its
// receipt instead of running twice.
async function retryUntil(button: Locator, done: Locator) {
  await expect(async () => {
    if ((await button.isVisible()) && (await button.isEnabled())) await button.click({ timeout: 2_000 });
    await expect(done).toBeVisible({ timeout: 3_000 });
  }).toPass({ timeout: 60_000 });
}

test('two browsers on one order: a takeover leaves one editor and the stale page writes nothing', async ({ browser }) => {
  const world = newWorld();
  addSheet(world, 'ws_1');
  const first = await browser.newContext();
  const second = await browser.newContext();
  try {
    await installRetailApi(first, world);
    await installRetailApi(second, world);
    const a = await first.newPage();
    const b = await second.newPage();
    await login(a);
    await login(b);
    await openTab(a, 'ws_1');
    await scan(a, '8930000000011');
    await expect.poll(() => world.sheets.get('ws_1')?.lines.length).toBe(1);

    await tab(b, 'ws_1').click();
    await b.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
    await expect(b.getByRole('button', { name: 'Tiếp quản quyền sửa' })).toBeVisible();
    await b.getByRole('button', { name: 'Tiếp quản quyền sửa' }).click();
    await expect(b.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
    const generation = world.sheets.get('ws_1')?.generation;

    // The first page still believes it edits: its scan is refused, not merged.
    await scan(a, '8930000000028');
    await expect(a.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled({ timeout: 15_000 });
    await scan(b, '8930000000011');
    await expect.poll(() => world.sheets.get('ws_1')?.lines.map((line) => [line.variantId, line.quantity])).toEqual([
      ['v_rice', 2],
    ]);
    expect(world.sheets.get('ws_1')?.generation).toBe(generation);
    expect(world.conflicts).toBeGreaterThan(0);
    expect(postsOf(world, 'items').filter((post) => post.body.variant_id === 'v_water')).toHaveLength(1);
  } finally {
    await first.close();
    await second.close();
  }
});

test('lost responses on scan, tender, completion and handover never record twice', async ({ page }) => {
  test.setTimeout(180_000);
  const world = newWorld();
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');
  const dialog = page.getByRole('dialog');

  loseNext(world, 'items');
  await scan(page, '8930000000011');
  const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
  await retryUntil(page.getByRole('button', { name: 'Thử lại quét' }), basket.locator('td.basket-index').first());
  exactlyOnce(world, 'items');

  loseNext(world, 'tender.prepare');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await expect(async () => {
    const resume = panel.getByRole('button', { name: 'Tiếp tục thanh toán' });
    if (!(await dialog.isVisible()) && (await resume.isVisible())) await resume.click({ timeout: 2_000 });
    await expect(dialog.getByLabel('Khách đưa')).toBeVisible({ timeout: 2_000 });
  }).toPass({ timeout: 30_000 });
  exactlyOnce(world, 'tender.prepare');

  loseNext(world, 'tender.confirm');
  // "Kết thúc" also completes the paid order; that response is lost too.
  loseNext(world, 'complete');
  await dialog.getByLabel('Khách đưa').fill('100.000');
  const finish = dialog.getByRole('button', { name: 'Kết thúc', exact: true });
  await expect(async () => {
    if (await finish.isVisible()) await finish.click({ timeout: 2_000 });
    await expect(dialog).toHaveCount(0, { timeout: 3_000 });
  }).toPass({ timeout: 40_000 });
  exactlyOnce(world, 'tender.confirm');
  expect(world.drawer).toBe(100000);

  await retryUntil(panel.getByRole('button', { name: 'Hoàn tất đơn' }), page.getByRole('button', { name: 'Giao hàng tại quầy' }));
  exactlyOnce(world, 'complete');

  loseNext(world, 'handover');
  await retryUntil(page.getByRole('button', { name: 'Giao hàng tại quầy' }), page.getByText('Đã giao hàng tại quầy.'));
  exactlyOnce(world, 'handover');
  expect(world.stockMoves).toEqual([{ workspaceId: 'ws_1', variantId: 'v_rice', quantity: 1 }]);
});

test('lost responses on return, refund, exchange, collection and shift close never record twice', async ({ page }) => {
  test.setTimeout(240_000);
  const world = newWorld();
  const sold = addSheet(world, 'ws_sold', { customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' } });
  addLine(world, sold, 'v_rice', 3);
  await installRetailApi(page, world);
  await login(page);
  const panel = page.locator('.payment-panel');
  const dialog = page.getByRole('dialog');

  // Sell 300k: 200k cash now, 100k on approved credit, so there is debt to collect.
  await openTab(page, 'ws_sold');
  await panel.getByLabel('Tiền mặt').fill('200.000');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByLabel('Khách đưa').fill('200.000');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  sold.creditApproved = true;
  sold.creditRequested = true;
  await panel.getByRole('button', { name: 'Ghi nợ', exact: true }).click();
  await page.getByRole('dialog', { name: 'Ghi nợ cho khách' }).getByRole('button', { name: 'Hoàn tất & ghi nợ' }).click();
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible();

  loseNext(world, 'collection');
  await openMenuLink(page, 'Công nợ khách hàng');
  await page.getByRole('button', { name: /Chị Lan/ }).click();
  await page.getByRole('button', { name: 'Thu nợ' }).click();
  await dialog.getByLabel('Số tiền thu').fill('50.000');
  await dialog.getByLabel('Khách đưa').fill('50.000');
  const collect = dialog.getByRole('button', { name: 'Ghi nhận thu nợ' });
  // A recovered receipt is reported as recorded earlier, never recorded again.
  await retryUntil(collect, dialog.getByText(/Đã ghi nhận thu 50\.000 ₫\.|50\.000 ₫ đã được ghi nhận trước đó/));
  exactlyOnce(world, 'collection');
  await dialog.locator('.payment-popup-actions').getByRole('button', { name: 'Đóng' }).click();

  await page.goto(`/returns?orderId=${sold.orderId}`);
  await page.getByLabel('Gạo ST25', { exact: true }).fill('1');
  await page.getByRole('button', { name: 'Xem trước' }).click();
  await page.getByLabel('Lý do trả').fill('Khách đổi ý');
  loseNext(world, 'return.prepare');
  await retryUntil(page.getByRole('button', { name: 'Lập phiếu trả' }), page.getByRole('button', { name: 'Nhận hàng trả' }));
  exactlyOnce(world, 'return.prepare');

  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  await expect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();
  // The order still owed 50k, so the first 50k of the return clears debt.
  expect(world.returns[0]).toMatchObject({ creditNote: 50000, refund: 50000 });

  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  loseNext(world, 'refund.request');
  await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
  const recheck = page.getByRole('region', { name: 'Phiếu trả hàng' }).getByRole('button', { name: 'Kiểm tra lại' }).first();
  await retryUntil(recheck, refund.getByRole('button', { name: 'Xác nhận chi' }));
  exactlyOnce(world, 'refund.request');

  loseNext(world, 'refund.confirm');
  await refund.getByRole('button', { name: 'Xác nhận chi' }).click();
  const payout = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
  await payout.getByRole('checkbox').check();
  await expect(async () => {
    const confirm = payout.getByRole('button', { name: 'Xác nhận đã chi' });
    if (await confirm.isVisible()) await confirm.click({ timeout: 2_000 });
    await expect(payout).toHaveCount(0, { timeout: 3_000 });
  }).toPass({ timeout: 40_000 });
  await expect(async () => {
    if (await recheck.isVisible()) await recheck.click({ timeout: 2_000 });
    await expect(refund).toContainText('Đã chi', { timeout: 2_000 });
  }).toPass({ timeout: 30_000 });
  exactlyOnce(world, 'refund.confirm');

  loseNext(world, 'exchange');
  await retryUntil(page.getByRole('button', { name: 'Đổi hàng: mở đơn bán mới' }), page.getByText(/Đã mở đơn đổi R\d+\./));
  exactlyOnce(world, 'exchange');

  // Cash: 200k sale + 50k collection - 50k refund.
  expect(world.drawer).toBe(200000);
  await openMenuLink(page, 'Ca & két');
  await page.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  const close = page.getByRole('dialog', { name: 'Đóng ca' });
  await close.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();
  await close.getByLabel('Tổng tiền mặt đếm được').fill('200.000');
  loseNext(world, 'shift.count');
  await retryUntil(close.getByRole('button', { name: 'Ghi nhận số đếm' }), close.locator('.variance'));
  exactlyOnce(world, 'shift.count');
  loseNext(world, 'shift.close');
  await expect(async () => {
    const button = close.getByRole('button', { name: 'Đóng ca', exact: true });
    if (await button.isVisible()) await button.click({ timeout: 2_000 });
    await expect(close).toContainText('Đã đóng ca', { timeout: 3_000 });
  }).toPass({ timeout: 40_000 });
  exactlyOnce(world, 'shift.close');
});

test('100 rapid scans add every item exactly once on the order they were scanned into', async ({ page }) => {
  test.setTimeout(180_000);
  const world = newWorld();
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_1');
  const codes = Array.from({ length: 100 }, (_, index) => product((index % 10) + 1).barcode ?? '');
  for (let burst = 0; burst < 10; burst += 1) await scan(page, ...codes.slice(burst * 10, burst * 10 + 10));
  await expect
    .poll(() => world.sheets.get('ws_1')?.lines.reduce((sum, line) => sum + line.quantity, 0), { timeout: 150_000 })
    .toBe(100);
  expect(world.sheets.get('ws_1')?.lines.map((line) => line.quantity)).toEqual(Array(10).fill(10));
  const posts = postsOf(world, 'items');
  expect(posts).toHaveLength(100);
  expect(new Set(posts.map((post) => post.key)).size).toBe(100);
  // Each scan waits for the previous answer, so it is sent from the newest revision.
  expect(posts.map((post) => post.body.expected_revision)).toEqual(Array.from({ length: 100 }, (_, index) => index + 1));
  expect(world.conflicts).toBe(0);
});

test('out-of-order answers: slow scans and stale reads never land on the wrong order or roll back', async ({ page }) => {
  const world = newWorld();
  addSheet(world, 'ws_a');
  addSheet(world, 'ws_b');
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_b');
  await openTab(page, 'ws_a');

  // A's answers are slow; the cashier moves to B and scans there meanwhile.
  world.faults.set('items', { delayMs: 1200 });
  await scan(page, '8930000000011', '8930000000011');
  await openTab(page, 'ws_b');
  world.faults.set('items', { delayMs: 0 });
  await scan(page, '8930000000028');
  await expect.poll(() => world.sheets.get('ws_b')?.lines.map((line) => [line.variantId, line.quantity])).toEqual([
    ['v_water', 1],
  ]);
  await expect.poll(() => world.sheets.get('ws_a')?.lines.map((line) => [line.variantId, line.quantity]), { timeout: 15_000 }).toEqual([
    ['v_rice', 2],
  ]);

  // Reads that arrive after a newer write carry an older revision; the page keeps the newer one.
  world.slowReads.set('/pos/workspaces', 1500);
  await scan(page, '8930000000028');
  const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
  await expect(page.getByRole('spinbutton', { name: 'Số lượng Nước suối' })).toHaveValue('2');
  await page.waitForTimeout(2000);
  await expect(page.getByRole('spinbutton', { name: 'Số lượng Nước suối' })).toHaveValue('2');
  await expect(basket.locator('td.basket-index')).toHaveCount(1);
  expect(world.conflicts).toBe(0);
});

test.describe('real API', () => {
  test.afterEach(async ({ request }) => restoreLiveFeatures(request));
  test('a response lost after the server committed is recovered by key: one line, one payment', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'Live runs share one fixture shift; desktop only');
    test.setTimeout(180_000);
    const fixture = requireLive();
    const water = fixture.products.water;
    await liveLogin(page, fixture);
    const draft = await liveNewDraft(page);
    const api = await liveApi(request, fixture, 'cashier');

    // The server commits each first attempt; the browser never sees the answer.
    const lost = new Map<string, number>([['/items', 3], ['/confirm', 3]]);
    await page.route('**/api/v3/admin/pos/workspaces/**', async (route) => {
      const path = new URL(route.request().url()).pathname;
      const suffix = [...lost.keys()].find((end) => path.endsWith(end));
      if (!suffix || route.request().method() !== 'POST' || (lost.get(suffix) ?? 0) <= 0) return route.fallback();
      lost.set(suffix, (lost.get(suffix) ?? 0) - 1);
      await route.fetch();
      return route.abort('connectionreset');
    });
    await scan(page, water.barcode);
    const retry = page.getByRole('button', { name: 'Thử lại quét' });
    await liveExpect(retry).toBeVisible({ timeout: 60_000 });
    await retryUntil(retry, page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index').first());
    type Detail = { data: { line_items: Array<{ quantity: number }>; financial: { allocated: string; attempts: Array<{ status: string }> } } };
    await liveExpect
      .poll(async () => (await api.get<Detail>(`/pos/workspaces/${draft.id}`)).data.line_items.map((line) => line.quantity))
      .toEqual([1]);
    await liveExpect(page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index')).toHaveCount(1);

    const panel = page.locator('.payment-panel');
    const dialog = page.getByRole('dialog');
    await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
    await dialog.getByLabel('Khách đưa').fill(String(water.price));
    const finish = dialog.getByRole('button', { name: 'Kết thúc', exact: true });
    await liveExpect(async () => {
      if (await finish.isVisible()) await finish.click({ timeout: 2_000 });
      await liveExpect(dialog).toHaveCount(0, { timeout: 5_000 });
    }).toPass({ timeout: 90_000 });
    const after = (await api.get<Detail>(`/pos/workspaces/${draft.id}`)).data;
    liveExpect(after.financial.attempts.filter((attempt) => attempt.status === 'confirmed')).toHaveLength(1);
    liveExpect(Number(after.financial.allocated)).toBe(water.price);
    // Leave nothing paid but open: it would block the shift close.
    await page.unrouteAll({ behavior: 'wait' });
    await completeAndHandOver(page, 30_000);
  });
});
