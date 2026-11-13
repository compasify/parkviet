import {
  describeInventoryFailure,
  type PosTraceStatus,
  stockEntryPayload,
} from '@parkviet/pos-shared/traceability'
import { defineTable, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  ResourceNameCell,
  RowActions,
} from '@spree/dashboard-ui'
import { PackageIcon, RotateCcwIcon } from '@spree/dashboard-ui/icons'
import { useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  fetchInventoryVariants,
  OPENING_PATH,
  useInventoryCommand,
  useUncertainOpenings,
} from '../../hooks/use-inventory'
import { hiddenTimestamps } from '../../tables/columns'
import { localList } from '../../tables/local-list'
import { quantity } from './inventory-helpers'
import {
  CommandCheck,
  entryError,
  FormError,
  type InventoryScope,
  type Notice,
  NoticeLine,
  StockEntryFields,
  useStockEntry,
} from './inventory-shared'

type VariantRow = PosTraceStatus & { id: string }

// Tracked variants of the branch: tracking mode, enrolment, reconciliation of
// typed stock against core stock, and the opening balance that enrols one.
export function VariantsPanel({ scope }: { scope: InventoryScope }) {
  const { t } = useTranslation()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const [opening, setOpening] = useState<PosTraceStatus | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const uncertainOpening = useUncertainOpenings(scope.branchId)
  const recheck = useInventoryCommand<PosTraceStatus>()

  function checkAgain(row: PosTraceStatus) {
    const body = uncertainOpening(row.variant_id)
    if (!body) return
    setNotice(null)
    // The very body sent before, under its stored key: a committed opening
    // answers from its receipt; a switched-off branch refuses only if it never ran.
    recheck.run(
      { branchId: scope.branchId, action: 'opening', path: OPENING_PATH, body },
      {
        onSuccess: () =>
          setNotice({ text: t('inventoryOpeningDone', { name: row.name }), failed: false }),
        onError: (failure) =>
          setNotice({ text: describeInventoryFailure(failure, t), failed: true }),
      },
    )
  }

  const tableKey = 'pos-inventory-variants'
  defineTable<VariantRow>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('inventoryVariantSearch'),
    emptyMessage: t('inventoryEmpty'),
    columns: [
      {
        key: 'name',
        label: t('orderLineItem'),
        default: true,
        render: (row) => <ResourceNameCell id={row.id} name={row.name} secondary={row.sku} />,
      },
      {
        key: 'tracked_mode',
        label: t('inventoryTrackedMode'),
        default: true,
        render: (row) => t(`variantUnitTracked_${row.tracked_mode}`),
      },
      {
        key: 'enrolled',
        label: t('inventoryEnrollment'),
        default: true,
        sortable: false,
        render: (row) =>
          `${row.enrolled ? t('inventoryEnrolled') : t('inventoryNotEnrolled')} · ${
            row.reconciled ? t('inventoryReconciled') : t('inventoryUnreconciled')
          }`,
      },
      {
        key: 'core_on_hand',
        label: t('inventoryCoreOnHand'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => quantity(row.core_on_hand, row.base_unit),
      },
      {
        key: 'typed_on_hand',
        label: t('inventoryTypedOnHand'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => quantity(row.typed_on_hand, row.base_unit),
      },
      {
        key: 'blocked_reason',
        label: t('inventoryBlocked'),
        default: true,
        sortable: false,
        render: (row) => (
          <span className="inline-flex flex-wrap items-center gap-2">
            {row.blocked_reason ? (
              <Badge variant="warning">{t(`inventoryBlocked_${row.blocked_reason}`)}</Badge>
            ) : (
              <Badge variant="success">{t('inventorySellable')}</Badge>
            )}
            {uncertainOpening(row.variant_id) && (
              <Badge variant="outline">{t('inventoryOpeningUncertain')}</Badge>
            )}
          </span>
        ),
      },
      ...hiddenTimestamps<VariantRow>(),
    ],
  })

  return (
    <div className="space-y-4">
      <p className="text-sm text-muted-foreground">{t('inventoryVariantsHint')}</p>
      <NoticeLine notice={notice} />
      <ResourceTable<VariantRow>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'inventory', 'variants', scope.branchId, 'table']}
        queryFn={async (params: Record<string, unknown>) => {
          const rows = await fetchInventoryVariants(scope.branchId)
          return localList(
            rows.map((row) => ({ ...row, id: row.variant_id })),
            params,
            { searchParam: 'search', text: (row) => `${row.name} ${row.sku}` },
          )
        }}
        searchParams={search}
        rowActions={(row) => {
          const pending = Boolean(uncertainOpening(row.variant_id))
          return (
            <RowActions
              actions={[
                {
                  key: 'recheck',
                  label: t('inventoryOpeningRecheckFor', { name: row.name }),
                  icon: <RotateCcwIcon className="size-4" />,
                  visible: pending,
                  disabled: recheck.isPending,
                  onSelect: () => checkAgain(row),
                },
                {
                  key: 'opening',
                  label: t('inventoryOpeningFor', { name: row.name }),
                  icon: <PackageIcon className="size-4" />,
                  visible: scope.enroll && !row.enrolled && row.tracked_mode !== 'none' && !pending,
                  onSelect: () => {
                    setNotice(null)
                    setOpening(row)
                  },
                },
              ]}
            />
          )
        }}
      />
      {opening && (
        <OpeningDialog
          key={opening.variant_id}
          scope={scope}
          variant={opening}
          onClose={() => setOpening(null)}
          onDone={(name) => {
            setOpening(null)
            setNotice({ text: t('inventoryOpeningDone', { name }), failed: false })
          }}
        />
      )}
    </div>
  )
}

// The opening balance enrols a variant: its serials, or its lots with expiry
// and quantity, which must reconcile with the stock already counted.
function OpeningDialog({
  scope,
  variant,
  onClose,
  onDone,
}: {
  scope: InventoryScope
  variant: PosTraceStatus
  onClose: () => void
  onDone: (name: string) => void
}) {
  const { t } = useTranslation()
  const entry = useStockEntry()
  const command = useInventoryCommand<PosTraceStatus>()
  const [error, setError] = useState('')
  const busy = command.isPending
  const locked = busy || command.uncertain
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{t('inventoryOpeningTitle', { name: variant.name })}</DialogTitle>
          <DialogDescription>
            {t('inventoryOpeningHint', {
              core: quantity(variant.core_on_hand, variant.base_unit),
            })}
          </DialogDescription>
        </DialogHeader>
        <form
          className="flex min-h-0 flex-col"
          aria-busy={busy}
          onSubmit={(event) => {
            event.preventDefault()
            if (locked) return
            const payload = stockEntryPayload(variant.tracked_mode, entry.serialText, entry.lotRows)
            if (!payload.body) {
              setError(entryError(payload, t))
              return
            }
            setError('')
            command.run(
              {
                branchId: scope.branchId,
                action: 'opening',
                path: OPENING_PATH,
                body: {
                  branch_id: scope.branchId,
                  variant_id: variant.variant_id,
                  ...payload.body,
                },
              },
              {
                onSuccess: () => onDone(variant.name),
                onError: (failure) => setError(describeInventoryFailure(failure, t)),
              },
            )
          }}
        >
          <DialogBody className="space-y-4">
            <StockEntryFields
              mode={variant.tracked_mode}
              baseUnit={variant.base_unit}
              entry={entry}
              disabled={locked}
            />
            <FormError text={error} />
            <CommandCheck command={command} />
          </DialogBody>
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={locked}>
              {busy ? t('waiting') : t('inventoryOpeningSubmit')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
