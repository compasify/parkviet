import { formatMoney } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import { depositToApply } from '../lib/table-courses';

// The booking seated at this table, and its held deposit taken off the bill.
export function ReservationDepositNote({
  workspace,
  disabled,
  onApply,
}: {
  workspace: PosWorkspace;
  disabled: boolean;
  onApply: () => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const reservation = workspace.reservation;
  if (!reservation) return null;
  const left = depositToApply(workspace);
  const currency = workspace.totals?.currency || 'VND';
  return (
    <section className="reservation-deposit-note" aria-label={t('reservationsDeposit')}>
      <p>
        {t('reservationsSeatedGuest', {
          name: reservation.guest_name,
          count: reservation.party_size,
        })}
      </p>
      {left > 0 ? (
        <button
          type="button"
          className="checkout-submit"
          disabled={disabled || busy}
          onClick={() => {
            setBusy(true);
            setMessage('');
            void onApply()
              .catch((error) =>
                setMessage(
                  conflictReason(error) === 'deposit_none'
                    ? t('reservationsDepositNone')
                    : t(posFailureKey(error)),
                ),
              )
              .finally(() => setBusy(false));
          }}
        >
          {t('reservationsApplyDeposit', { amount: formatMoney(String(left), currency) })}
        </button>
      ) : reservation.deposits.some((row) => row.status === 'applied') ? (
        <p className="workspace-hint">{t('reservationsDepositApplied')}</p>
      ) : null}
      {message ? (
        <p className="workspace-hint" role="status">
          {message}
        </p>
      ) : null}
    </section>
  );
}
