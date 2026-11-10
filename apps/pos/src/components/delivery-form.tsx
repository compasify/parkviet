import { formatMoney } from '@parkviet/pos-shared/money';
import { useId, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useRecentDeliverers } from '../hooks/use-deliveries';
import { deliveryFailureKey, normalizeDeliverer, normalizeDeliveryFee } from '../lib/deliveries';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';

// Marks the open order as one to deliver: who takes it (a typed name, no
// account needed) and an optional delivery fee. The server adds the fee to
// the order total; this form only sends what was typed.
export function DeliveryForm({
  workspace,
  disabled,
  disabledReason,
  onSave,
  onClear,
  onClose,
}: {
  workspace: PosWorkspace;
  disabled: boolean;
  disabledReason?: string;
  onSave: (input: { deliverer: string; fee: string }) => Promise<PosWorkspace>;
  onClear: () => Promise<PosWorkspace>;
  onClose?: () => void;
}) {
  const { t } = useTranslation();
  const listId = useId();
  const current = workspace.delivery;
  const currency = workspace.totals?.currency ?? 'VND';
  const [deliverer, setDeliverer] = useState(current?.deliverer ?? '');
  const [fee, setFee] = useState(
    current && Number(current.fee) > 0 ? String(Number(current.fee)) : '',
  );
  const [error, setError] = useState('');
  const recent = useRecentDeliverers(workspace.branch_id, !disabled);
  // Once money was taken the fee is part of what the customer was quoted.
  const feeLocked = workspace.payments;
  const failureText = (failure: unknown) => {
    const key = deliveryFailureKey(conflictReason(failure));
    return key ? t(key) : describeFailure(failure, t, 'deliveryFailed');
  };

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (disabled) return;
    const amount = feeLocked ? (current?.fee ?? '0') : normalizeDeliveryFee(fee);
    if (amount === null) {
      setError(t('deliveryFeeInvalid'));
      return;
    }
    setError('');
    try {
      await onSave({ deliverer: normalizeDeliverer(deliverer), fee: amount });
      onClose?.();
    } catch (failure) {
      setError(failureText(failure));
    }
  }

  async function clear() {
    if (disabled) return;
    setError('');
    try {
      await onClear();
      onClose?.();
    } catch (failure) {
      setError(failureText(failure));
    }
  }

  return (
    <form className="delivery-form pos-popup-card" onSubmit={submit}>
      <div className="pos-popup-header">
        <strong>{t('deliveryTitle')}</strong>
      </div>
      <p className="muted">{t('deliveryHint')}</p>
      <label>
        {t('deliveryDeliverer')}
        <input
          list={listId}
          maxLength={80}
          value={deliverer}
          onChange={(event) => setDeliverer(event.target.value)}
          disabled={disabled}
          title={disabledReason}
          placeholder={t('deliveryDelivererPlaceholder')}
          autoComplete="off"
        />
        <datalist id={listId}>
          {(recent.data ?? []).map((name) => (
            <option key={name} value={name} />
          ))}
        </datalist>
      </label>
      {recent.data?.length ? (
        <fieldset className="delivery-names">
          <legend className="visually-hidden">{t('deliveryRecent')}</legend>
          {recent.data.map((name) => (
            <button
              key={name}
              type="button"
              aria-pressed={normalizeDeliverer(deliverer) === name}
              disabled={disabled}
              onClick={() => setDeliverer(name)}
            >
              {name}
            </button>
          ))}
        </fieldset>
      ) : null}
      <label>
        {t('deliveryFee')}
        <input
          inputMode="numeric"
          className="money-input"
          value={fee}
          onChange={(event) => setFee(event.target.value)}
          disabled={disabled || feeLocked}
          title={feeLocked ? t('deliveryFeeLocked') : disabledReason}
          placeholder="0"
        />
      </label>
      {feeLocked ? <p className="muted">{t('deliveryFeeLocked')}</p> : null}
      {current && Number(current.fee) > 0 ? (
        <p className="muted">
          {t('deliveryFeeInTotal', { amount: formatMoney(current.fee, currency) })}
        </p>
      ) : null}
      <div className="row">
        <button type="submit" className="primary-button" disabled={disabled} title={disabledReason}>
          {t(current ? 'deliverySave' : 'deliveryMark')}
        </button>
        {current ? (
          <button
            type="button"
            disabled={disabled || (feeLocked && Number(current.fee) > 0)}
            onClick={() => void clear()}
          >
            {t('deliveryClear')}
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
