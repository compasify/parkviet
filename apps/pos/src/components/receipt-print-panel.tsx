import { type QueryClient, useMutation, useQueryClient } from '@tanstack/react-query';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  loadReceiptTemplateVersion,
  refreshReceiptTemplates,
  usePrintTemplate,
} from '../hooks/use-receipt-templates';
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
import { snapshotDocumentType } from '../lib/receipt-template/data';
import { defaultTemplate } from '../lib/receipt-template/defaults';
import { printCopies } from '../lib/receipt-template/render';
import {
  autoPrintEnabled,
  type PrintChoice,
  rememberTemplate,
  setAutoPrint,
} from '../lib/receipt-template/selection';
import type { TemplateConfig } from '../lib/receipt-template/types';
import { serverIssues } from '../lib/receipt-template/validate';
import { describeFailure, failureStatus } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { ReceiptPrintPortal, ReceiptSheet } from './receipt-sheet';
import { TemplatePicker } from './template-picker';

const adapter = createBrowserPrintAdapter();

type PrintResult = { print: ReceiptPrint; receipt: ReceiptSnapshot };

// The asked-for template or version is refused (disabled or gone since the
// list loaded). Nothing was recorded, so printing on the server's own
// choice cannot print twice.
const layoutRefused = (error: unknown) =>
  failureStatus(error) === 422 &&
  serverIssues(error).some((issue) =>
    ['/receipt_template_id', '/template_version'].includes(issue.pointer),
  );

// The recorded prints of one press (the original and its copies, or one
// reprint) with the template they print with. `fallback` marks the
// built-in template standing in for one that could not be loaded.
type PrintJob = {
  prints: ReceiptPrint[];
  paper: PaperSize;
  config: TemplateConfig;
  fallback: boolean;
};

// What one press recorded: `total` prints were asked for; `failure` stopped
// the copies after `prints`, which are all recorded and still print.
type PrintBatch = {
  prints: ReceiptPrint[];
  receipt: ReceiptSnapshot;
  config: TemplateConfig | null;
  total: number;
  failure: unknown;
};

// Every cached read of this receipt (by source, by id, in a list) now
// holds the receipt as the last print returned it, so reopening it never
// starts from a receipt that looks unprinted.
function cachePrinted(client: QueryClient, receipt: ReceiptSnapshot) {
  const replace = (old: unknown) =>
    typeof old === 'object' && old !== null && (old as { id?: unknown }).id === receipt.id
      ? receipt
      : Array.isArray(old)
        ? old.map((row) => (row?.id === receipt.id ? receipt : row))
        : old;
  for (const key of ['receipt-source', 'receipt', 'receipts'])
    client.setQueriesData({ queryKey: ['pos', key] }, replace);
}

// The layout a recorded print used, so its copies print the same way.
function layoutOf(print: ReceiptPrint): Record<string, unknown> {
  if (!print.template_id || typeof print.template_version !== 'number') return {};
  return {
    receipt_template_id: print.template_id,
    template_version: print.template_version,
    ...(print.paper ? { paper: print.paper } : {}),
  };
}

// The config of the layout the server recorded: the one on screen when it
// matches, else that version read from the server. Null when it cannot be
// read; the print is recorded by then and must still go out.
async function recordedConfig(
  print: ReceiptPrint,
  shown: { choice: PrintChoice | null; config: TemplateConfig | null },
): Promise<TemplateConfig | null> {
  const id = print.template_id;
  const version = print.template_version;
  if (!id || typeof version !== 'number') return null;
  if (shown.config && shown.choice?.templateId === id && shown.choice.version === version)
    return shown.config;
  try {
    return (await loadReceiptTemplateVersion(id, version)).config;
  } catch {
    return null;
  }
}

// Print controls and preview of one posted receipt. The first print is the
// original; every later one is recorded and printed as "BẢN SAO". A print is
// recorded before the browser prints, so a failed or cancelled print still
// used up its number and the next one is a copy. A reprint starts from the
// template, version and paper of the original; another template prints with
// its current version. The sheet follows the layout the server recorded.
// A sale template may print several copies with the first press: each is
// recorded in turn under its own key, and a copy that could not be recorded
// is never printed. `autoPrint` prints a sale receipt that was never printed
// as soon as its template is ready. Key it by receipt id.
export function ReceiptPrintPanel({
  receipt: loaded,
  onBusyChange,
  autoPrint = false,
  refreshing = false,
}: {
  receipt: ReceiptSnapshot;
  onBusyChange?: (busy: boolean) => void;
  autoPrint?: boolean;
  // The receipt shown is a cached read being refreshed: what it says about
  // earlier prints may be out of date.
  refreshing?: boolean;
}) {
  const { t } = useTranslation();
  const queryClient = useQueryClient();
  // The receipt as returned by the last print; newer than the loaded one.
  const [printed, setPrinted] = useState<ReceiptSnapshot | null>(null);
  const [job, setJob] = useState<PrintJob | null>(null);
  const delivered = useRef(new Set<string>());
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const [autoOn, setAutoOn] = useState(autoPrintEnabled);
  const autoStarted = useRef(false);
  // The newer of the two: a refreshed read may know of prints made elsewhere.
  const printCount = (row: ReceiptSnapshot) => (row.printed ? row.copy_count + 1 : 0);
  const receipt = printed && printCount(printed) >= printCount(loaded) ? printed : loaded;
  const documentType = snapshotDocumentType(receipt);
  const template = usePrintTemplate(documentType, {
    original: receipt.original_print ?? null,
    remember: true,
  });

  const print = useMutation({
    mutationFn: async (target: ReceiptSnapshot): Promise<PrintBatch> => {
      const { choice } = template;
      // Only a loaded template counts; the built-in stand-in never does.
      const loadedConfig = template.loading || template.fallback ? null : template.config;
      const shown = { choice, config: loadedConfig };
      // Each attempt has its own key: the layout is part of the recorded command.
      const record = async (layout: Record<string, unknown>) => {
        const idempotencyKey = crypto.randomUUID();
        return (
          await session.request<{ data: PrintResult }>(
            'POST',
            `/pos/receipts/${target.id}/prints`,
            {
              body: { idempotency_key: idempotencyKey, ...layout },
              idempotencyKey,
            },
          )
        ).data;
      };
      let result: PrintResult;
      if (choice) {
        try {
          result = await record({
            receipt_template_id: choice.templateId,
            template_version: choice.version,
            paper: choice.paper,
          });
        } catch (failure) {
          if (!layoutRefused(failure)) throw failure;
          void refreshReceiptTemplates();
          template.reset();
          result = await record({});
        }
      } else {
        result = await record({});
      }
      const config = await recordedConfig(result.print, shown);
      // Copies come with the original only: the server, not the receipt on
      // screen (which may be a stale read), says whether this print was it.
      const total = result.print.copy
        ? 1
        : printCopies(config ?? defaultTemplate(documentType), documentType);
      const prints = [result.print];
      let receipt = result.receipt;
      let failure: unknown = null;
      while (prints.length < total) {
        try {
          const copy = await record(layoutOf(result.print));
          prints.push(copy.print);
          receipt = copy.receipt;
        } catch (copyFailure) {
          failure = copyFailure;
          break;
        }
      }
      return { prints, receipt, config, total, failure };
    },
  });
  const busy = print.isPending || Boolean(job);

  useEffect(() => {
    onBusyChange?.(busy);
  }, [busy, onBusyChange]);

  const config = job ? job.config : template.config;
  const paper = job ? job.paper : template.paper;
  const fallback = job ? job.fallback : template.fallback;

  // While a print runs the sheets carry their recorded labels; otherwise the
  // preview shows the next print (a copy once the original was used).
  const preview = useMemo(() => {
    const next = receipt.printed ? { copy: true, copy_number: receipt.copy_count + 1 } : null;
    return receiptPrintDocument(receipt, job?.prints[0] ?? next, t, config);
  }, [receipt, job, t, config]);
  const sheets = useMemo(
    () =>
      job?.prints.map((recorded) => ({
        document: receiptPrintDocument(receipt, recorded, t, job.config),
        printId: recorded.id,
      })),
    [receipt, job, t],
  );
  const copies = receipt.printed || refreshing ? 1 : printCopies(template.config, documentType);

  // Print only once the print copy carrying the last print's label is in the DOM.
  useEffect(() => {
    const last = job?.prints.at(-1);
    if (!job || !last || delivered.current.has(last.id)) return;
    const sheet = document.querySelector(
      `[data-testid="receipt-print-sheet"][data-print-id="${last.id}"]`,
    );
    if (!sheet) return;
    delivered.current.add(last.id);
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
      const batch = await print.mutateAsync(receipt);
      const [first] = batch.prints;
      if (!first) return;
      setPrinted(batch.receipt);
      cachePrinted(queryClient, batch.receipt);
      setNotice(
        batch.prints.length > 1
          ? t('receiptTemplates.counter.printedCopies', { count: batch.prints.length - 1 })
          : first.copy
            ? t('receiptPrintedCopy', { number: first.copy_number })
            : t('receiptPrintedOriginal'),
      );
      if (batch.failure) {
        abandonIfNeeded(batch.failure);
        // The recorded ones print; the rest were never recorded and do not.
        setError(
          t('receiptTemplates.counter.copiesFailed', {
            done: batch.prints.length,
            total: batch.total,
            reason: describeFailure(batch.failure, t),
          }),
        );
      }
      if (first.template_id) rememberTemplate(documentType, first.template_id);
      // The next print starts again from the original's template.
      template.reset();
      setJob({
        prints: batch.prints,
        paper: isPaperSize(first.paper) ? first.paper : template.paper,
        config: batch.config ?? defaultTemplate(documentType),
        fallback: batch.config === null,
      });
    } catch (failure) {
      abandonIfNeeded(failure);
      // Not recorded, so nothing is printed: a copy is never printed unlabelled.
      setError(t('receiptPrintNotRecorded', { reason: describeFailure(failure, t) }));
    }
  };

  // An automatic print starts once, when the template is ready.
  useEffect(() => {
    if (!autoPrint || autoStarted.current || receipt.printed || documentType !== 'sale') return;
    if (template.loading || refreshing) return;
    autoStarted.current = true;
    void doPrint();
  });

  return (
    <section className="receipt-print-panel" aria-label={t('receiptPreview')}>
      <div className="receipt-print-toolbar">
        <TemplatePicker
          choices={template.choices}
          value={template.choice?.key ?? null}
          disabled={busy}
          onChange={template.pick}
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
      {documentType === 'sale' ? (
        <label className="receipt-auto-print">
          <input
            type="checkbox"
            checked={autoOn}
            onChange={(event) => {
              setAutoPrint(event.target.checked);
              setAutoOn(event.target.checked);
            }}
          />
          {t('receiptTemplates.counter.autoPrint')}
        </label>
      ) : null}
      {copies > 1 ? (
        <p className="receipt-template-note" data-testid="receipt-copies-note">
          {t('receiptTemplates.counter.copies', { count: copies })}
        </p>
      ) : null}
      {template.loading && !job ? (
        <p className="receipt-template-note">{t('receiptTemplates.counter.loading')}</p>
      ) : null}
      {fallback ? (
        <p className="receipt-template-note" data-testid="receipt-template-fallback">
          {t('receiptTemplates.counter.fallback')}
        </p>
      ) : null}
      {notice ? <p role="status">{notice}</p> : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <div className="receipt-preview">
        <ReceiptSheet document={preview} paper={paper} printId={job?.prints[0]?.id} />
      </div>
      <ReceiptPrintPortal document={preview} paper={paper} sheets={sheets} />
    </section>
  );
}
