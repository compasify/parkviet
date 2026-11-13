import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { describeCreditFailure, parseDueDays } from '@parkviet/pos-shared/receivables'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosCreditAccount, PosCustomerProfile } from '@parkviet/pos-shared/types/pos-context'
import { defineTable, PageHeader, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Dialog,
  DialogBody,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Input,
  Label,
  ResourceNameCell,
  RowActions,
  useConfirm,
} from '@spree/dashboard-ui'
import { PlusIcon } from '@spree/dashboard-ui/icons'
import { useSearch } from '@tanstack/react-router'
import { useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import {
  type CreditTermsInput,
  fetchCreditAccounts,
  useConfigureCredit,
  useCustomerSearch,
} from '../hooks/use-debts'
import { usePosSession } from '../hooks/use-pos-session'
import { hiddenTimestamps } from '../tables/columns'

type Editing = { kind: 'create' } | { kind: 'edit'; account: PosCreditAccount }
type Notice = { text: string; failed: boolean } | null

// "Tài khoản nợ": customers allowed to buy on credit at the selected branch,
// with their limit, due days and what is owed or reserved. Credit managers
// open accounts, change terms and suspend or reactivate them.
export function CreditAccountsPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('creditAccountsTitle')}
        description={t('creditAccountsHint')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <CreditAccounts key={branchId} branchId={branchId} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function CreditAccounts({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const { context, selection } = usePosSession()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const confirm = useConfirm()
  const configure = useConfigureCredit()
  const [editing, setEditing] = useState<Editing | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const locked = writesLocked(context.data, selection) || configure.isPending

  async function save(input: Omit<CreditTermsInput, 'branchId'>): Promise<boolean> {
    setNotice(null)
    try {
      const account = await configure.mutateAsync({ ...input, branchId })
      setNotice({ text: t('creditSaved', { name: account.customer_name }), failed: false })
      return true
    } catch (failure) {
      setNotice({ text: describeCreditFailure(failure, t), failed: true })
      return false
    }
  }

  const tableKey = 'pos-credit-accounts'
  defineTable<PosCreditAccount>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('creditAccountsSearch'),
    emptyMessage: t('creditAccountsEmpty'),
    columns: [
      {
        key: 'customer_name',
        label: t('creditCustomer'),
        default: true,
        render: (account) => (
          <ResourceNameCell
            id={account.id}
            name={account.customer_name}
            secondary={account.customer_phone ?? undefined}
          />
        ),
      },
      {
        key: 'status',
        label: t('creditAccountStatusLabel'),
        default: true,
        render: (account) => (
          <Badge variant={account.status === 'suspended' ? 'warning' : 'secondary'}>
            {t(`creditAccountStatus_${account.status}`)}
          </Badge>
        ),
      },
      {
        key: 'credit_limit',
        label: t('creditLimit'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (account) => formatMoney(account.credit_limit, account.currency),
      },
      {
        key: 'due_days',
        label: t('creditDueDays'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
      },
      ...(
        [
          ['open_debt', 'creditOpenDebt'],
          ['reserved', 'creditReserved'],
          ['available', 'creditAvailable'],
        ] as const
      ).map(([key, label]) => ({
        key,
        label: t(label),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (account: PosCreditAccount) => formatMoney(account[key], account.currency),
      })),
      ...hiddenTimestamps<PosCreditAccount>(),
    ],
  })

  return (
    <>
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      <ResourceTable<PosCreditAccount>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'credit-accounts', branchId]}
        queryFn={(params: Record<string, unknown>) => fetchCreditAccounts(branchId, params)}
        searchParams={search}
        actions={
          <Button disabled={locked} onClick={() => setEditing({ kind: 'create' })}>
            <PlusIcon className="size-4" />
            {t('creditAccountCreate')}
          </Button>
        }
        rowActions={(account) => {
          const suspended = account.status === 'suspended'
          return (
            <RowActions
              actions={[
                {
                  key: 'edit',
                  label: t('creditEdit'),
                  disabled: locked,
                  onSelect: () => setEditing({ kind: 'edit', account }),
                },
                {
                  key: 'status',
                  label: t(suspended ? 'creditActivate' : 'creditSuspend'),
                  destructive: !suspended,
                  disabled: locked,
                  onSelect: async () => {
                    if (
                      !suspended &&
                      !(await confirm({
                        message: t('creditSuspendConfirm', { name: account.customer_name }),
                        variant: 'destructive',
                        confirmLabel: t('creditSuspend'),
                        cancelLabel: t('adminCancel'),
                      }))
                    )
                      return
                    await save({
                      accountId: account.id,
                      status: suspended ? 'active' : 'suspended',
                    })
                  },
                },
              ]}
            />
          )
        }}
      />
      {editing && (
        <TermsDialog
          editing={editing}
          branchId={branchId}
          busy={configure.isPending}
          onClose={() => setEditing(null)}
          onSave={async (input) => {
            if (await save(input)) setEditing(null)
          }}
        />
      )}
    </>
  )
}

// Opens an account for a customer found by name or phone, or changes the
// limit and due days of an existing one.
function TermsDialog({
  editing,
  branchId,
  busy,
  onClose,
  onSave,
}: {
  editing: Editing
  branchId: string
  busy: boolean
  onClose: () => void
  onSave: (input: Omit<CreditTermsInput, 'branchId'>) => Promise<void>
}) {
  const { t } = useTranslation()
  const ids = useId()
  const account = editing.kind === 'edit' ? editing.account : null
  const [customer, setCustomer] = useState<PosCustomerProfile | null>(null)
  const [query, setQuery] = useState('')
  const [limit, setLimit] = useState(account ? (parseVndAmount(account.credit_limit) ?? '') : '')
  const [days, setDays] = useState(account ? String(account.due_days) : '30')
  const results = useCustomerSearch(account || customer ? null : branchId, query)
  const parsedLimit = parseVndInput(limit)
  const parsedDays = parseDueDays(days)
  const ready = parsedLimit !== null && parsedDays !== null && (account || customer)
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>
            {account
              ? t('creditEditTerms', { name: account.customer_name })
              : t('creditAccountCreate')}
          </DialogTitle>
        </DialogHeader>
        <form
          className="flex min-h-0 flex-col"
          onSubmit={(event) => {
            event.preventDefault()
            if (parsedLimit === null || parsedDays === null) return
            if (account)
              void onSave({ accountId: account.id, creditLimit: parsedLimit, dueDays: parsedDays })
            else if (customer)
              void onSave({
                customerId: customer.id,
                creditLimit: parsedLimit,
                dueDays: parsedDays,
              })
          }}
        >
          <DialogBody className="space-y-4">
            {!account &&
              (customer ? (
                <p>
                  {t('creditCustomer')}: <strong>{customer.name}</strong> {customer.phone ?? ''}{' '}
                  <Button
                    type="button"
                    variant="link"
                    disabled={busy}
                    onClick={() => setCustomer(null)}
                  >
                    {t('creditChangeCustomer')}
                  </Button>
                </p>
              ) : (
                <div className="grid gap-1">
                  <Label htmlFor={`${ids}-search`}>{t('creditCustomerSearch')}</Label>
                  <Input
                    id={`${ids}-search`}
                    type="search"
                    value={query}
                    autoComplete="off"
                    disabled={busy}
                    onChange={(event) => setQuery(event.target.value)}
                  />
                  {results.isError && (
                    <p role="alert" className="text-sm text-destructive">
                      {describeFailure(results.error, t)}
                    </p>
                  )}
                  <ul className="grid gap-1" aria-label={t('creditCustomerResults')}>
                    {(results.data?.data ?? []).map((profile) => (
                      <li key={profile.id}>
                        <Button
                          type="button"
                          variant="ghost"
                          className="w-full justify-start"
                          disabled={busy}
                          onClick={() => setCustomer(profile)}
                        >
                          {profile.name} {profile.phone ?? ''}
                        </Button>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-limit`}>{t('creditLimit')}</Label>
              <Input
                id={`${ids}-limit`}
                inputMode="numeric"
                autoComplete="off"
                value={limit}
                required
                aria-invalid={limit.trim() !== '' && parsedLimit === null}
                disabled={busy}
                onChange={(event) => setLimit(event.target.value)}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-days`}>{t('creditDueDays')}</Label>
              <Input
                id={`${ids}-days`}
                inputMode="numeric"
                autoComplete="off"
                value={days}
                required
                aria-invalid={days.trim() !== '' && parsedDays === null}
                aria-describedby={`${ids}-days-hint`}
                disabled={busy}
                onChange={(event) => setDays(event.target.value)}
              />
              <p id={`${ids}-days-hint`} className="text-sm text-muted-foreground">
                {t('creditDueDaysHint')}
              </p>
            </div>
          </DialogBody>
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !ready}>
              {t(account ? 'creditSaveTerms' : 'creditAccountCreate')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
