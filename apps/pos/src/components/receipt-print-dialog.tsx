import { useQuery } from '@tanstack/react-query';
import { useCallback, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSession } from '../hooks/use-session';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { session } from '../lib/app-session';
import { useModalFocus } from '../lib/dialog-focus';
import type { ReceiptSnapshot } from '../lib/print-adapter';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { ReceiptPrintPanel } from './receipt-print-panel';

// A button that opens the print popup for a posted document's receipt.
// `autoPrint` turning true opens the popup by itself and prints right away
// (a sale just issued on a device set to print automatically).
export function ReceiptPrintButton({
  sourceId,
  label,
  className,
  autoPrint = false,
}: {
  sourceId: string;
  label: string;
  className?: string;
  autoPrint?: boolean;
}) {
  const [open, setOpen] = useState<'manual' | 'auto' | null>(null);
  useEffect(() => {
    if (autoPrint) setOpen('auto');
  }, [autoPrint]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen('manual')}>
        <PosIcon name="print" />
        {label}
      </button>
      {open ? (
        <ReceiptPrintDialog
          sourceId={sourceId}
          autoPrint={open === 'auto'}
          onClose={() => setOpen(null)}
        />
      ) : null}
    </>
  );
}

// The receipt of a posted document (sale, return, refund, shift closure),
// looked up by its source and printed from a popup over the current screen.
export function ReceiptPrintDialog({
  sourceId,
  onClose,
  autoPrint = false,
}: {
  sourceId: string;
  onClose: () => void;
  autoPrint?: boolean;
}) {
  const { t } = useTranslation();
  const card = useRef<HTMLDivElement>(null);
  const titleId = useId();
  const snapshot = useSession();
  const [busy, setBusy] = useState(false);
  const close = useCallback(() => {
    // Closing mid-print would drop the sheet the browser is about to print.
    if (!busy) onClose();
  }, [busy, onClose]);
  useModalFocus(card, close);

  const lookup = useQuery({
    queryKey: ['pos', 'receipt-source', snapshot.generation, sourceId],
    enabled: snapshot.status === 'authenticated',
    retry: false,
    queryFn: async () => {
      try {
        return (
          await session.request<{ data: ReceiptSnapshot }>('GET', '/pos/receipts/lookup', {
            params: { source_id: sourceId },
          })
        ).data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
  const receipt = lookup.data;

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
          <h4 id={titleId}>
            {t('receiptPrint')}
            {receipt ? <span className="receipt-print-number"> · {receipt.number}</span> : null}
          </h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={close}
            disabled={busy}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        {lookup.isPending ? (
          <p className="muted" role="status">
            {t('receiptLoading')}
          </p>
        ) : null}
        {lookup.error ? (
          <p className="error" role="alert">
            {conflictReason(lookup.error) === 'receipt_unavailable'
              ? t('receiptUnavailable')
              : describeFailure(lookup.error, t)}
          </p>
        ) : null}
        {receipt ? (
          <ReceiptPrintPanel
            key={receipt.id}
            receipt={receipt}
            onBusyChange={setBusy}
            autoPrint={autoPrint}
            refreshing={lookup.isFetching}
          />
        ) : null}
      </div>
    </div>
  );
}
