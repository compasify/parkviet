import { useQuery } from '@tanstack/react-query';
import { type FormEvent, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { type BranchProduct, useUnitDefinitions } from '../hooks/use-branch-catalog';
import { fetchCatalogPage } from '../hooks/use-catalog';
import { useSession } from '../hooks/use-session';
import { saveVariantUnit, useVariantUnit } from '../hooks/use-variant-unit';
import type { PosVariantUnit } from '../lib/pos-context';
import { queryClient } from '../lib/query-client';
import { describeFailure, posFailureKey } from '../lib/request-failure';
import { describeTraceFailure } from '../lib/traceability';
import { AdminDialog } from './admin-dialog';

const TRACKED_MODES = ['none', 'lot', 'serial'] as const;
const MAX_RATIO = 1_000_000;

type UnitDraft = {
  sale_unit: string;
  price_unit: string;
  ratio_numerator: string;
  ratio_denominator: string;
  tracked_mode: string;
  label_code: string;
};

function draftFrom(unit: PosVariantUnit): UnitDraft {
  return {
    sale_unit: unit.sale_unit,
    price_unit: unit.price_unit,
    ratio_numerator: String(unit.ratio_numerator),
    ratio_denominator: String(unit.ratio_denominator),
    tracked_mode: unit.tracked_mode,
    label_code: unit.label_code ?? '',
  };
}

function ratio(input: string): number | null {
  if (!/^\d{1,7}$/.test(input.trim())) return null;
  const value = Number(input.trim());
  return value >= 1 && value <= MAX_RATIO ? value : null;
}

// Unit conversion and scale-label code of one SKU sold at a branch. The server
// accepts a label-code change at any time but refuses a conversion change once
// the SKU has been sold.
export function VariantUnitEditor({
  branchId,
  storeId,
  product,
  canWrite,
  onClose,
}: {
  branchId: string;
  storeId: string | null;
  product: BranchProduct;
  canWrite: boolean;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const snapshot = useSession();
  // Branch catalog search returns the variants of assigned products only.
  const variants = useQuery({
    queryKey: ['pos', 'catalog', snapshot.generation, storeId, branchId, 'product', product.id],
    enabled: snapshot.status === 'authenticated',
    queryFn: async () => {
      const page = await fetchCatalogPage(branchId, { q: product.name, limit: 100 });
      return page.data.filter((variant) => variant.product_id === product.id);
    },
  });
  const [variantId, setVariantId] = useState('');
  const variantRows = variants.data ?? [];
  const selectedId = variantId || variantRows[0]?.id || '';
  const unit = useVariantUnit(storeId, branchId, selectedId || null);
  const units = useUnitDefinitions(branchId, true);
  const [draft, setDraft] = useState<UnitDraft | null>(null);
  const [dirty, setDirty] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [saved, setSaved] = useState('');
  const loaded = unit.data?.data;
  useEffect(() => {
    if (loaded) {
      setDraft(draftFrom(loaded));
      setDirty(false);
    }
  }, [loaded]);

  const definitions = units.data?.data ?? [];
  const saleUnit = definitions.find((item) => item.code === draft?.sale_unit);
  const baseUnit = saleUnit?.base_code ?? '';
  const priceOptions = definitions.filter(
    (item) => item.code === draft?.sale_unit || item.dimension === saleUnit?.dimension,
  );
  const numerator = draft ? ratio(draft.ratio_numerator) : null;
  const denominator = draft ? ratio(draft.ratio_denominator) : null;
  const labelCodeValid = draft ? /^\d{0,8}$/.test(draft.label_code.trim()) : false;
  const valid = Boolean(
    draft && saleUnit && numerator !== null && denominator !== null && labelCodeValid,
  );

  function set(key: keyof UnitDraft, value: string) {
    setDraft((current) => {
      if (!current) return current;
      const next = { ...current, [key]: value };
      // A new sale unit resets the price unit when the old one no longer fits.
      if (key === 'sale_unit') {
        const sale = definitions.find((item) => item.code === value);
        const price = definitions.find((item) => item.code === current.price_unit);
        if (!sale || !price || price.dimension !== sale.dimension) next.price_unit = value;
      }
      return next;
    });
    setDirty(true);
    setSaved('');
  }

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!draft || !valid || !canWrite || busy || numerator === null || denominator === null) return;
    setBusy(true);
    setError('');
    setSaved('');
    try {
      await saveVariantUnit({
        branch_id: branchId,
        variant_id: selectedId,
        sale_unit: draft.sale_unit,
        base_unit: baseUnit,
        price_unit: draft.price_unit,
        ratio_numerator: numerator,
        ratio_denominator: denominator,
        tracked_mode: draft.tracked_mode,
        label_code: draft.label_code.trim(),
      });
      setDirty(false);
      setSaved(t('variantUnitSaved'));
      await queryClient.invalidateQueries({ queryKey: ['pos', 'variant-unit'] });
    } catch (failure) {
      setError(describeTraceFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  const loadError = variants.error ?? unit.error ?? units.error;
  return (
    <AdminDialog
      id="variant-unit-editor"
      title={t('variantUnitTitle')}
      subtitle={product.name}
      busy={busy}
      dirty={dirty}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={submit} aria-busy={busy}>
          <fieldset className="admin-form-fields" disabled={busy}>
            {variants.isSuccess && variantRows.length === 0 ? (
              <p className="error" role="alert">
                {t('variantUnitNoVariants')}
              </p>
            ) : null}
            {variantRows.length > 0 ? (
              <label>
                {t('variantUnitVariant')}
                <select
                  aria-label={t('variantUnitVariant')}
                  value={selectedId}
                  disabled={variantRows.length < 2 || dirty}
                  aria-describedby={dirty ? 'variant-unit-switch-hint' : undefined}
                  onChange={(event) => {
                    setVariantId(event.target.value);
                    setDraft(null);
                    setSaved('');
                    setError('');
                  }}
                >
                  {variantRows.map((variant) => (
                    <option key={variant.id} value={variant.id}>
                      {variant.sku || variant.name}
                      {variant.barcode ? ` · ${variant.barcode}` : ''}
                    </option>
                  ))}
                </select>
                {dirty && variantRows.length > 1 ? (
                  <small id="variant-unit-switch-hint">{t('variantUnitSwitchHint')}</small>
                ) : null}
              </label>
            ) : null}
            {loadError ? (
              <p className="error" role="alert">
                {t('variantUnitLoadFailed', {
                  reason:
                    posFailureKey(loadError) === 'missing'
                      ? t('variantUnitNotSold')
                      : describeFailure(loadError, t),
                })}
              </p>
            ) : null}
            {selectedId && !draft && !loadError ? <p role="status">{t('waiting')}</p> : null}
            {draft ? (
              <>
                <div className="admin-form-grid">
                  <label>
                    {t('variantUnitSale')}
                    <select
                      aria-label={t('variantUnitSale')}
                      value={draft.sale_unit}
                      disabled={!canWrite}
                      onChange={(event) => set('sale_unit', event.target.value)}
                    >
                      {definitions.map((item) => (
                        <option key={item.code} value={item.code}>
                          {item.name} ({item.code})
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    {t('variantUnitBase')}
                    <input
                      aria-label={t('variantUnitBase')}
                      value={baseUnit}
                      readOnly
                      aria-describedby="variant-unit-base-hint"
                    />
                    <small id="variant-unit-base-hint">{t('variantUnitBaseHint')}</small>
                  </label>
                  <label>
                    {t('variantUnitPrice')}
                    <select
                      aria-label={t('variantUnitPrice')}
                      value={draft.price_unit}
                      disabled={!canWrite}
                      onChange={(event) => set('price_unit', event.target.value)}
                    >
                      {priceOptions.map((item) => (
                        <option key={item.code} value={item.code}>
                          {item.name} ({item.code})
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    {t('variantUnitTracked')}
                    <select
                      aria-label={t('variantUnitTracked')}
                      value={draft.tracked_mode}
                      disabled={!canWrite}
                      onChange={(event) => set('tracked_mode', event.target.value)}
                    >
                      {TRACKED_MODES.map((mode) => (
                        <option key={mode} value={mode}>
                          {t(`variantUnitTracked_${mode}`)}
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    {t('variantUnitRatioNumerator')}
                    <input
                      aria-label={t('variantUnitRatioNumerator')}
                      inputMode="numeric"
                      required
                      readOnly={!canWrite}
                      value={draft.ratio_numerator}
                      aria-invalid={numerator === null}
                      onChange={(event) => set('ratio_numerator', event.target.value)}
                    />
                  </label>
                  <label>
                    {t('variantUnitRatioDenominator')}
                    <input
                      aria-label={t('variantUnitRatioDenominator')}
                      inputMode="numeric"
                      required
                      readOnly={!canWrite}
                      value={draft.ratio_denominator}
                      aria-invalid={denominator === null}
                      onChange={(event) => set('ratio_denominator', event.target.value)}
                    />
                  </label>
                </div>
                {numerator === null || denominator === null ? (
                  <p className="error" role="alert">
                    {t('variantUnitRatioInvalid')}
                  </p>
                ) : null}
                <label>
                  {t('variantUnitLabelCode')}
                  <input
                    aria-label={t('variantUnitLabelCode')}
                    inputMode="numeric"
                    maxLength={8}
                    readOnly={!canWrite}
                    value={draft.label_code}
                    aria-invalid={!labelCodeValid}
                    aria-describedby="variant-unit-label-hint"
                    onChange={(event) => set('label_code', event.target.value)}
                  />
                  <small id="variant-unit-label-hint">{t('variantUnitLabelCodeHint')}</small>
                </label>
                {!labelCodeValid ? (
                  <p className="error" role="alert">
                    {t('variantUnitLabelCodeInvalid')}
                  </p>
                ) : null}
                <p className="admin-info">{t('variantUnitLockNote')}</p>
              </>
            ) : null}
          </fieldset>
          {error ? (
            <p role="alert" className="error">
              {error}
            </p>
          ) : null}
          {saved ? (
            <p role="status" className="page-success">
              {saved}
            </p>
          ) : null}
          <div className="topology-dialog-actions">
            <button type="button" disabled={busy} onClick={close}>
              {t(canWrite ? 'adminCancel' : 'adminClose')}
            </button>
            {canWrite ? (
              <button type="submit" className="primary-button" disabled={busy || !dirty || !valid}>
                {busy ? t('waiting') : t('save')}
              </button>
            ) : null}
          </div>
        </form>
      )}
    </AdminDialog>
  );
}
