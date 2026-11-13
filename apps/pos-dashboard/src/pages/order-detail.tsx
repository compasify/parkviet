import { formatMoney } from '@parkviet/pos-shared/money'
import { orderSourceKey, orderSourceOf } from '@parkviet/pos-shared/order-source'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  canResolve,
  describeReturnFailure,
  type PosOrderDetail,
  saleQuantityLabel,
  sumMoney,
} from '@parkviet/pos-shared/returns'
import { formatExpiry, type OrderLineTrace } from '@parkviet/pos-shared/traceability'
import { PageHeader } from '@spree/dashboard-core'
import { Badge, Button, ResourceLayout } from '@spree/dashboard-ui'
import {
  ClockIcon,
  InfoIcon,
  PackageIcon,
  ReceiptTextIcon,
  ShoppingCartIcon,
  Undo2Icon,
} from '@spree/dashboard-ui/icons'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { ModelCard } from '../components/setup/model-ui'
import { useOrder, useReconcileHandover } from '../hooks/use-orders'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { OrderTags } from './orders'

export function OrderDetailPage({ orderId }: { orderId: string }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const order = useOrder(orderId, branchId)
  const backTo = `/${storeId}/orders`
  if (!order.data)
    return (
      <div className="space-y-6">
        <PageHeader title={t('orderDetail')} backTo={backTo} />
        {order.isError ? (
          <div role="alert" className="space-y-2">
            <p>{describeFailure(order.error, t)}</p>
            <Button onClick={() => void order.refetch()}>{t('retry')}</Button>
          </div>
        ) : (
          <p role="status">{t('waiting')}</p>
        )}
      </div>
    )
  return <OrderDetail order={order.data} backTo={backTo} />
}

function Summary({ rows }: { rows: [string, string][] }) {
  return (
    <dl className="grid grid-cols-[1fr_auto] gap-x-4 gap-y-2 text-sm">
      {rows.map(([label, value]) => (
        <div key={label} className="contents">
          <dt className="text-muted-foreground">{label}</dt>
          <dd className="text-right tabular-nums">{value}</dd>
        </div>
      ))}
    </dl>
  )
}

function TraceText({ trace }: { trace: OrderLineTrace | null | undefined }) {
  const { t } = useTranslation()
  if (!trace?.allocations.length) return null
  return (
    <span className="block text-xs text-muted-foreground">
      {trace.allocations
        .map((allocation) => {
          const label =
            trace.mode === 'serial'
              ? (allocation.serial ?? '')
              : `${
                  allocation.expiry_on
                    ? t('saleLineLotExpiry', {
                        code: allocation.lot_code,
                        expiry: formatExpiry(allocation.expiry_on),
                      })
                    : (allocation.lot_code ?? '')
                } × ${allocation.quantity}`
          return allocation.returned_quantity > 0
            ? `${label} (${t('returnTraceReturned', { count: allocation.returned_quantity })})`
            : label
        })
        .join(' · ')}
    </span>
  )
}

function OrderDetail({ order, backTo }: { order: PosOrderDetail; backTo: string }) {
  const { t, i18n } = useTranslation()
  const { context } = usePosSession()
  const reconcile = useReconcileHandover()
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const timeZone = branchTimeZone(context.data)
  const time = (value: string | null | undefined) => formatInstant(value, i18n.language, timeZone)
  const money = (value: string | null | undefined) => formatMoney(value, order.currency)
  const source = orderSourceOf(order.order_source)
  const openGaps = order.stock.discrepancies.filter((gap) => gap.status === 'open')
  const header = (
    <PageHeader
      title={t('orderDetailTitle', { number: order.number })}
      subtitle={time(order.placed_at)}
      backTo={backTo}
      badges={
        <>
          {source !== 'counter' && <Badge variant="outline">{t(orderSourceKey(source))}</Badge>}
          <OrderTags order={order} />
        </>
      }
    />
  )
  const main = (
    <>
      <ModelCard title={t('orderLines')} id="order-lines" icon={<ShoppingCartIcon />}>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="text-left text-muted-foreground">
              <tr>
                <th scope="col" className="py-2 pe-3 font-medium">
                  {t('orderLineItem')}
                </th>
                <th scope="col" className="py-2 pe-3 font-medium">
                  {t('orderLineSold')}
                </th>
                <th scope="col" className="py-2 pe-3 font-medium">
                  {t('orderLineReturned')}
                </th>
                <th scope="col" className="py-2 pe-3 font-medium">
                  {t('orderLineReturnable')}
                </th>
                <th scope="col" className="py-2 text-right font-medium">
                  {t('orderLineValue')}
                </th>
              </tr>
            </thead>
            <tbody>
              {order.lines.map((line) => (
                <tr key={line.sale_line_id} className="border-t align-top">
                  <th scope="row" className="py-2 pe-3 text-left font-normal">
                    {line.name}
                    {line.sku && (
                      <span className="block text-xs text-muted-foreground">{line.sku}</span>
                    )}
                    {line.trace ? (
                      <TraceText trace={line.trace} />
                    ) : line.lot_code ? (
                      <span className="block text-xs text-muted-foreground">{line.lot_code}</span>
                    ) : null}
                  </th>
                  <td className="py-2 pe-3 whitespace-nowrap">{saleQuantityLabel(line)}</td>
                  <td className="py-2 pe-3">
                    {t('orderLineReturnedValue', {
                      posted: line.posted_quantity,
                      held: line.returned_quantity - line.posted_quantity,
                      unit: line.base_unit,
                    })}
                  </td>
                  <td className="py-2 pe-3 whitespace-nowrap">
                    {line.handed_over
                      ? `${line.returnable_quantity} ${line.base_unit}`
                      : t('orderNotHandedOver')}
                  </td>
                  <td className="py-2 text-right tabular-nums">{money(line.original.total)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </ModelCard>
      <ModelCard title={t('orderReceipts')} id="order-receipts" icon={<ReceiptTextIcon />}>
        {order.receipts.length === 0 ? (
          <p className="text-sm text-muted-foreground">{t('orderNoReceipts')}</p>
        ) : (
          <ul className="divide-y text-sm" aria-label={t('orderReceipts')}>
            {order.receipts.map((receipt) => (
              <li key={receipt.allocation_id} className="flex flex-wrap justify-between gap-2 py-2">
                <span>
                  {t(receipt.kind === 'cash' ? 'orderReceiptCash' : 'orderReceiptBank')}
                  {receipt.collection ? ` · ${t('orderCollection')}` : ''}
                  {receipt.reference ? ` · ${receipt.reference}` : ''}
                  <span className="block text-xs text-muted-foreground">
                    {t('orderReceiptRefunded', {
                      refunded: money(receipt.refunded),
                      reserved: money(receipt.refund_reserved),
                    })}
                  </span>
                </span>
                <span className="tabular-nums">{money(receipt.amount)}</span>
              </li>
            ))}
          </ul>
        )}
      </ModelCard>
      {order.returns.length > 0 && (
        <ModelCard title={t('orderReturns')} id="order-returns" icon={<Undo2Icon />}>
          <ul className="divide-y text-sm" aria-label={t('orderReturns')}>
            {order.returns.map((row) => (
              <li key={row.id} className="flex flex-wrap items-center justify-between gap-2 py-2">
                <span className="flex flex-wrap items-center gap-2">
                  <span className="font-medium">{row.return_number}</span>
                  <Badge variant={row.status === 'pending_approval' ? 'warning' : 'outline'}>
                    {t(`returnStatus_${row.status}`)}
                  </Badge>
                  <span className="text-xs text-muted-foreground">
                    {t('orderReturnRefunds', {
                      refunded: money(row.refunded),
                      requested: money(row.refund_requested),
                    })}
                  </span>
                </span>
                <span className="tabular-nums">{money(row.entitlement_total)}</span>
              </li>
            ))}
          </ul>
        </ModelCard>
      )}
      <ModelCard title={t('orderStock')} id="order-stock" icon={<PackageIcon />}>
        <p className="text-sm text-muted-foreground">
          {t('orderStockEffects', {
            restocked: order.stock.restocked_quantity,
            damaged: order.stock.damaged_quantity,
          })}
        </p>
        {order.stock.discrepancies.length > 0 && (
          <div className="space-y-3" role="note">
            <p className="font-medium text-warning">{t('orderStockAttention')}</p>
            <ul className="space-y-1 text-sm">
              {order.stock.discrepancies.map((gap) => (
                <li key={gap.id}>
                  {t('orderStockGap', { name: gap.name, needed: gap.needed, onHand: gap.on_hand })}{' '}
                  · {t(`stockGapStatus_${gap.status}`)}
                </li>
              ))}
            </ul>
            {openGaps.length > 0 && canResolve(context.data?.capabilities) && (
              <div className="flex flex-wrap items-center gap-3">
                <Button
                  disabled={reconcile.isPending}
                  onClick={() => {
                    setNotice(null)
                    reconcile.mutate(order.id, {
                      onSuccess: (result) =>
                        setNotice({
                          text: t(
                            result.stock_discrepancies.length
                              ? 'orderReconcileStillShort'
                              : 'orderReconcileDone',
                          ),
                          failed: result.stock_discrepancies.length > 0,
                        }),
                      onError: (failure) =>
                        setNotice({ text: describeReturnFailure(failure, t), failed: true }),
                    })
                  }}
                >
                  {t('orderReconcile')}
                </Button>
                <span className="text-sm text-muted-foreground">{t('orderReconcileHint')}</span>
              </div>
            )}
            {notice && (
              <p
                role={notice.failed ? 'alert' : 'status'}
                className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
              >
                {notice.text}
              </p>
            )}
          </div>
        )}
      </ModelCard>
    </>
  )
  const sidebar = (
    <>
      <ModelCard title={t('orderSummary')} id="order-summary" icon={<ReceiptTextIcon />}>
        <Summary
          rows={[
            [t('orderOriginalTotal'), money(order.totals.original_total)],
            [t('orderPaid'), money(order.paid)],
            [t('orderEntitlementUsed'), money(order.entitlement.used)],
            [t('orderEntitlementReserved'), money(order.entitlement.reserved)],
            [t('orderCreditNotes'), money(order.entitlement.credit_notes)],
            [t('orderRefunded'), money(sumMoney(order.receipts.map((row) => row.refunded)))],
            ...(order.credit
              ? [[t('orderDebtBalance'), money(order.credit.balance)] as [string, string]]
              : []),
          ]}
        />
      </ModelCard>
      <ModelCard title={t('orderInformation')} id="order-information" icon={<InfoIcon />}>
        <Summary
          rows={[
            [t('ordersRegister'), order.register ?? '—'],
            [t('ordersCashier'), order.cashier],
            [t('ordersCustomer'), order.customer?.name || t('customerWalkIn')],
            ...(order.customer?.phone
              ? [[t('ordersPhone'), order.customer.phone] as [string, string]]
              : []),
          ]}
        />
      </ModelCard>
      <ModelCard title={t('orderTimeline')} id="order-timeline" icon={<ClockIcon />}>
        <ol className="space-y-2 text-sm" aria-label={t('orderTimeline')}>
          {order.timeline.map((event) => (
            <li key={event.id}>
              <time dateTime={event.at} className="block text-xs text-muted-foreground">
                {time(event.at)}
              </time>
              {t(`timeline_${event.kind}`, { defaultValue: event.kind })}
              {event.reference ? ` ${event.reference}` : ''}
              {event.amount ? ` · ${money(event.amount)}` : ''}
            </li>
          ))}
        </ol>
      </ModelCard>
    </>
  )
  return <ResourceLayout header={header} main={main} sidebar={sidebar} />
}
