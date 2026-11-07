import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTraceability, useVariantUnit } from '../hooks/use-variant-unit';
import type { PosWorkspace } from '../lib/pos-context';
import { parseCountQuantity, parseMeasuredQuantity } from '../lib/quantity';
import { describeFailure } from '../lib/request-failure';

export type SaleLineAddExtra = Partial<{
  sale_quantity: string;
  sale_unit_code: string;
  lot_code: string;
  expiry_on: string;
  serial_codes: string[];
  price_override: string;
  merge: boolean;
}>;

// Add row for one catalog variant. Measured variants take an exact decimal
// sale quantity; tracked variants take draft lot/serial text only — selection
// never claims stock is reserved (reservation stays unavailable_phase_8).
export function AddItemForm({
  storeId,
  branchId,
  variantId,
  disabled,
  disabledReason,
  onAdd,
}: {
  storeId: string | null;
  branchId: string | null;
  variantId: string;
  disabled: boolean;
  disabledReason?: string;
  onAdd: (variantId: string, quantity: number, extra: SaleLineAddExtra) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const unit = useVariantUnit(storeId, branchId, variantId);
  const trace = useTraceability(storeId, branchId, variantId);
  const [quantity, setQuantity] = useState('1');
  const [saleQuantity, setSaleQuantity] = useState('');
  const [lotCode, setLotCode] = useState('');
  const [serials, setSerials] = useState('');
  const [merge, setMerge] = useState(false);
  const [error, setError] = useState('');

  const configured = unit.data?.data;
  const measured = configured ? configured.sale_unit !== configured.base_unit : false;
  const trackedMode = configured?.tracked_mode ?? 'none';
  const count = parseCountQuantity(quantity);
  const measuredQuantity = parseMeasuredQuantity(saleQuantity);
  const quantityValid = measured ? measuredQuantity !== null : count !== null;
  const locked = disabled;
  const serialList = serials
    .split(/[\s,]+/)
    .map((code) => code.trim())
    .filter(Boolean);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (locked) return;
    if (!quantityValid) {
      setError(t(measured ? 'saleLineInvalidQuantity' : 'saleLineInvalidCount'));
      return;
    }
    setError('');
    try {
      await onAdd(variantId, measured ? 1 : (count ?? 1), {
        sale_quantity: measured ? (measuredQuantity ?? undefined) : undefined,
        sale_unit_code: measured ? configured?.sale_unit : undefined,
        lot_code: lotCode.trim() || undefined,
        serial_codes: serialList.length ? serialList : undefined,
        merge: merge || undefined,
      });
      setSaleQuantity('');
      setLotCode('');
      setSerials('');
    } catch (failure) {
      setError(describeFailure(failure, t, 'saleLineAddFailed'));
    }
  }

  return (
    <form className="add-item-form" onSubmit={submit}>
      <span>
        {configured
          ? `${t('saleLineUnit')}: ${configured.sale_unit} / ${configured.base_unit}`
          : t('waiting')}
      </span>
      {measured ? (
        <label>
          {t('saleLineSaleQuantity')} ({configured?.sale_unit})
          <input
            inputMode="decimal"
            value={saleQuantity}
            onChange={(event) => setSaleQuantity(event.target.value)}
            disabled={locked}
            title={disabledReason}
          />
        </label>
      ) : (
        <label>
          {t('quantity')}
          <input
            inputMode="numeric"
            aria-invalid={!measured && count === null}
            value={quantity}
            onChange={(event) => setQuantity(event.target.value)}
            disabled={locked}
            title={disabledReason}
          />
        </label>
      )}
      {trackedMode !== 'none' ? (
        <>
          <p role="status">{t('saleLineReservationUnavailable')}</p>
          <label>
            {t('saleLineLot')}
            <input
              value={lotCode}
              onChange={(event) => setLotCode(event.target.value)}
              disabled={locked}
              title={disabledReason}
            />
          </label>
          <label>
            {t('saleLineSerials')}
            <input
              value={serials}
              onChange={(event) => setSerials(event.target.value)}
              disabled={locked}
              title={disabledReason}
              placeholder="SN-1, SN-2"
            />
          </label>
        </>
      ) : null}
      {trace.data?.data.reservation === 'unavailable_phase_8' && trackedMode !== 'none' ? (
        <p className="muted">{t('saleLineDraftOnly')}</p>
      ) : null}
      <label>
        <input
          type="checkbox"
          checked={merge}
          disabled={locked}
          title={disabledReason}
          onChange={(event) => setMerge(event.target.checked)}
        />
        {t('saleLineMerge')}
      </label>
      <button type="submit" disabled={locked || unit.isLoading} title={disabledReason}>
        {t('addItem')}
      </button>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </form>
  );
}
