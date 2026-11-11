import { goToMenuPage } from './menu';
import { isRefusal, menuBody, menuItemByVariant, type MenuLine, type MenuWorld, priceMenuAdd } from './menu-api';
import { type BrowserContext, expect, type Page, type Request, type Route } from '@playwright/test';

// An in-memory POS server for whole-day journeys. It keeps one shared state
// across pages and browser contexts, records every command under its
// idempotency key (a replay returns the first result and changes nothing),
// checks revisions and leases the way the server does, and counts each real
// effect so tests can assert "exactly once" on money and stock instead of
// screenshots. Faults are injected per command family: the server commits,
// then the response is lost or delayed.

export const STAFF_ID = 'stf_1';
export const WEIGHT_LABEL = '2100012005008';
export const OTHER_LABEL = '2100012003004';

export const CASHIER = [
  'pos.shift.open',
  'pos.payment.collect',
  'pos.customer.write',
  'pos.workspace.takeover',
];
export const FULL_CASHIER = [
  ...CASHIER,
  'pos.payment.resolve',
  'pos.credit.sell',
  'pos.return.process',
  'pos.cash.move',
  'pos.report.read',
];

export type Family =
  | 'workspace.create'
  | 'lease'
  | 'items'
  | 'item.modifiers'
  | 'trace'
  | 'park'
  | 'tender.prepare'
  | 'tender.confirm'
  | 'tender.cancel'
  | 'complete'
  | 'handover'
  | 'credit.request'
  | 'collection'
  | 'return.prepare'
  | 'return.receive'
  | 'refund.request'
  | 'refund.confirm'
  | 'exchange'
  | 'shift.count'
  | 'shift.close'
  | 'cash.move'
  | 'return.cancel'
  | 'refund.resolve'
  | 'display.bind'
  | 'display.pin'
  | 'display.clear'
  | 'display.pairing'
  | 'display.revoke'
  | 'export.create'
  | 'cash.request'
  | 'inventory.opening';

type Product = {
  id: string;
  name: string;
  sku: string;
  barcode: string | null;
  price: number;
  mode: 'ordinary' | 'measured' | 'serial' | 'lot';
};

type LotStock = { code: string; expiry: string; quantity: number };

type Line = {
  saleLineId: string;
  variantId: string;
  quantity: number;
  label?: { barcode: string; eventId: string; saleQuantity: string; base: number };
  serials?: string[];
  lots?: Array<{ code: string; expiry: string; quantity: number }>;
  // A menu line: priced on the server with its options and note.
  menu?: MenuLine;
};

type Attempt = {
  id: string;
  workspace_id: string;
  payment_method_id: string;
  kind: 'cash' | 'bank_manual';
  status: 'prepared' | 'confirmed' | 'canceled';
  amount: string;
  order_total_snapshot: string;
  currency: 'VND';
  workspace_revision: number;
  received_funds_id: string | null;
  confirmed_at: string | null;
  canceled_at: string | null;
};

export type Sheet = {
  id: string;
  // The shift the order belongs to; 'sh_1' is the cashier's open one.
  shiftId?: string;
  number: string;
  revision: number;
  generation: number;
  editor: string | null;
  status: 'editing' | 'parked' | 'completed';
  lines: Line[];
  customer: { id: string; name: string; phone: string } | null;
  attempts: Attempt[];
  allocated: number;
  changeDue: number;
  debt: number;
  traceReserved: boolean;
  handedOver: boolean;
  creditRequested: boolean;
  creditApproved: boolean;
  orderId: string | null;
};

type Funds = {
  id: string;
  allocationId: string;
  workspaceId: string;
  kind: 'cash' | 'bank_manual';
  amount: number;
  refunded: number;
  reserved: number;
  reference: string | null;
};

type ReturnLine = {
  saleLineId: string;
  name: string;
  quantity: number;
  condition: 'resellable' | 'damaged';
  value: number;
  serials?: string[];
  lot?: string;
};

type ReturnRecord = {
  id: string;
  number: string;
  orderId: string;
  status: 'ready' | 'received' | 'canceled';
  lines: ReturnLine[];
  creditNote: number;
  refund: number;
  exchangeId: string | null;
};

type Refund = {
  id: string;
  returnId: string;
  allocationId: string;
  method: 'cash' | 'bank_manual';
  status: 'reserved' | 'confirmed' | 'canceled' | 'unknown' | 'failed';
  amount: number;
  // False: still waiting for a second person (cancelable by the requester).
  approved?: boolean;
};

type Debt = { orderId: string; number: string; workspaceId: string; debt: number; collected: number };

export type Write = { family: Family; key: string; path: string; body: Record<string, unknown> };

export type World = {
  capabilities: string[];
  // Absent: the server predates branch flags and the context has no `features`.
  features?: Record<string, boolean>;
  // Stored switches: store defaults and this branch's overrides (off only).
  flags?: { store: Record<string, boolean>; branch: Record<string, boolean>; writes: Array<Record<string, unknown>> };
  // Absent: the server predates branch modules; the context has no `modules`
  // (nothing is hidden). Present: modules on at the branch, as the server sends.
  modules?: Record<string, boolean>;
  // Store-wide data a module still has (`module_usage`), e.g. tracked SKUs.
  moduleUsage?: Record<string, boolean>;
  // Industry profile of the selected branch (`profile` in the context).
  profile?: { key: string; version: number; display: { catalog_view?: 'cards' | 'list' } };
  administration?: { read: boolean; write: boolean };
  // The store's e-invoice (`einvoice_type` in the context); absent on older servers.
  einvoiceType?: 'none' | 'cash_register' | 'coded';
  // The branch menu (`GET /pos/menu`) when the branch runs `fnb.menu`.
  menu?: MenuWorld;
  products: Product[];
  serialStock: Set<string>;
  lotStock: Map<string, LotStock[]>;
  sheets: Map<string, Sheet>;
  funds: Funds[];
  orders: Map<string, { id: string; number: string; workspaceId: string; placedAt: string }>;
  returns: ReturnRecord[];
  refunds: Refund[];
  exchanges: Array<{ id: string; returnId: string; workspaceId: string }>;
  debts: Debt[];
  collections: Array<{ amount: number; allocations: Array<{ order_id: string; amount: string }> }>;
  shift: { open: boolean; revision: number; counted: number | null; openingFloat: number };
  // Physical cash the drawer should hold, from the cash effects above.
  drawer: number;
  stockMoves: Array<{ workspaceId: string; variantId: string; quantity: number }>;
  restocks: Array<{ returnId: string; saleLineId: string; quantity: number }>;
  receipts: Map<string, { status: number; json: unknown }>;
  // Digest of family, path and payload per key: a reused key with another payload is refused.
  digests: Map<string, string>;
  display: Record<string, unknown> | null;
  exports: Array<Record<string, unknown>>;
  downloads: string[];
  cashRequests: Array<Record<string, unknown>>;
  creditRequests: Array<Record<string, unknown>>;
  // Variants enrolled into serial/lot tracking at the branch (opening balance done).
  enrolled: Set<string>;
  writes: Write[];
  effects: Map<Family, number>;
  conflicts: number;
  faults: Map<Family, { lose?: number; delayMs?: number }>;
  sessionExpired: boolean;
  // The network is down: every request fails before reaching the server.
  offline: boolean;
  logins: number;
  // Reads that answer with what the server held when they arrived, but late.
  slowReads: Map<string, number>;
  counter: number;
};

export function product(index: number): Product {
  return {
    id: `v_${index}`,
    name: `Hàng số ${index}`,
    sku: `SKU-${index}`,
    barcode: `89300000${String(index).padStart(5, '0')}`,
    price: 10000,
    mode: 'ordinary',
  };
}

const NEAR = '2026-11-20';
const LATER = '2027-03-01';

export const FEATURES = ['credit', 'returns', 'refunds', 'exchanges', 'traceability', 'customer_display', 'cash_moves', 'exports'];

// Effective switches: on only when the store default is on and the branch did not switch it off.
export function effectiveFeatures(world: World): Record<string, boolean> | undefined {
  if (!world.flags) return world.features;
  const flags = world.flags;
  return Object.fromEntries(FEATURES.map((feature) => [feature, flags.store[feature] === true && flags.branch[feature] !== false]));
}

export function newWorld(
  options: {
    capabilities?: string[];
    features?: Record<string, boolean>;
    modules?: Record<string, boolean>;
    moduleUsage?: Record<string, boolean>;
    profile?: World['profile'];
    menu?: MenuWorld;
  } = {},
): World {
  return {
    capabilities: options.capabilities ?? FULL_CASHIER,
    features: options.features,
    modules: options.modules,
    moduleUsage: options.moduleUsage,
    profile: options.profile,
    menu: options.menu,
    products: [
      ...(options.menu?.items ?? []).map((item) => ({
        id: item.variantId, name: item.name, sku: item.id.toUpperCase(), barcode: null, price: item.price, mode: 'ordinary' as const,
      })),
      { id: 'v_rice', name: 'Gạo ST25', sku: 'GAO-1', barcode: '8930000000011', price: 100000, mode: 'ordinary' },
      { id: 'v_water', name: 'Nước suối', sku: 'NUOC-1', barcode: '8930000000028', price: 5000, mode: 'ordinary' },
      { id: 'v_pork', name: 'Thịt heo ba chỉ', sku: 'PORK', barcode: null, price: 120, mode: 'measured' },
      { id: 'v_phone', name: 'Điện thoại A', sku: 'DT-1', barcode: null, price: 2500000, mode: 'serial' },
      { id: 'v_yogurt', name: 'Sữa chua', sku: 'SUA-1', barcode: '8930000000035', price: 50000, mode: 'lot' },
      ...Array.from({ length: 10 }, (_, index) => product(index + 1)),
    ],
    serialStock: new Set(['SN-1', 'SN-2', 'SN-3', 'SN-4']),
    lotStock: new Map([
      ['v_yogurt', [
        { code: 'L-01', expiry: NEAR, quantity: 2 },
        { code: 'L-02', expiry: LATER, quantity: 10 },
      ]],
    ]),
    sheets: new Map(),
    funds: [],
    orders: new Map(),
    returns: [],
    refunds: [],
    exchanges: [],
    debts: [],
    collections: [],
    shift: { open: true, revision: 1, counted: null, openingFloat: 0 },
    drawer: 0,
    stockMoves: [],
    restocks: [],
    receipts: new Map(),
    digests: new Map(),
    display: null,
    exports: [],
    downloads: [],
    cashRequests: [],
    creditRequests: [],
    enrolled: new Set(['v_yogurt']),
    writes: [],
    effects: new Map(),
    conflicts: 0,
    faults: new Map(),
    sessionExpired: false,
    offline: false,
    logins: 0,
    slowReads: new Map(),
    counter: 0,
  };
}

export function addSheet(world: World, id: string, extra: Partial<Sheet> = {}): Sheet {
  const sheet: Sheet = {
    id,
    number: `R${100 + world.sheets.size}`,
    revision: 1,
    generation: 1,
    editor: null,
    status: 'editing',
    lines: [],
    customer: null,
    attempts: [],
    allocated: 0,
    changeDue: 0,
    debt: 0,
    traceReserved: false,
    handedOver: false,
    creditRequested: false,
    creditApproved: false,
    orderId: null,
    ...extra,
  };
  world.sheets.set(id, sheet);
  return sheet;
}

export function addLine(world: World, sheet: Sheet, variantId: string, quantity: number) {
  sheet.lines.push({ saleLineId: `sl_${sheet.id}_${sheet.lines.length + 1}`, variantId, quantity });
}

export const effects = (world: World, family: Family) => world.effects.get(family) ?? 0;
export const keysOf = (world: World, family: Family) =>
  new Set(world.writes.filter((write) => write.family === family).map((write) => write.key));
export const keylessWrites = (world: World) => world.writes.filter((write) => !write.key);
export const postsOf = (world: World, family: Family) =>
  world.writes.filter((write) => write.family === family);

const money = (value: number) => `${value}.0`;
const productOf = (world: World, id: string) => world.products.find((item) => item.id === id);

function lineAmount(world: World, line: Line) {
  const item = productOf(world, line.variantId);
  if (!item) return 0;
  if (line.menu) return line.quantity * line.menu.unitPrice;
  return line.label ? line.label.base * item.price : line.quantity * item.price;
}

export function sheetTotal(world: World, sheet: Sheet) {
  return sheet.lines.reduce((sum, line) => sum + lineAmount(world, line), 0);
}

function fefo(world: World, variantId: string, quantity: number) {
  const plan: Array<{ code: string; expiry: string; quantity: number }> = [];
  let left = quantity;
  for (const lot of world.lotStock.get(variantId) ?? []) {
    if (left <= 0) break;
    const take = Math.min(left, lot.quantity);
    if (take > 0) plan.push({ code: lot.code, expiry: lot.expiry, quantity: take });
    left -= take;
  }
  return plan;
}

function lineTrace(world: World, sheet: Sheet, line: Line) {
  const item = productOf(world, line.variantId);
  if (item?.mode === 'serial')
    return {
      mode: 'serial',
      complete: true,
      issue: null,
      allocations: (line.serials ?? []).map((serial) => ({
        id: `al_${serial}`, kind: 'serial', serial, lot_code: null, expiry_on: null, quantity: 1,
        status: sheet.status === 'completed' ? 'consumed' : 'reserved', expires_at: null,
      })),
      preview: [],
    };
  if (item?.mode === 'lot') {
    const reserved = sheet.traceReserved && line.lots;
    return {
      mode: 'lot',
      complete: Boolean(reserved),
      issue: null,
      allocations: reserved
        ? (line.lots ?? []).map((lot) => ({
            id: `al_${line.saleLineId}_${lot.code}`, kind: 'lot', serial: null, lot_code: lot.code,
            expiry_on: lot.expiry, quantity: lot.quantity, status: 'reserved', expires_at: null,
          }))
        : [],
      preview: reserved
        ? []
        : fefo(world, line.variantId, line.quantity).map((lot) => ({
            lot_code: lot.code, expiry_on: lot.expiry, quantity: lot.quantity,
          })),
    };
  }
  return null;
}

export function serialize(world: World, sheet: Sheet) {
  const total = sheetTotal(world, sheet);
  const remaining = Math.max(total - sheet.allocated - sheet.debt, 0);
  return {
    id: sheet.id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: sheet.shiftId ?? 'sh_1',
    order_id: sheet.number,
    revision: sheet.revision,
    lease_generation: sheet.generation,
    operational_status: sheet.status,
    payments: sheet.attempts.some((attempt) => attempt.status !== 'canceled'),
    note: null,
    customer: sheet.customer && {
      ...sheet.customer, email: null, customer_id: null, has_account: false,
    },
    discount: null,
    line_items: sheet.lines.map((line, index) => {
      const item = productOf(world, line.variantId);
      const amount = lineAmount(world, line);
      const trace = lineTrace(world, sheet, line);
      return {
        id: `li_${sheet.id}_${index + 1}`,
        sale_line_id: line.saleLineId,
        variant_id: line.variantId,
        product_id: `p_${line.variantId}`,
        name: item?.name ?? line.variantId,
        sku: item?.sku ?? '',
        quantity: line.label ? line.label.base : line.quantity,
        price: money(item?.price ?? 0),
        unit_price: line.label ? '120000.0' : money(item?.price ?? 0),
        list_price: money(item?.price ?? 0),
        amount: money(amount),
        discounts: [],
        kind: line.label ? 'measured' : trace ? 'tracked' : 'ordinary',
        ...(line.label
          ? {
              sale_quantity: line.label.saleQuantity, sale_unit: 'kg', base_quantity: line.label.base,
              base_unit: 'g', label_barcode: line.label.barcode, label_format_version: 2,
            }
          : { base_quantity: line.quantity, base_unit: trace?.mode === 'lot' ? 'hộp' : 'cái' }),
        ...(trace ? { tracked_mode: trace.mode, trace } : {}),
        ...(line.menu
          ? {
              kind: 'menu', price: money(line.menu.unitPrice), unit_price: money(line.menu.unitPrice),
              note: line.menu.note, modifiers: line.menu.modifiers, components: [],
            }
          : {}),
      };
    }),
    totals: {
      item_total: money(total),
      discount_total: '0.0',
      manual_discount_total: '0.0',
      included_tax_total: '0.0',
      additional_tax_total: '0.0',
      total: money(total),
      currency: 'VND',
    },
    financial: {
      received: money(sheet.allocated),
      allocated: money(sheet.allocated),
      unapplied: '0.0',
      remaining: money(remaining),
      change_due: money(sheet.changeDue),
      attempts: sheet.attempts,
      credit: {
        approved: sheet.creditApproved && sheet.status !== 'completed' ? money(total - sheet.allocated) : null,
        approval_id: sheet.creditApproved ? 'posapproval_credit' : null,
        debt: sheet.debt ? money(sheet.debt) : null,
        due_on: sheet.debt ? '2026-12-07' : null,
        balance: sheet.debt ? money(debtBalance(world, sheet.orderId)) : null,
      },
    },
    trace: { ready: true, issues: [] },
  };
}

function debtBalance(world: World, orderId: string | null) {
  const debt = world.debts.find((row) => row.orderId === orderId);
  return debt ? debt.debt - debt.collected - creditNotes(world, orderId) : 0;
}

function creditNotes(world: World, orderId: string | null) {
  return world.returns
    .filter((row) => row.orderId === orderId && row.status === 'received')
    .reduce((sum, row) => sum + row.creditNote, 0);
}

function returnedQuantity(world: World, saleLineId: string, serial?: string, lot?: string) {
  return world.returns
    .filter((row) => row.status !== 'canceled')
    .flatMap((row) => row.lines)
    .filter((line) => line.saleLineId === saleLineId)
    .filter((line) => (serial ? line.serials?.includes(serial) : true) && (lot ? line.lot === lot : true))
    .reduce((sum, line) => sum + (serial ? 1 : line.quantity), 0);
}

function lineBase(line: Line) {
  return line.label ? line.label.base : line.quantity;
}

function unitValue(world: World, line: Line) {
  return productOf(world, line.variantId)?.price ?? 0;
}

function orderRow(world: World, sheet: Sheet) {
  const order = world.orders.get(sheet.orderId ?? '');
  return {
    id: sheet.orderId,
    number: sheet.number,
    workspace_id: sheet.id,
    placed_at: order?.placedAt ?? '2026-11-07T03:00:00Z',
    register: 'Quầy 1',
    cashier: 'Lan',
    cashier_id: STAFF_ID,
    customer: sheet.customer ? { id: sheet.customer.id, name: sheet.customer.name, phone: '•••••••567' } : null,
    currency: 'VND',
    total: money(sheetTotal(world, sheet)),
    paid: money(sheet.allocated),
    debt: sheet.debt ? money(sheet.debt) : null,
    returned: world.returns.some((row) => row.orderId === sheet.orderId && row.status === 'received'),
    refund_pending: world.refunds.some((row) => row.status === 'reserved'),
  };
}

function orderDetail(world: World, sheet: Sheet) {
  const total = sheetTotal(world, sheet);
  const lines = sheet.lines.map((line) => {
    const item = productOf(world, line.variantId);
    const base = lineBase(line);
    const value = lineAmount(world, line);
    const returned = returnedQuantity(world, line.saleLineId);
    const components = { total: money(value), net: money(value), tax: '0.0', discount: '0.0', gross: money(value) };
    const trace =
      item?.mode === 'serial'
        ? {
            mode: 'serial',
            allocations: (line.serials ?? []).map((serial) => ({
              serial, lot_code: null, expiry_on: null, quantity: 1,
              returned_quantity: returnedQuantity(world, line.saleLineId, serial),
            })),
          }
        : item?.mode === 'lot'
          ? {
              mode: 'lot',
              allocations: (line.lots ?? []).map((lot) => ({
                serial: null, lot_code: lot.code, expiry_on: lot.expiry, quantity: lot.quantity,
                returned_quantity: returnedQuantity(world, line.saleLineId, undefined, lot.code),
              })),
            }
          : null;
    return {
      sale_line_id: line.saleLineId,
      name: item?.name ?? line.variantId,
      sku: item?.sku ?? null,
      sale_quantity: line.label ? line.label.saleQuantity : `${line.quantity}.0`,
      sale_unit: line.label ? 'kg' : 'item',
      base_quantity: base,
      base_unit: line.label ? 'g' : item?.mode === 'lot' ? 'hộp' : 'cái',
      unit_price: money(unitValue(world, line)),
      lot_code: null,
      serial_codes: line.serials ?? [],
      original: components,
      returned_quantity: returned,
      posted_quantity: returned,
      returnable_quantity: base - returned,
      handed_over: sheet.handedOver,
      entitlement_used: '0.0',
      entitlement_reserved: '0.0',
      ...(trace ? { trace } : {}),
    };
  });
  const receipts = world.funds
    .filter((funds) => funds.workspaceId === sheet.id)
    .map((funds) => ({
      allocation_id: funds.allocationId,
      funds_id: funds.id,
      kind: funds.kind,
      status: 'active',
      amount: money(funds.amount),
      refunded: money(funds.refunded),
      refund_reserved: money(funds.reserved),
      refundable: money(funds.amount - funds.refunded - funds.reserved),
      collection: false,
      reference: funds.reference,
      received_at: '2026-11-07T03:00:00Z',
    }));
  return {
    ...orderRow(world, sheet),
    sale_branch_id: 'br_1',
    totals: { original_total: money(total), item_total: money(total), discount_total: '0.0', tax_total: '0.0' },
    lines,
    entitlement: { used: '0.0', reserved: '0.0', credit_notes: money(creditNotes(world, sheet.orderId)), refund_entitlement: '0.0' },
    receipts,
    refunds: [],
    credit: null,
    returns: [],
    exchanges: [],
    stock: {
      location_id: 'sloc_1',
      fulfillments: sheet.handedOver
        ? [{ id: `ful_${sheet.id}`, status: 'fulfilled', location_id: 'sloc_1', fulfilled_at: '2026-11-07T03:01:00Z' }]
        : [],
      restocked_quantity: 0,
      damaged_quantity: 0,
      discrepancies: [],
    },
    timeline: [
      { id: `${sheet.orderId}:placed`, at: '2026-11-07T03:00:00Z', kind: 'placed', amount: money(total) },
    ],
  };
}

function returnJson(world: World, record: ReturnRecord) {
  const sheet = [...world.sheets.values()].find((row) => row.orderId === record.orderId);
  const value = record.lines.reduce((sum, line) => sum + line.value, 0);
  const posted = record.status === 'received';
  const requested = world.refunds
    .filter((row) => row.returnId === record.id && row.status !== 'canceled')
    .reduce((sum, row) => sum + row.amount, 0);
  const refunded = world.refunds
    .filter((row) => row.returnId === record.id && row.status === 'confirmed')
    .reduce((sum, row) => sum + row.amount, 0);
  return {
    id: record.id,
    branch_id: 'br_1',
    sale_branch_id: 'br_1',
    workspace_id: sheet?.id ?? null,
    order_id: record.orderId,
    order_number: sheet?.number ?? '',
    return_number: record.number,
    requester_id: STAFF_ID,
    requester_name: 'Lan',
    status: record.status,
    entitlement_status: posted ? 'posted' : 'pending',
    reason: 'Khách đổi ý',
    cross_branch: false,
    out_of_window: false,
    damaged: false,
    requires_approval: false,
    revision: 1,
    approval: null,
    currency: 'VND',
    entitlement_total: money(value),
    credit_note_amount: posted ? money(record.creditNote) : '0.0',
    refund_entitlement: posted ? money(record.refund) : '0.0',
    refund_requested: money(requested),
    refunded: money(refunded),
    expected_credit_note: money(record.creditNote),
    expected_refund: money(record.refund),
    expires_at: null,
    refundable_remaining: posted ? money(record.refund - requested) : '0.0',
    lines: record.lines.map((line, index) => ({
      id: `posretline_${record.id}_${index + 1}`,
      sale_line_id: line.saleLineId,
      name: line.name,
      sku: null,
      quantity: line.quantity,
      sequence: 1,
      cumulative_before: 0,
      cumulative_after: line.quantity,
      condition: line.condition,
      status: posted ? 'posted' : 'reserved',
      received_quantity: posted ? line.quantity : 0,
      restocked_quantity: posted && line.condition === 'resellable' ? line.quantity : 0,
      total: money(line.value),
      net: money(line.value),
      tax: '0.0',
      discount: '0.0',
      gross: money(line.value),
      trace: line.serials
        ? line.serials.map((serial) => ({ serial, lot_code: null, expiry_on: null, quantity: 1, status: posted ? 'restocked' : 'pending' }))
        : line.lot
          ? [{ serial: null, lot_code: line.lot, expiry_on: null, quantity: line.quantity, status: posted ? 'restocked' : 'pending' }]
          : [],
    })),
    refund_requests: world.refunds.filter((row) => row.returnId === record.id).map((row) => refundJson(world, row)),
    exchange_id: record.exchangeId,
    created_at: '2026-11-07T04:00:00Z',
    received_at: null,
    posted_at: null,
    canceled_at: null,
  };
}

function refundJson(world: World, refund: Refund) {
  const record = world.returns.find((row) => row.id === refund.returnId);
  const sheet = [...world.sheets.values()].find((row) => row.orderId === record?.orderId);
  return {
    id: refund.id,
    return_id: refund.returnId,
    branch_id: 'br_1',
    order_id: record?.orderId,
    order_number: sheet?.number,
    allocation_id: refund.allocationId,
    funds_id: world.funds.find((row) => row.allocationId === refund.allocationId)?.id,
    funds_kind: refund.method,
    method: refund.method,
    status: refund.status,
    amount: money(refund.amount),
    currency: 'VND',
    revision: 1,
    requester_id: STAFF_ID,
    confirmer_id: refund.status === 'confirmed' ? STAFF_ID : null,
    shift_id: null,
    refund_id: null,
    beneficiary_reference: null,
    // The branch policy pre-approves refunds within the cashier's limit.
    approval:
      refund.approved === false
        ? null
        : { id: `posapproval_${refund.id}`, status: 'active', expires_at: '2099-01-01T00:00:00Z' },
    evidence: null,
    created_at: '2026-11-07T04:10:00Z',
    confirmed_at: refund.status === 'confirmed' ? '2026-11-07T04:20:00Z' : null,
    resolved_at: null,
  };
}

function shiftCount(world: World) {
  const counted = world.shift.counted;
  const expected = world.shift.openingFloat + world.drawer;
  const variance = counted === null ? null : counted - expected;
  return {
    shift_id: 'sh_1', branch_id: 'br_1', currency: 'VND', revision: world.shift.revision,
    status: world.shift.open ? 'open' : 'closed',
    counted: counted === null ? null : money(counted),
    expected: counted === null ? null : money(expected),
    variance: variance === null ? null : money(variance),
    variance_threshold: null, reason: null,
    counted_at: counted === null ? null : '2026-11-07T10:00:00Z',
    counted_by_id: counted === null ? null : STAFF_ID,
    stale: counted === null ? null : false,
    requires_approval: variance === null ? null : variance !== 0,
    approval: null,
  };
}

function checklist(world: World) {
  const blocking = [...world.sheets.values()].flatMap((sheet) =>
    sheet.attempts
      .filter((attempt) => attempt.status === 'prepared')
      .map((attempt) => ({
        type: 'tender_attempt', id: attempt.id, workspace_id: sheet.id, order_number: sheet.number,
        status: 'prepared', amount: attempt.amount, kind: attempt.kind,
      })),
  );
  const warnings = [...world.sheets.values()]
    .filter((sheet) => sheet.status !== 'completed' && sheet.attempts.every((attempt) => attempt.status !== 'prepared'))
    .map((sheet) => ({ type: 'draft', workspace_id: sheet.id, order_number: sheet.number, status: sheet.status }));
  return { blocking, warnings };
}

function closure(world: World) {
  const expected = world.shift.openingFloat + world.drawer;
  return {
    id: 'posclosure_1', shift_id: 'sh_1', branch_id: 'br_1', register_id: 'reg_1', closer_id: STAFF_ID,
    closer_name: 'Lan', approver_id: null, approver_name: null, currency: 'VND',
    opening_float: money(world.shift.openingFloat), inflow_total: money(Math.max(world.drawer, 0)),
    outflow_total: '0.0', expected: money(expected), counted: money(world.shift.counted ?? 0),
    variance: money((world.shift.counted ?? 0) - expected), variance_threshold: null, reason: null,
    cutoff_movement_id: 'poscashmv_1', movement_count: 1, breakdown: {}, reconciled: '0.0',
    opened_at: '2026-11-07T01:00:00Z', closed_at: '2026-11-07T10:05:00Z',
  };
}

type Answer = { status: number; json: unknown };
const conflict = (message: string, reason?: string, extra: Record<string, unknown> = {}): Answer => ({
  status: 409,
  json: { error: { code: 'conflict', message, details: reason ? { reason, ...extra } : extra } },
});
const data = (value: unknown, status = 200): Answer => ({ status, json: { data: value } });
const page = (rows: unknown[], extra: Record<string, unknown> = {}) => ({
  json: { data: rows, meta: { page: 1, pages: 1, count: rows.length, ...extra } },
});

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

// The workspace guards every editing command checks before it runs.
function guard(world: World, sheet: Sheet, body: Record<string, unknown>): Answer | null {
  if (body.editor_id !== sheet.editor || body.lease_generation !== sheet.generation) {
    world.conflicts += 1;
    return conflict('Lease is stale.', 'lease_stale', { current_revision: sheet.revision });
  }
  if (body.expected_revision !== sheet.revision) {
    world.conflicts += 1;
    return conflict('Revision changed.', 'stale_revision', { current_revision: sheet.revision });
  }
  return null;
}

// The cashier's open shift: the world's only drawer, unless the order belongs to another shift.
function shiftOpen(world: World, sheet: Sheet) {
  return world.shift.open && (sheet.shiftId ?? 'sh_1') === 'sh_1';
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object')
    return `{${Object.keys(value as Record<string, unknown>).sort().map((field) => `${JSON.stringify(field)}:${stableJson((value as Record<string, unknown>)[field])}`).join(',')}}`;
  return JSON.stringify(value ?? null);
}

export function displaySession(extra: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    id: 'posdisplay_1', status: 'active', generation: 1, freshness_ttl_seconds: 15, pinned_workspace_id: null,
    pinned_order_number: null, pinned_tender_attempt_id: null, acked_generation: Number(extra.generation ?? 1),
    acked_at: '2026-11-07T03:00:00Z', ack_current: true, last_seen_at: '2026-11-07T03:00:00Z',
    token_expires_at: '2099-01-01T00:00:00Z', ...extra,
  };
}

function nextId(world: World, prefix: string) {
  world.counter += 1;
  return `${prefix}_${world.counter}`;
}

function completeSheet(world: World, sheet: Sheet, debt: number) {
  sheet.debt = debt;
  sheet.status = 'completed';
  sheet.orderId = `or_${sheet.id}`;
  world.orders.set(sheet.orderId, {
    id: sheet.orderId, number: sheet.number, workspaceId: sheet.id, placedAt: '2026-11-07T03:00:00Z',
  });
  if (debt > 0) world.debts.push({ orderId: sheet.orderId, number: sheet.number, workspaceId: sheet.id, debt, collected: 0 });
  for (const line of sheet.lines) for (const serial of line.serials ?? []) world.serialStock.delete(serial);
}

async function handle(world: World, route: Route) {
  const request = route.request();
  const url = new URL(request.url());
  const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
  const method = request.method();
  const body = (method === 'GET' ? {} : (request.postDataJSON() ?? {})) as Record<string, unknown>;
  const fulfill = (answer: Answer) => route.fulfill({ status: answer.status, json: answer.json });
  if (world.offline) return route.abort('internetdisconnected');

  if (path === '/auth/login') {
    world.sessionExpired = false;
    world.logins += 1;
    return route.fulfill({ json: { token: `token-${world.logins}` } });
  }
  if (world.sessionExpired) return route.fulfill({ status: 401, json: { error: { code: 'unauthorized', message: 'Expired.' } } });
  if (path === '/auth/refresh') return route.fulfill({ json: { token: `token-${world.logins}` } });
  if (path === '/auth/logout') return route.fulfill({ json: {} });
  if (path === '/me') return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
  if (path === '/pos/context/branches') return route.fulfill(page([{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }]));
  if (path === '/pos/context/registers')
    return route.fulfill(page([{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }]));
  if (path === '/pos/context') {
    const branch = url.searchParams.get('branch_id');
    const register = url.searchParams.get('register_id');
    return route.fulfill({
      json: {
        staff: { id: STAFF_ID, email: 'staff@example.test', full_name: 'Lan' },
        store: { id: 'store_1', name: 'ParkViet', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: branch ? world.capabilities : [],
        ...(effectiveFeatures(world) ? { features: effectiveFeatures(world) } : {}),
        // Like the server: modules and profile belong to the selected branch.
        ...(world.modules ? { modules: branch ? world.modules : {} } : {}),
        ...(world.moduleUsage ? { module_usage: world.moduleUsage } : {}),
        ...(world.profile ? { profile: branch ? world.profile : null } : {}),
        ...(world.administration ? { administration: world.administration } : {}),
        ...(world.einvoiceType ? { einvoice_type: world.einvoiceType } : {}),
        branches: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active', timezone: 'Asia/Ho_Chi_Minh' }],
        registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [],
        shift:
          register && world.shift.open
            ? {
                id: 'sh_1', branch_id: 'br_1', register_id: 'reg_1', status: 'open',
                opening_float: money(world.shift.openingFloat), currency: 'VND', owner_id: STAFF_ID,
                opened_at: '2026-11-07T01:00:00Z', reports: false,
              }
            : null,
        selection: { branch_id: branch, register_id: register },
      },
    });
  }
  if (path === '/pos/command_receipts') {
    const stored = world.receipts.get(url.searchParams.get('idempotency_key') ?? '');
    return stored && stored.status < 300
      ? route.fulfill({ json: stored.json })
      : route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'No receipt.' } } });
  }

  // Reads.
  if (method === 'GET') {
    const slow = [...world.slowReads.entries()].find(([prefix]) => path.startsWith(prefix));
    if (path === '/pos/workspaces') {
      const rows = [...world.sheets.values()].map((sheet) => serialize(world, sheet));
      if (slow) await sleep(slow[1]);
      return route.fulfill(page(rows));
    }
    const read = /^\/pos\/workspaces\/([^/]+)(\/[a-z_]+)?$/.exec(path);
    const sheet = read ? world.sheets.get(read[1]) : undefined;
    if (read && !sheet) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
    if (sheet && !read?.[2]) {
      const snapshot = serialize(world, sheet);
      if (slow) await sleep(slow[1]);
      return route.fulfill({ json: { data: snapshot } });
    }
    if (sheet && read?.[2] === '/payment_methods')
      return fulfill(data([
        { id: 'posmethod-cash', code: 'cash', name: 'Tiền mặt', kind: 'cash', status: 'active', position: 0 },
        { id: 'posmethod-bank_manual', code: 'bank_transfer', name: 'Chuyển khoản', kind: 'bank_manual', status: 'active', position: 1 },
      ]));
    if (sheet && read?.[2] === '/credit') {
      const total = sheetTotal(world, sheet);
      const remaining = total - sheet.allocated;
      const approved = sheet.creditApproved;
      return fulfill(data({
        workspace_id: sheet.id,
        revision: sheet.revision,
        customer: sheet.customer && { id: sheet.customer.id, name: sheet.customer.name },
        can_sell: true,
        request: sheet.creditRequested
          ? {
              id: `poscreditreq_${sheet.id}`, branch_id: 'br_1', workspace_id: sheet.id, order_number: sheet.number,
              customer: sheet.customer && { id: sheet.customer.id, name: sheet.customer.name },
              requester: { id: STAFF_ID, name: 'Lan' }, amount: money(remaining), currency: 'VND',
              workspace_revision: sheet.revision, status: approved ? 'approved' : 'pending', reason: null,
              created_at: '2026-11-07T03:00:00Z', decided_at: null,
              approval_id: approved ? 'posapproval_credit' : null, approval_active: approved,
            }
          : null,
        account: sheet.customer
          ? {
              id: 'poscredit_1', customer_id: sheet.customer.id, customer_name: sheet.customer.name, status: 'active',
              currency: 'VND', credit_limit: '2000000.0', due_days: 30, open_debt: '0.0',
              reserved: approved ? money(remaining) : '0.0',
              available: approved ? money(2000000 - remaining) : '2000000.0', due_on: '2026-12-07',
            }
          : null,
        reservation: approved
          ? {
              id: 'poscreditres_1', credit_account_id: 'poscredit_1', workspace_id: sheet.id,
              approval_id: 'posapproval_credit', customer_id: sheet.customer?.id, amount: money(remaining),
              currency: 'VND', workspace_revision: sheet.revision, status: 'active', usable: true,
              approver: { id: 'stf_2', name: 'Quản lý Hà' }, expires_at: '2099-01-01T00:00:00Z',
            }
          : null,
      }));
    }
    if (path === '/pos/menu' && world.menu) return fulfill(data(menuBody(world.menu)));
    if (path === '/pos/catalog') {
      const q = url.searchParams.get('q') ?? '';
      const exact = url.searchParams.get('barcode') === 'true';
      const rows = world.products.filter((item) =>
        item.mode !== 'measured' &&
        (exact
          ? item.barcode === q || item.sku === q
          : `${item.name} ${item.sku} ${item.barcode ?? ''}`.toLowerCase().includes(q.toLowerCase())),
      );
      return route.fulfill(
        page(
          rows.map((item) => ({
            id: item.id, product_id: `p_${item.id}`, name: item.name, sku: item.sku, barcode: item.barcode,
            price: money(item.price), compare_at_price: null, currency: 'VND', stock_on_hand: 10,
          })),
          { ambiguous: false },
        ),
      );
    }
    if (path === '/pos/units/variant') {
      const item = productOf(world, url.searchParams.get('variant_id') ?? '');
      const mode = item?.mode === 'serial' || item?.mode === 'lot' ? item.mode : 'none';
      const unit = mode === 'lot' ? 'hộp' : 'cái';
      return fulfill(data({
        variant_id: item?.id, sale_unit: unit, base_unit: unit, price_unit: unit, ratio_numerator: 1,
        ratio_denominator: 1, tracked_mode: mode, version: 1, status: 'active', label_code: null,
      }));
    }
    if (path === '/pos/traceability') {
      const item = productOf(world, url.searchParams.get('variant_id') ?? '');
      return fulfill(data({
        variant_id: item?.id, name: item?.name, sku: item?.sku, tracked_mode: item?.mode === 'serial' ? 'serial' : item?.mode === 'lot' ? 'lot' : 'none',
        base_unit: 'cái', enrolled: true, reconciled: true, sellable: true, blocked_reason: null,
        core_on_hand: 4, typed_on_hand: 4,
      }));
    }
    if (path === '/pos/display_sessions/current') return fulfill(data(world.display));
    if (path === '/pos/inventory/variants')
      return fulfill(data(world.products.filter((item) => item.mode === 'serial' || item.mode === 'lot').map((item) => ({
        variant_id: item.id, name: item.name, sku: item.sku, tracked_mode: item.mode, base_unit: item.mode === 'lot' ? 'hộp' : 'cái',
        enrolled: world.enrolled.has(item.id), reconciled: world.enrolled.has(item.id), sellable: world.enrolled.has(item.id),
        blocked_reason: world.enrolled.has(item.id) ? null : 'not_enrolled', core_on_hand: 4, typed_on_hand: world.enrolled.has(item.id) ? 4 : 0,
      }))));
    if (path === '/pos/inventory/adjustments' || path === '/pos/lots' || path === '/pos/serial_units') return route.fulfill(page([]));
    if (path === '/pos/exports') return route.fulfill(page(world.exports));
    if (path.startsWith('/pos/export_files/'))
      return route.fulfill({ status: 200, headers: { 'Content-Type': 'text/csv; charset=utf-8' }, body: 'order_number,total\nR100,100000.0\n' });
    if (path === '/pos/cash_movement_requests') {
      const pendingOnly = url.searchParams.get('status') === 'requested';
      const shiftId = url.searchParams.get('shift_id');
      const rows = world.cashRequests.filter((row) => (!pendingOnly || row.status === 'requested') && (!shiftId || row.shift_id === shiftId));
      return route.fulfill(page(rows));
    }
    const report = /^\/pos\/reports\/(\w+)$/.exec(path);
    if (report)
      return route.fulfill({
        json: {
          data: [],
          meta: {
            report: report[1], page: 1, pages: 1, count: 0, limit: 50, scope: 'branch', timezone: 'Asia/Ho_Chi_Minh',
            from: url.searchParams.get('from'), to: url.searchParams.get('to'),
            summary: report[1] === 'sales'
              ? { orders: 0, sales_total: '0.0', returns: 0, returns_total: '0.0', net_sales: '0.0' }
              : report[1] === 'cashbook' ? { shifts: [], shift_count: 0, shift_page: 1, shift_pages: 1 } : {},
          },
        },
      });
    if (path === '/pos/branches')
      return route.fulfill(page([{
        id: 'br_1', name: 'Chi nhánh 1', code: 'cn1', timezone: 'Asia/Ho_Chi_Minh', status: 'active',
        stock_location_id: 'sloc_1', receiving_stock_location_id: null, receiving_note: null,
      }]));
    if (path === '/pos/feature_flags' && world.flags) {
      const flags = world.flags;
      return fulfill(data({
        branch_id: url.searchParams.get('branch_id'),
        features: effectiveFeatures(world),
        switches: Object.fromEntries(FEATURES.map((feature) => [feature, {
          store: flags.store[feature] === true,
          branch_override: flags.branch[feature] === false ? false : null,
          effective: effectiveFeatures(world)?.[feature] === true,
        }])),
        settings: [
          ...Object.entries(flags.store).map(([feature, enabled]) => ({ feature, enabled, branch_id: null, reason: 'Mở bán', changed_by_name: 'Chủ cửa hàng', changed_at: '2026-11-07T02:00:00Z' })),
          ...Object.entries(flags.branch).map(([feature, enabled]) => ({ feature, enabled, branch_id: 'br_1', reason: 'Tạm dừng', changed_by_name: 'Quản lý Hà', changed_at: '2026-11-07T03:00:00Z' })),
        ],
      }));
    }
    if (path === '/pos/credit_requests') return route.fulfill(page(world.creditRequests));
    if (path === '/pos/received_funds' || path === '/pos/credit_accounts' ||
        path === '/pos/returns' || path === '/pos/refund_requests' ||
        path === '/pos/cash_reconciliations' || path === '/pos/customers')
      return route.fulfill(page([]));
    if (path === '/pos/shift_closures/pending' || path === '/pos/shift_closures/open')
      return route.fulfill({ json: { data: [], meta: { count: 0 } } });
    if (path === '/pos/orders') {
      const number = url.searchParams.get('number')?.toUpperCase();
      const rows = [...world.sheets.values()]
        .filter((sheet) => sheet.orderId && (!number || sheet.number.includes(number)))
        .map((sheet) => orderRow(world, sheet));
      return route.fulfill(page(rows));
    }
    const order = /^\/pos\/orders\/([^/]+)$/.exec(path);
    if (order) {
      const number = url.searchParams.get('number')?.toUpperCase();
      const sheet = [...world.sheets.values()].find((row) =>
        order[1] === 'lookup' ? row.number === number && row.orderId : row.orderId === order[1],
      );
      return sheet ? fulfill(data(orderDetail(world, sheet))) : route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
    }
    const ret = /^\/pos\/returns\/([^/]+)$/.exec(path);
    if (ret) {
      const record = world.returns.find((row) => row.id === ret[1]);
      return record ? fulfill(data(returnJson(world, record))) : route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    }
    const exchange = /^\/pos\/exchanges\/([^/]+)$/.exec(path);
    if (exchange) {
      const row = world.exchanges.find((item) => item.id === exchange[1]);
      const record = world.returns.find((item) => item.id === row?.returnId);
      const replacement = world.sheets.get(row?.workspaceId ?? '');
      if (!row || !record || !replacement) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
      const refunded = world.refunds.filter((item) => item.returnId === record.id && item.status === 'confirmed')
        .reduce((sum, item) => sum + item.amount, 0);
      return fulfill(data({
        id: row.id, return_id: record.id, replacement_workspace_id: replacement.id,
        replacement_order_number: replacement.number, replacement_status: replacement.status,
        replacement_total: money(sheetTotal(world, replacement)), credit_note_amount: money(record.creditNote),
        refund_entitlement: money(record.refund), refunded: money(refunded), refund_owed: money(record.refund - refunded),
        customer_pays: null, store_refunds: null, currency: 'VND',
      }));
    }
    if (path === '/pos/receivables/customers') {
      const balance = world.debts.reduce((sum, row) => sum + debtBalance(world, row.orderId), 0);
      const rows = world.debts.length
        ? [{
            credit_account_id: 'poscredit_1', currency: 'VND',
            customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' }, orders: world.debts.length,
            credit_limit: '2000000.0', account_status: 'active', balance: money(balance), overdue: '0.0',
            current: money(balance), days_1_30: '0.0', days_31_60: '0.0', days_61_90: '0.0', days_over_90: '0.0',
          }]
        : [];
      return route.fulfill({
        json: { data: rows, meta: { count: rows.length, totals: { balance: money(balance), overdue: '0.0', current: money(balance), days_1_30: '0.0', days_31_60: '0.0', days_61_90: '0.0', days_over_90: '0.0' } } },
      });
    }
    if (path === '/pos/receivables')
      return route.fulfill(page(world.debts.filter((row) => debtBalance(world, row.orderId) > 0).map((row) => ({
        order_id: row.orderId, order_number: row.number, workspace_id: row.workspaceId, credit_account_id: 'poscredit_1',
        customer: { id: 'poscustomer_1', name: 'Chị Lan', phone: '0901234567' }, currency: 'VND',
        original_total: money(sheetTotal(world, world.sheets.get(row.workspaceId) as Sheet)),
        paid_at_sale: money((world.sheets.get(row.workspaceId) as Sheet).allocated), debt: money(row.debt),
        credit_notes: money(creditNotes(world, row.orderId)), collected: money(row.collected), refunds: '0.0',
        balance: money(debtBalance(world, row.orderId)), due_on: '2026-12-07', overdue: false, days_overdue: 0,
        aging: 'current', placed_at: '2026-11-07T03:00:00Z',
      }))));
    if (path === '/pos/shifts/sh_1/closure')
      return fulfill(data({
        shift: { id: 'sh_1', branch_id: 'br_1', register_id: 'reg_1', status: world.shift.open ? 'open' : 'closed',
          opening_float: money(world.shift.openingFloat), currency: 'VND', owner_id: STAFF_ID,
          opened_at: '2026-11-07T01:00:00Z', closed_at: null, revision: world.shift.revision,
          counted: world.shift.counted !== null, reports: false },
        checklist: world.shift.open ? checklist(world) : { blocking: [], warnings: [] },
        count: shiftCount(world),
        closure: world.shift.open ? null : closure(world),
        can_close: world.shift.open,
        can_approve: false,
      }));
    if (path === '/pos/shifts/sh_1/cash_movements') return route.fulfill(page([]));
    return route.fulfill({ status: 404, json: { error: { code: 'missing', message: `Not mocked: ${path}` } } });
  }

  // Commands. Each runs once per key; a replay answers with the first result.
  const key = request.headers()['idempotency-key'] ?? (typeof body.idempotency_key === 'string' ? body.idempotency_key : '');
  const familyOf = (): Family | null => {
    if (path === '/pos/workspaces') return 'workspace.create';
    if (/\/lease$/.test(path)) return 'lease';
    if (/\/items$/.test(path)) return 'items';
    if (/\/items\/[^/]+\/modifiers$/.test(path)) return 'item.modifiers';
    if (/\/trace_allocations$/.test(path)) return 'trace';
    if (/\/(park|reopen)$/.test(path)) return 'park';
    if (/\/tender_attempts$/.test(path)) return 'tender.prepare';
    if (/\/tender_attempts\/[^/]+\/confirm$/.test(path)) return 'tender.confirm';
    if (/\/tender_attempts\/[^/]+\/cancel$/.test(path)) return 'tender.cancel';
    if (/\/complete$/.test(path)) return 'complete';
    if (/\/handover$/.test(path)) return 'handover';
    if (/\/credit_requests$/.test(path)) return 'credit.request';
    if (path === '/pos/collections') return 'collection';
    if (path === '/pos/returns') return 'return.prepare';
    if (/^\/pos\/returns\/[^/]+\/receive$/.test(path)) return 'return.receive';
    if (path === '/pos/refund_requests') return 'refund.request';
    if (/^\/pos\/refund_requests\/[^/]+\/confirmation$/.test(path)) return 'refund.confirm';
    if (path === '/pos/exchanges') return 'exchange';
    if (/\/count$/.test(path)) return 'shift.count';
    if (/\/shifts\/[^/]+\/close$/.test(path)) return 'shift.close';
    if (/\/cash_movements$/.test(path)) return 'cash.move';
    if (/^\/pos\/returns\/[^/]+\/cancel$/.test(path)) return 'return.cancel';
    if (/^\/pos\/refund_requests\/[^/]+\/resolution$/.test(path)) return 'refund.resolve';
    if (path === '/pos/display_sessions') return 'display.bind';
    if (/^\/pos\/display_sessions\/[^/]+\/pin$/.test(path)) return 'display.pin';
    if (/^\/pos\/display_sessions\/[^/]+\/clear$/.test(path)) return 'display.clear';
    if (/^\/pos\/display_sessions\/[^/]+\/pairing_code$/.test(path)) return 'display.pairing';
    if (/^\/pos\/display_sessions\/[^/]+\/revoke$/.test(path)) return 'display.revoke';
    if (path === '/pos/exports') return 'export.create';
    if (/^\/pos\/cash_movement_requests\/[^/]+\/(confirm|cancel)$/.test(path)) return 'cash.request';
    if (path === '/pos/inventory/opening_balances') return 'inventory.opening';
    return null;
  };
  const family = familyOf();
  if (path === '/pos/returns/preview') return fulfill(data(preview(world, body)));
  // A signed link to a file already made: a read that the server re-authorizes, not a command.
  const link = /^\/pos\/exports\/([^/]+)\/download_link$/.exec(path);
  if (link) {
    world.downloads.push(link[1]);
    return fulfill(data({ id: link[1], url: `/api/v3/admin/pos/export_files/${link[1]}`, filename: `${link[1]}.csv`, expires_at: '2099-01-01T00:00:00Z' }));
  }
  const flagWrite = /^\/pos\/feature_flags\/([a-z_]+)$/.exec(path);
  if (flagWrite && world.flags) {
    world.flags.writes.push({ feature: flagWrite[1], ...body });
    const denied = () => route.fulfill({ status: 403, json: { error: { code: 'access_denied', message: 'Forbidden' } } });
    // Authority first, as the server does, then the input.
    const store = world.administration?.write === true;
    const manager = world.capabilities.includes('pos.topology.manage');
    if (body.branch_id ? (body.enabled === false ? !(store || manager) : !store) : !store) return denied();
    if (!String(body.reason ?? '').trim()) return fulfill(conflict('A reason is required.', 'reason_required'));
    if (!body.branch_id && typeof body.enabled !== 'boolean')
      return fulfill(conflict('A store default must be on or off.', 'feature_value_invalid'));
    if (body.branch_id) {
      if (body.enabled === false) world.flags.branch[flagWrite[1]] = false;
      else delete world.flags.branch[flagWrite[1]];
    } else {
      world.flags.store[flagWrite[1]] = body.enabled === true;
    }
    return fulfill(data({ branch_id: body.branch_id ?? null, features: effectiveFeatures(world) }));
  }
  if (path === '/pos/measurement_barcodes/parse') return fulfill(data(parseLabel(world, String(body.barcode ?? ''))));
  if (!family) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: `Not mocked: ${method} ${path}` } } });
  world.writes.push({ family, key, path, body });

  // Heartbeats are not commands with effects.
  if (family === 'lease' && method === 'PATCH') {
    const sheet = world.sheets.get(path.split('/')[3]);
    if (!sheet) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    if (sheet.editor !== body.editor_id || sheet.generation !== body.lease_generation)
      return fulfill(conflict('Lease is stale.', 'lease_stale', { current_revision: sheet.revision }));
    return fulfill(data(serialize(world, sheet)));
  }

  // Display bind, pairing code and revoke take no key on the server.
  const keyless: Family[] = ['display.bind', 'display.pairing', 'display.revoke'];
  if (!key && !keyless.includes(family))
    return route.fulfill({ status: 422, json: { error: { code: 'parameter_invalid', message: 'Idempotency-Key is required.' } } });
  const digest = stableJson({ family, path, body: Object.fromEntries(Object.entries(body).filter(([field]) => field !== 'idempotency_key')) });
  if (key && world.digests.has(key) && world.digests.get(key) !== digest)
    return fulfill(conflict('Idempotency key was reused with a different payload.'));
  let answer = key ? world.receipts.get(key) : undefined;
  const gate: Partial<Record<Family, string>> = {
    'credit.request': 'credit', 'return.prepare': 'returns', 'refund.request': 'refunds', exchange: 'exchanges', 'cash.move': 'cash_moves',
    'inventory.opening': 'traceability',
    'display.bind': 'customer_display', 'display.pin': 'customer_display', 'display.pairing': 'customer_display', 'export.create': 'exports',
  };
  const feature = family === 'complete' && body.credit_approval_id ? 'credit' : gate[family];
  const switches = effectiveFeatures(world);
  if (!answer && feature && switches && switches[feature] !== true)
    return fulfill(conflict(`${feature} is turned off at this branch.`, 'feature_disabled', { feature }));
  if (!answer) {
    answer = run(world, family, path, body);
    if (answer.status < 300) {
      if (key) {
        world.receipts.set(key, answer);
        world.digests.set(key, digest);
      }
      world.effects.set(family, (world.effects.get(family) ?? 0) + 1);
    }
  }
  const fault = world.faults.get(family);
  if (fault?.delayMs) await sleep(fault.delayMs);
  if (fault?.lose && fault.lose > 0) {
    fault.lose -= 1;
    return route.abort('connectionreset');
  }
  return fulfill(answer);
}

function parseLabel(world: World, barcode: string) {
  const labels: Record<string, { saleQuantity: string; base: number }> = {
    [WEIGHT_LABEL]: { saleQuantity: '0.5', base: 500 },
    [OTHER_LABEL]: { saleQuantity: '0.3', base: 300 },
  };
  const label = labels[barcode];
  if (!label) return { kind: 'ordinary', barcode, measurement: null, capability: 'measured_labels' };
  const item = productOf(world, 'v_pork');
  return {
    kind: 'measured_label', barcode, capability: 'measured_labels', format_id: 'poslabel_1', format_version: 2,
    label_kind: 'weight', variant_id: 'v_pork', name: item?.name, sku: item?.sku, sale_quantity: label.saleQuantity,
    sale_unit: 'kg', base_quantity: label.base, base_unit: 'g', unit_price: '120000.0', currency: 'VND',
    line_amount: money(label.base * 120), label_amount: null,
  };
}

function findLine(world: World, saleLineId: string) {
  for (const sheet of world.sheets.values()) {
    const line = sheet.lines.find((row) => row.saleLineId === saleLineId);
    if (line) return { sheet, line };
  }
  return null;
}

function preview(world: World, body: Record<string, unknown>) {
  const lines = (body.lines as Array<{ sale_line_id: string; quantity: number; condition: string; serial_codes?: string[]; lot_code?: string }>) ?? [];
  const rows = lines.map((input) => {
    const found = findLine(world, input.sale_line_id);
    const value = found ? input.quantity * unitValue(world, found.line) : 0;
    const sold = found ? lineBase(found.line) : 0;
    const before = returnedQuantity(world, input.sale_line_id);
    const original = found ? lineAmount(world, found.line) : 0;
    return {
      sale_line_id: input.sale_line_id, quantity: input.quantity, condition: input.condition, sold_quantity: sold,
      cumulative_before: before, cumulative_after: before + input.quantity, remaining_before: sold - before,
      original: { total: money(original), net: money(original), tax: '0.0', discount: '0.0', gross: money(original) },
      used: '0.0', reserved: '0.0',
      this_time: { total: money(value), net: money(value), tax: '0.0', discount: '0.0', gross: money(value) },
      ...(input.serial_codes ? { trace: { mode: 'serial', serials: input.serial_codes, lots: [] } } : {}),
      ...(input.lot_code ? { trace: { mode: 'lot', serials: [], lots: [{ lot_code: input.lot_code, expiry_on: null, quantity: input.quantity, forced_quarantine: false }] } } : {}),
    };
  });
  const total = rows.reduce((sum, row) => sum + Number.parseInt(row.this_time.total, 10), 0);
  const found = lines[0] ? findLine(world, lines[0].sale_line_id) : null;
  const credit = Math.min(total, debtBalance(world, found?.sheet.orderId ?? null));
  return {
    order_id: body.order_id, order_number: found?.sheet.number, currency: 'VND', cross_branch: false, out_of_window: false,
    damaged: false, requires_approval: false, entitlement_total: money(total), credit_note: money(credit),
    refund: money(total - credit), unrefundable: '0.0', lines: rows,
  };
}

function run(world: World, family: Family, path: string, body: Record<string, unknown>): Answer {
  const segments = path.split('/');
  const sheet = segments[2] === 'workspaces' ? world.sheets.get(segments[3]) : undefined;
  const reply = (target: Sheet, status = 200) => data(serialize(world, target), status);
  switch (family) {
    case 'workspace.create': {
      const created = addSheet(world, nextId(world, 'ws'), { editor: String(body.editor_id), generation: 1 });
      return reply(created, 201);
    }
    case 'lease': {
      if (!sheet) break;
      if (sheet.editor && sheet.editor !== body.editor_id && !body.takeover)
        return conflict('Another editor holds this order.', 'lease_busy', { retry_after_seconds: 90 });
      if (sheet.editor !== body.editor_id) sheet.generation += 1;
      sheet.editor = String(body.editor_id);
      return reply(sheet);
    }
    case 'park': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      sheet.status = path.endsWith('/park') ? 'parked' : 'editing';
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'items': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      if (sheet.attempts.some((attempt) => attempt.status !== 'canceled'))
        return conflict('Payments recorded.', 'snapshot_locked');
      if (body.label_barcode) {
        const parsed = parseLabel(world, String(body.label_barcode));
        if (parsed.kind !== 'measured_label') return conflict('Not a scale label of this branch.');
        if (['variant_id', 'quantity'].some((field) => field in body)) return conflict('The label carries its quantity.');
        const event = String(body.measurement_event_id);
        if (sheet.lines.some((line) => line.label?.eventId === event)) return conflict('Measurement already added.');
        sheet.lines.push({
          saleLineId: `sl_${sheet.id}_${sheet.lines.length + 1}`, variantId: 'v_pork', quantity: 1,
          label: { barcode: String(body.label_barcode), eventId: event, saleQuantity: String(parsed.sale_quantity), base: Number(parsed.base_quantity) },
        });
      } else {
        const item = productOf(world, String(body.variant_id));
        if (!item) return conflict('Unknown variant.');
        const quantity = Number(body.quantity);
        const menuEntry = world.menu ? menuItemByVariant(world.menu, item.id) : undefined;
        if (item.mode === 'serial') {
          const serials = (body.serial_codes as string[] | undefined) ?? [];
          if (serials.length !== quantity) return conflict('Serials required.', 'trace_serial_required');
          const taken = new Set(sheet.lines.flatMap((line) => line.serials ?? []));
          const bad = serials.find((serial) => !world.serialStock.has(serial) || taken.has(serial));
          if (bad) return conflict(`Serial ${bad} is not available.`, 'trace_serial_unavailable');
          sheet.lines.push({ saleLineId: `sl_${sheet.id}_${sheet.lines.length + 1}`, variantId: item.id, quantity, serials });
        } else if (world.menu && menuEntry) {
          const priced = priceMenuAdd(world.menu, menuEntry, body);
          if (isRefusal(priced)) return conflict(priced.refused, priced.reason);
          const twin = body.merge
            ? sheet.lines.find((line) => line.variantId === item.id && line.menu?.signature === priced.signature && line.menu.unitPrice === priced.unitPrice)
            : undefined;
          if (twin) twin.quantity += quantity;
          else sheet.lines.push({ saleLineId: `sl_${sheet.id}_${sheet.lines.length + 1}`, variantId: item.id, quantity, menu: priced });
        } else {
          const existing = body.merge ? sheet.lines.find((line) => line.variantId === item.id && !line.label) : undefined;
          if (existing) existing.quantity += quantity;
          else sheet.lines.push({ saleLineId: `sl_${sheet.id}_${sheet.lines.length + 1}`, variantId: item.id, quantity });
        }
      }
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'item.modifiers': {
      // Options of a menu line change; a line left with the same options as
      // another one joins it, as the server does.
      if (!sheet || !world.menu) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      const line = sheet.lines.find((row) => row.saleLineId === segments[5]);
      const entry = line?.menu ? menuItemByVariant(world.menu, line.variantId) : undefined;
      if (!line || !entry) return conflict('Only a menu line has options.', 'modifier_unknown');
      const priced = priceMenuAdd(world.menu, { ...entry, scheduledPrice: undefined, price: line.menu?.basePrice ?? entry.price }, {
        modifiers: body.modifiers ?? [],
        note: body.note,
      });
      if (isRefusal(priced)) return conflict(priced.refused, priced.reason);
      const twin = sheet.lines.find(
        (row) => row !== line && row.variantId === line.variantId && row.menu?.signature === priced.signature && row.menu.unitPrice === priced.unitPrice,
      );
      if (twin) {
        twin.quantity += line.quantity;
        sheet.lines.splice(sheet.lines.indexOf(line), 1);
      } else {
        line.menu = priced;
      }
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'trace': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      reserveLots(world, sheet);
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'tender.prepare': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      if (!shiftOpen(world, sheet)) return conflict('Shift is closed.', 'shift_closed');
      const amount = String(body.amount ?? '');
      if (!/^\d+$/.test(amount)) return conflict('Amount must be whole VND.');
      const open = sheet.attempts.filter((attempt) => attempt.status === 'prepared')
        .reduce((sum, attempt) => sum + Number.parseInt(attempt.amount, 10), 0);
      const remaining = sheetTotal(world, sheet) - sheet.allocated - open;
      if (Number(amount) > remaining) return conflict('Amount exceeds the remaining total.');
      reserveLots(world, sheet);
      sheet.attempts.push({
        id: nextId(world, 'ten'), workspace_id: sheet.id, payment_method_id: String(body.payment_method_id),
        kind: String(body.payment_method_id).endsWith('cash') ? 'cash' : 'bank_manual', status: 'prepared',
        amount: money(Number(amount)), order_total_snapshot: money(sheetTotal(world, sheet)), currency: 'VND',
        workspace_revision: sheet.revision, received_funds_id: null, confirmed_at: null, canceled_at: null,
      });
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'tender.confirm':
    case 'tender.cancel': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      if (family === 'tender.confirm' && !shiftOpen(world, sheet)) return conflict('Shift is closed.', 'shift_closed');
      const attempt = sheet.attempts.find((item) => item.id === segments[5]);
      if (!attempt || attempt.status !== 'prepared') return conflict('Tender is not prepared.');
      if (family === 'tender.cancel') {
        attempt.status = 'canceled';
        sheet.revision += 1;
        return reply(sheet);
      }
      const applied = Number.parseInt(attempt.amount, 10);
      if (attempt.kind === 'cash') {
        const handed = Number(body.handed_amount);
        if (!(handed >= applied)) return conflict('Handed cash is less than the tender amount.');
        sheet.changeDue += handed - applied;
        world.drawer += applied;
      } else if (!body.reference || !body.receiving_account) {
        return { status: 422, json: { error: { code: 'validation_error', message: 'Reference is required.' } } };
      }
      const funds: Funds = {
        id: nextId(world, 'posfunds'), allocationId: nextId(world, 'posalloc'), workspaceId: sheet.id,
        kind: attempt.kind, amount: applied, refunded: 0, reserved: 0,
        reference: typeof body.reference === 'string' ? body.reference : null,
      };
      world.funds.push(funds);
      sheet.allocated += applied;
      attempt.status = 'confirmed';
      attempt.received_funds_id = funds.id;
      attempt.confirmed_at = '2026-11-07T03:00:00Z';
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'complete': {
      if (!sheet) break;
      const refused = guard(world, sheet, body);
      if (refused) return refused;
      if (!shiftOpen(world, sheet)) return conflict('Shift is closed.', 'shift_closed');
      // Like the server: a buyer with a tax code needs a name and an address.
      const buyer = body.einvoice_buyer as Record<string, string> | undefined;
      const missing = buyer?.tax_code ? ['name', 'address'].find((field) => !buyer[field]) : undefined;
      if (missing) return conflict('Buyer details are invalid.', 'einvoice_buyer_invalid', { field: missing });
      const remaining = sheetTotal(world, sheet) - sheet.allocated;
      if (sheet.attempts.some((attempt) => attempt.status === 'prepared')) return conflict('A tender is unresolved.');
      if (remaining > 0 && !(body.credit_approval_id === 'posapproval_credit' && sheet.creditApproved))
        return conflict('Received funds do not cover the order total.');
      completeSheet(world, sheet, Math.max(remaining, 0));
      sheet.revision += 1;
      return reply(sheet);
    }
    case 'handover': {
      if (!sheet) break;
      if (sheet.status !== 'completed') return conflict('Order is not complete.');
      // Once only: a second handover of a delivered order moves no stock.
      if (!sheet.handedOver) {
        sheet.handedOver = true;
        for (const line of sheet.lines) world.stockMoves.push({ workspaceId: sheet.id, variantId: line.variantId, quantity: lineBase(line) });
      }
      return reply(sheet);
    }
    case 'credit.request': {
      if (!sheet) break;
      sheet.creditRequested = true;
      return data({ id: `poscreditreq_${sheet.id}`, status: 'pending' }, 201);
    }
    case 'collection': {
      if (!world.shift.open) return conflict('Open your own shift before collecting debt.', 'shift_required');
      const amount = Number(body.amount);
      const allocations = (body.allocations as Array<{ order_id: string; amount: string }>) ?? [];
      const allocated = allocations.reduce((sum, row) => sum + Number(row.amount), 0);
      if (allocated > amount) return conflict('Allocations exceed the money available on this receipt.');
      for (const row of allocations) {
        const debt = world.debts.find((item) => item.orderId === row.order_id);
        if (!debt || Number(row.amount) > debtBalance(world, row.order_id)) return conflict('Allocation exceeds the balance.');
      }
      for (const row of allocations) {
        const debt = world.debts.find((item) => item.orderId === row.order_id);
        if (debt) debt.collected += Number(row.amount);
      }
      if (body.kind === 'cash') world.drawer += amount;
      world.collections.push({ amount, allocations });
      return data({
        id: nextId(world, 'poscollect'), credit_account_id: 'poscredit_1', branch_id: 'br_1', customer_id: 'poscustomer_1',
        note: null, funds: { id: nextId(world, 'posfunds'), received_net: money(amount), available: money(amount - allocated), currency: 'VND' },
        allocations: [], created_at: null,
      }, 201);
    }
    case 'return.prepare': {
      const lines = (body.lines as Array<{ sale_line_id: string; quantity: number; condition: 'resellable' | 'damaged'; serial_codes?: string[]; lot_code?: string }>) ?? [];
      const prepared: ReturnLine[] = [];
      for (const input of lines) {
        const found = findLine(world, input.sale_line_id);
        if (!found) return conflict('Unknown sale line.');
        const left = lineBase(found.line) - returnedQuantity(world, input.sale_line_id);
        if (input.quantity <= 0 || input.quantity > left) return conflict('Too many.', 'exceeds_returnable');
        prepared.push({
          saleLineId: input.sale_line_id, name: productOf(world, found.line.variantId)?.name ?? '', quantity: input.quantity,
          condition: input.condition, value: input.quantity * unitValue(world, found.line),
          ...(input.serial_codes ? { serials: input.serial_codes } : {}), ...(input.lot_code ? { lot: input.lot_code } : {}),
        });
      }
      const first = findLine(world, lines[0]?.sale_line_id ?? '');
      const value = prepared.reduce((sum, line) => sum + line.value, 0);
      const credit = Math.min(value, debtBalance(world, first?.sheet.orderId ?? null));
      const record: ReturnRecord = {
        id: nextId(world, 'posreturn'), number: `RET${100 + world.returns.length}`, orderId: String(body.order_id),
        status: 'ready', lines: prepared, creditNote: credit, refund: value - credit, exchangeId: null,
      };
      world.returns.push(record);
      return data(returnJson(world, record), 201);
    }
    case 'return.receive': {
      const record = world.returns.find((row) => row.id === segments[3]);
      if (!record) break;
      if (record.status === 'received') return conflict('Already received.', 'already_received');
      record.status = 'received';
      for (const line of record.lines)
        if (line.condition === 'resellable') {
          world.restocks.push({ returnId: record.id, saleLineId: line.saleLineId, quantity: line.quantity });
          for (const serial of line.serials ?? []) world.serialStock.add(serial);
        }
      return data(returnJson(world, record));
    }
    case 'refund.request': {
      const record = world.returns.find((row) => row.id === body.return_id);
      const funds = world.funds.find((row) => row.allocationId === body.allocation_id);
      if (!record || !funds) return conflict('Unknown return or receipt.');
      const amount = Number(body.amount);
      const requested = world.refunds.filter((row) => row.returnId === record.id && row.status !== 'canceled')
        .reduce((sum, row) => sum + row.amount, 0);
      if (!(amount > 0) || amount > record.refund - requested || amount > funds.amount - funds.refunded - funds.reserved)
        return conflict('Refund exceeds the entitlement.', 'exceeds_refundable');
      funds.reserved += amount;
      const refund: Refund = {
        id: nextId(world, 'posrefund'), returnId: record.id, allocationId: funds.allocationId,
        method: body.method === 'bank_manual' ? 'bank_manual' : 'cash', status: 'reserved', amount,
      };
      world.refunds.push(refund);
      return data(refundJson(world, refund), 201);
    }
    case 'refund.confirm': {
      const refund = world.refunds.find((row) => row.id === segments[3]);
      if (!refund || !['reserved', 'unknown'].includes(refund.status)) return conflict('Refund is not awaiting payout.');
      if (refund.method === 'cash' && !world.shift.open)
        return conflict('Cash refunds need your own open shift in this branch.', 'shift_required');
      const funds = world.funds.find((row) => row.allocationId === refund.allocationId);
      if (funds) {
        funds.reserved -= refund.amount;
        funds.refunded += refund.amount;
      }
      if (refund.method === 'cash') world.drawer -= refund.amount;
      refund.status = 'confirmed';
      return data(refundJson(world, refund));
    }
    case 'exchange': {
      const record = world.returns.find((row) => row.id === body.return_id);
      if (!record) return conflict('Unknown return.');
      if (record.exchangeId) return conflict('Already exchanged.');
      const replacement = addSheet(world, nextId(world, 'ws'), { editor: String(body.editor_id) });
      const exchange = { id: nextId(world, 'posexchange'), returnId: record.id, workspaceId: replacement.id };
      world.exchanges.push(exchange);
      record.exchangeId = exchange.id;
      return data({
        id: exchange.id, return_id: record.id, replacement_workspace_id: replacement.id,
        replacement_order_number: replacement.number, replacement_status: 'editing', replacement_total: '0.0',
        credit_note_amount: money(record.creditNote), refund_entitlement: money(record.refund), refunded: '0.0',
        refund_owed: money(record.refund), customer_pays: null, store_refunds: null, currency: 'VND',
      }, 201);
    }
    case 'shift.count': {
      if (checklist(world).blocking.length) return conflict('close_blocked', 'close_blocked', { checklist: checklist(world) });
      world.shift.counted = Number(body.counted);
      world.shift.revision += 1;
      return data(shiftCount(world));
    }
    case 'shift.close': {
      if (world.shift.counted === null) return conflict('count_required', 'count_required');
      if (world.shift.counted !== world.shift.openingFloat + world.drawer) return conflict('approval_required', 'approval_required');
      world.shift.open = false;
      return data(closure(world), 201);
    }
    case 'cash.move': {
      if (body.kind !== 'cash_in') return conflict('evidence_required', 'evidence_required');
      world.drawer += Number(body.amount);
      return data({
        id: nextId(world, 'poscashmv'), branch_id: 'br_1', shift_id: 'sh_1', kind: 'cash_in', category: 'cash_in',
        amount: money(Number(body.amount)), currency: 'VND', reason: body.reason, evidence_reference: null,
        created_at: '2026-11-07T09:00:00Z', status: 'posted',
      }, 201);
    }
    case 'inventory.opening': {
      const item = productOf(world, String(body.variant_id));
      if (!item) break;
      if (world.enrolled.has(item.id)) return conflict('Tracked stock of this item is already open at this branch.', 'already_enrolled');
      world.enrolled.add(item.id);
      return data({
        variant_id: item.id, name: item.name, sku: item.sku, tracked_mode: item.mode, base_unit: 'cái', enrolled: true,
        reconciled: true, sellable: true, blocked_reason: null, core_on_hand: 4, typed_on_hand: 4,
      }, 201);
    }
    case 'return.cancel': {
      const record = world.returns.find((row) => row.id === segments[3]);
      if (!record || record.status !== 'ready') return conflict('This return cannot be canceled.', 'not_cancelable');
      record.status = 'canceled';
      return data(returnJson(world, record));
    }
    case 'refund.resolve': {
      const refund = world.refunds.find((row) => row.id === segments[3]);
      if (!refund) break;
      const funds = world.funds.find((row) => row.allocationId === refund.allocationId);
      if (body.outcome === 'cancel') {
        if (refund.status !== 'reserved') return conflict('Only a reserved refund can be canceled.', 'not_cancelable');
        refund.status = 'canceled';
        if (funds) funds.reserved -= refund.amount;
      } else if (body.outcome === 'failed_no_effect') {
        refund.status = 'failed';
        if (funds) funds.reserved -= refund.amount;
      } else refund.status = 'unknown';
      return data(refundJson(world, refund));
    }
    case 'display.bind':
      world.display = displaySession({ generation: 1 });
      return { status: 201, json: { data: world.display, token: 'display-token' } };
    case 'display.pin':
    case 'display.clear': {
      if (!world.display) break;
      const pinned = family === 'display.pin' ? world.sheets.get(String(body.workspace_id)) : undefined;
      world.display = displaySession({
        generation: Number(world.display.generation) + 1,
        pinned_workspace_id: pinned?.id ?? null,
        pinned_order_number: pinned?.number ?? null,
      });
      return data(world.display);
    }
    case 'display.pairing':
      return data({ code: 'ABCD1234', expires_at: '2099-01-01T00:00:00Z' });
    case 'display.revoke':
      world.display = null;
      return data(null);
    case 'export.create': {
      const created = {
        id: nextId(world, 'posexport'), branch_id: 'br_1', report_type: body.type ?? body.report_type ?? 'sales',
        filters: body.filters ?? {}, status: 'queued', row_count: null, error_message: null, expires_at: null,
        completed_at: null, created_at: '2026-11-07T10:00:00Z',
      };
      world.exports.push(created);
      return data(created, 202);
    }
    case 'cash.request': {
      const row = world.cashRequests.find((item) => item.id === segments[3]);
      if (!row || row.status !== 'requested') return conflict('Request is not pending.', 'not_pending');
      if (path.endsWith('/confirm')) {
        Object.assign(row, { status: 'confirmed', confirmer_id: STAFF_ID, confirmer_name: 'Lan', cash_movement_id: nextId(world, 'poscashmv') });
        if (row.kind === 'cash_in') world.drawer += Number.parseInt(String(row.amount), 10);
        else world.drawer -= Number.parseInt(String(row.amount), 10);
      } else Object.assign(row, { status: 'canceled', resolution_note: body.note ?? null });
      return data(row);
    }
    default:
      break;
  }
  return { status: 404, json: { error: { code: 'missing', message: `Not mocked: ${path}` } } };
}

function reserveLots(world: World, sheet: Sheet) {
  if (sheet.traceReserved) return;
  for (const line of sheet.lines) {
    if (productOf(world, line.variantId)?.mode !== 'lot') continue;
    line.lots = fefo(world, line.variantId, line.quantity);
    for (const pick of line.lots) {
      const lot = world.lotStock.get(line.variantId)?.find((row) => row.code === pick.code);
      if (lot) lot.quantity -= pick.quantity;
    }
  }
  sheet.traceReserved = true;
}

export async function installRetailApi(target: Page | BrowserContext, world: World) {
  await target.route('**/api/v3/admin/**', (route) => handle(world, route));
}

export function requestFamily(request: Request) {
  return new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
}

// UI helpers shared by the journeys.

export async function login(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.header-user')).toHaveText('Lan');
}

export function tab(page: Page, workspaceId: string) {
  return page.locator(`[role="tab"][data-workspace-id="${workspaceId}"]`);
}

export async function openTab(page: Page, workspaceId: string) {
  await tab(page, workspaceId).click();
  const claim = page.getByRole('button', { name: 'Nhận quyền sửa', exact: true });
  if (await claim.isVisible().catch(() => false)) await claim.click();
  // After a reload the page is a new editor; its own old lease needs a takeover.
  const takeover = page.getByRole('button', { name: 'Tiếp quản quyền sửa' });
  const park = page.getByRole('button', { name: 'Tạm giữ' });
  // Takeover is offered beside the claim, so wait for the claim's outcome first.
  const claimed = await expect(park)
    .toBeEnabled({ timeout: 5_000 })
    .then(() => true)
    .catch(() => false);
  if (!claimed) {
    await takeover.click();
    await expect(park).toBeEnabled();
  }
}

// A hardware scanner types a whole code within milliseconds outside any text
// field; the burst is dispatched in one task, as a scanner delivers it.
export async function scan(page: Page, ...codes: string[]) {
  await page.evaluate((burst) => {
    (document.activeElement as HTMLElement | null)?.blur();
    const target = document.activeElement ?? document.body;
    for (const code of burst) {
      for (const key of [...code, 'Enter'])
        target.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));
    }
  }, codes);
}

export async function openMenuLink(page: Page, name: string) {
  await goToMenuPage(page, name);
}

// Opens the return wizard for an order looked up by its number.
export async function openReturnFor(page: Page, number: string) {
  await goToMenuPage(page, 'Trả / đổi hàng');
  await page.getByLabel('Số đơn gốc').fill(number);
  await page.getByRole('button', { name: 'Tìm đơn' }).click();
}

// `timeout` is raised by the real-API runs, which answer slower than the mocks.
export async function payCash(page: Page, handed: string, timeout = 5_000) {
  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Khách đưa').fill(handed, { timeout });
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog).toHaveCount(0, { timeout });
}

// Browser and server see the same outage: routed requests ignore setOffline.
export async function setNetwork(context: BrowserContext, world: World, online: boolean) {
  world.offline = !online;
  await context.setOffline(!online);
}

// "Kết thúc" in the payment dialog already completed a fully paid order;
// only the counter handover is left.
export async function completeAndHandOver(page: Page, timeout = 5_000) {
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click({ timeout });
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible({ timeout });
}
