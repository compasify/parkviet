import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useRemindDebt } from '../hooks/use-receivables';
import { debtReminderMessage } from '../lib/debt-reminder';
import { copyMessage, payLaterQr, type ShareOutcome, shareMessage } from '../lib/pay-later';
import type { PosReceivableAccount } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

// "Nhắc nợ": sends the customer a polite reminder with the open orders and
// one QR for the total through the share sheet (Zalo), or copies it. A
// shared or copied reminder is recorded as "Nhắc lần cuối".
export function DebtReminderActions({
  account,
  branchId,
  storeName,
}: {
  account: PosReceivableAccount;
  branchId: string;
  storeName?: string | null;
}) {
  const { t } = useTranslation();
  const remind = useRemindDebt();
  const [busy, setBusy] = useState(false);
  const [outcome, setOutcome] = useState<ShareOutcome | null>(null);
  const [recordFailed, setRecordFailed] = useState(false);
  const qr = payLaterQr(account.pay_later);

  async function send(via: 'share' | 'copy') {
    setBusy(true);
    setOutcome(null);
    setRecordFailed(false);
    try {
      const message = debtReminderMessage(account, qr, t, storeName);
      const result =
        via === 'share'
          ? await shareMessage(message, qr, t('debtReminderTitle'))
          : await copyMessage(message);
      setOutcome(result);
      if (result === 'shared' || result === 'copied') {
        // The message is already out; failing to note it only loses the timestamp.
        await remind
          .mutateAsync({ branchId, creditAccountId: account.credit_account_id, via })
          .catch(() => setRecordFailed(true));
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <span className="pay-later-share debt-reminder-actions">
      <button type="button" disabled={busy} onClick={() => void send('share')}>
        <PosIcon name="qr" />
        {t('debtReminderShare')}
      </button>
      <button type="button" disabled={busy} onClick={() => void send('copy')}>
        {t('debtReminderCopy')}
      </button>
      {outcome === 'copied' ? (
        <small role="status">{t('payLaterCopied')}</small>
      ) : outcome === 'failed' ? (
        <small className="error" role="alert">
          {t('payLaterShareFailed')}
        </small>
      ) : null}
      {recordFailed ? (
        <small className="error" role="alert">
          {t('debtReminderRecordFailed')}
        </small>
      ) : null}
      {!qr ? <small className="muted">{t('debtReminderNoQr')}</small> : null}
    </span>
  );
}
