import { formatMoney } from '@parkviet/pos-shared/money';
import { useId, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

// Quick credit (one-person shops): one confirmation, no second person. The
// cashier approves the unpaid remainder themselves and the sale completes on
// credit in the same step; the server still enforces the customer's limit.
export function QuickCreditDialog({
  workspace,
  busy,
  error,
  onConfirm,
  onClose,
}: {
  workspace: PosWorkspace;
  busy: boolean;
  error: string;
  onConfirm: () => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const currency = workspace.totals?.currency ?? 'VND';
  const remaining = workspace.financial?.remaining ?? workspace.totals?.total ?? '0';
  const customer = workspace.customer?.name ?? null;

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card credit-approval"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('creditTitle')}</h4>
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
        {customer ? (
          <p>
            {t('quickCreditConfirm', {
              amount: formatMoney(remaining, currency),
              name: customer,
            })}
          </p>
        ) : (
          <p className="error" role="alert">
            {t('creditCustomerRequired')}
          </p>
        )}
        <p className="muted">{t('quickCreditHint')}</p>
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="payment-popup-actions">
          <button
            type="button"
            className="checkout-submit"
            disabled={busy || !customer}
            onClick={onConfirm}
          >
            {busy ? t('waiting') : t('quickCreditAction')}
          </button>
          <button type="button" disabled={busy} onClick={onClose}>
            {t('creditClose')}
          </button>
        </div>
      </div>
    </div>
  );
}
