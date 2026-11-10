import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { definitiveRejection, describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  addsDrawerCash,
  type CashReconciliation,
  type CustodyOutcome,
  describeShiftFailure,
  outcomeNeedsReference,
  outcomeTakesShift,
  reconcileAmountError,
} from '@parkviet/pos-shared/shifts'
import { defineTable, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Input,
  Label,
  RadioGroup,
  RadioGroupItem,
  ResourceNameCell,
} from '@spree/dashboard-ui'
import { type ReactNode, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { FilterSelect } from '../components/filter-select'
import { usePosSession } from '../hooks/use-pos-session'
import {
  fetchReconciliations,
  useReconcileCandidates,
  useReconcileLateCash,
} from '../hooks/use-shifts'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { hiddenTimestamps } from '../tables/columns'
import { ShiftsFrame } from './shifts'

const OUTCOMES: CustodyOutcome[] = [
  'in_opening_float',
  'safe',
  'handed_over',
  'new_physical_inflow',
]
const NONE = 'none'
const ONE_PAGE = resourceSearchSchema.parse({ limit: 100 })

// Cash found after a shift closed: which closed shift's overage and/or which
// held receipt it is, and where that money is now. Only "put into a drawer
// now" adds cash to a current shift; the other outcomes record custody
// already counted elsewhere, so nothing is counted twice.
export function LateCashPage() {
  const { t } = useTranslation()
  return (
    <ShiftsFrame title={t('lateCashTitle')} description={t('lateCashHint')}>
      {(branchId) => (
        <div className="space-y-6">
          <LateCashForm branchId={branchId} />
          <History branchId={branchId} />
        </div>
      )}
    </ShiftsFrame>
  )
}

function LateCashForm({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context, selection } = usePosSession()
  const candidates = useReconcileCandidates(branchId)
  const reconcile = useReconcileLateCash()
  // One intent per filled-in form; renewed after a recorded reconciliation.
  const intent = useRef(crypto.randomUUID())
  const [closureId, setClosureId] = useState('')
  const [fundsId, setFundsId] = useState('')
  const [outcome, setOutcome] = useState<CustodyOutcome | ''>('')
  const [targetShiftId, setTargetShiftId] = useState('')
  const [reference, setReference] = useState('')
  const [reason, setReason] = useState('')
  const [amountText, setAmountText] = useState('')
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [uncertain, setUncertain] = useState(false)
  const locked = writesLocked(context.data, selection)
  const timeZone = branchTimeZone(context.data)
  const time = (value: string | null | undefined) => formatInstant(value, i18n.language, timeZone)
  const data = candidates.data
  const closure = data?.closures.find((row) => row.id === closureId)
  const funds = data?.held_funds.find((row) => row.id === fundsId)
  const closureOnly = Boolean(closure && !funds)
  const targets = (data?.shifts ?? []).filter((row) =>
    outcome === 'new_physical_inflow' ? row.status === 'open' : true,
  )
  const parsedAmount = parseVndInput(amountText)
  const amountError =
    closureOnly && closure
      ? reconcileAmountError(amountText, parsedAmount, closure.unexplained)
      : null
  const amount = funds?.amount ?? (closureOnly ? parsedAmount : null)
  const currency = funds?.currency ?? closure?.currency ?? 'VND'
  const ready =
    Boolean(closure || funds) &&
    !amountError &&
    outcome !== '' &&
    reason.trim() !== '' &&
    (!outcomeNeedsReference(outcome) || reference.trim() !== '') &&
    (!outcomeTakesShift(outcome) || targetShiftId !== '')
  const frozen = locked || reconcile.isPending || uncertain

  function reset() {
    intent.current = crypto.randomUUID()
    setClosureId('')
    setFundsId('')
    setOutcome('')
    setTargetShiftId('')
    setReference('')
    setReason('')
    setAmountText('')
  }

  function submit() {
    if (!ready || !outcome || reconcile.isPending) return
    setError('')
    reconcile.mutate(
      {
        branchId,
        intent: intent.current,
        outcome,
        reason: reason.trim(),
        amount: closureOnly ? (parsedAmount ?? undefined) : undefined,
        closureId: closureId || undefined,
        fundsId: fundsId || undefined,
        targetShiftId: outcomeTakesShift(outcome) ? targetShiftId || undefined : undefined,
        custodyReference: reference.trim() || undefined,
      },
      {
        onSuccess: ({ data: result }) => {
          setUncertain(false)
          setNotice(
            t(result.cash_movement_id ? 'lateCashDoneInflow' : 'lateCashDoneCustody', {
              amount: formatMoney(result.amount, result.currency),
            }),
          )
          reset()
        },
        onError: (failure) => {
          setUncertain(!definitiveRejection(failure))
          setError(describeShiftFailure(failure, t))
        },
      },
    )
  }

  const field = (id: string, label: string, control: ReactNode, hint?: ReactNode) => (
    <div className="grid gap-1">
      <Label htmlFor={id}>{label}</Label>
      {control}
      {hint}
    </div>
  )

  return (
    <Card>
      <CardHeader>
        <CardTitle>{t('lateCashTitle')}</CardTitle>
        <CardDescription>{t('lateCashHint')}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {candidates.isError && <p role="alert">{describeFailure(candidates.error, t)}</p>}
        {!data && !candidates.isError && <p role="status">{t('waiting')}</p>}
        {notice && (
          <p role="status" className="text-sm text-muted-foreground">
            {notice}
          </p>
        )}
        {data && data.closures.length === 0 && data.held_funds.length === 0 && (
          <p className="text-muted-foreground">{t('lateCashEmpty')}</p>
        )}
        {data && (data.closures.length > 0 || data.held_funds.length > 0) && (
          <form
            className="space-y-6"
            onSubmit={(event) => {
              event.preventDefault()
              submit()
            }}
          >
            <fieldset className="space-y-3" disabled={frozen}>
              <legend className="font-medium">{t('lateCashStepSource')}</legend>
              <div className="grid gap-1">
                <span className="text-sm">{t('lateCashClosedShift')}</span>
                <FilterSelect
                  label={t('lateCashClosedShift')}
                  value={closureId || NONE}
                  options={[
                    { value: NONE, label: t('lateCashNone') },
                    ...data.closures.map((row) => ({
                      value: row.id,
                      label: t('lateCashClosureOption', {
                        owner: row.owner_name,
                        register: row.register ?? '—',
                        time: time(row.closed_at),
                        amount: formatMoney(row.unexplained, row.currency),
                      }),
                    })),
                  ]}
                  onChange={(value) => setClosureId(value === NONE ? '' : value)}
                />
              </div>
              {closure && (
                <p className="text-sm text-muted-foreground">
                  {t('lateCashClosureFacts', {
                    counted: formatMoney(closure.counted, closure.currency),
                    expected: formatMoney(closure.expected, closure.currency),
                    variance: formatMoney(closure.variance, closure.currency),
                  })}
                </p>
              )}
              <div className="grid gap-1">
                <span className="text-sm">{t('lateCashHeld')}</span>
                <FilterSelect
                  label={t('lateCashHeld')}
                  value={fundsId || NONE}
                  options={[
                    { value: NONE, label: t('lateCashNone') },
                    // Nobody reconciles held cash they recorded themselves.
                    ...data.held_funds
                      .filter((row) => !row.recorded_by_me)
                      .map((row) => ({
                        value: row.id,
                        label: t('lateCashHeldOption', {
                          amount: formatMoney(row.amount, row.currency),
                          note: row.custody_note ?? '',
                          time: time(row.received_at),
                        }),
                      })),
                  ]}
                  onChange={(value) => setFundsId(value === NONE ? '' : value)}
                />
                {data.held_funds.some((row) => row.recorded_by_me) && (
                  <span className="text-xs text-muted-foreground">
                    {t('lateCashRecordedByMeHint')}
                  </span>
                )}
              </div>
              {funds && (
                <p role="status" className="text-sm text-muted-foreground">
                  {t('lateCashHeldShift', {
                    owner: funds.shift_owner_name ?? '—',
                    opened: time(funds.shift_opened_at),
                    status: t(
                      funds.shift_status === 'closed' ? 'lateCashShiftClosed' : 'lateCashShiftOpen',
                    ),
                  })}
                  {funds.closure_id
                    ? ` ${t('lateCashHeldClosure', {
                        counted: formatMoney(funds.closure_counted, funds.currency),
                        expected: formatMoney(funds.closure_expected, funds.currency),
                      })}`
                    : ''}
                  {funds.overage_explained ? ` ${t('lateCashOverageExplained')}` : ''}
                </p>
              )}
              {closureOnly &&
                closure &&
                field(
                  'late-cash-amount',
                  t('lateCashAmountInput', {
                    max: formatMoney(closure.unexplained, closure.currency),
                  }),
                  <Input
                    id="late-cash-amount"
                    inputMode="numeric"
                    autoComplete="off"
                    value={amountText}
                    aria-invalid={Boolean(amountError && amountText)}
                    onChange={(event) => setAmountText(event.target.value)}
                  />,
                  amountError && amountText ? (
                    <span className="text-xs text-destructive">{t(amountError)}</span>
                  ) : null,
                )}
              {amount && (
                <p role="status">
                  {t('lateCashAmount', { amount: formatMoney(amount, currency) })}
                </p>
              )}
            </fieldset>
            <fieldset className="space-y-3" disabled={frozen}>
              <legend className="font-medium">{t('lateCashStepCustody')}</legend>
              <RadioGroup
                value={outcome}
                onValueChange={(value) => setOutcome(value as CustodyOutcome)}
                aria-label={t('lateCashStepCustody')}
              >
                {OUTCOMES.map((value) => (
                  <div key={value} className="flex items-start gap-2">
                    <RadioGroupItem value={value} id={`late-cash-outcome-${value}`} />
                    <Label
                      htmlFor={`late-cash-outcome-${value}`}
                      className="flex flex-col items-start gap-0.5"
                    >
                      <span>{t(`lateCashOutcome_${value}`)}</span>
                      <span className="text-xs font-normal text-muted-foreground">
                        {t(`lateCashOutcomeHint_${value}`)}
                      </span>
                    </Label>
                  </div>
                ))}
              </RadioGroup>
              {outcome !== '' && (
                <p role="status">
                  <Badge variant={addsDrawerCash(outcome) ? 'warning' : 'secondary'}>
                    {t(addsDrawerCash(outcome) ? 'lateCashAddsDrawer' : 'lateCashNoDrawer')}
                  </Badge>
                </p>
              )}
              {outcome !== '' && outcomeTakesShift(outcome) && (
                <div className="grid gap-1">
                  <span className="text-sm">
                    {t(
                      outcome === 'new_physical_inflow'
                        ? 'lateCashTargetDrawer'
                        : 'lateCashTargetFloat',
                    )}
                  </span>
                  <FilterSelect
                    label={t(
                      outcome === 'new_physical_inflow'
                        ? 'lateCashTargetDrawer'
                        : 'lateCashTargetFloat',
                    )}
                    value={targetShiftId || NONE}
                    options={[
                      { value: NONE, label: t('lateCashNone') },
                      ...targets.map((row) => ({
                        value: row.id,
                        label: t('lateCashShiftOption', {
                          owner: row.owner_name,
                          register: row.register ?? '—',
                          float: formatMoney(row.opening_float, currency),
                          time: time(row.opened_at),
                        }),
                      })),
                    ]}
                    onChange={(value) => setTargetShiftId(value === NONE ? '' : value)}
                  />
                </div>
              )}
              {outcome !== '' &&
                outcomeNeedsReference(outcome) &&
                field(
                  'late-cash-reference',
                  t('lateCashReference'),
                  <Input
                    id="late-cash-reference"
                    value={reference}
                    maxLength={120}
                    onChange={(event) => setReference(event.target.value)}
                  />,
                )}
              {field(
                'late-cash-reason',
                t('lateCashReason'),
                <Input
                  id="late-cash-reason"
                  value={reason}
                  maxLength={200}
                  onChange={(event) => setReason(event.target.value)}
                />,
              )}
            </fieldset>
            {uncertain && (
              <p role="status">
                <Badge variant="warning">{t('shiftCommandChecking')}</Badge>
              </p>
            )}
            {error && (
              <p role="alert" className="text-sm text-destructive">
                {error}
              </p>
            )}
            <Button
              type="submit"
              disabled={locked || (!ready && !uncertain) || reconcile.isPending}
            >
              {reconcile.isPending
                ? t('waiting')
                : uncertain
                  ? t('shiftCommandRecheck')
                  : t('lateCashSubmit')}
            </Button>
          </form>
        )}
      </CardContent>
    </Card>
  )
}

function History({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context } = usePosSession()
  const timeZone = branchTimeZone(context.data)
  const tableKey = 'pos-cash-reconciliations'
  defineTable<CashReconciliation>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('lateCashHistorySearch'),
    emptyMessage: t('lateCashHistoryEmpty'),
    columns: [
      {
        key: 'outcome',
        label: t('lateCashStepCustody'),
        default: true,
        sortable: false,
        render: (row) => (
          <ResourceNameCell
            id={row.id}
            name={t(`lateCashOutcome_${row.outcome}`)}
            secondary={[row.reason, row.custody_reference].filter(Boolean).join(' · ')}
          />
        ),
      },
      { key: 'actor_name', label: t('lateCashActor'), default: true, sortable: false },
      {
        key: 'created_at',
        label: t('lateCashAt'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (row) => formatInstant(row.created_at, i18n.language, timeZone),
      },
      {
        key: 'amount',
        label: t('cashRequestAmount'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.amount, row.currency),
      },
      ...hiddenTimestamps<CashReconciliation>().filter((column) => column.key !== 'created_at'),
    ],
  })
  return (
    <Card>
      <CardHeader>
        <CardTitle>{t('lateCashHistory')}</CardTitle>
      </CardHeader>
      <CardContent>
        <ResourceTable<CashReconciliation>
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'cash-reconcile', branchId, 'list']}
          queryFn={(params: Record<string, unknown>) => fetchReconciliations(branchId, params)}
          searchParams={ONE_PAGE}
        />
      </CardContent>
    </Card>
  )
}
