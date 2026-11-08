import { expect, type Page, test } from '@playwright/test';

type Attempt = Record<string, unknown> & { id: string; kind: string; amount: string; status: string };

type MockWorkspace = {
  id: string;
  order_id: string;
  total: number;
  revision: number;
  status: 'editing' | 'completed';
  customer: { id: string; name: string } | null;
  attempts: Attempt[];
  allocated: number;
  debt: number;
};

const money = (value: number) => `${value}.0`;

function serialize(ws: MockWorkspace) {
  return {
    id: ws.id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: ws.order_id,
    revision: ws.revision,
    lease_generation: 1,
    operational_status: ws.status,
    payments: ws.attempts.length > 0,
    line_items: [
      {
        id: `line_${ws.id}`,
        variant_id: 'variant_1',
        product_id: 'prod_1',
        name: 'Gạo ST25',
        sku: 'GAO-1',
        quantity: 1,
        price: money(ws.total),
        amount: money(ws.total),
        discounts: [],
        sale_line_id: `sale_${ws.id}`,
        kind: 'ordinary',
      },
    ],
    customer: ws.customer && {
      ...ws.customer,
      phone: '0901234567',
      email: null,
      customer_id: null,
      has_account: false,
    },
    discount: null,
    totals: {
      item_total: money(ws.total),
      discount_total: '0.0',
      manual_discount_total: '0.0',
      included_tax_total: '0.0',
      additional_tax_total: '0.0',
      total: money(ws.total),
      currency: 'VND',
    },
    financial: {
      received: money(ws.allocated),
      allocated: money(ws.allocated),
      unapplied: '0.0',
      remaining: money(Math.max(ws.total - ws.allocated, 0)),
      change_due: '0.0',
      attempts: ws.attempts,
      credit: {
        approved: null,
        approval_id: null,
        debt: ws.debt ? money(ws.debt) : null,
        due_on: ws.debt ? '2026-12-07' : null,
        balance: ws.debt ? money(ws.debt) : null,
      },
    },
  };
}

const debts = [
  {
    order_id: 'or_1',
    order_number: 'R100',
    workspace_id: 'ws_old1',
    credit_account_id: 'poscredit_1',
    customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' },
    currency: 'VND',
    original_total: '800000.0',
    paid_at_sale: '200000.0',
    debt: '600000.0',
    credit_notes: '0.0',
    collected: '0.0',
    refunds: '0.0',
    balance: '600000.0',
    due_on: '2026-10-30',
    overdue: true,
    days_overdue: 8,
    aging: 'days_1_30',
    placed_at: '2026-10-23T09:00:00Z',
  },
  {
    order_id: 'or_2',
    order_number: 'R200',
    workspace_id: 'ws_old2',
    credit_account_id: 'poscredit_1',
    customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' },
    currency: 'VND',
    original_total: '400000.0',
    paid_at_sale: '0.0',
    debt: '400000.0',
    credit_notes: '0.0',
    collected: '0.0',
    refunds: '0.0',
    balance: '400000.0',
    due_on: '2026-11-20',
    overdue: false,
    days_overdue: 0,
    aging: 'current',
    placed_at: '2026-11-05T09:00:00Z',
  },
];

// In-memory POS API that enforces the credit and collection rules the client
// must not bypass, and keeps request bodies for assertions.
type CreditRequestRow = {
  id: string;
  order_number: string;
  status: 'pending' | 'approved' | 'rejected' | 'stale';
  approval_active: boolean;
  reason: string | null;
};

async function mockPos(
  page: Page,
  workspace: Pick<MockWorkspace, 'id' | 'order_id' | 'total' | 'customer'>,
  options: { capabilities?: string[]; abortFirstCollection?: boolean; creditOff?: boolean } = {},
) {
  // Effective branch switches, as the server sends them in the context.
  const features = {
    credit: !options.creditOff,
    returns: true,
    refunds: true,
    exchanges: true,
    traceability: true,
    customer_display: true,
    cash_moves: true,
    exports: true,
  };
  const ws: MockWorkspace = {
    ...workspace,
    revision: 1,
    status: 'editing',
    attempts: [],
    allocated: 0,
    debt: 0,
  };
  const capabilities = options.capabilities ?? ['pos.shift.open', 'pos.payment.collect', 'pos.credit.sell'];
  const completions: Array<Record<string, unknown>> = [];
  const collections: Array<Record<string, unknown>> = [];
  const collectionKeys: string[] = [];
  const receiptLookups: string[] = [];
  const creditRequests: Array<Record<string, unknown>> = [];
  const accountWrites: Array<{ method: string; path: string; body: Record<string, unknown> }> = [];
  const decisions: Array<{ id: string; decision: string; body: Record<string, unknown> }> = [];
  const accounts = [
    {
      id: 'poscredit_1',
      customer_id: 'poscustomer_1',
      customer_name: 'Chị Lan',
      customer_phone: '0901234567',
      branch_id: 'br_1',
      status: 'active',
      currency: 'VND',
      credit_limit: '2000000.0',
      due_days: 30,
      open_debt: '1000000.0',
      reserved: '0.0',
      available: '1000000.0',
    },
  ];
  const requestRows: CreditRequestRow[] = [
    { id: 'poscreditreq_1', order_number: 'R700', status: 'pending', approval_active: false, reason: null },
    { id: 'poscreditreq_2', order_number: 'R800', status: 'pending', approval_active: false, reason: null },
    { id: 'poscreditreq_3', order_number: 'R900', status: 'approved', approval_active: true, reason: null },
  ];
  let creditChecks = 0;
  let managerApproved = false;
  let networkBack = false;

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const conflict = (message: string) =>
      route.fulfill({ status: 409, json: { error: { code: 'conflict', message } } });
    // Like the server: with credit off, new credit requests, approvals and
    // credit completions are refused; rejecting, revoking and collecting
    // existing debt stay open.
    const creditRefused = () =>
      route.fulfill({
        status: 409,
        json: {
          error: {
            code: 'conflict',
            message: 'Credit is turned off.',
            details: { reason: 'feature_disabled', feature: 'credit' },
          },
        },
      });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh'))
      return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me'))
      return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context/branches'))
      return route.fulfill({
        json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } },
      });
    if (path.endsWith('/pos/context/registers'))
      return route.fulfill({
        json: {
          data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }],
          meta: { page: 1, pages: 1, count: 1 },
        },
      });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? capabilities : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', branch_id: 'br_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
          features,
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET')
      return route.fulfill({ json: { data: [serialize(ws)], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/received_funds'))
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/command_receipts')) {
      receiptLookups.push(url.searchParams.get('idempotency_key') ?? '');
      return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
    }
    if (path.endsWith('/pos/customers') && method === 'GET')
      return route.fulfill({
        json: {
          data: [
            {
              id: 'poscustomer_2',
              name: 'Anh Bình',
              phone: '0907654321',
              email: null,
              customer_id: null,
              has_account: false,
            },
          ],
          meta: { page: 1, pages: 1, count: 1, duplicate_candidates: 0 },
        },
      });
    if (path.endsWith('/pos/credit_accounts') && method === 'GET')
      return route.fulfill({ json: { data: accounts, meta: { page: 1, pages: 1, count: accounts.length } } });
    const accountWrite = /\/pos\/credit_accounts(?:\/([^/]+))?$/.exec(path);
    if (accountWrite && (method === 'POST' || method === 'PATCH')) {
      const body = request.postDataJSON() as Record<string, unknown>;
      accountWrites.push({ method, path, body });
      const existing = accounts.find((row) => row.id === accountWrite[1]);
      if (existing) {
        if (typeof body.credit_limit === 'string') existing.credit_limit = `${body.credit_limit}.0`;
        if (typeof body.due_days === 'number') existing.due_days = body.due_days;
        if (typeof body.status === 'string') existing.status = body.status;
        return route.fulfill({ json: { data: existing } });
      }
      const created = {
        ...accounts[0],
        id: 'poscredit_2',
        customer_id: String(body.customer_id),
        customer_name: 'Anh Bình',
        customer_phone: '0907654321',
        credit_limit: `${body.credit_limit}.0`,
        due_days: Number(body.due_days),
        open_debt: '0.0',
        available: `${body.credit_limit}.0`,
      };
      accounts.push(created);
      return route.fulfill({ status: 201, json: { data: created } });
    }
    const requestRow = (row: CreditRequestRow) => ({
      ...row,
      branch_id: 'br_1',
      workspace_id: 'ws_9',
      customer: { id: 'poscustomer_1', name: 'Chị Lan' },
      requester: { id: 'stf_3', name: 'Thu ngân Mai' },
      amount: '250000.0',
      currency: 'VND',
      workspace_revision: 4,
      created_at: '2026-11-07T03:00:00Z',
      decided_at: null,
      approval_id: row.status === 'approved' ? 'posapproval_9' : null,
    });
    if (path.endsWith('/pos/credit_requests') && method === 'GET') {
      const visible = requestRows.filter(
        (row) => row.status === 'pending' || (row.status === 'approved' && row.approval_active),
      );
      return route.fulfill({
        json: { data: visible.map(requestRow), meta: { page: 1, pages: 1, count: visible.length } },
      });
    }
    const decision = /\/pos\/credit_requests\/([^/]+)\/(approve|reject|revoke)$/.exec(path);
    if (decision && method === 'POST') {
      const row = requestRows.find((item) => item.id === decision[1]);
      const body = request.postDataJSON() as Record<string, unknown>;
      decisions.push({ id: decision[1], decision: decision[2], body });
      if (!row) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
      if (decision[2] === 'approve' && !features.credit) return creditRefused();
      if (decision[2] === 'approve') Object.assign(row, { status: 'approved', approval_active: true });
      if (decision[2] === 'reject') Object.assign(row, { status: 'rejected', reason: String(body.reason) });
      if (decision[2] === 'revoke') row.approval_active = false;
      return route.fulfill({ json: { data: requestRow(row) } });
    }
    if (path.endsWith('/pos/receivables/customers'))
      return route.fulfill({
        json: {
          data: [
            {
              credit_account_id: 'poscredit_1',
              currency: 'VND',
              customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' },
              orders: 2,
              credit_limit: '2000000.0',
              account_status: 'active',
              balance: '1000000.0',
              overdue: '600000.0',
              current: '400000.0',
              days_1_30: '600000.0',
              days_31_60: '0.0',
              days_61_90: '0.0',
              days_over_90: '0.0',
            },
          ],
          meta: {
            count: 1,
            totals: {
              balance: '1000000.0',
              overdue: '600000.0',
              current: '400000.0',
              days_1_30: '600000.0',
              days_31_60: '0.0',
              days_61_90: '0.0',
              days_over_90: '0.0',
            },
          },
        },
      });
    if (path.endsWith('/pos/receivables'))
      return route.fulfill({ json: { data: debts, meta: { page: 1, pages: 1, count: debts.length } } });
    if (path.endsWith('/pos/collections') && method === 'POST') {
      const body = request.postDataJSON() as {
        amount: string;
        allocations: Array<{ order_id: string; amount: string }>;
      };
      collections.push(body);
      collectionKeys.push((await request.headerValue('idempotency-key')) ?? '');
      // The SDK may retry a failed request itself; keep the network down
      // until the test restores it.
      if (options.abortFirstCollection && !networkBack) return route.abort('failed');
      const allocated = body.allocations.reduce((sum, row) => sum + Number(row.amount), 0);
      if (allocated > Number(body.amount)) return conflict('Allocations exceed the money available on this receipt.');
      return route.fulfill({
        status: 201,
        json: {
          data: {
            id: 'poscollect_1',
            credit_account_id: 'poscredit_1',
            branch_id: 'br_1',
            customer_id: 'poscustomer_1',
            note: null,
            funds: {
              id: 'posfunds_1',
              received_net: money(Number(body.amount)),
              available: money(Number(body.amount) - allocated),
              currency: 'VND',
            },
            allocations: [],
            created_at: null,
          },
        },
      });
    }

    const match = /\/pos\/workspaces\/(ws_\d+)(\/.*)?$/.exec(path);
    if (!match || match[1] !== ws.id) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    const rest = match[2] ?? '';
    const reply = () => route.fulfill({ json: { data: serialize(ws) } });

    if (rest === '' && method === 'GET') return reply();
    if (rest === '/lease') return reply();
    if (rest === '/credit_requests' && method === 'POST') {
      if (!features.credit) return creditRefused();
      creditRequests.push(request.postDataJSON() as Record<string, unknown>);
      return route.fulfill({ status: 201, json: { data: { id: 'poscreditreq_ws', status: 'pending' } } });
    }
    if (rest === '/credit') {
      creditChecks += 1;
      const remaining = ws.total - ws.allocated;
      // The manager approves in their own session once the test says so.
      const approved = Boolean(ws.customer && creditRequests.length > 0 && managerApproved);
      return route.fulfill({
        json: {
          data: {
            workspace_id: ws.id,
            revision: ws.revision,
            customer: ws.customer,
            can_sell: true,
            request:
              creditRequests.length > 0
                ? {
                    id: 'poscreditreq_ws',
                    branch_id: 'br_1',
                    workspace_id: ws.id,
                    order_number: ws.order_id,
                    customer: ws.customer,
                    requester: { id: 'stf_1', name: 'Lan' },
                    amount: money(remaining),
                    currency: 'VND',
                    workspace_revision: ws.revision,
                    status: approved ? 'approved' : 'pending',
                    reason: null,
                    created_at: '2026-11-07T03:00:00Z',
                    decided_at: null,
                    approval_id: approved ? 'posapproval_1' : null,
                    approval_active: approved,
                  }
                : null,
            account: ws.customer
              ? {
                  id: 'poscredit_1',
                  customer_id: ws.customer.id,
                  customer_name: ws.customer.name,
                  status: 'active',
                  currency: 'VND',
                  credit_limit: '2000000.0',
                  due_days: 30,
                  open_debt: '0.0',
                  reserved: approved ? money(remaining) : '0.0',
                  available: approved ? money(2000000 - remaining) : '2000000.0',
                  due_on: '2026-12-07',
                }
              : null,
            reservation: approved
              ? {
                  id: 'poscreditres_1',
                  credit_account_id: 'poscredit_1',
                  workspace_id: ws.id,
                  approval_id: 'posapproval_1',
                  customer_id: ws.customer?.id,
                  amount: money(remaining),
                  currency: 'VND',
                  workspace_revision: ws.revision,
                  status: 'active',
                  usable: true,
                  approver: { id: 'stf_2', name: 'Quản lý Hà' },
                  expires_at: '2099-01-01T00:00:00Z',
                }
              : null,
          },
        },
      });
    }
    if (rest === '/payment_methods')
      return route.fulfill({
        json: {
          data: [
            { id: 'posmethod-cash', code: 'cash', name: 'Cash', kind: 'cash', status: 'active', position: 0 },
            { id: 'posmethod-bank_manual', code: 'bank_transfer', name: 'Bank', kind: 'bank_manual', status: 'active', position: 1 },
          ],
        },
      });
    if (rest === '/tender_attempts' && method === 'POST') {
      const body = request.postDataJSON() as { payment_method_id: string; amount: string };
      ws.attempts = [
        ...ws.attempts,
        {
          id: `ten_${ws.attempts.length + 1}`,
          workspace_id: ws.id,
          payment_method_id: body.payment_method_id,
          kind: body.payment_method_id.endsWith('cash') ? 'cash' : 'bank_manual',
          status: 'prepared',
          amount: money(Number(body.amount)),
          order_total_snapshot: money(ws.total),
          currency: 'VND',
          workspace_revision: ws.revision,
          received_funds_id: null,
          confirmed_at: null,
          canceled_at: null,
        },
      ];
      ws.revision += 1;
      return reply();
    }
    const attemptMatch = /^\/tender_attempts\/([^/]+)\/confirm$/.exec(rest);
    if (attemptMatch && method === 'POST') {
      const attempt = ws.attempts.find((item) => item.id === attemptMatch[1]);
      if (!attempt || attempt.status !== 'prepared') return conflict('Tender is not prepared.');
      attempt.status = 'confirmed';
      ws.allocated += Number.parseInt(attempt.amount, 10);
      ws.revision += 1;
      return reply();
    }
    if (rest === '/complete' && method === 'POST') {
      const body = request.postDataJSON() as Record<string, unknown>;
      completions.push(body);
      if (body.credit_approval_id && !features.credit) return creditRefused();
      const remaining = ws.total - ws.allocated;
      if (remaining > 0 && body.credit_approval_id !== 'posapproval_1')
        return conflict('Received funds do not cover the order total.');
      ws.debt = remaining;
      ws.status = 'completed';
      ws.revision += 1;
      return reply();
    }
    if (rest === '/handover' && method === 'POST') return reply();
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  void creditChecks;
  return {
    ws,
    completions,
    collections,
    collectionKeys,
    receiptLookups,
    creditRequests,
    accountWrites,
    decisions,
    approveAsManager: () => {
      managerApproved = true;
    },
    restoreNetwork: () => {
      networkBack = true;
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

async function openTab(page: Page, workspaceId: string) {
  await page.locator(`[role="tab"][data-workspace-id="${workspaceId}"]`).click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.locator('.payment-panel')).toBeVisible();
}

test('credit sale: cash part first, then manager-approved debt with "Hoàn tất & ghi nợ"', async ({
  page,
}) => {
  const api = await mockPos(page, {
    id: 'ws_1',
    order_id: 'R500',
    total: 500000,
    customer: { id: 'poscustomer_1', name: 'Chị Lan' },
  });
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');

  await panel.getByLabel('Tiền mặt').fill('400.000');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const evidence = page.getByRole('dialog');
  await evidence.getByLabel('Khách đưa').fill('400.000');
  await evidence.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(evidence).toHaveCount(0);

  await panel.getByRole('button', { name: 'Ghi nợ', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Ghi nợ cho khách' });
  await expect(dialog).toContainText('Chị Lan');
  await expect(dialog).toContainText('100.000 ₫');
  await expect(dialog).toContainText('Chờ quản lý duyệt ghi nợ 100.000 ₫');
  await expect(dialog).toContainText('Đã gửi yêu cầu duyệt');
  expect(api.creditRequests).toHaveLength(1);
  const finish = dialog.getByRole('button', { name: 'Hoàn tất & ghi nợ' });
  await expect(finish).toBeDisabled();

  api.approveAsManager();
  await dialog.getByRole('button', { name: 'Kiểm tra duyệt' }).click();
  await expect(dialog).toContainText('Quản lý Hà');
  await expect(dialog).toContainText('1.900.000 ₫');
  await finish.click();
  await expect(dialog).toHaveCount(0);

  expect(api.completions).toEqual([expect.objectContaining({ credit_approval_id: 'posapproval_1' })]);
  await expect(panel.locator('.payment-summary')).toContainText('Dư nợ còn lại');
  await expect(panel.locator('.payment-summary')).toContainText('100.000 ₫');
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
});

test('a walk-in cannot be sold on credit and Escape closes the credit dialog', async ({ page }) => {
  const api = await mockPos(page, { id: 'ws_1', order_id: 'R500', total: 500000, customer: null });
  await login(page);
  await openTab(page, 'ws_1');
  const trigger = page.locator('.payment-panel').getByRole('button', { name: 'Ghi nợ', exact: true });
  await trigger.click();
  const dialog = page.getByRole('dialog', { name: 'Ghi nợ cho khách' });
  await expect(dialog).toContainText('cần khách hàng đã xác định');
  await expect(dialog.getByRole('button', { name: 'Hoàn tất & ghi nợ' })).toBeDisabled();
  await expect(page.locator('header.header')).toHaveJSProperty('inert', true);
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  await expect(trigger).toBeFocused();
  expect(api.completions).toEqual([]);
  expect(api.creditRequests).toEqual([]);
});

test('collection: one cash receipt split oldest debt first, with change and a bounded preview', async ({
  page,
}) => {
  const api = await mockPos(page, { id: 'ws_1', order_id: 'R500', total: 500000, customer: null });
  await login(page);
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name: 'Công nợ khách hàng' }).click();
  await expect(page.getByRole('heading', { name: 'Công nợ khách hàng' })).toBeVisible();
  await expect(page.getByText('Quá hạn 8 ngày')).toBeVisible();

  await page.getByRole('button', { name: /Chị Lan/ }).click();
  await page.getByRole('button', { name: 'Thu nợ' }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await dialog.getByLabel('Số tiền thu').fill('700.000');
  await expect(dialog.getByLabel('Đã phân bổ R100')).toHaveValue('600000');
  await expect(dialog.getByLabel('Đã phân bổ R200')).toHaveValue('100000');
  await dialog.getByLabel('Khách đưa').fill('1.000.000');
  await expect(dialog).toContainText('300.000 ₫');

  await dialog.getByLabel('Đã phân bổ R200').fill('200.000');
  await expect(dialog).toContainText('Tổng phân bổ vượt số tiền thu.');
  const submit = dialog.getByRole('button', { name: 'Ghi nhận thu nợ' });
  await expect(submit).toBeDisabled();
  await dialog.getByLabel('Đã phân bổ R200').fill('50.000');
  await expect(dialog).toContainText('50.000 ₫');
  await submit.click();
  await expect(dialog).toContainText('Đã ghi nhận thu 700.000 ₫.');
  await expect(dialog.getByRole('button', { name: 'Ghi nhận thu nợ' })).toHaveCount(0);
  await dialog.locator('.payment-popup-actions').getByRole('button', { name: 'Đóng' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận thu 700.000 ₫.' })).toBeVisible();

  expect(api.collections).toEqual([
    expect.objectContaining({
      credit_account_id: 'poscredit_1',
      kind: 'cash',
      amount: '700000',
      handed_amount: '1000000',
      allocations: [
        { order_id: 'or_1', amount: '600000' },
        { order_id: 'or_2', amount: '50000' },
      ],
    }),
  ]);
});

async function openReceivables(page: Page) {
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name: 'Công nợ khách hàng' }).click();
  await expect(page.getByRole('heading', { name: 'Công nợ khách hàng' })).toBeVisible();
}

test('a collection whose response was lost is resent under the same key even after editing', async ({
  page,
}) => {
  const api = await mockPos(
    page,
    { id: 'ws_1', order_id: 'R500', total: 500000, customer: null },
    { abortFirstCollection: true },
  );
  await login(page);
  await openReceivables(page);
  await page.getByRole('button', { name: /Chị Lan/ }).click();
  await page.getByRole('button', { name: 'Thu nợ' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Số tiền thu').fill('300.000');
  await dialog.getByLabel('Khách đưa').fill('500.000');
  await dialog.getByRole('button', { name: 'Ghi nhận thu nợ' }).click();
  await expect(dialog.getByRole('alert')).toBeVisible();
  const failedAttempts = api.collectionKeys.length;

  // The cashier corrects the handed amount and tries again once the network is back.
  api.restoreNetwork();
  await dialog.getByLabel('Khách đưa').fill('300.000');
  await dialog.getByRole('button', { name: 'Ghi nhận thu nợ' }).click();
  await expect(dialog).toContainText('Đã ghi nhận thu 300.000 ₫.');

  expect(api.collectionKeys.length).toBe(failedAttempts + 1);
  expect(new Set(api.collectionKeys).size).toBe(1);
  expect(api.receiptLookups).toEqual([api.collectionKeys[0]]);
  expect(api.collections.at(-1)?.handed_amount).toBe('300000');
  expect(api.collections[0].handed_amount).toBe('500000');
});

test('a credit manager opens, edits and suspends customer credit accounts', async ({ page }) => {
  const api = await mockPos(
    page,
    { id: 'ws_1', order_id: 'R500', total: 500000, customer: null },
    { capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.credit.manage'] },
  );
  await login(page);
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name: 'Tài khoản nợ' }).click();
  const list = page.getByRole('list', { name: 'Tài khoản công nợ của chi nhánh' });
  await expect(list).toContainText('Chị Lan');
  await expect(list).toContainText('1.000.000 ₫');

  await page.getByLabel('Tìm khách theo tên hoặc số điện thoại').fill('Bình');
  await page.getByRole('button', { name: /Anh Bình/ }).click();
  await page.getByLabel('Hạn mức').first().fill('5.000.000');
  await page.getByLabel('Số ngày nợ').first().fill('4000');
  const create = page.getByRole('button', { name: 'Mở tài khoản công nợ' });
  await expect(create).toBeDisabled();
  await page.getByLabel('Số ngày nợ').first().fill('45');
  await create.click();
  await expect(page.getByText('Đã lưu công nợ cho Anh Bình.')).toBeVisible();

  const row = list.getByRole('listitem').filter({ hasText: 'Chị Lan' });
  await row.getByRole('button', { name: 'Sửa hạn mức' }).click();
  await row.getByRole('textbox', { name: 'Hạn mức', exact: true }).fill('3.000.000');
  await row.getByRole('button', { name: 'Lưu hạn mức' }).click();
  await row.getByRole('button', { name: 'Tạm khóa' }).click();
  await expect(row).toContainText('Tạm khóa');

  expect(api.accountWrites.map(({ method, body }) => [method, body])).toEqual([
    ['POST', expect.objectContaining({ branch_id: 'br_1', customer_id: 'poscustomer_2', credit_limit: '5000000', due_days: 45 })],
    ['PATCH', expect.objectContaining({ credit_limit: '3000000', due_days: 30 })],
    ['PATCH', expect.objectContaining({ status: 'suspended' })],
  ]);
});

test('an approver approves, declines with a reason and revokes credit requests', async ({ page }) => {
  const api = await mockPos(
    page,
    { id: 'ws_1', order_id: 'R500', total: 500000, customer: null },
    { capabilities: ['pos.shift.open', 'pos.approval.grant', 'pos.credit.manage'] },
  );
  await login(page);
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name: 'Duyệt', exact: true }).click();
  const list = page.getByRole('list', { name: 'Duyệt ghi nợ' });
  await expect(list.getByRole('listitem')).toHaveCount(3);
  await expect(list).toContainText('Thu ngân Mai');

  await list.getByRole('listitem').filter({ hasText: 'R700' }).getByRole('button', { name: 'Duyệt ghi nợ' }).click();
  await expect(page.getByText('Đã duyệt ghi nợ cho đơn R700.')).toBeVisible();

  const second = list.getByRole('listitem').filter({ hasText: 'R800' });
  await second.getByRole('button', { name: 'Từ chối' }).click();
  await second.getByLabel('Lý do từ chối').fill('Khách đang nợ quá hạn');
  await second.getByRole('button', { name: 'Từ chối' }).click();
  await expect(page.getByText('Đã từ chối ghi nợ cho đơn R800.')).toBeVisible();

  await list.getByRole('listitem').filter({ hasText: 'R900' }).getByRole('button', { name: 'Thu hồi duyệt' }).click();
  await expect(page.getByText('Đã thu hồi duyệt cho đơn R900.')).toBeVisible();

  expect(api.decisions.map(({ id, decision }) => [id, decision])).toEqual([
    ['poscreditreq_1', 'approve'],
    ['poscreditreq_2', 'reject'],
    ['poscreditreq_3', 'revoke'],
  ]);
  expect(api.decisions[1].body).toMatchObject({ reason: 'Khách đang nợ quá hạn' });
});

test('with credit switched off an approver cannot approve, but still declines and revokes', async ({ page }) => {
  const api = await mockPos(
    page,
    { id: 'ws_1', order_id: 'R500', total: 500000, customer: null },
    { capabilities: ['pos.shift.open', 'pos.approval.grant', 'pos.credit.manage'], creditOff: true },
  );
  await login(page);
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name: 'Duyệt', exact: true }).click();
  const list = page.getByRole('list', { name: 'Duyệt ghi nợ' });
  await expect(list.getByRole('listitem')).toHaveCount(3);

  const first = list.getByRole('listitem').filter({ hasText: 'R700' });
  const approve = first.getByRole('button', { name: 'Duyệt ghi nợ' });
  await expect(approve).toBeDisabled();
  await expect(approve).toHaveAccessibleDescription(/Bán ghi nợ chưa được bật cho chi nhánh này/);

  const second = list.getByRole('listitem').filter({ hasText: 'R800' });
  await second.getByRole('button', { name: 'Từ chối' }).click();
  await second.getByLabel('Lý do từ chối').fill('Tạm dừng bán ghi nợ');
  await second.getByRole('button', { name: 'Từ chối' }).click();
  await expect(page.getByText('Đã từ chối ghi nợ cho đơn R800.')).toBeVisible();
  await list.getByRole('listitem').filter({ hasText: 'R900' }).getByRole('button', { name: 'Thu hồi duyệt' }).click();
  await expect(page.getByText('Đã thu hồi duyệt cho đơn R900.')).toBeVisible();

  expect(api.decisions.map(({ id, decision }) => [id, decision])).toEqual([
    ['poscreditreq_2', 'reject'],
    ['poscreditreq_3', 'revoke'],
  ]);
});
