import { shortDate } from '@parkviet/pos-shared/debt-reminder'
import { formatMoney } from '@parkviet/pos-shared/money'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosReceivable, PosReceivableAccount } from '@parkviet/pos-shared/types/pos-context'
import { defineTable, PageHeader, ResourceTable } from '@spree/dashboard-core'
import { Button, ResourceNameCell, RowActions, useRowClickBridge } from '@spree/dashboard-ui'
import { HandCoinsIcon, RotateCcwIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { DebtorSheet, DueBadge, OverdueBadge } from '../components/debtor-sheet'
import { FilterSelect } from '../components/filter-select'
import { PillTabs } from '../components/pill-tabs'
import { ModelCard } from '../components/setup/model-ui'
import {
  debtorList,
  fetchReceivables,
  RECEIVABLE_STATUSES,
  type ReceivableAccounts,
  type ReceivableStatus,
  receivableAccountsQuery,
  useReceivableAccounts,
} from '../hooks/use-debts'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { receivableSearchSchema } from '../schemas/list-search'
import { hiddenTimestamps } from '../tables/columns'

const AGING = ['current', 'days_1_30', 'days_31_60', 'days_61_90', 'days_over_90'] as const
type View = 'customers' | 'orders'

// "Công nợ phải thu": who owes the selected branch and for which sales, with
// the aging of the total. A customer opens beside the list with their open
// debts and the reminder that can be shared or copied. Collecting money
// stays at the counter, where it lands in the collector's own shift.
export function ReceivablesPage({ view }: { view: View }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const base = `/${storeId}/receivables`
  const tabs = [
    { key: 'customers', label: t('receivablesCustomers'), to: base },
    { key: 'orders', label: t('receivablesOrders'), to: `${base}/orders` },
  ]
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('receivablesTitle')}
        description={t('receivablesHint')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <Receivables key={`${branchId}:${view}`} branchId={branchId} view={view}>
          <PillTabs tabs={tabs} />
        </Receivables>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function Receivables({
  branchId,
  view,
  children,
}: {
  branchId: string
  view: View
  children: React.ReactNode
}) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const client = useQueryClient()
  const navigate = useNavigate()
  const search = receivableSearchSchema.parse(useSearch({ strict: false }))
  const accounts = useReceivableAccounts(branchId)
  const currency = context.data?.store.currency ?? 'VND'
  const totals = accounts.data?.meta.totals
  const open = useCallback(
    (id: string) =>
      void navigate({
        to: '.',
        search: (previous: Record<string, unknown>) => ({ ...previous, accountId: id }),
      }),
    [navigate],
  )
  useRowClickBridge('data-pos-debtor-id', open)
  const selected = accounts.data?.data.find((row) => row.credit_account_id === search.accountId)
  const refresh = (
    <Button
      variant="outline"
      onClick={() => void client.invalidateQueries({ queryKey: ['pos', storeId, 'receivables'] })}
    >
      <RotateCcwIcon className="size-4" />
      {t('refresh')}
    </Button>
  )
  return (
    <>
      {accounts.isError ? (
        <div role="alert" className="space-y-2">
          <p>{describeFailure(accounts.error, t)}</p>
          <Button variant="outline" onClick={() => void accounts.refetch()}>
            {t('retry')}
          </Button>
        </div>
      ) : totals ? (
        <ModelCard
          title={`${t('receivablesTotal')}: ${formatMoney(totals.balance, currency)} · ${t('receivablesOverdue')}: ${formatMoney(totals.overdue, currency)}`}
          id="receivables-aging"
          icon={<HandCoinsIcon />}
        >
          <dl className="grid grid-cols-2 gap-3 sm:grid-cols-5" aria-label={t('receivablesAging')}>
            {AGING.map((bucket) => (
              <div key={bucket}>
                <dt className="text-sm text-muted-foreground">{t(`aging_${bucket}`)}</dt>
                <dd className="font-medium tabular-nums">
                  {formatMoney(totals[bucket], currency)}
                </dd>
              </div>
            ))}
          </dl>
        </ModelCard>
      ) : null}
      {children}
      {view === 'customers' ? (
        <DebtorsTable branchId={branchId} accounts={accounts.data} actions={refresh} open={open} />
      ) : (
        <DebtsTable branchId={branchId} actions={refresh} />
      )}
      {search.accountId && (
        <DebtorSheet
          key={search.accountId}
          branchId={branchId}
          account={selected ?? null}
          loading={accounts.isPending}
          onClose={() =>
            void navigate({
              to: '.',
              search: (previous: Record<string, unknown>) => ({
                ...previous,
                accountId: undefined,
              }),
            })
          }
        />
      )}
    </>
  )
}

function DebtorsTable({
  branchId,
  accounts,
  actions,
  open,
}: {
  branchId: string
  accounts: ReceivableAccounts | undefined
  actions: React.ReactNode
  open: (id: string) => void
}) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const client = useQueryClient()
  const search = receivableSearchSchema.parse(useSearch({ strict: false }))
  const timeZone = branchTimeZone(context.data)
  const tableKey = 'pos-debtors'
  defineTable<PosReceivableAccount>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('debtorsSearch'),
    emptyMessage: t(accounts && accounts.data.length > 0 ? 'debtorsNoMatch' : 'receivablesEmpty'),
    columns: [
      {
        key: 'customer',
        label: t('receivablesCustomers'),
        default: true,
        sortable: false,
        render: (account) => (
          <ResourceNameCell
            id={account.credit_account_id}
            dataAttr="data-pos-debtor-id"
            name={account.customer.name}
            secondary={[
              account.customer.phone,
              t('receivablesOrderCount', { count: account.orders }),
              account.oldest_placed_at
                ? t('debtorsSince', {
                    date: shortDate(account.oldest_placed_at),
                    count: account.days_owed ?? 0,
                  })
                : null,
            ]
              .filter(Boolean)
              .join(' · ')}
          />
        ),
      },
      {
        key: 'overdue',
        label: t('receivablesOverdue'),
        default: true,
        sortable: false,
        render: (account) => <OverdueBadge account={account} />,
      },
      {
        key: 'last_reminded_at',
        label: t('debtorsLastRemindedLabel'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (account) =>
          account.last_reminded_at
            ? formatInstant(account.last_reminded_at, i18n.language, timeZone)
            : t('debtorsNeverReminded'),
      },
      {
        key: 'balance',
        label: t('receivablesBalance'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (account) => formatMoney(account.balance, account.currency),
      },
      ...hiddenTimestamps<PosReceivableAccount>(),
    ],
  })
  return (
    <ResourceTable<PosReceivableAccount>
      tableKey={tableKey}
      hideHeader
      queryKey={['pos', 'receivables', branchId, 'accounts', 'table']}
      queryFn={async (params: Record<string, unknown>) =>
        debtorList(await client.fetchQuery(receivableAccountsQuery(storeId, branchId)), params)
      }
      searchParams={search}
      actions={actions}
      rowActions={(account) => (
        <RowActions
          actions={[
            {
              key: 'view',
              label: t('receivablesOpenCustomer'),
              onSelect: () => open(account.credit_account_id),
            },
          ]}
        />
      )}
    />
  )
}

function DebtsTable({ branchId, actions }: { branchId: string; actions: React.ReactNode }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const search = receivableSearchSchema.parse(useSearch({ strict: false }))
  const status = search.status ?? 'open'
  const tableKey = 'pos-receivables'
  defineTable<PosReceivable>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('receivablesSearch'),
    emptyMessage: t('receivablesEmpty'),
    columns: [
      {
        key: 'order_number',
        label: t('receivablesOrders'),
        default: true,
        sortable: false,
        render: (debt) => (
          <ResourceNameCell
            id={debt.order_id}
            name={debt.order_number}
            secondary={[debt.customer.name, debt.customer.phone].filter(Boolean).join(' · ')}
          />
        ),
      },
      {
        key: 'due_on',
        label: t('receivablesDue'),
        default: true,
        sortable: false,
        render: (debt) => <DueBadge debt={debt} />,
      },
      ...(
        [
          ['original_total', 'receivablesOriginal'],
          ['paid_at_sale', 'receivablesPaidAtSale'],
          ['collected', 'receivablesCollected'],
          ['balance', 'receivablesBalance'],
        ] as const
      ).map(([key, label]) => ({
        key,
        label: t(label),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (debt: PosReceivable) => formatMoney(debt[key], debt.currency),
      })),
      ...hiddenTimestamps<PosReceivable>(),
    ],
  })
  return (
    <ResourceTable<PosReceivable>
      tableKey={tableKey}
      hideHeader
      queryKey={['pos', 'receivables', branchId, 'orders', status]}
      queryFn={async (params: Record<string, unknown>) => {
        // The server pages debts and has no text search: the search box
        // narrows the loaded page by order number or customer.
        const page = await fetchReceivables(branchId, { status }, params)
        const term = String(params.search ?? '')
          .trim()
          .toLocaleLowerCase()
        return term
          ? {
              ...page,
              data: page.data.filter((debt) =>
                [debt.order_number, debt.customer.name, debt.customer.phone]
                  .join(' ')
                  .toLocaleLowerCase()
                  .includes(term),
              ),
            }
          : page
      }}
      searchParams={search}
      actions={
        <>
          <FilterSelect
            label={t('receivablesStatus')}
            value={status}
            options={RECEIVABLE_STATUSES.map((value) => ({
              value,
              label: t(`receivablesStatus_${value}`),
            }))}
            onChange={(value) =>
              void navigate({
                to: '.',
                search: (previous: Record<string, unknown>) => ({
                  ...previous,
                  status: value as ReceivableStatus,
                  page: undefined,
                }),
              })
            }
          />
          {actions}
        </>
      }
      rowActions={(debt) => (
        <RowActions
          actions={[
            {
              key: 'customer',
              label: t('receivablesOpenCustomer'),
              onSelect: () =>
                void navigate({
                  to: '.',
                  search: (previous: Record<string, unknown>) => ({
                    ...previous,
                    accountId: debt.credit_account_id,
                  }),
                }),
            },
          ]}
        />
      )}
    />
  )
}
