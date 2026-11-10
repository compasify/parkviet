import type { PosContext } from '@parkviet/pos-shared/types/pos-context'

const FALLBACK_ZONE = 'Asia/Ho_Chi_Minh'

// The selected branch's timezone: the server keeps branch days in it.
export function branchTimeZone(context: PosContext | undefined): string {
  const branch = context?.branches.find((row) => row.id === context.selection.branch_id)
  return branch?.timezone || context?.store.timezone || FALLBACK_ZONE
}

// A server timestamp as wall-clock time where the branch trades.
export function formatInstant(
  value: string | null | undefined,
  locale: string,
  timeZone: string,
): string {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  try {
    return date.toLocaleString(locale, { timeZone, dateStyle: 'short', timeStyle: 'short' })
  } catch {
    return date.toLocaleString(locale, { timeZone: FALLBACK_ZONE })
  }
}
