import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import { createBrowserPrintAdapter, formatPrebill, type PaperSize } from '../lib/print-adapter';
import { PosIcon } from './pos-icon';
import { ReceiptPrintPortal, ReceiptSheet } from './receipt-sheet';

const adapter = createBrowserPrintAdapter();

// Provisional bill of an open order, from the server figures on screen. It is
// labelled "TẠM TÍNH – CHƯA THANH TOÁN", has no receipt number and records
// nothing: an order is only paid by its receipts.
export function PrebillDialog({
  workspace,
  names,
  timeZone,
  onClose,
}: {
  workspace: PosWorkspace;
  names: { storeName?: string | null; branchName?: string | null; registerName?: string | null };
  timeZone: string;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const card = useRef<HTMLDivElement>(null);
  const titleId = useId();
  const [paper, setPaper] = useState<PaperSize>('80mm');
  const [error, setError] = useState('');
  useModalFocus(card, onClose);
  const document = formatPrebill(workspace, names, t, new Date(), timeZone);
  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('receiptPrebillTitle')}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <fieldset className="row">
          <legend>{t('receiptPaper')}</legend>
          {(['80mm', 'a4'] as const).map((size) => (
            <label key={size}>
              <input
                type="radio"
                name="prebill-paper"
                checked={paper === size}
                onChange={() => setPaper(size)}
              />
              {t(`receiptPaper_${size}`)}
            </label>
          ))}
        </fieldset>
        <button
          type="button"
          onClick={() =>
            void adapter.deliver(paper).then((outcome) => {
              setError(
                outcome.ok
                  ? ''
                  : t(outcome.reason === 'blocked' ? 'prebillPrintBlocked' : 'prebillPrintFailed'),
              );
            })
          }
        >
          {t('receiptPrebillPrint')}
        </button>
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="receipt-preview">
          <ReceiptSheet document={document} paper={paper} />
        </div>
        <ReceiptPrintPortal document={document} paper={paper} />
      </div>
    </div>
  );
}
