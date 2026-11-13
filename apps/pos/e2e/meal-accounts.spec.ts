import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addLine, addSheet, FULL_CASHIER, installRetailApi, login, newWorld, openTab, type Sheet, serialize, sheetTotal, type World } from './support/retail-api';

// A canteen sells at the quick counter: the meal code field heads the ticket
// and keeps the focus. An employee code and Enter records the meal and the
// eater shows on the ticket with the sponsor's and the eater's parts. One
// touch pays the eater's part from the wallet and completes the order, the
// sponsor's part going on its credit, and the bill prints; cash (F1) takes
// only the eater's part. A second swipe of the same eater is refused in red
// on the ticket with the duplicate tone. A code typed as fast as a scanner
// types it is never taken by the payment keys, and after each order the
// focus is back in the field for the next eater. Limits, windows and the
// split are decided on the server.
// Presentation fixtures only: no real account privileges.

const SPONSOR_PART = 10000;
const EATER_PART = 5000;

type MealApi = {
  lookups: string[];
  swipes: Record<string, unknown>[];
  walletPays: Record<string, unknown>[];
  completes: Record<string, unknown>[];
};

function canteenWorld(modules: Record<string, boolean> = {}): World {
  return newWorld({
    capabilities: FULL_CASHIER,
    modules: { 'retail.units': true, 'fnb.menu': true, 'fnb.meal_accounts': true, ...modules },
    profile: { key: 'cang_tin_tram_dung', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
  });
}

function account(balance: number) {
  return {
    id: 'posmeal_1', employee_code: 'NV001', name: 'Nguyễn An', phone: null, customer_id: 'poscustomer_meal',
    group_label: 'Kho', sponsor: { id: 'possponsor_1', name: 'Công ty A' }, pay_mode: 'sponsor_subsidy',
    daily_meal_limit: 2, meal_windows: [], low_balance_threshold: '50000.0', balance: `${balance}.0`,
    currency: 'VND', status: 'active', revision: 1, updated_at: '2026-11-12T03:00:00Z',
  };
}

// A meal of one flan (15.000 ₫): the sponsor pays 10.000 ₫, the eater 5.000 ₫.
const PLAN = {
  meal_account_id: 'posmeal_1', pay_mode: 'sponsor_subsidy', total: '15000.0', sponsor_id: 'possponsor_1',
  sponsor_name: 'Công ty A', sponsor_amount: `${SPONSOR_PART}.0`, employee_amount: `${EATER_PART}.0`,
  sponsor_unavailable: false,
};

// The meal endpoints, in front of the retail server, for whichever order is
// on the ticket: resolving a code, recording the meal (a second swipe on the
// same order is a duplicate), the wallet paying the eater's part and
// completing with the sponsor's part on credit.
// `lookup`: holds each code lookup until it resolves (a slow network).
async function installMealApi(page: Page, world: World, lookup?: Promise<void>): Promise<MealApi> {
  const api: MealApi = { lookups: [], swipes: [], walletPays: [], completes: [] };
  const recorded = new Set<string>();
  let balance = 120000;
  const status = () => ({
    ...account(balance), meals_today: 1, meals_left: 1, low_balance: false, wallet_covers: balance >= EATER_PART, plan: PLAN,
  });
  const reply = (route: Route, value: unknown, code = 200) => route.fulfill({ status: code, json: { data: value } });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const body = (request.method() === 'GET' ? {} : (request.postDataJSON() ?? {})) as Record<string, unknown>;
    if (path === '/pos/meal_accounts/resolve') {
      const q = url.searchParams.get('q') ?? '';
      api.lookups.push(q);
      if (lookup) await lookup;
      return reply(route, { match: q.toUpperCase() === 'NV001' ? account(balance) : null, suggestions: [] });
    }
    const meal = /^\/pos\/workspaces\/([^/]+)\/(meal|meal_swipes|meal_wallet|complete)$/.exec(path);
    const sheet: Sheet | undefined = meal ? world.sheets.get(meal[1]) : undefined;
    if (!meal || !sheet) return route.fallback();
    const id = sheet.id;
    if (meal[2] === 'meal')
      return reply(route, { workspace_id: id, meal: recorded.has(id) ? status() : null, plan: recorded.has(id) ? PLAN : null });
    if (meal[2] === 'meal_swipes') {
      api.swipes.push(body);
      if (recorded.has(id))
        return route.fulfill({
          status: 409,
          json: {
            error: {
              code: 'conflict', message: 'This meal was just recorded.',
              details: { reason: 'meal_duplicate_swipe', result: 'duplicate', meal: status() },
            },
          },
        });
      recorded.add(id);
      sheet.customer = { id: 'poscustomer_meal', name: 'Nguyễn An', phone: '0901000001' };
      sheet.revision += 1;
      return reply(route, { result: 'ok', reason: null, meal: status(), workspace: serialize(world, sheet) }, 201);
    }
    if (meal[2] === 'meal_wallet') {
      api.walletPays.push(body);
      balance -= EATER_PART;
      sheet.allocated += EATER_PART;
      sheet.revision += 1;
      return reply(route, { workspace: serialize(world, sheet), meal: status() });
    }
    if (body.meal_sponsor !== true) return route.fallback();
    api.completes.push(body);
    if (sheetTotal(world, sheet) - sheet.allocated !== SPONSOR_PART)
      return route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message: 'Unpaid.', details: { reason: 'meal_split_unpaid' } } },
      });
    sheet.status = 'completed';
    sheet.orderId = `or_${id}`;
    sheet.revision += 1;
    return reply(route, serialize(world, sheet));
  });
  return api;
}

// The sale receipt for the print popup, and a browser print that records itself.
async function mockSaleReceipt(page: Page) {
  const receipt = {
    id: 'posreceipt_meal', source_type: 'sale', number: 'HD-0042', branch_id: 'br_1',
    issued_at: '2026-11-12T04:00:00Z', issued_late: false, disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: false, copy_count: 0,
    document: { title: 'PHIẾU BÁN HÀNG', currency: 'VND', lines: [], totals: { item_total: '15000', total: '15000' } },
  };
  await page.route('**/pos/receipts/lookup?*', (route) => route.fulfill({ json: { data: receipt } }));
  await page.route('**/pos/receipts/posreceipt_meal/prints', (route) =>
    route.fulfill({
      status: 201,
      json: {
        data: {
          print: { id: 'posprint_1', copy: false, copy_number: 0, label: null, printed_at: '2026-11-12T04:00:01Z' },
          receipt: { ...receipt, printed: true },
        },
      },
    }),
  );
  await page.addInitScript(() => {
    localStorage.setItem('parkviet-pos:auto-print:sale', 'on');
    window.print = () => {
      const sheet = window.document.querySelector('[data-testid="receipt-print-sheet"]');
      const seen = window as unknown as { receiptPrints?: string[] };
      seen.receiptPrints = [...(seen.receiptPrints ?? []), sheet?.getAttribute('data-print-id') ?? ''];
    };
  });
}

// Every tone the scan field asked for, in order.
async function recordTones(page: Page) {
  await page.addInitScript(() => {
    window.addEventListener('parkviet-pos:scan-tone', (event) => {
      const seen = window as unknown as { scanTones?: string[] };
      seen.scanTones = [...(seen.scanTones ?? []), (event as CustomEvent<{ tone: string }>).detail.tone];
    });
  });
}

const tones = (page: Page) => page.evaluate(() => (window as unknown as { scanTones?: string[] }).scanTones ?? []);
const receiptPrints = (page: Page) =>
  page.evaluate(() => (window as unknown as { receiptPrints?: string[] }).receiptPrints ?? []);
const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu quầy' });
const codeField = (page: Page) => ticket(page).getByLabel('Mã nhân viên / tên');
const flan = (page: Page) => page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true });
const prepares = (world: World) => world.writes.filter((write) => write.family === 'tender.prepare');

// The canteen opens on the quick counter: no invoice tabs, the first ticket
// ready and the code field waiting for the first eater.
async function openCanteen(page: Page, world: World) {
  await login(page);
  await expect(ticket(page)).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(1);
  await expect(page.getByRole('tablist')).toHaveCount(0);
  await expect(codeField(page)).toBeFocused();
  return [...world.sheets.values()][0];
}

async function swipe(page: Page, code: string) {
  await codeField(page).fill(code);
  await codeField(page).press('Enter');
}

test('an employee code and Enter records the meal, and one touch pays the wallet, completes and prints the bill', async ({ page }) => {
  const world = canteenWorld();
  await installRetailApi(page, world);
  const api = await installMealApi(page, world);
  await mockSaleReceipt(page);
  await recordTones(page);
  const sheet = await openCanteen(page, world);
  await flan(page).click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');

  await swipe(page, 'nv001');
  const banner = ticket(page).getByTestId('meal-banner');
  await expect(banner).toContainText('Nguyễn An');
  await expect(banner).toContainText('NV001 · Kho');
  await expect(banner).toContainText('120.000');
  await expect(banner).toContainText('Công ty A trả');
  await expect(banner).toContainText('10.000');
  await expect(banner).toContainText('5.000');
  await expect(ticket(page).getByRole('status').filter({ hasText: 'Đã ghi suất cho Nguyễn An.' })).toBeVisible();
  expect(api.lookups).toEqual(['nv001']);
  expect(api.swipes).toHaveLength(1);
  expect(api.swipes[0]).toMatchObject({ code: 'nv001', input_method: 'code' });
  expect(api.swipes[0]).toHaveProperty('idempotency_key');
  await expect.poll(() => tones(page)).toEqual(['ok']);

  // The cashier takes only the eater's part: the notes are offered for it.
  await expect(ticket(page).getByTestId('quick-eater-due')).toContainText('5.000 ₫');
  await expect(ticket(page).getByRole('button', { name: 'Khách đưa 10.000' })).toBeVisible();
  await expect(ticket(page).getByRole('button', { name: 'Khách đưa 20.000' })).toHaveCount(0);

  await banner.getByRole('button', { name: /Trả 5\.000 ₫ bằng ví và hoàn tất/ }).click();
  await expect.poll(() => sheet.status).toBe('completed');
  expect(api.walletPays).toHaveLength(1);
  expect(api.walletPays[0]).not.toHaveProperty('amount');
  expect(api.completes).toHaveLength(1);
  expect(api.completes[0]).toMatchObject({ meal_sponsor: true });
  expect(sheet.allocated).toBe(EATER_PART);
  expect(prepares(world)).toHaveLength(0);
  await expect.poll(() => sheet.handedOver).toBe(true);

  const receiptDialog = page.getByRole('dialog');
  await expect(receiptDialog).toContainText('HD-0042');
  await expect.poll(() => receiptPrints(page)).toEqual(['posprint_1']);
  await expect(ticket(page).getByTestId('quick-done')).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(2);

  // Once the bill is put away, the code field waits for the next eater.
  await page.keyboard.press('Escape');
  await expect(receiptDialog).toHaveCount(0);
  await expect(codeField(page)).toBeFocused();
});

test('a second swipe of the same eater is refused in red on the ticket with the duplicate tone', async ({ page }) => {
  const world = canteenWorld();
  await installRetailApi(page, world);
  const api = await installMealApi(page, world);
  await recordTones(page);
  await openCanteen(page, world);
  await flan(page).click();

  await swipe(page, 'NV001');
  await expect(ticket(page).getByTestId('meal-banner')).toContainText('Nguyễn An');
  await swipe(page, 'NV001');

  const refusal = ticket(page).getByRole('alert').filter({ hasText: 'Người này vừa được ghi suất. Không ghi trùng.' });
  await expect(refusal).toBeVisible();
  await expect(refusal).toHaveAttribute('data-tone', 'duplicate');
  await expect(refusal).toHaveCSS('color', 'rgb(161, 45, 32)');
  await expect(page.getByRole('dialog')).toHaveCount(0);
  expect(api.swipes).toHaveLength(2);
  await expect.poll(() => tones(page)).toEqual(['ok', 'duplicate']);
  await expect(codeField(page)).toBeFocused();
});

test('a code typed as fast as a scanner is never taken by the payment keys, F1 takes the eater part and the field is ready again', async ({ page }) => {
  const world = canteenWorld();
  await installRetailApi(page, world);
  const api = await installMealApi(page, world);
  await recordTones(page);
  const sheet = await openCanteen(page, world);

  // A tap on the menu hands the focus back to the code field.
  await flan(page).click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');
  await expect(codeField(page)).toBeFocused();

  // The scanner's keys land in the field, F1 in the middle of a code pays
  // nothing, and Enter records the meal.
  await page.keyboard.type('NV0', { delay: 0 });
  await page.keyboard.press('F1');
  await page.keyboard.type('01', { delay: 0 });
  await page.keyboard.press('Enter');
  await expect(ticket(page).getByTestId('meal-banner')).toContainText('Nguyễn An');
  expect(api.lookups).toEqual(['NV001']);
  await expect.poll(() => tones(page)).toEqual(['ok']);
  expect(prepares(world)).toHaveLength(0);
  expect(sheet.status).toBe('editing');
  await expect(page).not.toHaveURL(/view=pay/);
  await expect(codeField(page)).toHaveValue('');
  await expect(codeField(page)).toBeFocused();

  // From the empty field, F1 takes the eater's part in cash; completing
  // charges the sponsor's part.
  const cash = ticket(page).getByRole('button', { name: /^Tiền mặt đủ/ });
  await expect(ticket(page).getByTestId('quick-eater-due')).toContainText('5.000 ₫');
  await expect(cash).toBeEnabled();
  await page.keyboard.press('F1');
  await expect.poll(() => sheet.status).toBe('completed');
  expect(prepares(world).map((write) => [write.body.payment_method_id, write.body.amount])).toEqual([
    ['posmethod-cash', String(EATER_PART)],
  ]);
  expect(api.completes).toHaveLength(1);
  expect(api.completes[0]).toMatchObject({ meal_sponsor: true });
  expect(sheet.allocated).toBe(EATER_PART);
  await expect.poll(() => sheet.handedOver).toBe(true);

  // The next eater's ticket opens with the focus back in the field.
  await expect(ticket(page).getByTestId('quick-done')).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(2);
  await expect(ticket(page).getByTestId('meal-banner')).toHaveCount(0);
  await expect(codeField(page)).toBeFocused();
});

test('a branch selling from the catalogue keeps the meal code field on the counter', async ({ page }) => {
  const world = newWorld({ capabilities: FULL_CASHIER, modules: { 'fnb.meal_accounts': true } });
  const sheet = addSheet(world, 'ws_meal');
  // Three bottles of water: 15.000 ₫, the meal's price.
  addLine(world, sheet, 'v_water', 3);
  await installRetailApi(page, world);
  const api = await installMealApi(page, world);
  await login(page);
  await openTab(page, sheet.id);

  const field = page.getByLabel('Mã nhân viên / tên');
  await field.fill('NV001');
  await field.press('Enter');
  await expect(page.getByTestId('meal-banner')).toContainText('Nguyễn An');
  expect(api.swipes).toHaveLength(1);
  await expect(page.locator('.payment-panel .payment-method-row input').first()).toHaveAttribute('placeholder', String(EATER_PART));
});

test('F1 pressed while a scanned code is still answering takes nothing until the meal applies, then only the eater part', async ({ page }) => {
  const world = canteenWorld();
  await installRetailApi(page, world);
  let answer = () => {};
  const lookup = new Promise<void>((resolve) => {
    answer = resolve;
  });
  const api = await installMealApi(page, world, lookup);
  const sheet = await openCanteen(page, world);
  await flan(page).click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');
  const cash = ticket(page).getByRole('button', { name: /^Tiền mặt đủ/ });
  await expect(cash).toBeEnabled();

  // The scanner's code and Enter, then F1 at once: the code is still being
  // looked up, so cash waits and says so.
  await page.keyboard.type('NV001', { delay: 0 });
  await page.keyboard.press('Enter');
  await page.keyboard.press('F1');
  await expect.poll(() => api.lookups).toEqual(['NV001']);
  await expect(ticket(page).getByTestId('quick-meal-checking')).toHaveText('Đang kiểm suất ăn…');
  await expect(cash).toBeDisabled();
  expect(prepares(world)).toHaveLength(0);

  answer();
  await expect(ticket(page).getByTestId('meal-banner')).toContainText('Nguyễn An');
  await expect(ticket(page).getByTestId('quick-eater-due')).toContainText('5.000 ₫');
  await expect(cash).toBeEnabled();
  await expect(ticket(page).getByTestId('quick-meal-checking')).toHaveCount(0);
  expect(prepares(world)).toHaveLength(0);
  expect(sheet.status).toBe('editing');

  await page.keyboard.press('F1');
  await expect.poll(() => sheet.status).toBe('completed');
  expect(prepares(world).map((write) => write.body.amount)).toEqual([String(EATER_PART)]);
  expect(api.completes[0]).toMatchObject({ meal_sponsor: true });
});

test('a name typed after a payment keeps its focus once the paid number fades', async ({ page }) => {
  // Call numbers give the ticket a guest name field.
  const world = canteenWorld({ 'fnb.order_number': true });
  await installRetailApi(page, world);
  await installMealApi(page, world);
  const sheet = await openCanteen(page, world);
  await flan(page).click();
  await expect(ticket(page).getByTestId('quick-total')).toHaveText('15.000 ₫');
  await page.keyboard.press('F1');
  await expect.poll(() => sheet.status).toBe('completed');
  await expect(ticket(page).getByTestId('quick-done')).toBeVisible();
  await expect.poll(() => world.sheets.size).toBe(2);
  await expect(codeField(page)).toBeFocused();

  const guest = ticket(page).getByTestId('guest-name');
  await guest.click();
  await page.keyboard.type('Lan', { delay: 0 });
  // The paid number leaves the head of the ticket after 8 seconds.
  await expect(ticket(page).getByTestId('quick-done')).toHaveCount(0, { timeout: 12_000 });
  await expect(guest).toBeFocused();
  await expect(guest).toHaveValue('Lan');
});
