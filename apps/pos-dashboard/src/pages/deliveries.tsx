import {
  type DeliveryStatus,
  deliveryFailureKey,
  hasOwed,
  type PosDeliveryRow,
  telHref,
} from '@parkviet/pos-shared/deliveries'
import { formatMoney } from '@parkviet/pos-shared/money'
import { orderSourceKey, orderSourceOf } from '@parkviet/pos-shared/order-source'
import { contextFeature } from '@parkviet/pos-shared/pos-features'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { defineTable, PageHeader, ResourceTable, usePermissions } from '@spree/dashboard-core'
import { Badge, Button, ResourceNameCell, RowActions } from '@spree/dashboard-ui'
import { CheckIcon, EyeIcon, RotateCcwIcon, Undo2Icon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { FilterSelect } from '../components/filter-select'
import { fetchDeliveries, useChangeDelivery } from '../hooks/use-deliveries'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { canReadOrders } from '../lib/pos-access'
import { deliverySearchSchema } from '../schemas/list-search'
import { hiddenTimestamps } from '../tables/columns'

// "Đơn cần giao": the branch's sales marked for delivery. Pending ones wait
// oldest first; the ones delivered today can be reviewed and put back if
// marked by mistake.
export function DeliveriesPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('deliveriesTitle')}
        description={t('deliveriesHint')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <Deliveries key={branchId} branchId={branchId} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function Deliveries({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const client = useQueryClient()
  const navigate = useNavigate({ from: '/$storeId/deliveries' })
  const search = deliverySearchSchema.parse(useSearch({ strict: false }))
  const status: DeliveryStatus = search.status ?? 'pending'
  const change = useChangeDelivery()
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const timeZone = branchTimeZone(context.data)
  const time = (value: string | null) => formatInstant(value, i18n.language, timeZone)
  const ordersReadable = canReadOrders({ permissionKeys, context: context.data })
  const refresh = () => client.invalidateQueries({ queryKey: ['pos', storeId, 'deliveries'] })
  // Other devices sell and deliver too; refresh every half minute.
  // biome-ignore lint/correctness/useExhaustiveDependencies: the interval only depends on the store
  useEffect(() => {
    const timer = window.setInterval(() => void refresh(), 30_000)
    return () => window.clearInterval(timer)
  }, [storeId])

  function act(row: PosDeliveryRow, action: 'deliver' | 'reopen') {
    if (change.isPending) return
    setNotice(null)
    change.mutate(
      { id: row.id, action },
      {
        onSuccess: () =>
          setNotice({
            text: t(action === 'deliver' ? 'deliveriesDone' : 'deliveriesReopened', {
              number: row.order_number,
            }),
            failed: false,
          }),
        onError: (failure) => {
          const key = deliveryFailureKey(conflictReason(failure))
          setNotice({
            text: key ? t(key) : describeFailure(failure, t, 'deliveriesFailed'),
            failed: true,
          })
        },
      },
    )
  }

  const tableKey = 'pos-deliveries'
  defineTable<PosDeliveryRow>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('deliveriesSearch'),
    defaultSort: { field: 'placed_at', direction: status === 'pending' ? 'asc' : 'desc' },
    emptyMessage: t(status === 'pending' ? 'deliveriesEmpty' : 'deliveriesEmptyToday'),
    columns: [
      {
        key: 'order_number',
        label: t('ordersNumber'),
        default: true,
        render: (row) => {
          const source = orderSourceOf(row.order_source)
          return (
            <ResourceNameCell
              id={row.id}
              name={row.order_number}
              secondary={[
                time(row.placed_at),
                ...(source === 'counter' ? [] : [t(orderSourceKey(source))]),
              ].join(' · ')}
            />
          )
        },
      },
      {
        key: 'customer',
        label: t('ordersCustomer'),
        default: true,
        className: 'whitespace-normal',
        render: (row) => {
          const phone = row.customer?.phone ?? null
          const tel = telHref(phone)
          return (
            <span className="flex flex-col">
              <span>{row.customer?.name || t('customerWalkIn')}</span>
              {phone && (
                <span className="text-xs">
                  {tel ? (
                    <a href={tel} className="underline">
                      {phone}
                    </a>
                  ) : (
                    phone
                  )}
                </span>
              )}
              {row.customer?.address && (
                <span className="text-xs text-muted-foreground">{row.customer.address}</span>
              )}
            </span>
          )
        },
      },
      {
        key: 'deliverer',
        label: t('deliveryDeliverer'),
        default: true,
        render: (row) => (
          <span className="flex flex-col">
            <span>{row.deliverer ?? t('deliveriesNoDeliverer')}</span>
            {row.status === 'delivered' && row.delivered_at && (
              <span className="text-xs text-muted-foreground">
                {t('deliveriesDeliveredAt', { time: time(row.delivered_at) })}
              </span>
            )}
          </span>
        ),
      },
      {
        key: 'total',
        label: t('orderTotal'),
        default: true,
        render: (row) => (
          <span className="flex flex-col items-start gap-1">
            <span className="tabular-nums">{formatMoney(row.total, row.currency)}</span>
            {hasOwed(row) ? (
              <Badge variant="warning">
                {t('deliveriesOwed', { amount: formatMoney(row.owed, row.currency) })}
              </Badge>
            ) : (
              <Badge variant="success">{t('deliveriesPaid')}</Badge>
            )}
          </span>
        ),
      },
      ...hiddenTimestamps<PosDeliveryRow>(),
    ],
  })

  return (
    <div className="space-y-4">
      {!contextFeature(context.data, 'delivery') && (
        <p role="note" className="text-sm text-muted-foreground">
          {t('featureOff_delivery')}
        </p>
      )}
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      <ResourceTable<PosDeliveryRow>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'deliveries', branchId, status]}
        queryFn={(params: Record<string, unknown>) => fetchDeliveries(branchId, status, params)}
        searchParams={search}
        actions={
          <>
            <FilterSelect
              label={t('deliveriesFilter')}
              value={status}
              options={(['pending', 'delivered'] as const).map((value) => ({
                value,
                label: t(`deliveriesStatus_${value}`),
              }))}
              onChange={(value) => {
                setNotice(null)
                void navigate({
                  search: (previous) => ({
                    ...previous,
                    status: value === 'delivered' ? 'delivered' : undefined,
                    page: 1,
                  }),
                })
              }}
            />
            <Button variant="outline" onClick={() => void refresh()}>
              <RotateCcwIcon className="size-4" />
              {t('refresh')}
            </Button>
          </>
        }
        rowActions={(row) => (
          <RowActions
            actions={[
              {
                key: 'deliver',
                label: t('deliveriesMarkDelivered'),
                icon: <CheckIcon className="size-4" />,
                visible: row.status === 'pending',
                disabled: change.isPending,
                onSelect: () => act(row, 'deliver'),
              },
              {
                key: 'reopen',
                label: t('deliveriesUndo'),
                icon: <Undo2Icon className="size-4" />,
                visible: row.status === 'delivered',
                disabled: change.isPending,
                onSelect: () => act(row, 'reopen'),
              },
              {
                key: 'order',
                label: t('orderOpen'),
                icon: <EyeIcon className="size-4" />,
                visible: ordersReadable,
                onSelect: () =>
                  void navigate({
                    to: '/$storeId/orders/$orderId',
                    params: { orderId: row.order_id },
                  }),
              },
            ]}
          />
        )}
      />
    </div>
  )
}
