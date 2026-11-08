import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import {
  createBrowserPrintAdapter,
  type PaperSize,
  prebillPrintDocument,
  printTitle,
} from '../lib/print-adapter';
import { PaperPicker } from './paper-picker';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';
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
  // The store's address and phone, and the branch, from the POS context.
  const context = usePosSelection().context.data;
  const branch = context?.branches.find((row) => row.id === workspace.branch_id);
  const document = prebillPrintDocument(
    workspace,
    {
      ...names,
      storeProfile: context?.store.profile,
      branchCode: branch?.code,
      returnWindowDays: branch?.return_window_days,
    },
    t,
    new Date(),
    timeZone,
  );
  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card receipt-print-dialog"
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
        <div className="receipt-print-toolbar">
          <PaperPicker value={paper} onChange={setPaper} />
          <button
            type="button"
            className="primary-button"
            onClick={() =>
              void adapter
                .deliver(paper, {
                  title: printTitle(t('receiptPrebillTitle'), null, workspace.order_id, t),
                })
                .then((outcome) => {
                  setError(
                    outcome.ok
                      ? ''
                      : t(
                          outcome.reason === 'blocked'
                            ? 'prebillPrintBlocked'
                            : 'prebillPrintFailed',
                        ),
                  );
                })
            }
          >
            <PosIcon name="print" />
            {t('receiptPrebillPrint')}
          </button>
        </div>
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
