import type { PaginationMeta } from '@spree/dashboard-ui'

// Operational POS lists take a calendar-day range (`from`/`to`, branch days)
// instead of Ransack. The date filter of the shared ResourceTable emits
// `<field>_gteq`/`_lteq` (the upper bound carries the day's last instant) and
// the filter panel may add `_gt`, `_lt` or `_eq`; all reduce to whole days.
const DAY = /^(\d{4}-\d{2}-\d{2})/

function previousDay(day: string) {
  const date = new Date(`${day}T00:00:00Z`)
  date.setUTCDate(date.getUTCDate() - 1)
  return date.toISOString().slice(0, 10)
}

export function dayRange(
  params: Record<string, unknown>,
  field: string,
): { from?: string; to?: string } {
  let from: string | undefined
  let to: string | undefined
  const later = (a: string | undefined, b: string) => (a && a > b ? a : b)
  const earlier = (a: string | undefined, b: string) => (a && a < b ? a : b)
  for (const operator of ['gteq', 'gt', 'eq', 'lteq', 'lt']) {
    const raw = params[`${field}_${operator}`]
    const day = typeof raw === 'string' ? DAY.exec(raw.trim())?.[1] : undefined
    if (!day || Number.isNaN(Date.parse(`${day}T00:00:00Z`))) continue
    if (operator !== 'lteq' && operator !== 'lt') from = later(from, day)
    if (operator === 'eq' || operator === 'lteq') to = earlier(to, day)
    if (operator === 'lt') to = earlier(to, previousDay(day))
  }
  return { from, to }
}

export const pageParams = (params: Record<string, unknown>) => ({
  page: String(Math.max(1, Number(params.page) || 1)),
  limit: String(Math.min(100, Math.max(1, Number(params.limit) || 25))),
})

export type Page<T> = { data: T[]; meta: PaginationMeta }
