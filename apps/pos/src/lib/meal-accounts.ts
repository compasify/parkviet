import { parseVndAmount } from '@parkviet/pos-shared/money';

// Canteen meal accounts as the counter reads them: the eater, their wallet
// and who pays what on an order. Money stays the server's decimal strings.

export const MEAL_ACCOUNTS_MODULE = 'fnb.meal_accounts';

export type MealPayMode = 'wallet' | 'sponsor' | 'sponsor_subsidy';
export type MealAccountStatus = 'active' | 'locked';

export type MealWindow = { key: string; from: string; to: string; limit: number | null };

export type MealAccount = {
  id: string;
  employee_code: string;
  name: string;
  phone: string | null;
  customer_id: string | null;
  group_label: string | null;
  sponsor: { id: string; name: string } | null;
  pay_mode: MealPayMode;
  daily_meal_limit: number | null;
  meal_windows: MealWindow[];
  low_balance_threshold: string | null;
  balance: string;
  currency: string;
  status: MealAccountStatus;
  revision: number;
  updated_at: string;
};

// Who pays what on one order: the sponsor's part goes on its credit as the
// order completes, the eater pays the rest (wallet, cash or transfer).
export type MealPlan = {
  meal_account_id: string | null;
  pay_mode: MealPayMode | null;
  total: string;
  sponsor_id: string | null;
  sponsor_name: string | null;
  sponsor_amount: string;
  employee_amount: string;
  sponsor_unavailable: boolean;
};

export type MealStatus = MealAccount & {
  meals_today: number;
  meals_left: number | null;
  low_balance: boolean;
  wallet_covers: boolean;
  plan: MealPlan | null;
};

export type MealEntryKind = 'top_up' | 'spend' | 'refund' | 'adjust';

export type MealEntry = {
  id: string;
  kind: MealEntryKind;
  amount: string;
  funds_id: string | null;
  payout_id: string | null;
  workspace_id: string | null;
  order_number: string | null;
  actor: string | null;
  note: string | null;
  created_at: string;
};

const PAY_MODES: readonly MealPayMode[] = ['wallet', 'sponsor', 'sponsor_subsidy'];
const STATUSES: readonly MealAccountStatus[] = ['active', 'locked'];
const ENTRY_KINDS: readonly MealEntryKind[] = ['top_up', 'spend', 'refund', 'adjust'];

type Row = Record<string, unknown>;

function row(value: unknown): Row {
  return typeof value === 'object' && value !== null ? (value as Row) : {};
}

function text(value: unknown): string | null {
  return typeof value === 'string' && value ? value : null;
}

function int(value: unknown): number | null {
  return typeof value === 'number' && Number.isInteger(value) ? value : null;
}

// Decimal strings as the server sends them ("35000.0", "-10000.0").
function decimal(value: unknown): string | null {
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  return typeof value === 'string' && /^-?\d+(?:\.\d+)?$/.test(value) ? value : null;
}

function mealWindow(value: unknown): MealWindow[] {
  const slot = row(value);
  const key = text(slot.key);
  if (!key) return [];
  return [{ key, from: text(slot.from) ?? '', to: text(slot.to) ?? '', limit: int(slot.limit) }];
}

export function normalizeMealAccount(value: unknown): MealAccount | null {
  const data = row(value);
  const id = text(data.id);
  const code = text(data.employee_code);
  const status = data.status as MealAccountStatus;
  if (!id || !code || !STATUSES.includes(status)) return null;
  const sponsor = row(data.sponsor);
  const sponsorId = text(sponsor.id);
  const payMode = data.pay_mode as MealPayMode;
  return {
    id,
    employee_code: code,
    name: text(data.name) ?? code,
    phone: text(data.phone),
    customer_id: text(data.customer_id),
    group_label: text(data.group_label),
    sponsor: sponsorId ? { id: sponsorId, name: text(sponsor.name) ?? sponsorId } : null,
    pay_mode: PAY_MODES.includes(payMode) ? payMode : 'wallet',
    daily_meal_limit: int(data.daily_meal_limit),
    meal_windows: Array.isArray(data.meal_windows) ? data.meal_windows.flatMap(mealWindow) : [],
    low_balance_threshold: decimal(data.low_balance_threshold),
    balance: decimal(data.balance) ?? '0',
    currency: text(data.currency) ?? 'VND',
    status,
    revision: int(data.revision) ?? 0,
    updated_at: text(data.updated_at) ?? '',
  };
}

export function normalizeMealAccounts(rows: unknown): MealAccount[] {
  if (!Array.isArray(rows)) return [];
  return rows.flatMap((item) => {
    const account = normalizeMealAccount(item);
    return account ? [account] : [];
  });
}

export function normalizeMealPlan(value: unknown): MealPlan | null {
  if (typeof value !== 'object' || value === null) return null;
  const data = row(value);
  const payMode = data.pay_mode as MealPayMode;
  return {
    meal_account_id: text(data.meal_account_id),
    pay_mode: PAY_MODES.includes(payMode) ? payMode : null,
    total: decimal(data.total) ?? '0',
    sponsor_id: text(data.sponsor_id),
    sponsor_name: text(data.sponsor_name),
    sponsor_amount: decimal(data.sponsor_amount) ?? '0',
    employee_amount: decimal(data.employee_amount) ?? '0',
    sponsor_unavailable: data.sponsor_unavailable === true,
  };
}

export function normalizeMealStatus(value: unknown): MealStatus | null {
  const account = normalizeMealAccount(value);
  if (!account) return null;
  const data = row(value);
  return {
    ...account,
    meals_today: int(data.meals_today) ?? 0,
    meals_left: int(data.meals_left),
    low_balance: data.low_balance === true,
    wallet_covers: data.wallet_covers === true,
    plan: normalizeMealPlan(data.plan),
  };
}

export function normalizeMealEntries(rows: unknown): MealEntry[] {
  if (!Array.isArray(rows)) return [];
  return rows.flatMap((item) => {
    const data = row(item);
    const id = text(data.id);
    const kind = data.kind as MealEntryKind;
    const amount = decimal(data.amount);
    if (!id || !ENTRY_KINDS.includes(kind) || amount === null) return [];
    return [
      {
        id,
        kind,
        amount,
        funds_id: text(data.funds_id),
        payout_id: text(data.payout_id),
        workspace_id: text(data.workspace_id),
        order_number: text(data.order_number),
        actor: text(row(data.actor).name),
        note: text(data.note),
        created_at: text(data.created_at) ?? '',
      },
    ];
  });
}

// Whole VND of a server decimal; a fraction or garbage counts as nothing.
function vnd(value: string | null | undefined): bigint {
  const amount = parseVndAmount(value ?? '');
  return amount === null ? 0n : BigInt(amount);
}

// What is still to pay on a meal order: the sponsor's part (charged when the
// order completes) and the eater's unpaid part (`remaining` minus the
// sponsor's part, never below zero).
export function mealDue(
  remaining: string | null | undefined,
  plan: MealPlan | null | undefined,
): { sponsor: bigint; eater: bigint } {
  const sponsor = plan ? vnd(plan.sponsor_amount) : 0n;
  const left = vnd(remaining) - sponsor;
  return { sponsor, eater: left > 0n ? left : 0n };
}

// Readable refusal of a meal command; null when the reason has no own text.
const MEAL_REASONS = new Set([
  'meal_account_locked',
  'meal_account_unknown',
  'meal_duplicate_swipe',
  'meal_daily_limit',
  'meal_outside_window',
  'meal_account_missing',
  'meal_wallet_nothing_due',
  'meal_split_unpaid',
  'meal_amount_invalid',
  'meal_resolve_rate_limited',
  'stored_value_insufficient',
  'stored_value_adjust_invalid',
  'sponsor_limit',
  'sponsor_unavailable',
  'sponsor_nothing_due',
  'approval_required',
  'shift_required',
]);

export function mealReasonKey(reason: string | null | undefined): string | null {
  return reason && MEAL_REASONS.has(reason) ? `mealReason_${reason}` : null;
}

// A signed VND amount typed for a correction: "-10.000", "+5000", "20 000".
export function parseSignedVnd(
  input: string,
  parse: (value: string) => string | null,
): string | null {
  const value = input.trim();
  const negative = value.startsWith('-');
  const unsigned = parse(value.replace(/^[-+]/, ''));
  if (unsigned === null || unsigned === '0') return null;
  return negative ? `-${unsigned}` : unsigned;
}
