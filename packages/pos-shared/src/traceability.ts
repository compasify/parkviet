import { conflictReason, describeFailure } from './request-failure';

// Stock traceability: serial units, lots with expiry (FEFO) and the trace
// state the server attaches to sale lines, workspaces and orders. Every stock
// rule is enforced by the server; these helpers only shape what the cashier
// and the stock keeper see and send.

export type TrackedMode = 'none' | 'serial' | 'lot';

export type PosLot = {
  id: string;
  variant_id: string;
  sku: string;
  name: string;
  stock_location_id: string;
  branch_id: string | null;
  lot_code: string;
  expiry_on: string | null;
  status: 'active' | 'quarantined' | 'expired';
  received_quantity: number;
  on_hand: number;
  quarantined_quantity: number;
  reserved: number;
  committed: number;
  available: number;
  base_unit: string;
  source_lot_id: string | null;
  quarantine_reason: string | null;
  created_at: string;
};

export type SerialStatus =
  | 'in_stock'
  | 'reserved'
  | 'sold'
  | 'returned'
  | 'quarantined'
  | 'removed';

export type PosSerialUnit = {
  id: string;
  variant_id: string;
  sku: string;
  name: string;
  serial: string;
  status: SerialStatus;
  stock_location_id: string;
  branch_id: string | null;
  quarantine_reason: string | null;
  updated_at: string;
};

export type TraceBlockedReason = 'not_enrolled' | 'unreconciled' | 'not_tracked';

export type PosTraceStatus = {
  variant_id: string;
  sku: string;
  name: string;
  tracked_mode: TrackedMode;
  stock_location_id: string;
  base_unit: string;
  sale_unit: string;
  enrolled: boolean;
  reconciled: boolean;
  sellable: boolean;
  blocked_reason: TraceBlockedReason | null;
  core_on_hand: number | null;
  typed_on_hand: number | null;
  lot_selection: LotSelection;
  lots: PosLot[];
  serials_available: number;
};

export type LotSelection = 'fefo' | 'cashier_pick';

export type AdjustmentStatus = 'pending_approval' | 'applied' | 'canceled';

export type PosAdjustment = {
  id: string;
  branch_id: string;
  variant_id: string;
  sku: string;
  name: string;
  reason: string;
  status: AdjustmentStatus;
  requires_approval: boolean;
  delta: number;
  revision: number;
  lines: {
    kind: 'lot' | 'serial';
    lot_id?: string;
    lot_code?: string;
    serial?: string;
    before: number;
    after: number;
    delta: number;
    quarantined_before?: number;
    quarantined_after?: number;
    quarantined_delta?: number;
  }[];
  requester_id: string;
  requester_name: string;
  approval: { id: string; status: string; expires_at: string } | null;
  created_at: string;
  applied_at: string | null;
};

export type PosTransferResult = {
  branch_id: string;
  from: PosTraceStatus;
  to: PosTraceStatus;
};

export type RecallSale = {
  variant_id?: string;
  order_id: string;
  order_number: string;
  branch_id: string;
  branch_name: string;
  sold_at: string;
  sale_line_id: string;
  sku: string;
  name: string;
  quantity: number;
  returned_quantity: number;
  base_unit: string;
  lot_code: string | null;
  expiry_on: string | null;
  serial: string | null;
  status: 'committed' | 'consumed';
  customer: { id: string; name: string; phone: string | null } | null;
};

export type RecallResult = {
  query: { lot_code: string | null; serial: string | null };
  lots: PosLot[];
  serial_units: PosSerialUnit[];
  sales: RecallSale[];
};

export type SaleLineTraceIssue =
  | 'trace_unreconciled'
  | 'trace_not_enrolled'
  | 'trace_serial_released'
  | 'trace_insufficient';

export type SaleLineTrace = {
  mode: 'serial' | 'lot';
  complete: boolean;
  issue: SaleLineTraceIssue | null;
  allocations: {
    id: string;
    kind: 'serial' | 'lot';
    serial: string | null;
    lot_code: string | null;
    expiry_on: string | null;
    quantity: number;
    status: 'reserved' | 'committed' | 'consumed';
    expires_at: string | null;
  }[];
  preview: { lot_code: string; expiry_on: string | null; quantity: number }[];
};

export type WorkspaceTrace = {
  ready: boolean;
  issues: { sale_line_id: string; reason: string }[];
};

export type OrderLineTrace = {
  mode: 'serial' | 'lot';
  allocations: {
    serial: string | null;
    lot_code: string | null;
    expiry_on: string | null;
    quantity: number;
    returned_quantity: number;
  }[];
};

export type ReturnPreviewTrace = {
  mode: 'serial' | 'lot';
  serials: string[];
  // An expired lot cannot go back on sale: its units are quarantined.
  lots: {
    lot_code: string;
    expiry_on: string | null;
    quantity: number;
    forced_quarantine?: boolean;
  }[];
};

export type ReturnLineTraceRow = {
  serial: string | null;
  lot_code: string | null;
  expiry_on: string | null;
  quantity: number;
  condition: string;
  status: string;
};

// Refusals the server names for stock traceability; each has its own sentence
// under `traceReason_<reason>`.
const TRACE_REASONS = new Set([
  'trace_unreconciled',
  'trace_not_enrolled',
  'trace_serial_required',
  'trace_serial_unavailable',
  'trace_serial_duplicate',
  'trace_serial_released',
  'trace_lot_pick_forbidden',
  'trace_lot_invalid',
  'trace_insufficient',
  'trace_stock_exists',
  'trace_serial_mismatch',
  'trace_lot_mismatch',
  'trace_already_returned',
  'trace_return_detail_required',
  'trace_serial_unit_mismatch',
  'trace_condition_required',
  'trace_allocation_missing',
  'trace_fulfillment_mismatch',
  'trace_count_below_held',
  'trace_serial_invalid',
  'trace_mode_mismatch',
]);

// Refusals of stock commands (receipts, transfers, counts, approvals). Some
// share a name with other POS flows, so they are only read on stock screens.
const INVENTORY_REASONS = new Set([
  'opening_unreconciled',
  'already_enrolled',
  'enrollment_allocated',
  'not_tracked',
  'lot_expired',
  'lot_expiry_mismatch',
  'lot_quarantined',
  'serial_exists',
  'serial_unavailable',
  'recall_query_invalid',
  'count_no_change',
  'count_stale',
  'duplicate_lot',
  'duplicate_serial',
  'nothing_to_receive',
  'nothing_to_transfer',
  'self_approval',
  'not_pending',
  'approval_required',
  'already_applied',
  'adjustment_canceled',
]);

export function traceReasonKey(reason: string | null | undefined): string | null {
  return reason && TRACE_REASONS.has(reason) ? `traceReason_${reason}` : null;
}

export function inventoryReasonKey(reason: string | null | undefined): string | null {
  return (
    traceReasonKey(reason) ??
    (reason && INVENTORY_REASONS.has(reason) ? `traceReason_${reason}` : null)
  );
}

type Translate = (key: string, options?: Record<string, unknown>) => string;

// A whole number from the conflict details, when the server gave one.
function detailNumber(error: unknown, field: string): number | null {
  if (typeof error !== 'object' || error === null || !('details' in error)) return null;
  const details = error.details;
  if (typeof details !== 'object' || details === null || !(field in details)) return null;
  const value = (details as Record<string, unknown>)[field];
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

function sentence(error: unknown, reason: string, key: string, translate: Translate): string {
  if (reason === 'opening_unreconciled') {
    const typed = detailNumber(error, 'typed_on_hand');
    const core = detailNumber(error, 'core_on_hand');
    if (typed !== null && core !== null)
      return translate('traceReason_opening_unreconciled_counts', { typed, core });
  }
  return translate(key);
}

// Sale, basket and return screens: trace refusals get their own sentence,
// anything else keeps the shared wording.
export function describeTraceFailure(
  error: unknown,
  translate: Translate,
  fallbackKey?: string,
): string {
  const reason = conflictReason(error);
  const key = traceReasonKey(reason);
  return key && reason
    ? sentence(error, reason, key, translate)
    : describeFailure(error, translate, fallbackKey);
}

// Stock screens also name the stock command refusals.
export function describeInventoryFailure(error: unknown, translate: Translate): string {
  const reason = conflictReason(error);
  const key = inventoryReasonKey(reason);
  return key && reason
    ? sentence(error, reason, key, translate)
    : describeFailure(error, translate);
}

export type ExpiryState = 'none' | 'expired' | 'near' | 'ok';

const DAY_MS = 86_400_000;
const DATE = /^\d{4}-\d{2}-\d{2}$/;

// Whole days from `today` to `expiryOn`, both YYYY-MM-DD calendar dates in the
// branch timezone. Null when either is not a date.
export function daysUntil(expiryOn: string | null | undefined, today: string): number | null {
  if (!expiryOn || !DATE.test(expiryOn) || !DATE.test(today)) return null;
  const end = Date.parse(`${expiryOn}T00:00:00Z`);
  const start = Date.parse(`${today}T00:00:00Z`);
  if (Number.isNaN(end) || Number.isNaN(start)) return null;
  return Math.round((end - start) / DAY_MS);
}

// A lot is usable through its expiry date and expired from the next day on.
export function expiryState(
  expiryOn: string | null | undefined,
  today: string,
  nearDays = 30,
): ExpiryState {
  const days = daysUntil(expiryOn, today);
  if (days === null) return 'none';
  if (days < 0) return 'expired';
  return days <= nearDays ? 'near' : 'ok';
}

// 2026-12-31 -> 31/12/2026, the way Vietnamese receipts print dates.
export function formatExpiry(expiryOn: string | null | undefined): string {
  if (!expiryOn || !DATE.test(expiryOn)) return '—';
  const [year, month, day] = expiryOn.split('-');
  return `${day}/${month}/${year}`;
}

export const MAX_SERIAL_LENGTH = 100;

// Serial codes typed or scanned one per line (commas and spaces also separate
// them). Order is kept, repeats are reported once and dropped.
export function parseSerials(text: string): {
  codes: string[];
  duplicates: string[];
  tooLong: string[];
} {
  const seen = new Set<string>();
  const duplicates = new Set<string>();
  const tooLong: string[] = [];
  const codes: string[] = [];
  for (const raw of text.split(/[\s,;]+/)) {
    const code = raw.trim();
    if (!code) continue;
    if (code.length > MAX_SERIAL_LENGTH) {
      tooLong.push(code);
      continue;
    }
    if (seen.has(code)) {
      duplicates.add(code);
      continue;
    }
    seen.add(code);
    codes.push(code);
  }
  return { codes, duplicates: [...duplicates], tooLong };
}

export type LotRowDraft = { lot_code: string; expiry_on: string; quantity: string };
export type LotRowInput = { lot_code: string; expiry_on?: string; quantity: number };

// Lot rows of a receipt or opening balance. Blank rows are ignored; a row with
// a code needs a whole positive quantity in base units and an optional date.
export function parseLotRows(
  rows: LotRowDraft[],
): { lots: LotRowInput[]; error: null } | { lots: null; error: string } {
  const lots: LotRowInput[] = [];
  const codes = new Set<string>();
  for (const row of rows) {
    const code = row.lot_code.trim();
    const quantityText = row.quantity.trim();
    const expiry = row.expiry_on.trim();
    if (!code && !quantityText && !expiry) continue;
    if (!code || code.length > 64) return { lots: null, error: 'inventoryLotCodeInvalid' };
    if (!/^\d{1,9}$/.test(quantityText) || Number(quantityText) <= 0)
      return { lots: null, error: 'inventoryQuantityInvalid' };
    if (expiry && (!DATE.test(expiry) || Number.isNaN(Date.parse(`${expiry}T00:00:00Z`))))
      return { lots: null, error: 'inventoryExpiryInvalid' };
    const key = code.toLocaleUpperCase('vi');
    if (codes.has(key)) return { lots: null, error: 'inventoryLotDuplicate' };
    codes.add(key);
    lots.push({
      lot_code: code,
      ...(expiry ? { expiry_on: expiry } : {}),
      quantity: Number(quantityText),
    });
  }
  return lots.length ? { lots, error: null } : { lots: null, error: 'inventoryNothingEntered' };
}

export type StockEntry =
  | { body: { serials: string[] } | { lots: LotRowInput[] }; error: null; codes: [] }
  | { body: null; error: string; codes: string[] };

// Body of a receipt or opening balance for the variant's tracked mode: serial
// codes one per line, or lot rows. Repeated or overlong codes are refused here
// so the stock keeper sees them before anything is sent.
export function stockEntryPayload(
  mode: TrackedMode,
  serialText: string,
  lotRows: LotRowDraft[],
): StockEntry {
  if (mode === 'serial') {
    const { codes, duplicates, tooLong } = parseSerials(serialText);
    if (tooLong.length) return { body: null, error: 'inventorySerialTooLong', codes: tooLong };
    if (duplicates.length)
      return { body: null, error: 'inventorySerialDuplicate', codes: duplicates };
    if (!codes.length) return { body: null, error: 'inventoryNothingEntered', codes: [] };
    return { body: { serials: codes }, error: null, codes: [] };
  }
  if (mode === 'lot') {
    const parsed = parseLotRows(lotRows);
    return parsed.error === null
      ? { body: { lots: parsed.lots }, error: null, codes: [] }
      : { body: null, error: parsed.error, codes: [] };
  }
  return { body: null, error: 'traceReason_not_tracked', codes: [] };
}

// A whole number of base units, or null. Blank is null too.
export function parseWholeQuantity(text: string, allowZero = false): number | null {
  const value = text.trim();
  if (!/^\d{1,9}$/.test(value)) return null;
  const number = Number(value);
  return number > 0 || (allowZero && number === 0) ? number : null;
}

// Serials of a sold line that can still come back.
export function returnableSerials(trace: OrderLineTrace | null | undefined): string[] {
  if (trace?.mode !== 'serial') return [];
  return trace.allocations.flatMap((allocation) =>
    allocation.serial && allocation.returned_quantity < allocation.quantity
      ? [allocation.serial]
      : [],
  );
}

// Lots of a sold line with quantity still returnable, merged by code.
export function returnableLots(
  trace: OrderLineTrace | null | undefined,
): { lot_code: string; expiry_on: string | null; remaining: number }[] {
  if (trace?.mode !== 'lot') return [];
  const lots = new Map<string, { lot_code: string; expiry_on: string | null; remaining: number }>();
  for (const allocation of trace.allocations) {
    if (!allocation.lot_code) continue;
    const remaining = allocation.quantity - allocation.returned_quantity;
    if (remaining <= 0) continue;
    const current = lots.get(allocation.lot_code);
    if (current) current.remaining += remaining;
    else
      lots.set(allocation.lot_code, {
        lot_code: allocation.lot_code,
        expiry_on: allocation.expiry_on,
        remaining,
      });
  }
  return [...lots.values()];
}

// The server needs the lot named when more than one lot of the line can still
// be returned.
export function lotChoiceRequired(trace: OrderLineTrace | null | undefined): boolean {
  return returnableLots(trace).length > 1;
}

export type PaymentBlock = {
  ready: boolean;
  issues: { saleLineId: string; name: string; reason: string }[];
  // Holding stock again can clear these; unreconciled or not-enrolled stock
  // needs a stock keeper first.
  fixable: boolean;
};

const FIXABLE_ISSUES = new Set(['trace_serial_released', 'trace_insufficient']);

// Payment stays closed while the server says traced stock is not ready.
// Payloads without trace come from servers without traceability: ready.
export function paymentBlock(workspace: {
  trace?: WorkspaceTrace | null;
  line_items?: { sale_line_id: string | null; id: string; name: string }[];
}): PaymentBlock {
  const trace = workspace.trace;
  if (trace?.ready !== false) return { ready: true, issues: [], fixable: false };
  const names = new Map(
    (workspace.line_items ?? []).map((line) => [line.sale_line_id ?? line.id, line.name]),
  );
  const issues = (trace.issues ?? []).map((issue) => ({
    saleLineId: issue.sale_line_id,
    name: names.get(issue.sale_line_id) ?? issue.sale_line_id,
    reason: issue.reason,
  }));
  return {
    ready: false,
    issues,
    fixable: issues.some((issue) => FIXABLE_ISSUES.has(issue.reason)),
  };
}

export function canManageInventory(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.inventory.manage'));
}

export function canTraceInventory(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.inventory.trace'));
}

// Approvers open the page to decide stock adjustments, and see nothing else.
export function canOpenInventory(capabilities: readonly string[] | undefined): boolean {
  return (
    canManageInventory(capabilities) ||
    canTraceInventory(capabilities) ||
    Boolean(capabilities?.includes('pos.approval.grant'))
  );
}

export type InventoryTab =
  | 'variants'
  | 'lots'
  | 'serials'
  | 'receive'
  | 'transfer'
  | 'adjust'
  | 'recall';

export function inventoryTabs(capabilities: readonly string[] | undefined): InventoryTab[] {
  const manage = canManageInventory(capabilities);
  const trace = canTraceInventory(capabilities);
  const approve = Boolean(capabilities?.includes('pos.approval.grant'));
  return [
    ...(manage || trace ? (['variants', 'lots', 'serials'] as const) : []),
    ...(manage ? (['receive', 'transfer'] as const) : []),
    ...(manage || approve ? (['adjust'] as const) : []),
    ...(trace ? (['recall'] as const) : []),
  ];
}

// A scanner may end each code with Tab. Inside a serial list that Tab is a
// line break, so the next scan stays in the list instead of leaving it; Tab on
// an empty last line still moves focus on. Null lets the browser handle it.
export function serialListAfterTab(value: string, shiftKey: boolean): string | null {
  if (shiftKey) return null;
  const lastLine = value.split('\n').at(-1) ?? '';
  return lastLine.trim() ? `${value}\n` : null;
}

// What the signed-in member may do with an adjustment. Mirrors the server:
// a different approver approves, the requester applies once approved, and the
// requester or an approver cancels while it waits.
export function adjustmentActions(
  adjustment: Pick<PosAdjustment, 'status' | 'requester_id' | 'approval' | 'requires_approval'>,
  staffId: string | null,
  capabilities: readonly string[] | undefined,
): { approve: boolean; apply: boolean; cancel: boolean } {
  if (adjustment.status !== 'pending_approval')
    return { approve: false, apply: false, cancel: false };
  const approver = Boolean(capabilities?.includes('pos.approval.grant'));
  const requester = staffId !== null && adjustment.requester_id === staffId;
  const approved = adjustment.approval?.status === 'active';
  return {
    approve: approver && !requester && !approved,
    apply: requester && (approved || !adjustment.requires_approval),
    cancel: requester || approver,
  };
}
