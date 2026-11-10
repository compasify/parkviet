import {
  describeInventoryFailure,
  formatExpiry,
  type PosTransferResult,
} from '@parkviet/pos-shared/traceability'
import {
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Input,
  Label,
} from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useFormLots, useInventoryCommand, useInventoryVariants } from '../../hooks/use-inventory'
import { usePosSession } from '../../hooks/use-pos-session'
import { quantity, transferBody } from './inventory-helpers'
import {
  ChoiceField,
  CommandCheck,
  FormError,
  type InventoryScope,
  LotFilter,
  SerialTextarea,
  TraceSummary,
  VariantField,
  VariantsState,
} from './inventory-shared'

// Moves tracked stock to another active branch: serials by code, or amounts
// of the chosen active lots. The server checks stock management at both.
export function TransferPanel({ scope }: { scope: InventoryScope }) {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const variants = useInventoryVariants(scope.branchId)
  const tracked = (variants.data ?? []).filter((row) => row.tracked_mode !== 'none')
  const [variantId, setVariantId] = useState('')
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null
  const [q, setQ] = useState('')
  const lots = useFormLots(
    scope.branchId,
    variant?.variant_id,
    { q, status: 'active' },
    variant?.tracked_mode === 'lot',
  )
  const lotRows = lots.data?.data ?? []
  const destinations = (context.data?.branches ?? []).filter(
    (branch) => branch.id !== scope.branchId && branch.status === 'active',
  )
  const [toBranchId, setToBranchId] = useState('')
  const [serialText, setSerialText] = useState('')
  const [amounts, setAmounts] = useState<Record<string, string>>({})
  const command = useInventoryCommand<PosTransferResult>()
  const [error, setError] = useState('')
  const [result, setResult] = useState<PosTransferResult | null>(null)
  const busy = command.isPending
  const locked = busy || command.uncertain

  return (
    <Card>
      <CardHeader>
        <CardTitle>{t('inventoryTab_transfer')}</CardTitle>
        <CardDescription>{t('inventoryTransferHint')}</CardDescription>
      </CardHeader>
      <CardContent>
        <form
          className="max-w-3xl space-y-4"
          aria-label={t('inventoryTab_transfer')}
          aria-busy={busy}
          onSubmit={(event) => {
            event.preventDefault()
            if (locked || !variant) return
            if (!toBranchId) {
              setError(t('inventoryDestinationRequired'))
              return
            }
            const built = transferBody(variant, serialText, amounts, lotRows)
            if ('error' in built) {
              setError(t(built.error, built.options))
              return
            }
            setError('')
            setResult(null)
            command.run(
              {
                branchId: scope.branchId,
                action: 'transfer',
                path: '/pos/inventory/transfers',
                body: {
                  from_branch_id: scope.branchId,
                  to_branch_id: toBranchId,
                  variant_id: variant.variant_id,
                  ...built.body,
                },
              },
              {
                onSuccess: (data) => {
                  setResult(data)
                  setSerialText('')
                  setAmounts({})
                },
                onError: (failure) => setError(describeInventoryFailure(failure, t)),
              },
            )
          }}
        >
          <VariantsState query={variants} empty={variants.isSuccess && tracked.length === 0} />
          <div className="grid gap-4 sm:grid-cols-2">
            <VariantField
              variants={tracked}
              value={variantId}
              disabled={locked}
              onChange={(value) => {
                setVariantId(value)
                setError('')
                setSerialText('')
                setAmounts({})
                setQ('')
              }}
            />
            <ChoiceField
              label={t('inventoryDestination')}
              value={toBranchId}
              disabled={locked}
              onChange={setToBranchId}
              options={destinations.map((branch) => ({ value: branch.id, label: branch.name }))}
            />
          </div>
          {destinations.length === 0 && (
            <p className="text-sm text-muted-foreground">{t('inventoryNoDestination')}</p>
          )}
          {variant?.tracked_mode === 'serial' && (
            <SerialTextarea
              label={t('inventorySerialList')}
              value={serialText}
              onChange={setSerialText}
              disabled={locked}
            />
          )}
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
                    <li
                      key={lot.id}
                      className="grid items-center gap-2 p-3 sm:grid-cols-[1fr_8rem]"
                    >
                      <Label htmlFor={`transfer-lot-${lot.id}`} className="font-normal">
                        {t('inventoryTransferLot', {
                          code: lot.lot_code,
                          expiry: formatExpiry(lot.expiry_on),
                          available: quantity(lot.available, lot.base_unit),
                        })}
                      </Label>
                      <Input
                        id={`transfer-lot-${lot.id}`}
                        inputMode="numeric"
                        value={amounts[lot.id] ?? ''}
                        disabled={locked}
                        onChange={(event) =>
                          setAmounts({ ...amounts, [lot.id]: event.target.value })
                        }
                      />
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}
          <FormError text={error} />
          <CommandCheck command={command} />
          {result && (
            <>
              <TraceSummary status={result.from} />
              <TraceSummary status={result.to} />
            </>
          )}
          <Button type="submit" disabled={locked || !variant}>
            {busy ? t('waiting') : t('inventoryTransferSubmit')}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}
