import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { parseVndAmount, parseVndInput } from '../lib/money';
import type { PosLineItem, PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

export function LinePriceEditor({
  line,
  currency,
  disabled,
  disabledReason,
  canApplyDiscount,
  onApply,
}: {
  line: PosLineItem;
  currency: string;
  disabled: boolean;
  disabledReason?: string;
  canApplyDiscount: boolean;
  onApply: (input: { value: string; reason: string; approvalId?: string }) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const currentPrice =
    line.line_discount?.value_type === 'unit_price'
      ? line.line_discount.value
      : (line.unit_price ?? line.price);
  const currentVnd = parseVndAmount(currentPrice);
  const listPrice = parseVndAmount(line.list_price ?? line.unit_price ?? line.price);
  const isOverridden =
    (listPrice !== null && currentVnd !== null && listPrice !== currentVnd) ||
    line.line_discount?.value_type === 'unit_price';
  const [price, setPrice] = useState(currentVnd ?? currentPrice);
  const [reason, setReason] = useState(t('linePriceDefaultReason'));
  const [approvalId, setApprovalId] = useState('');
  const [error, setError] = useState('');
  const reasonId = useId();
  const reasonRef = useRef<HTMLInputElement>(null);
  const details = useRef<HTMLDetailsElement>(null);
  const value = parseVndInput(price);
  const valid = currency === 'VND' && value !== null && BigInt(value) >= 0n;

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
    <details className="line-price-edit" ref={details}>
      <summary
        className="cell-edit-button"
        aria-label={t('linePriceEditName', { name: line.name })}
        title={disabledReason ?? t('linePriceEdit')}
      >
        <PosIcon name="edit" />
      </summary>
      <div className="pos-popup-backdrop">
        <form
          className="line-price-form pos-popup-card"
          onSubmit={(event) => {
            event.preventDefault();
            if (!valid || disabled || !reason.trim()) return;
            void run(() =>
              onApply({
                value,
                reason: reason.trim(),
                approvalId: approvalId.trim() || undefined,
              }),
            );
          }}
        >
          <div className="pos-popup-header">
            <strong>
              {t('linePriceEdit')} · {line.name}
            </strong>
          </div>
          <label>
            {t('linePriceTarget')}
            <input
              aria-label={t('linePriceTargetName', { name: line.name })}
              inputMode="numeric"
              value={price}
              maxLength={64}
              disabled={disabled}
              aria-invalid={!valid}
              onChange={(event) => setPrice(event.target.value)}
            />
          </label>
          <div className="clearable-field">
            <label htmlFor={reasonId}>{t('discountReason')}</label>
            <div className="clearable-input">
              <input
                id={reasonId}
                ref={reasonRef}
                value={reason}
                maxLength={200}
                disabled={disabled}
                onChange={(event) => setReason(event.target.value)}
              />
              {reason && !disabled ? (
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
                disabled={disabled}
                onChange={(event) => setApprovalId(event.target.value)}
              />
            </label>
          ) : null}
          <div className="row">
            <button
              type="submit"
              className="primary-button"
              disabled={disabled || !valid || !reason.trim()}
            >
              {t('save')}
            </button>
            {isOverridden && listPrice !== null ? (
              <button
                type="button"
                disabled={disabled}
                onClick={() =>
                  void run(() =>
                    onApply({
                      value: listPrice,
                      reason: reason.trim() || t('linePriceDefaultReason'),
                      approvalId: approvalId.trim() || undefined,
                    }),
                  )
                }
              >
                {t('linePriceReset')}
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
  );
}
