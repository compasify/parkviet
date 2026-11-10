import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@spree/dashboard-ui'
import type { UseQueryResult } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
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
      visible: funds,
      query: useFundsAttention(branchId, funds),
    },
    {
      key: 'credit',
      titleKey: 'creditApprovalsTitle',
      hintKey: 'attention.creditHint',
      visible: credit,
      query: useCreditRequestsAttention(branchId, credit),
    },
    {
      key: 'cash',
      titleKey: 'cashRequestsTitle',
      hintKey: 'attention.cashHint',
      visible: cash,
      query: useCashRequestsAttention(branchId, data?.staff.id ?? null, cash),
    },
    {
      key: 'shifts',
      titleKey: 'attention.openShifts',
      hintKey: 'attention.openShiftsHint',
      visible: shifts,
      query: useOpenShiftsAttention(branchId, data?.shift?.id ?? null, shifts),
    },
    {
      key: 'deliveries',
      titleKey: 'attention.deliveries',
      hintKey: 'attention.deliveriesHint',
      visible: deliveries,
      query: usePendingDeliveryCount(branchId, deliveries),
      to: '/deliveries',
    },
    {
      key: 'refunds',
      titleKey: 'ordersStatus_refund_pending',
      hintKey: 'attention.refundsHint',
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
        <p role="status">{t('contextWaiting')}</p>
      ) : context.isError ? (
        <div role="alert">
          {describeFailure(context.error, t)}
          <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
        </div>
      ) : !branchId ? (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      ) : items.length === 0 ? (
        <Card>
          <CardContent className="pt-6 text-muted-foreground">{t('attention.nothing')}</CardContent>
        </Card>
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
    <Card className="h-full" aria-label={title}>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>{t(item.hintKey)}</CardDescription>
      </CardHeader>
      <CardContent className="flex items-center justify-between gap-3">
        {query.isError ? (
          <p role="alert" className="text-destructive">
            {describeFailure(query.error, t)}
          </p>
        ) : count === undefined ? (
          <p role="status" className="text-muted-foreground">
            {t('waiting')}
          </p>
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
      </CardContent>
    </Card>
  )
}
