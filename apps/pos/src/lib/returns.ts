import {
  describeTraceFailure,
  lotChoiceRequired,
  type OrderLineTrace,
  type ReturnLineTraceRow,
  type ReturnPreviewTrace,
  returnableLots,
} from '@parkviet/pos-shared/traceability';
import { conflictReason } from './request-failure';

// Domain refusals the server names; each has its own Vietnamese sentence.
const RETURN_REASONS = new Set([
  'returns_disabled',
  'exceeds_returnable',
  'not_handed_over',
  'core_return_refused',
  'approval_required',
  'already_received',
  'return_canceled',
  'not_pending',
  'self_approval',
  'not_cancelable',
  'dependent_posted',
  'entitlement_not_posted',
  'exceeds_entitlement',
  'exceeds_payment',
  'not_awaiting',
  'shift_required',
  'not_reserved',
  'invalid_state',
  'exchange_exists',
  'reason_required',
  'approval_issued',
  'retry',
  'not_covered',
  'return_entitlement_depends_on_collection',
]);

export function describeReturnFailure(error: unknown, translate: (key: string) => string): string {
  const reason = conflictReason(error);
  return reason && RETURN_REASONS.has(reason)
    ? translate(`returnReason_${reason}`)
    : describeTraceFailure(error, translate);
}

// Order history, returns, refunds and exchanges. Amounts are canonical decimal
// strings from the server; the helpers below only add, compare and split them
// with BigInt fixed point (4 decimals, the server's scale) for presentation.
// Every amount that is posted or paid is computed by the server under locks.

export type EntitlementComponents = {
  total: string;
  net: string;
  tax: string;
  discount: string;
  gross: string;
};

export type PosOrderRow = {
  id: string;
  number: string;
  workspace_id: string;
  // Missing on older servers (read as counter).
  order_source?: string;
  placed_at: string | null;
  register: string | null;
  cashier: string;
  cashier_id: string;
  customer: { id: string; name: string | null; phone: string | null } | null;
  currency: string;
  total: string;
  paid: string;
  debt: string | null;
  returned: boolean;
  refund_pending: boolean;
};

export type PosOrderLine = {
  sale_line_id: string;
  name: string;
  sku: string | null;
  sale_quantity: string;
  sale_unit: string;
  base_quantity: number;
  base_unit: string;
  unit_price: string;
  lot_code: string | null;
  serial_codes: string[];
  original: EntitlementComponents;
  returned_quantity: number;
  posted_quantity: number;
  returnable_quantity: number;
  handed_over: boolean;
  entitlement_used: string;
  entitlement_reserved: string;
  // Serials or lots the line sold, with what already came back.
  trace?: OrderLineTrace | null;
};

export type PosOrderReceipt = {
  allocation_id: string;
  funds_id: string;
  kind: 'cash' | 'bank_manual';
  status: string;
  amount: string;
  refunded: string;
  refund_reserved: string;
  refundable: string;
  collection: boolean;
  reference: string | null;
  received_at: string | null;
};

export type PosApprovalRef = { id: string; status: string; expires_at: string } | null;

export type RefundStatus = 'reserved' | 'unknown' | 'confirmed' | 'failed' | 'canceled';

export type PosRefundRequest = {
  id: string;
  return_id: string;
  branch_id: string;
  order_id: string;
  order_number: string;
  allocation_id: string;
  funds_id: string;
  funds_kind: string;
  method: 'cash' | 'bank_manual';
  status: RefundStatus;
  amount: string;
  currency: string;
  revision: number;
  requester_id: string;
  confirmer_id: string | null;
  shift_id: string | null;
  refund_id: string | null;
  beneficiary_reference: string | null;
  approval: PosApprovalRef;
  // kind 'unknown' records that nobody could tell whether money left.
  evidence: { id: string; kind: string; reference: string | null; attested_at: string } | null;
  created_at: string;
  confirmed_at: string | null;
  resolved_at: string | null;
};

export type ReturnCondition = 'resellable' | 'damaged';

export type PosReturnLine = EntitlementComponents & {
  id: string;
  sale_line_id: string;
  name: string;
  sku: string | null;
  quantity: number;
  sequence: number;
  cumulative_before: number;
  cumulative_after: number;
  condition: ReturnCondition;
  status: 'reserved' | 'posted' | 'canceled';
  received_quantity: number;
  restocked_quantity: number;
  trace?: ReturnLineTraceRow[];
};

// List row of a return (approvals, order detail); the full return adds lines,
// refund requests and the expected credit-note/refund split.
export type PosReturnRow = {
  id: string;
  branch_id: string;
  sale_branch_id: string;
  order_id: string;
  order_number: string;
  return_number: string;
  requester_id: string;
  requester_name: string | null;
  status: 'pending_approval' | 'ready' | 'received' | 'canceled';
  entitlement_status: 'pending' | 'awaiting_predecessor' | 'posted' | 'canceled';
  reason: string;
  cross_branch: boolean;
  out_of_window: boolean;
  damaged: boolean;
  requires_approval: boolean;
  revision: number;
  approval: PosApprovalRef;
  currency: string;
  entitlement_total: string;
  credit_note_amount: string;
  refund_entitlement: string;
  refund_requested: string;
  refunded: string;
  created_at: string;
  received_at: string | null;
};

export type PosReturn = PosReturnRow & {
  workspace_id: string;
  expected_credit_note: string;
  expected_refund: string;
  refundable_remaining: string;
  lines: PosReturnLine[];
  refund_requests: PosRefundRequest[];
  exchange_id: string | null;
  expires_at: string | null;
  posted_at: string | null;
  canceled_at: string | null;
};

export type PosExchange = {
  id: string;
  return_id: string;
  replacement_workspace_id: string;
  replacement_order_number: string;
  replacement_status: string;
  replacement_total: string;
  credit_note_amount: string;
  refund_entitlement: string;
  refunded: string;
  refund_owed: string;
  // Null until the replacement sale has a total.
  customer_pays: string | null;
  store_refunds: string | null;
  currency: string;
};

export type PosStockDiscrepancy = {
  id: string;
  sku: string | null;
  name: string;
  needed: number;
  on_hand: number;
  status: 'open' | 'resolved';
  checked_at: string;
};

export type PosTimelineEvent = {
  id: string;
  at: string;
  kind: string;
  amount: string | null;
  reference?: string;
};

export type PosOrderDetail = PosOrderRow & {
  sale_branch_id: string;
  totals: { original_total: string; item_total: string; discount_total: string; tax_total: string };
  lines: PosOrderLine[];
  entitlement: { used: string; reserved: string; credit_notes: string; refund_entitlement: string };
  receipts: PosOrderReceipt[];
  refunds: PosRefundRequest[];
  credit: {
    debt: string;
    credit_notes: string;
    collected: string;
    balance: string;
    due_on: string | null;
  } | null;
  returns: PosReturnRow[];
  exchanges: PosExchange[];
  stock: {
    location_id: string;
    fulfillments: {
      id: string;
      status: string;
      location_id: string;
      fulfilled_at: string | null;
    }[];
    restocked_quantity: number;
    damaged_quantity: number;
    discrepancies: PosStockDiscrepancy[];
  };
  timeline: PosTimelineEvent[];
};

export type ReturnPreviewLine = {
  sale_line_id: string;
  quantity: number;
  condition: ReturnCondition;
  sold_quantity: number;
  cumulative_before: number;
  cumulative_after: number;
  remaining_before: number;
  original: EntitlementComponents;
  used: string;
  reserved: string;
  this_time: EntitlementComponents;
  // The serials or lot quantities this return takes back.
  trace?: ReturnPreviewTrace | null;
};

export type ReturnPreview = {
  order_id: string;
  order_number: string;
  currency: string;
  cross_branch: boolean;
  out_of_window: boolean;
  damaged: boolean;
  requires_approval: boolean;
  entitlement_total: string;
  credit_note: string;
  refund: string;
  // Value returned that is neither credited to debt nor refundable.
  unrefundable: string;
  lines: ReturnPreviewLine[];
};

// Serial lines name the serials coming back (their count is the quantity);
// lot lines name the lot when more than one can still be returned.
// Traced lines (serials, lots) start without a condition: the cashier must
// look at the goods and choose; other lines default to resellable.
export type ReturnPick = {
  quantity: number;
  condition: ReturnCondition | null;
  serial_codes?: string[];
  lot_code?: string;
};

export type ReturnSelection = Record<string, ReturnPick>;

export type ReturnSelectionLine = {
  sale_line_id: string;
  quantity: number;
  condition: ReturnCondition;
  serial_codes?: string[];
  lot_code?: string;
};

const SCALE = 4;
const FACTOR = 10n ** BigInt(SCALE);

// "150000.0", "0.4", "-12.3456" -> scaled BigInt. Throws on anything else so a
// malformed server value is never shown as a believable number.
export function toUnits(value: string): bigint {
  const match = /^(-)?(\d+)(?:\.(\d{1,4})\d*)?$/.exec(value.trim());
  if (!match) throw new Error(`Not a decimal amount: ${value}`);
  const fraction = (match[3] ?? '').padEnd(SCALE, '0');
  const units = BigInt(match[2]) * FACTOR + BigInt(fraction);
  return match[1] ? -units : units;
}

export function fromUnits(units: bigint): string {
  const negative = units < 0n;
  const absolute = negative ? -units : units;
  const whole = absolute / FACTOR;
  const fraction = (absolute % FACTOR).toString().padStart(SCALE, '0').replace(/0+$/, '');
  return `${negative ? '-' : ''}${whole}${fraction ? `.${fraction}` : ''}`;
}

export function sumMoney(values: string[]): string {
  return fromUnits(values.reduce((total, value) => total + toUnits(value), 0n));
}

export function subtractMoney(left: string, right: string): string {
  return fromUnits(toUnits(left) - toUnits(right));
}

export function minMoney(...values: string[]): string {
  // Math.min does not take BigInt; the smallest sorts first.
  const [smallest] = values
    .map(toUnits)
    .sort((left, right) => (left < right ? -1 : left > right ? 1 : 0));
  return fromUnits(smallest);
}

export function compareMoney(left: string, right: string): number {
  const difference = toUnits(left) - toUnits(right);
  return difference === 0n ? 0 : difference > 0n ? 1 : -1;
}

export function isPositive(value: string): boolean {
  return toUnits(value) > 0n;
}

// What a refund request may default to: the return's remaining refund
// entitlement, never more than the chosen receipt can still give back.
export function defaultRefundAmount(
  operation: Pick<PosReturn, 'refundable_remaining'>,
  receipt: Pick<PosOrderReceipt, 'refundable'>,
): string {
  const amount = minMoney(operation.refundable_remaining, receipt.refundable);
  return compareMoney(amount, '0') > 0 ? amount : '0';
}

// Lines of a selection that can be sent: positive whole quantities within the
// remaining returnable units of handed-over lines.
// Units of one lot the line can still take back.
function lotRemaining(line: PosOrderLine, lotCode: string): number {
  return returnableLots(line.trace).find((lot) => lot.lot_code === lotCode)?.remaining ?? 0;
}

export function selectionLines(
  lines: PosOrderLine[],
  selection: ReturnSelection,
): ReturnSelectionLine[] {
  return lines.flatMap((line) => {
    const picked = selection[line.sale_line_id];
    if (!picked || !Number.isInteger(picked.quantity) || picked.quantity <= 0) return [];
    if (picked.quantity > line.returnable_quantity) return [];
    const serials = line.trace?.mode === 'serial' ? (picked.serial_codes ?? []) : [];
    if (line.trace?.mode === 'serial' && serials.length !== picked.quantity) return [];
    const lot = line.trace?.mode === 'lot' ? picked.lot_code : undefined;
    if (lotChoiceRequired(line.trace) && !lot) return [];
    if (lot && picked.quantity > lotRemaining(line, lot)) return [];
    const condition = picked.condition;
    if (!condition) return [];
    return [
      {
        sale_line_id: line.sale_line_id,
        quantity: picked.quantity,
        condition,
        ...(serials.length ? { serial_codes: serials } : {}),
        ...(lot ? { lot_code: lot } : {}),
      },
    ];
  });
}

export function selectionError(lines: PosOrderLine[], selection: ReturnSelection): string | null {
  for (const line of lines) {
    const picked = selection[line.sale_line_id];
    if (!picked || picked.quantity === 0) continue;
    if (!Number.isInteger(picked.quantity) || picked.quantity < 0) return 'returnQuantityInvalid';
    if (picked.quantity > line.returnable_quantity) return 'returnQuantityTooMany';
    if (lotChoiceRequired(line.trace) && !picked.lot_code) return 'returnLotRequired';
    if (picked.lot_code && picked.quantity > lotRemaining(line, picked.lot_code))
      return 'returnLotTooMany';
    if (!picked.condition) return 'returnConditionRequired';
  }
  return selectionLines(lines, selection).length === 0 ? 'returnNothingSelected' : null;
}

export function parseQuantityInput(value: string): number | null {
  const text = value.trim();
  if (text === '') return 0;
  if (!/^\d{1,9}$/.test(text)) return null;
  return Number(text);
}

// The return screen keeps polling while someone else has to act: an approver,
// a predecessor return, or the approval of a refund payout.
export function returnWaits(operation: PosReturn): boolean {
  return (
    (operation.status === 'pending_approval' && operation.approval?.status !== 'active') ||
    operation.entitlement_status === 'awaiting_predecessor' ||
    operation.refund_requests.some(
      (refund) => refund.status === 'reserved' && refund.approval?.status !== 'active',
    )
  );
}

export function refundAwaitsPayout(status: RefundStatus): boolean {
  return status === 'reserved' || status === 'unknown';
}

export function canProcessReturns(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.return.process'));
}

export function canApprove(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.approval.grant'));
}

export function canResolve(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.payment.resolve'));
}

// The server lets return, resolve and approve staff read returns.
export function canReadReturns(capabilities: readonly string[] | undefined): boolean {
  return canProcessReturns(capabilities) || canApprove(capabilities) || canResolve(capabilities);
}

// Mirrors the server: the requester or an approver, before any approval
// was granted for the payout.
export function canCancelRefund(
  refund: Pick<PosRefundRequest, 'status' | 'approval' | 'requester_id'>,
  staffId: string | null,
  capabilities: readonly string[] | undefined,
): boolean {
  if (refund.status !== 'reserved' || refund.approval) return false;
  return (
    canApprove(capabilities) || (refund.requester_id === staffId && canProcessReturns(capabilities))
  );
}

export function canFailRefund(
  refund: Pick<PosRefundRequest, 'status'>,
  capabilities: readonly string[] | undefined,
): boolean {
  return refundAwaitsPayout(refund.status) && canResolve(capabilities);
}

export function canCancelReturn(
  operation: Pick<PosReturnRow, 'status' | 'requester_id'>,
  staffId: string | null,
  capabilities: readonly string[] | undefined,
): boolean {
  if (operation.status !== 'pending_approval' && operation.status !== 'ready') return false;
  return (
    canApprove(capabilities) ||
    (operation.requester_id === staffId && canProcessReturns(capabilities))
  );
}

// Stable money intent of one prepared return: the same order and lines give
// the same intent, so a retry after a lost response reuses its key.
export function prepareIntent(
  orderId: string,
  lines: {
    sale_line_id: string;
    quantity: number;
    condition: string;
    serial_codes?: string[];
    lot_code?: string;
  }[],
): string {
  const parts = [...lines]
    .sort((left, right) => left.sale_line_id.localeCompare(right.sale_line_id))
    .map((line) => {
      const serials = line.serial_codes?.length
        ? `:${[...line.serial_codes].sort().join('|')}`
        : '';
      const lot = line.lot_code ? `:lot=${line.lot_code}` : '';
      return `${line.sale_line_id}:${line.quantity}:${line.condition}${serials}${lot}`;
    });
  return `prepare:${orderId}:${parts.join(',')}`;
}

// Weighed and converted lines show their sale quantity and unit; returns are
// counted and sent in base units.
export function saleQuantityLabel(
  line: Pick<PosOrderLine, 'sale_quantity' | 'sale_unit' | 'base_quantity' | 'base_unit'>,
): string {
  const sale = line.sale_quantity
    .replace(/\.0+$/, '')
    .replace(/(\.\d*?)0+$/, '$1')
    .replace('.', ',');
  return line.sale_unit === line.base_unit
    ? `${sale} ${line.sale_unit}`
    : `${sale} ${line.sale_unit} (${line.base_quantity} ${line.base_unit})`;
}

export function dateRangeInvalid(from: string, to: string): boolean {
  return Boolean(from && to && from > to);
}
