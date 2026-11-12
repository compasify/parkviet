import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'

// Canteen meal accounts and their sponsors as the Admin API returns them, and
// the checks the back-office forms run before sending. The server decides;
// these checks only keep obviously wrong values from leaving the form.

export const MEAL_PAY_MODES = ['wallet', 'sponsor', 'sponsor_subsidy'] as const
export type MealPayMode = (typeof MEAL_PAY_MODES)[number]
export const MEAL_ACCOUNT_STATUSES = ['active', 'locked'] as const
export type MealAccountStatus = (typeof MEAL_ACCOUNT_STATUSES)[number]
export const SUBSIDY_MODES = ['none', 'fixed', 'percent'] as const
export type SubsidyMode = (typeof SUBSIDY_MODES)[number]
export const MEAL_ENTRY_KINDS = ['top_up', 'spend', 'refund', 'adjust'] as const

export type MealWindow = { key: string; from: string; to: string; limit?: number }

export type MealAccount = {
  id: string
  employee_code: string
  name: string | null
  phone: string | null
  customer_id: string
  group_label: string | null
  sponsor: { id: string; name: string } | null
  pay_mode: MealPayMode
  daily_meal_limit: number | null
  meal_windows: MealWindow[]
  low_balance_threshold: string | null
  balance: string
  currency: string
  status: MealAccountStatus
  revision: number
  updated_at: string | null
}

export type MealEntry = {
  id: string
  kind: (typeof MEAL_ENTRY_KINDS)[number]
  amount: string
  funds_id: string | null
  payout_id: string | null
  workspace_id: string | null
  order_number: string | null
  actor: { id: string; name: string }
  note: string | null
  created_at: string
}

export type MealSponsor = {
  id: string
  name: string
  customer_id: string
  customer_name: string | null
  customer_phone: string | null
  credit_account_id: string | null
  credit_limit: string | null
  due_days: number | null
  open_debt: string | null
  credit_available: string | null
  statement_day: number
  subsidy_mode: SubsidyMode
  subsidy_value: string
  subsidy_daily_cap: string | null
  status: 'active' | 'suspended'
  accounts_count: number
  updated_at: string | null
}

export const MAX_MEAL_WINDOWS = 6
export const MAX_DAILY_MEALS = 20
export const MAX_IMPORT_BYTES = 2 * 1024 * 1024
export const MEAL_IMPORT_HEADER =
  'employee_code,name,phone,email,group_label,sponsor,daily_meal_limit,pay_mode'

const WINDOW_KEY = /^[a-z0-9_]{1,32}$/
const CLOCK = /^([01]\d|2[0-3]):[0-5]\d$/
const CODE = /^[A-Za-z0-9][A-Za-z0-9._-]{0,31}$/

// A whole number typed in a form: null when left blank, undefined when it is
// not a whole number between min and max.
export function wholeNumber(text: string, min: number, max: number): number | null | undefined {
  const value = text.trim()
  if (value === '') return null
  if (!/^\d+$/.test(value)) return undefined
  const number = Number(value)
  return number >= min && number <= max ? number : undefined
}

// The server upper-cases codes; letters, digits, dot, dash and underscore.
export const validEmployeeCode = (text: string) => CODE.test(text.trim())

export type MealWindowDraft = { key: string; from: string; to: string; limit: string }

export const windowDraft = (window?: MealWindow): MealWindowDraft => ({
  key: window?.key ?? '',
  from: window?.from ?? '',
  to: window?.to ?? '',
  limit: window?.limit == null ? '' : String(window.limit),
})

export function windowDraftValid(draft: MealWindowDraft): boolean {
  return (
    WINDOW_KEY.test(draft.key.trim()) &&
    CLOCK.test(draft.from) &&
    CLOCK.test(draft.to) &&
    draft.from !== draft.to &&
    wholeNumber(draft.limit, 0, MAX_DAILY_MEALS) !== undefined
  )
}

// The meal times as the server takes them, or null when any is invalid or
// two share a key. A window may run past midnight (from 22:00 to 02:00).
export function parseMealWindows(drafts: MealWindowDraft[]): MealWindow[] | null {
  if (drafts.length > MAX_MEAL_WINDOWS || !drafts.every(windowDraftValid)) return null
  const keys = drafts.map((draft) => draft.key.trim())
  if (new Set(keys).size !== keys.length) return null
  return drafts.map((draft) => {
    const limit = wholeNumber(draft.limit, 0, MAX_DAILY_MEALS)
    const window: MealWindow = { key: draft.key.trim(), from: draft.from, to: draft.to }
    return limit == null ? window : { ...window, limit }
  })
}

const iso = (date: Date) => date.toISOString().slice(0, 10)

// The sponsor's last closed statement cycle before `today` (YYYY-MM-DD): a
// cycle closes at the end of its statement day and the next one starts the
// day after, so on the statement day itself the cycle is still open.
export function statementPeriod(statementDay: number, today: string) {
  const [year, month, day] = today.split('-').map(Number)
  const closing = Math.min(28, Math.max(1, Math.trunc(statementDay) || 1))
  // The closing month, counted from 0 as Date.UTC does; below 0 it rolls
  // into the previous year.
  const endMonth = day > closing ? month - 1 : month - 2
  return {
    from: iso(new Date(Date.UTC(year, endMonth - 1, closing + 1))),
    to: iso(new Date(Date.UTC(year, endMonth, closing))),
  }
}

const INVALID_REASONS = ['meal_account_invalid', 'meal_sponsor_invalid']

function details(error: unknown): Record<string, unknown> | null {
  if (typeof error !== 'object' || error === null || !('details' in error)) return null
  const value = error.details
  return typeof value === 'object' && value !== null ? (value as Record<string, unknown>) : null
}

// The form field the server refused (409 `meal_account_invalid` or
// `meal_sponsor_invalid` with `details.field`), or null.
export function refusedField(error: unknown): string | null {
  const reason = conflictReason(error)
  if (!reason || !INVALID_REASONS.includes(reason)) return null
  const field = details(error)?.field
  return typeof field === 'string' && field ? field : null
}

export type ImportProblem = { line: number | null; field: string | null; message: string }

// The rows a CSV import refused (409 `meal_import_invalid`, `details.errors`).
export function importProblems(error: unknown): ImportProblem[] {
  if (conflictReason(error) !== 'meal_import_invalid') return []
  const errors = details(error)?.errors
  if (!Array.isArray(errors)) return []
  return errors.flatMap((entry: unknown) => {
    if (typeof entry !== 'object' || entry === null) return []
    const row = entry as Record<string, unknown>
    const message = typeof row.message === 'string' ? row.message : ''
    if (!message) return []
    return [
      {
        line: typeof row.line === 'number' ? row.line : null,
        field: typeof row.field === 'string' && row.field ? row.field : null,
        message,
      },
    ]
  })
}

type Translate = (key: string, options?: Record<string, unknown>) => string

// One wording for canteen commands: a refused field is named first, then the
// server's explanation (or the shared failure text).
export function describeMealFailure(error: unknown, t: Translate): string {
  const text = describeFailure(error, t)
  const field = refusedField(error)
  return field
    ? t('mealAccounts.fieldProblem', {
        field: t(`mealAccounts.field_${field}`, { defaultValue: field }),
        detail: text,
      })
    : text
}
