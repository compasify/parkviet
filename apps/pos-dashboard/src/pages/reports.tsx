import { contextFeature } from '@parkviet/pos-shared/pos-features'
import {
  businessDate,
  canExportReports,
  type ReportRow,
  todayIn,
} from '@parkviet/pos-shared/reports'
import { describeShiftFailure } from '@parkviet/pos-shared/shifts'
import {
  defineTable,
  PageHeader,
  type PageTab,
  PageTabs,
  ResourceTable,
  usePermissions,
} from '@spree/dashboard-core'
import { Button } from '@spree/dashboard-ui'
import { DownloadIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { ReportExports } from '../components/reports/report-exports'
import { type ReportFilterPatch, ReportFilters } from '../components/reports/report-filters'
import {
  ReportCell,
  ReportSummary,
  ShiftSummary,
  SourceSummary,
} from '../components/reports/report-summaries'
import { useMealSponsors } from '../hooks/use-meal-accounts'
import { usePosSession } from '../hooks/use-pos-session'
import { type ReportResult, reportQuery, useCreateExport, useReport } from '../hooks/use-reports'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { canManageMealAccounts } from '../lib/pos-access'
import { posKey } from '../lib/query-keys'
import {
  dashboardReportTypes,
  exportFilters,
  knownShifts,
  MONEY_COLUMNS,
  matchesTerm,
  type PosReportType,
  REPORT_LIMIT,
  reportColumns,
  reportPagination,
  reportRequest,
  SCREEN_ONLY_REPORTS,
  shiftLines,
  TIME_COLUMNS,
} from '../lib/report-table'
import { type ReportSearch, reportSearchSchema } from '../schemas/report-search'
import { hiddenTimestamps } from '../tables/columns'

type Row = ReportRow & { id: string }
const BUSINESS_DATED = new Set<PosReportType>([
  'sales',
  'ingredient_usage',
  'menu_margin',
  'platforms',
  'meals',
  'meal_statement',
  'vehicle_commissions',
  'attendants',
])
type Notice = { text: string; failed: boolean } | null

// "Báo cáo": sales, receipts, drawer cash, receivables and closures of the
// selected branch, its recipe usage and menu margin while it runs recipes,
// and its canteen meals and sponsor statements while it runs meal accounts,
// each computed by the server in the branch's timezone.
// Every tab is its own route; the day range, register, shift and "mine"
// filters travel with the tabs.
export function ReportsPage({ type }: { type: PosReportType }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const { permissionKeys } = usePermissions()
  const search = reportSearchSchema.parse(useSearch({ strict: false }))
  const branchId = context.data?.selection.branch_id ?? null
  const exporting = canExportReports(context.data?.capabilities)
  const base = `/${storeId}/reports`
  const carried = {
    from: search.from,
    to: search.to,
    registerId: search.registerId,
    shiftId: search.shiftId,
    mine: search.mine,
  }
  const readsSponsors = canManageMealAccounts({ permissionKeys, context: context.data })
  const tabs = dashboardReportTypes(context.data?.modules, readsSponsors).map((value) => ({
    key: value,
    label: t(`reportTab_${value}`),
    to: (value === 'sales' ? base : `${base}/${value}`) as PageTab['to'] & string,
    search: carried as PageTab['search'],
  }))
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('reportsTitle')}
        description={t('reportsHint')}
        actions={<BranchPicker />}
      />
      <PageTabs className="overflow-x-auto" tabs={tabs} />
      {branchId ? (
        <div key={branchId} className="space-y-6">
          <Report key={type} type={type} branchId={branchId} search={search} />
          {exporting && (
            <ReportExports branchId={branchId} timeZone={branchTimeZone(context.data)} />
          )}
        </div>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function Report({
  type,
  branchId,
  search,
}: {
  type: PosReportType
  branchId: string
  search: ReportSearch
}) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const client = useQueryClient()
  const navigate = useNavigate()
  const data = context.data
  const branch = data?.branches.find((row) => row.id === branchId)
  const branchZone = branchTimeZone(data)
  const cutoff = branch?.business_day_cutoff ?? '04:00'
  // Sales and recipe reports follow the business date. Other reports follow the calendar day.
  const today = BUSINESS_DATED.has(type) ? businessDate(branchZone, cutoff) : todayIn(branchZone)
  const { dated, from, to, rangeValid, needsSponsor, filters } = reportRequest(
    type,
    search,
    today,
    data?.staff.id,
  )
  const ready = rangeValid && !needsSponsor
  const page = Math.max(1, search.page ?? 1)
  const limit = search.limit ?? REPORT_LIMIT
  const report = useReport(type, branchId, filters, page, limit, ready)
  const sponsors = useMealSponsors(branchId, type === 'meal_statement')
  const meta = report.data?.meta
  const timeZone = meta?.timezone ?? branchZone
  const currency = data?.store.currency ?? 'VND'
  const exporting = canExportReports(data?.capabilities) && !SCREEN_ONLY_REPORTS.has(type)
  // Off stops new exports only; files already made stay downloadable until they expire.
  const exportsOn = contextFeature(data, 'exports')
  const createExport = useCreateExport()
  const [notice, setNotice] = useState<Notice>(null)

  // Shifts named on any cashbook page read for this branch offer themselves
  // as a filter on every report.
  const seen = knownShifts(
    client
      .getQueriesData<ReportResult>({ queryKey: posKey(storeId, 'reports', 'cashbook', branchId) })
      .map(([, result]) => result?.meta.summary),
  )
  const shifts = [
    ...(data?.shift && !seen.some((row) => row.shift_id === data.shift?.id)
      ? [{ id: data.shift.id, label: t('reportCurrentShift') }]
      : []),
    ...seen.map((row) => ({
      id: row.shift_id,
      label: `${row.cashier} · ${row.register ?? t('shiftNoRegister')} · ${formatInstant(row.opened_at, i18n.language, timeZone)}`,
    })),
  ]
  const registers = (data?.registers ?? []).filter((row) => row.branch_id === branchId)

  function update(patch: ReportFilterPatch & { shiftPage?: number }) {
    void navigate({
      to: '.',
      search: (previous: Record<string, unknown>) => ({ ...previous, ...patch, page: undefined }),
    })
  }

  function requestExport() {
    setNotice(null)
    createExport.mutate(
      { branchId, type, filters: exportFilters(filters) },
      {
        onSuccess: () => setNotice({ text: t('reportExportQueued'), failed: false }),
        onError: (failure) => setNotice({ text: describeShiftFailure(failure, t), failed: true }),
      },
    )
  }

  const columns = reportColumns(type, search.section)
  const tableKey = `pos-report-${type}${type === 'sales' && search.section ? `-${search.section}` : ''}`
  defineTable<Row>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('reportSearch'),
    emptyMessage: t('reportEmpty'),
    columns: [
      ...columns.map((column) => ({
        key: column,
        label: t(`reportCol_${column}`),
        default: true,
        sortable: false,
        className: MONEY_COLUMNS.has(column)
          ? 'text-right tabular-nums'
          : TIME_COLUMNS.has(column)
            ? 'whitespace-nowrap'
            : undefined,
        render: (row: Row) => (
          <ReportCell column={column} row={row} timeZone={timeZone} currency={currency} />
        ),
      })),
      ...hiddenTimestamps<Row>(),
    ],
  })

  const summary = meta?.summary
  const lines = shiftLines(summary)

  return (
    <div className="space-y-4">
      <div className="space-y-1 text-sm text-muted-foreground">
        <p>{t(`reportTabHint_${type}`)}</p>
        {BUSINESS_DATED.has(type) && (
          <p>{t('businessDay.reportHint', { cutoff: cutoff.slice(0, 5) })}</p>
        )}
      </div>
      <ReportFilters
        type={type}
        search={search}
        today={today}
        from={from}
        to={to}
        dated={dated}
        registers={registers}
        shifts={shifts}
        sponsors={sponsors.data?.data ?? []}
        onChange={update}
      >
        {exporting && (
          <Button
            type="button"
            variant="outline"
            disabled={!ready || createExport.isPending || !exportsOn}
            aria-describedby={exportsOn ? undefined : 'exports-off'}
            onClick={requestExport}
          >
            <DownloadIcon className="size-4" />
            {t('reportExport')}
          </Button>
        )}
      </ReportFilters>
      {exporting && !exportsOn && (
        <p id="exports-off" role="note" className="text-sm text-muted-foreground">
          {t('featureOff_exports')}
        </p>
      )}
      {!rangeValid && (
        <p role="alert" className="text-sm text-destructive">
          {t('reportRangeInvalid')}
        </p>
      )}
      {needsSponsor && (
        <p role="status" className="text-sm text-muted-foreground">
          {t('reportSponsorRequired')}
        </p>
      )}
      {sponsors.isError && (
        <p role="alert" className="text-sm text-destructive">
          {describeShiftFailure(sponsors.error, t)}
        </p>
      )}
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-sm text-destructive' : 'text-sm text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      {report.isError && (
        <p role="alert" className="text-sm text-destructive">
          {describeShiftFailure(report.error, t)}
        </p>
      )}
      {meta && (
        <p role="status" className="text-sm text-muted-foreground">
          {t(meta.scope === 'own' ? 'reportScopeOwn' : 'reportScopeBranch')} ·{' '}
          {t('reportTimezone', { zone: meta.timezone })}
        </p>
      )}
      {summary && <ReportSummary type={type} summary={summary} currency={currency} />}
      {type === 'sales' && search.section !== 'returns' && summary && (
        <SourceSummary value={summary.by_source} currency={currency} />
      )}
      {type === 'cashbook' && summary && (
        <ShiftSummary
          lines={lines}
          page={Number(summary.shift_page ?? 1)}
          pages={Number(summary.shift_pages ?? 1)}
          count={Number(summary.shift_count ?? lines.length)}
          currency={currency}
          timeZone={timeZone}
          onPage={(shiftPage) => update({ shiftPage })}
        />
      )}
      {ready && (
        <ResourceTable<Row>
          key={tableKey}
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'reports', type, branchId, filters, 'table']}
          queryFn={async (params: Record<string, unknown>) => {
            const at = Math.max(1, Number(params.page) || 1)
            const size = Number(params.limit) || REPORT_LIMIT
            // Shares the page's query, so the summary and the rows are one response.
            const result = await client.fetchQuery({
              ...reportQuery(storeId, type, branchId, filters, at, size),
              staleTime: 5_000,
            })
            const term = String(params.search ?? '')
            // The reports have no text search: the box narrows the loaded page.
            const rows = result.data
              .filter((row) => matchesTerm(row, term))
              .map((row, index) => ({ ...row, id: `${at}-${index}` }))
            return { data: rows, meta: reportPagination(result.meta, result.data.length) }
          }}
          searchParams={search}
        />
      )}
    </div>
  )
}
