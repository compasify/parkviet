import { expect, type Page, type Route, test } from '@playwright/test';

// Serial and lot stock against an in-memory POS API: the inventory page, a
// sale whose traced stock must be held before payment, and a return that
// names the serial coming back. Request bodies are kept for assertions.

// Dates relative to the real clock, so near-expiry and expired stay true.
function dayOffset(days: number) {
  return new Date(Date.now() + days * 86_400_000).toISOString().slice(0, 10);
}
function printed(date: string) {
  const [year, month, day] = date.split('-');
  return `${day}/${month}/${year}`;
}
const NEAR = dayOffset(10);
const PAST = dayOffset(-5);
const LATER = dayOffset(200);

type Write = { method: string; path: string; key: string | undefined; body: Record<string, unknown> };

function lot(id: string, code: string, expiry: string, extra: Record<string, unknown> = {}) {
  return {
    id,
    variant_id: 'v_yogurt',
    sku: 'SUA-1',
    name: 'Sữa chua',
    stock_location_id: 'sloc_1',
    branch_id: 'br_1',
    lot_code: code,
    expiry_on: expiry,
    status: 'active',
    received_quantity: 10,
    on_hand: 6,
    quarantined_quantity: 0,
    reserved: 1,
    committed: 1,
    available: 4,
    base_unit: 'hộp',
    source_lot_id: null,
    quarantine_reason: null,
    created_at: '2026-11-01T02:00:00Z',
    ...extra,
  };
}

function status(variant: 'phone' | 'yogurt', extra: Record<string, unknown> = {}) {
  const phone = variant === 'phone';
  return {
    variant_id: phone ? 'v_phone' : 'v_yogurt',
    sku: phone ? 'DT-1' : 'SUA-1',
    name: phone ? 'Điện thoại A' : 'Sữa chua',
    tracked_mode: phone ? 'serial' : 'lot',
    stock_location_id: 'sloc_1',
    base_unit: phone ? 'cái' : 'hộp',
    sale_unit: phone ? 'cái' : 'hộp',
    enrolled: !phone,
    reconciled: !phone,
    sellable: !phone,
    blocked_reason: phone ? 'not_enrolled' : null,
    core_on_hand: phone ? 3 : 6,
    typed_on_hand: phone ? null : 6,
    lot_selection: 'fefo',
    lots: [],
    serials_available: phone ? 3 : 0,
    ...extra,
  };
}

function adjustment(id: string, requester: string, extra: Record<string, unknown> = {}) {
  return {
    id,
    branch_id: 'br_1',
    variant_id: 'v_yogurt',
    sku: 'SUA-1',
    name: 'Sữa chua',
    reason: 'Đếm lại',
    status: 'pending_approval',
    requires_approval: true,
    delta: -3,
    revision: 1,
    lines: [{ kind: 'lot', lot_id: 'lot_1', lot_code: 'L-01', before: 6, after: 3, delta: -3 }],
    requester_id: requester,
    requester_name: requester === 'stf_1' ? 'Lan' : 'Minh',
    approval: null,
    created_at: '2026-11-07T03:00:00Z',
    applied_at: null,
    ...extra,
  };
}

const WORKSPACE_TOTALS = {
  item_total: '2600000.0',
  discount_total: '0.0',
  manual_discount_total: '0.0',
  included_tax_total: '0.0',
  additional_tax_total: '0.0',
  total: '2600000.0',
  currency: 'VND',
};

type Sheet = {
  revision: number;
  reserved: boolean;
  added: string[];
};

function workspace(sheet: Sheet) {
  const lotLine = {
    id: 'li_lot',
    sale_line_id: 'sl_lot',
    variant_id: 'v_yogurt',
    product_id: 'p_yogurt',
    name: 'Sữa chua',
    sku: 'SUA-1',
    quantity: 2,
    price: '50000.0',
    unit_price: '50000.0',
    list_price: '50000.0',
    amount: '100000.0',
    discounts: [],
    kind: 'tracked',
    tracked_mode: 'lot',
    base_unit: 'hộp',
    trace: {
      mode: 'lot',
      complete: sheet.reserved,
      issue: null,
      allocations: sheet.reserved
        ? [{ id: 'al_lot', kind: 'lot', serial: null, lot_code: 'L-01', expiry_on: NEAR, quantity: 2, status: 'reserved', expires_at: null }]
        : [],
      preview: sheet.reserved ? [] : [{ lot_code: 'L-01', expiry_on: NEAR, quantity: 2 }],
    },
  };
  const serialLine = {
    id: 'li_phone',
    sale_line_id: 'sl_phone',
    variant_id: 'v_phone',
    product_id: 'p_phone',
    name: 'Điện thoại A',
    sku: 'DT-1',
    quantity: 1,
    price: '2500000.0',
    unit_price: '2500000.0',
    list_price: '2500000.0',
    amount: '2500000.0',
    discounts: [],
    kind: 'tracked',
    tracked_mode: 'serial',
    base_unit: 'cái',
    trace: {
      mode: 'serial',
      complete: sheet.reserved,
      issue: sheet.reserved ? null : 'trace_serial_released',
      allocations: [
        { id: 'al_sn1', kind: 'serial', serial: 'SN-1', lot_code: null, expiry_on: null, quantity: 1, status: 'reserved', expires_at: null },
      ],
      preview: [],
    },
  };
  const added = sheet.added.length
    ? [
        {
          ...serialLine,
          id: 'li_phone_2',
          sale_line_id: 'sl_phone_2',
          quantity: sheet.added.length,
          trace: {
            mode: 'serial',
            complete: true,
            issue: null,
            allocations: sheet.added.map((serial) => ({
              id: `al_${serial}`,
              kind: 'serial',
              serial,
              lot_code: null,
              expiry_on: null,
              quantity: 1,
              status: 'reserved',
              expires_at: null,
            })),
            preview: [],
          },
        },
      ]
    : [];
  return {
    id: 'ws_1',
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: 'R200',
    revision: sheet.revision,
    lease_generation: 1,
    operational_status: 'editing',
    payments: false,
    note: null,
    customer: null,
    discount: null,
    line_items: [lotLine, serialLine, ...added],
    totals: WORKSPACE_TOTALS,
    financial: {
      received: '0.0',
      allocated: '0.0',
      unapplied: '0.0',
      remaining: '2600000.0',
      change_due: '0.0',
      attempts: [],
    },
    trace: sheet.reserved
      ? { ready: true, issues: [] }
      : { ready: false, issues: [{ sale_line_id: 'sl_phone', reason: 'trace_serial_released' }] },
  };
}

function orderDetail() {
  const line = (id: string, name: string, quantity: number, trace: Record<string, unknown>) => ({
    sale_line_id: id,
    name,
    sku: null,
    sale_quantity: `${quantity}.0`,
    sale_unit: 'item',
    base_quantity: quantity,
    base_unit: 'item',
    unit_price: '100000.0',
    lot_code: null,
    serial_codes: [],
    original: { total: `${quantity * 100000}.0`, net: `${quantity * 100000}.0`, tax: '0.0', discount: '0.0', gross: `${quantity * 100000}.0` },
    returned_quantity: id === 'sl_phone' ? 1 : 0,
    posted_quantity: 0,
    returnable_quantity: id === 'sl_phone' ? 2 : quantity,
    handed_over: true,
    entitlement_used: '0.0',
    entitlement_reserved: '0.0',
    trace,
  });
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
    total: '800000.0',
    paid: '800000.0',
    debt: null,
    returned: true,
    refund_pending: false,
    sale_branch_id: 'br_1',
    totals: { original_total: '800000.0', item_total: '800000.0', discount_total: '0.0', tax_total: '0.0' },
    lines: [
      line('sl_phone', 'Điện thoại A', 3, {
        mode: 'serial',
        allocations: ['SN-1', 'SN-2', 'SN-3'].map((serial) => ({
          serial,
          lot_code: null,
          expiry_on: null,
          quantity: 1,
          returned_quantity: serial === 'SN-1' ? 1 : 0,
        })),
      }),
      line('sl_lot', 'Sữa chua', 5, {
        mode: 'lot',
        allocations: [
          { serial: null, lot_code: 'L-01', expiry_on: PAST, quantity: 2, returned_quantity: 0 },
          { serial: null, lot_code: 'L-02', expiry_on: LATER, quantity: 3, returned_quantity: 0 },
        ],
      }),
    ],
    entitlement: { used: '0.0', reserved: '0.0', credit_notes: '0.0', refund_entitlement: '0.0' },
    receipts: [],
    refunds: [],
    credit: null,
    returns: [],
    exchanges: [],
    stock: { location_id: 'sloc_1', fulfillments: [], restocked_quantity: 0, damaged_quantity: 0, discrepancies: [] },
    timeline: [],
  };
}

async function mockPos(page: Page, capabilities: string[]) {
  const writes: Write[] = [];
  const reads: Array<{ path: string; params: Record<string, string> }> = [];
  const sheet: Sheet = { revision: 1, reserved: false, added: [] };
  const lots = [lot('lot_1', 'L-01', NEAR), lot('lot_0', 'L-00', PAST, { status: 'expired', available: 0 })];
  const pending = [adjustment('adj_other', 'stf_2')];
  const one = { page: 1, pages: 1, count: 1 };
  // Commands the "server" committed, by idempotency key, for receipt lookups;
  // paths whose next responses are lost after the server recorded them. The
  // client retries a keyed POST twice on a network error, so a response is
  // lost three times in a row before the browser gives up.
  const committed = new Map<string, unknown>();
  const loseNext = new Map<string, number>();

  await page.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    const body = (request.postDataJSON() ?? {}) as Record<string, unknown>;
    const data = (value: unknown, status = 200) => route.fulfill({ status, json: { data: value } });
    const conflict = (reason: string, message = 'Conflict') =>
      route.fulfill({ status: 409, json: { error: { code: 'conflict', message, details: { reason } } } });
    if (method !== 'GET') writes.push({ method, path, key: request.headers()['idempotency-key'], body });
    else reads.push({ path, params: Object.fromEntries(url.searchParams.entries()) });

    if (path === '/auth/login' || path === '/auth/refresh') return route.fulfill({ json: { token: 'test-token' } });
    if (path === '/me') return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path === '/pos/context/branches')
      return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: one } });
    if (path === '/pos/context/registers')
      return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }], meta: one } });
    if (path === '/pos/context') {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? capabilities : [],
          branches: [
            { id: 'br_1', name: 'Branch', status: 'active', timezone: 'Asia/Ho_Chi_Minh' },
            { id: 'br_2', name: 'Chi nhánh 2', status: 'active', timezone: 'Asia/Ho_Chi_Minh' },
          ],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    if (path === '/pos/command_receipts') {
      const found = committed.get(url.searchParams.get('idempotency_key') ?? '');
      return found
        ? data(found)
        : route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
    }
    // Records a stock command under its key, then maybe loses the response.
    const answer = async (value: unknown, status = 201) => {
      const key = request.headers()['idempotency-key'];
      const existing = key ? committed.get(key) : undefined;
      const result = existing ?? value;
      if (key) committed.set(key, result);
      const left = loseNext.get(path) ?? 0;
      if (left > 0) {
        loseNext.set(path, left - 1);
        return route.abort('connectionreset');
      }
      return data(result, status);
    };
    if (path === '/pos/workspaces' && method === 'GET')
      return route.fulfill({ json: { data: [workspace(sheet)], meta: one } });
    if (path === '/pos/workspaces/ws_1' || path === '/pos/workspaces/ws_1/lease') return data(workspace(sheet));
    if (path === '/pos/workspaces/ws_1/payment_methods')
      return data([{ id: 'posmethod-cash', code: 'cash', name: 'Cash', kind: 'cash', status: 'active', position: 0 }]);
    if (path === '/pos/received_funds') return route.fulfill({ json: { data: [], meta: one } });
    if (path === '/pos/workspaces/ws_1/items' && method === 'POST') {
      const serials = (body.serial_codes as string[] | undefined) ?? [];
      if (!serials.length) return conflict('trace_serial_required');
      if (serials.includes('SN-SOLD')) return conflict('trace_serial_unavailable', 'Serial SN-SOLD is sold.');
      if (body.quantity !== serials.length) return conflict('trace_serial_required');
      sheet.added = serials;
      sheet.revision += 1;
      return data(workspace(sheet));
    }
    if (path === '/pos/workspaces/ws_1/trace_allocations' && method === 'POST') {
      if (body.expected_revision !== sheet.revision) return conflict('stale_revision');
      sheet.reserved = true;
      sheet.revision += 1;
      return data(workspace(sheet));
    }
    if (path === '/pos/catalog')
      return route.fulfill({
        json: {
          data: [{ id: 'v_phone', product_id: 'p_phone', name: 'Điện thoại A', sku: 'DT-1', barcode: null, price: '2500000.0', compare_at_price: null, currency: 'VND', stock_on_hand: 3 }],
          meta: { page: 1, pages: 1, count: 1, ambiguous: false },
        },
      });
    if (path === '/pos/units/variant')
      return data({ variant_id: 'v_phone', sale_unit: 'cái', base_unit: 'cái', price_unit: 'cái', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'serial', version: 1, status: 'active', label_code: null });
    if (path === '/pos/traceability') return data(status('phone', { enrolled: true, reconciled: true, sellable: true, blocked_reason: null }));

    if (path === '/pos/inventory/variants') return data([status('phone'), status('yogurt')]);
    if (path === '/pos/inventory/opening_balances')
      return route.fulfill({
        status: 409,
        json: {
          error: {
            code: 'conflict',
            message: 'Typed 1 does not match core 3',
            details: { reason: 'opening_unreconciled', typed_on_hand: 1, core_on_hand: 3 },
          },
        },
      });
    if (path === '/pos/lots') {
      const filtered = lots.filter(
        (row) =>
          (!url.searchParams.get('variant_id') || row.variant_id === url.searchParams.get('variant_id')) &&
          (!url.searchParams.get('status') || row.status === url.searchParams.get('status')),
      );
      return route.fulfill({ json: { data: filtered, meta: { page: 1, pages: 1, count: filtered.length } } });
    }
    if (path === '/pos/lots/lot_1/quarantine') {
      lots[0] = {
        ...lots[0],
        status: 'quarantined',
        quarantine_reason: String(body.reason),
        quarantined_quantity: 2,
      };
      return data(lots[0]);
    }
    if (path === '/pos/inventory/receipts')
      return answer({ branch_id: 'br_1', ...status('yogurt', { core_on_hand: 18, typed_on_hand: 18 }) });
    if (path === '/pos/inventory/transfers')
      return answer({
        branch_id: 'br_1',
        from: status('yogurt', { core_on_hand: 4, typed_on_hand: 4 }),
        to: status('yogurt', { core_on_hand: 2, typed_on_hand: 2 }),
      });
    if (path === '/pos/inventory/adjustments' && method === 'POST') {
      const created = adjustment('adj_mine', 'stf_1');
      pending.push(created);
      return data(created, 201);
    }
    if (path === '/pos/inventory/adjustments' && method === 'GET')
      return route.fulfill({ json: { data: pending, meta: { page: 1, pages: 1, count: pending.length } } });
    if (path === '/pos/inventory/adjustments/adj_other/approve') {
      pending[0] = { ...pending[0], approval: { id: 'ap_1', status: 'active', expires_at: '2026-11-07T05:00:00Z' } };
      return data(pending[0]);
    }
    if (path === '/pos/inventory/recall')
      return route.fulfill({ json: { meta: { page: 1, limit: 50, count: 1, pages: 1, truncated: false }, data: {
        query: { lot_code: url.searchParams.get('lot_code'), serial: url.searchParams.get('serial') },
        lots: [lots[0]],
        serial_units: [],
        sales: [
          {
            order_id: 'or_100', order_number: 'R100', branch_id: 'br_1', branch_name: 'Branch', sold_at: '2026-11-06T03:00:00Z',
            sale_line_id: 'sl_lot', sku: 'SUA-1', name: 'Sữa chua', quantity: 2, returned_quantity: 0, base_unit: 'hộp',
            lot_code: 'L-01', expiry_on: NEAR, serial: null, status: 'consumed',
            customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '•••••••567' },
          },
        ],
      } } });

    if (path === '/pos/orders' && method === 'GET') {
      const detail = orderDetail();
      return route.fulfill({ json: { data: [detail], meta: one } });
    }
    if (path === '/pos/orders/or_100') return data(orderDetail());
    if (path === '/pos/returns/preview') {
      const lines = body.lines as Array<{ sale_line_id: string; quantity: number; condition: string; serial_codes?: string[]; lot_code?: string }>;
      return data({
        order_id: 'or_100', order_number: 'R100', currency: 'VND', cross_branch: false, out_of_window: false, damaged: false,
        requires_approval: false, entitlement_total: '100000.0', credit_note: '0.0', refund: '100000.0', unrefundable: '0.0',
        lines: lines.map((line) => ({
          sale_line_id: line.sale_line_id, quantity: line.quantity, condition: line.condition, sold_quantity: 3,
          cumulative_before: 1, cumulative_after: 1 + line.quantity, remaining_before: 2,
          original: { total: '300000.0', net: '300000.0', tax: '0.0', discount: '0.0', gross: '300000.0' },
          used: '0.0', reserved: '0.0',
          this_time: { total: '100000.0', net: '100000.0', tax: '0.0', discount: '0.0', gross: '100000.0' },
          trace: line.serial_codes
            ? { mode: 'serial', serials: line.serial_codes, lots: [] }
            : {
                mode: 'lot',
                serials: [],
                lots: [{
                  lot_code: line.lot_code,
                  expiry_on: line.lot_code === 'L-01' ? PAST : LATER,
                  quantity: line.quantity,
                  forced_quarantine: line.lot_code === 'L-01',
                }],
              },
        })),
      });
    }
    if (path.startsWith('/pos/credit_requests') || path === '/pos/returns' || path === '/pos/refund_requests')
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  return { writes, reads, sheet, loseNext };
}

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

const STOCK_KEEPER = ['pos.shift.open', 'pos.inventory.manage', 'pos.inventory.trace', 'pos.approval.grant'];

test('inventory page: opening balance mismatch, lots with expiry, quarantine, receive, adjustment approval and recall', async ({ page }) => {
  const api = await mockPos(page, STOCK_KEEPER);
  await login(page);
  await openMenuLink(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('heading', { name: 'Truy xuất tồn kho', level: 1 })).toBeVisible();

  const panel = page.getByRole('tabpanel');
  await expect(panel.getByRole('row', { name: /Điện thoại A/ })).toContainText('Chưa khai báo tồn đầu kỳ');
  await panel.getByRole('button', { name: 'Khai báo tồn đầu kỳ Điện thoại A' }).click();
  const opening = page.getByRole('dialog', { name: 'Tồn đầu kỳ · Điện thoại A' });
  await opening.getByLabel('Danh sách serial (mỗi dòng một mã)').fill('SN-1');
  await opening.getByRole('button', { name: 'Lưu tồn đầu kỳ' }).click();
  await expect(opening.getByRole('alert')).toHaveText('Tồn đầu kỳ không khớp: đã khai báo 1, tồn kho đang ghi 3.');
  expect(api.writes.at(-1)).toMatchObject({
    path: '/pos/inventory/opening_balances',
    body: { branch_id: 'br_1', variant_id: 'v_phone', serials: ['SN-1'] },
  });
  await page.keyboard.press('Escape');
  await expect(opening).toHaveCount(0);

  await page.getByRole('tab', { name: 'Lô hàng' }).click();
  const lotList = page.getByRole('table', { name: 'Danh sách lô' });
  await expect(lotList.getByRole('row', { name: /L-01/ })).toContainText(`${printed(NEAR)} Sắp hết hạn`);
  await expect(lotList.getByRole('row', { name: /L-00/ })).toContainText('Đã hết hạn');
  await lotList.getByRole('button', { name: 'Cách ly L-01' }).click();
  const quarantine = page.getByRole('dialog', { name: 'Cách ly L-01' });
  await quarantine.getByLabel('Lý do').fill('Bao bì phồng');
  await quarantine.getByRole('button', { name: 'Cách ly', exact: true }).click();
  await expect(page.getByText('Đã cách ly L-01.')).toBeVisible();
  expect(api.writes.at(-1)).toMatchObject({ path: '/pos/lots/lot_1/quarantine', body: { reason: 'Bao bì phồng' } });
  expect(api.writes.at(-1)?.key).toBeTruthy();
  await expect(lotList.getByRole('row', { name: /L-01/ })).toContainText('Đang cách ly');

  await page.getByRole('tab', { name: 'Nhập hàng' }).click();
  const receive = page.getByRole('form', { name: 'Nhập hàng' });
  await receive.getByLabel('Mặt hàng').selectOption('v_yogurt');
  await receive.getByLabel('Mã lô dòng 1').fill('L-05');
  await receive.getByLabel('Hạn dùng dòng 1').fill(LATER);
  await receive.getByLabel('Số lượng dòng 1').fill('12');
  await receive.getByRole('button', { name: 'Nhập hàng', exact: true }).click();
  await expect(receive.getByRole('status')).toContainText('tồn kho 18 hộp, theo lô/serial 18 hộp');
  expect(api.writes.at(-1)).toMatchObject({
    path: '/pos/inventory/receipts',
    body: { branch_id: 'br_1', variant_id: 'v_yogurt', lots: [{ lot_code: 'L-05', expiry_on: LATER, quantity: 12 }] },
  });

  await page.getByRole('tab', { name: 'Kiểm kê / điều chỉnh' }).click();
  const adjust = page.getByRole('form', { name: 'Kiểm kê / điều chỉnh' });
  await adjust.getByLabel('Mặt hàng').selectOption('v_yogurt');
  await adjust.getByLabel(/Đếm được lô L-01/).fill('3');
  await adjust.getByLabel(/Đang cách ly lô L-01/).fill('1');
  await adjust.getByLabel('Lý do').fill('Đếm lại');
  await adjust.getByRole('button', { name: 'Ghi điều chỉnh' }).click();
  await expect(adjust.getByRole('status')).toHaveText('Điều chỉnh Sữa chua (-3 hộp) đang chờ duyệt.');
  expect(api.writes.at(-1)).toMatchObject({
    path: '/pos/inventory/adjustments',
    body: { branch_id: 'br_1', variant_id: 'v_yogurt', reason: 'Đếm lại', lots: [{ lot_id: 'lot_1', counted: 3, counted_quarantined: 1 }] },
  });
  const queue = page.getByRole('list', { name: 'Điều chỉnh chờ duyệt' });
  await expect(queue.getByRole('listitem')).toHaveCount(2);
  await expect(queue).toContainText('L-01: 6 hộp → 3 hộp');
  // The requester cannot approve their own count; a colleague's can be approved.
  const mine = queue.getByRole('listitem').filter({ hasText: 'Lan' });
  await expect(mine.getByRole('button', { name: 'Duyệt' })).toHaveCount(0);
  await expect(mine.getByRole('button', { name: 'Hủy điều chỉnh' })).toBeVisible();
  await queue.getByRole('listitem').filter({ hasText: 'Minh' }).getByRole('button', { name: 'Duyệt' }).click();
  await expect(page.getByText('Đã duyệt điều chỉnh Sữa chua.')).toBeVisible();
  expect(api.writes.at(-1)?.path).toBe('/pos/inventory/adjustments/adj_other/approve');

  await page.getByRole('tab', { name: 'Thu hồi' }).click();
  await page.getByLabel('Mã cần tìm').fill('L-01');
  await page.getByRole('button', { name: 'Tìm', exact: true }).click();
  const sales = page.getByRole('table', { name: 'Đơn đã bán' });
  await expect(sales.getByRole('row', { name: /R100/ })).toContainText('Chị Lan · •••••••567');
  await expect(sales).toContainText(`L-01 · HSD ${printed(NEAR)}`);
  expect(api.reads.find((read) => read.path === '/pos/inventory/recall')?.params).toEqual({ lot_code: 'L-01', page: '1', limit: '50' });
});

test('sale: serial entry with refusals, lot preview, payment blocked until traced stock is held', async ({ page }) => {
  const api = await mockPos(page, ['pos.shift.open', 'pos.payment.collect']);
  await login(page);
  await page.locator('[role="tab"][data-workspace-id="ws_1"]').click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  const basket = page.locator('.basket-lines');
  await expect(basket).toContainText(`Dự kiến lô L-01, HSD ${printed(NEAR)} × 2 hộp`);

  const panel = page.locator('.payment-panel');
  const blocked = panel.getByRole('alert').filter({ hasText: 'Chưa thể thanh toán' });
  await expect(blocked).toContainText('Điện thoại A: Serial giữ cho đơn đã hết hạn giữ; hãy giữ hàng lại.');
  await expect(panel.getByRole('button', { name: 'Thanh toán', exact: true })).toBeDisabled();

  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill('dien');
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  await page.locator('details.catalog-advanced summary').first().click();
  const form = page.locator('.add-item-form');
  const serials = form.getByRole('textbox', { name: /^Serial/ });
  await serials.fill('SN-SOLD');
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(form.getByRole('alert')).toHaveText(
    'Serial không bán được: đã bán, ở chi nhánh khác, đang giữ ở quầy khác hoặc không tồn tại.',
  );
  await serials.fill('SN-2\nSN-2');
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(form.getByRole('alert')).toHaveText('Serial bị quét trùng: SN-2');
  await serials.fill('SN-2\nSN-3\n');
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(basket).toContainText('Serial: SN-3 · đang giữ');
  const added = api.writes.filter((write) => write.path === '/pos/workspaces/ws_1/items').at(-1);
  expect(added?.body).toMatchObject({ variant_id: 'v_phone', quantity: 2, serial_codes: ['SN-2', 'SN-3'] });

  await blocked.getByRole('button', { name: 'Giữ hàng truy xuất' }).click();
  await expect(blocked).toHaveCount(0);
  const hold = api.writes.find((write) => write.path === '/pos/workspaces/ws_1/trace_allocations');
  expect(hold?.body).toMatchObject({ expected_revision: 2, lease_generation: 1 });
  expect(typeof hold?.body.editor_id).toBe('string');
  expect(hold?.key).toBeTruthy();
  await expect(basket).toContainText(`Lô L-01, HSD ${printed(NEAR)} × 2 hộp · đang giữ`);
  await expect(panel.getByRole('button', { name: 'Thanh toán', exact: true })).toBeEnabled();
});

test('return wizard: shows sold serials and lots, sends the ticked serial and the chosen lot', async ({ page }) => {
  const api = await mockPos(page, ['pos.shift.open', 'pos.payment.collect', 'pos.return.process']);
  await login(page);
  await openMenuLink(page, 'Đơn hàng');
  await page.getByRole('list', { name: 'Danh sách đơn hàng' }).getByRole('button', { name: /R100/ }).click();
  await page.getByRole('region', { name: 'Chi tiết đơn' }).getByRole('link', { name: 'Trả / đổi hàng' }).click();
  await expect(page.getByRole('heading', { name: 'Trả hàng đơn R100' })).toBeVisible();

  const table = page.getByRole('form', { name: 'Chọn hàng trả' }).getByRole('table').first();
  await expect(table.getByRole('row', { name: /Điện thoại A/ })).toContainText('SN-1 (đã trả 1) · SN-2 · SN-3');
  const lotRow = table.getByRole('row', { name: /Sữa chua/ });
  await expect(lotRow).toContainText(`Lô L-02, HSD ${printed(LATER)} × 3`);
  await expect(lotRow).toContainText(`Lô L-01, HSD ${printed(PAST)} × 2 Đã hết hạn`);
  const serials = page.getByRole('group', { name: 'Serial trả lại của Điện thoại A' });
  await expect(serials.getByRole('checkbox')).toHaveCount(2);
  await serials.getByLabel('SN-3').check();
  // Traced goods have no default condition.
  await expect(page.getByLabel('Tình trạng Điện thoại A')).toHaveValue('');
  await expect(page.getByText('Hãy chọn tình trạng hàng trả cho hàng theo serial/lô.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Xem trước' })).toBeDisabled();
  await page.getByLabel('Tình trạng Điện thoại A').selectOption('resellable');

  await page.getByLabel('Sữa chua', { exact: true }).fill('3');
  await expect(page.getByText('Dòng này đã bán từ nhiều lô; hãy chọn lô trả về.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Xem trước' })).toBeDisabled();
  await page.getByLabel('Lô trả về của Sữa chua').selectOption('L-01');
  // L-01 sold only 2.
  await expect(page.getByText('Số lượng trả vượt quá phần còn trả được của lô đã chọn.')).toBeVisible();
  await page.getByLabel('Sữa chua', { exact: true }).fill('1');
  await page.getByLabel('Tình trạng Sữa chua').selectOption('resellable');
  await page.getByRole('button', { name: 'Xem trước' }).click();

  const preview = page.getByRole('region', { name: 'Xem trước giá trị trả' });
  await expect(preview).toContainText('Nhận lại: SN-3');
  await expect(preview).toContainText(`Nhận lại: Lô L-01, HSD ${printed(PAST)} × 1 item`);
  await expect(preview.getByRole('status')).toHaveText(
    `Lô L-01 đã hết hạn (${printed(PAST)}): hàng trả sẽ được cách ly, không bán lại.`,
  );
  const sent = api.writes.find((write) => write.path === '/pos/returns/preview');
  expect(sent?.body).toMatchObject({
    order_id: 'or_100',
    lines: [
      { sale_line_id: 'sl_phone', quantity: 1, condition: 'resellable', serial_codes: ['SN-3'] },
      { sale_line_id: 'sl_lot', quantity: 1, condition: 'resellable', lot_code: 'L-01' },
    ],
  });
});

test('approvers without stock rights see only the adjustment queue', async ({ page }) => {
  const api = await mockPos(page, ['pos.shift.open', 'pos.approval.grant']);
  await login(page);
  await openMenuLink(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('tab')).toHaveText(['Kiểm kê / điều chỉnh']);
  await expect(page.getByRole('form', { name: 'Kiểm kê / điều chỉnh' })).toHaveCount(0);
  const queue = page.getByRole('list', { name: 'Điều chỉnh chờ duyệt' });
  await expect(queue.getByRole('listitem')).toHaveCount(1);
  await queue.getByRole('button', { name: 'Duyệt' }).click();
  await expect(page.getByText('Đã duyệt điều chỉnh Sữa chua.')).toBeVisible();
  expect(api.writes.at(-1)?.path).toBe('/pos/inventory/adjustments/adj_other/approve');
  expect(api.reads.some((read) => read.path === '/pos/inventory/variants')).toBe(false);
  await page.getByRole('button', { name: 'Tải lại' }).click();
  await expect(queue.getByRole('listitem')).toContainText('Đã duyệt');
});

test('a lot receipt whose response was lost is checked by its key and never received twice', async ({ page }) => {
  const api = await mockPos(page, STOCK_KEEPER);
  api.loseNext.set('/pos/inventory/receipts', 3);
  await login(page);
  await openMenuLink(page, 'Truy xuất tồn kho');
  await page.getByRole('tab', { name: 'Nhập hàng' }).click();
  const receive = page.getByRole('form', { name: 'Nhập hàng' });
  await receive.getByLabel('Mặt hàng').selectOption('v_yogurt');
  await receive.getByLabel('Mã lô dòng 1').fill('L-07');
  await receive.getByLabel('Số lượng dòng 1').fill('5');
  await receive.getByRole('button', { name: 'Nhập hàng', exact: true }).click();
  await expect(receive.getByText(/Đang kiểm tra kết quả/)).toBeVisible();
  await expect(receive.getByLabel('Mã lô dòng 1')).toBeDisabled();
  await expect(receive.getByRole('button', { name: 'Nhập hàng', exact: true })).toBeDisabled();
  const sent = api.writes.filter((write) => write.path === '/pos/inventory/receipts');
  expect(new Set(sent.map((write) => write.key)).size).toBe(1);

  await receive.getByRole('button', { name: 'Kiểm tra lại' }).click();
  await expect(receive.getByRole('status')).toContainText('tồn kho 18 hộp');
  await expect(receive.getByText(/Đang kiểm tra kết quả/)).toHaveCount(0);
  // The receipt answered: nothing was sent again.
  expect(api.writes.filter((write) => write.path === '/pos/inventory/receipts')).toHaveLength(sent.length);
  expect(api.reads.filter((read) => read.path === '/pos/command_receipts').at(-1)?.params).toEqual({
    idempotency_key: sent[0].key,
  });
});

test('a transfer whose response was lost is resent under the same key after a reload', async ({ page }) => {
  const api = await mockPos(page, STOCK_KEEPER);
  api.loseNext.set('/pos/inventory/transfers', 3);
  await login(page);
  await openMenuLink(page, 'Truy xuất tồn kho');
  await page.getByRole('tab', { name: 'Chuyển kho' }).click();
  const transfer = page.getByRole('form', { name: 'Chuyển kho' });
  await transfer.getByLabel('Mặt hàng').selectOption('v_yogurt');
  await transfer.getByLabel('Chi nhánh nhận').selectOption('br_2');
  await transfer.getByLabel(/Lô L-01/).fill('2');
  await transfer.getByRole('button', { name: 'Chuyển kho', exact: true }).click();
  await expect(transfer.getByText(/Đang kiểm tra kết quả/)).toBeVisible();
  const first = api.writes.filter((write) => write.path === '/pos/inventory/transfers');
  expect(first[0].body).toMatchObject({
    from_branch_id: 'br_1',
    to_branch_id: 'br_2',
    variant_id: 'v_yogurt',
    lots: [{ lot_id: 'lot_1', quantity: 2 }],
  });

  // The same transfer submitted again after a reload reuses the stored key.
  await page.reload();
  await page.getByRole('tab', { name: 'Chuyển kho' }).click();
  await transfer.getByLabel('Mặt hàng').selectOption('v_yogurt');
  await transfer.getByLabel('Chi nhánh nhận').selectOption('br_2');
  await transfer.getByLabel(/Lô L-01/).fill('2');
  await transfer.getByRole('button', { name: 'Chuyển kho', exact: true }).click();
  await expect(transfer.getByRole('status').first()).toContainText('tồn kho 4 hộp');
  const all = api.writes.filter((write) => write.path === '/pos/inventory/transfers');
  expect(new Set(all.map((write) => write.key)).size).toBe(1);
});
