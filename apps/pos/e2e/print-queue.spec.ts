import { expect, type Page, test } from '@playwright/test';
import { printLedger, receiptTemplateApi } from './support/receipt-templates';

// Routing a receipt to a print station or a LAN printer, and the cashier's
// print queue, against a mocked Admin API. Presentation fixtures only.

const workspace = {
  id: 'ws_a', branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', order_id: 'R300', revision: 1, lease_generation: 1,
  operational_status: 'editing', payments: false, line_items: [], customer: null, discount: null,
  totals: { item_total: '0.0', discount_total: '0.0', total: '0.0', currency: 'VND' },
  financial: { received: '0.0', allocated: '0.0', unapplied: '0.0', remaining: '0.0', change_due: '0.0', attempts: [] },
};
const document = {
  kind: 'sale', title: 'PHIẾU BÁN HÀNG', number: 'RD300', order_number: 'R300', store: { name: 'Park Việt' }, branch: { name: 'Chi nhánh 1', code: 'cn1' },
  register: 'Quầy 1', timezone: 'Asia/Ho_Chi_Minh', at: '2026-11-08T03:00:00Z', currency: 'VND', cashier: 'Lan',
  lines: [{ name: 'Gạo <ST25>', quantity: 1, unit_price: '120000.0', amount: '120000.0', discount: '0.0', net_amount: '120000.0' }],
  totals: { item_total: '120000.0', discount_total: '0.0', included_tax_total: '0.0', additional_tax_total: '0.0', total: '120000.0' },
  receipts: [{ method: 'cash', amount: '120000.0' }], paid_total: '120000.0', credit: null,
};
const station = { id: 'posprinter_s', branch_id: 'br_1', name: 'Trạm quầy', connection: 'sunmi_builtin', address: null, bluetooth_id: null, paper: '58mm', command_language: 'escpos', roles: ['receipt'], print_station_device_id: 'posdevice_1', register_id: null, status: 'active', settings: {} };
const epson = { ...station, id: 'posprinter_e', name: 'Epson quầy', connection: 'epson_epos', address: 'printer.test:8008', print_station_device_id: null };

type Job = Record<string, unknown> & { id: string };
const job = (over: Partial<Job> = {}): Job => ({ id: 'posprintjob_1', branch_id: 'br_1', printer_id: station.id, printer_name: station.name, kind: 'receipt', status: 'failed', attempts: 5, label: 'RD300', last_error: 'paper_out', copy_of_id: null, created_at: '2026-11-08T03:00:00Z', printed_at: null, workspace_id: null, source_revision: null, printer_available: true, reprinted: false, ...over });

async function install(page: Page, printers: unknown[], jobs: Job[] = [], prebills: Job[] = []) {
  const templates = receiptTemplateApi([{ id: 'postpl_a', type: 'sale', name: 'Bán hàng K80', paper: '80mm', isDefault: true }]);
  const ledger = printLedger(templates, 'sale');
  const state = { queued: [] as Record<string, unknown>[], prints: 0, voided: [] as string[], actions: [] as { path: string; body: Record<string, unknown> }[], approvals: [] as Record<string, unknown>[], jobPages: [] as (string | null)[], printBodies: [] as Record<string, unknown>[], voidBodies: [] as Record<string, unknown>[] };
  const receipt = () => ({ id: 'posreceipt_1', source_type: 'sale', number: 'RD300', branch_id: 'br_1', register_id: 'reg_1', issued_at: '2026-11-08T03:00:00Z', issued_late: false, disclaimer: 'Phiếu bán hàng POS', ...ledger.receiptFields(), document });
  await page.addInitScript(() => {
    (window as unknown as { dialogs: number }).dialogs = 0;
    window.print = () => { (window as unknown as { dialogs: number }).dialogs += 1; };
  });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace(/^.*\/api\/v3\/admin/, ''); const method = request.method();
    const body = (method === 'GET' ? {} : (request.postDataJSON() ?? {})) as Record<string, unknown>;
    if (path === '/auth/login' || path === '/auth/refresh') return route.fulfill({ json: { token: 'test-token' } });
    if (path === '/me') return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path === '/pos/context') {
      const branch = url.searchParams.get('branch_id'); const register = url.searchParams.get('register_id');
      return route.fulfill({ json: { staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' }, store: { id: 'store_1', name: 'Park Việt', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' }, capabilities: branch ? ['pos.shift.open', 'pos.payment.collect'] : [], branches: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }], registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [], shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null, selection: { branch_id: branch, register_id: register } } });
    }
    if (path === '/pos/context/branches') return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path === '/pos/context/registers') return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path === '/pos/workspaces' && method === 'GET') return route.fulfill({ json: { data: [workspace], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.startsWith('/pos/workspaces/ws_a')) return route.fulfill({ json: { data: workspace } });
    if (path === '/pos/command_receipts') return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
    if (await templates.handle(route, path, url, method)) return;
    if (path === '/pos/printers') return route.fulfill({ json: { data: printers } });
    if (path === '/pos/print_jobs/prebills') return route.fulfill({ json: { data: prebills, meta: { page: 1, pages: 1, count: prebills.length, next: null } } });
    if (path === '/pos/approvals' && method === 'POST') {
      state.approvals.push(body);
      for (const row of prebills) row.reprint = { ...(row.reprint as object), approval_id: 'posapproval_1', can_approve: false };
      return route.fulfill({ status: 201, json: { data: { id: 'posapproval_1' } } });
    }
    if (path === '/pos/print_jobs' && method === 'GET') {
      // One job per page, so reading only the first page would lose the rest.
      const number = Number(url.searchParams.get('page') ?? '1');
      state.jobPages.push(url.searchParams.get('page'));
      return route.fulfill({ json: { data: jobs.slice(number - 1, number), meta: { page: number, pages: jobs.length, count: jobs.length, next: number < jobs.length ? number + 1 : null } } });
    }
    if (path === '/pos/print_jobs' && method === 'POST') {
      state.queued.push(body);
      const print = ledger.record(body);
      return route.fulfill({ status: 201, json: { data: { print_job: job({ status: 'queued', attempts: 0 }), print, receipt: receipt() } } });
    }
    if (path.endsWith('/reprint')) {
      state.actions.push({ path, body });
      return route.fulfill({ status: 201, json: { data: { print_job: job({ id: 'posprintjob_2', status: 'queued' }) } } });
    }
    if (path.endsWith('/cancel')) { state.actions.push({ path, body }); jobs.splice(0, jobs.length); return route.fulfill({ json: { data: job({ status: 'canceled' }) } }); }
    if (path === '/pos/receipts/lookup' || (path === '/pos/receipts/posreceipt_1' && method === 'GET')) return route.fulfill({ json: { data: receipt() } });
    if (path === '/pos/receipts/posreceipt_1/prints' && method === 'POST') { state.prints += 1; state.printBodies.push(body); return route.fulfill({ status: 201, json: { data: { print: ledger.record(body), receipt: receipt() } } }); }
    if (/\/prints\/[^/]+\/void$/.test(path)) { state.voided.push(path); state.voidBodies.push(body); return route.fulfill({ json: { data: { print: {}, receipt: { ...receipt(), printed: false, copy_count: 0 } } } }); }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  return state;
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
const dialogs = (page: Page) => page.evaluate(() => (window as unknown as { dialogs: number }).dialogs);
const printButton = (page: Page) => page.getByRole('button', { name: 'In hóa đơn', exact: true });

test('a receipt for a print station is queued and opens no print dialog', async ({ page }) => {
  const state = await install(page, [station]);
  await login(page); await openReceipt(page);
  await printButton(page).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã gửi tới máy in Trạm quầy.' })).toBeVisible();
  expect(state.queued[0]).toMatchObject({ kind: 'receipt', printer_id: station.id, receipt_id: 'posreceipt_1' });
  expect(state.prints).toBe(0);
  expect(await dialogs(page)).toBe(0);
});

test('a LAN printer that answers prints without the dialog, and what it receives is escaped', async ({ page }) => {
  const state = await install(page, [epson]);
  let sent = '';
  await page.route('http://printer.test:8008/**', async (route) => {
    sent = route.request().postData() ?? '';
    await route.fulfill({ body: '<response success="true" code="" status="1"/>', headers: { 'access-control-allow-origin': '*' } });
  });
  await login(page); await openReceipt(page);
  await printButton(page).click();
  await expect.poll(() => sent).toContain('Gạo &lt;ST25&gt;');
  expect(state.voided).toEqual([]);
  expect(await dialogs(page)).toBe(0);
});

test('a refused LAN print gives the number back and offers the browser', async ({ page }) => {
  const state = await install(page, [epson]);
  await page.route('http://printer.test:8008/**', (route) => route.fulfill({ body: '<response success="false" code="EPTR_REC_EMPTY"/>', headers: { 'access-control-allow-origin': '*' } }));
  await login(page); await openReceipt(page);
  await printButton(page).click();
  await expect(page.getByRole('alert').filter({ hasText: 'Máy in Epson quầy báo lỗi' })).toBeVisible();
  expect(state.voided).toHaveLength(1);
  await page.getByRole('button', { name: 'In bằng trình duyệt' }).click();
  await expect.poll(() => dialogs(page)).toBe(1);
});

test('the queue shows a failed job and can reprint or cancel it', async ({ page }) => {
  const state = await install(page, [station], [job()]);
  await login(page); await openReceipt(page);
  const row = page.getByTestId('print-job');
  await expect(row).toContainText('paper_out');
  await row.getByRole('button', { name: 'In lại' }).click();
  await expect.poll(() => state.actions.length).toBe(1);
  await row.getByRole('button', { name: 'Hủy' }).click();
  await expect(row).toHaveCount(0);
});

const printedPrebill = (reprint: Record<string, unknown>) => job({ id: 'posprintjob_p', kind: 'prebill', status: 'printed', label: 'PHIẾU TẠM TÍNH', attempts: 1, last_error: null, workspace_id: 'ws_a', source_revision: 4, reprint: { workspace_revision: 5, approval_id: null, requester_id: null, can_approve: false, ...reprint } });

test('a printed pre-bill needs a manager, and a cashier cannot reprint it alone', async ({ page }) => {
  const state = await install(page, [station], [], [printedPrebill({})]);
  await login(page); await openReceipt(page);
  const row = page.getByTestId('printed-prebill');
  await expect(row.getByTestId('prebill-needs-approval')).toHaveText('Cần quản lý duyệt');
  await expect(row.getByRole('button', { name: 'In lại' })).toHaveCount(0);
  await expect(row.getByRole('button', { name: 'Duyệt in lại' })).toHaveCount(0);
  expect(state.approvals).toEqual([]);
});

test('a manager grants the reprint for the current revision, and the holder spends it', async ({ page }) => {
  const state = await install(page, [station], [], [printedPrebill({ requester_id: 'stf_cashier', can_approve: true })]);
  await login(page); await openReceipt(page);
  const row = page.getByTestId('printed-prebill');
  await row.getByRole('button', { name: 'Duyệt in lại' }).click();
  await expect.poll(() => state.approvals.length).toBe(1);
  expect(state.approvals[0]).toMatchObject({ branch_id: 'br_1', workspace_id: 'ws_a', requester_id: 'stf_cashier', revision: 5, action_name: 'workspace.reprint_prebill' });
  await row.getByRole('button', { name: 'In lại' }).click();
  await expect.poll(() => state.actions.at(-1)?.body.approval_id).toBe('posapproval_1');
  expect(state.actions.at(-1)?.path).toBe('/pos/print_jobs/posprintjob_p/reprint');
});

test('a failed pre-bill offers no reprint without an approval', async ({ page }) => {
  await install(page, [station], [job({ kind: 'prebill', label: 'PHIẾU TẠM TÍNH', workspace_id: 'ws_a', source_revision: 4, reprint: { workspace_revision: 4, approval_id: null, requester_id: null, can_approve: false } })]);
  await login(page); await openReceipt(page);
  const row = page.getByTestId('print-job');
  await expect(row.getByTestId('prebill-needs-approval')).toBeVisible();
  await expect(row.getByRole('button', { name: 'In lại' })).toHaveCount(0);
  await expect(row.getByRole('button', { name: 'Hủy' })).toBeVisible();
});

test('a dropped connection keeps the number, since the printer may have printed', async ({ page }) => {
  const state = await install(page, [epson]);
  await page.route('http://printer.test:8008/**', (route) => route.abort('connectionreset'));
  await login(page); await openReceipt(page);
  await printButton(page).click();
  await expect(page.getByRole('button', { name: 'In bằng trình duyệt' })).toBeVisible();
  expect(state.voided).toEqual([]);
  expect(state.prints).toBeGreaterThan(0);
});

test('a LAN print names its printer, and a refusal says why it is taken back', async ({ page }) => {
  const state = await install(page, [epson]);
  await page.route('http://printer.test:8008/**', (route) => route.fulfill({ body: '<response success="false" code="EPTR_REC_EMPTY"/>', headers: { 'access-control-allow-origin': '*' } }));
  await login(page); await openReceipt(page);
  await printButton(page).click();
  await expect.poll(() => state.voidBodies.length).toBe(1);
  expect(state.voidBodies[0]).toMatchObject({ reason: 'printer_error' });
  expect(state.printBodies[0]).toMatchObject({ printer_id: epson.id });
});

test('a failure on a later page is still shown', async ({ page }) => {
  const state = await install(page, [station], [job({ id: 'posprintjob_new', status: 'queued', attempts: 0, last_error: null }), job({ id: 'posprintjob_old', last_error: 'old_failure' })]);
  await login(page); await openReceipt(page);
  await expect(page.getByTestId('print-job').filter({ hasText: 'old_failure' })).toBeVisible();
  expect(state.jobPages).toContain('2');
});

test('a failed job already reprinted leaves the queue and the alert', async ({ page }) => {
  await install(page, [station], [job({ reprinted: true })]);
  await login(page);
  await expect(page.getByRole('tab').first()).toBeVisible();
  await expect(page.getByTestId('print-queue-alert')).toHaveCount(0);
  await openReceipt(page);
  await expect(page.getByTestId('print-job')).toHaveCount(0);
});

test('the sale screen says when a job is stuck on an unavailable printer', async ({ page }) => {
  await install(page, [station], [job({ status: 'queued', attempts: 0, last_error: null, printer_available: false })]);
  await login(page);
  await expect(page.getByTestId('print-queue-alert')).toContainText('Có 1 phiếu kẹt');
  await openReceipt(page);
  await expect(page.getByTestId('print-job')).toContainText('sẽ không được in');
});

test('the sale screen says when a job failed', async ({ page }) => {
  await install(page, [station], [job()]);
  await login(page);
  await expect(page.getByTestId('print-queue-alert')).toContainText('Có 1 phiếu in lỗi.');
});
