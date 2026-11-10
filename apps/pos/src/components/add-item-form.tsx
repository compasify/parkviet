import {
  describeTraceFailure,
  formatExpiry,
  parseSerials,
  serialListAfterTab,
} from '@parkviet/pos-shared/traceability';
import { useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTraceability, useVariantUnit } from '../hooks/use-variant-unit';
import type { PosWorkspace } from '../lib/pos-context';
import { parseCountQuantity, parseMeasuredQuantity } from '../lib/quantity';

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
// sale quantity. Serial variants take one scanned or typed serial per unit and
// the count of serials is the quantity; the server reserves them at once.
// Lot variants get their lot from the server (FEFO) unless the branch lets the
// cashier pick one.
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
  const queryClient = useQueryClient();
  const unit = useVariantUnit(storeId, branchId, variantId);
  const configured = unit.data?.data;
  const trackedMode = configured?.tracked_mode ?? 'none';
  const tracked = trackedMode === 'serial' || trackedMode === 'lot';
  const trace = useTraceability(storeId, branchId, tracked ? variantId : null);
  const [quantity, setQuantity] = useState('1');
  const [saleQuantity, setSaleQuantity] = useState('');
  const [lotCode, setLotCode] = useState('');
  const [serials, setSerials] = useState('');
  const [merge, setMerge] = useState(false);
  const [error, setError] = useState('');

  const status = trace.data?.data;
  const serialMode = trackedMode === 'serial';
  const lotPick = trackedMode === 'lot' && status?.lot_selection === 'cashier_pick';
  const measured = configured ? configured.sale_unit !== configured.base_unit : false;
  const count = parseCountQuantity(quantity);
  const measuredQuantity = parseMeasuredQuantity(saleQuantity);
  const parsedSerials = parseSerials(serials);
  const quantityValid = serialMode
    ? parsedSerials.codes.length > 0
    : measured
      ? measuredQuantity !== null
      : count !== null;
  const locked = disabled;

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (locked) return;
    if (serialMode) {
      if (parsedSerials.tooLong.length || parsedSerials.duplicates.length) {
        setError(
          t(parsedSerials.tooLong.length ? 'inventorySerialTooLong' : 'saleLineSerialDuplicate', {
            codes: [...parsedSerials.tooLong, ...parsedSerials.duplicates].join(', '),
          }),
        );
        return;
      }
      if (!parsedSerials.codes.length) {
        setError(t('traceReason_trace_serial_required'));
        return;
      }
    } else if (!quantityValid) {
      setError(t(measured ? 'saleLineInvalidQuantity' : 'saleLineInvalidCount'));
      return;
    }
    setError('');
    try {
      await onAdd(
        variantId,
        serialMode ? parsedSerials.codes.length : measured ? 1 : (count ?? 1),
        {
          sale_quantity: measured && !serialMode ? (measuredQuantity ?? undefined) : undefined,
          sale_unit_code: measured && !serialMode ? configured?.sale_unit : undefined,
          lot_code: lotPick ? lotCode || undefined : undefined,
          serial_codes: serialMode ? parsedSerials.codes : undefined,
          merge: merge || undefined,
        },
      );
      setSaleQuantity('');
      setLotCode('');
      setSerials('');
      // The add reserved serials or lots: available counts changed.
      void queryClient.invalidateQueries({ queryKey: ['pos', 'traceability'] });
    } catch (failure) {
      setError(describeTraceFailure(failure, t, 'saleLineAddFailed'));
    }
  }

  return (
    <form className="add-item-form" onSubmit={submit}>
      <span>
        {configured
          ? `${t('saleLineUnit')}: ${configured.sale_unit} / ${configured.base_unit}`
          : t('waiting')}
      </span>
      {serialMode ? (
        <label>
          {t('saleLineSerials')}
          <textarea
            rows={3}
            value={serials}
            onChange={(event) => setSerials(event.target.value)}
            onKeyDown={(event) => {
              // A Tab-terminated scan stays in the list as a line break.
              if (event.key !== 'Tab') return;
              const next = serialListAfterTab(event.currentTarget.value, event.shiftKey);
              if (next === null) return;
              event.preventDefault();
              setSerials(next);
            }}
            disabled={locked}
            title={disabledReason}
            aria-describedby={`serial-hint-${variantId}`}
            placeholder="SN-1"
          />
          <small id={`serial-hint-${variantId}`}>
            {t('saleLineSerialHint', { count: parsedSerials.codes.length })}
            {status
              ? ` · ${t('saleLineSerialsAvailable', { count: status.serials_available })}`
              : ''}
          </small>
        </label>
      ) : measured ? (
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
            aria-invalid={count === null}
            value={quantity}
            onChange={(event) => setQuantity(event.target.value)}
            disabled={locked}
            title={disabledReason}
          />
        </label>
      )}
      {lotPick ? (
        <label>
          {t('saleLineLot')}
          <select
            value={lotCode}
            onChange={(event) => setLotCode(event.target.value)}
            disabled={locked}
            title={disabledReason}
          >
            <option value="">{t('saleLineLotAuto')}</option>
            {(status?.lots ?? []).map((lot) => (
              <option key={lot.id} value={lot.lot_code}>
                {t('saleLineLotOption', {
                  code: lot.lot_code,
                  expiry: formatExpiry(lot.expiry_on),
                  available: lot.available,
                  unit: lot.base_unit,
                })}
              </option>
            ))}
          </select>
        </label>
      ) : trackedMode === 'lot' && status ? (
        <p className="muted">{t('saleLineLotFefo')}</p>
      ) : null}
      {tracked && status?.blocked_reason ? (
        <p className="error" role="status">
          {t(`inventoryBlocked_${status.blocked_reason}`)}
        </p>
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
