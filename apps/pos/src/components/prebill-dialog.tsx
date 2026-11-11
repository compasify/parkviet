import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePrintRoute } from '../hooks/use-print-jobs';
import { usePrintTemplate } from '../hooks/use-receipt-templates';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { session } from '../lib/app-session';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import { createBrowserPrintAdapter, prebillPrintDocument, printTitle } from '../lib/print-adapter';
import { BROWSER_ROUTE, deliverDirect, type PrintRoute } from '../lib/print-adapters';
import { printRefusal } from '../lib/print-queue-messages';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';
import { ReceiptPrintPortal, ReceiptSheet } from './receipt-sheet';
import { TemplatePicker } from './template-picker';

const adapter = createBrowserPrintAdapter();

// Provisional bill of an open order, from the server figures on screen. It is
// labelled "TẠM TÍNH – CHƯA THANH TOÁN" and has no receipt number. It prints
// with the store's current default pre-bill template (or another active one
// picked here) on that template's paper. Sent to a print station it is built
// on the server and counted, so a second print of the same content needs a
// reprint with a manager's approval. The browser and a LAN printer record
// nothing yet, so the limit does not cover them.
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
  const template = usePrintTemplate('prebill');
  const { paper } = template;
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [busy, setBusy] = useState(false);
  const [offerBrowser, setOfferBrowser] = useState(false);
  const printRoute = usePrintRoute(workspace.branch_id, workspace.register_id ?? null, 'prebill');
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
    template.config,
  );

  const queue = async (route: Extract<PrintRoute, { kind: 'queue' }>) => {
    const idempotencyKey = crypto.randomUUID();
    try {
      await session.request('POST', '/pos/print_jobs', {
        body: {
          idempotency_key: idempotencyKey,
          kind: 'prebill',
          printer_id: route.printer.id,
          workspace_id: workspace.id,
          ...(template.choice ? { receipt_template_id: template.choice.templateId } : {}),
        },
        idempotencyKey,
      });
      setNotice(t('printQueuedNotice', { printer: route.printer.name }));
    } catch (failure) {
      abandonIfNeeded(failure);
      setError(
        printRefusal(failure, t) ??
          (conflictReason(failure) === 'prebill_already_printed'
            ? t('printPrebillAlreadyPrinted')
            : describeFailure(failure, t)),
      );
    }
  };

  const direct = async (route: Extract<PrintRoute, { kind: 'direct' }>) => {
    const outcome = await deliverDirect(route.printer, document);
    if (outcome.ok) return;
    setError(t(`printOutcome_${outcome.reason}`, { printer: route.printer.name }));
    setOfferBrowser(true);
  };

  const browser = async () => {
    const outcome = await adapter.deliver(paper, {
      title: printTitle(t('receiptPrebillTitle'), null, workspace.order_id, t),
    });
    if (!outcome.ok)
      setError(t(outcome.reason === 'blocked' ? 'prebillPrintBlocked' : 'prebillPrintFailed'));
  };

  const doPrint = async (route: PrintRoute = printRoute.route) => {
    if (busy) return;
    setError('');
    setNotice('');
    setOfferBrowser(false);
    setBusy(true);
    try {
      if (route.kind === 'queue') await queue(route);
      else if (route.kind === 'direct') await direct(route);
      else await browser();
    } finally {
      setBusy(false);
    }
  };

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
          {template.choices.length > 1 ? (
            <TemplatePicker
              choices={template.choices}
              value={template.choice?.key ?? null}
              onChange={template.pick}
            />
          ) : null}
          <button
            type="button"
            className="primary-button"
            disabled={busy || printRoute.loading}
            onClick={() => void doPrint()}
          >
            <PosIcon name="print" />
            {t('receiptPrebillPrint')}
          </button>
        </div>
        {template.fallback ? (
          <p className="receipt-template-note">{t('receiptTemplates.counter.fallback')}</p>
        ) : null}
        {notice ? <p role="status">{notice}</p> : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        {offerBrowser ? (
          <button type="button" disabled={busy} onClick={() => void doPrint(BROWSER_ROUTE)}>
            {t('printUseBrowser')}
          </button>
        ) : null}
        <div className="receipt-preview">
          <ReceiptSheet document={document} paper={paper} />
        </div>
        <ReceiptPrintPortal document={document} paper={paper} />
      </div>
    </div>
  );
}
