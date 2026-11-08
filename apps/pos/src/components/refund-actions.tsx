import { type ReactNode, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney } from '../lib/money';
import {
  canCancelRefund,
  canFailRefund,
  type PosRefundRequest,
  refundAwaitsPayout,
} from '../lib/returns';
import { usePosSelection } from './pos-selection';
import { ReceiptPrintButton } from './receipt-print-dialog';

// One refund request with what the reader may do with it: confirm the payout
// (evidence dialog), cancel it with a reason before any approval, or record
// that it had no effect with evidence (resolvers). While this browser holds
// an unconfirmed command for it, nothing new is offered until it is checked.
export function RefundActions({
  refund,
  staffId,
  capabilities,
  disabled,
  checking,
  onPayout,
  onCancel,
  onFail,
  onRecheck,
  extra,
}: {
  refund: PosRefundRequest;
  staffId: string | null;
  capabilities: readonly string[];
  disabled: boolean;
  checking: boolean;
  onPayout?: () => void;
  onCancel: (reason: string) => void;
  onFail: (reference: string) => void;
  onRecheck: () => void;
  // Links or approval controls of the hosting page.
  extra?: ReactNode;
}) {
  const { t } = useTranslation();
  const [form, setForm] = useState<'cancel' | 'fail' | null>(null);
  const [text, setText] = useState('');
  const waiting = refund.status === 'reserved' && refund.approval?.status !== 'active';
  const cancelable = canCancelRefund(refund, staffId, capabilities);
  const failable = canFailRefund(refund, capabilities);
  const evidence = refund.evidence;
  // Cash is paid out of any open shift the confirmer owns at the branch, which
  // may be at another register than the one selected here. The page only
  // sees the selected register's shift, so it hints and leaves the decision
  // (and the `shift_required` explanation) to the server.
  const { context } = usePosSelection();
  const shift = context.data?.shift;
  const drawerUnseen =
    refund.method === 'cash' &&
    !(shift && shift.owner_id === staffId && shift.branch_id === refund.branch_id);
  const noteId = `refund-shift-${refund.id}`;

  return (
    <li className="refund-row">
      <div className="record-copy">
        <strong>
          {t(refund.method === 'cash' ? 'refundCash' : 'refundBank')} ·{' '}
          {formatMoney(refund.amount, refund.currency)}
        </strong>
        <small>
          {refund.order_number}
          {refund.beneficiary_reference ? ` · ${refund.beneficiary_reference}` : ''}
          {evidence?.kind === 'unknown' ? ` · ${t('refundEvidenceUnknown')}` : ''}
        </small>
      </div>
      <span
        className="status-tag"
        data-warning={refund.status === 'unknown' || refund.status === 'reserved'}
      >
        {t(`refundStatus_${refund.status}`)}
        {waiting ? ` · ${t('refundWaitApproval')}` : ''}
      </span>
      {refund.status === 'confirmed' ? (
        <ReceiptPrintButton sourceId={refund.id} label={t('receiptOpenRefund')} />
      ) : null}
      {extra}
      {checking ? (
        <span className="row" role="status">
          {t('pendingChecking')}
          <button type="button" disabled={disabled} onClick={onRecheck}>
            {t('pendingRecheck')}
          </button>
        </span>
      ) : (
        <span className="row">
          {onPayout && refundAwaitsPayout(refund.status) ? (
            <>
              <button
                type="button"
                disabled={disabled}
                aria-describedby={drawerUnseen ? noteId : undefined}
                onClick={onPayout}
              >
                {t('refundPayout')}
              </button>
              {drawerUnseen ? (
                <small className="muted" id={noteId}>
                  {t('refundNeedsOpenShift')}
                </small>
              ) : null}
            </>
          ) : null}
          {cancelable ? (
            <button
              type="button"
              disabled={disabled}
              aria-expanded={form === 'cancel'}
              onClick={() => {
                setText('');
                setForm(form === 'cancel' ? null : 'cancel');
              }}
            >
              {t('refundCancel')}
            </button>
          ) : null}
          {failable ? (
            <button
              type="button"
              disabled={disabled}
              aria-expanded={form === 'fail'}
              onClick={() => {
                setText('');
                setForm(form === 'fail' ? null : 'fail');
              }}
            >
              {t('refundFailed')}
            </button>
          ) : null}
        </span>
      )}
      {form && !checking ? (
        <form
          className="row"
          onSubmit={(event) => {
            event.preventDefault();
            const value = text.trim();
            if (!value) return;
            if (form === 'cancel') onCancel(value);
            else onFail(value);
            setForm(null);
          }}
        >
          <label>
            {t(form === 'cancel' ? 'refundCancelReason' : 'refundFailedEvidence')}
            <input
              value={text}
              maxLength={200}
              required
              autoComplete="off"
              disabled={disabled}
              onChange={(event) => setText(event.target.value)}
            />
          </label>
          <button type="submit" className="danger-button" disabled={disabled || !text.trim()}>
            {t(form === 'cancel' ? 'refundCancelConfirm' : 'refundFailedConfirm')}
          </button>
        </form>
      ) : null}
    </li>
  );
}
