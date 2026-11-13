import {
  describeInventoryFailure,
  type PosTraceStatus,
  stockEntryPayload,
} from '@parkviet/pos-shared/traceability'
import { Button } from '@spree/dashboard-ui'
import { PackageCheckIcon } from '@spree/dashboard-ui/icons'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useInventoryCommand, useInventoryVariants } from '../../hooks/use-inventory'
import { ModelCard } from '../setup/model-ui'
import {
  CommandCheck,
  entryError,
  FormError,
  type InventoryScope,
  StockEntryFields,
  TraceSummary,
  useStockEntry,
  VariantField,
  VariantsState,
} from './inventory-shared'

// Stock received into a tracked variant: serial codes, or lots with expiry.
export function ReceivePanel({ scope }: { scope: InventoryScope }) {
  const { t } = useTranslation()
  const variants = useInventoryVariants(scope.branchId)
  const tracked = (variants.data ?? []).filter((row) => row.tracked_mode !== 'none')
  const [variantId, setVariantId] = useState('')
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null
  const entry = useStockEntry()
  const command = useInventoryCommand<PosTraceStatus>()
  const [error, setError] = useState('')
  const [result, setResult] = useState<PosTraceStatus | null>(null)
  const busy = command.isPending
  const locked = busy || command.uncertain
  return (
    <ModelCard title={t('inventoryTab_receive')} id="inventory-receive" icon={<PackageCheckIcon />}>
      <p className="text-sm text-muted-foreground">{t('inventoryReceiveHint')}</p>
      <form
        className="max-w-3xl space-y-4"
        aria-label={t('inventoryTab_receive')}
        aria-busy={busy}
        onSubmit={(event) => {
          event.preventDefault()
          if (locked || !variant) return
          const payload = stockEntryPayload(variant.tracked_mode, entry.serialText, entry.lotRows)
          if (!payload.body) {
            setError(entryError(payload, t))
            return
          }
          setError('')
          setResult(null)
          command.run(
            {
              branchId: scope.branchId,
              action: 'receive',
              path: '/pos/inventory/receipts',
              body: {
                branch_id: scope.branchId,
                variant_id: variant.variant_id,
                ...payload.body,
              },
            },
            {
              onSuccess: (status) => {
                setResult(status)
                entry.reset()
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
            entry.reset()
          }}
        />
        {variant && (
          <StockEntryFields
            mode={variant.tracked_mode}
            baseUnit={variant.base_unit}
            entry={entry}
            disabled={locked}
          />
        )}
        <FormError text={error} />
        <CommandCheck command={command} />
        {result && <TraceSummary status={result} />}
        <Button type="submit" disabled={locked || !variant}>
          {busy ? t('waiting') : t('inventoryReceiveSubmit')}
        </Button>
      </form>
    </ModelCard>
  )
}
