import { formatMoney } from '@parkviet/pos-shared/money'
import { orderSourceKey, orderSourceOf } from '@parkviet/pos-shared/order-source'
import { compareMoney, type PosOrderRow } from '@parkviet/pos-shared/returns'
import { defineTable, PageHeader, ResourceTable } from '@spree/dashboard-core'
import { Badge, ResourceNameCell, RowActions, useRowClickBridge } from '@spree/dashboard-ui'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { FilterSelect } from '../components/filter-select'
import { fetchOrders, ORDER_STATUSES, type OrderFilters } from '../hooks/use-orders'
import { usePosSession } from '../hooks/use-pos-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { orderSearchSchema } from '../schemas/list-search'
import { hiddenTimestamps } from '../tables/columns'

const ALL = 'all'

export function OrdersPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('ordersTitle')}
        description={t('ordersHint')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <OrdersTable key={branchId} branchId={branchId} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

export function OrderTags({ order }: { order: PosOrderRow }) {
  const { t } = useTranslation()
  return (
    <span className="flex flex-wrap gap-1">
      {order.debt && compareMoney(order.debt, '0') > 0 && (
        <Badge variant="warning">
          {t('ordersDebt', { amount: formatMoney(order.debt, order.currency) })}
        </Badge>
      )}
      {order.returned && <Badge variant="outline">{t('ordersReturned')}</Badge>}
      {order.refund_pending && <Badge variant="warning">{t('ordersRefundPending')}</Badge>}
    </span>
  )
}

function OrdersTable({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context } = usePosSession()
  const navigate = useNavigate({ from: '/$storeId/orders/' })
  const search = orderSearchSchema.parse(useSearch({ strict: false }))
  const filters: OrderFilters = {
    status: search.status ?? 'all',
    registerId: search.registerId,
    cashierId: search.cashierId,
  }
  const timeZone = branchTimeZone(context.data)
  const registers = (context.data?.registers ?? []).filter((row) => row.branch_id === branchId)
  // Cashiers seen in results so far; the server filters by the chosen one.
  const [cashiers, setCashiers] = useState<Record<string, string>>({})
  const remember = useCallback((rows: PosOrderRow[]) => {
    setCashiers((known) =>
      rows.some((row) => known[row.cashier_id] !== row.cashier)
        ? { ...known, ...Object.fromEntries(rows.map((row) => [row.cashier_id, row.cashier])) }
        : known,
    )
  }, [])
  const open = useCallback(
    (id: string) => void navigate({ to: '/$storeId/orders/$orderId', params: { orderId: id } }),
    [navigate],
  )
  useRowClickBridge('data-pos-order-id', open)
  const choose = (key: 'status' | 'registerId' | 'cashierId', value: string) =>
    void navigate({
      search: (previous) => ({ ...previous, [key]: value === ALL ? undefined : value, page: 1 }),
    })

  const tableKey = 'pos-orders'
  defineTable<PosOrderRow>(tableKey, {
    searchParam: 'number',
    searchPlaceholder: t('ordersNumber'),
    defaultSort: { field: 'placed_at', direction: 'desc' },
    emptyMessage: t('ordersEmpty'),
    columns: [
      {
        key: 'number',
        label: t('ordersNumber'),
        default: true,
        render: (order) => {
          const source = orderSourceOf(order.order_source)
          return (
            <ResourceNameCell
              id={order.id}
              dataAttr="data-pos-order-id"
              name={order.number}
              secondary={source === 'counter' ? undefined : t(orderSourceKey(source))}
            />
          )
        },
      },
      {
        key: 'placed_at',
        label: t('ordersPlacedAt'),
        default: true,
        filterable: true,
        filterType: 'date',
        quickFilter: true,
        className: 'whitespace-nowrap',
        render: (order) => formatInstant(order.placed_at, i18n.language, timeZone),
      },
      {
        key: 'register',
        label: t('ordersRegister'),
        default: true,
        render: (order) => order.register ?? '—',
      },
      { key: 'cashier', label: t('ordersCashier'), default: true },
      {
        key: 'customer',
        label: t('ordersCustomer'),
        default: true,
        render: (order) => order.customer?.name || t('customerWalkIn'),
      },
      {
        key: 'flags',
        label: t('ordersStatus'),
        default: true,
        render: (order) => <OrderTags order={order} />,
      },
      {
        key: 'total',
        label: t('orderTotal'),
        default: true,
        className: 'text-right tabular-nums',
        render: (order) => formatMoney(order.total, order.currency),
      },
      ...hiddenTimestamps<PosOrderRow>(),
    ],
  })

  return (
    <ResourceTable<PosOrderRow>
      tableKey={tableKey}
      hideHeader
      queryKey={['pos', 'orders', branchId, filters]}
      queryFn={async (params: Record<string, unknown>) => {
        const page = await fetchOrders(branchId, filters, params)
        remember(page.data)
        return page
      }}
      searchParams={search}
      actions={
        <>
          <FilterSelect
            label={t('ordersStatus')}
            value={filters.status}
            options={ORDER_STATUSES.map((value) => ({
              value,
              label: t(value === 'all' ? 'ordersAllStatuses' : `ordersStatus_${value}`),
            }))}
            onChange={(value) => choose('status', value)}
          />
          {registers.length > 0 && (
            <FilterSelect
              label={t('ordersRegister')}
              value={filters.registerId ?? ALL}
              options={[
                { value: ALL, label: t('ordersAllRegisters') },
                ...registers.map((register) => ({ value: register.id, label: register.name })),
              ]}
              onChange={(value) => choose('registerId', value)}
            />
          )}
          {(Object.keys(cashiers).length > 0 || filters.cashierId) && (
            <FilterSelect
              label={t('ordersCashier')}
              value={filters.cashierId ?? ALL}
              options={[
                { value: ALL, label: t('ordersAllCashiers') },
                ...Object.entries(cashiers).map(([value, label]) => ({ value, label })),
                ...(filters.cashierId && !cashiers[filters.cashierId]
                  ? [{ value: filters.cashierId, label: filters.cashierId }]
                  : []),
              ]}
              onChange={(value) => choose('cashierId', value)}
            />
          )}
        </>
      }
      rowActions={(order) => (
        <RowActions
          actions={[{ key: 'view', label: t('orderOpen'), onSelect: () => open(order.id) }]}
        />
      )}
    />
  )
}
