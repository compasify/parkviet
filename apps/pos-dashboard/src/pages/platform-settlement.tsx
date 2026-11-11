import { formatMoney } from '@parkviet/pos-shared/money'
import {
  PLATFORMS,
  type Platform,
  type PlatformOrder,
  platformKey,
} from '@parkviet/pos-shared/platform-orders'
import { validReportRange } from '@parkviet/pos-shared/reports'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { Button, Input, Label } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { ModelNotice, ModelPage, ModelSelect, ModelState } from '../components/setup/model-ui'
import {
  type UnsettledFilters,
  useSettlePlatformOrders,
  useUnsettledPlatformOrders,
} from '../hooks/use-platform-orders'
import { usePosSession } from '../hooks/use-pos-session'
import { dayText } from '../lib/report-table'

const REFUSALS = [
  'platform_order_open',
  'platform_order_settled',
  'platform_commission_invalid',
  'platform_settle_empty',
] as const
type Notice = { text: string; failed: boolean } | null
type T = (key: string, options?: Record<string, unknown>) => string

function settleFailure(error: unknown, t: T) {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`platformSettlement.failure_${reason}`)
    : describeFailure(error, t)
}

// A whole amount of money, as typed; blank keeps the estimate.
const amountValid = (value: string) => value.trim() === '' || /^\d+(\.\d{1,2})?$/.test(value.trim())

// "Đối soát nền tảng": the completed platform orders of the selected branch
// the platforms have not paid yet. Ticking orders and recording the payout
// keeps the commission the platform actually kept (the branch rate's estimate
// unless changed) and the payout reference; the sales do not change.
export function PlatformSettlementPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  return (
    <ModelPage
      title={t('platformSettlement.title')}
      description={t('platformSettlement.intro')}
      actions={<BranchPicker />}
    >
      {branchId ? (
        <Settlement key={branchId} branchId={branchId} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </ModelPage>
  )
}

function Settlement({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const [filters, setFilters] = useState<UnsettledFilters>({ page: 1 })
  const [picked, setPicked] = useState<Record<string, boolean>>({})
  const [commissions, setCommissions] = useState<Record<string, string>>({})
  const [reference, setReference] = useState('')
  const [notice, setNotice] = useState<Notice>(null)
  const datesValid = !filters.from || !filters.to || validReportRange(filters.from, filters.to)
  const orders = useUnsettledPlatformOrders(branchId, filters)
  const settle = useSettlePlatformOrders(branchId)
  const rows = orders.data?.data ?? []
  const chosen = rows.filter((row) => picked[row.id])
  const valid = chosen.length > 0 && chosen.every((row) => amountValid(commissions[row.id] ?? ''))
  const meta = orders.data?.meta

  const filter = (patch: Partial<UnsettledFilters>) => {
    setPicked({})
    setFilters((current) => ({ ...current, ...patch, page: patch.page ?? 1 }))
  }

  async function submit() {
    if (!valid || settle.isPending) return
    setNotice(null)
    try {
      const settled = await settle.mutateAsync({
        reference,
        orders: chosen.map((row) => {
          const commission = (commissions[row.id] ?? '').trim()
          return commission ? { id: row.id, commission_amount: commission } : { id: row.id }
        }),
      })
      setPicked({})
      setCommissions({})
      setReference('')
      setNotice({
        text: t('platformSettlement.settled', { count: settled.data.length }),
        failed: false,
      })
    } catch (failure) {
      setNotice({ text: settleFailure(failure, t), failed: true })
    }
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 sm:grid-cols-3">
        <ModelSelect
          label={t('platformSettlement.platform')}
          value={filters.platform ?? ''}
          options={[
            { value: '', label: t('platformSettlement.allPlatforms') },
            ...PLATFORMS.map((value) => ({ value, label: t(platformKey(value)) })),
          ]}
          onChange={(value) => filter({ platform: (value || undefined) as Platform | undefined })}
        />
        <div className="space-y-2">
          <Label htmlFor="settle-from">{t('platformSettlement.from')}</Label>
          <Input
            id="settle-from"
            type="date"
            value={filters.from ?? ''}
            onChange={(event) => filter({ from: event.target.value || undefined })}
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="settle-to">{t('platformSettlement.to')}</Label>
          <Input
            id="settle-to"
            type="date"
            value={filters.to ?? ''}
            aria-invalid={!datesValid}
            onChange={(event) => filter({ to: event.target.value || undefined })}
          />
        </div>
      </div>
      <ModelNotice notice={notice} />
      {orders.isError ? (
        <ModelState
          title={describeFailure(orders.error, t)}
          error
          retry={() => void orders.refetch()}
        />
      ) : orders.isPending ? (
        <ModelState title={t('waiting')} />
      ) : rows.length === 0 ? (
        <ModelState title={t('platformSettlement.empty')} />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full text-sm" data-testid="platform-settlement-table">
            <thead>
              <tr className="border-b text-left">
                <th className="p-2">
                  <span className="sr-only">{t('platformSettlement.pick')}</span>
                </th>
                <th className="p-2">{t('platformSettlement.businessDate')}</th>
                <th className="p-2">{t('platformSettlement.platform')}</th>
                <th className="p-2">{t('platformSettlement.ref')}</th>
                <th className="p-2 text-right">{t('platformSettlement.gross')}</th>
                <th className="p-2 text-right">{t('platformSettlement.estimate')}</th>
                <th className="p-2">{t('platformSettlement.actual')}</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <SettleRow
                  key={row.id}
                  row={row}
                  picked={Boolean(picked[row.id])}
                  commission={commissions[row.id] ?? ''}
                  onPick={(value) => setPicked((current) => ({ ...current, [row.id]: value }))}
                  onCommission={(value) =>
                    setCommissions((current) => ({ ...current, [row.id]: value }))
                  }
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
      {meta && meta.pages > 1 ? (
        <div className="flex items-center gap-2">
          <Button
            type="button"
            variant="outline"
            disabled={filters.page <= 1}
            onClick={() => filter({ page: filters.page - 1 })}
          >
            {t('previousPage')}
          </Button>
          <span>
            {meta.page} / {meta.pages}
          </span>
          <Button
            type="button"
            variant="outline"
            disabled={filters.page >= meta.pages}
            onClick={() => filter({ page: filters.page + 1 })}
          >
            {t('nextPage')}
          </Button>
        </div>
      ) : null}
      <form
        className="flex flex-wrap items-end gap-4"
        onSubmit={(event) => {
          event.preventDefault()
          void submit()
        }}
      >
        <div className="space-y-2">
          <Label htmlFor="settle-reference">{t('platformSettlement.reference')}</Label>
          <Input
            id="settle-reference"
            value={reference}
            maxLength={120}
            onChange={(event) => setReference(event.target.value)}
          />
        </div>
        <Button type="submit" disabled={!valid || settle.isPending} data-testid="platform-settle">
          {t('platformSettlement.submit', { count: chosen.length })}
        </Button>
      </form>
    </div>
  )
}

function SettleRow({
  row,
  picked,
  commission,
  onPick,
  onCommission,
}: {
  row: PlatformOrder
  picked: boolean
  commission: string
  onPick: (value: boolean) => void
  onCommission: (value: string) => void
}) {
  const { t } = useTranslation()
  const money = (value: string) => formatMoney(value, row.currency)
  return (
    <tr className="border-b last:border-0" data-testid={`settle-${row.id}`}>
      <td className="p-2">
        <input
          type="checkbox"
          checked={picked}
          aria-label={t('platformSettlement.pickOrder', { ref: row.platform_order_ref })}
          onChange={(event) => onPick(event.target.checked)}
        />
      </td>
      <td className="p-2">{row.business_date ? dayText(row.business_date) : '—'}</td>
      <td className="p-2">{t(platformKey(row.platform))}</td>
      <td className="p-2">{row.platform_order_ref}</td>
      <td className="p-2 text-right">{money(row.gross_amount)}</td>
      <td className="p-2 text-right">
        {money(row.commission_amount)}{' '}
        <span className="text-muted-foreground">({Number(row.commission_rate)}%)</span>
      </td>
      <td className="p-2">
        <Input
          inputMode="numeric"
          className="w-32"
          value={commission}
          placeholder={String(Number(row.commission_amount))}
          aria-label={t('platformSettlement.actualOf', { ref: row.platform_order_ref })}
          aria-invalid={!amountValid(commission)}
          onChange={(event) => onCommission(event.target.value)}
        />
      </td>
    </tr>
  )
}
