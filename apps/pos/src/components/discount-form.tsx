import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parsePercentageInput, parseVndAmount, parseVndInput } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

// A flat discount arrives canonical ("20000.0"); the cashier edits whole VND.
function serverValue(discount: PosWorkspace['discount']): string | undefined {
  if (!discount) return undefined;
  return discount.value_type === 'flat'
    ? (parseVndAmount(discount.value) ?? discount.value)
    : discount.value;
}

export function DiscountForm({
  workspace,
  canApply,
  disabled,
  disabledReason,
  onApply,
  onClear,
  onApplyCoupon,
  onClearCoupon,
  onClose,
}: {
  workspace: PosWorkspace;
  canApply: boolean;
  disabled: boolean;
  disabledReason?: string;
  onApply: (input: {
    valueType: 'flat' | 'percent';
    value: string;
    reason: string;
    approvalId?: string;
  }) => Promise<PosWorkspace>;
  onClear: (approvalId?: string) => Promise<PosWorkspace>;
  onApplyCoupon?: (couponCode: string) => Promise<PosWorkspace>;
  onClearCoupon?: () => Promise<PosWorkspace>;
  onClose?: () => void;
}) {
  const { t } = useTranslation();
  const currency = workspace.totals?.currency ?? 'VND';
  const [couponCode, setCouponCode] = useState(workspace.coupon?.code ?? '');
  const [valueType, setValueType] = useState<'flat' | 'percent'>(
    workspace.discount?.value_type ?? 'percent',
  );
  const [value, setValue] = useState(() => serverValue(workspace.discount) ?? '10');
  const [reason, setReason] = useState(workspace.discount?.reason || t('discountTitle'));
  const [approvalId, setApprovalId] = useState('');
  const [error, setError] = useState('');
  const couponId = useId();
  const couponRef = useRef<HTMLInputElement>(null);
  const reasonId = useId();
  const reasonRef = useRef<HTMLInputElement>(null);
  const parsed = valueType === 'percent' ? parsePercentageInput(value) : parseVndInput(value);
  const invalid = value.trim() !== '' && parsed === null;

  async function submitCoupon() {
    if (disabled || !onApplyCoupon || !couponCode.trim()) return;
    setError('');
    try {
      await onApplyCoupon(couponCode.trim());
      onClose?.();
    } catch (failure) {
      setError(describeFailure(failure, t, 'couponFailed'));
    }
  }

  async function removeCoupon() {
    if (disabled || !onClearCoupon) return;
    setError('');
    try {
      await onClearCoupon();
      setCouponCode('');
      onClose?.();
    } catch (failure) {
      setError(describeFailure(failure, t, 'couponFailed'));
    }
  }

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (disabled || parsed === null || !reason.trim()) return;
    setError('');
    try {
      await onApply({
        valueType,
        value: parsed,
        reason: reason.trim(),
        approvalId: approvalId.trim() || undefined,
      });
      onClose?.();
    } catch (failure) {
      setError(describeFailure(failure, t, 'discountFailed'));
    }
  }

  async function clear() {
    if (disabled) return;
    setError('');
    try {
      await onClear(approvalId.trim() || undefined);
      setReason(t('discountTitle'));
      onClose?.();
    } catch (failure) {
      setError(describeFailure(failure, t, 'discountFailed'));
    }
  }

  return (
    <form className="discount-form pos-popup-card" onSubmit={submit}>
      <div className="pos-popup-header">
        <strong>{t('discountTitle')}</strong>
        {workspace.discount ? (
          <span className="item-discount-source">
            {workspace.discount.value_type === 'percent'
              ? `${workspace.discount.value}%`
              : formatMoney(workspace.discount.value, currency)}{' '}
            ({formatMoney(workspace.discount.amount, currency)})
          </span>
        ) : null}
      </div>
      {onApplyCoupon ? (
        <div className="coupon-section">
          <div className="clearable-field">
            <label htmlFor={couponId}>{t('couponLabel')}</label>
            <div className="coupon-input-row">
              <div className="clearable-input">
                <input
                  id={couponId}
                  ref={couponRef}
                  maxLength={64}
                  value={couponCode}
                  placeholder={t('couponPlaceholder')}
                  onChange={(event) => setCouponCode(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === 'Enter') {
                      event.preventDefault();
                      void submitCoupon();
                    }
                  }}
                  disabled={disabled}
                  title={disabledReason}
                />
                {couponCode && !disabled ? (
                  <button
                    type="button"
                    className="input-clear-button"
                    aria-label={t('couponRemove')}
                    onClick={() => {
                      setCouponCode('');
                      couponRef.current?.focus();
                    }}
                  >
                    <PosIcon name="close" />
                  </button>
                ) : null}
              </div>
              <button
                type="button"
                className="primary-button"
                disabled={disabled || !couponCode.trim()}
                onClick={() => void submitCoupon()}
              >
                {t('couponApply')}
              </button>
            </div>
          </div>
          {workspace.coupon ? (
            <div className="coupon-active-row">
              <span>
                <strong>{workspace.coupon.code}</strong>
                {workspace.coupon.name ? ` · ${workspace.coupon.name}` : ''} (
                {formatMoney(workspace.coupon.amount, currency)})
              </span>
              {onClearCoupon ? (
                <button
                  type="button"
                  disabled={disabled}
                  title={disabledReason}
                  onClick={() => void removeCoupon()}
                >
                  {t('couponRemove')}
                </button>
              ) : null}
            </div>
          ) : null}
        </div>
      ) : null}
      <label>
        {t('discountType')}
        <select
          value={valueType}
          onChange={(event) => {
            const next = event.target.value as 'flat' | 'percent';
            if (next === valueType) return;
            // A percentage is meaningless as an amount and vice versa.
            setValueType(next);
            setValue(
              workspace.discount?.value_type === next
                ? (serverValue(workspace.discount) ?? '')
                : '',
            );
          }}
          disabled={disabled}
          title={disabledReason}
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
          maxLength={64}
          aria-invalid={invalid}
          onChange={(event) => setValue(event.target.value)}
          disabled={disabled}
          title={disabledReason}
          required
        />
      </label>
      {invalid ? (
        <p className="error" role="alert">
          {t(valueType === 'percent' ? 'discountInvalidPercent' : 'discountInvalidFlat')}
        </p>
      ) : null}
      <div className="clearable-field">
        <label htmlFor={reasonId}>{t('discountReason')}</label>
        <div className="clearable-input">
          <input
            id={reasonId}
            ref={reasonRef}
            maxLength={200}
            value={reason}
            onChange={(event) => setReason(event.target.value)}
            disabled={disabled}
            title={disabledReason}
            required
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
      {!canApply ? (
        <label>
          {t('discountApproval')}
          <input
            value={approvalId}
            onChange={(event) => setApprovalId(event.target.value)}
            disabled={disabled}
            title={disabledReason}
            required={!workspace.discount}
          />
        </label>
      ) : null}
      <div className="row">
        <button
          type="submit"
          className="primary-button"
          disabled={disabled || parsed === null || !reason.trim()}
          title={disabledReason}
        >
          {workspace.discount ? t('discountUpdate') : t('discountApply')}
        </button>
        {workspace.discount ? (
          <button
            type="button"
            disabled={disabled}
            title={disabledReason}
            onClick={() => void clear()}
          >
            {t('discountClear')}
          </button>
        ) : null}
        {onClose ? (
          <button type="button" onClick={onClose}>
            {t('adminClose')}
          </button>
        ) : null}
      </div>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </form>
  );
}
