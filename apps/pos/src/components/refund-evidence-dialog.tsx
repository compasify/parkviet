import { formatMoney } from '@parkviet/pos-shared/money';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosRefundRequest } from '../lib/returns';
import { PosIcon } from './pos-icon';

// Evidence that refund money actually left: the cashier counts the cash out of
// their own drawer, or records the bank transfer reference. Only this action
// books the refund; "unknown" keeps the money held until someone with
// evidence resolves it.
export function RefundEvidenceDialog({
  refund,
  busy,
  error,
  onConfirm,
  onUnknown,
  onClose,
}: {
  refund: PosRefundRequest;
  busy: boolean;
  error: string;
  onConfirm: (reference?: string) => Promise<unknown>;
  onUnknown: () => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const inFlight = useRef(false);
  const [counted, setCounted] = useState(false);
  const [reference, setReference] = useState('');
  const cash = refund.method === 'cash';
  const ready = cash ? counted : reference.trim() !== '';

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card refund-evidence"
        onSubmit={(event) => {
          event.preventDefault();
          if (!ready || busy || inFlight.current) return;
          inFlight.current = true;
          void onConfirm(cash ? undefined : reference.trim()).finally(() => {
            inFlight.current = false;
          });
        }}
      >
        <div className="pos-popup-header">
          <div>
            <h4 id={titleId}>{t(cash ? 'refundEvidenceCashTitle' : 'refundEvidenceBankTitle')}</h4>
            <small className="muted">
              {refund.order_number} · {formatMoney(refund.amount, refund.currency)}
            </small>
          </div>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            disabled={busy}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        {cash ? (
          <label className="checkbox-row">
            <input
              type="checkbox"
              checked={counted}
              disabled={busy}
              onChange={(event) => setCounted(event.target.checked)}
            />
            {t('refundEvidenceCounted', { amount: formatMoney(refund.amount, refund.currency) })}
          </label>
        ) : (
          <>
            {refund.beneficiary_reference ? (
              <p className="muted">
                {t('refundBeneficiary')}: {refund.beneficiary_reference}
              </p>
            ) : null}
            <label>
              {t('refundTransferReference')}
              <input
                value={reference}
                required
                maxLength={120}
                autoComplete="off"
                disabled={busy}
                onChange={(event) => setReference(event.target.value)}
              />
            </label>
          </>
        )}
        <p className="muted">{t(cash ? 'refundEvidenceCashHint' : 'refundEvidenceBankHint')}</p>
        {refund.approval?.status !== 'active' ? (
          <p className="muted" role="note">
            {t('refundNeedsApproval')}
          </p>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="row">
          <button type="submit" className="checkout-submit" disabled={!ready || busy}>
            {busy ? t('waiting') : t('refundConfirmPayout')}
          </button>
          {refund.status === 'reserved' ? (
            <button type="button" disabled={busy} onClick={() => void onUnknown()}>
              {t('refundMarkUnknown')}
            </button>
          ) : null}
        </div>
      </form>
    </div>
  );
}
