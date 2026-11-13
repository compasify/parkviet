import { formatMoney } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { contextFeature } from '@parkviet/pos-shared/pos-features'
import { describeCreditFailure } from '@parkviet/pos-shared/receivables'
import { definitiveRejection } from '@parkviet/pos-shared/request-failure'
import {
  canCancelRefund,
  canFailRefund,
  describeReturnFailure,
  type PosRefundRequest,
  type PosReturnRow,
} from '@parkviet/pos-shared/returns'
import type { PosCreditRequest } from '@parkviet/pos-shared/types/pos-context'
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
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Label,
  ResourceNameCell,
  RowActions,
  Textarea,
  useConfirm,
} from '@spree/dashboard-ui'
import { CheckIcon, ShieldCheckIcon, XIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate } from '@tanstack/react-router'
import { type ReactNode, useEffect, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { ModelCard } from '../components/setup/model-ui'
import {
  type ApprovalDecision,
  fetchCreditRequests,
  fetchPendingReturns,
  fetchWaitingRefunds,
  useDecideCredit,
  useReturnDecisions,
} from '../hooks/use-debts'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { canManageCredit, canReadOrders, type PosAccess } from '../lib/pos-access'
import { hiddenTimestamps } from '../tables/columns'

type Notice = { text: string; failed: boolean } | null
type Reasoned = { title: string; label: string; confirm: string; submit: (text: string) => void }
// Each section is a short list read whole; it keeps its own first page.
const ONE_PAGE = resourceSearchSchema.parse({})
const POLL = 5_000

// "Duyệt cho nợ": what waits for an approver at the selected branch — credit
// sales (for credit managers), returns that need an approval and refund
// payouts waiting for one or with an unknown outcome. Nobody approves their
// own request. Closing-count variances and drawer requests are decided on
// the shifts screen.
export function CreditApprovalsPage() {
  const { t } = useTranslation()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const access: PosAccess = { permissionKeys, context: context.data }
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('approvalsTitle')}
        description={t('approvalsHint')}
        actions={<BranchPicker />}
      />
      {branchId ? (
        <div key={branchId} className="space-y-6">
          {canManageCredit(access) && <CreditRequests branchId={branchId} />}
          <ReturnApprovals branchId={branchId} />
        </div>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

// Requests arrive from the counters while the approver watches, as the
// selling app's approvals screen polls them.
function usePolling(resources: string[]) {
  const { storeId } = useSession()
  const client = useQueryClient()
  const key = resources.join(',')
  useEffect(() => {
    const timer = window.setInterval(() => {
      for (const resource of key.split(','))
        void client.invalidateQueries({ queryKey: ['pos', storeId, resource] })
    }, POLL)
    return () => window.clearInterval(timer)
  }, [client, storeId, key])
}

function Section({
  title,
  hint,
  notice,
  children,
}: {
  title: string
  hint?: string
  notice: Notice
  children: ReactNode
}) {
  const id = useId()
  return (
    <ModelCard title={title} id={id} icon={<ShieldCheckIcon />}>
      {hint ? <p className="text-sm text-muted-foreground">{hint}</p> : null}
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      {children}
    </ModelCard>
  )
}

function CreditRequests({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context, selection } = usePosSession()
  const confirm = useConfirm()
  const decide = useDecideCredit()
  usePolling(['credit-requests'])
  const [notice, setNotice] = useState<Notice>(null)
  const [rejecting, setRejecting] = useState<PosCreditRequest | null>(null)
  const locked = writesLocked(context.data, selection) || decide.isPending
  const timeZone = branchTimeZone(context.data)
  // Credit switched off at the branch: approving is refused by the server;
  // rejecting and revoking stay open.
  const creditOff = !contextFeature(context.data, 'credit')

  function run(
    request: PosCreditRequest,
    decision: 'approve' | 'reject' | 'revoke',
    reason?: string,
  ) {
    setNotice(null)
    decide.mutate(
      { requestId: request.id, decision, reason },
      {
        onSuccess: () => {
          setRejecting(null)
          setNotice({
            text: t(`creditDecision_${decision}`, { order: request.order_number }),
            failed: false,
          })
        },
        onError: (failure) => setNotice({ text: describeCreditFailure(failure, t), failed: true }),
      },
    )
  }

  const tableKey = 'pos-credit-requests'
  defineTable<PosCreditRequest>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('creditRequestsSearch'),
    emptyMessage: t('creditApprovalsEmpty'),
    columns: [
      {
        key: 'order_number',
        label: t('creditRequestOrder'),
        default: true,
        render: (row) => (
          <ResourceNameCell
            id={row.id}
            name={`${row.order_number} · ${row.customer.name}`}
            secondary={t('creditRequestedBy', {
              name: row.requester.name,
              time: formatInstant(row.created_at, i18n.language, timeZone),
            })}
          />
        ),
      },
      {
        key: 'status',
        label: t('creditRequestStatusLabel'),
        default: true,
        render: (row) => (
          <Badge variant={row.status === 'pending' ? 'warning' : 'secondary'}>
            {t(`creditRequestStatus_${row.status}`)}
          </Badge>
        ),
      },
      {
        key: 'amount',
        label: t('creditRequestAmount'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.amount, row.currency),
      },
      ...hiddenTimestamps<PosCreditRequest>(),
    ],
  })

  return (
    <Section title={t('creditApprovalsCredit')} notice={notice}>
      {creditOff && (
        <p role="note" className="text-sm text-muted-foreground">
          {t('featureOff_credit')}
        </p>
      )}
      <ResourceTable<PosCreditRequest>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'credit-requests', branchId, 'table']}
        queryFn={(params: Record<string, unknown>) => fetchCreditRequests(branchId, params)}
        searchParams={ONE_PAGE}
        rowActions={(row) => {
          const actions =
            row.status === 'pending'
              ? [
                  {
                    key: 'approve',
                    label: t('creditApprove'),
                    icon: <CheckIcon className="size-4" />,
                    disabled: locked || creditOff,
                    onSelect: () => run(row, 'approve'),
                  },
                  {
                    key: 'reject',
                    label: t('creditReject'),
                    icon: <XIcon className="size-4" />,
                    destructive: true,
                    disabled: locked,
                    onSelect: () => setRejecting(row),
                  },
                ]
              : row.status === 'approved' && row.approval_active
                ? [
                    {
                      key: 'revoke',
                      label: t('creditRevoke'),
                      destructive: true,
                      disabled: locked,
                      onSelect: async () => {
                        if (
                          await confirm({
                            message: t('creditRevokeConfirm', { order: row.order_number }),
                            variant: 'destructive',
                            confirmLabel: t('creditRevoke'),
                            cancelLabel: t('adminCancel'),
                          })
                        )
                          run(row, 'revoke')
                      },
                    },
                  ]
                : []
          return actions.length > 0 ? <RowActions actions={actions} /> : null
        }}
      />
      {rejecting && (
        <ReasonDialog
          busy={decide.isPending}
          onClose={() => setRejecting(null)}
          reasoned={{
            title: `${t('creditReject')} · ${rejecting.order_number}`,
            label: t('creditRejectReason'),
            confirm: t('creditReject'),
            submit: (reason) => run(rejecting, 'reject', reason),
          }}
        />
      )}
    </Section>
  )
}

// Approving binds the approval to the requester, the record, its revision and
// amount. Payouts are confirmed at the counter that pays them; an approver
// cancels one before any approval or records that it had no effect.
function ReturnApprovals({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { permissionKeys } = usePermissions()
  const { context, selection } = usePosSession()
  const navigate = useNavigate()
  const decide = useReturnDecisions()
  usePolling(['returns', 'refund-requests'])
  const [notice, setNotice] = useState<Notice>(null)
  const [reasoned, setReasoned] = useState<Reasoned | null>(null)
  const staffId = context.data?.staff.id ?? null
  const capabilities = context.data?.capabilities ?? []
  const locked = writesLocked(context.data, selection) || decide.isPending
  const access: PosAccess = { permissionKeys, context: context.data }
  const ordersOpen = canReadOrders(access)
  const openOrder = (orderId: string) =>
    void navigate({ to: `/${storeId}/orders/${orderId}` as string })

  function run(input: ApprovalDecision, done: string) {
    setNotice(null)
    decide.mutate(input, {
      onSuccess: () => {
        setReasoned(null)
        setNotice({ text: done, failed: false })
      },
      onError: (failure) =>
        setNotice({
          text: definitiveRejection(failure)
            ? describeReturnFailure(failure, t)
            : t('pendingCheckingLost'),
          failed: true,
        }),
    })
  }

  const returnsKey = 'pos-return-approvals'
  defineTable<PosReturnRow>(returnsKey, {
    searchParam: 'search',
    searchPlaceholder: t('approvalsReturnsSearch'),
    emptyMessage: t('approvalsReturnsEmpty'),
    columns: [
      {
        key: 'return_number',
        label: t('approvalsReturnList'),
        default: true,
        render: (row) => (
          <ResourceNameCell
            id={row.id}
            name={`${row.return_number} · ${row.order_number}`}
            secondary={[
              [
                row.cross_branch ? t('returnWhyCrossBranch') : null,
                row.out_of_window ? t('returnWhyWindow') : null,
                row.damaged ? t('returnWhyDamaged') : null,
              ]
                .filter(Boolean)
                .join(', '),
              row.reason,
            ]
              .filter(Boolean)
              .join(' · ')}
          />
        ),
      },
      {
        key: 'requester_name',
        label: t('approvalsRequester'),
        default: true,
        render: (row) => row.requester_name ?? '—',
      },
      {
        key: 'entitlement_total',
        label: t('approvalsAmount'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.entitlement_total, row.currency),
      },
      ...hiddenTimestamps<PosReturnRow>(),
    ],
  })

  const refundsKey = 'pos-refund-approvals'
  defineTable<PosRefundRequest>(refundsKey, {
    searchParam: 'search',
    searchPlaceholder: t('approvalsRefundsSearch'),
    emptyMessage: t('approvalsRefundsEmpty'),
    columns: [
      {
        key: 'method',
        label: t('approvalsRefundList'),
        default: true,
        sortable: false,
        render: (refund) => (
          <ResourceNameCell
            id={refund.id}
            name={`${t(refund.method === 'cash' ? 'refundCash' : 'refundBank')} · ${refund.order_number}`}
            secondary={[
              refund.beneficiary_reference,
              refund.evidence?.kind === 'unknown' ? t('refundEvidenceUnknown') : null,
            ]
              .filter(Boolean)
              .join(' · ')}
          />
        ),
      },
      {
        key: 'status',
        label: t('approvalsStatus'),
        default: true,
        render: (refund) => (
          <Badge variant="warning">
            {t(`refundStatus_${refund.status}`)}
            {refund.status === 'reserved' && refund.approval?.status !== 'active'
              ? ` · ${t('refundWaitApproval')}`
              : ''}
          </Badge>
        ),
      },
      {
        key: 'amount',
        label: t('approvalsAmount'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (refund) => formatMoney(refund.amount, refund.currency),
      },
      ...hiddenTimestamps<PosRefundRequest>(),
    ],
  })

  return (
    <Section title={t('approvalsReturns')} notice={notice}>
      <ResourceTable<PosReturnRow>
        tableKey={returnsKey}
        hideHeader
        queryKey={['pos', 'returns', branchId, 'pending-approval']}
        queryFn={(params: Record<string, unknown>) => fetchPendingReturns(branchId, params)}
        searchParams={ONE_PAGE}
        rowActions={(row) => (
          <RowActions
            actions={[
              {
                key: 'approve',
                label: t('approvalsApprove'),
                icon: <CheckIcon className="size-4" />,
                disabled: locked || row.requester_id === staffId,
                onSelect: () =>
                  run(
                    { kind: 'return.approve', returnId: row.id },
                    t('approvalsReturnApproved', { number: row.return_number }),
                  ),
              },
              {
                key: 'reject',
                label: t('approvalsReject'),
                icon: <XIcon className="size-4" />,
                destructive: true,
                disabled: locked,
                onSelect: () =>
                  setReasoned({
                    title: `${t('approvalsReject')} · ${row.return_number}`,
                    label: t('creditRejectReason'),
                    confirm: t('approvalsReject'),
                    submit: (reason) =>
                      run(
                        { kind: 'return.cancel', returnId: row.id, reason },
                        t('approvalsReturnRejected', { number: row.return_number }),
                      ),
                  }),
              },
              ...(ordersOpen
                ? [
                    {
                      key: 'order',
                      label: t('approvalsOpenOrder'),
                      onSelect: () => openOrder(row.order_id),
                    },
                  ]
                : []),
            ]}
          />
        )}
      />
      <ResourceTable<PosRefundRequest>
        tableKey={refundsKey}
        hideHeader
        queryKey={['pos', 'refund-requests', branchId, 'waiting']}
        queryFn={(params: Record<string, unknown>) => fetchWaitingRefunds(branchId, params)}
        searchParams={ONE_PAGE}
        rowActions={(refund) => (
          <RowActions
            actions={[
              ...(refund.status === 'reserved' && refund.approval?.status !== 'active'
                ? [
                    {
                      key: 'approve',
                      label: t('approvalsApprove'),
                      icon: <CheckIcon className="size-4" />,
                      disabled: locked || refund.requester_id === staffId,
                      onSelect: () =>
                        run(
                          { kind: 'refund.approve', refundId: refund.id },
                          t('approvalsRefundApproved', { order: refund.order_number }),
                        ),
                    },
                  ]
                : []),
              ...(canCancelRefund(refund, staffId, capabilities)
                ? [
                    {
                      key: 'cancel',
                      label: t('refundCancel'),
                      destructive: true,
                      disabled: locked,
                      onSelect: () =>
                        setReasoned({
                          title: `${t('refundCancel')} · ${refund.order_number}`,
                          label: t('refundCancelReason'),
                          confirm: t('refundCancelConfirm'),
                          submit: (reason) =>
                            run(
                              {
                                kind: 'refund.resolve',
                                refundId: refund.id,
                                outcome: 'cancel',
                                reason,
                              },
                              t('approvalsRefundCanceled', { order: refund.order_number }),
                            ),
                        }),
                    },
                  ]
                : []),
              ...(canFailRefund(refund, capabilities)
                ? [
                    {
                      key: 'failed',
                      label: t('refundFailed'),
                      destructive: true,
                      disabled: locked,
                      onSelect: () =>
                        setReasoned({
                          title: `${t('refundFailed')} · ${refund.order_number}`,
                          label: t('refundFailedEvidence'),
                          confirm: t('refundFailedConfirm'),
                          submit: (reference) =>
                            run(
                              {
                                kind: 'refund.resolve',
                                refundId: refund.id,
                                outcome: 'failed_no_effect',
                                reference,
                              },
                              t('approvalsRefundFailed', { order: refund.order_number }),
                            ),
                        }),
                    },
                  ]
                : []),
              ...(ordersOpen
                ? [
                    {
                      key: 'order',
                      label: t('approvalsOpenOrder'),
                      onSelect: () => openOrder(refund.order_id),
                    },
                  ]
                : []),
            ]}
          />
        )}
      />
      {reasoned && (
        <ReasonDialog
          busy={decide.isPending}
          reasoned={reasoned}
          onClose={() => setReasoned(null)}
        />
      )}
    </Section>
  )
}

// A required reason or evidence note for a refusal, as the server records it.
function ReasonDialog({
  reasoned,
  busy,
  onClose,
}: {
  reasoned: Reasoned
  busy: boolean
  onClose: () => void
}) {
  const id = useId()
  const { t } = useTranslation()
  const [text, setText] = useState('')
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{reasoned.title}</DialogTitle>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            if (text.trim()) reasoned.submit(text.trim())
          }}
        >
          <div className="grid gap-1">
            <Label htmlFor={id}>{reasoned.label}</Label>
            <Textarea
              id={id}
              value={text}
              maxLength={200}
              required
              disabled={busy}
              onChange={(event) => setText(event.target.value)}
            />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" variant="destructive" disabled={busy || !text.trim()}>
              {reasoned.confirm}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
