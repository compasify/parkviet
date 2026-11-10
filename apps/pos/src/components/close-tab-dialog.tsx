import { formatMoney } from '@parkviet/pos-shared/money';
import { useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';

// Asks before closing an invoice tab that already holds lines, a customer,
// a note, a discount or a payment. "Close tab" keeps the draft on the server;
// "Cancel invoice" also cancels it, which recorded payments forbid.
export function CloseTabDialog({
  workspace,
  number,
  canCancel,
  busy,
  onKeep,
  onCancelInvoice,
  onDismiss,
}: {
  workspace: PosWorkspace;
  number: number | undefined;
  canCancel: boolean;
  busy: boolean;
  onKeep: () => void;
  onCancelInvoice: () => void;
  onDismiss: () => void;
}) {
  const { t } = useTranslation();
  const dialog = useRef<HTMLDialogElement>(null);
  useEffect(() => {
    const element = dialog.current;
    const previous = document.activeElement;
    element?.showModal();
    element?.querySelector<HTMLButtonElement>('[data-autofocus]')?.focus();
    return () => {
      element?.close();
      if (previous instanceof HTMLElement && previous.isConnected) previous.focus();
    };
  }, []);
  const lines = workspace.line_items ?? [];
  const quantity = lines.reduce((sum, line) => sum + line.quantity, 0);
  const customer = workspace.customer?.name || workspace.customer?.phone;
  return (
    <dialog
      ref={dialog}
      className="context-setup-dialog close-tab-dialog"
      aria-labelledby="close-tab-title"
      aria-describedby="close-tab-hint"
      onCancel={(event) => {
        event.preventDefault();
        if (!busy) onDismiss();
      }}
    >
      <h2 id="close-tab-title">{t('closeTabTitle', { number })}</h2>
      <p id="close-tab-hint">{t('closeTabHint')}</p>
      <ul className="close-tab-summary">
        {lines.length > 0 ? <li>{t('closeTabLines', { count: lines.length, quantity })}</li> : null}
        {customer ? <li>{t('closeTabCustomer', { name: customer })}</li> : null}
        {workspace.note?.trim() ? <li>{t('closeTabNote')}</li> : null}
        {workspace.discount || workspace.coupon ? <li>{t('closeTabDiscount')}</li> : null}
        {workspace.totals && lines.length > 0 ? (
          <li>
            {t('closeTabTotal', {
              total: formatMoney(workspace.totals.total, workspace.totals.currency),
            })}
          </li>
        ) : null}
      </ul>
      {workspace.payments ? <p className="error">{t('closeTabPayments')}</p> : null}
      <div className="dialog-actions close-tab-actions">
        <button type="button" disabled={busy} onClick={onDismiss} data-autofocus>
          {t('closeTabBack')}
        </button>
        <button type="button" disabled={busy} onClick={onKeep}>
          {t('closeTabKeep')}
        </button>
        {canCancel ? (
          <button type="button" className="danger" disabled={busy} onClick={onCancelInvoice}>
            {t('closeTabCancelInvoice')}
          </button>
        ) : null}
      </div>
    </dialog>
  );
}
