import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { Badge, Button, Skeleton } from '@spree/dashboard-ui'
import {
  ArrowLeftRightIcon,
  BanknoteIcon,
  ClockIcon,
  HandCoinsIcon,
  RotateCcwIcon,
  TruckIcon,
} from '@spree/dashboard-ui/icons'
import type { UseQueryResult } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { PageSkeleton } from '../components/page-skeleton'
import { ModelCard } from '../components/setup/model-ui'
import {
  type AttentionCount,
  useCashRequestsAttention,
  useCreditRequestsAttention,
  useFundsAttention,
  useOpenShiftsAttention,
} from '../hooks/use-attention'
import { usePendingDeliveryCount } from '../hooks/use-deliveries'
import { useRefundPendingCount } from '../hooks/use-orders'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { canReadOrders, hasCapability, type PosAccess } from '../lib/pos-access'

type Item = {
  key: string
  titleKey: string
  hintKey: string
  icon: ReactNode
  visible: boolean
  query: UseQueryResult<AttentionCount | number>
  // Dashboard path below the store; items whose screen is not here yet have none.
  to?: string
}

// "Việc cần xử lý": what is waiting for the reader at the selected branch,
// limited to what their branch capabilities let them act on.
export function HomePage() {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const data = context.data
  const access: PosAccess = { permissionKeys, context: data }
  const branchId = data?.selection.branch_id ?? null
  const has = (capability: string) => hasCapability(access, capability)
  const funds = has('pos.payment.resolve')
  const credit = has('pos.approval.grant') && has('pos.credit.manage')
  const cash = has('pos.cash.move') || has('pos.approval.grant')
  const shifts = has('pos.topology.recover')
  const deliveries = canHandleDeliveries(data?.capabilities)
  const orders = canReadOrders(access)
  const items: Item[] = [
    {
      key: 'funds',
      titleKey: 'fundsAttentionTitle',
      hintKey: 'attention.fundsHint',
      icon: <BanknoteIcon />,
      visible: funds,
      query: useFundsAttention(branchId, funds),
      to: '/funds/attention',
    },
    {
      key: 'credit',
      titleKey: 'creditApprovalsTitle',
      hintKey: 'attention.creditHint',
      icon: <HandCoinsIcon />,
      visible: credit,
      query: useCreditRequestsAttention(branchId, credit),
      to: '/credit-approvals',
    },
    {
      key: 'cash',
      titleKey: 'cashRequestsTitle',
      hintKey: 'attention.cashHint',
      icon: <ArrowLeftRightIcon />,
      visible: cash,
      query: useCashRequestsAttention(branchId, data?.staff.id ?? null, cash),
      to: '/shifts',
    },
    {
      key: 'shifts',
      titleKey: 'attention.openShifts',
      hintKey: 'attention.openShiftsHint',
      icon: <ClockIcon />,
      visible: shifts,
      query: useOpenShiftsAttention(branchId, data?.shift?.id ?? null, shifts),
      to: '/shifts',
    },
    {
      key: 'deliveries',
      titleKey: 'attention.deliveries',
      hintKey: 'attention.deliveriesHint',
      icon: <TruckIcon />,
      visible: deliveries,
      query: usePendingDeliveryCount(branchId, deliveries),
      to: '/deliveries',
    },
    {
      key: 'refunds',
      titleKey: 'ordersStatus_refund_pending',
      hintKey: 'attention.refundsHint',
      icon: <RotateCcwIcon />,
      visible: orders,
      query: useRefundPendingCount(branchId, orders),
      to: '/orders?status=refund_pending',
    },
  ].filter((item) => item.visible)
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('attention.title')}
        description={t('attention.hint')}
        actions={<BranchPicker />}
      />
      {context.isPending ? (
        <PageSkeleton variant="cards" />
      ) : context.isError ? (
        <div role="alert">
          {describeFailure(context.error, t)}
          <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
        </div>
      ) : !branchId ? (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      ) : items.length === 0 ? (
        <p className="text-muted-foreground">{t('attention.nothing')}</p>
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3" aria-label={t('attention.title')}>
          {items.map((item) => (
            <li key={item.key}>
              <AttentionCard item={item} storeId={storeId} />
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function AttentionCard({ item, storeId }: { item: Item; storeId: string }) {
  const { t } = useTranslation()
  const { query } = item
  const value = query.data
  const count = typeof value === 'number' ? value : value?.count
  const more = typeof value === 'object' && value.more
  const title = t(item.titleKey)
  return (
    <ModelCard title={title} id={`attention-${item.key}`} icon={item.icon} className="h-full">
      <p className="text-sm text-muted-foreground">{t(item.hintKey)}</p>
      <div className="flex items-center justify-between gap-3">
        {query.isError ? (
          <p role="alert" className="text-destructive">
            {describeFailure(query.error, t)}
          </p>
        ) : count === undefined ? (
          <Skeleton role="status" aria-label={t('waiting')} className="h-9 w-14" />
        ) : (
          <p className="flex items-center gap-2">
            <span className="text-3xl font-semibold tabular-nums" data-testid="attention-count">
              {more ? `${count}+` : count}
            </span>
            {count > 0 && <Badge variant="warning">{t('attention.waiting')}</Badge>}
          </p>
        )}
        {item.to && (
          <Button variant="outline" size="sm" asChild>
            <Link to={`/${storeId}${item.to}` as string}>{t('attention.open')}</Link>
          </Button>
        )}
      </div>
    </ModelCard>
  )
}
