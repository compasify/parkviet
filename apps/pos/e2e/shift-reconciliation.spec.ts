import { expect, type Page, test } from '@playwright/test';

// Mocked POS API for shift close, drawer movements, late-cash reconciliation,
// variance approvals and reports. It enforces the rules the client must not
// bypass (blind count, approval before close) and records request bodies.

const workspace = {
  id: 'ws_1',
  branch_id: 'br_1',
  register_id: 'reg_1',
  shift_id: 'sh_1',
  order_id: 'R500',
  revision: 1,
  lease_generation: 1,
  operational_status: 'editing',
  payments: false,
  line_items: [],
  customer: null,
  discount: null,
  totals: {
    item_total: '0.0',
    discount_total: '0.0',
    manual_discount_total: '0.0',
    included_tax_total: '0.0',
    additional_tax_total: '0.0',
    total: '0.0',
    currency: 'VND',
  },
  financial: {
    received: '0.0',
    allocated: '0.0',
    unapplied: '0.0',
    remaining: '0.0',
    change_due: '0.0',
    attempts: [],
    credit: null,
  },
};


type Options = { capabilities: string[]; blocked?: boolean; loseFirstCount?: boolean };

async function mockPos(page: Page, options: Options) {
  const writes: Array<{ path: string; body: Record<string, unknown>; key: string }> = [];
  // Committed results by idempotency key, as the server's command receipts.
  const receipts = new Map<string, unknown>();
  const receiptLookups: string[] = [];
  let blocked = options.blocked ?? false;
  let loseCount = options.loseFirstCount ?? false;
  let counted: string | null = null;
  let reason: string | null = null;
  let revision = 1;
  let approved = false;
  let closed = false;
  const expected = '100000.0';
  const shift = {
    id: 'sh_1',
    branch_id: 'br_1',
    register_id: 'reg_1',
    status: 'open',
    opening_float: '50000.0',
    currency: 'VND',
    owner_id: 'stf_1',
    opened_at: '2026-11-07T01:00:00Z',
    reports: false,
  };
  const requests: Array<Record<string, unknown>> = [
    {
      id: 'poscashreq_7', branch_id: 'br_1', shift_id: 'sh_7', kind: 'safe_drop', status: 'requested', amount: '200000.0',
      currency: 'VND', reason: 'Nộp két giữa ca', evidence_reference: 'TUI-9', requester_id: 'stf_3', requester_name: 'Mai',
      confirmer_id: null, confirmer_name: null, cash_movement_id: null, resolution_note: null,
      created_at: '2026-11-07T03:00:00Z', resolved_at: null,
    },
  ];
  const count = () => {
    const base = {
      shift_id: 'sh_1', branch_id: 'br_1', currency: 'VND', revision, status: closed ? 'closed' : 'open', counted,
      variance_threshold: null, reason, counted_at: counted ? '2026-11-07T10:00:00Z' : null,
      counted_by_id: counted ? 'stf_1' : null,
    };
    if (!counted) return { ...base, expected: null, variance: null, requires_approval: null, stale: null, approval: null };
    const variance = `${Number(counted) - Number(expected)}.0`;
    return {
      ...base,
      expected,
      variance,
      stale: false,
      requires_approval: variance !== '0.0',
      approval: approved
        ? { id: 'posapproval_9', approver_id: 'stf_2', approver_name: 'Quản lý Hà', amount: variance, expires_at: '2099-01-01T00:00:00Z' }
        : null,
    };
  };
  const closure = () => ({
    id: 'posclosure_1', shift_id: 'sh_1', branch_id: 'br_1', register_id: 'reg_1', closer_id: 'stf_1', closer_name: 'Lan',
    approver_id: 'stf_2', approver_name: 'Quản lý Hà', currency: 'VND', opening_float: '50000.0', inflow_total: '80000.0',
    outflow_total: '30000.0', expected, counted, variance: count().variance, variance_threshold: null, reason,
    cutoff_movement_id: 'poscashmv_3', movement_count: 3, breakdown: {}, reconciled: '0.0', opened_at: shift.opened_at,
    closed_at: '2026-11-07T10:05:00Z',
  });
  const conflict = (reasonCode: string, extra: Record<string, unknown> = {}) => ({
    status: 409,
    json: { error: { code: 'conflict', message: reasonCode, details: { reason: reasonCode, ...extra } } },
  });
  const checklist = () =>
    blocked
      ? {
          blocking: [
            { type: 'tender_attempt', id: 'ten_1', workspace_id: 'ws_1', order_number: 'R500', status: 'prepared', amount: '20000.0', kind: 'bank_manual' },
          ],
          warnings: [{ type: 'draft', workspace_id: 'ws_2', order_number: 'R501', status: 'parked' }],
        }
      : { blocking: [], warnings: [] };
  const exportsList = () =>
    writes.some((write) => write.path === '/pos/exports')
      ? [
          { id: 'posexport_1', branch_id: 'br_1', report_type: 'sales', filters: { from: '2026-11-07', to: '2026-11-07' },
            status: 'ready', row_count: 1, error_message: null, expires_at: '2099-01-01T00:00:00Z',
            completed_at: '2026-11-07T10:00:01Z', created_at: '2026-11-07T10:00:00Z' },
          { id: 'posexport_2', branch_id: 'br_1', report_type: 'closures', filters: { from: '2026-11-01', to: '2026-11-01' },
            status: 'ready', row_count: 3, error_message: null, expires_at: '2099-01-01T00:00:00Z',
            completed_at: '2026-11-01T10:00:01Z', created_at: '2026-11-01T10:00:00Z' },
          { id: 'posexport_3', branch_id: 'br_1', report_type: 'cashbook', filters: { from: '2026-10-01', to: '2026-10-01' },
            status: 'expired', row_count: 2, error_message: null, expires_at: '2026-10-02T10:00:00Z',
            completed_at: '2026-10-01T10:00:01Z', created_at: '2026-10-01T10:00:00Z' },
        ]
      : [];

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const body = method === 'POST' ? ((request.postDataJSON() as Record<string, unknown>) ?? {}) : {};
    const key = (await request.headerValue('idempotency-key')) ?? '';
    if (method === 'POST') writes.push({ path: path.replace(/^.*\/pos/, '/pos'), body, key });
    const ok = (data: unknown, status = 200) => {
      if (key) receipts.set(key, data);
      return route.fulfill({ status, json: { data } });
    };
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context/branches'))
      return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers'))
      return route.fulfill({
        json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } },
      });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? options.capabilities : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active', timezone: 'Asia/Ho_Chi_Minh' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
          shift: register && !closed ? shift : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET')
      return route.fulfill({ json: { data: [workspace], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/workspaces/ws_1')) return route.fulfill({ json: { data: workspace } });
    if (path.endsWith('/pos/received_funds')) return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/command_receipts')) {
      const lookup = url.searchParams.get('idempotency_key') ?? '';
      receiptLookups.push(lookup);
      return receipts.has(lookup)
        ? route.fulfill({ json: { data: receipts.get(lookup) } })
        : route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'missing' } } });
    }

    if (path.endsWith('/pos/shifts/sh_1/closure'))
      return route.fulfill({
        json: {
          data: {
            shift: { ...shift, status: closed ? 'closed' : 'open', closed_at: null, revision, counted: Boolean(counted) },
            checklist: closed ? { blocking: [], warnings: [] } : checklist(),
            count: count(),
            closure: closed ? closure() : null,
            can_close: !closed,
            can_approve: false,
          },
        },
      });
    if (path.endsWith('/pos/shifts/sh_1/cash_movements') && method === 'GET')
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/shifts/sh_1/cash_movements') && method === 'POST') {
      if (body.kind === 'cash_in')
        return ok({ id: 'poscashmv_9', branch_id: 'br_1', shift_id: 'sh_1', kind: 'cash_in', category: 'cash_in',
                    amount: `${body.amount}.0`, currency: 'VND', reason: body.reason, evidence_reference: null,
                    created_at: '2026-11-07T09:00:00Z', status: 'posted' }, 201);
      if (!body.evidence_reference) return route.fulfill(conflict('evidence_required'));
      const created = {
        id: 'poscashreq_1', branch_id: 'br_1', shift_id: 'sh_1', kind: body.kind, status: 'requested', amount: `${body.amount}.0`,
        currency: 'VND', reason: body.reason, evidence_reference: body.evidence_reference, requester_id: 'stf_1',
        requester_name: 'Lan', confirmer_id: null, confirmer_name: null, cash_movement_id: null, resolution_note: null,
        created_at: '2026-11-07T09:00:00Z', resolved_at: null,
      };
      requests.push(created);
      return ok(created, 201);
    }
    if (path.endsWith('/pos/cash_movement_requests') && method === 'GET') {
      const shiftId = url.searchParams.get('shift_id');
      const pendingOnly = url.searchParams.get('status') === 'requested';
      const rows = requests.filter(
        (row) => (!shiftId || row.shift_id === shiftId) && (!pendingOnly || row.status === 'requested'),
      );
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    const decision = /\/pos\/cash_movement_requests\/([^/]+)\/(confirm|cancel)$/.exec(path);
    if (decision) {
      const row = requests.find((item) => item.id === decision[1]);
      if (!row) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
      Object.assign(row, decision[2] === 'confirm'
        ? { status: 'confirmed', confirmer_id: 'stf_1', confirmer_name: 'Lan', cash_movement_id: 'poscashmv_77' }
        : { status: 'canceled', resolution_note: body.note });
      return ok(row);
    }
    if (path.endsWith('/pos/shifts/sh_1/count')) {
      if (blocked) return route.fulfill(conflict('close_blocked', { checklist: checklist() }));
      // A replayed key returns its first result, like the server's command receipt.
      if (receipts.has(key)) {
        if (loseCount) return route.abort('failed');
        return route.fulfill({ json: { data: receipts.get(key) } });
      }
      counted = `${body.counted}.0`;
      reason = typeof body.reason === 'string' ? body.reason : null;
      revision += 1;
      approved = false;
      receipts.set(key, count());
      // The server commits but the response never arrives while the network is down.
      if (loseCount) return route.abort('failed');
      return route.fulfill({ json: { data: count() } });
    }
    if (path.endsWith('/pos/shifts/sh_1/close')) {
      if (!counted) return route.fulfill(conflict('count_required'));
      if (count().requires_approval && !approved) return route.fulfill(conflict('approval_required'));
      closed = true;
      return ok(closure(), 201);
    }
    if (path.endsWith('/pos/shift_closures/pending'))
      return route.fulfill({
        json: {
          data: [
            {
              ...count(), shift_id: 'sh_7', revision: 4, counted: '90000.0', expected: '100000.0', variance: '-10000.0',
              requires_approval: true, stale: false, reason: 'Thối nhầm', approval: approved ? count().approval : null,
              register: 'Q1', owner_name: 'Mai', counted_by_name: 'Mai', opened_at: '2026-11-07T01:00:00Z', self_count: false,
            },
            {
              ...count(), shift_id: 'sh_8', revision: 2, counted: '80000.0', expected: '100000.0', variance: '-20000.0',
              requires_approval: true, stale: false, reason: null, approval: null,
              register: 'Q2', owner_name: 'Tú', counted_by_name: 'Tú', opened_at: '2026-11-07T01:00:00Z', self_count: false,
            },
          ],
        },
      });
    if (path.endsWith('/pos/shifts/sh_7/close_approval')) {
      approved = true;
      return ok(count(), 201);
    }
    if (path.endsWith('/pos/shift_closures/open')) return route.fulfill({ json: { data: [], meta: { count: 0 } } });
    if (path.endsWith('/pos/cash_reconciliations/candidates'))
      return route.fulfill({
        json: {
          data: {
            closures: [
              { id: 'posclosure_s1', shift_id: 'sh_s1', register: 'Q1', owner_name: 'Mai', closed_at: '2026-11-06T14:00:00Z',
                counted: '100000.0', expected: '0.0', variance: '100000.0', unexplained: '100000.0', currency: 'VND' },
            ],
            held_funds: [
              { id: 'posfunds_held', shift_id: 'sh_s1', amount: '100000.0', currency: 'VND', custody_note: 'Khách trả muộn',
                received_at: '2026-11-06T13:30:00Z', booked_at: '2026-11-07T02:00:00Z', recorded_by: 'Hà', recorded_by_me: false,
                shift_owner_name: 'Mai', shift_status: 'closed', shift_opened_at: '2026-11-06T01:00:00Z',
                shift_closed_at: '2026-11-06T14:00:00Z', closure_id: 'posclosure_s1', closure_counted: '100000.0',
                closure_expected: '0.0', closure_unexplained: '100000.0', overage_explained: false },
            ],
            shifts: [
              { id: 'sh_s2', status: 'open', register: 'Q1', owner_name: 'Mai', opening_float: '100000.0',
                opened_at: '2026-11-07T01:00:00Z', closed_at: null },
            ],
          },
        },
      });
    if (path.endsWith('/pos/cash_reconciliations') && method === 'GET')
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/cash_reconciliations') && method === 'POST')
      return ok({
        id: 'poscashrec_1', branch_id: 'br_1', outcome: body.outcome, amount: body.amount ? `${body.amount}.0` : '100000.0',
        currency: 'VND', reason: body.reason, custody_reference: body.custody_reference ?? null, closed_shift_id: 'sh_s1',
        received_funds_id: body.funds_id ?? null, target_shift_id: body.target_shift_id ?? null,
        cash_movement_id: body.outcome === 'new_physical_inflow' ? 'poscashmv_10' : null, actor_name: 'Lan',
        created_at: '2026-11-07T10:00:00Z',
      }, 201);
    const reportMatch = /\/pos\/reports\/(\w+)$/.exec(path);
    if (reportMatch) {
      const type = reportMatch[1];
      // A slow receipts report: the sales rows must not show under its columns meanwhile.
      if (type === 'receipts') await new Promise((resolve) => setTimeout(resolve, 600));
      const shiftPage = Number(url.searchParams.get('shift_page') ?? '1');
      const rows: Record<string, Array<Record<string, unknown>>> = {
        sales: [{ order_number: 'R100', sold_at: '2026-11-06T17:30:00Z', register: 'Q1', cashier: 'Lan', item_total: '250000.0', adjustment_total: '0.0', total: '250000.0', currency: 'VND' }],
        receipts: [{ received_at: '2026-11-06T13:30:00Z', booked_at: '2026-11-07T02:00:00Z', kind: 'bank_manual', source: 'unsolicited', custody: 'drawer', received_net: '70000.0', currency: 'VND', cashier: 'Hà' }],
        cashbook: [{ at: '2026-11-07T02:00:00Z', register: 'Q1', cashier: 'Lan', category: 'safe_drop', amount: '-30000.0', running_expected: '70000.0', reason: 'Nộp két', currency: 'VND' }],
        receivables: [],
        closures: [{ closed_at: '2026-11-06T14:00:00Z', register: 'Q1', cashier: 'Mai', expected: '0.0', counted: '100000.0', variance: '100000.0', reason: 'Thừa', approver: 'Hà', reconciled: '0.0', currency: 'VND' }],
      };
      const shiftLines = [
        { shift_id: 'sh_1', register: 'Q1', cashier: 'Lan', status: 'open', opened_at: '2026-11-07T01:00:00Z', opening_float: '50000.0', expected: '70000.0', counted: null, variance: null },
        { shift_id: 'sh_s1', register: 'Q2', cashier: 'Mai', status: 'closed', opened_at: '2026-11-06T01:00:00Z', opening_float: '0.0', expected: '0.0', counted: '100000.0', variance: '100000.0' },
      ];
      const summary =
        type === 'sales'
          ? { orders: 1, sales_total: '250000.0', returns: 0, returns_total: '0.0', net_sales: '250000.0' }
          : type === 'cashbook'
            ? { shifts: [shiftLines[shiftPage - 1]], shift_count: 2, shift_page: shiftPage, shift_pages: 2 }
            : {};
      return route.fulfill({
        json: {
          data: rows[type] ?? [],
          meta: {
            report: type, page: 1, pages: 1, count: (rows[type] ?? []).length, limit: 50, scope: 'branch',
            timezone: 'Asia/Ho_Chi_Minh', from: url.searchParams.get('from'), to: url.searchParams.get('to'), summary,
          },
        },
      });
    }
    if (path.endsWith('/pos/exports') && method === 'GET')
      return route.fulfill({ json: { data: exportsList(), meta: { page: 1, pages: 1, count: 3 } } });
    if (path.endsWith('/pos/exports') && method === 'POST')
      return route.fulfill({ status: 202, json: { data: { id: 'posexport_1', status: 'queued' } } });
    if (path.endsWith('/pos/exports/posexport_1/download_link'))
      return route.fulfill({
        json: { data: { id: 'posexport_1', url: '/api/v3/admin/pos/export_files/signed-token', filename: 'sales-q1.csv', expires_at: '2099-01-01T00:00:00Z' } },
      });
    if (path.endsWith('/pos/exports/posexport_2/download_link'))
      return route.fulfill({ status: 410, json: { error: { code: 'export_expired', message: 'This export has expired.' } } });
    if (path.endsWith('/pos/export_files/signed-token'))
      return route.fulfill({
        status: 200,
        headers: { 'Content-Type': 'text/csv; charset=utf-8', 'Content-Disposition': 'attachment; filename="sales-q1.csv"' },
        body: "﻿order_number,total\n'=1+1,250000.0\n",
      });
    return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
  });

  return {
    writes,
    receiptLookups,
    unblock: () => {
      blocked = false;
    },
    restoreNetwork: () => {
      loseCount = false;
    },
    approve: () => {
      approved = true;
    },
  };
}

async function login(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function openPage(page: Page, name: string) {
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name, exact: true }).click();
}

test('cashier requests a safe drop and closes the shift with a blind count and an approved shortage', async ({ page }) => {
  const api = await mockPos(page, {
    capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.cash.move'],
    blocked: true,
  });
  await login(page);
  await openPage(page, 'Ca & két');
  await expect(page.getByRole('heading', { name: 'Ca hiện tại' })).toBeVisible();

  await page.getByRole('button', { name: 'Thu/chi tiền mặt' }).click();
  const movement = page.getByRole('dialog', { name: 'Thu/chi tiền mặt trong két' });
  await movement.getByLabel('Nộp két sắt').check();
  await movement.getByLabel('Số tiền').fill('30.000');
  await movement.getByLabel('Lý do', { exact: true }).fill('Nộp két giữa ca');
  await movement.getByRole('button', { name: 'Ghi nhận' }).click();
  await expect(movement.getByRole('alert')).toContainText('cần số chứng từ');
  await movement.getByLabel('Số chứng từ (bắt buộc)').fill('TUI-7');
  await movement.getByRole('button', { name: 'Ghi nhận' }).click();
  await expect(movement).toHaveCount(0);
  await expect(page.getByText('Đã gửi yêu cầu Nộp két sắt 30.000 ₫; chờ người khác xác nhận.')).toBeVisible();
  expect(api.writes.find((write) => write.path.endsWith('/cash_movements'))?.body).toMatchObject({
    kind: 'safe_drop', amount: '30000', reason: 'Nộp két giữa ca', evidence_reference: 'TUI-7',
  });
  // Another person's pending request can be confirmed here; one's own cannot.
  const confirmList = page.getByRole('region', { name: 'Thu/chi két chờ xác nhận' });
  await expect(confirmList).toContainText('Mai');
  await confirmList.getByRole('button', { name: 'Xác nhận' }).click();
  await expect(page.getByText('Đã xác nhận Nộp két sắt 200.000 ₫.')).toBeVisible();

  const trigger = page.getByRole('button', { name: 'Đóng ca', exact: true });
  await trigger.click();
  const dialog = page.getByRole('dialog', { name: 'Đóng ca' });
  await expect(dialog.getByRole('list', { name: 'Việc chặn đóng ca' })).toContainText('Khoản thanh toán chưa xong · R500');
  await expect(dialog).toContainText('tiếp tục trên ca mới');
  await expect(dialog.getByRole('button', { name: 'Tiếp tục: đếm két' })).toBeDisabled();
  api.unblock();
  await dialog.getByRole('button', { name: 'Kiểm tra lại' }).click();
  await expect(dialog).toContainText('Không còn việc nào chặn đóng ca.');
  await dialog.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();

  // Blind count: expected cash is not on screen before the count is recorded.
  await expect(dialog).not.toContainText('100.000');
  await dialog.getByLabel('Tổng tiền mặt đếm được').fill('90.000');
  await dialog.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
  await expect(dialog).toContainText('Két cần có');
  await expect(dialog).toContainText('100.000 ₫');
  await expect(dialog.locator('.variance')).toHaveText('Thiếu 10.000 ₫');
  await expect(dialog).toContainText('cần lý do và người duyệt khác');

  await dialog.getByLabel('Lý do chênh lệch').fill('Thối nhầm cho khách');
  await dialog.getByRole('button', { name: 'Gửi lý do & chờ duyệt' }).click();
  await expect(dialog).toContainText('Đang chờ quản lý duyệt. Lý do: Thối nhầm cho khách');
  api.approve();
  await dialog.getByRole('button', { name: 'Kiểm tra duyệt' }).click();
  await expect(dialog).toContainText('Quản lý Hà');
  await dialog.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  await expect(dialog).toContainText('Đã đóng ca');
  await expect(dialog).toContainText('không sửa được');

  const counts = api.writes.filter((write) => write.path.endsWith('/count'));
  expect(counts.map((write) => write.body)).toEqual([
    expect.objectContaining({ counted: '90000' }),
    expect.objectContaining({ counted: '90000', reason: 'Thối nhầm cho khách' }),
  ]);
  // Each count revision has its own key.
  expect(new Set(counts.map((write) => write.key)).size).toBe(2);
  expect(api.writes.filter((write) => write.path.endsWith('/close'))).toHaveLength(1);
  for (const write of api.writes.filter((item) => item.path.startsWith('/pos/shifts')))
    expect(write.body.idempotency_key).toBeTruthy();
});

test('a count whose response was lost is rechecked by its key and never sent twice', async ({ page }) => {
  const api = await mockPos(page, { capabilities: ['pos.shift.open'], loseFirstCount: true });
  await login(page);
  await openPage(page, 'Ca & két');
  await page.getByRole('button', { name: 'Đóng ca', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Đóng ca' });
  await dialog.getByRole('button', { name: 'Tiếp tục: đếm két' }).click();
  await dialog.getByLabel('Tổng tiền mặt đếm được').fill('100.000');
  await dialog.getByRole('button', { name: 'Ghi nhận số đếm' }).click();
  await expect(dialog).toContainText('Đang kiểm tra kết quả');
  api.restoreNetwork();
  await dialog.getByRole('button', { name: 'Kiểm tra lại' }).click();
  await expect(dialog).not.toContainText('Đang kiểm tra kết quả');
  await expect(dialog.locator('.variance')).toHaveText('Khớp');
  const counts = api.writes.filter((write) => write.path.endsWith('/count'));
  await expect.poll(() => api.receiptLookups).toContain(counts[0].key);
  // Every attempt (including the SDK's own retries) carried the one key, and
  // the recheck found the committed receipt instead of counting again.
  expect(new Set(counts.map((write) => write.key)).size).toBe(1);
  expect(api.receiptLookups).toContain(counts[0].key);
});

test('Escape closes the close wizard and returns focus', async ({ page }) => {
  await mockPos(page, { capabilities: ['pos.shift.open'] });
  await login(page);
  await openPage(page, 'Ca & két');
  const trigger = page.getByRole('button', { name: 'Đóng ca', exact: true });
  await trigger.click();
  await expect(page.getByRole('dialog', { name: 'Đóng ca' })).toBeVisible();
  await page.keyboard.press('Escape');
  await expect(page.getByRole('dialog')).toHaveCount(0);
  await expect(trigger).toBeFocused();
});

test('a manager reconciles late cash already in the next opening float without adding it to the drawer', async ({ page }) => {
  const api = await mockPos(page, {
    capabilities: ['pos.shift.open', 'pos.payment.resolve', 'pos.approval.grant'],
  });
  await login(page);
  await openPage(page, 'Ca & két');
  const wizard = page.getByRole('region', { name: 'Đối soát tiền mặt đến muộn' });
  await wizard.getByLabel('Ca đã đóng có tiền thừa').selectOption('posclosure_s1');
  await expect(wizard).toContainText('Lúc đóng ca: đếm 100.000 ₫, cần có 0 ₫');
  await wizard.getByLabel('Khoản tiền mặt đang giữ').selectOption('posfunds_held');
  await expect(wizard).toContainText('Tiền này được ghi cho ca của Mai');
  await expect(wizard).toContainText('Số tiền đối soát: 100.000 ₫');
  await wizard.getByLabel(/Đã nằm trong tiền đầu ca sau/).check();
  await expect(wizard).toContainText('Lựa chọn này không cộng tiền vào két hiện tại.');
  await wizard.getByLabel(/Ca có tiền đầu ca chứa khoản này/).selectOption('sh_s2');
  await wizard.getByLabel('Lý do', { exact: true }).fill('Tiền thừa ca trước đã để lại làm tiền đầu ca');
  await wizard.getByRole('button', { name: 'Ghi đối soát' }).click();
  await expect(page.getByText('Đã đối soát 100.000 ₫; không cộng vào két hiện tại.')).toBeVisible();
  expect(api.writes.find((write) => write.path === '/pos/cash_reconciliations')?.body).toMatchObject({
    branch_id: 'br_1', outcome: 'in_opening_float', closure_id: 'posclosure_s1', funds_id: 'posfunds_held', target_shift_id: 'sh_s2',
  });
});

test('a closure-only reconciliation sends an amount capped at the unexplained overage', async ({ page }) => {
  const api = await mockPos(page, {
    capabilities: ['pos.shift.open', 'pos.payment.resolve', 'pos.approval.grant'],
  });
  await login(page);
  await openPage(page, 'Ca & két');
  const wizard = page.getByRole('region', { name: 'Đối soát tiền mặt đến muộn' });
  await wizard.getByLabel('Ca đã đóng có tiền thừa').selectOption('posclosure_s1');
  const amount = wizard.getByLabel(/Số tiền đối soát \(tối đa 100.000 ₫\)/);
  await amount.fill('150.000');
  await expect(wizard).toContainText('vượt phần thừa chưa giải thích');
  await amount.fill('60.000');
  await wizard.getByLabel(/Đã nộp két sắt/).check();
  await wizard.getByLabel('Số chứng từ lưu giữ').fill('KET-2');
  await wizard.getByLabel('Lý do', { exact: true }).fill('Một phần tiền thừa đã nộp két');
  await wizard.getByRole('button', { name: 'Ghi đối soát' }).click();
  await expect(page.getByText('Đã đối soát 60.000 ₫; không cộng vào két hiện tại.')).toBeVisible();
  expect(api.writes.find((write) => write.path === '/pos/cash_reconciliations')?.body).toMatchObject({
    outcome: 'safe', closure_id: 'posclosure_s1', amount: '60000', custody_reference: 'KET-2',
  });
});

test('an approver approves a closing variance and waits for a missing reason', async ({ page }) => {
  const api = await mockPos(page, { capabilities: ['pos.shift.open', 'pos.approval.grant'] });
  await login(page);
  await openPage(page, 'Duyệt');
  const list = page.getByRole('list', { name: 'Ca chờ duyệt chênh lệch' });
  await expect(list).toContainText('Mai · Q1');
  await expect(list).toContainText('Thiếu 10.000 ₫');
  await expect(list.getByRole('listitem').filter({ hasText: 'Tú' }).getByRole('button', { name: 'Chờ thu ngân nhập lý do' })).toBeDisabled();
  await list.getByRole('button', { name: 'Duyệt chênh lệch' }).click();
  await expect(page.getByText('Đã duyệt chênh lệch đóng ca của Mai.')).toBeVisible();
  expect(api.writes.find((write) => write.path.endsWith('/close_approval'))?.body).toMatchObject({ revision: 4 });
});

test('reports keep sales, receipts and drawer cash apart, use keyboard tabs and export a CSV', async ({ page }) => {
  const api = await mockPos(page, {
    capabilities: ['pos.shift.open', 'pos.report.read', 'pos.report.export'],
  });
  await login(page);
  await openPage(page, 'Báo cáo');
  const panel = page.getByRole('tabpanel');
  await expect(panel.getByRole('table')).toContainText('R100');
  await expect(panel).toContainText('Cả chi nhánh');
  await expect(panel.getByLabel('Tổng hợp')).toContainText('250.000 ₫');

  await page.getByRole('tab', { name: 'Doanh số' }).focus();
  await page.keyboard.press('ArrowRight');
  await expect(page.getByRole('tab', { name: 'Thực thu' })).toHaveAttribute('aria-selected', 'true');
  await expect(page.getByRole('tab', { name: 'Thực thu' })).toBeFocused();
  // While the receipts report loads, the sales rows are not shown under its columns.
  await expect(panel).not.toContainText('R100');
  await expect(panel.getByRole('table')).toContainText('Ngoài luồng');
  await expect(panel.getByRole('table')).toContainText('Chuyển khoản');
  await page.keyboard.press('End');
  await expect(page.getByRole('tab', { name: 'Đóng ca' })).toBeFocused();
  await page.keyboard.press('Home');
  await expect(page.getByRole('tab', { name: 'Doanh số' })).toBeFocused();

  await page.getByRole('tab', { name: 'Tiền mặt trong két' }).click();
  await expect(panel.getByRole('table', { name: 'Tóm tắt theo ca' })).toContainText('Lan');
  await expect(panel.getByRole('table', { name: 'Tóm tắt theo ca' })).toContainText('Chưa đếm');
  await panel.getByRole('navigation', { name: 'Trang tóm tắt ca' }).getByRole('button', { name: 'Trang sau' }).click();
  await expect(panel.getByRole('table', { name: 'Tóm tắt theo ca' })).toContainText('Thừa 100.000 ₫');
  await expect(panel).toContainText('Nộp két sắt');

  await page.getByRole('tab', { name: 'Đóng ca' }).click();
  await expect(panel.getByRole('table')).toContainText('Thừa 100.000 ₫');

  await page.getByRole('tab', { name: 'Doanh số' }).click();
  await panel.getByRole('button', { name: 'Xuất CSV' }).click();
  await expect(page.getByText('Đã nhận yêu cầu xuất')).toBeVisible();
  const exports = page.getByRole('list', { name: 'File xuất của bạn' });
  await expect(exports.getByRole('listitem')).toHaveCount(3);
  await expect(exports.getByRole('listitem').filter({ hasText: 'Đã hết hạn' }).getByRole('button')).toHaveCount(0);
  const download = page.waitForEvent('download');
  await exports.getByRole('listitem').filter({ hasText: 'Doanh số' }).getByRole('button', { name: 'Tải về' }).click();
  expect((await download).suggestedFilename()).toBe('sales-q1.csv');
  await exports.getByRole('listitem').filter({ hasText: 'Đóng ca' }).getByRole('button', { name: 'Tải về' }).click();
  await expect(page.getByText('Bản xuất đã hết hạn, hãy tạo lại')).toBeVisible();
  const exported = api.writes.find((write) => write.path === '/pos/exports')?.body;
  expect(exported).toMatchObject({ branch_id: 'br_1', report_type: 'sales' });
  expect(Object.keys(exported?.filters as Record<string, string>).sort()).toEqual(['from', 'to']);
});
