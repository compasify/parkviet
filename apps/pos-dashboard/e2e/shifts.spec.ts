import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

const MANAGER = ['pos.topology.recover', 'pos.cash.move', 'pos.approval.grant', 'pos.payment.resolve'];
const count = (overrides: Record<string, unknown> = {}) => ({
  shift_id: 'shift_lan', revision: 3, status: 'open', counted: null, expected: null, variance: null,
  variance_threshold: '50000.0', requires_approval: null, stale: null, reason: null, counted_at: null,
  counted_by_id: null, approval: null, ...overrides,
});

async function install(page: Page, capabilities = MANAGER) {
  const state = {
    writes: [] as { path: string; body: Record<string, unknown> }[],
    requests: [
      { id: 'cmr_1', branch_id: 'branch_main', shift_id: 'shift_lan', kind: 'cash_out', status: 'requested', amount: '200000.0', currency: 'VND', reason: 'Trả tiền đá', evidence_reference: 'HD-12', requester_id: 'staff_lan', requester_name: 'Lan', confirmer_id: null, confirmer_name: null, cash_movement_id: null, resolution_note: null, created_at: '2026-11-10T03:00:00Z', resolved_at: null },
      { id: 'cmr_2', branch_id: 'branch_main', shift_id: 'shift_admin', kind: 'safe_drop', status: 'requested', amount: '1000000.0', currency: 'VND', reason: 'Nộp két sắt', evidence_reference: 'PN-1', requester_id: 'staff_admin', requester_name: 'Quản trị Hiền', confirmer_id: null, confirmer_name: null, cash_movement_id: null, resolution_note: null, created_at: '2026-11-10T03:10:00Z', resolved_at: null },
    ],
    pending: [
      { ...count({ shift_id: 'shift_minh', revision: 5, counted: '900000.0', expected: '1000000.0', variance: '-100000.0', requires_approval: true, reason: 'Thối nhầm', counted_at: '2026-11-10T09:00:00Z' }), register: 'Q2', owner_name: 'Minh', counted_by_name: 'Minh', opened_at: '2026-11-10T01:00:00Z', self_count: false, currency: 'VND' },
    ],
    count: count(),
    closure: null as Record<string, unknown> | null,
  };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', '');
    const write = () => state.writes.push({ path, body: request.method() === 'POST' ? request.postDataJSON() : {} });
    if (path === '/pos/context') return route.fulfill({ json: posContext(url, { capabilities }) });
    if (path === '/pos/cash_movement_requests') return route.fulfill({ json: { data: state.requests.filter((row) => row.status === 'requested') } });
    const decide = /^\/pos\/cash_movement_requests\/([^/]+)\/(confirm|cancel)$/.exec(path);
    if (decide) {
      write();
      const row = state.requests.find((item) => item.id === decide[1])!;
      row.status = decide[2] === 'confirm' ? 'confirmed' : 'canceled';
      return route.fulfill({ json: { data: row } });
    }
    if (path === '/pos/shift_closures/pending') return route.fulfill({ json: { data: state.pending } });
    if (path === '/pos/shifts/shift_minh/close_approval') {
      write();
      state.pending = [];
      return route.fulfill({ json: { data: count({ shift_id: 'shift_minh', revision: 5 }) } });
    }
    if (path === '/pos/shift_closures/open')
      return route.fulfill({ json: { data: state.closure ? [] : [{ id: 'shift_lan', branch_id: 'branch_main', register_id: 'reg_1', register: 'Q1', owner_id: 'staff_lan', owner_name: 'Lan', opening_float: '500000.0', currency: 'VND', opened_at: '2026-11-10T01:00:00Z', counted: false }] } });
    if (path === '/pos/shifts/shift_lan/closure')
      return route.fulfill({ json: { data: { shift: { id: 'shift_lan', branch_id: 'branch_main', register_id: 'reg_1', status: state.closure ? 'closed' : 'open', opening_float: '500000.0', currency: 'VND', owner_id: 'staff_lan', opened_at: '2026-11-10T01:00:00Z', closed_at: null, revision: state.count.revision, counted: Boolean(state.count.counted) }, checklist: { blocking: [], warnings: [] }, count: state.count, closure: state.closure, can_close: true, can_approve: true } } });
    if (path === '/pos/shifts/shift_lan/count') {
      write();
      state.count = count({ revision: 4, status: 'counted', counted: '1490000.0', expected: '1500000.0', variance: '-10000.0', requires_approval: false, stale: false, counted_at: '2026-11-10T10:00:00Z', counted_by_id: 'staff_admin' });
      return route.fulfill({ json: { data: state.count } });
    }
    if (path === '/pos/shifts/shift_lan/close') {
      write();
      state.closure = { id: 'closure_1', shift_id: 'shift_lan', branch_id: 'branch_main', register_id: 'reg_1', closer_id: 'staff_admin', closer_name: 'Quản trị Hiền', approver_id: null, approver_name: null, currency: 'VND', opening_float: '500000.0', inflow_total: '1000000.0', outflow_total: '0.0', expected: '1500000.0', counted: '1490000.0', variance: '-10000.0', variance_threshold: '50000.0', reason: null, cutoff_movement_id: null, movement_count: 3, breakdown: {}, reconciled: '0.0', opened_at: '2026-11-10T01:00:00Z', closed_at: '2026-11-10T10:01:00Z' };
      return route.fulfill({ json: { data: state.closure } });
    }
    if (path === '/pos/reports/closures')
      return route.fulfill({ json: { data: [{ closure_id: 'closure_0', shift_id: 'shift_lan', register: 'Q1', cashier: 'Lan', opened_at: '2026-11-10T08:00:00+07:00', closed_at: '2026-11-10T17:00:00+07:00', opening_float: '500000.0', expected: '1500000.0', counted: '1490000.0', variance: '-10000.0', reason: null, approver: null, reconciled: '0.0', currency: 'VND' }], meta: { page: 1, limit: 25, count: 1, pages: 1, from: '2026-11-10', to: '2026-11-10', timezone: 'Asia/Ho_Chi_Minh', summary: {} } } });
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}
const MENU = /^(Open actions|Mở menu thao tác)$/;
async function act(page: Page, section: string, row: string, item: string | RegExp) {
  await page.getByRole('region', { name: section }).getByRole('row').filter({ hasText: row }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: item }).click();
}

test('a manager confirms a colleague\'s drawer outflow and approves a variance', async ({ page }, testInfo) => {
  const state = await install(page);
  await page.goto('/store_1/shifts');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Quản lý ca & két');
  // The manager's own request is not theirs to confirm.
  await expect(page.getByRole('region', { name: 'Thu/chi két chờ xác nhận' }).getByText('Nộp két sắt', { exact: true })).toHaveCount(0);
  await page.screenshot({ path: testInfo.outputPath('shifts.png'), fullPage: true });

  await act(page, 'Thu/chi két chờ xác nhận', 'Lan', 'Xác nhận');
  await expect(page.getByRole('status').filter({ hasText: 'Đã xác nhận' })).toBeVisible();
  expect(state.writes.at(-1)?.path).toBe('/pos/cash_movement_requests/cmr_1/confirm');
  expect(typeof state.writes.at(-1)?.body.idempotency_key).toBe('string');

  await act(page, 'Duyệt chênh lệch đóng ca', 'Minh', 'Duyệt chênh lệch');
  await expect(page.getByRole('status').filter({ hasText: 'Đã duyệt chênh lệch đóng ca của Minh.' })).toBeVisible();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/shifts/shift_minh/close_approval', body: { revision: 5 } });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});

test('a manager closes a shift left open with a blind count', async ({ page }) => {
  const state = await install(page);
  await page.goto('/store_1/shifts');
  await act(page, 'Ca đang mở khác', 'Lan', 'Đóng ca của Lan');
  await page.getByRole('dialog').getByRole('button', { name: 'Đóng ca của Lan' }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toContainText('Không còn việc nào chặn đóng ca.');
  await dialog.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();
  // Expected cash is not shown before the count.
  await expect(dialog).not.toContainText('1.500.000');
  await dialog.getByLabel('Tổng tiền mặt đếm được').fill('1490000');
  await dialog.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/shifts/shift_lan/count', body: { counted: '1490000' } });
  await expect(dialog).toContainText('Thiếu');
  await dialog.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  await expect(dialog).toContainText('Đã đóng ca');
  expect(state.writes.at(-1)?.path).toBe('/pos/shifts/shift_lan/close');
});

test('closure history opens a closed shift snapshot', async ({ page }) => {
  const state = await install(page);
  state.closure = { id: 'closure_0', shift_id: 'shift_lan', branch_id: 'branch_main', register_id: 'reg_1', closer_id: 'staff_lan', closer_name: 'Lan', approver_id: null, approver_name: null, currency: 'VND', opening_float: '500000.0', inflow_total: '1000000.0', outflow_total: '0.0', expected: '1500000.0', counted: '1490000.0', variance: '-10000.0', variance_threshold: null, reason: null, cutoff_movement_id: null, movement_count: 2, breakdown: {}, reconciled: '0.0', opened_at: '2026-11-10T01:00:00Z', closed_at: '2026-11-10T10:00:00Z' };
  await page.goto('/store_1/shifts/closures');
  const row = page.getByRole('table').getByRole('row').filter({ hasText: 'Lan' });
  await expect(row).toContainText('Thiếu');
  await row.getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Xem biên bản đóng ca' }).click();
  await expect(page.getByRole('dialog')).toContainText('Đã đóng ca');
});

test('cashiers without management rights cannot open shift management', async ({ page }) => {
  await install(page, ['pos.shift.open', 'pos.payment.collect']);
  await page.goto('/store_1/shifts');
  await expect(page.getByRole('alert')).toContainText('Không có quyền truy cập');
});
