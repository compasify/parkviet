import { formatMoney } from '@parkviet/pos-shared/money'
import { orderSourceKey, orderSourceRows } from '@parkviet/pos-shared/order-source'
import type { ReportRow } from '@parkviet/pos-shared/reports'
import { Button } from '@spree/dashboard-ui'
import { ChartColumnIcon } from '@spree/dashboard-ui/icons'
import { type ReactNode, useId } from 'react'
import { useTranslation } from 'react-i18next'
import { formatInstant } from '../../lib/format-time'
import {
  CODE_COLUMNS,
  dayText,
  isDecimalText,
  MONEY_COLUMNS,
  PERCENT_COLUMNS,
  type PosReportType,
  reportFigures,
  type ShiftLine,
  summaryEntries,
  TIME_COLUMNS,
} from '../../lib/report-table'
import { ModelCard } from '../setup/model-ui'
import { VarianceText } from '../shift-close-dialog'

const TH = 'px-3 py-2 text-left font-medium text-muted-foreground'
const TD = 'px-3 py-2'
const NUM = 'px-3 py-2 text-right tabular-nums'

// One cell of a report row: money in the row's currency, instants in the
// report's timezone, business dates as days, codes translated.
export function ReportCell({
  column,
  row,
  timeZone,
  currency,
}: {
  column: string
  row: ReportRow
  timeZone: string
  currency: string
}) {
  const { t, i18n } = useTranslation()
  const value = row[column]
  const money = String(row.currency ?? currency)
  if (value == null || value === '') return <>—</>
  if (column === 'variance') return <VarianceText variance={String(value)} currency={money} />
  if (MONEY_COLUMNS.has(column)) return <>{formatMoney(String(value), money)}</>
  if (PERCENT_COLUMNS.has(column)) return <>{value}%</>
  if (TIME_COLUMNS.has(column)) return <>{formatInstant(String(value), i18n.language, timeZone)}</>
  if (column === 'business_date') return <>{dayText(String(value))}</>
  const prefix = CODE_COLUMNS[column]
  if (prefix) return <>{t(`${prefix}${value}`, { defaultValue: String(value) })}</>
  return <>{String(value)}</>
}

function SummaryCard({ title, children }: { title: string; children: ReactNode }) {
  const id = useId()
  return (
    <ModelCard title={title} id={id} icon={<ChartColumnIcon />}>
      {children}
    </ModelCard>
  )
}

// The figures the server totalled for the whole filtered report.
export function ReportSummary({
  type,
  summary,
  currency,
}: {
  type: PosReportType
  summary: Record<string, unknown>
  currency: string
}) {
  const { t } = useTranslation()
  const entries = summaryEntries(reportFigures(type, summary))
  if (entries.length === 0) return null
  return (
    <SummaryCard title={t('reportSummary')}>
      <dl
        aria-label={t('reportSummary')}
        className="grid grid-cols-2 gap-x-6 gap-y-3 text-sm sm:grid-cols-3 lg:grid-cols-4"
      >
        {entries.map(([key, value]) => (
          <div key={key}>
            <dt className="text-muted-foreground">
              {t(`reportSum_${type}_${key}`, {
                defaultValue: t(`reportSum_${key}`, { defaultValue: key }),
              })}
            </dt>
            <dd className="font-medium tabular-nums">
              {PERCENT_COLUMNS.has(key)
                ? `${value}%`
                : isDecimalText(value)
                  ? formatMoney(value, currency)
                  : String(value)}
            </dd>
          </div>
        ))}
      </dl>
    </SummaryCard>
  )
}

// Sales grouped by where the order came from ("Theo nguồn đơn"), as the
// server summed them for the chosen days.
export function SourceSummary({ value, currency }: { value: unknown; currency: string }) {
  const { t } = useTranslation()
  if (!Array.isArray(value)) return null
  const rows = orderSourceRows(value)
  return (
    <SummaryCard title={t('reportBySource')}>
      <div className="overflow-x-auto">
        <table className="w-full text-sm" aria-label={t('reportBySource')}>
          <thead className="border-b">
            <tr>
              <th scope="col" className={TH}>
                {t('reportCol_order_source')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('reportBySourceOrders')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('reportBySourceSales')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('reportBySourceOwed')}
              </th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {rows.map((row) => (
              <tr key={row.order_source}>
                <th scope="row" className={`${TD} text-left font-normal`}>
                  {t(orderSourceKey(row.order_source))}
                </th>
                <td className={NUM}>{row.orders}</td>
                <td className={NUM}>{formatMoney(row.sales_total, currency)}</td>
                <td className={NUM}>{formatMoney(row.owed, currency)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </SummaryCard>
  )
}

// Per-shift drawer lines of the cashbook, paged by the server.
export function ShiftSummary({
  lines,
  page,
  pages,
  count,
  currency,
  timeZone,
  onPage,
}: {
  lines: ShiftLine[]
  page: number
  pages: number
  count: number
  currency: string
  timeZone: string
  onPage: (page: number) => void
}) {
  const { t, i18n } = useTranslation()
  if (lines.length === 0) return null
  return (
    <SummaryCard title={t('reportShiftSummaryCaption', { count })}>
      <div className="overflow-x-auto">
        <table className="w-full text-sm" aria-label={t('reportShiftSummary')}>
          <thead className="border-b">
            <tr>
              <th scope="col" className={TH}>
                {t('reportCol_register')}
              </th>
              <th scope="col" className={TH}>
                {t('reportCol_cashier')}
              </th>
              <th scope="col" className={TH}>
                {t('shiftOpenedAt')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('shiftOpeningFloat')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('reportCol_expected')}
              </th>
              <th scope="col" className={`${TH} text-right`}>
                {t('reportCol_counted')}
              </th>
              <th scope="col" className={TH}>
                {t('reportCol_variance')}
              </th>
            </tr>
          </thead>
          <tbody className="divide-y">
            {lines.map((line) => (
              <tr key={line.shift_id}>
                <td className={TD}>{line.register ?? t('shiftNoRegister')}</td>
                <td className={TD}>{line.cashier}</td>
                <td className={`${TD} whitespace-nowrap`}>
                  {formatInstant(line.opened_at, i18n.language, timeZone)}
                </td>
                <td className={NUM}>{formatMoney(line.opening_float, currency)}</td>
                <td className={NUM}>{formatMoney(line.expected, currency)}</td>
                <td className={NUM}>
                  {line.counted ? formatMoney(line.counted, currency) : t('reportNotCounted')}
                </td>
                <td className={TD}>
                  {line.variance ? (
                    <VarianceText variance={line.variance} currency={currency} />
                  ) : (
                    '—'
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {pages > 1 && (
        <nav
          aria-label={t('reportShiftPages')}
          className="flex items-center justify-end gap-3 pt-3 text-sm"
        >
          <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
            {t('reportPrevious')}
          </Button>
          <span className="text-muted-foreground">{t('reportPageOf', { page, pages })}</span>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= pages}
            onClick={() => onPage(page + 1)}
          >
            {t('reportNext')}
          </Button>
        </nav>
      )}
    </SummaryCard>
  )
}
