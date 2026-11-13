import { moduleUis, skuEditorAreas } from '@parkviet/pos-shared/module-registry'
import { moduleTextKey } from '@parkviet/pos-shared/pos-modules'
import { describeFailure, posFailureKey } from '@parkviet/pos-shared/request-failure'
import { describeTraceFailure } from '@parkviet/pos-shared/traceability'
import type { PosVariantUnit } from '@parkviet/pos-shared/types/pos-context'
import { mapSpreeErrorsToForm, useResourceMutation } from '@spree/dashboard-core'
import { Button, DialogBody, DialogFooter, FieldDescription } from '@spree/dashboard-ui'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { type BranchProduct, useUnitDefinitions } from '../hooks/use-branch-catalog'
import { useBranchFeatures } from '../hooks/use-branch-features'
import { useBranchModules } from '../hooks/use-branch-modules'
import { fetchCatalogPage } from '../hooks/use-catalog'
import { useSession } from '../hooks/use-session'
import { saveVariantUnit, useVariantUnit } from '../hooks/use-variant-unit'
import { unitRatio, type VariantUnitFormValues, variantUnitSchema } from '../schemas/variant-unit'
import { TopologyDialog } from './topology-dialog'
import { Input, TopologyField, TopologySelect } from './topology-fields'

function draftFrom(unit: PosVariantUnit): VariantUnitFormValues {
  return {
    sale_unit: unit.sale_unit,
    price_unit: unit.price_unit,
    ratio_numerator: String(unit.ratio_numerator),
    ratio_denominator: String(unit.ratio_denominator),
    tracked_mode: unit.tracked_mode as VariantUnitFormValues['tracked_mode'],
    label_code: unit.label_code ?? '',
  }
}
export function VariantUnitEditor({
  branchId,
  storeId,
  product,
  canWrite,
  onClose,
}: {
  branchId: string
  storeId: string | null
  product: BranchProduct
  canWrite: boolean
  onClose: () => void
}) {
  const { t } = useTranslation()
  const snapshot = useSession()
  const client = useQueryClient()
  const variants = useQuery({
    queryKey: ['pos', storeId, 'catalog', branchId, 'product', product.id],
    enabled: snapshot.status === 'authenticated',
    queryFn: async () =>
      (await fetchCatalogPage(branchId, { q: product.name, limit: 100 })).data.filter(
        (variant) => variant.product_id === product.id,
      ),
  })
  const [variantId, setVariantId] = useState('')
  const variantRows = variants.data ?? []
  const selectedId = variantId || variantRows[0]?.id || ''
  const unit = useVariantUnit(storeId, branchId, selectedId || null)
  const units = useUnitDefinitions(branchId, true)
  const loaded = unit.data?.data
  const form = useForm<VariantUnitFormValues>({
    defaultValues: {
      sale_unit: '',
      price_unit: '',
      ratio_numerator: '1',
      ratio_denominator: '1',
      tracked_mode: 'none',
      label_code: '',
    },
  })
  const draft = form.watch()
  const dirty = form.formState.isDirty
  const [error, setError] = useState('')
  const [saved, setSaved] = useState('')
  const [draftVariant, setDraftVariant] = useState('')
  useEffect(() => {
    if (loaded) {
      form.reset(draftFrom(loaded))
      setDraftVariant(selectedId)
    }
  }, [loaded, selectedId, form])
  const switches = useBranchFeatures(branchId, canWrite)
  const trackingOff = Boolean(
    switches.data?.reported && switches.data.store_defaults.traceability !== true,
  )
  const areas = skuEditorAreas(useBranchModules(branchId))
  const showUnits =
    areas.has('units') ||
    Boolean(
      loaded &&
        (loaded.sale_unit !== loaded.base_unit ||
          loaded.ratio_numerator !== loaded.ratio_denominator),
    )
  const showTracking =
    areas.has('traceability') || Boolean(loaded && loaded.tracked_mode !== 'none')
  const showLabelCode = areas.has('measured') || Boolean(loaded?.label_code)
  const trackedModes = ['none', 'lot', 'serial'].filter(
    (mode) => areas.has('traceability') || mode === 'none' || mode === loaded?.tracked_mode,
  )
  const offModules = moduleUis.filter((module) => module.skuEditor && !areas.has(module.skuEditor))
  const definitions = units.data?.data ?? []
  const saleUnit = definitions.find((item) => item.code === draft.sale_unit)
  const baseUnit = saleUnit?.base_code ?? ''
  const priceOptions = definitions.filter(
    (item) => item.code === draft.sale_unit || item.dimension === saleUnit?.dimension,
  )
  const numerator = unitRatio(draft.ratio_numerator)
  const denominator = unitRatio(draft.ratio_denominator)
  const labelCodeValid = /^\d{0,8}$/.test(draft.label_code.trim())
  const valid = Boolean(
    variantUnitSchema.safeParse(draft).success &&
      saleUnit &&
      priceOptions.some((option) => option.code === draft.price_unit),
  )
  const mutation = useResourceMutation({
    mutationFn: saveVariantUnit,
    successMessage: false,
    errorMessage: false,
  })
  const busy = form.formState.isSubmitting
  function set<K extends keyof VariantUnitFormValues>(key: K, value: VariantUnitFormValues[K]) {
    form.setValue(key, value as never, { shouldDirty: true })
    if (key === 'sale_unit') {
      const sale = definitions.find((item) => item.code === value)
      const price = definitions.find((item) => item.code === draft.price_unit)
      if (!sale || !price || price.dimension !== sale.dimension)
        form.setValue('price_unit', value, { shouldDirty: true })
    }
    setSaved('')
  }
  async function submit(values: VariantUnitFormValues) {
    if (!canWrite || !valid || !loaded || draftVariant !== selectedId || busy) return
    form.clearErrors()
    const parsed = variantUnitSchema.safeParse(values)
    if (!parsed.success) {
      for (const issue of parsed.error.issues)
        form.setError(issue.path[0] as keyof VariantUnitFormValues, { message: t(issue.message) })
      return
    }
    setError('')
    setSaved('')
    try {
      await mutation.mutateAsync({
        branch_id: branchId,
        variant_id: selectedId,
        ...parsed.data,
        base_unit: baseUnit,
        ratio_numerator: numerator!,
        ratio_denominator: denominator!,
      })
      form.reset(values)
      setSaved(t('variantUnitSaved'))
      await client.invalidateQueries({ queryKey: ['pos', storeId, 'variant-unit'] })
    } catch (failure) {
      mapSpreeErrorsToForm(failure, form.setError)
      setError(describeTraceFailure(failure, t))
    }
  }
  const loadError = variants.error ?? unit.error ?? units.error
  const loadedDraft = Boolean(loaded && draftVariant === selectedId)
  const select = (
    key: keyof VariantUnitFormValues,
    label: string,
    options: { value: string; label: string; disabled?: boolean }[],
    hint?: string,
  ) => (
    <TopologyField
      label={t(label)}
      hint={hint && t(hint)}
      error={form.formState.errors[key]?.message}
    >
      {(id, describedBy) => (
        <TopologySelect
          id={id}
          describedBy={describedBy}
          value={draft[key]}
          onChange={(value) => set(key, value as never)}
          options={options}
          disabled={!canWrite}
        />
      )}
    </TopologyField>
  )
  const input = (
    key: keyof VariantUnitFormValues,
    label: string,
    invalid: boolean,
    hint?: string,
  ) => (
    <TopologyField
      label={t(label)}
      hint={hint && t(hint)}
      error={form.formState.errors[key]?.message}
    >
      {(id, describedBy) => (
        <Input
          id={id}
          aria-describedby={describedBy}
          inputMode="numeric"
          value={draft[key]}
          aria-invalid={invalid || Boolean(form.formState.errors[key])}
          readOnly={!canWrite}
          maxLength={key === 'label_code' ? 8 : undefined}
          onChange={(e) => set(key, e.target.value as never)}
        />
      )}
    </TopologyField>
  )
  return (
    <TopologyDialog
      title={t('variantUnitTitle')}
      subtitle={product.name}
      dirty={dirty}
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          onSubmit={form.handleSubmit(submit)}
          aria-busy={busy}
          className="flex min-h-0 flex-col"
        >
          <DialogBody className="space-y-5">
            <fieldset disabled={busy} className="space-y-4">
              {variants.isPending && <p role="status">{t('waiting')}</p>}
              {variants.isSuccess && variantRows.length === 0 && (
                <p role="alert" className="text-destructive">
                  {t('variantUnitNoVariants')}
                </p>
              )}
              {variantRows.length > 0 && (
                <TopologyField
                  label={t('variantUnitVariant')}
                  hint={dirty && variantRows.length > 1 ? t('variantUnitSwitchHint') : undefined}
                >
                  {(id, describedBy) => (
                    <TopologySelect
                      id={id}
                      describedBy={describedBy}
                      value={selectedId}
                      disabled={variantRows.length < 2 || dirty}
                      options={variantRows.map((variant) => ({
                        value: variant.id,
                        label: `${variant.sku || variant.name}${variant.barcode ? ` · ${variant.barcode}` : ''}`,
                      }))}
                      onChange={(value) => {
                        setVariantId(value)
                        setDraftVariant('')
                        setSaved('')
                        setError('')
                      }}
                    />
                  )}
                </TopologyField>
              )}
              {loadError && (
                <div role="alert">
                  <p>
                    {t('variantUnitLoadFailed', {
                      reason:
                        posFailureKey(loadError) === 'missing'
                          ? t('variantUnitNotSold')
                          : describeFailure(loadError, t),
                    })}
                  </p>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() =>
                      void Promise.all([variants.refetch(), unit.refetch(), units.refetch()])
                    }
                  >
                    {t('retry')}
                  </Button>
                </div>
              )}
              {selectedId && !loadedDraft && !loadError && <p role="status">{t('waiting')}</p>}
              {loadedDraft && (
                <>
                  <div className="grid gap-4 sm:grid-cols-2">
                    {showUnits && (
                      <>
                        {select(
                          'sale_unit',
                          'variantUnitSale',
                          definitions.map((item) => ({
                            value: item.code,
                            label: `${item.name} (${item.code})`,
                          })),
                        )}
                        <TopologyField label={t('variantUnitBase')} hint={t('variantUnitBaseHint')}>
                          {(id, describedBy) => (
                            <Input
                              id={id}
                              aria-describedby={describedBy}
                              value={baseUnit}
                              readOnly
                            />
                          )}
                        </TopologyField>
                        {select(
                          'price_unit',
                          'variantUnitPrice',
                          priceOptions.map((item) => ({
                            value: item.code,
                            label: `${item.name} (${item.code})`,
                          })),
                        )}
                      </>
                    )}
                    {showTracking &&
                      select(
                        'tracked_mode',
                        'variantUnitTracked',
                        trackedModes.map((mode) => ({
                          value: mode,
                          label: t(`variantUnitTracked_${mode}`),
                          disabled: trackingOff && mode !== 'none' && mode !== loaded?.tracked_mode,
                        })),
                        trackingOff ? 'variantUnitTrackingOff' : undefined,
                      )}
                    {showUnits && (
                      <>
                        {input('ratio_numerator', 'variantUnitRatioNumerator', numerator === null)}
                        {input(
                          'ratio_denominator',
                          'variantUnitRatioDenominator',
                          denominator === null,
                        )}
                      </>
                    )}
                  </div>
                  {(numerator === null || denominator === null) && (
                    <p role="alert" className="text-destructive">
                      {t('variantUnitRatioInvalid')}
                    </p>
                  )}
                  {showLabelCode &&
                    input(
                      'label_code',
                      'variantUnitLabelCode',
                      !labelCodeValid,
                      'variantUnitLabelCodeHint',
                    )}
                  {!labelCodeValid && (
                    <p role="alert" className="text-destructive">
                      {t('variantUnitLabelCodeInvalid')}
                    </p>
                  )}
                  <FieldDescription>{t('variantUnitLockNote')}</FieldDescription>
                  {offModules.map((module) => (
                    <p role="note" key={module.key}>
                      {t(
                        moduleTextKey(module.key)
                          ? `posModules.${moduleTextKey(module.key)}.off`
                          : 'moduleOff',
                      )}
                    </p>
                  ))}
                </>
              )}
            </fieldset>
            {error && (
              <p role="alert" className="text-destructive">
                {error}
              </p>
            )}
            {saved && <p role="status">{saved}</p>}
          </DialogBody>
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={close}>
              {t(canWrite ? 'adminCancel' : 'adminClose')}
            </Button>
            {canWrite && (
              <Button
                type="submit"
                disabled={busy || !dirty || !valid || !loadedDraft || Boolean(loadError)}
              >
                {t(busy ? 'waiting' : 'save')}
              </Button>
            )}
          </DialogFooter>
        </form>
      )}
    </TopologyDialog>
  )
}
