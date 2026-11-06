import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';

export function LineDiscountForm({
  workspace,
  saleLineId,
  canApplyDiscount,
  canOverridePrice,
  disabled,
  onLineDiscount,
  onClearLineDiscount,
  onPriceOverride,
}: {
  workspace: PosWorkspace;
  saleLineId: string;
  canApplyDiscount: boolean;
  canOverridePrice: boolean;
  disabled: boolean;
  onLineDiscount: (
    saleLineId: string,
    input: { valueType: 'flat' | 'percent'; value: string; reason: string; approvalId?: string },
  ) => Promise<PosWorkspace>;
  onClearLineDiscount: (saleLineId: string, approvalId?: string) => Promise<PosWorkspace>;
  onPriceOverride: (
    saleLineId: string,
    input: { price: string; reason: string; approvalId?: string },
  ) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const line = workspace.line_items?.find((item) => item.sale_line_id === saleLineId);
  const [valueType, setValueType] = useState<'flat' | 'percent'>('percent');
  const [value, setValue] = useState('10');
  const [reason, setReason] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [price, setPrice] = useState('');
  const [priceReason, setPriceReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  if (!line) return null;

  async function run(action: () => Promise<PosWorkspace>) {
    setBusy(true);
    setError('');
    try {
      await action();
    } catch {
      setError(t('saleLineCommandFailed'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="line-discount-form">
      {line.line_discount ? (
        <p>
          {t('discountCurrent')}: {line.line_discount.value}
          {line.line_discount.value_type === 'percent' ? '%' : ''} · {line.line_discount.amount}
        </p>
      ) : null}
      <label>
        {t('discountType')}
        <select
          value={valueType}
          onChange={(event) => setValueType(event.target.value as 'flat' | 'percent')}
          disabled={disabled || busy}
        >
          <option value="percent">{t('discountPercent')}</option>
          <option value="flat">{t('discountFlat')}</option>
        </select>
      </label>
      <label>
        {t('discountValue')}
        <input
          inputMode="decimal"
          value={value}
          onChange={(event) => setValue(event.target.value)}
          disabled={disabled || busy}
        />
      </label>
      <label>
        {t('discountReason')}
        <input
          value={reason}
          onChange={(event) => setReason(event.target.value)}
          disabled={disabled || busy}
        />
      </label>
      {!canApplyDiscount ? (
        <label>
          {t('discountApproval')}
          <input
            value={approvalId}
            onChange={(event) => setApprovalId(event.target.value)}
            disabled={disabled || busy}
          />
        </label>
      ) : null}
      <div className="row">
        <button
          type="button"
          disabled={disabled || busy || !value.trim() || !reason.trim()}
          onClick={() =>
            void run(() =>
              onLineDiscount(saleLineId, {
                valueType,
                value: value.trim(),
                reason: reason.trim(),
                approvalId: approvalId.trim() || undefined,
              }),
            )
          }
        >
          {t('saleLineDiscountApply')}
        </button>
        {line.line_discount ? (
          <button
            type="button"
            disabled={disabled || busy}
            onClick={() =>
              void run(() => onClearLineDiscount(saleLineId, approvalId.trim() || undefined))
            }
          >
            {t('discountClear')}
          </button>
        ) : null}
      </div>
      <label>
        {t('saleLinePriceOverride')}
        <input
          inputMode="decimal"
          value={price}
          onChange={(event) => setPrice(event.target.value)}
          disabled={disabled || busy}
        />
      </label>
      <label>
        {t('discountReason')}
        <input
          value={priceReason}
          onChange={(event) => setPriceReason(event.target.value)}
          disabled={disabled || busy}
        />
      </label>
      {!canOverridePrice ? (
        <label>
          {t('discountApproval')}
          <input
            value={approvalId}
            onChange={(event) => setApprovalId(event.target.value)}
            disabled={disabled || busy}
          />
        </label>
      ) : null}
      <button
        type="button"
        disabled={disabled || busy || !price.trim() || !priceReason.trim()}
        onClick={() =>
          void run(() =>
            onPriceOverride(saleLineId, {
              price: price.trim(),
              reason: priceReason.trim(),
              approvalId: approvalId.trim() || undefined,
            }),
          )
        }
      >
        {t('saleLinePriceOverrideApply')}
      </button>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  );
}
