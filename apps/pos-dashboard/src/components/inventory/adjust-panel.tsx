import {
  adjustmentActions,
  describeInventoryFailure,
  type PosAdjustment,
} from '@parkviet/pos-shared/traceability'
import { defineTable, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import { Badge, Button, ResourceNameCell, RowActions } from '@spree/dashboard-ui'
import {
  BanIcon,
  CheckIcon,
  ClipboardCheckIcon,
  PlayIcon,
  RotateCcwIcon,
  SlidersHorizontalIcon,
} from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useSearch } from '@tanstack/react-router'
import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  ADJUSTMENT_POLL_MS,
  fetchAdjustments,
  type InventoryCommandInput,
  useFormLots,
  useInventoryCommand,
  useInventoryVariants,
} from '../../hooks/use-inventory'
import { useSession } from '../../hooks/use-session'
import { formatInstant } from '../../lib/format-time'
import { hiddenTimestamps } from '../../tables/columns'
import { ModelCard } from '../setup/model-ui'
import {
  adjustmentCommandBody,
  type CountDraft,
  countBody,
  quantity,
  variantLabel,
} from './inventory-helpers'
import {
  CommandCheck,
  FormError,
  type InventoryScope,
  LotFilter,
  type Notice,
  NoticeLine,
  ReasonDialog,
  SerialTextarea,
  TextField,
  VariantField,
  VariantsState,
} from './inventory-shared'

// Stock counts: stock keepers count lots or serials and request the
// adjustment; approvers decide the ones waiting, and the requester applies.
export function AdjustPanel({ scope }: { scope: InventoryScope }) {
  // Approvers without stock rights see only the waiting counts.
  const variants = useInventoryVariants(scope.branchId, scope.manage)
  const tracked = (variants.data ?? []).filter((row) => row.tracked_mode !== 'none')
  return (
    <div className="space-y-6">
      {scope.manage && <CountForm scope={scope} variants={variants} />}
      <PendingAdjustments
        scope={scope}
        units={new Map(tracked.map((row) => [row.variant_id, row.base_unit]))}
      />
    </div>
  )
}

function CountForm({
  scope,
  variants,
}: {
  scope: InventoryScope
  variants: ReturnType<typeof useInventoryVariants>
}) {
  const { t } = useTranslation()
  const tracked = (variants.data ?? []).filter((row) => row.tracked_mode !== 'none')
  const [variantId, setVariantId] = useState('')
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null
  const [q, setQ] = useState('')
  const lots = useFormLots(
    scope.branchId,
    variant?.variant_id,
    { q },
    variant?.tracked_mode === 'lot',
  )
  const lotRows = lots.data?.data ?? []
  const [counted, setCounted] = useState<Record<string, CountDraft>>({})
  const [missing, setMissing] = useState('')
  const [found, setFound] = useState('')
  const [reason, setReason] = useState('')
  const command = useInventoryCommand<PosAdjustment>()
  const [error, setError] = useState('')
  const [result, setResult] = useState<PosAdjustment | null>(null)
  const busy = command.isPending
  const locked = busy || command.uncertain

  function setCount(lotId: string, field: keyof CountDraft, value: string) {
    setCounted((current) => ({
      ...current,
      [lotId]: { ...(current[lotId] ?? { counted: '', quarantined: '' }), [field]: value },
    }))
  }

  return (
    <ModelCard
      title={t('inventoryTab_adjust')}
      id="inventory-adjust"
      icon={<SlidersHorizontalIcon />}
    >
      <p className="text-sm text-muted-foreground">{t('inventoryAdjustHint')}</p>
      <form
        className="max-w-3xl space-y-4"
        aria-label={t('inventoryTab_adjust')}
        aria-busy={busy}
        onSubmit={(event) => {
          event.preventDefault()
          if (locked || !variant) return
          const built = countBody(variant, reason, counted, missing, found)
          if ('error' in built) {
            setError(t(built.error, built.options))
            return
          }
          setError('')
          setResult(null)
          command.run(
            {
              branchId: scope.branchId,
              action: 'adjust',
              path: '/pos/inventory/adjustments',
              body: {
                branch_id: scope.branchId,
                variant_id: variant.variant_id,
                reason: reason.trim(),
                ...built.body,
              },
            },
            {
              onSuccess: (adjustment) => {
                setResult(adjustment)
                setCounted({})
                setMissing('')
                setFound('')
                setReason('')
              },
              onError: (failure) => setError(describeInventoryFailure(failure, t)),
            },
          )
        }}
      >
        <VariantsState query={variants} empty={variants.isSuccess && tracked.length === 0} />
        <VariantField
          variants={tracked}
          value={variantId}
          disabled={locked}
          onChange={(value) => {
            setVariantId(value)
            setError('')
            setCounted({})
            setQ('')
          }}
        />
        {variant?.tracked_mode === 'lot' && (
          <div className="space-y-3">
            <LotFilter
              value={q}
              onChange={setQ}
              disabled={locked}
              truncated={(lots.data?.meta?.count ?? 0) > lotRows.length}
            />
            <VariantsState query={lots} empty={lots.isSuccess && lotRows.length === 0} />
            {lotRows.length > 0 && (
              <ul className="divide-y rounded-md border" aria-label={t('inventoryLotList')}>
                {lotRows.map((lot) => (
                  <li key={lot.id} className="grid gap-3 p-3 sm:grid-cols-2">
                    <TextField
                      numeric
                      label={t('inventoryCountLot', {
                        code: lot.lot_code,
                        onHand: quantity(lot.on_hand, lot.base_unit),
                      })}
                      value={counted[lot.id]?.counted ?? ''}
                      disabled={locked}
                      onChange={(value) => setCount(lot.id, 'counted', value)}
                    />
                    {lot.quarantined_quantity > 0 && (
                      <TextField
                        numeric
                        label={t('inventoryCountQuarantined', {
                          code: lot.lot_code,
                          held: quantity(lot.quarantined_quantity, lot.base_unit),
                        })}
                        value={counted[lot.id]?.quarantined ?? ''}
                        disabled={locked}
                        onChange={(value) => setCount(lot.id, 'quarantined', value)}
                      />
                    )}
                  </li>
                ))}
              </ul>
            )}
          </div>
        )}
        {variant?.tracked_mode === 'serial' && (
          <div className="grid gap-4 sm:grid-cols-2">
            <SerialTextarea
              label={t('inventoryMissingSerials')}
              value={missing}
              onChange={setMissing}
              disabled={locked}
              rows={3}
            />
            <SerialTextarea
              label={t('inventoryFoundSerials')}
              value={found}
              onChange={setFound}
              disabled={locked}
              rows={3}
            />
          </div>
        )}
        <TextField
          label={t('inventoryReason')}
          value={reason}
          maxLength={200}
          disabled={locked}
          onChange={setReason}
        />
        <FormError text={error} />
        <CommandCheck command={command} />
        {result && (
          <p role="status" className="text-sm text-muted-foreground">
            {t(`inventoryAdjustmentResult_${result.status}`, {
              name: result.name,
              delta: quantity(result.delta, variant?.base_unit),
            })}
          </p>
        )}
        <Button type="submit" disabled={locked || !variant}>
          {busy ? t('waiting') : t('inventoryAdjustSubmit')}
        </Button>
      </form>
    </ModelCard>
  )
}

function adjustmentLine(
  line: PosAdjustment['lines'][number],
  unit: string | undefined,
  t: (key: string, options?: Record<string, unknown>) => string,
) {
  const label = line.lot_code ?? line.serial ?? ''
  const main = `${label}: ${quantity(line.before, unit)} → ${quantity(line.after, unit)}`
  return line.quarantined_delta
    ? `${main} (${t('inventoryAdjustmentQuarantined', {
        before: quantity(line.quarantined_before, unit),
        after: quantity(line.quarantined_after, unit),
      })})`
    : main
}

// Counts waiting for a decision; the list refreshes itself while any waits
// for someone else to approve or apply it.
function PendingAdjustments({
  scope,
  units,
}: {
  scope: InventoryScope
  units: Map<string, string>
}) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const client = useQueryClient()
  const command = useInventoryCommand<PosAdjustment>()
  const [error, setError] = useState('')
  const [notice, setNotice] = useState<Notice>(null)
  const [canceling, setCanceling] = useState<PosAdjustment | null>(null)
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const waiting = useRef(false)
  const locked = command.isPending || command.uncertain
  const refresh = () =>
    client.invalidateQueries({ queryKey: ['pos', storeId, 'inventory', 'adjustments'] })

  // biome-ignore lint/correctness/useExhaustiveDependencies: the interval only depends on the store
  useEffect(() => {
    const timer = window.setInterval(() => {
      if (waiting.current) void refresh()
    }, ADJUSTMENT_POLL_MS)
    return () => window.clearInterval(timer)
  }, [storeId])

  function send(input: InventoryCommandInput, done: (updated: PosAdjustment) => void) {
    setError('')
    setNotice(null)
    command.run(input, {
      onSuccess: done,
      onError: (failure) => setError(describeInventoryFailure(failure, t)),
    })
  }

  function act(adjustment: PosAdjustment, action: 'approve' | 'apply') {
    send(
      {
        branchId: scope.branchId,
        action: `adjustment.${action}`,
        path: `/pos/inventory/adjustments/${adjustment.id}/${action}`,
        body: adjustmentCommandBody(adjustment, action),
      },
      (updated) =>
        setNotice({
          text: t(`inventoryAdjustmentDone_${action}`, { name: updated.name }),
          failed: false,
        }),
    )
  }

  const tableKey = 'pos-inventory-adjustments'
  defineTable<PosAdjustment>(tableKey, {
    searchParam: 'search',
    emptyMessage: t('inventoryEmpty'),
    columns: [
      {
        key: 'name',
        label: t('orderLineItem'),
        default: true,
        sortable: false,
        render: (row) => (
          <ResourceNameCell id={row.id} name={variantLabel(row)} secondary={row.reason} />
        ),
      },
      {
        key: 'delta',
        label: t('inventoryAdjustmentDeltaLabel'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => quantity(row.delta, units.get(row.variant_id)),
      },
      {
        key: 'lines',
        label: t('inventoryAdjustmentLines'),
        default: true,
        sortable: false,
        className: 'whitespace-normal text-sm',
        render: (row) =>
          row.lines.map((line) => adjustmentLine(line, units.get(row.variant_id), t)).join('; '),
      },
      {
        key: 'requester_name',
        label: t('inventoryAdjustmentRequesterLabel'),
        default: true,
        sortable: false,
        className: 'whitespace-normal',
        render: (row) => (
          <span className="flex flex-col gap-1">
            <span>{row.requester_name}</span>
            <span className="text-xs text-muted-foreground">
              {formatInstant(row.created_at, i18n.language, scope.timeZone)}
            </span>
            {row.approval?.status === 'active' && (
              <Badge variant="success">{t('inventoryApproved')}</Badge>
            )}
          </span>
        ),
      },
      ...hiddenTimestamps<PosAdjustment>(),
    ],
  })

  return (
    <section aria-label={t('inventoryPendingAdjustments')}>
      <ModelCard
        title={t('inventoryPendingAdjustments')}
        id="inventory-pending-adjustments"
        icon={<ClipboardCheckIcon />}
      >
        <NoticeLine notice={notice} />
        {!canceling && <FormError text={error} />}
        {!canceling && <CommandCheck command={command} />}
        <ResourceTable<PosAdjustment>
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'inventory', 'adjustments', scope.branchId, 'pending']}
          queryFn={async (params: Record<string, unknown>) => {
            const page = await fetchAdjustments(scope.branchId, 'pending_approval', params)
            waiting.current = page.data.some((row) => row.status === 'pending_approval')
            return page
          }}
          searchParams={search}
          actions={
            <Button variant="outline" onClick={() => void refresh()}>
              <RotateCcwIcon className="size-4" />
              {t('inventoryRefresh')}
            </Button>
          }
          rowActions={(row) => {
            const actions = adjustmentActions(row, scope.staffId, scope.capabilities)
            return (
              <RowActions
                actions={[
                  {
                    key: 'approve',
                    label: t('inventoryApprove'),
                    icon: <CheckIcon className="size-4" />,
                    visible: actions.approve,
                    disabled: locked,
                    onSelect: () => act(row, 'approve'),
                  },
                  {
                    key: 'apply',
                    label: t('inventoryApply'),
                    icon: <PlayIcon className="size-4" />,
                    visible: actions.apply,
                    disabled: locked,
                    onSelect: () => act(row, 'apply'),
                  },
                  {
                    key: 'cancel',
                    label: t('inventoryCancelAdjustment'),
                    icon: <BanIcon className="size-4" />,
                    visible: actions.cancel,
                    destructive: true,
                    disabled: locked,
                    onSelect: () => {
                      setError('')
                      setNotice(null)
                      setCanceling(row)
                    },
                  },
                ]}
              />
            )
          }}
        />
      </ModelCard>
      {canceling && (
        <ReasonDialog
          title={t('inventoryCancelTitle', { name: canceling.name })}
          submitLabel={t('inventoryCancelAdjustment')}
          destructive
          command={command}
          error={error}
          onClose={() => {
            setCanceling(null)
            setError('')
          }}
          onSubmit={(reason) =>
            send(
              {
                branchId: scope.branchId,
                action: 'adjustment.cancel',
                path: `/pos/inventory/adjustments/${canceling.id}/cancel`,
                body: { reason },
              },
              (updated) => {
                setCanceling(null)
                setNotice({
                  text: t('inventoryAdjustmentDone_cancel', { name: updated.name }),
                  failed: false,
                })
              },
            )
          }
        />
      )}
    </section>
  )
}
