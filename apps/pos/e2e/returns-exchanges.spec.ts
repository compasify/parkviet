import { expect, type Page, test } from '@playwright/test';

// In-memory POS API for order history, returns, refunds and exchanges. It
// enforces the rules the client must not bypass (returnable quantities,
// approval before payout) and keeps request bodies for assertions.

const workspace = {
  id: 'ws_1',
  branch_id: 'br_1',
  register_id: 'reg_1',
  shift_id: 'sh_1',
  order_id: 'or_new',
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
  financial: null,
};

type ReturnState = {
  status: 'pending_approval' | 'ready' | 'received' | 'canceled';
  entitlement_status: 'pending' | 'posted';
  approval: { id: string; status: string; expires_at: string } | null;
  quantity: number;
  condition: string;
  refunds: Array<Record<string, unknown> & { id: string; status: string; approval: unknown }>;
  exchanged: boolean;
};

function orderRow() {
  return {
    id: 'or_100',
    number: 'R100',
    workspace_id: 'ws_old',
    placed_at: '2026-11-06T03:00:00Z',
    register: 'Quầy 1',
    cashier: 'Lan',
    cashier_id: 'stf_1',
    customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '•••••••567' },
    currency: 'VND',
    total: '300000.0',
    paid: '300000.0',
    debt: null,
    returned: false,
    refund_pending: false,
  };
}

// Effective branch switches as the server sends them in the context: all on
// unless a test switches one off.
const FEATURES_ON: Record<string, boolean> = {
  credit: true,
  returns: true,
  refunds: true,
  exchanges: true,
  traceability: true,
  customer_display: true,
  cash_moves: true,
  exports: true,
};

async function mockPos(
  page: Page,
  options: { capabilities: string[]; staffId?: string; features?: Record<string, boolean> } = { capabilities: [] },
) {
  const capabilities = options.capabilities;
  const staffId = options.staffId ?? 'stf_1';
  const features = { ...FEATURES_ON, ...options.features };
  const state: ReturnState = {
    status: 'ready',
    entitlement_status: 'pending',
    approval: null,
    quantity: 0,
    condition: 'resellable',
    refunds: [],
    exchanged: false,
  };
  // Commands the "server" committed, by idempotency key, for receipt lookups;
  // paths whose next response is lost after the server recorded it.
  const committed = new Map<string, unknown>();
  // The client retries a keyed POST twice on a network error, so a response
  // must be lost three times in a row before the browser gives up.
  const loseNext = new Map<string, number>();
  const resolutions: Array<Record<string, unknown>> = [];
  const orderQueries: Array<Record<string, string>> = [];
  const previews: Array<Record<string, unknown>> = [];
  const prepares: Array<Record<string, unknown>> = [];
  const refundRequests: Array<{ key: string | null; body: Record<string, unknown> }> = [];
  const confirmations: Array<Record<string, unknown>> = [];
  const exchanges: Array<Record<string, unknown>> = [];
  const approvals: string[] = [];
  let refundApproved = false;

  const returnLine = () => ({
    id: 'posretline_1',
    sale_line_id: 'possaleline_1',
    name: 'Gạo ST25',
    sku: 'GAO-1',
    quantity: state.quantity,
    sequence: 1,
    cumulative_before: 0,
    cumulative_after: state.quantity,
    condition: state.condition,
    status: state.entitlement_status === 'posted' ? 'posted' : 'reserved',
    received_quantity: state.status === 'received' ? state.quantity : 0,
    restocked_quantity: state.status === 'received' && state.condition === 'resellable' ? state.quantity : 0,
    total: `${state.quantity * 100000}.0`,
    net: `${state.quantity * 100000}.0`,
    tax: '0.0',
    discount: '0.0',
    gross: `${state.quantity * 100000}.0`,
  });
  const returned = () => {
    const value = state.quantity * 100000;
    const requested = state.refunds
      .filter((refund) => ['reserved', 'unknown', 'confirmed'].includes(refund.status))
      .reduce((sum, refund) => sum + Number.parseInt(String(refund.amount), 10), 0);
    const posted = state.entitlement_status === 'posted';
    return {
      id: 'posreturn_1',
      branch_id: 'br_1',
      sale_branch_id: 'br_1',
      workspace_id: 'ws_old',
      order_id: 'or_100',
      order_number: 'R100',
      return_number: 'RET100',
      requester_id: 'stf_1',
      requester_name: 'Lan',
      status: state.status,
      entitlement_status: state.entitlement_status,
      reason: 'Vỡ bao',
      cross_branch: false,
      out_of_window: false,
      damaged: state.condition === 'damaged',
      requires_approval: state.condition === 'damaged',
      revision: 1,
      approval: state.approval,
      currency: 'VND',
      entitlement_total: `${value}.0`,
      credit_note_amount: '0.0',
      refund_entitlement: posted ? `${value}.0` : '0.0',
      refund_requested: '0.0',
      refunded: '0.0',
      expected_credit_note: '0.0',
      expected_refund: `${value}.0`,
      expires_at: null,
      refundable_remaining: posted ? `${value - requested}.0` : '0.0',
      lines: [returnLine()],
      refund_requests: state.refunds,
      exchange_id: state.exchanged ? 'posexchange_1' : null,
      created_at: '2026-11-07T03:00:00Z',
      received_at: null,
      posted_at: null,
      canceled_at: null,
    };
  };
  const detail = () => ({
    ...orderRow(),
    sale_branch_id: 'br_1',
    totals: { original_total: '300000.0', item_total: '300000.0', discount_total: '0.0', tax_total: '0.0' },
    lines: [
      {
        sale_line_id: 'possaleline_1',
        name: 'Gạo ST25',
        sku: 'GAO-1',
        sale_quantity: '3.0',
        sale_unit: 'item',
        base_quantity: 3,
        base_unit: 'item',
        unit_price: '100000.0',
        lot_code: null,
        serial_codes: [],
        original: { total: '300000.0', net: '300000.0', tax: '0.0', discount: '0.0', gross: '300000.0' },
        returned_quantity: state.quantity,
        posted_quantity: 0,
        returnable_quantity: 3 - state.quantity,
        handed_over: true,
        entitlement_used: '0.0',
        entitlement_reserved: '0.0',
      },
    ],
    entitlement: { used: '0.0', reserved: '0.0', credit_notes: '0.0', refund_entitlement: '0.0' },
    receipts: [
      {
        allocation_id: 'posalloc_1',
        funds_id: 'posfunds_1',
        kind: 'cash',
        status: 'active',
        amount: '300000.0',
        refunded: '0.0',
        refund_reserved: '0.0',
        refundable: '300000.0',
        collection: false,
        reference: null,
        received_at: '2026-11-06T03:00:00Z',
      },
    ],
    refunds: [],
    credit: null,
    returns: [],
    exchanges: [],
    stock: {
      location_id: 'sloc_1',
      fulfillments: [{ id: 'ful_1', status: 'fulfilled', location_id: 'sloc_1', fulfilled_at: '2026-11-06T03:01:00Z' }],
      restocked_quantity: 0,
      damaged_quantity: 0,
      discrepancies: [],
    },
    timeline: [
      { id: 'or_100:placed', at: '2026-11-06T03:00:00Z', kind: 'placed', amount: '300000.0' },
      { id: 'posalloc_1:receipt', at: '2026-11-06T03:00:00Z', kind: 'receipt', amount: '300000.0' },
      { id: 'ful_1:handed_over', at: '2026-11-06T03:01:00Z', kind: 'handed_over', amount: null },
    ],
  });

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    const body = () => (request.postDataJSON() ?? {}) as Record<string, unknown>;
    const conflict = (message: string, reason?: string, extra: Record<string, unknown> = {}) =>
      route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message, details: reason ? { reason, ...extra } : extra } },
      });
    // Like the server: a switched-off feature refuses only NEW commands; a
    // replay of a command it already recorded answers with the stored result.
    const refuseNew = (feature: string) => {
      const key = request.headers()['idempotency-key'];
      if (features[feature] === true) return null;
      if (key && committed.has(key)) return route.fulfill({ json: { data: committed.get(key) } });
      return conflict(`${feature} is turned off.`, 'feature_disabled', { feature });
    };
    if (path === '/auth/login' || path === '/auth/refresh') return route.fulfill({ json: { token: 'test-token' } });
    if (path === '/me') return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path === '/pos/context/branches')
      return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path === '/pos/context/registers')
      return route.fulfill({
        json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } },
      });
    if (path === '/pos/context') {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: staffId, email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? capabilities : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', branch_id: 'br_1', owner_id: staffId, opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
          features,
        },
      });
    }
    if (path === '/pos/workspaces' && method === 'GET')
      return route.fulfill({ json: { data: [workspace], meta: { page: 1, pages: 1, count: 1 } } });
    if (path === '/pos/command_receipts') {
      const found = committed.get(url.searchParams.get('idempotency_key') ?? '');
      return found
        ? route.fulfill({ json: { data: found } })
        : route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
    }
    // The server records the command, then the response never arrives.
    const answer = async (lost: string, key: string | undefined, data: unknown, status = 200) => {
      if (key) committed.set(key, data);
      const left = loseNext.get(lost) ?? 0;
      if (left > 0) {
        loseNext.set(lost, left - 1);
        return route.abort('connectionreset');
      }
      return route.fulfill({ status, json: { data } });
    };
    const keyOf = () => request.headers()['idempotency-key'];
    if (path === '/pos/orders' && method === 'GET') {
      orderQueries.push(Object.fromEntries(url.searchParams.entries()));
      const number = url.searchParams.get('number');
      const rows = !number || 'R100'.includes(number.toUpperCase()) ? [orderRow()] : [];
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    if (path === '/pos/orders/or_100' || path === '/pos/orders/lookup') return route.fulfill({ json: { data: detail() } });
    if (path === '/pos/returns/preview') {
      const input = body();
      previews.push(input);
      const [line] = input.lines as Array<{ quantity: number; condition: string }>;
      const value = `${line.quantity * 100000}.0`;
      return route.fulfill({
        json: {
          data: {
            order_id: 'or_100',
            order_number: 'R100',
            currency: 'VND',
            cross_branch: false,
            out_of_window: false,
            damaged: line.condition === 'damaged',
            requires_approval: line.condition === 'damaged',
            entitlement_total: value,
            credit_note: '0.0',
            refund: value,
            unrefundable: '0.0',
            lines: [
              {
                sale_line_id: 'possaleline_1',
                quantity: line.quantity,
                condition: line.condition,
                sold_quantity: 3,
                cumulative_before: 0,
                cumulative_after: line.quantity,
                remaining_before: 3,
                original: { total: '300000.0', net: '300000.0', tax: '0.0', discount: '0.0', gross: '300000.0' },
                used: '0.0',
                reserved: '0.0',
                this_time: { total: value, net: value, tax: '0.0', discount: '0.0', gross: value },
              },
            ],
          },
        },
      });
    }
    if (path === '/pos/returns' && method === 'POST') {
      const input = body();
      prepares.push(input);
      const off = refuseNew('returns');
      if (off) return off;
      const [line] = input.lines as Array<{ quantity: number; condition: string }>;
      if (line.quantity > 3) return conflict('Too many', 'exceeds_returnable');
      state.quantity = line.quantity;
      state.condition = line.condition;
      state.status = line.condition === 'damaged' ? 'pending_approval' : 'ready';
      return answer('prepare', keyOf(), returned(), 201);
    }
    if (path === '/pos/returns' && method === 'GET') {
      const rows = state.status === 'pending_approval' && !state.approval ? [returned()] : [];
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    if (path === '/pos/returns/posreturn_1' && method === 'GET') return route.fulfill({ json: { data: returned() } });
    if (path === '/pos/returns/posreturn_1/approve' && method === 'POST') {
      approvals.push('return');
      state.approval = { id: 'posapproval_ret', status: 'active', expires_at: '2026-11-07T04:00:00Z' };
      return route.fulfill({ json: { data: returned() } });
    }
    if (path === '/pos/returns/posreturn_1/receive' && method === 'POST') {
      if (state.status === 'pending_approval' && body().approval_id !== 'posapproval_ret')
        return conflict('This return needs an approval.', 'approval_required');
      state.status = 'received';
      state.entitlement_status = 'posted';
      return route.fulfill({ json: { data: returned() } });
    }
    if (path === '/pos/refund_requests' && method === 'GET') {
      const rows = state.refunds.filter((refund) => ['reserved', 'unknown'].includes(refund.status));
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    if (path === '/pos/refund_requests' && method === 'POST') {
      const input = body();
      refundRequests.push({ key: request.headers()['idempotency-key'] ?? null, body: input });
      const off = refuseNew('refunds');
      if (off) return off;
      const refund = {
        id: 'posrefund_1',
        return_id: 'posreturn_1',
        branch_id: 'br_1',
        order_id: 'or_100',
        order_number: 'R100',
        allocation_id: String(input.allocation_id),
        funds_id: 'posfunds_1',
        funds_kind: 'cash',
        method: String(input.method),
        status: 'reserved',
        amount: `${input.amount}.0`,
        currency: 'VND',
        revision: 1,
        requester_id: 'stf_1',
        confirmer_id: null,
        shift_id: null,
        refund_id: null,
        beneficiary_reference: (input.beneficiary_reference as string) ?? null,
        approval: null,
        evidence: null,
        created_at: '2026-11-07T03:10:00Z',
        confirmed_at: null,
        resolved_at: null,
      };
      state.refunds = [refund];
      return answer('refund', keyOf(), refund, 201);
    }
    if (path === '/pos/refund_requests/posrefund_1/approve' && method === 'POST') {
      approvals.push('refund');
      refundApproved = true;
      state.refunds[0].approval = { id: 'posapproval_ref', status: 'active', expires_at: '2026-11-07T04:00:00Z' };
      return route.fulfill({ json: { data: state.refunds[0] } });
    }
    if (path === '/pos/refund_requests/posrefund_1/confirmation' && method === 'POST') {
      const input = body();
      confirmations.push(input);
      if (!refundApproved) return conflict('This refund needs an approval.', 'approval_required');
      state.refunds[0] = { ...state.refunds[0], status: 'confirmed', confirmed_at: '2026-11-07T03:20:00Z' };
      return route.fulfill({ json: { data: state.refunds[0] } });
    }
    const exchange = () => ({
      id: 'posexchange_1',
      return_id: 'posreturn_1',
      replacement_workspace_id: 'ws_2',
      replacement_order_number: 'R101',
      replacement_status: 'editing',
      replacement_total: '0.0',
      credit_note_amount: '0.0',
      refund_entitlement: `${state.quantity * 100000}.0`,
      refunded: state.refunds.some((refund) => refund.status === 'confirmed')
        ? `${state.quantity * 100000}.0`
        : '0.0',
      refund_owed: state.refunds.some((refund) => refund.status === 'confirmed')
        ? '0.0'
        : `${state.quantity * 100000}.0`,
      // The replacement has no total yet, so no difference is offered.
      customer_pays: null,
      store_refunds: null,
      currency: 'VND',
    });
    if (path === '/pos/exchanges' && method === 'POST') {
      exchanges.push(body());
      const off = refuseNew('exchanges');
      if (off) return off;
      state.exchanged = true;
      return answer('exchange', keyOf(), exchange(), 201);
    }
    if (path === '/pos/exchanges/posexchange_1') return route.fulfill({ json: { data: exchange() } });
    if (path === '/pos/refund_requests/posrefund_1/resolution' && method === 'POST') {
      const input = body();
      resolutions.push(input);
      const status = input.outcome === 'cancel' ? 'canceled' : input.outcome === 'failed_no_effect' ? 'failed' : 'unknown';
      state.refunds[0] = { ...state.refunds[0], status };
      return route.fulfill({ json: { data: state.refunds[0] } });
    }
    if (path.startsWith('/pos/credit_requests'))
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  return {
    state,
    orderQueries,
    previews,
    prepares,
    refundRequests,
    confirmations,
    exchanges,
    approvals,
    resolutions,
    loseNext,
    approveReturn: () => {
      state.approval = { id: 'posapproval_ret', status: 'active', expires_at: '2026-11-07T04:00:00Z' };
    },
    approveRefund: () => {
      refundApproved = true;
      state.refunds[0].approval = { id: 'posapproval_ref', status: 'active', expires_at: '2026-11-07T04:00:00Z' };
    },
  };
}

const CASHIER = ['pos.shift.open', 'pos.payment.collect', 'pos.return.process'];

async function login(page: Page) {
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function openMenuLink(page: Page, name: string) {
  await page.locator('.pos-context-details summary').click();
  await page.getByRole('link', { name, exact: true }).first().click();
}

test('order history filters on the server and shows the order timeline', async ({ page }) => {
  const api = await mockPos(page, { capabilities: CASHIER });
  await login(page);
  await openMenuLink(page, 'Đơn hàng');
  await expect(page.getByRole('heading', { name: 'Đơn hàng', level: 1 })).toBeVisible();
  const list = page.getByRole('list', { name: 'Danh sách đơn hàng' });
  await expect(list.getByRole('listitem')).toHaveCount(1);

  await page.getByLabel('Số đơn').fill('R1');
  await page.getByLabel('Trạng thái').selectOption('returned');
  await page.getByRole('button', { name: 'Tìm', exact: true }).click();
  await expect.poll(() => api.orderQueries.at(-1)).toMatchObject({ branch_id: 'br_1', number: 'R1', status: 'returned' });

  await list.getByRole('button', { name: /R100/ }).click();
  const detail = page.getByRole('region', { name: 'Chi tiết đơn' });
  await expect(detail).toContainText('Đơn R100');
  await expect(detail).toContainText('300.000 ₫');
  await expect(detail.getByRole('list').last()).toContainText('Giao hàng');
  await expect(detail.locator('.order-timeline')).toContainText('Hoàn tất đơn');
  await expect(detail.getByRole('link', { name: 'Trả / đổi hàng' })).toBeVisible();
});

test('return wizard: preview, approval wait, receive, refund with evidence and exchange', async ({ page }) => {
  const api = await mockPos(page, { capabilities: CASHIER });
  await login(page);
  await openMenuLink(page, 'Đơn hàng');
  await page.getByRole('list', { name: 'Danh sách đơn hàng' }).getByRole('button', { name: /R100/ }).click();
  await page.getByRole('region', { name: 'Chi tiết đơn' }).getByRole('link', { name: 'Trả / đổi hàng' }).click();
  await expect(page.getByRole('heading', { name: 'Trả hàng đơn R100' })).toBeVisible();

  const quantity = page.getByLabel('Gạo ST25', { exact: true });
  await quantity.fill('4');
  await expect(page.getByText('Số lượng vượt quá phần còn trả được.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Xem trước' })).toBeDisabled();
  await quantity.fill('2');
  await page.getByLabel('Tình trạng Gạo ST25').selectOption('damaged');
  await page.getByRole('button', { name: 'Xem trước' }).click();

  const preview = page.getByRole('region', { name: 'Xem trước giá trị trả' });
  await expect(preview).toContainText('0 → 2 / 3');
  await expect(preview).toContainText('200.000 ₫');
  await expect(preview).toContainText('Cần người duyệt: hàng hư hỏng.');
  expect(api.previews[0]).toMatchObject({
    branch_id: 'br_1',
    order_id: 'or_100',
    lines: [{ sale_line_id: 'possaleline_1', quantity: 2, condition: 'damaged' }],
  });

  await page.getByLabel('Lý do trả').fill('Vỡ bao');
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await expect(page.getByText('Chờ duyệt', { exact: true })).toBeVisible();
  // The return is reopened from its address after a reload.
  await expect(page).toHaveURL(/returnId=posreturn_1/);
  await page.reload();
  await expect(page.getByRole('heading', { name: 'Phiếu RET100 · R100' })).toBeVisible();
  await expect(page.getByText(/Đang chờ người duyệt/)).toBeVisible();
  await expect(page.getByRole('button', { name: 'Nhận hàng trả' })).toHaveCount(0);

  api.approveReturn();
  await expect(page.getByRole('button', { name: 'Nhận hàng trả' })).toBeVisible({ timeout: 12_000 });
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  await expect(page.getByText('Đã nhận hàng · đã ghi giá trị')).toBeVisible();

  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  await expect(refund.getByLabel('Số tiền hoàn')).toHaveValue('200.000');
  await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
  await expect(refund).toContainText('Chờ chi · chờ duyệt');
  expect(api.refundRequests[0].body).toMatchObject({
    return_id: 'posreturn_1',
    allocation_id: 'posalloc_1',
    amount: '200000',
    method: 'cash',
  });
  expect(api.refundRequests[0].key).toBeTruthy();

  await refund.getByRole('button', { name: 'Xác nhận chi' }).click();
  const dialog = page.getByRole('dialog', { name: 'Chi tiền mặt hoàn khách' });
  await expect(dialog.getByRole('button', { name: 'Xác nhận đã chi' })).toBeDisabled();
  await dialog.getByLabel(/đếm và đưa khách đủ 200.000 ₫/).check();
  await dialog.getByRole('button', { name: 'Xác nhận đã chi' }).click();
  await expect(dialog.getByRole('alert')).toHaveText('Cần người duyệt trước khi thực hiện.');
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  await expect(refund.getByRole('button', { name: 'Xác nhận chi' })).toBeFocused();

  api.approveRefund();
  await expect(refund).not.toContainText('chờ duyệt', { timeout: 12_000 });
  await refund.getByRole('button', { name: 'Xác nhận chi' }).click();
  await dialog.getByLabel(/đếm và đưa khách đủ/).check();
  await dialog.getByRole('button', { name: 'Xác nhận đã chi' }).click();
  await expect(dialog).toHaveCount(0);
  await expect(refund).toContainText('Đã chi');
  expect(api.confirmations.at(-1)).toMatchObject({ evidence_kind: 'cash_count', approval_id: 'posapproval_ref' });

  await page.getByRole('button', { name: 'Đổi hàng: mở đơn bán mới' }).click();
  await expect(page.getByText('Đã mở đơn đổi R101.')).toBeVisible();
  // The refund was already paid and the new sale is still empty: nothing is
  // shown as owed either way until the replacement has a total.
  await expect(page.getByText(/Đơn đổi chưa có hàng. Phần còn phải hoàn khách: 0 ₫/)).toBeVisible();
  expect(api.exchanges[0]).toMatchObject({ return_id: 'posreturn_1', register_id: 'reg_1' });
  expect(typeof api.exchanges[0].editor_id).toBe('string');

  // The summary comes from the server, so it survives a reload.
  await page.reload();
  await expect(page.getByText('Đã mở đơn đổi R101.')).toBeVisible();
  await page.getByRole('button', { name: 'Mở màn hình bán' }).click();
  await expect(page).toHaveURL(/\/pos\/?$/);
  const layout = await page.evaluate(() => localStorage.getItem('parkviet-pos-layout'));
  expect(JSON.parse(layout ?? '{}')).toMatchObject({ activeWorkspaceId: 'ws_2' });
});

test('an approver approves pending returns and refunds on the Duyệt page', async ({ page }) => {
  const api = await mockPos(page, {
    capabilities: ['pos.shift.open', 'pos.approval.grant', 'pos.return.process'],
    staffId: 'stf_9',
  });
  api.state.quantity = 1;
  api.state.condition = 'damaged';
  api.state.status = 'pending_approval';
  await login(page);
  await openMenuLink(page, 'Duyệt');
  const list = page.getByRole('list', { name: 'Trả hàng và hoàn tiền chờ duyệt' });
  await expect(list).toContainText('RET100 · R100');
  await expect(list).toContainText('hàng hư hỏng');
  await list.getByRole('button', { name: 'Duyệt', exact: true }).click();
  await expect(page.getByText('Đã duyệt phiếu trả RET100.')).toBeVisible();
  expect(api.approvals).toEqual(['return']);
});

test('returns stay hidden without the return capability', async ({ page }) => {
  await mockPos(page, { capabilities: ['pos.shift.open', 'pos.payment.collect'] });
  await login(page);
  await page.locator('.pos-context-details summary').click();
  await expect(page.getByRole('link', { name: 'Đơn hàng', exact: true })).toBeVisible();
  await expect(page.getByRole('link', { name: 'Trả / đổi hàng', exact: true })).toHaveCount(0);
});

async function preparedReturn(page: Page, api: Awaited<ReturnType<typeof mockPos>>) {
  await page.goto('/pos/returns?orderId=or_100');
  await expect(page.getByRole('heading', { name: 'Trả hàng đơn R100' })).toBeVisible();
  await page.getByLabel('Gạo ST25', { exact: true }).fill('1');
  await page.getByRole('button', { name: 'Xem trước' }).click();
  await page.getByLabel('Lý do trả').fill('Khách đổi ý');
  void api;
}

test('a prepare whose response was lost is recovered from its receipt, never sent twice', async ({ page }) => {
  const api = await mockPos(page, { capabilities: CASHIER });
  await login(page);
  await preparedReturn(page, api);
  api.loseNext.set('prepare', 3);
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await expect(page.getByRole('alert')).toHaveText(/đang kiểm tra kết quả/, { timeout: 15_000 });
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await expect(page.getByRole('heading', { name: 'Phiếu RET100 · R100' })).toBeVisible();
  // Every attempt carried the one stored key; the server replays it, so a
  // single return exists however often the cashier pressed the button.
  expect(new Set(api.prepares.map((body) => body.idempotency_key)).size).toBe(1);
  expect(api.state.quantity).toBe(1);
});

test('a refund request whose response was lost is checked on screen and not requested again', async ({ page }) => {
  const api = await mockPos(page, { capabilities: CASHIER });
  await login(page);
  await preparedReturn(page, api);
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  api.loseNext.set('refund', 3);
  await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
  await expect(page.getByRole('alert')).toHaveText(/đang kiểm tra kết quả/, { timeout: 15_000 });
  const recheck = page
    .getByRole('region', { name: 'Phiếu trả hàng' })
    .getByRole('button', { name: 'Kiểm tra lại' })
    .first();
  await expect(recheck).toBeVisible({ timeout: 10_000 });
  // While unconfirmed, no new refund can be requested for this return (the
  // form is disabled, or gone once the request shows as recorded).
  const again = refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' });
  if (await again.count()) await expect(again).toBeDisabled();
  await recheck.click();
  await expect(page.getByText('Yêu cầu trước đó đã được ghi nhận.')).toBeVisible();
  await expect(refund).toContainText('Chờ chi');
  expect(new Set(api.refundRequests.map((row) => row.key)).size).toBe(1);
});

test('a reserved refund is canceled with a reason; a resolver records an unknown one as no effect', async ({ page }) => {
  const api = await mockPos(page, { capabilities: [...CASHIER, 'pos.payment.resolve'] });
  await login(page);
  await preparedReturn(page, api);
  await page.getByRole('button', { name: 'Lập phiếu trả' }).click();
  await page.getByRole('button', { name: 'Nhận hàng trả' }).click();
  const refund = page.getByRole('region', { name: 'Hoàn tiền' });
  await refund.getByRole('button', { name: 'Yêu cầu hoàn tiền' }).click();
  await refund.getByRole('button', { name: 'Hủy yêu cầu' }).click();
  await expect(refund.getByRole('button', { name: 'Xác nhận hủy' })).toBeDisabled();
  await refund.getByLabel('Lý do hủy').fill('Khách nhận đổi hàng');
  await refund.getByRole('button', { name: 'Xác nhận hủy' }).click();
  await expect(refund).toContainText('Đã hủy');
  expect(api.resolutions[0]).toMatchObject({ outcome: 'cancel', reason: 'Khách nhận đổi hàng' });

  api.state.refunds[0] = { ...api.state.refunds[0], status: 'unknown' };
  await page.reload();
  await refund.getByRole('button', { name: 'Không thực hiện (có chứng từ)' }).click();
  await refund.getByLabel(/Chứng từ không chi/).fill('Sao kê 07/11 không có lệnh');
  await refund.getByRole('button', { name: 'Ghi nhận không thực hiện' }).click();
  await expect.poll(() => api.resolutions.length).toBe(2);
  await expect(refund.locator('.status-tag')).toHaveText('Không thực hiện');
  expect(api.resolutions[1]).toMatchObject({ outcome: 'failed_no_effect', reference: 'Sao kê 07/11 không có lệnh' });
});

