import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { contextFeature } from '@parkviet/pos-shared/pos-features'
import { describeCreditFailure, parseDueDays } from '@parkviet/pos-shared/receivables'
import { canExportReports, todayIn, validReportRange } from '@parkviet/pos-shared/reports'
import { describeShiftFailure } from '@parkviet/pos-shared/shifts'
import {
  defineTable,
  PageHeader,
  ResourceTable,
  resourceSearchSchema,
  usePermissions,
} from '@spree/dashboard-core'
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
  useConfirm,
} from '@spree/dashboard-ui'
import { DownloadIcon, PlusIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { ReportExports } from '../components/reports/report-exports'
import { ModelSelect } from '../components/setup/model-ui'
import {
  type MealSponsorInput,
  mealSponsorsQuery,
  sponsorList,
  useSaveMealSponsor,
} from '../hooks/use-meal-accounts'
import { usePosSession } from '../hooks/use-pos-session'
import { useCreateExport } from '../hooks/use-reports'
import { useSession } from '../hooks/use-session'
import { branchTimeZone } from '../lib/format-time'
import {
  describeMealFailure,
  type MealSponsor,
  refusedField,
  SUBSIDY_MODES,
  type SubsidyMode,
  statementPeriod,
  wholeNumber,
} from '../lib/meal-accounts'
import { canManageCredit, canReadDebts } from '../lib/pos-access'
import { hiddenTimestamps } from '../tables/columns'

type Editing = { kind: 'create' } | { kind: 'edit'; sponsor: MealSponsor }
type Notice = { text: string; failed: boolean } | null
type T = (key: string, options?: Record<string, unknown>) => string

// Credit terms come from the shared credit configuration; other refusals
// name the sponsor field the server refused.
const sponsorFailure = (error: unknown, t: T) =>
  refusedField(error) ? describeMealFailure(error, t) : describeCreditFailure(error, t)

function subsidyText(sponsor: MealSponsor, t: T) {
  if (sponsor.subsidy_mode === 'none') return t('mealSponsors.subsidy_none')
  const value =
    sponsor.subsidy_mode === 'percent'
      ? `${Number(sponsor.subsidy_value)}%`
      : formatMoney(sponsor.subsidy_value)
  const cap = sponsor.subsidy_daily_cap
    ? ` · ${t('mealSponsors.capPerDay', { cap: formatMoney(sponsor.subsidy_daily_cap) })}`
    : ''
  return `${t(`mealSponsors.subsidy_${sponsor.subsidy_mode}`)} ${value}${cap}`
}

// "Đơn vị chi trả": the companies and schools that pay for their people's
// meals on credit, in full or as a subsidy. Their credit limit and due days
// are credit terms; the statement of a period is exported as a CSV, and the
// debt is collected through the receivables like any credit sale.
export function MealSponsorsPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const exporting = canExportReports(context.data?.capabilities)
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('mealSponsors.title')}
        description={t('mealSponsors.intro')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <div key={branchId} className="space-y-6">
          <MealSponsors branchId={branchId} />
          {exporting && (
            <ReportExports branchId={branchId} timeZone={branchTimeZone(context.data)} />
          )}
        </div>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function MealSponsors({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context, selection } = usePosSession()
  const { permissionKeys } = usePermissions()
  const client = useQueryClient()
  const navigate = useNavigate()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const confirm = useConfirm()
  const save = useSaveMealSponsor(branchId)
  const [editing, setEditing] = useState<Editing | null>(null)
  const [statement, setStatement] = useState<MealSponsor | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const access = { permissionKeys, context: context.data }
  const locked = writesLocked(context.data, selection) || save.isPending
  const exporting = canExportReports(context.data?.capabilities)
  const readsDebts = canReadDebts(access)

  async function setStatus(sponsor: MealSponsor, status: MealSponsor['status']) {
    setNotice(null)
    try {
      await save.mutateAsync({ sponsorId: sponsor.id, values: { status } })
      setNotice({ text: t('mealSponsors.saved', { name: sponsor.name }), failed: false })
    } catch (failure) {
      setNotice({ text: sponsorFailure(failure, t), failed: true })
    }
  }

  // The sponsor's debt is its credit account's, collected like any credit sale.
  const openReceivables = (accountId: string) =>
    void navigate({
      to: `/${storeId}/receivables?accountId=${encodeURIComponent(accountId)}` as string,
    })

  const money = (value: string | null) => (value == null ? '—' : formatMoney(value))
  const tableKey = 'pos-meal-sponsors'
  defineTable<MealSponsor>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('mealSponsors.search'),
    emptyMessage: t('mealSponsors.empty'),
    columns: [
      {
        key: 'name',
        label: t('mealSponsors.name'),
        default: true,
        sortable: false,
        filterable: false,
        render: (sponsor) => (
          <ResourceNameCell
            id={sponsor.id}
            name={sponsor.name}
            secondary={sponsor.customer_phone ?? undefined}
          />
        ),
      },
      {
        key: 'subsidy_mode',
        label: t('mealSponsors.subsidy'),
        default: true,
        sortable: false,
        filterable: false,
        render: (sponsor) => subsidyText(sponsor, t),
      },
      {
        key: 'statement_day',
        label: t('mealSponsors.statementDay'),
        default: true,
        sortable: false,
        filterable: false,
        className: 'text-right tabular-nums',
      },
      {
        key: 'accounts_count',
        label: t('mealSponsors.accounts'),
        default: true,
        sortable: false,
        filterable: false,
        className: 'text-right tabular-nums',
      },
      ...(
        [
          ['credit_limit', 'creditLimit'],
          ['open_debt', 'creditOpenDebt'],
          ['credit_available', 'creditAvailable'],
        ] as const
      ).map(([key, label]) => ({
        key,
        label: t(label),
        default: true,
        sortable: false,
        filterable: false,
        className: 'text-right tabular-nums',
        render: (sponsor: MealSponsor) => money(sponsor[key]),
      })),
      {
        key: 'status',
        label: t('mealSponsors.status'),
        default: true,
        sortable: false,
        filterable: false,
        render: (sponsor) => (
          <Badge variant={sponsor.status === 'suspended' ? 'warning' : 'secondary'}>
            {t(`mealSponsors.status_${sponsor.status}`)}
          </Badge>
        ),
      },
      ...hiddenTimestamps<MealSponsor>(),
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
      <ResourceTable<MealSponsor>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'meal-sponsors', branchId, 'table']}
        queryFn={async (params: Record<string, unknown>) => {
          const rows = await client.fetchQuery(mealSponsorsQuery(storeId, branchId))
          return sponsorList(rows.data, params)
        }}
        searchParams={search}
        actions={
          <Button disabled={locked} onClick={() => setEditing({ kind: 'create' })}>
            <PlusIcon className="size-4" />
            {t('mealSponsors.create')}
          </Button>
        }
        rowActions={(sponsor) => {
          const suspended = sponsor.status === 'suspended'
          const debtor = sponsor.credit_account_id
          return (
            <RowActions
              actions={[
                {
                  key: 'edit',
                  label: t('mealSponsors.edit'),
                  disabled: locked,
                  onSelect: () => setEditing({ kind: 'edit', sponsor }),
                },
                ...(exporting
                  ? [
                      {
                        key: 'statement',
                        label: t('mealSponsors.exportStatement'),
                        onSelect: () => setStatement(sponsor),
                      },
                    ]
                  : []),
                ...(readsDebts && debtor
                  ? [
                      {
                        key: 'receivables',
                        label: t('mealSponsors.openReceivables'),
                        onSelect: () => openReceivables(debtor),
                      },
                    ]
                  : []),
                {
                  key: 'status',
                  label: t(suspended ? 'mealSponsors.activate' : 'mealSponsors.suspend'),
                  destructive: !suspended,
                  disabled: locked,
                  onSelect: async () => {
                    if (
                      !suspended &&
                      !(await confirm({
                        message: t('mealSponsors.suspendConfirm', { name: sponsor.name }),
                        variant: 'destructive',
                        confirmLabel: t('mealSponsors.suspend'),
                        cancelLabel: t('adminCancel'),
                      }))
                    )
                      return
                    await setStatus(sponsor, suspended ? 'active' : 'suspended')
                  },
                },
              ]}
            />
          )
        }}
      />
      <p className="text-sm text-muted-foreground">{t('mealSponsors.collectHint')}</p>
      {editing && (
        <SponsorDialog
          editing={editing}
          branchId={branchId}
          setsCredit={canManageCredit(access)}
          onClose={() => setEditing(null)}
          onSaved={(sponsor) => {
            setEditing(null)
            setNotice({ text: t('mealSponsors.saved', { name: sponsor.name }), failed: false })
          }}
        />
      )}
      {statement && (
        <StatementDialog
          branchId={branchId}
          sponsor={statement}
          onClose={() => setStatement(null)}
          onQueued={() => {
            setStatement(null)
            setNotice({ text: t('mealSponsors.statementQueued'), failed: false })
          }}
        />
      )}
    </>
  )
}

type SponsorForm = {
  name: string
  phone: string
  email: string
  statementDay: string
  subsidyMode: SubsidyMode
  subsidyValue: string
  dailyCap: string
  creditLimit: string
  dueDays: string
}

// A stored amount as typed in the form; zero and none leave the field blank.
const amountText = (value: string | null | undefined) => {
  const text = value ? (parseVndAmount(value) ?? '') : ''
  return text === '0' ? '' : text
}

// A typed VND amount: null when blank, undefined when it is not an amount.
function optionalAmount(text: string): string | null | undefined {
  if (text.trim() === '') return null
  return parseVndInput(text) ?? undefined
}

function sponsorForm(sponsor: MealSponsor | null): SponsorForm {
  return {
    name: sponsor?.name ?? '',
    phone: sponsor?.customer_phone ?? '',
    email: '',
    statementDay: String(sponsor?.statement_day ?? 25),
    subsidyMode: sponsor?.subsidy_mode ?? 'none',
    subsidyValue: amountText(sponsor?.subsidy_value),
    dailyCap: amountText(sponsor?.subsidy_daily_cap),
    creditLimit: amountText(sponsor?.credit_limit),
    dueDays: sponsor?.due_days == null ? '30' : String(sponsor.due_days),
  }
}

// The subsidy value as sent: a VND amount, or a whole percent up to 100.
function subsidyValue(form: SponsorForm): string | null {
  if (form.subsidyMode === 'none') return '0'
  if (form.subsidyMode === 'percent') {
    const percent = wholeNumber(form.subsidyValue, 0, 100)
    return percent == null ? null : String(percent)
  }
  return parseVndInput(form.subsidyValue)
}

// Adds a sponsor (a customer made from the name and phone or email) or
// changes its statement day, subsidy and, for credit managers, its credit terms.
function SponsorDialog({
  editing,
  branchId,
  setsCredit,
  onClose,
  onSaved,
}: {
  editing: Editing
  branchId: string
  setsCredit: boolean
  onClose: () => void
  onSaved: (sponsor: MealSponsor) => void
}) {
  const { t } = useTranslation()
  const ids = useId()
  const sponsor = editing.kind === 'edit' ? editing.sponsor : null
  const save = useSaveMealSponsor(branchId)
  const [form, setForm] = useState<SponsorForm>(() => sponsorForm(sponsor))
  const [error, setError] = useState<{ text: string; field: string | null } | null>(null)
  const busy = save.isPending
  const set = (patch: Partial<SponsorForm>) => setForm((current) => ({ ...current, ...patch }))
  const initial = sponsorForm(sponsor)

  const statementDay = wholeNumber(form.statementDay, 1, 28)
  const value = subsidyValue(form)
  const cap = form.subsidyMode === 'none' ? null : optionalAmount(form.dailyCap)
  const limit = optionalAmount(form.creditLimit)
  const dueDays = parseDueDays(form.dueDays)
  // Credit terms are sent only when a credit manager sets or changes them.
  const creditChanged =
    setsCredit &&
    form.creditLimit.trim() !== '' &&
    (form.creditLimit !== initial.creditLimit || form.dueDays !== initial.dueDays)
  const problems = {
    name: !form.name.trim(),
    statementDay: statementDay == null,
    subsidy: value === null,
    cap: cap === undefined,
    credit: creditChanged && (limit == null || dueDays === null),
  }
  const ready = !Object.values(problems).some(Boolean)
  const subsidyRefused = form.subsidyValue !== '' && problems.subsidy
  const invalid = (field: string, local: boolean) => local || error?.field === field

  async function submit() {
    if (!ready || busy || statementDay == null || value === null || cap === undefined) return
    setError(null)
    const values: MealSponsorInput = {
      name: form.name.trim(),
      phone: form.phone.trim() || null,
      statement_day: statementDay,
      subsidy_mode: form.subsidyMode,
      subsidy_value: value,
      subsidy_daily_cap: cap,
      ...(sponsor ? {} : { email: form.email.trim() || null }),
      ...(creditChanged && limit && dueDays !== null
        ? { credit_limit: limit, due_days: dueDays }
        : {}),
    }
    try {
      onSaved(await save.mutateAsync({ sponsorId: sponsor?.id, values }))
    } catch (failure) {
      setError({ text: sponsorFailure(failure, t), field: refusedField(failure) })
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
          <DialogTitle>
            {sponsor
              ? t('mealSponsors.editTitle', { name: sponsor.name })
              : t('mealSponsors.create')}
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
              <Label htmlFor={`${ids}-name`}>{t('mealSponsors.name')}</Label>
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
              <Label htmlFor={`${ids}-phone`}>{t('mealSponsors.phone')}</Label>
              <Input
                id={`${ids}-phone`}
                type="tel"
                value={form.phone}
                autoComplete="off"
                aria-invalid={invalid('phone', false)}
                disabled={busy}
                onChange={(event) => set({ phone: event.target.value })}
              />
            </div>
            {!sponsor && (
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-email`}>{t('mealSponsors.email')}</Label>
                <Input
                  id={`${ids}-email`}
                  type="email"
                  value={form.email}
                  autoComplete="off"
                  aria-invalid={invalid('email', false)}
                  disabled={busy}
                  onChange={(event) => set({ email: event.target.value })}
                />
              </div>
            )}
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-day`}>{t('mealSponsors.statementDay')}</Label>
              <Input
                id={`${ids}-day`}
                inputMode="numeric"
                value={form.statementDay}
                autoComplete="off"
                required
                aria-invalid={invalid('statement_day', problems.statementDay)}
                aria-describedby={`${ids}-day-hint`}
                disabled={busy}
                onChange={(event) => set({ statementDay: event.target.value })}
              />
              <p id={`${ids}-day-hint`} className="text-sm text-muted-foreground">
                {t('mealSponsors.statementDayHint')}
              </p>
            </div>
            <ModelSelect
              label={t('mealSponsors.subsidyMode')}
              value={form.subsidyMode}
              disabled={busy}
              invalid={invalid('subsidy_mode', false)}
              hint={t(`mealSponsors.subsidyHint_${form.subsidyMode}`)}
              options={SUBSIDY_MODES.map((mode) => ({
                value: mode,
                label: t(`mealSponsors.subsidy_${mode}`),
              }))}
              onChange={(mode) => set({ subsidyMode: mode as SubsidyMode })}
            />
            {form.subsidyMode !== 'none' && (
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-value`}>
                  {t(
                    form.subsidyMode === 'percent'
                      ? 'mealSponsors.subsidyPercent'
                      : 'mealSponsors.subsidyAmount',
                  )}
                </Label>
                <Input
                  id={`${ids}-value`}
                  inputMode="numeric"
                  value={form.subsidyValue}
                  autoComplete="off"
                  required
                  aria-invalid={invalid('subsidy_value', subsidyRefused)}
                  disabled={busy}
                  onChange={(event) => set({ subsidyValue: event.target.value })}
                />
              </div>
            )}
            {form.subsidyMode !== 'none' && (
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-cap`}>{t('mealSponsors.dailyCap')}</Label>
                <Input
                  id={`${ids}-cap`}
                  inputMode="numeric"
                  value={form.dailyCap}
                  autoComplete="off"
                  aria-invalid={invalid('subsidy_daily_cap', problems.cap)}
                  aria-describedby={`${ids}-cap-hint`}
                  disabled={busy}
                  onChange={(event) => set({ dailyCap: event.target.value })}
                />
                <p id={`${ids}-cap-hint`} className="text-sm text-muted-foreground">
                  {t('mealSponsors.dailyCapHint')}
                </p>
              </div>
            )}
          </div>
          {setsCredit ? (
            <fieldset className="grid gap-4 sm:grid-cols-2">
              <legend className="mb-2 text-sm font-medium sm:col-span-2">
                {t('mealSponsors.creditTerms')}
              </legend>
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-limit`}>{t('creditLimit')}</Label>
                <Input
                  id={`${ids}-limit`}
                  inputMode="numeric"
                  value={form.creditLimit}
                  autoComplete="off"
                  aria-invalid={limit === undefined}
                  disabled={busy}
                  onChange={(event) => set({ creditLimit: event.target.value })}
                />
              </div>
              <div className="grid gap-1">
                <Label htmlFor={`${ids}-due`}>{t('creditDueDays')}</Label>
                <Input
                  id={`${ids}-due`}
                  inputMode="numeric"
                  value={form.dueDays}
                  autoComplete="off"
                  aria-invalid={form.dueDays.trim() !== '' && dueDays === null}
                  disabled={busy}
                  onChange={(event) => set({ dueDays: event.target.value })}
                />
              </div>
              <p className="text-sm text-muted-foreground sm:col-span-2">
                {t('mealSponsors.creditHint')}
              </p>
            </fieldset>
          ) : (
            <p className="text-sm text-muted-foreground">{t('mealSponsors.creditLocked')}</p>
          )}
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
              {t(sponsor ? 'mealSponsors.save' : 'mealSponsors.create')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

// Asks for the sponsor's statement of a period as a CSV through the report
// exports; the period starts as the sponsor's last closed statement cycle.
function StatementDialog({
  branchId,
  sponsor,
  onClose,
  onQueued,
}: {
  branchId: string
  sponsor: MealSponsor
  onClose: () => void
  onQueued: () => void
}) {
  const { t } = useTranslation()
  const ids = useId()
  const { context } = usePosSession()
  const createExport = useCreateExport()
  const [period, setPeriod] = useState(() =>
    statementPeriod(sponsor.statement_day, todayIn(branchTimeZone(context.data))),
  )
  const [error, setError] = useState('')
  const exportsOn = contextFeature(context.data, 'exports')
  const valid = validReportRange(period.from, period.to)
  const busy = createExport.isPending

  function submit() {
    if (!valid || busy || !exportsOn) return
    setError('')
    createExport.mutate(
      {
        branchId,
        type: 'meal_statement',
        filters: { from: period.from, to: period.to, meal_sponsor_id: sponsor.id },
      },
      {
        onSuccess: onQueued,
        onError: (failure) => setError(describeShiftFailure(failure, t)),
      },
    )
  }

  return (
    <Dialog
      open
      onOpenChange={(next) => {
        if (!next && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>{t('mealSponsors.statementTitle', { name: sponsor.name })}</DialogTitle>
          <DialogDescription>
            {t('mealSponsors.statementIntro', { day: sponsor.statement_day })}
          </DialogDescription>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            submit()
          }}
        >
          <div className="flex flex-wrap gap-4">
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-from`}>{t('reportFrom')}</Label>
              <Input
                id={`${ids}-from`}
                type="date"
                className="w-40"
                value={period.from}
                max={period.to}
                disabled={busy}
                onChange={(event) => setPeriod({ ...period, from: event.target.value })}
              />
            </div>
            <div className="grid gap-1">
              <Label htmlFor={`${ids}-to`}>{t('reportTo')}</Label>
              <Input
                id={`${ids}-to`}
                type="date"
                className="w-40"
                value={period.to}
                min={period.from}
                aria-invalid={!valid}
                disabled={busy}
                onChange={(event) => setPeriod({ ...period, to: event.target.value })}
              />
            </div>
          </div>
          {!valid && (
            <p role="alert" className="text-sm text-destructive">
              {t('reportRangeInvalid')}
            </p>
          )}
          {!exportsOn && (
            <p role="note" className="text-sm text-muted-foreground">
              {t('featureOff_exports')}
            </p>
          )}
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !valid || !exportsOn}>
              <DownloadIcon className="size-4" />
              {t('reportExport')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
