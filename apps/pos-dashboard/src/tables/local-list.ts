import type { PaginationMeta } from '@spree/dashboard-ui'

// The POS topology endpoints return whole, small lists without Ransack, so the
// shared ResourceTable's search, filter, sort and page parameters are applied
// here instead of on the server.
const PREDICATE = /^(.+?)_(not_in|in|not_eq|eq)$/
const collator = new Intl.Collator('vi', { sensitivity: 'base', numeric: true })

export function localList<T>(
  rows: T[],
  params: Record<string, unknown>,
  options: {
    searchParam: string
    text: (row: T) => string
    // What a column sorts by when that is not its raw value (a name for an id).
    sortValue?: (row: T, field: string) => string | undefined
  },
): { data: T[]; meta: PaginationMeta } {
  const read = (row: T, field: string) => String((row as Record<string, unknown>)[field] ?? '')
  const sortBy = (row: T, field: string) => options.sortValue?.(row, field) ?? read(row, field)
  const term = String(params[options.searchParam] ?? '')
    .trim()
    .toLocaleLowerCase()
  const predicates = Object.entries(params).flatMap(([key, raw]) => {
    const match = PREDICATE.exec(key)
    if (!match) return []
    const values = (Array.isArray(raw) ? raw : [raw]).map(String)
    return [{ field: match[1], negate: match[2].startsWith('not_'), values }]
  })
  const filtered = rows.filter(
    (row) =>
      (!term || options.text(row).toLocaleLowerCase().includes(term)) &&
      predicates.every(({ field, negate, values }) => values.includes(read(row, field)) !== negate),
  )
  const sort = typeof params.sort === 'string' ? params.sort : ''
  const field = sort.replace(/^-/, '')
  const sorted = field
    ? [...filtered].sort(
        (a, b) =>
          collator.compare(sortBy(a, field), sortBy(b, field)) * (sort.startsWith('-') ? -1 : 1),
      )
    : filtered
  const limit = Math.max(1, Number(params.limit) || 25)
  const count = sorted.length
  const pages = Math.max(1, Math.ceil(count / limit))
  const page = Math.min(Math.max(1, Number(params.page) || 1), pages)
  const start = (page - 1) * limit
  const data = sorted.slice(start, start + limit)
  return {
    data,
    meta: {
      page,
      limit,
      count,
      pages,
      from: count ? start + 1 : 0,
      to: start + data.length,
      previous: page > 1 ? page - 1 : null,
      next: page < pages ? page + 1 : null,
    },
  }
}
