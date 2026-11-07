import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parsePercentageInput, parseVndAmount } from '../lib/money';
import type { PosLineItem, PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

export function ItemDiscountEditor({
  line,
  currency,
  disabled,
  disabledReason,
  canApplyDiscount,
  onApply,
  onClear,
}: {
  line: PosLineItem;
  currency: string;
  disabled: boolean;
  disabledReason?: string;
  canApplyDiscount: boolean;
  onApply: (input: {
    valueType: 'item_flat' | 'item_percent';
    value: string;
    reason: string;
    approvalId?: string;
  }) => Promise<PosWorkspace>;
  onClear: (approvalId?: string) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const current = line.item_discount;
  const initialType = current?.value_type ?? 'flat';
  const initialValue = current?.value ?? '0';
  const [type, setType] = useState<'flat' | 'percent'>(initialType);
  const [value, setValue] = useState(initialValue);
  const [reason, setReason] = useState(t('itemDiscountReason'));
  const [approvalId, setApprovalId] = useState('');
  const [error, setError] = useState('');
  const reasonId = useId();
  const reasonRef = useRef<HTMLInputElement>(null);
  const details = useRef<HTMLDetailsElement>(null);
  const parsed = type === 'percent' ? parsePercentageInput(value) : parseVndAmount(value);
  const dirty =
    type !== initialType ||
    parsed !==
      (type === 'percent' ? parsePercentageInput(initialValue) : parseVndAmount(initialValue));
  const locked = disabled || !line.sale_line_id;
  const hasDiscount = Boolean(
    current?.amount && current.amount !== '0.0' && current.amount !== '0',
  );

  async function run(action: () => Promise<PosWorkspace>) {
    setError('');
    try {
      await action();
      if (details.current) details.current.open = false;
    } catch (failure) {
      setError(describeFailure(failure, t));
    }
  }

  return (
    <div className="basket-cell-inline">
      <span
        className={hasDiscount ? 'item-discount-amount' : undefined}
        title={current?.labels.join(', ')}
      >
        {formatMoney(hasDiscount ? (current?.amount ?? '0') : '0', currency)}
      </span>
      <details className="item-discount-edit" ref={details}>
        <summary
          className="cell-edit-button"
          aria-label={`${t('itemDiscountColumn')}: ${line.name}`}
          title={disabledReason ?? t('itemDiscountColumn')}
        >
          <PosIcon name="edit" />
        </summary>
        <div className="pos-popup-backdrop">
          <form
            className="item-discount-editor pos-popup-card"
            onSubmit={(event) => {
              event.preventDefault();
              if (
                locked ||
                parsed === null ||
                !dirty ||
                !reason.trim() ||
                (!canApplyDiscount && !approvalId.trim())
              )
                return;
              void run(() =>
                onApply({
                  valueType: type === 'percent' ? 'item_percent' : 'item_flat',
                  value: parsed,
                  reason: reason.trim(),
                  approvalId: approvalId.trim() || undefined,
                }),
              );
            }}
          >
            <div className="pos-popup-header">
              <strong>
                {t('itemDiscountColumn')} · {line.name}
              </strong>
              <span className="item-discount-source" title={current?.labels.join(', ')}>
                {t(
                  current?.source === 'promotion'
                    ? 'itemDiscountPromotion'
                    : current?.source === 'manual'
                      ? 'itemDiscountManual'
                      : 'itemDiscountNone',
                )}
              </span>
            </div>
            <div className="item-discount-inputs">
              <input
                aria-label={t('itemDiscountValueName', { name: line.name })}
                inputMode="decimal"
                value={value}
                maxLength={64}
                disabled={locked}
                onChange={(event) => setValue(event.target.value)}
                aria-invalid={parsed === null}
                title={t('itemDiscountHint')}
              />
              <select
                aria-label={t('itemDiscountTypeName', { name: line.name })}
                value={type}
                disabled={locked}
                onChange={(event) => setType(event.target.value as 'flat' | 'percent')}
              >
                <option value="flat">₫</option>
                <option value="percent">%</option>
              </select>
            </div>
            <div className="clearable-field">
              <label htmlFor={reasonId}>{t('discountReason')}</label>
              <div className="clearable-input">
                <input
                  id={reasonId}
                  ref={reasonRef}
                  value={reason}
                  maxLength={200}
                  disabled={locked}
                  onChange={(event) => setReason(event.target.value)}
                />
                {reason && !locked ? (
                  <button
                    type="button"
                    className="input-clear-button"
                    aria-label={t('discountClear')}
                    onClick={() => {
                      setReason('');
                      reasonRef.current?.focus();
                    }}
                  >
                    <PosIcon name="close" />
                  </button>
                ) : null}
              </div>
            </div>
            {!canApplyDiscount ? (
              <label>
                {t('discountApproval')}
                <input
                  value={approvalId}
                  disabled={locked}
                  onChange={(event) => setApprovalId(event.target.value)}
                />
              </label>
            ) : null}
            <div className="row">
              <button
                type="submit"
                className="primary-button"
                disabled={
                  locked ||
                  !dirty ||
                  parsed === null ||
                  !reason.trim() ||
                  (!canApplyDiscount && !approvalId.trim())
                }
              >
                {t('save')}
              </button>
              {line.line_discount ? (
                <button
                  type="button"
                  className="item-discount-reset"
                  disabled={locked || (!canApplyDiscount && !approvalId.trim())}
                  onClick={() => void run(() => onClear(approvalId.trim() || undefined))}
                >
                  {t('itemDiscountAutomatic')}
                </button>
              ) : null}
              <button
                type="button"
                onClick={() => {
                  if (details.current) details.current.open = false;
                }}
              >
                {t('adminClose')}
              </button>
            </div>
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </form>
        </div>
      </details>
      {hasDiscount ? (
        <button
          type="button"
          className="cell-edit-button cell-clear-button"
          title={disabledReason ?? t('discountClear')}
          aria-label={`${t('discountClear')} ${line.name}`}
          disabled={locked || (!canApplyDiscount && !approvalId.trim())}
          onClick={() =>
            void run(() =>
              line.line_discount
                ? onClear(approvalId.trim() || undefined)
                : onApply({
                    valueType: 'item_flat',
                    value: '0',
                    reason: reason.trim() || t('itemDiscountReason'),
                    approvalId: approvalId.trim() || undefined,
                  }),
            )
          }
        >
          <PosIcon name="close" />
        </button>
      ) : null}
    </div>
  );
}
