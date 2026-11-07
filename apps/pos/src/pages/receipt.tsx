import { useMutation, useQuery } from '@tanstack/react-query';
import { useSearch } from '@tanstack/react-router';
import { type FormEvent, useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintPortal, ReceiptSheet } from '../components/receipt-sheet';
import { useSession } from '../hooks/use-session';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { session } from '../lib/app-session';
import {
  createBrowserPrintAdapter,
  formatDocumentTime,
  formatReceipt,
  type PaperSize,
  type ReceiptPrint,
  type ReceiptSnapshot,
} from '../lib/print-adapter';
import { conflictReason, describeFailure } from '../lib/request-failure';

async function read<T>(path: string, params?: Record<string, string | undefined>) {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

const adapter = createBrowserPrintAdapter();
const PAPER_KEY = 'parkviet-pos:receipt-paper';

function savedPaper(): PaperSize {
  try {
    return window.localStorage.getItem(PAPER_KEY) === 'a4' ? 'a4' : '80mm';
  } catch {
    return '80mm';
  }
}

type PrintJob = { print: ReceiptPrint; paper: PaperSize };

// A new search (or the menu link without one) starts from a clean page.
export function ReceiptPage() {
  const search = useSearch({ from: '/authed/receipts' });
  return <Receipts key={`${search.source ?? ''}:${search.receiptId ?? ''}`} />;
}

// Receipts of posted documents: look one up by its source or by number,
// preview it for an 80mm roll or A4, and print. The first print is the
// original; every later one is recorded and printed as "BẢN SAO". A print
// is recorded before the browser prints, so a failed or cancelled print
// still used up its number and the next one is a copy.
function Receipts() {
  const { t } = useTranslation();
  const search = useSearch({ from: '/authed/receipts' });
  const { context, selection } = usePosSelection();
  const snapshot = useSession();
  const [selectedId, setSelectedId] = useState<string | null>(search.receiptId ?? null);
  const [number, setNumber] = useState('');
  const [submitted, setSubmitted] = useState('');
  const [paper, setPaper] = useState<PaperSize>(savedPaper);
  // The receipt as returned by the last print; newer than any query.
  const [printed, setPrinted] = useState<ReceiptSnapshot | null>(null);
  const [job, setJob] = useState<PrintJob | null>(null);
  const delivered = useRef(new Set<string>());
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const authed = snapshot.status === 'authenticated';
  const branch = context.data?.branches.find((row) => row.id === selection.branchId);
  const zone = branch?.timezone ?? context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh';

  const bySource = useQuery({
    queryKey: ['pos', 'receipt-source', snapshot.generation, search.source ?? null],
    enabled: authed && Boolean(search.source) && !selectedId,
    retry: false,
    queryFn: async () =>
      (await read<{ data: ReceiptSnapshot }>('/pos/receipts/lookup', { source_id: search.source }))
        .data,
  });
  const byId = useQuery({
    queryKey: ['pos', 'receipt', snapshot.generation, selectedId],
    enabled: authed && Boolean(selectedId),
    retry: false,
    queryFn: async () =>
      (await read<{ data: ReceiptSnapshot }>(`/pos/receipts/${selectedId}`)).data,
  });
  const results = useQuery({
    queryKey: ['pos', 'receipts', snapshot.generation, selection.branchId, submitted],
    enabled: authed && Boolean(selection.branchId) && submitted !== '',
    queryFn: async () =>
      (
        await read<{ data: ReceiptSnapshot[] }>('/pos/receipts', {
          branch_id: selection.branchId ?? undefined,
          number: submitted,
        })
      ).data,
  });
  const loaded = (selectedId ? byId.data : bySource.data) ?? null;
  const receipt = printed ?? loaded;
  const loadError = printed ? null : selectedId ? byId.error : bySource.error;

  // While a print runs the sheet carries its recorded label; otherwise it
  // previews the next print (a copy once the original was used).
  const preview = useMemo(() => {
    if (!receipt) return null;
    const next = receipt.printed ? { copy: true, copy_number: receipt.copy_count + 1 } : null;
    return formatReceipt(receipt, job ? job.print : next, t);
  }, [receipt, job, t]);

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

  // Print only once the print copy carrying this print's label is in the DOM.
  useEffect(() => {
    if (!job || delivered.current.has(job.print.id)) return;
    const sheet = document.querySelector(
      `[data-testid="receipt-print-sheet"][data-print-id="${job.print.id}"]`,
    );
    if (!sheet) return;
    delivered.current.add(job.print.id);
    void adapter.deliver(job.paper).then((outcome) => {
      if (!outcome.ok)
        setError(t(outcome.reason === 'blocked' ? 'receiptPrintBlocked' : 'receiptPrintFailed'));
      setJob(null);
    });
  });

  const doPrint = async () => {
    if (!receipt || job) return;
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

  const submit = (event: FormEvent) => {
    event.preventDefault();
    setSubmitted(number.trim());
  };

  return (
    <PosPage title={t('receiptsTitle')} description={t('receiptsDescription')}>
      <form className="row receipt-search" onSubmit={submit}>
        <label>
          {t('receiptsSearchNumber')}
          <input
            value={number}
            onChange={(event) => setNumber(event.target.value)}
            maxLength={64}
          />
        </label>
        <button type="submit" disabled={!selection.branchId}>
          {t('receiptsSearch')}
        </button>
      </form>
      {results.data ? (
        results.data.length === 0 ? (
          <p className="muted">{t('receiptsNone')}</p>
        ) : (
          <ul className="record-list" aria-label={t('receiptsResults')}>
            {results.data.map((row) => (
              <li key={row.id}>
                <button
                  type="button"
                  disabled={Boolean(job)}
                  onClick={() => {
                    setPrinted(null);
                    setNotice('');
                    setError('');
                    setSelectedId(row.id);
                  }}
                >
                  {row.number} · {t(`receiptType_${row.source_type}`)} ·{' '}
                  {formatDocumentTime(row.issued_at, zone)}
                </button>
              </li>
            ))}
          </ul>
        )
      ) : null}
      {loadError ? (
        <p className="error" role="alert">
          {conflictReason(loadError) === 'receipt_unavailable'
            ? t('receiptUnavailable')
            : describeFailure(loadError, t)}
        </p>
      ) : null}
      {receipt && preview ? (
        <section className="receipt-workspace" aria-label={t('receiptPreview')}>
          <fieldset className="row">
            <legend>{t('receiptPaper')}</legend>
            {(['80mm', 'a4'] as const).map((size) => (
              <label key={size}>
                <input
                  type="radio"
                  name="receipt-paper"
                  checked={paper === size}
                  disabled={Boolean(job)}
                  onChange={() => {
                    setPaper(size);
                    try {
                      window.localStorage.setItem(PAPER_KEY, size);
                    } catch {
                      // Preference only.
                    }
                  }}
                />
                {t(`receiptPaper_${size}`)}
              </label>
            ))}
          </fieldset>
          <p className="muted">
            {receipt.printed
              ? t('receiptCopyCount', { count: receipt.copy_count })
              : t('receiptNotPrinted')}
          </p>
          <button
            type="button"
            disabled={print.isPending || Boolean(job)}
            onClick={() => void doPrint()}
          >
            {receipt.printed ? t('receiptReprint') : t('receiptPrint')}
          </button>
          {notice ? <p role="status">{notice}</p> : null}
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <div className="receipt-preview">
            <ReceiptSheet document={preview} paper={paper} printId={job?.print.id} />
          </div>
          <ReceiptPrintPortal
            document={preview}
            paper={job?.paper ?? paper}
            printId={job?.print.id}
          />
        </section>
      ) : null}
    </PosPage>
  );
}
