// Opening another store (POST /stores): its form values, the request body,
// and how the new store joins the signed-in user's store list.

export interface StoreSummary {
  id: string
  name: string
  code: string
}

/** A row of the stores table. `current` is the store this tab is managing. */
export interface StoreRow extends StoreSummary {
  current: boolean
}

export interface NewStoreFormValues {
  name: string
  country_code: string
  mail_from_address: string
  customer_support_email: string
}

export const EMPTY_NEW_STORE: NewStoreFormValues = {
  name: '',
  country_code: 'VN',
  mail_from_address: '',
  customer_support_email: '',
}

/** Blank emails are left out so the API copies the current store's. */
export function newStorePayload(values: NewStoreFormValues): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    name: values.name.trim(),
    country_code: values.country_code,
  }
  for (const field of ['mail_from_address', 'customer_support_email'] as const) {
    const value = values[field].trim()
    if (value !== '') payload[field] = value
  }
  return payload
}

const TEXT_FILTER = /^(name|code)_(cont|not_cont|eq|not_eq|start|end)$/

/**
 * Search, filter, sort and page the signed-in user's stores. The list is
 * already in memory (it comes from `/me`), and the table still speaks the
 * same params as every other settings table.
 */
export function pageStores(rows: readonly StoreRow[], params: Record<string, unknown>) {
  const query = text(params.q).toLocaleLowerCase()
  const matched = rows.filter((row) => {
    if (query && !`${row.name} ${row.code}`.toLocaleLowerCase().includes(query)) return false
    return matchesTextFilters(row, params)
  })
  const sorted = sortRows(matched, text(params.sort) || 'name')
  const page = positive(params.page, 1)
  const limit = positive(params.limit, 25)
  const start = (page - 1) * limit
  const data = sorted.slice(start, start + limit)
  const pages = Math.max(1, Math.ceil(sorted.length / limit) || 1)
  return {
    data,
    meta: {
      page,
      limit,
      count: sorted.length,
      pages,
      from: sorted.length === 0 ? 0 : start + 1,
      to: start + data.length,
      previous: page > 1 ? page - 1 : null,
      next: page < pages ? page + 1 : null,
    },
  }
}

function matchesTextFilters(row: StoreRow, params: Record<string, unknown>) {
  return Object.entries(params).every(([key, raw]) => {
    const match = TEXT_FILTER.exec(key)
    if (!match || raw == null || raw === '') return true
    return compareText(row[match[1] as 'name' | 'code'], match[2], String(raw))
  })
}

function compareText(value: string, operator: string, expected: string) {
  const left = value.toLocaleLowerCase()
  const right = expected.toLocaleLowerCase()
  switch (operator) {
    case 'cont':
      return left.includes(right)
    case 'not_cont':
      return !left.includes(right)
    case 'eq':
      return left === right
    case 'not_eq':
      return left !== right
    case 'start':
      return left.startsWith(right)
    case 'end':
      return left.endsWith(right)
    default:
      return true
  }
}

function sortRows(rows: readonly StoreRow[], sort: string) {
  const descending = sort.startsWith('-')
  const field = descending ? sort.slice(1) : sort
  if (field !== 'name' && field !== 'code') return [...rows]
  return [...rows].sort((a, b) => a[field].localeCompare(b[field]) * (descending ? -1 : 1))
}

function text(value: unknown) {
  return typeof value === 'string' ? value : ''
}

function positive(value: unknown, fallback: number) {
  const number = Number(value)
  return Number.isInteger(number) && number > 0 ? number : fallback
}

/**
 * The user's stores with `created` added, in the order the API lists them
 * (by name), so the store switcher shows it without signing in again.
 */
export function withStore(stores: StoreSummary[], created: StoreSummary): StoreSummary[] {
  const summary = { id: created.id, name: created.name, code: created.code }
  return [...stores.filter((store) => store.id !== created.id), summary].sort((a, b) =>
    a.name.localeCompare(b.name),
  )
}
