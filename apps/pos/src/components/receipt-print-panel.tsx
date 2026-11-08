import { useMutation } from '@tanstack/react-query';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { session } from '../lib/app-session';
import {
  createBrowserPrintAdapter,
  isPaperSize,
  type PaperSize,
  type ReceiptPrint,
  type ReceiptSnapshot,
  receiptPrintDocument,
  receiptPrintTitle,
} from '../lib/print-adapter';
import { describeFailure } from '../lib/request-failure';
import { PaperPicker } from './paper-picker';
import { PosIcon } from './pos-icon';
import { ReceiptPrintPortal, ReceiptSheet } from './receipt-sheet';

const adapter = createBrowserPrintAdapter();
const PAPER_KEY = 'parkviet-pos:receipt-paper';

function savedPaper(): PaperSize {
  try {
    const saved = window.localStorage.getItem(PAPER_KEY);
    return isPaperSize(saved) ? saved : '80mm';
  } catch {
    return '80mm';
  }
}

function savePaper(paper: PaperSize) {
  try {
    window.localStorage.setItem(PAPER_KEY, paper);
  } catch {
    // Preference only.
  }
}

type PrintJob = { print: ReceiptPrint; paper: PaperSize };

// Print controls and preview of one posted receipt. The first print is the
// original; every later one is recorded and printed as "BẢN SAO". A print is
// recorded before the browser prints, so a failed or cancelled print still
// used up its number and the next one is a copy. Key it by receipt id.
export function ReceiptPrintPanel({
  receipt: loaded,
  onBusyChange,
}: {
  receipt: ReceiptSnapshot;
  onBusyChange?: (busy: boolean) => void;
}) {
  const { t } = useTranslation();
  const [paper, setPaper] = useState<PaperSize>(savedPaper);
  // The receipt as returned by the last print; newer than the loaded one.
  const [printed, setPrinted] = useState<ReceiptSnapshot | null>(null);
  const [job, setJob] = useState<PrintJob | null>(null);
  const delivered = useRef(new Set<string>());
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const receipt = printed ?? loaded;

  const print = useMutation({
    mutationFn: async (target: ReceiptSnapshot) => {
      const idempotencyKey = crypto.randomUUID();
      return (
        await session.request<{ data: { print: ReceiptPrint; receipt: ReceiptSnapshot } }>(
          'POST',
          `/pos/receipts/${target.id}/prints`,
          { body: { idempotency_key: idempotencyKey }, idempotencyKey },
        )
      ).data;
    },
  });
  const busy = print.isPending || Boolean(job);

  useEffect(() => {
    onBusyChange?.(busy);
  }, [busy, onBusyChange]);

  // While a print runs the sheet carries its recorded label; otherwise it
  // previews the next print (a copy once the original was used).
  const preview = useMemo(() => {
    const next = receipt.printed ? { copy: true, copy_number: receipt.copy_count + 1 } : null;
    return receiptPrintDocument(receipt, job ? job.print : next, t);
  }, [receipt, job, t]);

  // Print only once the print copy carrying this print's label is in the DOM.
  useEffect(() => {
    if (!job || delivered.current.has(job.print.id)) return;
    const sheet = document.querySelector(
      `[data-testid="receipt-print-sheet"][data-print-id="${job.print.id}"]`,
    );
    if (!sheet) return;
    delivered.current.add(job.print.id);
    void adapter.deliver(job.paper, { title: receiptPrintTitle(receipt, t) }).then((outcome) => {
      if (!outcome.ok)
        setError(t(outcome.reason === 'blocked' ? 'receiptPrintBlocked' : 'receiptPrintFailed'));
      setJob(null);
    });
  });

  const doPrint = async () => {
    if (busy) return;
    setError('');
    setNotice('');
    try {
      const result = await print.mutateAsync(receipt);
      setPrinted(result.receipt);
      setNotice(
        result.print.copy
          ? t('receiptPrintedCopy', { number: result.print.copy_number })
          : t('receiptPrintedOriginal'),
      );
      setJob({ print: result.print, paper });
    } catch (failure) {
      abandonIfNeeded(failure);
      // Not recorded, so nothing is printed: a copy is never printed unlabelled.
      setError(t('receiptPrintNotRecorded', { reason: describeFailure(failure, t) }));
    }
  };

  return (
    <section className="receipt-print-panel" aria-label={t('receiptPreview')}>
      <div className="receipt-print-toolbar">
        <PaperPicker
          value={paper}
          disabled={busy}
          onChange={(size) => {
            setPaper(size);
            savePaper(size);
          }}
        />
        <div className="receipt-print-actions">
          <small className="receipt-print-status">
            {receipt.printed
              ? t('receiptCopyCount', { count: receipt.copy_count })
              : t('receiptNotPrinted')}
          </small>
          <button
            type="button"
            className="primary-button"
            disabled={busy}
            onClick={() => void doPrint()}
          >
            <PosIcon name="print" />
            {receipt.printed ? t('receiptReprint') : t('receiptPrint')}
          </button>
        </div>
      </div>
      {notice ? <p role="status">{notice}</p> : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <div className="receipt-preview">
        <ReceiptSheet document={preview} paper={paper} printId={job?.print.id} />
      </div>
      <ReceiptPrintPortal document={preview} paper={job?.paper ?? paper} printId={job?.print.id} />
    </section>
  );
}
