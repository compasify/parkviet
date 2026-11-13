import { formatMoney } from '@parkviet/pos-shared/money'
import type { PosReceivedFunds } from '@parkviet/pos-shared/types/pos-context'
import { defineTable, PageHeader, ResourceTable, usePermissions } from '@spree/dashboard-core'
import { Badge, Button, ResourceNameCell, RowActions, useRowClickBridge } from '@spree/dashboard-ui'
import { RotateCcwIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { FundsDetailSheet } from '../components/funds-detail-sheet'
import { PillTabs } from '../components/pill-tabs'
import { fetchFunds, fetchFundsAttention } from '../hooks/use-funds'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { hasCapability } from '../lib/pos-access'
import { fundsSearchSchema } from '../schemas/list-search'
import { hiddenTimestamps } from '../tables/columns'

// "Sổ tiền": money received at the selected branch, and the "Cần chú ý"
// view of what is not fully applied or not yet identified. Resolvers open a
// record to allocate it by hand at the counter or pay it back to a
// beneficiary; collectors read the ledger only.
export function FundsPage({ attention }: { attention: boolean }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const resolver = hasCapability({ permissionKeys, context: context.data }, 'pos.payment.resolve')
  const base = `/${storeId}/funds`
  const tabs = [
    { key: 'ledger', label: t('fundsNav'), to: base },
    { key: 'attention', label: t('attentionNav'), to: `${base}/attention` },
  ]
  return (
    <div className="space-y-6">
      <PageHeader
        title={t(attention ? 'fundsAttentionTitle' : 'fundsTitle')}
        description={t(attention ? 'fundsAttentionHint' : 'fundsHint')}
        actions={<BranchPicker />}
      />
      {resolver && <PillTabs tabs={tabs} />}
      {branchId ? (
        <FundsTable key={`${branchId}:${attention}`} branchId={branchId} attention={attention} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
      <p className="text-sm text-muted-foreground">{t('fundsManualReconcile')}</p>
    </div>
  )
}

function FundsTable({ branchId, attention }: { branchId: string; attention: boolean }) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const client = useQueryClient()
  const navigate = useNavigate()
  const search = fundsSearchSchema.parse(useSearch({ strict: false }))
  const timeZone = branchTimeZone(context.data)
  const open = useCallback(
    (id: string) =>
      void navigate({
        to: '.',
        search: (previous: Record<string, unknown>) => ({ ...previous, fundsId: id }),
      }),
    [navigate],
  )
  useRowClickBridge('data-pos-funds-id', open)

  const tableKey = attention ? 'pos-funds-attention' : 'pos-funds'
  defineTable<PosReceivedFunds>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('fundsSearch'),
    defaultSort: { field: 'received_at', direction: 'desc' },
    emptyMessage: t(attention ? 'fundsAttentionEmpty' : 'fundsEmpty'),
    columns: [
      {
        key: 'kind',
        label: t('fundsKind'),
        default: true,
        sortable: false,
        render: (fund) => (
          <ResourceNameCell
            id={fund.id}
            dataAttr="data-pos-funds-id"
            name={t(fund.kind === 'cash' ? 'cash' : 'bankTransfer')}
            secondary={fund.reference || fund.id}
          />
        ),
      },
      {
        key: 'status',
        label: t('fundsStatus'),
        default: true,
        sortable: false,
        render: (fund) => (
          <Badge variant={fund.status === 'attention' ? 'warning' : 'secondary'}>
            {t(`fundStatus_${fund.status}`)}
          </Badge>
        ),
      },
      {
        key: 'received_at',
        label: t('fundsReceivedAt'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (fund) => formatInstant(fund.received_at, i18n.language, timeZone),
      },
      {
        key: 'received_net',
        label: t('fundsReceived'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (fund) => formatMoney(fund.received_net, fund.currency),
      },
      {
        key: 'available',
        label: t('fundsAvailableShort'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (fund) => formatMoney(fund.available, fund.currency),
      },
      ...hiddenTimestamps<PosReceivedFunds>(),
    ],
  })

  return (
    <>
      <ResourceTable<PosReceivedFunds>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'received-funds', branchId, attention ? 'attention' : 'ledger']}
        queryFn={async (params: Record<string, unknown>) => {
          if (attention) return fetchFundsAttention(branchId, params)
          // The ledger pages on the server, which has no text search: the
          // search box narrows the loaded page by reference or id.
          const page = await fetchFunds(branchId, params)
          const term = String(params.search ?? '')
            .trim()
            .toLocaleLowerCase()
          return term
            ? {
                ...page,
                data: page.data.filter((fund) =>
                  [fund.reference, fund.id].join(' ').toLocaleLowerCase().includes(term),
                ),
              }
            : page
        }}
        searchParams={search}
        actions={
          <Button
            variant="outline"
            onClick={() =>
              void client.invalidateQueries({ queryKey: ['pos', storeId, 'received-funds'] })
            }
          >
            <RotateCcwIcon className="size-4" />
            {t('refresh')}
          </Button>
        }
        rowActions={(fund) => (
          <RowActions
            actions={[{ key: 'view', label: t('fundsDetail'), onSelect: () => open(fund.id) }]}
          />
        )}
      />
      {search.fundsId && (
        <FundsDetailSheet
          key={search.fundsId}
          fundsId={search.fundsId}
          branchId={branchId}
          onClose={() =>
            void navigate({
              to: '.',
              search: (previous: Record<string, unknown>) => ({ ...previous, fundsId: undefined }),
            })
          }
        />
      )}
    </>
  )
}
