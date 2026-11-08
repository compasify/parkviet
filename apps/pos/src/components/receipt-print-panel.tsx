import { useMutation } from '@tanstack/react-query';
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
import { type PrintChoice, rememberTemplate } from '../lib/receipt-template/selection';
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

// A recorded print with the template it prints with. `fallback` marks the
// built-in template standing in for one that could not be loaded.
type PrintJob = {
  print: ReceiptPrint;
  paper: PaperSize;
  config: TemplateConfig;
  fallback: boolean;
};

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
// Key it by receipt id.
export function ReceiptPrintPanel({
  receipt: loaded,
  onBusyChange,
}: {
  receipt: ReceiptSnapshot;
  onBusyChange?: (busy: boolean) => void;
}) {
  const { t } = useTranslation();
  // The receipt as returned by the last print; newer than the loaded one.
  const [printed, setPrinted] = useState<ReceiptSnapshot | null>(null);
  const [job, setJob] = useState<PrintJob | null>(null);
  const delivered = useRef(new Set<string>());
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const receipt = printed ?? loaded;
  const documentType = snapshotDocumentType(receipt);
  const template = usePrintTemplate(documentType, {
    original: receipt.original_print ?? null,
    remember: true,
  });

  const print = useMutation({
    mutationFn: async (target: ReceiptSnapshot) => {
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
      return { ...result, config: await recordedConfig(result.print, shown) };
    },
  });
  const busy = print.isPending || Boolean(job);

  useEffect(() => {
    onBusyChange?.(busy);
  }, [busy, onBusyChange]);

  const config = job ? job.config : template.config;
  const paper = job ? job.paper : template.paper;
  const fallback = job ? job.fallback : template.fallback;

  // While a print runs the sheet carries its recorded label; otherwise it
  // previews the next print (a copy once the original was used).
  const preview = useMemo(() => {
    const next = receipt.printed ? { copy: true, copy_number: receipt.copy_count + 1 } : null;
    return receiptPrintDocument(receipt, job ? job.print : next, t, config);
  }, [receipt, job, t, config]);

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
      if (result.print.template_id) rememberTemplate(documentType, result.print.template_id);
      // The next print starts again from the original's template.
      template.reset();
      setJob({
        print: result.print,
        paper: isPaperSize(result.print.paper) ? result.print.paper : template.paper,
        config: result.config ?? defaultTemplate(documentType),
        fallback: result.config === null,
      });
    } catch (failure) {
      abandonIfNeeded(failure);
      // Not recorded, so nothing is printed: a copy is never printed unlabelled.
      setError(t('receiptPrintNotRecorded', { reason: describeFailure(failure, t) }));
    }
  };

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
        <ReceiptSheet document={preview} paper={paper} printId={job?.print.id} />
      </div>
      <ReceiptPrintPortal document={preview} paper={paper} printId={job?.print.id} />
    </section>
  );
}
