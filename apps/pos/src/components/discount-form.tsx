import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

export function DiscountForm({
  workspace,
  canApply,
  disabled,
  onApply,
  onClear,
  onApplyCoupon,
  onClearCoupon,
  onClose,
}: {
  workspace: PosWorkspace;
  canApply: boolean;
  disabled: boolean;
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
  const [value, setValue] = useState(workspace.discount?.value ?? '10');
  const [reason, setReason] = useState(workspace.discount?.reason || t('discountTitle'));
  const [approvalId, setApprovalId] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const couponId = useId();
  const couponRef = useRef<HTMLInputElement>(null);
  const reasonId = useId();
  const reasonRef = useRef<HTMLInputElement>(null);

  async function submitCoupon() {
    if (!onApplyCoupon || !couponCode.trim()) return;
    setBusy(true);
    setError('');
    try {
      await onApplyCoupon(couponCode.trim());
      onClose?.();
    } catch {
      setError(t('couponFailed'));
    } finally {
      setBusy(false);
    }
  }

  async function removeCoupon() {
    if (!onClearCoupon) return;
    setBusy(true);
    setError('');
    try {
      await onClearCoupon();
      setCouponCode('');
      onClose?.();
    } catch {
      setError(t('couponFailed'));
    } finally {
      setBusy(false);
    }
  }

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError('');
    try {
      await onApply({
        valueType,
        value: value.trim(),
        reason: reason.trim(),
        approvalId: approvalId.trim() || undefined,
      });
      onClose?.();
    } catch {
      setError(t('discountFailed'));
    } finally {
      setBusy(false);
    }
  }

  async function clear() {
    setBusy(true);
    setError('');
    try {
      await onClear(approvalId.trim() || undefined);
      setReason(t('discountTitle'));
      onClose?.();
    } catch {
      setError(t('discountFailed'));
    } finally {
      setBusy(false);
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
                  disabled={disabled || busy}
                />
                {couponCode && !disabled && !busy ? (
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
                disabled={disabled || busy || !couponCode.trim()}
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
                  disabled={disabled || busy}
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
          required
        />
      </label>
      <div className="clearable-field">
        <label htmlFor={reasonId}>{t('discountReason')}</label>
        <div className="clearable-input">
          <input
            id={reasonId}
            ref={reasonRef}
            maxLength={200}
            value={reason}
            onChange={(event) => setReason(event.target.value)}
            disabled={disabled || busy}
            required
          />
          {reason && !disabled && !busy ? (
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
            disabled={disabled || busy}
            required={!workspace.discount}
          />
        </label>
      ) : null}
      <div className="row">
        <button
          type="submit"
          className="primary-button"
          disabled={disabled || busy || !value.trim() || !reason.trim()}
        >
          {workspace.discount ? t('discountUpdate') : t('discountApply')}
        </button>
        {workspace.discount ? (
          <button type="button" disabled={disabled || busy} onClick={() => void clear()}>
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
