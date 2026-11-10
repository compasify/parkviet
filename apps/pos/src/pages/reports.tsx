import { formatMoney } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { type KeyboardEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FeatureOffNote } from '../components/feature-off-note';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { VarianceText } from '../components/shift-close-dialog';
import {
  exportDownloadLink,
  type ReportFilters,
  useCreateExport,
  useExports,
  useReport,
} from '../hooks/use-reports';
import {
  matchingPreset,
  ORDER_SOURCES,
  orderSourceKey,
  orderSourceRows,
  RANGE_PRESETS,
  rangePreset,
} from '../lib/order-source';
import { failureStatus } from '../lib/request-failure';
import {
  canExportReports,
  describeShiftFailure,
  formatInZone,
  REPORT_TYPES,
  type ReportRow,
  type ReportType,
  startDownload,
  businessDate,
  todayIn,
  validReportRange,
} from '../lib/shifts';

const COLUMNS: Record<ReportType, string[]> = {
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
};
const RETURN_COLUMNS = [
  'return_id',
  'order_number',
  'returned_at',
  'receiver',
  'entitlement_total',
  'credit_note_amount',
  'refund_entitlement',
];
const MONEY = new Set([
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
]);
const TIMES = new Set([
  'sold_at',
  'received_at',
  'booked_at',
  'at',
  'placed_at',
  'closed_at',
  'returned_at',
]);
const CODES: Record<string, string> = {
  kind: 'reportKind_',
  source: 'reportSource_',
  custody: 'reportCustody_',
  category: 'reportCategory_',
  aging: 'reportAging_',
  order_source: 'orderSource_',
};

type ShiftLine = {
  shift_id: string;
  register: string | null;
  cashier: string;
  status: string;
  opened_at: string | null;
  opening_float: string;
  expected: string;
  counted: string | null;
  variance: string | null;
};

export function ReportsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Reports key={scope} />;
}

function Cell({
  column,
  row,
  timezone,
  currency,
}: {
  column: string;
  row: ReportRow;
  timezone: string;
  currency: string;
}) {
  const { t, i18n } = useTranslation();
  const value = row[column];
  const money = String(row.currency ?? currency);
  if (value == null || value === '') return <>—</>;
  if (column === 'variance') return <VarianceText variance={String(value)} currency={money} />;
  if (MONEY.has(column)) return <>{formatMoney(String(value), money)}</>;
  if (TIMES.has(column)) return <>{formatInZone(String(value), i18n.language, timezone)}</>;
  if (column === 'business_date') {
    const match = String(value).match(/^(\d{4})-(\d{2})-(\d{2})/);
    return <>{match ? `${match[3]}/${match[2]}/${match[1]}` : String(value)}</>;
  }
  if (CODES[column]) return <>{t(`${CODES[column]}${value}`, { defaultValue: String(value) })}</>;
  return <>{String(value)}</>;
}

function Summary({
  type,
  summary,
  currency,
}: {
  type: ReportType;
  summary: Record<string, unknown>;
  currency: string;
}) {
  const { t } = useTranslation();
  const entries = Object.entries(summary).filter(
    ([key, value]) =>
      (typeof value === 'string' || typeof value === 'number') && !key.startsWith('shift_page'),
  );
  if (entries.length === 0) return null;
  return (
    <dl className="summary-grid report-summary" aria-label={t('reportSummary')}>
      {entries.map(([key, value]) => (
        <div key={key}>
          <dt>
            {t(`reportSum_${type}_${key}`, {
              defaultValue: t(`reportSum_${key}`, { defaultValue: key }),
            })}
          </dt>
          <dd>
            {typeof value === 'string' && /^-?\d+\.\d+$/.test(value)
              ? formatMoney(value, currency)
              : String(value)}
          </dd>
        </div>
      ))}
    </dl>
  );
}

// Sales grouped by where the order came from ("Theo nguồn đơn"), as the
// server summed them for the chosen days.
function SourceSummary({ value, currency }: { value: unknown; currency: string }) {
  const { t } = useTranslation();
  if (!Array.isArray(value)) return null;
  const rows = orderSourceRows(value);
  return (
    <div className="table-scroll">
      <table className="report-table report-by-source">
        <caption>{t('reportBySource')}</caption>
        <thead>
          <tr>
            <th scope="col">{t('reportCol_order_source')}</th>
            <th scope="col">{t('reportBySourceOrders')}</th>
            <th scope="col">{t('reportBySourceSales')}</th>
            <th scope="col">{t('reportBySourceOwed')}</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.order_source}>
              <th scope="row">{t(orderSourceKey(row.order_source))}</th>
              <td className="numeric">{row.orders}</td>
              <td className="numeric">{formatMoney(row.sales_total, currency)}</td>
              <td className="numeric">{formatMoney(row.owed, currency)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

// Per-shift drawer lines of the cashbook, paged by the server.
function ShiftSummary({
  lines,
  page,
  pages,
  count,
  currency,
  timezone,
  onPage,
}: {
  lines: ShiftLine[];
  page: number;
  pages: number;
  count: number;
  currency: string;
  timezone: string;
  onPage: (page: number) => void;
}) {
  const { t, i18n } = useTranslation();
  if (lines.length === 0) return null;
  return (
    <div className="table-scroll">
      <table className="report-table" aria-label={t('reportShiftSummary')}>
        <caption>{t('reportShiftSummaryCaption', { count })}</caption>
        <thead>
          <tr>
            <th scope="col">{t('reportCol_register')}</th>
            <th scope="col">{t('reportCol_cashier')}</th>
            <th scope="col">{t('shiftOpenedAt')}</th>
            <th scope="col">{t('shiftOpeningFloat')}</th>
            <th scope="col">{t('reportCol_expected')}</th>
            <th scope="col">{t('reportCol_counted')}</th>
            <th scope="col">{t('reportCol_variance')}</th>
          </tr>
        </thead>
        <tbody>
          {lines.map((line) => (
            <tr key={line.shift_id}>
              <td>{line.register ?? t('shiftNoRegister')}</td>
              <td>{line.cashier}</td>
              <td>{formatInZone(line.opened_at, i18n.language, timezone)}</td>
              <td className="numeric">{formatMoney(line.opening_float, currency)}</td>
              <td className="numeric">{formatMoney(line.expected, currency)}</td>
              <td className="numeric">
                {line.counted ? formatMoney(line.counted, currency) : t('reportNotCounted')}
              </td>
              <td>
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
      {pages > 1 ? (
        <nav className="row" aria-label={t('reportShiftPages')}>
          <button type="button" disabled={page <= 1} onClick={() => onPage(page - 1)}>
            {t('reportPrevious')}
          </button>
          <span>{t('reportPageOf', { page, pages })}</span>
          <button type="button" disabled={page >= pages} onClick={() => onPage(page + 1)}>
            {t('reportNext')}
          </button>
        </nav>
      ) : null}
    </div>
  );
}

function Reports() {
  const { t, i18n } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branch = data?.branches.find((row) => row.id === selection.branchId);
  const branchZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const currency = data?.store.currency ?? 'VND';
  const [type, setType] = useState<ReportType>('sales');
  const cutoff = branch?.business_day_cutoff ?? '04:00';
  // Sales follow the business date. Other reports follow the calendar day.
  const today = type === 'sales' ? businessDate(branchZone, cutoff) : todayIn(branchZone);
  const [range, setRange] = useState<{ from: string; to: string } | null>(null);
  const from = range?.from ?? today;
  const to = range?.to ?? today;
  const [registerId, setRegisterId] = useState('');
  const [shiftId, setShiftId] = useState('');
  const [mine, setMine] = useState(false);
  const [extra, setExtra] = useState<Record<string, string>>({});
  const [page, setPage] = useState(1);
  const [shiftPage, setShiftPage] = useState(1);
  const [knownShifts, setKnownShifts] = useState<ShiftLine[]>([]);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const dated = type !== 'receivables';
  const rangeValid = !dated || validReportRange(from, to);
  const filters: ReportFilters = {
    ...(dated ? { from, to } : {}),
    ...(registerId ? { register_id: registerId } : {}),
    ...(shiftId ? { shift_id: shiftId } : {}),
    ...(mine && data ? { cashier_id: data.staff.id } : {}),
    ...(type === 'cashbook' && shiftPage > 1 ? { shift_page: String(shiftPage) } : {}),
    ...Object.fromEntries(Object.entries(extra).filter(([, value]) => value)),
  };
  const view = `${type}:${extra.section ?? ''}`;
  const report = useReport(type, selection.branchId, filters, page, rangeValid);
  // Rows kept from a previous query are shown only for the same report view.
  const current = report.data && report.data.view === view ? report.data : null;
  const exporting = canExportReports(data?.capabilities);
  // Off stops new exports only; files already made stay downloadable until they expire.
  const exportsOn = contextFeature(data, 'exports');
  const exports = useExports(selection.branchId, exporting);
  const createExport = useCreateExport();
  const columns = type === 'sales' && extra.section === 'returns' ? RETURN_COLUMNS : COLUMNS[type];
  const meta = current?.meta;
  const timezone = meta?.timezone ?? branchZone;
  const summaryShifts = (meta?.summary.shifts as ShiftLine[] | undefined) ?? [];
  if (
    summaryShifts.length > 0 &&
    summaryShifts.some((line) => !knownShifts.some((row) => row.shift_id === line.shift_id))
  ) {
    setKnownShifts((rows) => [
      ...rows,
      ...summaryShifts.filter((line) => !rows.some((row) => row.shift_id === line.shift_id)),
    ]);
  }
  const shiftOptions = [
    ...(data?.shift && !knownShifts.some((row) => row.shift_id === data.shift?.id)
      ? [{ shift_id: data.shift.id, label: t('reportCurrentShift') }]
      : []),
    ...knownShifts.map((row) => ({
      shift_id: row.shift_id,
      label: `${row.cashier} · ${row.register ?? t('shiftNoRegister')} · ${formatInZone(row.opened_at, i18n.language, timezone)}`,
    })),
  ];

  function choose(next: ReportType) {
    setType(next);
    setExtra({});
    setPage(1);
    setShiftPage(1);
  }

  function onTabKey(event: KeyboardEvent<HTMLButtonElement>, index: number) {
    const last = REPORT_TYPES.length - 1;
    const target =
      event.key === 'ArrowRight'
        ? (index + 1) % REPORT_TYPES.length
        : event.key === 'ArrowLeft'
          ? (index + last) % REPORT_TYPES.length
          : event.key === 'Home'
            ? 0
            : event.key === 'End'
              ? last
              : null;
    if (target === null) return;
    event.preventDefault();
    const next = REPORT_TYPES[target];
    choose(next);
    document.getElementById(`report-tab-${next}`)?.focus();
  }

  function setFilter(key: string, value: string) {
    setExtra((existing) => ({ ...existing, [key]: value }));
    setPage(1);
  }

  async function download(id: string) {
    setError('');
    try {
      const link = await exportDownloadLink(id);
      startDownload(link.url, link.filename);
    } catch (failure) {
      if (failureStatus(failure) === 410) {
        setError(t('reportExportExpired'));
        void exports.refetch();
        return;
      }
      setError(describeShiftFailure(failure, t));
    }
  }

  return (
    <PosPage title={t('reportsTitle')} description={t('reportsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !selection.branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : (
        <>
          <div className="report-tabs" role="tablist" aria-label={t('reportsTitle')}>
            {REPORT_TYPES.map((value, index) => (
              <button
                key={value}
                id={`report-tab-${value}`}
                type="button"
                role="tab"
                aria-selected={type === value}
                aria-controls="report-panel"
                tabIndex={type === value ? 0 : -1}
                onClick={() => choose(value)}
                onKeyDown={(event) => onTabKey(event, index)}
              >
                {t(`reportTab_${value}`)}
              </button>
            ))}
          </div>
          <section
            id="report-panel"
            className="page-card"
            role="tabpanel"
            aria-labelledby={`report-tab-${type}`}
          >
            <p className="muted">{t(`reportTabHint_${type}`)}</p>
            {type === 'sales' ? (
              <p className="muted">{t('businessDay.reportHint', { cutoff: cutoff.slice(0, 5) })}</p>
            ) : null}
            {dated ? (
              <fieldset className="report-range-presets">
                <legend className="visually-hidden">{t('reportRangeQuick')}</legend>
                {RANGE_PRESETS.map((preset) => (
                  <button
                    key={preset}
                    type="button"
                    aria-pressed={matchingPreset({ from, to }, today) === preset}
                    onClick={() => {
                      setRange(preset === 'today' ? null : rangePreset(preset, today));
                      setPage(1);
                    }}
                  >
                    {t(`reportRange_${preset}`)}
                  </button>
                ))}
              </fieldset>
            ) : null}
            <form className="report-filters row" onSubmit={(event) => event.preventDefault()}>
              {dated ? (
                <>
                  <label>
                    {t('reportFrom')}
                    <input
                      type="date"
                      value={from}
                      max={to}
                      onChange={(event) => {
                        setRange({ from: event.target.value, to });
                        setPage(1);
                      }}
                    />
                  </label>
                  <label>
                    {t('reportTo')}
                    <input
                      type="date"
                      value={to}
                      min={from}
                      onChange={(event) => {
                        setRange({ from, to: event.target.value });
                        setPage(1);
                      }}
                    />
                  </label>
                </>
              ) : null}
              <label>
                {t('register')}
                <select
                  value={registerId}
                  onChange={(event) => {
                    setRegisterId(event.target.value);
                    setPage(1);
                  }}
                >
                  <option value="">{t('reportAllRegisters')}</option>
                  {(data?.registers ?? [])
                    .filter((row) => row.branch_id === selection.branchId)
                    .map((row) => (
                      <option key={row.id} value={row.id}>
                        {row.name}
                      </option>
                    ))}
                </select>
              </label>
              <label>
                {t('reportShift')}
                <select
                  value={shiftId}
                  onChange={(event) => {
                    setShiftId(event.target.value);
                    setPage(1);
                  }}
                >
                  <option value="">{t('reportAllShifts')}</option>
                  {shiftOptions.map((row) => (
                    <option key={row.shift_id} value={row.shift_id}>
                      {row.label}
                    </option>
                  ))}
                </select>
              </label>
              <label className="checkbox-row">
                <input
                  type="checkbox"
                  checked={mine}
                  onChange={(event) => {
                    setMine(event.target.checked);
                    setPage(1);
                  }}
                />
                {t('reportMineOnly')}
              </label>
              {type === 'sales' ? (
                <label>
                  {t('reportSection')}
                  <select
                    value={extra.section ?? ''}
                    onChange={(event) => setFilter('section', event.target.value)}
                  >
                    <option value="">{t('reportSection_sales')}</option>
                    <option value="returns">{t('reportSection_returns')}</option>
                  </select>
                </label>
              ) : null}
              {type === 'sales' ? (
                <label>
                  {t('reportCol_order_source')}
                  <select
                    value={extra.order_source ?? ''}
                    onChange={(event) => setFilter('order_source', event.target.value)}
                  >
                    <option value="">{t('reportAll')}</option>
                    {ORDER_SOURCES.map((source) => (
                      <option key={source} value={source}>
                        {t(orderSourceKey(source))}
                      </option>
                    ))}
                  </select>
                </label>
              ) : null}
              {type === 'receipts' ? (
                <>
                  <label>
                    {t('reportKind')}
                    <select
                      value={extra.kind ?? ''}
                      onChange={(event) => setFilter('kind', event.target.value)}
                    >
                      <option value="">{t('reportAll')}</option>
                      <option value="cash">{t('reportKind_cash')}</option>
                      <option value="bank_manual">{t('reportKind_bank_manual')}</option>
                    </select>
                  </label>
                  <label>
                    {t('reportSource')}
                    <select
                      value={extra.source ?? ''}
                      onChange={(event) => setFilter('source', event.target.value)}
                    >
                      <option value="">{t('reportAll')}</option>
                      <option value="sale">{t('reportSource_sale')}</option>
                      <option value="collection">{t('reportSource_collection')}</option>
                      <option value="unsolicited">{t('reportSource_unsolicited')}</option>
                    </select>
                  </label>
                </>
              ) : null}
              {type === 'receivables' ? (
                <label>
                  {t('reportStatus')}
                  <select
                    value={extra.status ?? ''}
                    onChange={(event) => setFilter('status', event.target.value)}
                  >
                    <option value="">{t('reportStatus_open')}</option>
                    <option value="overdue">{t('reportStatus_overdue')}</option>
                    <option value="settled">{t('reportStatus_settled')}</option>
                    <option value="all">{t('reportAll')}</option>
                  </select>
                </label>
              ) : null}
              {exporting ? (
                <button
                  type="button"
                  disabled={!rangeValid || createExport.isPending || !exportsOn}
                  aria-describedby={exportsOn ? undefined : 'exports-off'}
                  onClick={() => {
                    if (!selection.branchId) return;
                    setError('');
                    const { shift_page: _page, ...exportFilters } = filters;
                    createExport.mutate(
                      { branchId: selection.branchId, type, filters: exportFilters },
                      {
                        onSuccess: () => setNotice(t('reportExportQueued')),
                        onError: (failure) => setError(describeShiftFailure(failure, t)),
                      },
                    );
                  }}
                >
                  {t('reportExport')}
                </button>
              ) : null}
            </form>
            {exporting && !exportsOn ? <FeatureOffNote feature="exports" id="exports-off" /> : null}
            {!rangeValid ? (
              <p className="error" role="alert">
                {t('reportRangeInvalid')}
              </p>
            ) : null}
            {notice ? (
              <p className="muted" role="status">
                {notice}
              </p>
            ) : null}
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
            {meta ? (
              <p className="muted" role="status">
                {t(meta.scope === 'own' ? 'reportScopeOwn' : 'reportScopeBranch')} ·{' '}
                {t('reportTimezone', { zone: meta.timezone })}
              </p>
            ) : null}
            {meta ? <Summary type={type} summary={meta.summary} currency={currency} /> : null}
            {type === 'sales' && extra.section !== 'returns' && meta ? (
              <SourceSummary value={meta.summary.by_source} currency={currency} />
            ) : null}
            {type === 'cashbook' && meta ? (
              <ShiftSummary
                lines={summaryShifts}
                page={Number(meta.summary.shift_page ?? 1)}
                pages={Number(meta.summary.shift_pages ?? 1)}
                count={Number(meta.summary.shift_count ?? summaryShifts.length)}
                currency={currency}
                timezone={timezone}
                onPage={setShiftPage}
              />
            ) : null}
            {report.isLoading || (report.isFetching && !current) ? (
              <PageState kind="loading" title={t('waiting')} />
            ) : null}
            {report.isError ? (
              <PageState kind="error" title={describeShiftFailure(report.error, t)} />
            ) : null}
            {current && current.data.length === 0 ? (
              <PageState kind="empty" title={t('reportEmpty')} />
            ) : null}
            {current && current.data.length > 0 ? (
              <div className="table-scroll">
                <table className="report-table">
                  <caption className="visually-hidden">{t(`reportTab_${type}`)}</caption>
                  <thead>
                    <tr>
                      {columns.map((column) => (
                        <th key={column} scope="col">
                          {t(`reportCol_${column}`)}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {current.data.map((row, index) => (
                      // biome-ignore lint/suspicious/noArrayIndexKey: a read-only server page, replaced as a whole; cashbook rows have no id of their own
                      <tr key={`${page}-${index}`}>
                        {columns.map((column) => (
                          <td key={column} className={MONEY.has(column) ? 'numeric' : undefined}>
                            <Cell
                              column={column}
                              row={row}
                              timezone={timezone}
                              currency={currency}
                            />
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : null}
            {meta && meta.pages > 1 ? (
              <nav className="row" aria-label={t('reportPages')}>
                <button type="button" disabled={page <= 1} onClick={() => setPage(page - 1)}>
                  {t('reportPrevious')}
                </button>
                <span>{t('reportPageOf', { page: meta.page, pages: meta.pages })}</span>
                <button
                  type="button"
                  disabled={page >= meta.pages}
                  onClick={() => setPage(page + 1)}
                >
                  {t('reportNext')}
                </button>
              </nav>
            ) : null}
          </section>
          {exporting ? (
            <section className="page-card" aria-labelledby="exports-title">
              <h2 id="exports-title">{t('reportExports')}</h2>
              <p className="muted">{t('reportExportsHint')}</p>
              {exports.isError ? (
                <PageState kind="error" title={describeShiftFailure(exports.error, t)} />
              ) : null}
              <ul className="record-list" aria-label={t('reportExports')}>
                {(exports.data?.data ?? []).map((row) => {
                  const expired =
                    row.status === 'expired' || Date.parse(row.expires_at) <= Date.now();
                  const status = expired ? 'expired' : row.status;
                  return (
                    <li key={row.id}>
                      <div className="record-copy">
                        <strong>{t(`reportTab_${row.report_type}`)}</strong>
                        <small>
                          {[row.filters.from, row.filters.to].filter(Boolean).join(' – ')} ·{' '}
                          {t('reportExpires', {
                            time: formatInZone(row.expires_at, i18n.language, timezone),
                          })}
                        </small>
                      </div>
                      <span
                        className="status-tag"
                        data-warning={String(status === 'failed' || status === 'expired')}
                      >
                        {t(`reportExportStatus_${status}`)}
                        {row.row_count != null
                          ? ` · ${t('reportRows', { count: row.row_count })}`
                          : ''}
                      </span>
                      {status === 'ready' ? (
                        <button type="button" onClick={() => void download(row.id)}>
                          {t('reportDownload')}
                        </button>
                      ) : null}
                    </li>
                  );
                })}
              </ul>
            </section>
          ) : null}
        </>
      )}
    </PosPage>
  );
}
