import { formatMoney } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { definitiveRejection } from '@parkviet/pos-shared/request-failure'
import {
  type CashMovementRequest,
  canReconcileCash,
  describeShiftFailure,
  type OpenShiftRow,
  type PendingClose,
} from '@parkviet/pos-shared/shifts'
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
import { CheckIcon, ClockIcon, XIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { type ReactNode, useEffect, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { PillTabs } from '../components/pill-tabs'
import { ModelCard } from '../components/setup/model-ui'
import { ShiftCloseDialog, VarianceText } from '../components/shift-close-dialog'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import {
  fetchCashRequests,
  fetchOpenShifts,
  fetchPendingCloses,
  useApproveClose,
  useDecideCashRequest,
} from '../hooks/use-shifts'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import {
  canApproveCloses,
  canConfirmCash,
  canRecoverShifts,
  type PosAccess,
} from '../lib/pos-access'
import { hiddenTimestamps } from '../tables/columns'

type Notice = { text: string; failed: boolean } | null

// Header and tabs of "Ca & két", shared by its three screens.
export function ShiftsFrame({
  title,
  description,
  children,
}: {
  title: string
  description: string
  children: (branchId: string) => ReactNode
}) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const base = `/${storeId}/shifts`
  const tabs = [
    { key: 'open', label: t('shiftsManageTab'), to: base },
    { key: 'closures', label: t('shiftClosuresTab'), to: `${base}/closures` },
    ...(canReconcileCash(context.data?.capabilities)
      ? [{ key: 'late-cash', label: t('lateCashTitle'), to: `${base}/late-cash` }]
      : []),
  ]
  return (
    <div className="space-y-6">
      <PageHeader title={title} description={description} actions={<BranchPicker />} />
      <PillTabs tabs={tabs} />
      {branchId ? (
        <div key={branchId}>{children(branchId)}</div>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}

function NoticeLine({ notice }: { notice: Notice }) {
  if (!notice) return null
  return (
    <p
      role={notice.failed ? 'alert' : 'status'}
      className={notice.failed ? 'text-sm text-destructive' : 'text-sm text-muted-foreground'}
    >
      {notice.text}
    </p>
  )
}

function Section({ title, hint, children }: { title: string; hint: string; children: ReactNode }) {
  const id = useId()
  return (
    <ModelCard title={title} id={id} icon={<ClockIcon />}>
      <p className="text-sm text-muted-foreground">{hint}</p>
      {children}
    </ModelCard>
  )
}

// What a manager settles for others at the branch: drawer requests waiting
// for a second person, counts waiting for a variance approval, and shifts
// left open by someone who is not at the counter.
export function ShiftsPage() {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const client = useQueryClient()
  const access: PosAccess = { permissionKeys, context: context.data }
  // Other devices open, count and request all the time; refresh every 15 seconds.
  // biome-ignore lint/correctness/useExhaustiveDependencies: the interval only depends on the store
  useEffect(() => {
    const timer = window.setInterval(() => {
      for (const resource of ['shift-close', 'cash-requests', 'pending-closes'])
        void client.invalidateQueries({ queryKey: ['pos', storeId, resource] })
    }, 15_000)
    return () => window.clearInterval(timer)
  }, [storeId])
  return (
    <ShiftsFrame title={t('shiftsManageTitle')} description={t('shiftsManageHint')}>
      {(branchId) => (
        <div className="space-y-6">
          {canConfirmCash(access) && <CashRequests branchId={branchId} />}
          {canApproveCloses(access) && <PendingCloses branchId={branchId} />}
          {canRecoverShifts(access) && <OpenShifts branchId={branchId} />}
        </div>
      )}
    </ShiftsFrame>
  )
}

// Several short lists share this page, so none of them follows the URL:
// each shows its whole list on one page and searches it in place.
const ONE_PAGE = resourceSearchSchema.parse({ limit: 100 })

function CashRequests({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context, selection } = usePosSession()
  const decide = useDecideCashRequest()
  const [notice, setNotice] = useState<Notice>(null)
  const [uncertainId, setUncertainId] = useState<string | null>(null)
  const [declining, setDeclining] = useState<CashMovementRequest | null>(null)
  const locked = writesLocked(context.data, selection)
  const timeZone = branchTimeZone(context.data)
  const staffId = context.data?.staff.id ?? null

  function run(request: CashMovementRequest, decision: 'confirm' | 'cancel', note?: string) {
    setNotice(null)
    decide.mutate(
      { request, decision, note },
      {
        onSuccess: () => {
          setUncertainId(null)
          setDeclining(null)
          setNotice({
            text: t(decision === 'confirm' ? 'cashRequestConfirmed' : 'cashRequestCanceled', {
              kind: t(`cashMovement_${request.kind}`),
              amount: formatMoney(request.amount, request.currency),
            }),
            failed: false,
          })
        },
        onError: (failure) => {
          setUncertainId(definitiveRejection(failure) ? null : request.id)
          setNotice({ text: describeShiftFailure(failure, t), failed: true })
        },
      },
    )
  }

  const tableKey = 'pos-cash-requests'
  defineTable<CashMovementRequest>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('cashRequestsSearch'),
    emptyMessage: t('cashRequestsEmpty'),
    columns: [
      {
        key: 'kind',
        label: t('cashRequestKind'),
        default: true,
        sortable: false,
        render: (row) => (
          <ResourceNameCell
            id={row.id}
            name={t(`cashMovement_${row.kind}`)}
            secondary={[row.reason, row.evidence_reference].filter(Boolean).join(' · ')}
          />
        ),
      },
      { key: 'requester_name', label: t('cashRequestRequester'), default: true },
      {
        key: 'created_at',
        label: t('cashRequestAt'),
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
      { key: 'updated_at', label: '', displayable: false, filterable: false, sortable: false },
    ],
  })

  return (
    <Section title={t('cashRequestsTitle')} hint={t('cashRequestsHint')}>
      <NoticeLine notice={notice} />
      <ResourceTable<CashMovementRequest>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'cash-requests', branchId, 'table', staffId]}
        queryFn={(params: Record<string, unknown>) => fetchCashRequests(branchId, staffId, params)}
        searchParams={ONE_PAGE}
        rowActions={(row) => (
          <RowActions
            actions={[
              {
                key: 'confirm',
                label: t(uncertainId === row.id ? 'shiftCommandRecheck' : 'cashRequestConfirm'),
                icon: <CheckIcon className="size-4" />,
                disabled: locked || decide.isPending,
                onSelect: () => run(row, 'confirm'),
              },
              {
                key: 'decline',
                label: t('cashRequestCancel'),
                icon: <XIcon className="size-4" />,
                destructive: true,
                disabled: locked || decide.isPending,
                onSelect: () => setDeclining(row),
              },
            ]}
          />
        )}
      />
      {declining && (
        <DeclineDialog
          request={declining}
          busy={decide.isPending}
          onClose={() => setDeclining(null)}
          onDecline={(note) => run(declining, 'cancel', note)}
        />
      )}
    </Section>
  )
}

function DeclineDialog({
  request,
  busy,
  onClose,
  onDecline,
}: {
  request: CashMovementRequest
  busy: boolean
  onClose: () => void
  onDecline: (note: string) => void
}) {
  const { t } = useTranslation()
  const [note, setNote] = useState('')
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>
            {t('cashRequestCancel')} · {t(`cashMovement_${request.kind}`)} ·{' '}
            {formatMoney(request.amount, request.currency)}
          </DialogTitle>
        </DialogHeader>
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            if (note.trim()) onDecline(note.trim())
          }}
        >
          <div className="grid gap-1">
            <Label htmlFor="cash-request-note">{t('cashRequestCancelNote')}</Label>
            <Textarea
              id="cash-request-note"
              value={note}
              maxLength={200}
              required
              onChange={(event) => setNote(event.target.value)}
            />
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" variant="destructive" disabled={busy || !note.trim()}>
              {t('cashRequestCancel')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

// Approving a variance binds the approval to that count; a recount needs a
// new one, and nobody approves their own count.
function PendingCloses({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context, selection } = usePosSession()
  const approve = useApproveClose()
  const [notice, setNotice] = useState<Notice>(null)
  const locked = writesLocked(context.data, selection)
  const timeZone = branchTimeZone(context.data)

  const tableKey = 'pos-pending-closes'
  defineTable<PendingClose>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('shiftApprovalsSearch'),
    emptyMessage: t('shiftApprovalsEmpty'),
    columns: [
      {
        key: 'owner_name',
        label: t('shiftOwner'),
        default: true,
        render: (row) => (
          <ResourceNameCell
            id={row.shift_id}
            name={row.owner_name}
            secondary={row.register ?? t('shiftNoRegister')}
          />
        ),
      },
      {
        key: 'counted_at',
        label: t('shiftCountedAt'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (row) => formatInstant(row.counted_at, i18n.language, timeZone),
      },
      {
        key: 'counted',
        label: t('shiftCounted'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.counted, row.currency ?? 'VND'),
      },
      {
        key: 'expected',
        label: t('shiftExpected'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.expected, row.currency ?? 'VND'),
      },
      {
        key: 'variance',
        label: t('shiftVarianceLabel'),
        default: true,
        sortable: false,
        render: (row) => <VarianceText variance={row.variance} currency={row.currency ?? 'VND'} />,
      },
      {
        key: 'reason',
        label: t('shiftReason'),
        default: true,
        sortable: false,
        className: 'whitespace-normal',
        render: (row) =>
          row.approval ? (
            <Badge variant="success">{t('shiftApprovalGranted')}</Badge>
          ) : row.reason ? (
            row.reason
          ) : (
            <Badge variant="outline">{t('shiftApprovalWaitingReason')}</Badge>
          ),
      },
      ...hiddenTimestamps<PendingClose>(),
    ],
  })

  return (
    <Section title={t('shiftApprovalsTitle')} hint={t('shiftApprovalsHint')}>
      <NoticeLine notice={notice} />
      <ResourceTable<PendingClose>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'pending-closes', branchId, 'table']}
        queryFn={(params: Record<string, unknown>) => fetchPendingCloses(branchId, params)}
        searchParams={ONE_PAGE}
        rowActions={(row) => (
          <RowActions
            actions={[
              {
                key: 'approve',
                label: row.self_count ? t('shiftReason_self_approval') : t('shiftApproveVariance'),
                icon: <CheckIcon className="size-4" />,
                visible: !row.approval,
                disabled: locked || approve.isPending || row.self_count || !row.reason,
                onSelect: () => {
                  setNotice(null)
                  approve.mutate(
                    { shiftId: row.shift_id, revision: row.revision },
                    {
                      onSuccess: () =>
                        setNotice({
                          text: t('shiftApprovalDone', { name: row.owner_name }),
                          failed: false,
                        }),
                      onError: (failure) =>
                        setNotice({ text: describeShiftFailure(failure, t), failed: true }),
                    },
                  )
                },
              },
            ]}
          />
        )}
      />
    </Section>
  )
}

function OpenShifts({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context, selection } = usePosSession()
  const confirm = useConfirm()
  const [closing, setClosing] = useState<OpenShiftRow | null>(null)
  const locked = writesLocked(context.data, selection)
  const timeZone = branchTimeZone(context.data)
  const ownShiftId = context.data?.shift?.id ?? null

  const tableKey = 'pos-open-shifts'
  defineTable<OpenShiftRow>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('shiftOthersSearch'),
    emptyMessage: t('shiftOthersEmpty'),
    columns: [
      {
        key: 'owner_name',
        label: t('shiftOwner'),
        default: true,
        render: (row) => (
          <ResourceNameCell
            id={row.id}
            name={row.owner_name}
            secondary={row.register ?? t('shiftNoRegister')}
          />
        ),
      },
      {
        key: 'opened_at',
        label: t('shiftOpenedAt'),
        default: true,
        className: 'whitespace-nowrap',
        render: (row) => formatInstant(row.opened_at, i18n.language, timeZone),
      },
      {
        key: 'opening_float',
        label: t('shiftOpeningFloat'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.opening_float, row.currency),
      },
      {
        key: 'counted',
        label: t('shiftStatusLabel'),
        default: true,
        sortable: false,
        render: (row) => (
          <Badge variant={row.counted ? 'secondary' : 'outline'}>
            {t(row.counted ? 'shiftStatusCounted' : 'shiftStatusOpen')}
          </Badge>
        ),
      },
      ...hiddenTimestamps<OpenShiftRow>(),
    ],
  })

  return (
    <Section title={t('shiftOthersTitle')} hint={t('shiftOthersHint')}>
      <ResourceTable<OpenShiftRow>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'shift-close', 'open', branchId, ownShiftId]}
        queryFn={(params: Record<string, unknown>) => fetchOpenShifts(branchId, ownShiftId, params)}
        searchParams={ONE_PAGE}
        rowActions={(row) => (
          <RowActions
            actions={[
              {
                key: 'close',
                label: t('shiftCloseFor', { name: row.owner_name }),
                disabled: locked,
                onSelect: async () => {
                  if (
                    await confirm({
                      message: t('shiftCloseForConfirm', { name: row.owner_name }),
                      variant: 'destructive',
                      confirmLabel: t('shiftCloseFor', { name: row.owner_name }),
                      cancelLabel: t('adminCancel'),
                    })
                  )
                    setClosing(row)
                },
              },
            ]}
          />
        )}
      />
      {closing && (
        <ShiftCloseDialog
          shiftId={closing.id}
          ownerName={closing.owner_name}
          timeZone={timeZone}
          onClose={() => setClosing(null)}
        />
      )}
    </Section>
  )
}
