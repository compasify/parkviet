import {
  type ReportPage,
  type ReportType,
  reportTypesFor,
  validReportRange,
} from '@parkviet/pos-shared/reports'
import type { PaginationMeta } from '@spree/dashboard-ui'

// Columns, filters and paging of the server reports. The server allowlists and
// scopes every filter; this module only decides what the screen sends and shows.

export type ReportFilters = Record<string, string>

export const REPORT_LIMIT = 50

// Canteen reports, offered while the branch runs meal accounts: meals by
// meal time, counter and sponsor with the refused attempts, and a sponsor's
// statement for a period (which needs a sponsor).
export const MEAL_REPORT_TYPES = ['meals', 'meal_statement'] as const
// A rest stop's coach commission by day, bus operator and plate, offered while
// the branch runs coach visits.
export const VEHICLE_REPORT_TYPES = ['vehicle_commissions'] as const
export type PosReportType =
  | ReportType
  | (typeof MEAL_REPORT_TYPES)[number]
  | (typeof VEHICLE_REPORT_TYPES)[number]
export const MEAL_RESULTS = ['ok', 'duplicate', 'limit', 'window', 'revoked', 'unknown'] as const

// The report tabs of the selected branch. The statement picks a sponsor, so
// it is listed only to readers who may see the sponsors.
export function dashboardReportTypes(
  modules: Record<string, boolean> | null | undefined,
  readsSponsors: boolean,
): PosReportType[] {
  const meals = modules?.['fnb.meal_accounts'] === true
  return [
    ...reportTypesFor(modules),
    ...(meals ? (['meals'] as const) : []),
    ...(meals && readsSponsors ? (['meal_statement'] as const) : []),
    ...(modules?.['fnb.vehicle_commission'] === true ? VEHICLE_REPORT_TYPES : []),
  ]
}

export const REPORT_COLUMNS: Record<PosReportType, string[]> = {
  sales: [
    'order_number',
    'sold_at',
    'business_date',
    'order_source',
    'register',
    'cashier',
    'item_total',
    'adjustment_total',
    'total',
  ],
  receipts: [
    'received_at',
    'booked_at',
    'kind',
    'source',
    'custody',
    'received_net',
    'order_number',
    'cashier',
  ],
  cashbook: ['at', 'register', 'cashier', 'category', 'amount', 'running_expected', 'reason'],
  receivables: [
    'order_number',
    'placed_at',
    'customer',
    'debt',
    'credit_notes',
    'collected',
    'balance',
    'due_on',
    'aging',
  ],
  closures: [
    'closed_at',
    'register',
    'cashier',
    'expected',
    'counted',
    'variance',
    'reason',
    'approver',
    'reconciled',
  ],
  ingredient_usage: [
    'business_date',
    'ingredient',
    'menu_item',
    'quantity',
    'unit',
    'cost',
    'cost_missing',
  ],
  menu_margin: ['menu_item', 'quantity', 'revenue', 'cost', 'margin', 'margin_rate', 'costed'],
  platforms: [
    'business_date',
    'platform',
    'orders',
    'gross',
    'commission',
    'net',
    'unsettled',
    'commission_estimated',
    'commission_actual',
  ],
  meals: ['business_date', 'meal_window', 'register', 'sponsor', 'result', 'meals'],
  meal_statement: [
    'business_date',
    'employee_code',
    'name',
    'group_label',
    'order_number',
    'total',
    'sponsor_amount',
    'employee_amount',
  ],
  vehicle_commissions: [
    'business_date',
    'bus_operator',
    'plate',
    'visits',
    'guests',
    'revenue',
    'commission_amount',
    'paid',
    'unpaid',
    'commission_rate',
  ],
}

export const RETURN_COLUMNS = [
  'return_id',
  'order_number',
  'returned_at',
  'receiver',
  'entitlement_total',
  'credit_note_amount',
  'refund_entitlement',
]

export const MONEY_COLUMNS = new Set([
  'item_total',
  'adjustment_total',
  'total',
  'received_net',
  'amount',
  'running_expected',
  'debt',
  'credit_notes',
  'collected',
  'balance',
  'expected',
  'counted',
  'reconciled',
  'entitlement_total',
  'credit_note_amount',
  'refund_entitlement',
  'cost',
  'revenue',
  'margin',
  'gross',
  'commission',
  'net',
  'unsettled',
  'commission_estimated',
  'commission_actual',
  'sponsor_amount',
  'employee_amount',
  'commission_amount',
  'paid',
  'unpaid',
])

// Percent figures (one decimal) of rows and summaries.
export const PERCENT_COLUMNS = new Set(['margin_rate', 'commission_rate'])

export const TIME_COLUMNS = new Set([
  'sold_at',
  'received_at',
  'booked_at',
  'at',
  'placed_at',
  'closed_at',
  'returned_at',
])

// Code columns translated through a key prefix; unknown codes show as sent.
export const CODE_COLUMNS: Record<string, string> = {
  kind: 'reportKind_',
  source: 'reportSource_',
  custody: 'reportCustody_',
  category: 'reportCategory_',
  aging: 'reportAging_',
  order_source: 'orderSource_',
  cost_missing: 'reportYesNo_',
  costed: 'reportYesNo_',
  platform: 'platform_',
  result: 'reportMealResult_',
}

export function reportColumns(type: PosReportType, section?: string): string[] {
  return type === 'sales' && section === 'returns' ? RETURN_COLUMNS : REPORT_COLUMNS[type]
}

// Rows kept from a previous query are shown only for the same report view
// (one sponsor's statement is never shown under another's).
export const reportView = (type: PosReportType, filters: ReportFilters) =>
  `${type}:${filters.section ?? ''}:${filters.meal_sponsor_id ?? ''}`

export type ReportSearchFilters = {
  from?: string
  to?: string
  registerId?: string
  shiftId?: string
  mine?: boolean
  section?: string
  orderSource?: string
  kind?: string
  source?: string
  status?: string
  shiftPage?: number
  result?: string
  sponsorId?: string
}

// Receivables are a balance as of now; every other report covers a day range,
// today (in the branch's days) unless another range is chosen. A sponsor's
// statement waits until a sponsor is chosen (`needsSponsor`).
export function reportRequest(
  type: PosReportType,
  search: ReportSearchFilters,
  today: string,
  staffId: string | undefined,
) {
  const dated = type !== 'receivables'
  const from = search.from ?? today
  const to = search.to ?? today
  const extra: ReportFilters = {
    ...(type === 'sales' && search.section ? { section: search.section } : {}),
    ...(type === 'sales' && search.orderSource ? { order_source: search.orderSource } : {}),
    ...(type === 'receipts' && search.kind ? { kind: search.kind } : {}),
    ...(type === 'receipts' && search.source ? { source: search.source } : {}),
    ...(type === 'receivables' && search.status ? { status: search.status } : {}),
    ...(type === 'meals' && search.result ? { result: search.result } : {}),
    ...(type === 'meal_statement' && search.sponsorId ? { meal_sponsor_id: search.sponsorId } : {}),
  }
  const filters: ReportFilters = {
    ...(dated ? { from, to } : {}),
    ...(search.registerId ? { register_id: search.registerId } : {}),
    ...(search.shiftId ? { shift_id: search.shiftId } : {}),
    ...(search.mine && staffId ? { cashier_id: staffId } : {}),
    ...(type === 'cashbook' && search.shiftPage && search.shiftPage > 1
      ? { shift_page: String(search.shiftPage) }
      : {}),
    ...extra,
  }
  return {
    dated,
    from,
    to,
    rangeValid: !dated || validReportRange(from, to),
    needsSponsor: type === 'meal_statement' && !search.sponsorId,
    filters,
  }
}

// An export covers the whole filtered report, not the shift summary page on screen.
export function exportFilters(filters: ReportFilters): ReportFilters {
  const { shift_page: _page, ...rest } = filters
  return rest
}

// The report meta carries page, pages, count and limit; the shared pagination
// also wants the visible range and the neighbouring pages.
export function reportPagination(
  meta: Pick<ReportPage['meta'], 'page' | 'pages' | 'count' | 'limit'>,
  rows: number,
): PaginationMeta {
  const page = Math.max(1, meta.page)
  const pages = Math.max(0, meta.pages)
  const start = (page - 1) * meta.limit
  return {
    page,
    limit: meta.limit,
    count: meta.count,
    pages,
    from: rows ? start + 1 : 0,
    to: start + rows,
    previous: page > 1 ? page - 1 : null,
    next: page < pages ? page + 1 : null,
  }
}

// Plain figures of the summary; nested lists (shifts, by source) and the shift
// paging have their own tables.
export function summaryEntries(summary: Record<string, unknown>): [string, string | number][] {
  return Object.entries(summary).filter(
    (entry): entry is [string, string | number] =>
      (typeof entry[1] === 'string' || typeof entry[1] === 'number') &&
      !entry[0].startsWith('shift_page'),
  )
}

// The meals summary nests the refused attempts by reason; each reason is
// shown as its own figure beside the meals.
export function reportFigures(
  type: PosReportType,
  summary: Record<string, unknown>,
): Record<string, unknown> {
  if (type !== 'meals') return summary
  const { refused, ...rest } = summary
  const reasons =
    typeof refused === 'object' && refused !== null && !Array.isArray(refused)
      ? Object.entries(refused).map(([reason, count]) => [`refused_${reason}`, count] as const)
      : []
  return { ...rest, ...Object.fromEntries(reasons) }
}

export const isDecimalText = (value: unknown): value is string =>
  typeof value === 'string' && /^-?\d+\.\d+$/.test(value)

// YYYY-MM-DD as DD/MM/YYYY, as the counter shows business dates.
export function dayText(value: string): string {
  const match = value.match(/^(\d{4})-(\d{2})-(\d{2})/)
  return match ? `${match[3]}/${match[2]}/${match[1]}` : value
}

export type ShiftLine = {
  shift_id: string
  register: string | null
  cashier: string
  status: string
  opened_at: string | null
  opening_float: string
  expected: string
  counted: string | null
  variance: string | null
}

export function shiftLines(summary: Record<string, unknown> | undefined): ShiftLine[] {
  const value = summary?.shifts
  return Array.isArray(value) ? (value as ShiftLine[]) : []
}

// Shifts seen on any cashbook page of the branch, once each, in the order seen.
export function knownShifts(pages: (Record<string, unknown> | undefined)[]): ShiftLine[] {
  const seen = new Map<string, ShiftLine>()
  for (const summary of pages)
    for (const line of shiftLines(summary))
      if (!seen.has(line.shift_id)) seen.set(line.shift_id, line)
  return [...seen.values()]
}

// Narrows a loaded page by any text cell; the reports have no server search.
export function matchesTerm(row: Record<string, unknown>, term: string): boolean {
  const needle = term.trim().toLocaleLowerCase()
  if (!needle) return true
  return Object.values(row).some(
    (value) =>
      (typeof value === 'string' || typeof value === 'number') &&
      String(value).toLocaleLowerCase().includes(needle),
  )
}
