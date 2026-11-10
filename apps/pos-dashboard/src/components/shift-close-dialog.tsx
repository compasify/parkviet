import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money'
import { definitiveRejection } from '@parkviet/pos-shared/request-failure'
import {
  absoluteAmount,
  blockedChecklist,
  type ChecklistItem,
  describeShiftFailure,
  type ShiftChecklist,
  type ShiftClosure,
  varianceKind,
} from '@parkviet/pos-shared/shifts'
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
} from '@spree/dashboard-ui'
import { Link } from '@tanstack/react-router'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useSession } from '../hooks/use-session'
import { useCloseShift, useCountShift, useShiftCloseState } from '../hooks/use-shifts'
import { formatInstant } from '../lib/format-time'

// Variance direction in words, so status is never conveyed by colour alone.
export function VarianceText({
  variance,
  currency,
}: {
  variance: string | null
  currency: string
}) {
  const { t } = useTranslation()
  const kind = varianceKind(variance)
  if (!kind || variance == null) return <span>—</span>
  return (
    <span data-variance={kind} className={kind === 'short' ? 'text-destructive' : undefined}>
      {t(`shiftVariance_${kind}`)}
      {kind === 'even' ? null : ` ${formatMoney(absoluteAmount(variance), currency)}`}
    </span>
  )
}

export function Summary({ rows }: { rows: [string, ReactNode][] }) {
  return (
    <dl className="grid grid-cols-[1fr_auto] gap-x-4 gap-y-2 text-sm">
      {rows.map(([label, value]) => (
        <div key={label} className="contents">
          <dt className="text-muted-foreground">{label}</dt>
          <dd className="text-right tabular-nums">{value}</dd>
        </div>
      ))}
    </dl>
  )
}

export function ClosureSnapshot({
  closure,
  timeZone,
}: {
  closure: ShiftClosure
  timeZone: string
}) {
  const { t, i18n } = useTranslation()
  const money = (value: string) => formatMoney(value, closure.currency)
  return (
    <div className="space-y-3" role="status" aria-live="polite">
      <p>
        <strong>{t('shiftClosedTitle')}</strong> ·{' '}
        {formatInstant(closure.closed_at, i18n.language, timeZone)}
      </p>
      <Summary
        rows={[
          [t('shiftClosedBy'), closure.closer_name],
          [t('shiftOpeningFloat'), money(closure.opening_float)],
          [t('shiftInflow'), money(closure.inflow_total)],
          [t('shiftOutflow'), money(closure.outflow_total)],
          [t('shiftExpected'), money(closure.expected)],
          [t('shiftCounted'), money(closure.counted)],
          [
            t('shiftVarianceLabel'),
            <VarianceText key="variance" variance={closure.variance} currency={closure.currency} />,
          ],
          ...(closure.reason ? ([[t('shiftReason'), closure.reason]] as [string, string][]) : []),
          ...(closure.approver_name
            ? ([[t('shiftApprovedBy'), closure.approver_name]] as [string, string][])
            : []),
        ]}
      />
      <p className="text-sm text-muted-foreground">{t('shiftClosedImmutable')}</p>
    </div>
  )
}

function ChecklistList({
  items,
  label,
  currency,
}: {
  items: ChecklistItem[]
  label: string
  currency: string
}) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  if (items.length === 0) return null
  return (
    <ul className="divide-y rounded-md border text-sm" aria-label={label}>
      {items.map((item) => (
        <li
          key={`${item.type}-${item.id ?? item.workspace_id}`}
          className="flex items-center justify-between gap-3 p-3"
        >
          <span className="flex flex-col">
            <span className="font-medium">
              {t(`shiftCheck_${item.type}`)}
              {item.order_number ? ` · ${item.order_number}` : ''}
            </span>
            <span className="text-xs text-muted-foreground">
              {t(`shiftCheckStatus_${item.status}`, { defaultValue: item.status })}
              {item.amount ? ` · ${formatMoney(item.amount, currency)}` : ''}
            </span>
          </span>
          {/* Drafts, tenders and refunds are settled at the counter; a payout is settled here. */}
          {item.type === 'liability_payout' && item.funds_id ? (
            <Button variant="outline" size="sm" asChild>
              <Link to={`/${storeId}/funds?fundsId=${encodeURIComponent(item.funds_id)}` as string}>
                {t(`shiftCheckAction_${item.type}`)}
              </Link>
            </Button>
          ) : null}
        </li>
      ))}
    </ul>
  )
}

type Step = 'checklist' | 'count'

// Closing another person's shift: checklist, blind count, expected and
// variance, a reason (and approval) when the variance exceeds the branch
// threshold, then the immutable snapshot. Expected cash shows only after the
// count is recorded. Count and close keys follow the shift revision, so a
// retry after a lost response reuses the same key.
export function ShiftCloseDialog({
  shiftId,
  ownerName,
  timeZone,
  onClose,
}: {
  shiftId: string
  ownerName: string
  timeZone: string
  onClose: () => void
}) {
  const { t } = useTranslation()
  const [step, setStep] = useState<Step>('checklist')
  const [counted, setCounted] = useState('')
  const [reason, setReason] = useState('')
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [uncertain, setUncertain] = useState<null | (() => void)>(null)
  const [blocked, setBlocked] = useState<ShiftChecklist | null>(null)
  const [recounting, setRecounting] = useState(false)
  const countShift = useCountShift()
  const closeShift = useCloseShift()
  const peek = useShiftCloseState(shiftId)
  const peekCount = peek.data?.count
  // Keep checking while a reasoned count waits for its approval.
  const waiting = Boolean(
    peekCount?.requires_approval && peekCount.reason && !peekCount.approval && !peekCount.stale,
  )
  const state = useShiftCloseState(shiftId, waiting)
  const busy = countShift.isPending || closeShift.isPending
  const data = state.data
  const currency = data?.shift.currency ?? 'VND'
  const revision = data?.shift.revision ?? 0
  const count = data?.count
  const checklist = blocked ?? data?.checklist
  const reviewing = Boolean(count?.counted && !count.stale && !data?.closure && !recounting)

  function fail(failure: unknown, retry: () => void) {
    const items = blockedChecklist(failure)
    if (items) {
      setBlocked(items)
      setStep('checklist')
    }
    setUncertain(definitiveRejection(failure) ? null : () => retry)
    setError(describeShiftFailure(failure, t))
  }

  // A retry keeps the revision (and so the key) of the attempt whose outcome
  // is unknown, even if the shift already moved on because it committed.
  function submitCount(withReason?: string, atRevision = revision, typed?: string) {
    const amount = typed ?? parseVndInput(counted || count?.counted?.replace(/\.0+$/, '') || '')
    if (amount === null) {
      setError(t('shiftCountedInvalid'))
      return
    }
    setError('')
    setNotice('')
    countShift.mutate(
      { shiftId, revision: atRevision, counted: amount, reason: withReason },
      {
        onSuccess: (result) => {
          setBlocked(null)
          setRecounting(false)
          setUncertain(null)
          if (result.recovered && result.data.counted?.replace(/\.0+$/, '') !== amount) {
            setNotice(
              t('shiftCountRecovered', { amount: formatMoney(result.data.counted, currency) }),
            )
          }
        },
        onError: (failure) => fail(failure, () => submitCount(withReason, atRevision, amount)),
      },
    )
  }

  function close(atRevision = revision) {
    setError('')
    closeShift.mutate(
      { shiftId, revision: atRevision, reason: reason.trim() || undefined },
      {
        onSuccess: () => setUncertain(null),
        onError: (failure) => fail(failure, () => close(atRevision)),
      },
    )
  }

  const steps = (current: 0 | 1 | 2) => (
    <ol className="flex flex-wrap gap-2 text-xs" aria-label={t('shiftCloseSteps')}>
      {['shiftStepChecklist', 'shiftStepCount', 'shiftStepReview'].map((key, index) => (
        <li key={key} aria-current={index === current ? 'step' : undefined}>
          <Badge variant={index === current ? 'default' : 'outline'}>{t(key)}</Badge>
        </li>
      ))}
    </ol>
  )

  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="max-h-[90dvh] overflow-y-auto sm:max-w-xl" aria-busy={busy}>
        <DialogHeader>
          <DialogTitle>{t('shiftCloseFor', { name: ownerName })}</DialogTitle>
          <DialogDescription>{t('shiftOthersHint')}</DialogDescription>
        </DialogHeader>
        <div className="space-y-4">
          {uncertain && (
            <div role="status" className="flex flex-wrap items-center gap-2">
              <Badge variant="warning">{t('shiftCommandChecking')}</Badge>
              <Button
                variant="outline"
                size="sm"
                disabled={busy}
                onClick={() => {
                  setError('')
                  uncertain()
                }}
              >
                {t('shiftCommandRecheck')}
              </Button>
            </div>
          )}
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          {notice && (
            <p role="status" className="text-sm text-muted-foreground">
              {notice}
            </p>
          )}
          {state.isLoading && <p role="status">{t('waiting')}</p>}
          {state.isError && <p role="alert">{describeShiftFailure(state.error, t)}</p>}
          {data?.closure ? (
            <>
              <ClosureSnapshot closure={data.closure} timeZone={timeZone} />
              <DialogFooter>
                <Button onClick={onClose}>{t('shiftCloseDone')}</Button>
              </DialogFooter>
            </>
          ) : data && !data.can_close ? (
            <p>{t('shiftCloseNotAllowed')}</p>
          ) : data && reviewing && count ? (
            <div className="space-y-4">
              {steps(2)}
              <Summary
                rows={[
                  [t('shiftCounted'), formatMoney(count.counted, currency)],
                  [t('shiftExpected'), formatMoney(count.expected, currency)],
                  [
                    t('shiftVarianceLabel'),
                    <VarianceText key="variance" variance={count.variance} currency={currency} />,
                  ],
                ]}
              />
              <p className="text-sm text-muted-foreground">{t('shiftExpectedExplained')}</p>
              {count.requires_approval ? (
                <>
                  <Badge variant="warning">
                    {count.variance_threshold
                      ? t('shiftNeedsApprovalThreshold', {
                          threshold: formatMoney(count.variance_threshold, currency),
                        })
                      : t('shiftNeedsApproval')}
                  </Badge>
                  {count.approval ? (
                    <p role="status">
                      {t('shiftApprovedBy')}: {count.approval.approver_name}
                    </p>
                  ) : count.reason ? (
                    <p role="status" aria-live="polite">
                      {t('shiftWaitingApproval', { reason: count.reason })}
                    </p>
                  ) : (
                    <ReasonField
                      label={t('shiftReason')}
                      value={reason}
                      required
                      disabled={busy}
                      onChange={setReason}
                    />
                  )}
                </>
              ) : count.variance && varianceKind(count.variance) !== 'even' ? (
                <ReasonField
                  label={t('shiftReasonOptional')}
                  value={reason}
                  disabled={busy}
                  onChange={setReason}
                />
              ) : null}
              <DialogFooter>
                <Button
                  variant="outline"
                  disabled={busy}
                  onClick={() => {
                    setCounted('')
                    setReason('')
                    setNotice('')
                    setRecounting(true)
                    setStep('count')
                  }}
                >
                  {t('shiftRecount')}
                </Button>
                {count.requires_approval && !count.approval && !count.reason ? (
                  <Button
                    disabled={busy || !reason.trim()}
                    onClick={() => submitCount(reason.trim())}
                  >
                    {t('shiftSendForApproval')}
                  </Button>
                ) : count.requires_approval && !count.approval ? (
                  <Button
                    variant="outline"
                    disabled={busy || state.isFetching}
                    onClick={() => void state.refetch()}
                  >
                    {t('shiftCheckApproval')}
                  </Button>
                ) : (
                  <Button disabled={busy} onClick={() => close()}>
                    {busy ? t('waiting') : t('shiftCloseConfirm')}
                  </Button>
                )}
              </DialogFooter>
            </div>
          ) : data && step === 'count' ? (
            <form
              className="space-y-4"
              onSubmit={(event) => {
                event.preventDefault()
                if (!busy) submitCount()
              }}
            >
              {steps(1)}
              <p className="text-sm">{t('shiftBlindCountHint')}</p>
              {count?.stale && <Badge variant="warning">{t('shiftCountStale')}</Badge>}
              <div className="grid gap-1">
                <Label htmlFor="shift-counted">{t('shiftCountedInput')}</Label>
                <Input
                  id="shift-counted"
                  inputMode="numeric"
                  autoComplete="off"
                  value={counted}
                  disabled={busy}
                  onChange={(event) => setCounted(event.target.value)}
                />
              </div>
              <DialogFooter>
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => setStep('checklist')}
                >
                  {t('back')}
                </Button>
                <Button type="submit" disabled={busy || !counted.trim()}>
                  {busy ? t('waiting') : t('shiftRecordCount')}
                </Button>
              </DialogFooter>
            </form>
          ) : data && checklist ? (
            <div className="space-y-4">
              {steps(0)}
              {checklist.blocking.length === 0 ? (
                <p role="status">{t('shiftChecklistClear')}</p>
              ) : (
                <p role="status">
                  <Badge variant="warning">
                    {t('shiftChecklistBlocked', { count: checklist.blocking.length })}
                  </Badge>
                </p>
              )}
              <ChecklistList
                items={checklist.blocking}
                label={t('shiftChecklistBlocking')}
                currency={currency}
              />
              {checklist.warnings.length > 0 && (
                <>
                  <p className="text-sm text-muted-foreground">{t('shiftChecklistWarnings')}</p>
                  <ChecklistList
                    items={checklist.warnings}
                    label={t('shiftChecklistWarningList')}
                    currency={currency}
                  />
                </>
              )}
              <DialogFooter>
                <Button
                  variant="outline"
                  disabled={state.isFetching}
                  onClick={() => {
                    setBlocked(null)
                    void state.refetch()
                  }}
                >
                  {t('shiftChecklistRefresh')}
                </Button>
                <Button
                  disabled={checklist.blocking.length > 0}
                  onClick={() => {
                    setError('')
                    setStep('count')
                  }}
                >
                  {t('shiftStartCount')}
                </Button>
              </DialogFooter>
            </div>
          ) : null}
        </div>
      </DialogContent>
    </Dialog>
  )
}

function ReasonField({
  label,
  value,
  required,
  disabled,
  onChange,
}: {
  label: string
  value: string
  required?: boolean
  disabled: boolean
  onChange: (value: string) => void
}) {
  return (
    <div className="grid gap-1">
      <Label htmlFor="shift-reason">{label}</Label>
      <Input
        id="shift-reason"
        value={value}
        maxLength={200}
        required={required}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )
}
