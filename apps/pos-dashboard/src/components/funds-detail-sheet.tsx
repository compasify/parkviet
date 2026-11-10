import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosLiabilityPayout, PosReceivedFunds } from '@parkviet/pos-shared/types/pos-context'
import { usePermissions } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Input,
  Label,
  RowActions,
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  useConfirm,
} from '@spree/dashboard-ui'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { type PayoutInput, useFundDetail, useLiabilityPayouts } from '../hooks/use-funds'
import { usePosSession } from '../hooks/use-pos-session'
import { hasCapability } from '../lib/pos-access'

export function FundsDetailSheet({
  fundsId,
  branchId,
  onClose,
}: {
  fundsId: string
  branchId: string
  onClose: () => void
}) {
  const { t } = useTranslation()
  const detail = useFundDetail(fundsId, branchId)
  // A record of another branch is not shown, even when the link names it.
  const funds = detail.data?.branch_id === branchId ? detail.data : null
  return (
    <Sheet
      open
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
    >
      <SheetContent className="overflow-y-auto data-[side=right]:sm:max-w-xl">
        <SheetHeader>
          <SheetTitle>{t('fundsDetail')}</SheetTitle>
          <SheetDescription>{fundsId}</SheetDescription>
        </SheetHeader>
        <div className="space-y-6 px-4 pb-6">
          {detail.isError ? (
            <div role="alert" className="space-y-2">
              <p>{describeFailure(detail.error, t)}</p>
              <Button variant="outline" onClick={() => void detail.refetch()}>
                {t('retry')}
              </Button>
            </div>
          ) : !detail.data ? (
            <p role="status">{t('waiting')}</p>
          ) : !funds ? (
            <p role="alert">{t('missing')}</p>
          ) : (
            <FundsDetail funds={funds} />
          )}
        </div>
      </SheetContent>
    </Sheet>
  )
}

function FundsDetail({ funds }: { funds: PosReceivedFunds }) {
  const { t } = useTranslation()
  const { permissionKeys } = usePermissions()
  const { context, selection } = usePosSession()
  const canResolve = hasCapability({ permissionKeys, context: context.data }, 'pos.payment.resolve')
  const rows: [string, string][] = [
    ['fundsReceived', formatMoney(funds.received_net, funds.currency)],
    ['paymentAllocated', formatMoney(funds.allocated, funds.currency)],
    ['fundsReserved', formatMoney(funds.payout_reserved, funds.currency)],
    ['fundsPaidOut', formatMoney(funds.paid_out, funds.currency)],
    ['paymentUnapplied', formatMoney(funds.available, funds.currency)],
    ['paymentReference', funds.reference || '—'],
  ]
  return (
    <>
      <div className="flex flex-wrap items-center gap-2">
        <Badge variant={funds.status === 'attention' ? 'warning' : 'secondary'}>
          {t(`fundStatus_${funds.status}`)}
        </Badge>
        <span className="font-medium">{t(funds.kind === 'cash' ? 'cash' : 'bankTransfer')}</span>
      </div>
      <dl className="grid grid-cols-[1fr_auto] gap-x-4 gap-y-2 text-sm">
        {rows.map(([label, value]) => (
          <div key={label} className="contents">
            <dt className="text-muted-foreground">{t(label)}</dt>
            <dd className="text-right tabular-nums">{value}</dd>
          </div>
        ))}
      </dl>
      {funds.allocations?.length ? (
        <section className="space-y-2" aria-label={t('fundsAllocations')}>
          <h3 className="font-medium">
            {t('fundsAllocations')} ({funds.allocations.length})
          </h3>
          <ul className="divide-y rounded-md border text-sm">
            {funds.allocations.map((allocation) => (
              <li key={allocation.id} className="flex items-center justify-between gap-3 p-3">
                <span className="flex flex-col">
                  <span>{allocation.order_id || allocation.workspace_id}</span>
                  <span className="text-xs text-muted-foreground">
                    {t(`allocationStatus_${allocation.status}`)}
                  </span>
                </span>
                <span className="tabular-nums">
                  {formatMoney(allocation.amount, allocation.currency)}
                </span>
              </li>
            ))}
          </ul>
        </section>
      ) : null}
      {canResolve ? (
        <>
          <p className="text-sm text-muted-foreground">{t('fundsAllocateHint')}</p>
          <Payouts funds={funds} locked={writesLocked(context.data, selection)} />
        </>
      ) : (
        <p className="text-sm text-muted-foreground">{t('fundsReadOnly')}</p>
      )}
    </>
  )
}

const OPEN_PAYOUT = ['requested', 'reserved', 'unknown']

// Paying received money back: request (with an approval when the branch
// requires one), confirm with evidence, or record an outcome that is unknown,
// failed without effect, or canceled.
function Payouts({ funds, locked }: { funds: PosReceivedFunds; locked: boolean }) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const payouts = useLiabilityPayouts(funds)
  const [error, setError] = useState('')
  const [notice, setNotice] = useState('')
  const [confirming, setConfirming] = useState<PosLiabilityPayout | null>(null)
  const disabled = locked || payouts.isPending
  // Cash in a drawer is confirmed by the count; held cash names its custody
  // (safe, envelope) and bank money its transfer reference.
  const needsReference = funds.kind !== 'cash' || funds.custody === 'held'

  async function run(input: PayoutInput, done: string): Promise<boolean> {
    setError('')
    setNotice('')
    try {
      await payouts.mutateAsync(input)
      setNotice(t(done))
      return true
    } catch (failure) {
      setError(describeFailure(failure, t))
      return false
    }
  }

  function request(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const element = event.currentTarget
    const form = new FormData(element)
    const amount = parseVndInput(String(form.get('amount') ?? ''))
    if (!amount || amount === '0') {
      setError(t('invalid'))
      return
    }
    void run(
      {
        action: 'request',
        amount,
        beneficiaryName: String(form.get('beneficiary_name') ?? '').trim(),
        beneficiaryReference: String(form.get('beneficiary_reference') ?? '').trim() || undefined,
        reason: String(form.get('reason') ?? '').trim(),
        approvalId: String(form.get('approval_id') ?? '').trim() || undefined,
      },
      'fundsPayoutRequested',
    ).then((ok) => {
      if (ok) element.reset()
    })
  }

  function confirmWithReference(event: FormEvent<HTMLFormElement>, payout: PosLiabilityPayout) {
    event.preventDefault()
    const reference = String(new FormData(event.currentTarget).get('reference') ?? '').trim()
    if (!reference) return
    const input: PayoutInput =
      funds.kind === 'cash'
        ? {
            action: 'confirm',
            payoutId: payout.id,
            evidenceKind: 'cash_count',
            reference,
            paidFrom: 'custody',
          }
        : { action: 'confirm', payoutId: payout.id, evidenceKind: 'bank_manual', reference }
    void run(input, 'fundsPayoutConfirmed').then((ok) => {
      if (ok) setConfirming(null)
    })
  }

  async function resolve(
    payout: PosLiabilityPayout,
    outcome: 'unknown' | 'failed_no_effect' | 'cancel',
  ) {
    if (
      outcome !== 'unknown' &&
      !(await confirm({
        message: t(outcome === 'cancel' ? 'fundsPayoutCancelConfirm' : 'fundsPayoutFailedConfirm', {
          name: payout.beneficiary_name,
          amount: formatMoney(payout.amount, payout.currency),
        }),
        variant: 'destructive',
        confirmLabel: t(outcome === 'cancel' ? 'fundsPayoutCancel' : 'fundsPayoutFailed'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    void run({ action: 'resolve', payoutId: payout.id, outcome }, 'fundsPayoutResolved')
  }

  const list = funds.payouts ?? []
  return (
    <section className="space-y-4" aria-label={t('fundsPayouts')}>
      <div>
        <h3 className="font-medium">{t('fundsPayouts')}</h3>
        <p className="text-sm text-muted-foreground">{t('paymentSandbox')}</p>
      </div>
      {notice && (
        <p role="status" className="text-sm text-muted-foreground">
          {notice}
        </p>
      )}
      {error && (
        <p role="alert" className="text-sm text-destructive">
          {error}
        </p>
      )}
      {list.length > 0 && (
        <ul className="divide-y rounded-md border text-sm" aria-label={t('fundsPayoutList')}>
          {list.map((payout) => (
            <li key={payout.id} className="space-y-2 p-3">
              <div className="flex items-start justify-between gap-3">
                <span className="flex flex-col">
                  <span className="font-medium">
                    {payout.beneficiary_name} · {formatMoney(payout.amount, payout.currency)}
                  </span>
                  <span className="text-xs text-muted-foreground">{payout.reason}</span>
                  <span>
                    <Badge variant={OPEN_PAYOUT.includes(payout.status) ? 'warning' : 'secondary'}>
                      {t(`payoutStatus_${payout.status}`)}
                    </Badge>
                  </span>
                </span>
                {OPEN_PAYOUT.includes(payout.status) && (
                  <RowActions
                    actions={[
                      {
                        key: 'confirm',
                        label: t('fundsPayoutConfirm'),
                        disabled,
                        onSelect: () => {
                          if (needsReference) setConfirming(payout)
                          else
                            void run(
                              {
                                action: 'confirm',
                                payoutId: payout.id,
                                evidenceKind: 'cash_count',
                              },
                              'fundsPayoutConfirmed',
                            )
                        },
                      },
                      {
                        key: 'unknown',
                        label: t('fundsPayoutUnknown'),
                        disabled,
                        onSelect: () => void resolve(payout, 'unknown'),
                      },
                      {
                        key: 'failed',
                        label: t('fundsPayoutFailed'),
                        disabled,
                        destructive: true,
                        onSelect: () => void resolve(payout, 'failed_no_effect'),
                      },
                      {
                        key: 'cancel',
                        label: t('fundsPayoutCancel'),
                        disabled,
                        destructive: true,
                        onSelect: () => void resolve(payout, 'cancel'),
                      },
                    ]}
                  />
                )}
              </div>
              {confirming?.id === payout.id && (
                <form
                  className="flex flex-wrap items-end gap-2"
                  onSubmit={(event) => confirmWithReference(event, payout)}
                >
                  <div className="grid flex-1 gap-1">
                    <Label htmlFor={`payout-reference-${payout.id}`}>
                      {t(
                        funds.kind === 'cash'
                          ? 'fundsPayoutCustodyReference'
                          : 'fundsPayoutReference',
                      )}
                    </Label>
                    <Input
                      id={`payout-reference-${payout.id}`}
                      name="reference"
                      required
                      autoComplete="off"
                      disabled={disabled}
                    />
                  </div>
                  <Button type="submit" disabled={disabled}>
                    {t('fundsPayoutConfirm')}
                  </Button>
                  <Button type="button" variant="ghost" onClick={() => setConfirming(null)}>
                    {t('adminCancel')}
                  </Button>
                </form>
              )}
            </li>
          ))}
        </ul>
      )}
      <form className="grid gap-3 rounded-md border p-4" onSubmit={request}>
        <h4 className="font-medium">{t('fundsPayoutRequest')}</h4>
        {(
          [
            ['amount', 'fundsPayoutAmount', true],
            ['beneficiary_name', 'fundsBeneficiary', true],
            ['beneficiary_reference', 'fundsBeneficiaryReference', false],
            ['reason', 'discountReason', true],
            ['approval_id', 'discountApproval', false],
          ] as const
        ).map(([name, label, required]) => (
          <div key={name} className="grid gap-1">
            <Label htmlFor={`payout-${name}`}>{t(label)}</Label>
            <Input
              id={`payout-${name}`}
              name={name}
              required={required}
              inputMode={name === 'amount' ? 'numeric' : undefined}
              autoComplete="off"
              disabled={disabled}
            />
          </div>
        ))}
        <div>
          <Button type="submit" disabled={disabled}>
            {payouts.isPending ? t('waiting') : t('fundsPayoutRequest')}
          </Button>
        </div>
      </form>
    </section>
  )
}
