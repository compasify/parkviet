import { expect, type Page, type Route, test } from '@playwright/test';
import { addLine, addSheet, FULL_CASHIER, installRetailApi, login, newWorld, openTab, serialize, type Sheet, type World } from './support/retail-api';

// A canteen counter: the cashier types an employee code and Enter in the scan
// field, the meal is recorded and the eater shows on the order with the
// sponsor's and the eater's parts. One touch pays the eater's part from the
// wallet and completes the order, the sponsor's part going on its credit,
// and the bill prints. A second swipe of the same eater is refused with the
// duplicate tone. Limits, windows and the split are decided on the server.
// Presentation fixtures only: no real account privileges.

const SHEET = 'ws_meal';
const SPONSOR_PART = 25000;
const EATER_PART = 10000;

type MealApi = {
  lookups: string[];
  swipes: Record<string, unknown>[];
  walletPays: Record<string, unknown>[];
  completes: Record<string, unknown>[];
};

function canteenWorld(): { world: World; sheet: Sheet } {
  const world = newWorld({ capabilities: FULL_CASHIER, modules: { 'fnb.meal_accounts': true } });
  const sheet = addSheet(world, SHEET);
  // Seven bottles of water: 35.000 ₫, the meal's price.
  addLine(world, sheet, 'v_water', 7);
  return { world, sheet };
}

function account(balance: number) {
  return {
    id: 'posmeal_1', employee_code: 'NV001', name: 'Nguyễn An', phone: null, customer_id: 'poscustomer_meal',
    group_label: 'Kho', sponsor: { id: 'possponsor_1', name: 'Công ty A' }, pay_mode: 'sponsor_subsidy',
    daily_meal_limit: 2, meal_windows: [], low_balance_threshold: '50000.0', balance: `${balance}.0`,
    currency: 'VND', status: 'active', revision: 1, updated_at: '2026-11-12T03:00:00Z',
  };
}

const PLAN = {
  meal_account_id: 'posmeal_1', pay_mode: 'sponsor_subsidy', total: '35000.0', sponsor_id: 'possponsor_1',
  sponsor_name: 'Công ty A', sponsor_amount: `${SPONSOR_PART}.0`, employee_amount: `${EATER_PART}.0`,
  sponsor_unavailable: false,
};

// The meal endpoints, in front of the retail server: resolving a code,
// recording the meal (a second swipe is a duplicate), the wallet paying the
// eater's part and completing with the sponsor's part on credit.
async function installMealApi(page: Page, world: World, sheet: Sheet): Promise<MealApi> {
  const api: MealApi = { lookups: [], swipes: [], walletPays: [], completes: [] };
  let recorded = false;
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
      return reply(route, { match: q.toUpperCase() === 'NV001' ? account(balance) : null, suggestions: [] });
    }
    if (path === `/pos/workspaces/${SHEET}/meal`)
      return reply(route, { workspace_id: SHEET, meal: recorded ? status() : null, plan: recorded ? PLAN : null });
    if (path === `/pos/workspaces/${SHEET}/meal_swipes`) {
      api.swipes.push(body);
      if (recorded)
        return route.fulfill({
          status: 409,
          json: {
            error: {
              code: 'conflict', message: 'This meal was just recorded.',
              details: { reason: 'meal_duplicate_swipe', result: 'duplicate', meal: status() },
            },
          },
        });
      recorded = true;
      sheet.customer = { id: 'poscustomer_meal', name: 'Nguyễn An', phone: '0901000001' };
      sheet.revision += 1;
      return reply(route, { result: 'ok', reason: null, meal: status(), workspace: serialize(world, sheet) }, 201);
    }
    if (path === `/pos/workspaces/${SHEET}/meal_wallet`) {
      api.walletPays.push(body);
      balance -= EATER_PART;
      sheet.allocated += EATER_PART;
      sheet.revision += 1;
      return reply(route, { workspace: serialize(world, sheet), meal: status() });
    }
    if (path === `/pos/workspaces/${SHEET}/complete` && body.meal_sponsor === true) {
      api.completes.push(body);
      const remaining = 7 * 5000 - sheet.allocated;
      if (remaining !== SPONSOR_PART)
        return route.fulfill({
          status: 409,
          json: { error: { code: 'conflict', message: 'Unpaid.', details: { reason: 'meal_split_unpaid' } } },
        });
      sheet.status = 'completed';
      sheet.orderId = `or_${SHEET}`;
      sheet.revision += 1;
      return reply(route, serialize(world, sheet));
    }
    return route.fallback();
  });
  return api;
}

// The sale receipt for the print popup, and a browser print that records itself.
async function mockSaleReceipt(page: Page) {
  const receipt = {
    id: 'posreceipt_meal', source_type: 'sale', number: 'HD-0042', branch_id: 'br_1',
    issued_at: '2026-11-12T04:00:00Z', issued_late: false, disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: false, copy_count: 0,
    document: { title: 'PHIẾU BÁN HÀNG', currency: 'VND', lines: [], totals: { item_total: '35000', total: '35000' } },
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

async function swipe(page: Page, code: string) {
  const field = page.getByLabel('Mã nhân viên / tên');
  await field.fill(code);
  await field.press('Enter');
}

test('an employee code and Enter records the meal, and one touch pays the wallet, completes and prints the bill', async ({ page }) => {
  const { world, sheet } = canteenWorld();
  await installRetailApi(page, world);
  const api = await installMealApi(page, world, sheet);
  await mockSaleReceipt(page);
  await recordTones(page);
  await login(page);
  await openTab(page, SHEET);

  await swipe(page, 'nv001');
  const banner = page.getByTestId('meal-banner');
  await expect(banner).toContainText('Nguyễn An');
  await expect(banner).toContainText('NV001 · Kho');
  await expect(banner).toContainText('120.000');
  await expect(banner).toContainText('Công ty A trả');
  await expect(banner).toContainText('25.000');
  await expect(banner).toContainText('10.000');
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi suất cho Nguyễn An.' })).toBeVisible();
  expect(api.lookups).toEqual(['nv001']);
  expect(api.swipes).toHaveLength(1);
  expect(api.swipes[0]).toMatchObject({ code: 'nv001', input_method: 'code' });
  expect(api.swipes[0]).toHaveProperty('idempotency_key');
  await expect.poll(() => tones(page)).toEqual(['ok']);

  // The cashier takes only the eater's part with ordinary tenders.
  await expect(page.locator('.payment-panel .payment-method-row input').first()).toHaveAttribute('placeholder', '10000');

  await banner.getByRole('button', { name: /Trả 10\.000 ₫ bằng ví và hoàn tất/ }).click();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  expect(api.walletPays).toHaveLength(1);
  expect(api.walletPays[0]).not.toHaveProperty('amount');
  expect(api.completes).toHaveLength(1);
  expect(api.completes[0]).toMatchObject({ meal_sponsor: true });
  expect(sheet.allocated).toBe(EATER_PART);

  const receiptDialog = page.getByRole('dialog');
  await expect(receiptDialog).toContainText('HD-0042');
  await expect.poll(() => receiptPrints(page)).toEqual(['posprint_1']);
});

test('a second swipe of the same eater is refused with the duplicate tone', async ({ page }) => {
  const { world, sheet } = canteenWorld();
  await installRetailApi(page, world);
  const api = await installMealApi(page, world, sheet);
  await recordTones(page);
  await login(page);
  await openTab(page, SHEET);

  await swipe(page, 'NV001');
  await expect(page.getByTestId('meal-banner')).toContainText('Nguyễn An');
  await swipe(page, 'NV001');

  await expect(page.getByRole('alert').filter({ hasText: 'Người này vừa được ghi suất. Không ghi trùng.' })).toBeVisible();
  expect(api.swipes).toHaveLength(2);
  await expect.poll(() => tones(page)).toEqual(['ok', 'duplicate']);
  await expect(page.locator('.meal-scan-feedback')).toHaveAttribute('data-tone', 'duplicate');
});
