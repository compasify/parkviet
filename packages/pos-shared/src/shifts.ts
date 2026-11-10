import {
  conflictReason,
  featureDisabledText,
  financialStorageFailure,
  posFailureKey,
} from './request-failure';

// Shift close, drawer movements and late-cash reconciliation. Every amount is
// a canonical decimal string computed by the server; the helpers below only
// classify and present them.

export type ChecklistItem = {
  type:
    | 'tender_attempt'
    | 'workspace_money'
    | 'liability_payout'
    | 'refund_request'
    | 'cash_movement_request'
    | 'draft';
  id?: string;
  workspace_id?: string;
  funds_id?: string;
  return_id?: string;
  order_number?: string;
  status: string;
  amount?: string;
  kind?: string;
};

export type ShiftChecklist = { blocking: ChecklistItem[]; warnings: ChecklistItem[] };

export type ShiftCount = {
  shift_id: string;
  branch_id?: string;
  currency?: string;
  revision: number;
  status: string;
  counted: string | null;
  expected: string | null;
  variance: string | null;
  variance_threshold: string | null;
  requires_approval: boolean | null;
  stale: boolean | null;
  reason: string | null;
  counted_at: string | null;
  counted_by_id: string | null;
  approval: {
    id: string;
    approver_id: string;
    approver_name: string;
    amount: string | null;
    expires_at: string;
  } | null;
};

export type ShiftClosure = {
  id: string;
  shift_id: string;
  branch_id: string;
  register_id: string | null;
  closer_id: string;
  closer_name: string;
  approver_id: string | null;
  approver_name: string | null;
  currency: string;
  opening_float: string;
  inflow_total: string;
  outflow_total: string;
  expected: string;
  counted: string;
  variance: string;
  variance_threshold: string | null;
  reason: string | null;
  cutoff_movement_id: string | null;
  movement_count: number;
  breakdown: Record<string, string>;
  reconciled: string;
  opened_at: string;
  closed_at: string;
};

export type ShiftCloseState = {
  shift: {
    id: string;
    branch_id: string;
    register_id: string | null;
    status: 'open' | 'closed';
    opening_float: string;
    currency: string;
    owner_id: string;
    opened_at: string | null;
    closed_at: string | null;
    revision: number;
    counted: boolean;
  };
  checklist: ShiftChecklist;
  count: ShiftCount;
  closure: ShiftClosure | null;
  can_close: boolean;
  can_approve: boolean;
};

export type PendingClose = ShiftCount & {
  register: string | null;
  owner_name: string;
  counted_by_name: string;
  opened_at: string;
  self_count: boolean;
};

export type CashMovementKind = 'cash_in' | 'cash_out' | 'safe_drop';

// A cash out or safe drop waiting for a second person; only a confirmed one
// moved drawer cash.
export type CashMovementRequest = {
  id: string;
  branch_id: string;
  shift_id: string;
  kind: 'cash_out' | 'safe_drop';
  status: 'requested' | 'confirmed' | 'canceled';
  amount: string;
  currency: string;
  reason: string;
  evidence_reference: string;
  requester_id: string;
  requester_name: string;
  confirmer_id: string | null;
  confirmer_name: string | null;
  cash_movement_id: string | null;
  resolution_note: string | null;
  created_at: string | null;
  resolved_at: string | null;
};

export type OpenShiftRow = {
  id: string;
  branch_id: string;
  register_id: string | null;
  register: string | null;
  owner_id: string;
  owner_name: string;
  opening_float: string;
  currency: string;
  opened_at: string | null;
  counted: boolean;
};

export type PosCashMovement = {
  id: string;
  shift_id: string;
  kind: string;
  category: string;
  amount: string;
  currency: string;
  reason: string | null;
  evidence_reference: string | null;
  created_at: string | null;
  // 'posted' on the response of a cash in.
  status?: string;
};

export type CustodyOutcome = 'in_opening_float' | 'safe' | 'handed_over' | 'new_physical_inflow';

export type ReconcileCandidates = {
  closures: {
    id: string;
    shift_id: string;
    register: string | null;
    owner_name: string;
    closed_at: string;
    counted: string;
    expected: string;
    variance: string;
    unexplained: string;
    currency: string;
  }[];
  held_funds: {
    id: string;
    shift_id: string;
    amount: string;
    currency: string;
    custody_note: string | null;
    received_at: string;
    booked_at: string;
    recorded_by: string;
    recorded_by_me: boolean;
    shift_owner_name?: string;
    shift_status?: string;
    shift_opened_at?: string;
    shift_closed_at?: string | null;
    closure_id?: string | null;
    closure_counted?: string | null;
    closure_expected?: string | null;
    closure_unexplained?: string | null;
    overage_explained?: boolean;
  }[];
  shifts: {
    id: string;
    status: string;
    register: string | null;
    owner_name: string;
    opening_float: string;
    opened_at: string;
    closed_at: string | null;
  }[];
};

export type CashReconciliation = {
  id: string;
  outcome: CustodyOutcome;
  amount: string;
  currency: string;
  reason: string;
  custody_reference: string | null;
  closed_shift_id: string | null;
  received_funds_id: string | null;
  target_shift_id: string | null;
  cash_movement_id: string | null;
  actor_name: string;
  created_at: string | null;
};

export function canMoveCash(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.cash.move'));
}

export function canReconcileCash(capabilities: readonly string[] | undefined): boolean {
  return Boolean(
    capabilities?.includes('pos.approval.grant') && capabilities.includes('pos.payment.resolve'),
  );
}
// Variance direction in words, so status is never conveyed by colour alone.
export function varianceKind(
  variance: string | null | undefined,
): 'over' | 'short' | 'even' | null {
  if (variance == null || !/^-?\d+(\.\d+)?$/.test(variance)) return null;
  if (/^-?0+(\.0+)?$/.test(variance)) return 'even';
  return variance.startsWith('-') ? 'short' : 'over';
}

// Absolute value of a canonical decimal string, for "thiếu 10.000 ₫".
export function absoluteAmount(amount: string): string {
  return amount.startsWith('-') ? amount.slice(1) : amount;
}

// The movements that take cash out of the drawer.
export function isOutflow(kind: CashMovementKind): boolean {
  return kind !== 'cash_in';
}
// Only the custody outcome that puts cash into a drawer now posts a movement.
export function addsDrawerCash(outcome: CustodyOutcome): boolean {
  return outcome === 'new_physical_inflow';
}

export function outcomeNeedsReference(outcome: CustodyOutcome): boolean {
  return outcome === 'safe' || outcome === 'handed_over';
}

export function outcomeTakesShift(outcome: CustodyOutcome): boolean {
  return outcome === 'new_physical_inflow' || outcome === 'in_opening_float';
}

// Whole-VND comparison of canonical strings ("100000.0") for client checks.
export function wholeAmount(value: string | null | undefined): bigint | null {
  if (value == null) return null;
  const match = /^(-?\d+)(?:\.0+)?$/.exec(value);
  return match ? BigInt(match[1]) : null;
}

// A closure-only reconciliation names its amount: whole VND, at most the
// overage still unexplained.
export function reconcileAmountError(
  input: string,
  parsed: string | null,
  unexplained: string,
): 'shiftReason_amount_invalid' | 'shiftReason_exceeds_variance' | null {
  if (input.trim() === '' || parsed === null || parsed === '0') return 'shiftReason_amount_invalid';
  const cap = wholeAmount(unexplained);
  return cap !== null && BigInt(parsed) > cap ? 'shiftReason_exceeds_variance' : null;
}

const SHIFT_REASONS = new Set([
  'shift_closed',
  'close_blocked',
  'count_required',
  'count_stale',
  'recount_required',
  'reason_required',
  'approval_required',
  'approval_not_needed',
  'revision_stale',
  'self_approval',
  'amount_invalid',
  'insufficient_cash',
  'kind_invalid',
  'reason_invalid',
  'evidence_invalid',
  'evidence_required',
  'outcome_invalid',
  'source_required',
  'target_required',
  'target_invalid',
  'not_held',
  'already_reconciled',
  'shift_mismatch',
  'amount_mismatch',
  'no_overage',
  'exceeds_variance',
  'overage_explained',
  'exceeds_float',
  'held_custody',
  'not_awaiting',
  'decision_invalid',
  'retry',
]);

// Vietnamese copy for every failure: known reasons have their own sentence;
// an unknown server message never reaches the cashier verbatim.
export function describeShiftFailure(error: unknown, translate: (key: string) => string): string {
  if (financialStorageFailure(error)) return translate('financialStorageUnavailable');
  const disabled = featureDisabledText(error, translate);
  if (disabled) return disabled;
  const reason = conflictReason(error);
  if (reason && SHIFT_REASONS.has(reason)) return translate(`shiftReason_${reason}`);
  const key = posFailureKey(error);
  return translate(key === 'conflict' || key === 'invalid' ? 'shiftFailureGeneric' : key);
}

// The checklist a blocked count or close returned with its 409.
export function blockedChecklist(error: unknown): ShiftChecklist | null {
  if (conflictReason(error) !== 'close_blocked') return null;
  const details = (error as { details?: { checklist?: ShiftChecklist } }).details;
  const checklist = details?.checklist;
  return checklist && Array.isArray(checklist.blocking) ? checklist : null;
}
