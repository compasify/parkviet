import { parseVndAmount } from './money';
import { posCapabilities } from './pos-capabilities';
import { conflictReason, describeFailure } from './request-failure';

// Receivables are readable by members of the branch. Topology management and
// recovery can come from store roles, so they alone do not prove membership.
const MEMBERSHIP_CAPABILITIES: string[] = posCapabilities
  .map(([key]) => key)
  .filter((key) => key !== 'pos.topology.manage' && key !== 'pos.topology.recover');

export function canReadReceivables(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.some((capability) => MEMBERSHIP_CAPABILITIES.includes(capability)));
}

// Whole-VND arithmetic for debt collection previews. Inputs are canonical
// server strings ("150000.0") or already-parsed cashier input ("150000"); the
// server re-checks every amount, so these helpers only shape the preview.

export type DebtRow = { orderId: string; balance: string };
export type AllocationDraft = { orderId: string; amount: string };

function whole(value: string | null | undefined): bigint | null {
  if (value == null) return null;
  const parsed = parseVndAmount(value);
  return parsed === null ? null : BigInt(parsed);
}

export function sumVnd(values: Array<string | null | undefined>): string {
  return String(values.reduce((total, value) => total + (whole(value) ?? 0n), 0n));
}

// Fills debts in the given order (callers pass oldest due first) until the
// collected amount runs out. Orders that receive nothing are left out.
export function planAllocations(amount: string, debts: DebtRow[]): AllocationDraft[] {
  let left = whole(amount) ?? 0n;
  const plan: AllocationDraft[] = [];
  for (const debt of debts) {
    if (left <= 0n) break;
    const balance = whole(debt.balance) ?? 0n;
    if (balance <= 0n) continue;
    // BigInt cannot go through Math.min.
    let take = left;
    if (balance < left) take = balance;
    plan.push({ orderId: debt.orderId, amount: String(take) });
    left -= take;
  }
  return plan;
}

export type AllocationPreview = {
  allocated: string;
  // Money kept on the receipt for a later allocation or payout; never negative debt.
  unallocated: string;
  // Allocations add up to more than was collected.
  exceedsReceipt: boolean;
  // Orders whose allocation is larger than what they still owe.
  overDebt: string[];
  // Rows whose amount is not a whole positive VND amount.
  invalid: string[];
};

export function previewAllocations(
  amount: string,
  rows: AllocationDraft[],
  debts: DebtRow[],
): AllocationPreview {
  const collected = whole(amount) ?? 0n;
  const balances = new Map(debts.map((debt) => [debt.orderId, whole(debt.balance) ?? 0n]));
  let allocated = 0n;
  const overDebt: string[] = [];
  const invalid: string[] = [];
  for (const row of rows) {
    const value = whole(row.amount);
    if (value === null || value <= 0n) {
      invalid.push(row.orderId);
      continue;
    }
    allocated += value;
    if (value > (balances.get(row.orderId) ?? 0n)) overDebt.push(row.orderId);
  }
  const rest = collected - allocated;
  return {
    allocated: String(allocated),
    unallocated: String(rest > 0n ? rest : 0n),
    exceedsReceipt: allocated > collected,
    overDebt,
    invalid,
  };
}

// Sign of a canonical server amount ("0.0", "150000.0"); never a string compare.
export function amountSign(value: string | null | undefined): -1 | 0 | 1 {
  if (value == null) return 0;
  const match = /^(-)?(\d+)(?:\.(\d+))?$/.exec(value.trim());
  if (!match) return 0;
  const nonZero = /[1-9]/.test(match[2]) || /[1-9]/.test(match[3] ?? '');
  if (!nonZero) return 0;
  return match[1] ? -1 : 1;
}

export const STORE_TIMEZONE = 'Asia/Ho_Chi_Minh';

// "2026-12-07" (a calendar date from the server) as dd/MM/yyyy.
export function formatDueDate(value: string | null | undefined): string {
  const match = value ? /^(\d{4})-(\d{2})-(\d{2})$/.exec(value) : null;
  return match ? `${match[3]}/${match[2]}/${match[1]}` : '—';
}

// A server timestamp shown in the store's timezone, like the local records list.
export function formatInstant(value: string | null | undefined, locale: string): string {
  if (!value) return '—';
  const date = new Date(value);
  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleString(locale, { timeZone: STORE_TIMEZONE });
}

// An approval past its expiry is unusable even before the server says so.
export function approvalExpired(expiresAt: string | null | undefined, now = Date.now()): boolean {
  if (!expiresAt) return true;
  const time = Date.parse(expiresAt);
  return Number.isNaN(time) || time <= now;
}

// Server conflict reasons that have their own Vietnamese explanation.
export const CREDIT_CONFLICT_REASONS = [
  'credit_approval_stale',
  'credit_limit_exceeded',
  'credit_account_suspended',
  'credit_account_missing',
  'credit_customer_required',
  'credit_request_closed',
  'exceeds_debt',
  'duplicate_reference',
  'shift_required',
  'shift_closed',
  'tender_unresolved',
  'allocation_consumed',
  'approval_not_active',
] as const;

export function creditConflictKey(reason: string | null): string | null {
  return reason && (CREDIT_CONFLICT_REASONS as readonly string[]).includes(reason)
    ? `conflictReason_${reason}`
    : null;
}

export function describeCreditFailure(error: unknown, translate: (key: string) => string): string {
  const key = creditConflictKey(conflictReason(error));
  return key ? translate(key) : describeFailure(error, translate);
}

// Change owed back for cash: null while the handed amount is missing or short.
export function cashChange(handed: string | null, amount: string | null): string | null {
  const given = whole(handed);
  const kept = whole(amount);
  if (given === null || kept === null || given < kept) return null;
  return String(given - kept);
}
