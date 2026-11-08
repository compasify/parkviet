import { expect, type Page, test } from '@playwright/test';
import { printLedger, receiptTemplateApi } from './support/receipt-templates';

// Printing a posted receipt by the store's templates against a mocked Admin
// API: the first print uses the chosen template, a reprint the template,
// version and paper of the original even after the template changed or was
// disabled, another template only when picked, and a template outage still
// prints with the built-in template. Presentation fixtures only.

type PrintSeen = {
  marker: string | null;
  sheet: string;
  printId: string | null;
  rules: string[];
  // Every sheet of the print, in page order.
  sheets: { printId: string | null; text: string }[];
};

const workspace = {
  id: 'ws_a',
  branch_id: 'br_1',
  register_id: 'reg_1',
  shift_id: 'sh_1',
  order_id: 'R300',
  revision: 1,
  lease_generation: 1,
  operational_status: 'editing',
  payments: false,
  line_items: [],
  customer: null,
  discount: null,
  totals: { item_total: '0.0', discount_total: '0.0', total: '0.0', currency: 'VND' },
  financial: { received: '0.0', allocated: '0.0', unapplied: '0.0', remaining: '0.0', change_due: '0.0', attempts: [] },
};

const document = {
  kind: 'sale',
  title: 'PHIẾU BÁN HÀNG',
  number: 'RD300',
  order_number: 'R300',
  store: { name: 'Park Việt' },
  branch: { name: 'Chi nhánh 1', code: 'cn1' },
  register: 'Quầy 1',
  timezone: 'Asia/Ho_Chi_Minh',
  at: '2026-11-08T03:00:00Z',
  currency: 'VND',
  cashier: 'Lan',
  lines: [{ name: 'Gạo ST25', quantity: 1, unit_price: '120000.0', amount: '120000.0', discount: '0.0', net_amount: '120000.0' }],
  totals: { item_total: '120000.0', discount_total: '0.0', included_tax_total: '0.0', additional_tax_total: '0.0', total: '120000.0' },
  receipts: [{ method: 'cash', amount: '120000.0' }],
  paid_total: '120000.0',
  credit: null,
};

async function install(page: Page, { copies }: { copies?: number } = {}) {
  const templates = receiptTemplateApi([
    { id: 'postpl_a', type: 'sale', name: 'Bán hàng K80', paper: '80mm', isDefault: true, footer: 'Mẫu A bản 1', copies },
    { id: 'postpl_b', type: 'sale', name: 'Bán hàng A4', paper: 'a4', footer: 'Mẫu B', marginMm: 10 },
  ]);
  const ledger = printLedger(templates, 'sale');
  const refused: Record<string, unknown>[] = [];
  const receipt = () => ({
    id: 'posreceipt_1',
    source_type: 'sale',
    number: 'RD300',
    branch_id: 'br_1',
    issued_at: '2026-11-08T03:00:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    ...ledger.receiptFields(),
    document,
  });

  await page.addInitScript(() => {
    // Kept across page loads: the counter reopens the receipt between prints.
    const seen: unknown[] = JSON.parse(sessionStorage.getItem('printed') ?? '[]');
    (window as unknown as { printed: unknown[] }).printed = seen;
    window.print = () => {
      const sheet = window.document.querySelector('[data-testid="receipt-print-sheet"]');
      const style = window.document.getElementById('pos-receipt-page-size') as HTMLStyleElement | null;
      seen.push({
        marker: window.document.documentElement.getAttribute('data-receipt-printing'),
        sheet: sheet?.textContent ?? '',
        printId: sheet?.getAttribute('data-print-id') ?? null,
        rules: [...(style?.sheet?.cssRules ?? [])].map((rule) => rule.cssText),
        sheets: [...window.document.querySelectorAll('[data-testid="receipt-print-sheet"]')].map((item) => ({
          printId: item.getAttribute('data-print-id'),
          text: item.textContent ?? '',
        })),
      });
      sessionStorage.setItem('printed', JSON.stringify(seen));
    };
  });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    if (path === '/auth/login' || path === '/auth/refresh') return route.fulfill({ json: { token: 'test-token' } });
    if (path === '/me') return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path === '/pos/context') {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Park Việt', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? ['pos.shift.open', 'pos.payment.collect'] : [],
          branches: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    if (path === '/pos/context/branches')
      return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path === '/pos/context/registers')
      return route.fulfill({
        json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } },
      });
    if (path === '/pos/workspaces' && method === 'GET')
      return route.fulfill({ json: { data: [workspace], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.startsWith('/pos/workspaces/ws_a')) return route.fulfill({ json: { data: workspace } });
    if (path === '/pos/command_receipts') return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
    if (await templates.handle(route, path, url, method)) return;
    if (path === '/pos/receipts/lookup' || (path === '/pos/receipts/posreceipt_1' && method === 'GET'))
      return route.fulfill({ json: { data: receipt() } });
    if (path === '/pos/receipts/posreceipt_1/prints' && method === 'POST') {
      const body = (request.postDataJSON() ?? {}) as Record<string, unknown>;
      const print = ledger.record(body);
      if (!print) {
        refused.push(body);
        return route.fulfill({
          status: 422,
          json: {
            error: {
              code: 'validation_error',
              message: 'This template is disabled.',
              details: {
                errors: [{ pointer: '/receipt_template_id', code: 'template_disabled', message: 'This template is disabled.' }],
              },
            },
          },
        });
      }
      return route.fulfill({ status: 201, json: { data: { print, receipt: receipt() } } });
    }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  return { templates, ledger, refused, receipt };
}

async function login(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function openReceipt(page: Page) {
  await page.goto('/receipts?source=posworkspace_done');
  await expect(page.getByTestId('receipt-sheet')).toContainText('RD300');
}

const printed = (page: Page) => page.evaluate(() => (window as unknown as { printed: PrintSeen[] }).printed);
const choice = (page: Page, name: string | RegExp) =>
  page.getByRole('radiogroup', { name: 'Mẫu in' }).getByRole('radio', { name });

test('a reprint keeps the original template version and paper; another template is used only when picked', async ({
  page,
}) => {
  const { templates, ledger } = await install(page);
  await login(page);
  await openReceipt(page);
  const sheet = page.getByTestId('receipt-sheet');
  await expect(choice(page, 'Bán hàng K80 · 80mm')).toBeChecked();
  await expect(choice(page, 'Bán hàng A4 · A4')).not.toBeChecked();
  await expect(sheet).toHaveAttribute('data-paper', '80mm');
  await expect(sheet).toContainText('Mẫu A bản 1');

  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  expect(ledger.prints[0].body).toMatchObject({ receipt_template_id: 'postpl_a', template_version: 1, paper: '80mm' });
  const [original] = await printed(page);
  expect(original).toMatchObject({ marker: '80mm', printId: 'posprint_1' });
  expect(original.sheet).toContain('Mẫu A bản 1');
  expect(original.sheet).not.toContain('BẢN SAO');
  expect(await page.evaluate(() => localStorage.getItem('parkviet-pos:receipt-template:sale'))).toBe('postpl_a');

  // Another device saves template A again; the counter opens the receipt later.
  templates.revise('postpl_a', 'Mẫu A bản 2');
  await openReceipt(page);
  await expect(choice(page, /Bán hàng K80 · 80mm · Mẫu của bản gốc/)).toBeChecked();
  await expect(sheet).toContainText('Mẫu A bản 1');
  await expect(sheet).not.toContainText('Mẫu A bản 2');
  await expect(sheet).toContainText('BẢN SAO – lần 1');
  await page.getByRole('button', { name: 'In lại (bản sao)' }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(2);
  const copy = (await printed(page))[1];
  expect(copy).toMatchObject({ marker: '80mm', printId: 'posprint_2' });
  expect(copy.sheet).toContain('BẢN SAO – lần 1');
  expect(copy.sheet).toContain('Mẫu A bản 1');
  expect(copy.sheet).not.toContain('Mẫu A bản 2');
  expect(ledger.prints[1]).toMatchObject({ template_id: 'postpl_a', template_version: 1, paper: '80mm' });

  // The original printed badly: this copy goes out on template B (A4).
  await choice(page, 'Bán hàng A4 · A4').check();
  await expect(sheet).toHaveAttribute('data-paper', 'a4');
  await expect(sheet).toContainText('Mẫu B');
  await page.getByRole('button', { name: 'In lại (bản sao)' }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(3);
  const onB = (await printed(page))[2];
  expect(onB).toMatchObject({ marker: 'a4', printId: 'posprint_3' });
  expect(onB.sheet).toContain('BẢN SAO – lần 2');
  expect(onB.sheet).toContain('Mẫu B');
  expect(onB.rules.join(' ')).toMatch(/size: A4/i);
  // The template's page margin is carried but not applied: A4 keeps its own.
  expect(onB.rules.join(' ')).toContain('margin: 12mm');
  expect(ledger.prints[2]).toMatchObject({ template_id: 'postpl_b', template_version: 1, paper: 'a4' });

  // The next reprint starts from the original's template again.
  await expect(choice(page, /Mẫu của bản gốc/)).toBeChecked();
  await expect(sheet).toHaveAttribute('data-paper', '80mm');
  await openReceipt(page);
  await expect(choice(page, /Bán hàng K80 · 80mm · Mẫu của bản gốc/)).toBeChecked();
  await expect(sheet).toContainText('BẢN SAO – lần 3');
  await expect(sheet).toContainText('Mẫu A bản 1');
  expect(new Set(ledger.prints.map((row) => row.body.idempotency_key)).size).toBe(3);
});

test('a receipt whose original template was disabled since still reprints with it', async ({ page }) => {
  const { templates, ledger } = await install(page);
  await login(page);
  await openReceipt(page);
  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(1);

  templates.revise('postpl_a', 'Mẫu A bản 2');
  templates.disable('postpl_a', 'postpl_b');
  await openReceipt(page);
  // Not listed any more: its name and old version are read from the server.
  await expect(choice(page, /Bán hàng K80 · 80mm · Mẫu của bản gốc/)).toBeChecked();
  await expect(page.getByTestId('receipt-sheet')).toContainText('Mẫu A bản 1');
  expect(templates.state.versionReads).toContain('postpl_a@1');
  await page.getByRole('button', { name: 'In lại (bản sao)' }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(2);
  const copy = (await printed(page))[1];
  expect(copy.marker).toBe('80mm');
  expect(copy.sheet).toContain('Mẫu A bản 1');
  expect(copy.sheet).toContain('BẢN SAO – lần 1');
  expect(ledger.prints[1]).toMatchObject({ template_id: 'postpl_a', template_version: 1 });
  await expect(page.getByTestId('receipt-template-fallback')).toHaveCount(0);
});

test('when templates cannot be loaded the receipt still prints with the built-in template', async ({ page }) => {
  const { templates, ledger } = await install(page);
  templates.state.failing = true;
  await login(page);
  await openReceipt(page);
  const sheet = page.getByTestId('receipt-sheet');
  await expect(page.getByTestId('receipt-template-fallback')).toContainText('mẫu dựng sẵn');
  await expect(page.getByRole('radiogroup', { name: 'Mẫu in' })).toHaveCount(0);
  await expect(sheet).toContainText('PHIẾU BÁN HÀNG');
  await expect(sheet).toHaveAttribute('data-paper', '80mm');

  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bản gốc' })).toBeVisible();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  // Nothing was asked for: the server recorded its default template.
  expect(ledger.prints[0].body).not.toHaveProperty('receipt_template_id');
  expect(ledger.prints[0]).toMatchObject({ template_id: 'postpl_a', paper: '80mm' });
  const [seen] = await printed(page);
  expect(seen.marker).toBe('80mm');
  expect(seen.sheet).toContain('PHIẾU BÁN HÀNG');
  expect(seen.sheet).toContain('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  expect(seen.sheet).not.toContain('Mẫu A');
  await expect(page.getByTestId('receipt-template-fallback')).toBeVisible();
});

test('a template disabled after the list loaded is refused once, then the print goes out on the server default', async ({
  page,
}) => {
  const { templates, ledger, refused } = await install(page);
  await login(page);
  await openReceipt(page);
  await choice(page, 'Bán hàng A4 · A4').check();
  await expect(page.getByTestId('receipt-sheet')).toContainText('Mẫu B');
  // Another device disables B; this counter still lists it.
  templates.disable('postpl_b');

  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bản gốc' })).toBeVisible();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  expect(refused).toEqual([expect.objectContaining({ receipt_template_id: 'postpl_b' })]);
  // Retried once without a layout, under a new key: one print recorded.
  expect(ledger.prints).toHaveLength(1);
  expect(ledger.prints[0].body).not.toHaveProperty('receipt_template_id');
  expect(ledger.prints[0].body.idempotency_key).not.toBe(refused[0].idempotency_key);
  expect(ledger.prints[0]).toMatchObject({ template_id: 'postpl_a', template_version: 1, paper: '80mm' });
  const [seen] = await printed(page);
  expect(seen.marker).toBe('80mm');
  expect(seen.sheet).toContain('Mẫu A bản 1');
  expect(seen.sheet).not.toContain('Mẫu B');
  await expect(page.getByRole('alert')).toHaveCount(0);
  // The refreshed list no longer offers B.
  await expect(choice(page, /Bán hàng A4/)).toHaveCount(0);
  await expect(choice(page, /Bán hàng K80 · 80mm · Mẫu của bản gốc/)).toBeChecked();
});

test('a sale template with two copies records the original and one copy with one press and prints both', async ({
  page,
}) => {
  const { ledger } = await install(page, { copies: 2 });
  await login(page);
  await openReceipt(page);
  await expect(page.getByTestId('receipt-copies-note')).toContainText('2 liên');

  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bản gốc và 1 bản sao.' })).toBeVisible();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  // Two recorded prints, one after the other, each under its own key and on the original's layout.
  expect(ledger.prints.map((row) => row.copy_number)).toEqual([0, 1]);
  expect(new Set(ledger.prints.map((row) => row.body.idempotency_key)).size).toBe(2);
  expect(ledger.prints[1].body).toMatchObject({ receipt_template_id: 'postpl_a', template_version: 1, paper: '80mm' });
  // One print dialog with the original and then the copy, each with its own label.
  const [seen] = await printed(page);
  expect(seen.marker).toBe('80mm');
  expect(seen.sheets.map((sheet) => sheet.printId)).toEqual(['posprint_1', 'posprint_2']);
  expect(seen.sheets[0].text).not.toContain('BẢN SAO');
  expect(seen.sheets[1].text).toContain('BẢN SAO – lần 1');
  expect(seen.sheets.every((sheet) => sheet.text.includes('Mẫu A bản 1'))).toBe(true);

  // A reprint is one more copy, not another set.
  await expect(page.getByTestId('receipt-copies-note')).toHaveCount(0);
  await page.getByRole('button', { name: 'In lại (bản sao)' }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(2);
  expect(ledger.prints).toHaveLength(3);
  const reprint = (await printed(page))[1];
  expect(reprint.sheets.map((sheet) => sheet.printId)).toEqual(['posprint_3']);
  expect(reprint.sheets[0].text).toContain('BẢN SAO – lần 2');
});

test('a copy that could not be recorded is never printed; the prints recorded before it are', async ({ page }) => {
  const { ledger } = await install(page, { copies: 3 });
  let calls = 0;
  await page.route('**/pos/receipts/posreceipt_1/prints', (route) => {
    calls += 1;
    if (calls === 2)
      return route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message: 'Receipt unavailable.', details: { reason: 'receipt_unavailable' } } },
      });
    return route.fallback();
  });
  await login(page);
  await openReceipt(page);
  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect(page.getByRole('alert')).toContainText('Chỉ ghi nhận được 1/3 liên');
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  // The copy that failed is not retried and the third is not asked for.
  expect(calls).toBe(2);
  expect(ledger.prints.map((row) => row.copy_number)).toEqual([0]);
  const [seen] = await printed(page);
  expect(seen.sheets.map((sheet) => sheet.printId)).toEqual(['posprint_1']);
  expect(seen.sheet).not.toContain('BẢN SAO');
});

test('a receipt read before its last print still prints one copy, never another set of copies', async ({ page }) => {
  const { ledger, receipt } = await install(page, { copies: 3 });
  // Printed on another device; this counter's read is from before that.
  ledger.record({});
  let lookups = 0;
  await page.route('**/pos/receipts/lookup?*', (route) => {
    lookups += 1;
    const stale = { ...receipt(), printed: false, copy_count: 0, original_print: null };
    return route.fulfill({ json: { data: lookups === 1 ? stale : receipt() } });
  });
  await login(page);
  await page.goto('/receipts?source=posworkspace_done');
  await expect(page.getByTestId('receipt-sheet')).toContainText('RD300');
  await page.getByRole('button', { name: /^In hóa đơn$|^In lại \(bản sao\)$/ }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  // The server recorded a copy, so no further copies were asked for.
  expect(ledger.prints.map((row) => row.copy_number)).toEqual([0, 1]);
  const [seen] = await printed(page);
  expect(seen.sheets.map((sheet) => sheet.printId)).toEqual(['posprint_2']);
  expect(seen.sheets[0].text).toContain('BẢN SAO – lần 1');
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bản sao' })).toBeVisible();
});

test('reopening the print popup after a print starts from the printed receipt', async ({ page }) => {
  const { ledger, receipt } = await install(page, { copies: 2 });
  // Only the first lookup answers; later ones never do, so only the cache
  // the print updated can know the receipt was printed.
  const first = receipt();
  let lookups = 0;
  await page.route('**/pos/receipts/lookup?*', async (route) => {
    lookups += 1;
    if (lookups > 1) await new Promise(() => {});
    return route.fulfill({ json: { data: first } });
  });
  await login(page);
  await page.goto('/receipts?source=posworkspace_done');
  await expect(page.getByTestId('receipt-sheet')).toContainText('RD300');
  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  expect(ledger.prints).toHaveLength(2);

  // Back on the same screen: the cached receipt is the printed one.
  await page.getByRole('link', { name: 'Về quầy' }).click();
  await page.goBack();
  await expect(page.getByRole('button', { name: 'In lại (bản sao)' })).toBeVisible();
  await expect(page.getByTestId('receipt-sheet')).toContainText('BẢN SAO – lần 2');
  await expect(page.getByTestId('receipt-copies-note')).toHaveCount(0);
  expect(lookups).toBe(2);
});
