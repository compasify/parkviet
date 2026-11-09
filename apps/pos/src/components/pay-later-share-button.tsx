import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { type PayLaterQr, type ShareOutcome, sharePayLater } from '../lib/pay-later';
import { PosIcon } from './pos-icon';

// "Gửi Zalo": hands the pay-later QR and message to the device's share sheet
// (Zalo is one of its targets on phones and tablets), or copies the message
// to paste into Zalo where there is no share sheet.
export function PayLaterShareButton({
  qr,
  storeName,
  label,
}: {
  qr: PayLaterQr;
  storeName?: string | null;
  // A short label for a table row; the full one names Zalo.
  label?: string;
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const [outcome, setOutcome] = useState<ShareOutcome | null>(null);

  return (
    <span className="pay-later-share">
      <button
        type="button"
        disabled={busy}
        title={t('payLaterShareHint', { note: qr.transfer_content })}
        onClick={async () => {
          setBusy(true);
          setOutcome(null);
          try {
            setOutcome(await sharePayLater(qr, t, storeName));
          } finally {
            setBusy(false);
          }
        }}
      >
        <PosIcon name="qr" />
        {label ?? t('payLaterShareButton')}
      </button>
      {outcome === 'copied' ? (
        <small role="status">{t('payLaterCopied')}</small>
      ) : outcome === 'failed' ? (
        <small className="error" role="alert">
          {t('payLaterShareFailed')}
        </small>
      ) : null}
    </span>
  );
}
