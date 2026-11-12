import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { defineTable, PageHeader, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Input,
  Label,
  ResourceNameCell,
  RowActions,
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { PlusIcon, UploadIcon } from '@spree/dashboard-ui/icons'
import { useSearch } from '@tanstack/react-router'
import { useCallback, useId, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { FilterSelect } from '../components/filter-select'
import { ModelSelect } from '../components/setup/model-ui'
import {
  fetchMealAccounts,
  type MealAccountFilters,
  type MealAccountInput,
  useImportMealAccounts,
  useMealEntries,
  useMealSponsors,
  useSaveMealAccount,
} from '../hooks/use-meal-accounts'
import { usePosSession } from '../hooks/use-pos-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import {
  describeMealFailure,
  type ImportProblem,
  importProblems,
  MAX_DAILY_MEALS,
  MAX_IMPORT_BYTES,
  MAX_MEAL_WINDOWS,
  MEAL_ACCOUNT_STATUSES,
  MEAL_IMPORT_HEADER,
  MEAL_PAY_MODES,
  type MealAccount,
  type MealAccountStatus,
  type MealPayMode,
  type MealWindow,
  type MealWindowDraft,
  parseMealWindows,
  refusedField,
  validEmployeeCode,
  wholeNumber,
  windowDraft,
  windowDraftValid,
} from '../lib/meal-accounts'
import { hiddenTimestamps } from '../tables/columns'

// The "all" choice of a single-choice filter; no filter value uses it.
const ALL = '*'
const NONE = ''
type Editing = { kind: 'create' } | { kind: 'edit'; account: MealAccount }
type Notice = { text: string; failed: boolean } | null
type Translate = (key: string, options?: Record<string, unknown>) => string

// "Tài khoản suất ăn": the canteen's eaters, found by employee or student
// code, name or group, with who pays for their meals, their daily rules and
// their wallet balance. Managers add, import, change, lock and unlock them;
// the wallet history is read here while top-ups, refunds and corrections
// happen at the counter.
export function MealAccountsPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('mealAccounts.title')}
        description={t('mealAccounts.intro')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <MealAccounts key={branchId} branchId={branchId} />
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function MealAccounts({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const { context, selection } = usePosSession()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const confirm = useConfirm()
  const save = useSaveMealAccount(branchId)
  const sponsors = useMealSponsors(branchId)
  const [filters, setFilters] = useState<MealAccountFilters>({})
  const [editing, setEditing] = useState<Editing | null>(null)
  const [importing, setImporting] = useState(false)
  const [history, setHistory] = useState<MealAccount | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const loaded = useRef(new Map<string, MealAccount>())
  const locked = writesLocked(context.data, selection) || save.isPending
  const sponsorRows = sponsors.data?.data ?? []

  const open = useCallback((id: string) => {
    const account = loaded.current.get(id)
    if (account) setHistory(account)
  }, [])
  useRowClickBridge('data-pos-meal-account-id', open)

  async function setStatus(account: MealAccount, status: MealAccountStatus) {
    setNotice(null)
    try {
      await save.mutateAsync({ accountId: account.id, values: { status } })
      setNotice({
        text: t(status === 'locked' ? 'mealAccounts.lockedDone' : 'mealAccounts.unlockedDone', {
          code: account.employee_code,
        }),
        failed: false,
      })
    } catch (failure) {
      setNotice({ text: describeMealFailure(failure, t), failed: true })
    }
  }

  const tableKey = 'pos-meal-accounts'
  defineTable<MealAccount>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('mealAccounts.search'),
    emptyMessage: t('mealAccounts.empty'),
    columns: [
      {
        key: 'employee_code',
        label: t('mealAccounts.code'),
        default: true,
        sortable: false,
        filterable: false,
        render: (account) => (
          <ResourceNameCell
            id={account.id}
            dataAttr="data-pos-meal-account-id"
            name={account.employee_code}
            secondary={account.name ?? undefined}
          />
        ),
      },
      {
        key: 'group_label',
        label: t('mealAccounts.group'),
        default: true,
        sortable: false,
        filterable: false,
        render: (account) => account.group_label ?? '—',
      },
      {
        key: 'pay_mode',
        label: t('mealAccounts.payMode'),
        default: true,
        sortable: false,
        filterable: false,
        render: (account) => (
          <span className="flex flex-col">
            <span>{t(`mealAccounts.payMode_${account.pay_mode}`)}</span>
            {account.sponsor && (
              <span className="text-xs text-muted-foreground">{account.sponsor.name}</span>
            )}
          </span>
        ),
      },
      {
        key: 'daily_meal_limit',
        label: t('mealAccounts.dailyLimit'),
        default: true,
        sortable: false,
        filterable: false,
        className: 'text-right tabular-nums',
        render: (account) => account.daily_meal_limit ?? t('mealAccounts.noLimit'),
      },
      {
        key: 'balance',
        label: t('mealAccounts.balance'),
        default: true,
        sortable: false,
        filterable: false,
        className: 'text-right tabular-nums',
        render: (account) => formatMoney(account.balance, account.currency),
      },
      {
        key: 'status',
        label: t('mealAccounts.status'),
        default: true,
        sortable: false,
        filterable: false,
        render: (account) => (
          <Badge variant={account.status === 'locked' ? 'warning' : 'secondary'}>
            {t(`mealAccounts.status_${account.status}`)}
          </Badge>
        ),
      },
      ...hiddenTimestamps<MealAccount>(),
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
      <ResourceTable<MealAccount>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'meal-accounts', branchId, 'list', filters]}
        queryFn={async (params: Record<string, unknown>) => {
          const page = await fetchMealAccounts(branchId, filters, params)
          for (const account of page.data) loaded.current.set(account.id, account)
          return page
        }}
        searchParams={search}
        actions={
          <div className="flex flex-wrap items-center gap-2">
            <FilterSelect
              label={t('mealAccounts.status')}
              value={filters.status ?? ALL}
              options={[
                { value: ALL, label: t('mealAccounts.allStatuses') },
                ...MEAL_ACCOUNT_STATUSES.map((value) => ({
                  value,
                  label: t(`mealAccounts.status_${value}`),
                })),
              ]}
              onChange={(value) =>
                setFilters((current) => ({
                  ...current,
                  status: value === ALL ? undefined : (value as MealAccountStatus),
                }))
              }
            />
            <FilterSelect
              label={t('mealAccounts.sponsor')}
              value={filters.sponsorId ?? ALL}
              options={[
                { value: ALL, label: t('mealAccounts.allSponsors') },
                ...sponsorRows.map((row) => ({ value: row.id, label: row.name })),
              ]}
              onChange={(value) =>
                setFilters((current) => ({
                  ...current,
                  sponsorId: value === ALL ? undefined : value,
                }))
              }
            />
            <Button variant="outline" disabled={locked} onClick={() => setImporting(true)}>
              <UploadIcon className="size-4" />
              {t('mealAccounts.import')}
            </Button>
            <Button disabled={locked} onClick={() => setEditing({ kind: 'create' })}>
              <PlusIcon className="size-4" />
              {t('mealAccounts.create')}
            </Button>
          </div>
        }
        rowActions={(account) => {
          const isLocked = account.status === 'locked'
          return (
            <RowActions
              actions={[
                {
                  key: 'history',
                  label: t('mealAccounts.history'),
                  onSelect: () => setHistory(account),
                },
                {
                  key: 'edit',
                  label: t('mealAccounts.edit'),
                  disabled: locked,
                  onSelect: () => setEditing({ kind: 'edit', account }),
                },
                {
                  key: 'status',
                  label: t(isLocked ? 'mealAccounts.unlock' : 'mealAccounts.lock'),
                  destructive: !isLocked,
                  disabled: locked,
                  onSelect: async () => {
                    if (
                      !isLocked &&
                      !(await confirm({
                        message: t('mealAccounts.lockConfirm', { code: account.employee_code }),
                        variant: 'destructive',
                        confirmLabel: t('mealAccounts.lock'),
                        cancelLabel: t('adminCancel'),
                      }))
                    )
                      return
                    await setStatus(account, isLocked ? 'active' : 'locked')
                  },
                },
              ]}
            />
          )
        }}
      />
      {sponsors.isError && (
        <p role="alert" className="text-sm text-destructive">
          {describeFailure(sponsors.error, t)}
        </p>
      )}
      {editing && (
        <AccountDialog
          editing={editing}
          branchId={branchId}
          sponsors={sponsorRows.filter(
            (row) =>
              row.status === 'active' ||
              (editing.kind === 'edit' && row.id === editing.account.sponsor?.id),
          )}
          onClose={() => setEditing(null)}
          onSaved={(account) => {
            setEditing(null)
            setNotice({
              text: t('mealAccounts.saved', { code: account.employee_code }),
              failed: false,
            })
          }}
        />
      )}
      {importing && (
        <ImportDialog
          branchId={branchId}
          onClose={() => setImporting(false)}
          onImported={(result) => {
            setImporting(false)
            setNotice({ text: t('mealAccounts.imported', result), failed: false })
          }}
        />
      )}
      {history && (
        <HistorySheet branchId={branchId} account={history} onClose={() => setHistory(null)} />
      )}
    </>
  )
}

type AccountForm = {
  code: string
  name: string
  phone: string
  email: string
  group: string
  payMode: MealPayMode
  sponsorId: string
  dailyLimit: string
  threshold: string
  windows: MealWindowDraft[]
}

function accountForm(account: MealAccount | null): AccountForm {
  return {
    code: account?.employee_code ?? '',
    name: account?.name ?? '',
    phone: account?.phone ?? '',
    email: '',
    group: account?.group_label ?? '',
    payMode: account?.pay_mode ?? 'wallet',
    sponsorId: account?.sponsor?.id ?? NONE,
    dailyLimit: account?.daily_meal_limit == null ? '' : String(account.daily_meal_limit),
    threshold: account?.low_balance_threshold
      ? (parseVndAmount(account.low_balance_threshold) ?? '')
      : '',
    windows: (account?.meal_windows ?? []).map(windowDraft),
  }
}

// Adds an eater (a customer profile is made from the name and phone or
// email) or changes one: code, group, who pays, daily meals, meal times and
// the low-balance warning.
function AccountDialog({
  editing,
  branchId,
  sponsors,
  onClose,
  onSaved,
}: {
  editing: Editing
  branchId: string
  sponsors: { id: string; name: string }[]
  onClose: () => void
  onSaved: (account: MealAccount) => void
}) {
  const { t } = useTranslation()
  const ids = useId()
  const account = editing.kind === 'edit' ? editing.account : null
  const save = useSaveMealAccount(branchId)
  const [form, setForm] = useState<AccountForm>(() => accountForm(account))
  const [error, setError] = useState<{ text: string; field: string | null } | null>(null)
  const busy = save.isPending
  const set = (patch: Partial<AccountForm>) => setForm((current) => ({ ...current, ...patch }))

  const dailyLimit = wholeNumber(form.dailyLimit, 0, MAX_DAILY_MEALS)
  const threshold = form.threshold.trim() === '' ? null : parseVndInput(form.threshold)
  const windows = parseMealWindows(form.windows)
  const needsSponsor = form.payMode !== 'wallet'
  const contactMissing = !account && !form.phone.trim() && !form.email.trim()
  const problems = {
    code: !validEmployeeCode(form.code),
    name: !form.name.trim(),
    contact: contactMissing,
    sponsor: needsSponsor && !form.sponsorId,
    dailyLimit: dailyLimit === undefined,
    threshold: form.threshold.trim() !== '' && threshold === null,
    windows: windows === null,
  }
  const ready = !Object.values(problems).some(Boolean)
  const invalid = (field: string, local: boolean) => local || error?.field === field

  async function submit() {
    if (!ready || busy || windows === null || dailyLimit === undefined) return
    setError(null)
    const values: MealAccountInput = {
      employee_code: form.code.trim(),
      name: form.name.trim(),
      phone: form.phone.trim() || null,
      group_label: form.group.trim() || null,
      meal_sponsor_id: form.sponsorId || null,
      pay_mode: form.payMode,
      daily_meal_limit: dailyLimit,
      meal_windows: windows,
      low_balance_threshold: threshold,
      ...(account ? {} : { email: form.email.trim() || null }),
    }
    try {
      const input = account ? { accountId: account.id, values } : { values }
      onSaved(await save.mutateAsync(input))
    } catch (failure) {
      setError({ text: describeMealFailure(failure, t), field: refusedField(failure) })
    }
  }

  const sponsorOptions = [
    { value: NONE, label: t('mealAccounts.noSponsor') },
    ...sponsors.map((row) => ({ value: row.id, label: row.name })),
  ]

  return (
    <Dialog
      open
      onOpenChange={(next) => {
        if (!next && !busy) onClose()
      }}
    >
      <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>
            {account
              ? t('mealAccounts.editTitle', { code: account.employee_code })
              : t('mealAccounts.create')}
          </DialogTitle>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit()
          }}
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-code`}>{t('mealAccounts.code')}</Label>
              <Input
                id={`${ids}-code`}
                value={form.code}
                maxLength={32}
                autoComplete="off"
                required
                aria-invalid={invalid('employee_code', form.code !== '' && problems.code)}
                aria-describedby={`${ids}-code-hint`}
                disabled={busy}
                onChange={(event) => set({ code: event.target.value })}
              />
              <p id={`${ids}-code-hint`} className="text-sm text-muted-foreground">
                {t('mealAccounts.codeHint')}
              </p>
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-name`}>{t('mealAccounts.name')}</Label>
              <Input
                id={`${ids}-name`}
                value={form.name}
                maxLength={120}
                autoComplete="off"
                required
                aria-invalid={invalid('name', false)}
                disabled={busy}
                onChange={(event) => set({ name: event.target.value })}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-phone`}>{t('mealAccounts.phone')}</Label>
              <Input
                id={`${ids}-phone`}
                type="tel"
                value={form.phone}
                autoComplete="off"
                aria-invalid={invalid('phone', false)}
                aria-describedby={account ? undefined : `${ids}-contact`}
                disabled={busy}
                onChange={(event) => set({ phone: event.target.value })}
              />
            </div>
            {!account && (
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-email`}>{t('mealAccounts.email')}</Label>
                <Input
                  id={`${ids}-email`}
                  type="email"
                  value={form.email}
                  autoComplete="off"
                  aria-invalid={invalid('email', false)}
                  aria-describedby={`${ids}-contact`}
                  disabled={busy}
                  onChange={(event) => set({ email: event.target.value })}
                />
              </div>
            )}
            {!account && (
              <p id={`${ids}-contact`} className="text-sm text-muted-foreground sm:col-span-2">
                {t('mealAccounts.contactHint')}
              </p>
            )}
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-group`}>{t('mealAccounts.group')}</Label>
              <Input
                id={`${ids}-group`}
                value={form.group}
                maxLength={120}
                autoComplete="off"
                aria-invalid={invalid('group_label', false)}
                disabled={busy}
                onChange={(event) => set({ group: event.target.value })}
              />
            </div>
            <ModelSelect
              label={t('mealAccounts.payMode')}
              value={form.payMode}
              disabled={busy}
              invalid={invalid('pay_mode', false)}
              options={MEAL_PAY_MODES.map((value) => ({
                value,
                label: t(`mealAccounts.payMode_${value}`),
              }))}
              onChange={(value) => set({ payMode: value as MealPayMode })}
            />
            <ModelSelect
              label={t('mealAccounts.sponsor')}
              value={form.sponsorId}
              disabled={busy}
              invalid={
                invalid('meal_sponsor', problems.sponsor) ||
                invalid('meal_sponsor_id', problems.sponsor)
              }
              hint={needsSponsor ? t('mealAccounts.sponsorHint') : undefined}
              options={sponsorOptions}
              onChange={(value) => set({ sponsorId: value })}
            />
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-limit`}>{t('mealAccounts.dailyLimit')}</Label>
              <Input
                id={`${ids}-limit`}
                inputMode="numeric"
                value={form.dailyLimit}
                autoComplete="off"
                aria-invalid={invalid('daily_meal_limit', problems.dailyLimit)}
                aria-describedby={`${ids}-limit-hint`}
                disabled={busy}
                onChange={(event) => set({ dailyLimit: event.target.value })}
              />
              <p id={`${ids}-limit-hint`} className="text-sm text-muted-foreground">
                {t('mealAccounts.dailyLimitHint', { max: MAX_DAILY_MEALS })}
              </p>
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-threshold`}>{t('mealAccounts.threshold')}</Label>
              <Input
                id={`${ids}-threshold`}
                inputMode="numeric"
                value={form.threshold}
                autoComplete="off"
                aria-invalid={invalid('low_balance_threshold', problems.threshold)}
                aria-describedby={`${ids}-threshold-hint`}
                disabled={busy}
                onChange={(event) => set({ threshold: event.target.value })}
              />
              <p id={`${ids}-threshold-hint`} className="text-sm text-muted-foreground">
                {t('mealAccounts.thresholdHint')}
              </p>
            </div>
          </div>
          <WindowsEditor
            windows={form.windows}
            busy={busy}
            refused={error?.field === 'meal_windows'}
            onChange={(next) => set({ windows: next })}
          />
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error.text}
            </p>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !ready}>
              {t(account ? 'mealAccounts.save' : 'mealAccounts.create')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

// The meal times an eater may eat in, each with an optional meal count of
// its own. None means any time of day.
function WindowsEditor({
  windows,
  busy,
  refused,
  onChange,
}: {
  windows: MealWindowDraft[]
  busy: boolean
  refused: boolean
  onChange: (windows: MealWindowDraft[]) => void
}) {
  const { t } = useTranslation()
  const ids = useId()
  const keys = windows.map((row) => row.key.trim())
  const update = (index: number, patch: Partial<MealWindowDraft>) =>
    onChange(windows.map((row, at) => (at === index ? { ...row, ...patch } : row)))
  return (
    <fieldset className="space-y-2">
      <legend className="text-sm font-medium">{t('mealAccounts.windows')}</legend>
      <p className="text-sm text-muted-foreground">{t('mealAccounts.windowsHint')}</p>
      {windows.map((row, index) => {
        const duplicate = row.key.trim() !== '' && keys.indexOf(row.key.trim()) !== index
        const bad = (row.key !== '' || row.from !== '' || row.to !== '') && !windowDraftValid(row)
        return (
          // biome-ignore lint/suspicious/noArrayIndexKey: positional draft rows
          <div key={index} className="flex flex-wrap items-end gap-2">
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-${index}-key`}>{t('mealAccounts.windowKey')}</Label>
              <Input
                id={`${ids}-${index}-key`}
                className="w-32"
                value={row.key}
                maxLength={32}
                autoComplete="off"
                aria-invalid={duplicate || bad || refused}
                disabled={busy}
                onChange={(event) => update(index, { key: event.target.value })}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-${index}-from`}>{t('mealAccounts.windowFrom')}</Label>
              <Input
                id={`${ids}-${index}-from`}
                type="time"
                className="w-32"
                value={row.from}
                aria-invalid={bad || refused}
                disabled={busy}
                onChange={(event) => update(index, { from: event.target.value })}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-${index}-to`}>{t('mealAccounts.windowTo')}</Label>
              <Input
                id={`${ids}-${index}-to`}
                type="time"
                className="w-32"
                value={row.to}
                aria-invalid={bad || refused}
                disabled={busy}
                onChange={(event) => update(index, { to: event.target.value })}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-${index}-limit`}>{t('mealAccounts.windowLimit')}</Label>
              <Input
                id={`${ids}-${index}-limit`}
                inputMode="numeric"
                className="w-24"
                value={row.limit}
                autoComplete="off"
                aria-invalid={bad || refused}
                disabled={busy}
                onChange={(event) => update(index, { limit: event.target.value })}
              />
            </div>
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => onChange(windows.filter((_, at) => at !== index))}
            >
              {t('mealAccounts.windowRemove')}
            </Button>
            {(bad || duplicate) && (
              <p role="alert" className="basis-full text-sm text-destructive">
                {t(duplicate ? 'mealAccounts.windowDuplicate' : 'mealAccounts.windowInvalid', {
                  max: MAX_DAILY_MEALS,
                })}
              </p>
            )}
          </div>
        )
      })}
      <Button
        type="button"
        variant="outline"
        disabled={busy || windows.length >= MAX_MEAL_WINDOWS}
        onClick={() => onChange([...windows, windowDraft()])}
      >
        <PlusIcon className="size-4" />
        {t('mealAccounts.windowAdd', { max: MAX_MEAL_WINDOWS })}
      </Button>
    </fieldset>
  )
}

// Imports accounts from a CSV file, all or nothing: refused rows are listed
// by line and nothing is saved until the file is clean.
function ImportDialog({
  branchId,
  onClose,
  onImported,
}: {
  branchId: string
  onClose: () => void
  onImported: (result: { created: number; updated: number }) => void
}) {
  const { t } = useTranslation()
  const ids = useId()
  const run = useImportMealAccounts(branchId)
  const [file, setFile] = useState<File | null>(null)
  const [error, setError] = useState('')
  const [problems, setProblems] = useState<ImportProblem[]>([])
  const busy = run.isPending
  const tooLarge = Boolean(file && file.size > MAX_IMPORT_BYTES)

  async function submit() {
    if (!file || tooLarge || busy) return
    setError('')
    setProblems([])
    let text: string
    try {
      text = await file.text()
    } catch {
      setError(t('mealAccounts.importUnreadable'))
      return
    }
    try {
      onImported(await run.mutateAsync(text))
    } catch (failure) {
      setProblems(importProblems(failure))
      setError(describeMealFailure(failure, t))
    }
  }

  return (
    <Dialog
      open
      onOpenChange={(next) => {
        if (!next && !busy) onClose()
      }}
    >
      <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{t('mealAccounts.import')}</DialogTitle>
          <DialogDescription>{t('mealAccounts.importIntro')}</DialogDescription>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit()
          }}
        >
          <div className="space-y-1 text-sm">
            <p>{t('mealAccounts.importHeader')}</p>
            <code className="block overflow-x-auto rounded-md bg-muted p-2 text-xs">
              {MEAL_IMPORT_HEADER}
            </code>
            <p className="text-muted-foreground">{t('mealAccounts.importRules')}</p>
          </div>
          <div className="grid gap-1">
            <Label htmlFor={`${ids}-file`}>{t('mealAccounts.importFile')}</Label>
            <Input
              id={`${ids}-file`}
              type="file"
              accept=".csv,text/csv"
              aria-invalid={tooLarge}
              disabled={busy}
              onChange={(event) => {
                setFile(event.target.files?.[0] ?? null)
                setError('')
                setProblems([])
              }}
            />
            {tooLarge && (
              <p role="alert" className="text-sm text-destructive">
                {t('mealAccounts.importTooLarge')}
              </p>
            )}
          </div>
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          {problems.length > 0 && (
            <div className="max-h-64 overflow-y-auto rounded-lg border">
              <table className="w-full text-sm" aria-label={t('mealAccounts.importProblems')}>
                <thead className="border-b">
                  <tr>
                    <th scope="col" className="px-3 py-2 text-left font-medium">
                      {t('mealAccounts.importLine')}
                    </th>
                    <th scope="col" className="px-3 py-2 text-left font-medium">
                      {t('mealAccounts.importField')}
                    </th>
                    <th scope="col" className="px-3 py-2 text-left font-medium">
                      {t('mealAccounts.importMessage')}
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {problems.map((problem, index) => (
                    // biome-ignore lint/suspicious/noArrayIndexKey: one line may have several problems
                    <tr key={index}>
                      <td className="px-3 py-2 tabular-nums">{problem.line ?? '—'}</td>
                      <td className="px-3 py-2">
                        {problem.field
                          ? t(`mealAccounts.field_${problem.field}`, {
                              defaultValue: problem.field,
                            })
                          : '—'}
                      </td>
                      <td className="px-3 py-2">{problem.message}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !file || tooLarge}>
              <UploadIcon className="size-4" />
              {t('mealAccounts.importSubmit')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

function windowText(window: MealWindow, t: Translate) {
  const range = `${window.key} ${window.from}–${window.to}`
  if (window.limit == null) return range
  return `${range} (${t('mealAccounts.windowMeals', { count: window.limit })})`
}

// One account beside the list: its rules and its wallet history, newest
// first. Money moves at the counter, so nothing here changes the balance.
function HistorySheet({
  branchId,
  account,
  onClose,
}: {
  branchId: string
  account: MealAccount
  onClose: () => void
}) {
  const { t, i18n } = useTranslation()
  const { context } = usePosSession()
  const timeZone = branchTimeZone(context.data)
  const [page, setPage] = useState(1)
  const entries = useMealEntries(branchId, account.id, page)
  const meta = entries.data?.meta
  const rows = entries.data?.data ?? []
  return (
    <Sheet
      open
      onOpenChange={(next) => {
        if (!next) onClose()
      }}
    >
      <SheetContent className="overflow-y-auto data-[side=right]:sm:max-w-xl">
        <SheetHeader>
          <SheetTitle>
            {account.employee_code}
            {account.name ? ` · ${account.name}` : ''}
          </SheetTitle>
          <SheetDescription>
            {t('mealAccounts.balance')}: {formatMoney(account.balance, account.currency)}
          </SheetDescription>
        </SheetHeader>
        <div className="space-y-6 px-4 pb-6">
          <dl className="grid grid-cols-2 gap-3 text-sm">
            <div>
              <dt className="text-muted-foreground">{t('mealAccounts.status')}</dt>
              <dd>{t(`mealAccounts.status_${account.status}`)}</dd>
            </div>
            <div>
              <dt className="text-muted-foreground">{t('mealAccounts.payMode')}</dt>
              <dd>
                {t(`mealAccounts.payMode_${account.pay_mode}`)}
                {account.sponsor ? ` · ${account.sponsor.name}` : ''}
              </dd>
            </div>
            <div>
              <dt className="text-muted-foreground">{t('mealAccounts.dailyLimit')}</dt>
              <dd>{account.daily_meal_limit ?? t('mealAccounts.noLimit')}</dd>
            </div>
            <div>
              <dt className="text-muted-foreground">{t('mealAccounts.threshold')}</dt>
              <dd>
                {account.low_balance_threshold
                  ? formatMoney(account.low_balance_threshold, account.currency)
                  : '—'}
              </dd>
            </div>
            <div className="col-span-2">
              <dt className="text-muted-foreground">{t('mealAccounts.windows')}</dt>
              <dd>
                {account.meal_windows.length === 0
                  ? t('mealAccounts.anyTime')
                  : account.meal_windows.map((window) => windowText(window, t)).join(', ')}
              </dd>
            </div>
          </dl>
          <section className="space-y-2" aria-label={t('mealAccounts.history')}>
            <h3 className="font-medium">{t('mealAccounts.history')}</h3>
            <p className="text-sm text-muted-foreground">{t('mealAccounts.historyHint')}</p>
            {entries.isError ? (
              <div role="alert" className="space-y-2">
                <p className="text-sm text-destructive">{describeFailure(entries.error, t)}</p>
                <Button variant="outline" size="sm" onClick={() => void entries.refetch()}>
                  {t('retry')}
                </Button>
              </div>
            ) : entries.isPending ? (
              <p role="status">{t('waiting')}</p>
            ) : rows.length === 0 ? (
              <p role="status" className="text-sm text-muted-foreground">
                {t('mealAccounts.historyEmpty')}
              </p>
            ) : (
              <div className="overflow-x-auto rounded-lg border">
                <table className="w-full text-sm" aria-label={t('mealAccounts.history')}>
                  <thead className="border-b">
                    <tr>
                      <th scope="col" className="px-3 py-2 text-left font-medium">
                        {t('mealAccounts.entryAt')}
                      </th>
                      <th scope="col" className="px-3 py-2 text-left font-medium">
                        {t('mealAccounts.entryKind')}
                      </th>
                      <th scope="col" className="px-3 py-2 text-right font-medium">
                        {t('mealAccounts.entryAmount')}
                      </th>
                      <th scope="col" className="px-3 py-2 text-left font-medium">
                        {t('mealAccounts.entryDetail')}
                      </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y">
                    {rows.map((entry) => (
                      <tr key={entry.id}>
                        <td className="whitespace-nowrap px-3 py-2">
                          {formatInstant(entry.created_at, i18n.language, timeZone)}
                        </td>
                        <td className="px-3 py-2">
                          {t(`mealAccounts.entry_${entry.kind}`, { defaultValue: entry.kind })}
                        </td>
                        <td className="px-3 py-2 text-right tabular-nums">
                          {formatMoney(entry.amount, account.currency)}
                        </td>
                        <td className="px-3 py-2">
                          {[entry.order_number, entry.note, entry.actor.name]
                            .filter(Boolean)
                            .join(' · ')}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
            {meta && meta.pages > 1 && (
              <nav
                aria-label={t('mealAccounts.historyPages')}
                className="flex items-center justify-end gap-3 text-sm"
              >
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => setPage(page - 1)}
                >
                  {t('reportPrevious')}
                </Button>
                <span className="text-muted-foreground">
                  {t('reportPageOf', { page, pages: meta.pages })}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page >= meta.pages}
                  onClick={() => setPage(page + 1)}
                >
                  {t('reportNext')}
                </Button>
              </nav>
            )}
          </section>
        </div>
      </SheetContent>
    </Sheet>
  )
}
