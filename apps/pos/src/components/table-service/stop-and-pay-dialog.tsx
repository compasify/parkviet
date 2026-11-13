import { formatMoney } from '@parkviet/pos-shared/money';
import type { BoardTimed } from '@parkviet/pos-shared/tables';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTableCommands } from '../../hooks/use-resource-board';
import { useTimedQuote } from '../../hooks/use-timed';
import { type ApprovalAsk, askFromFailure } from '../../lib/approval-requests';
import { useModalFocus } from '../../lib/dialog-focus';
import type { PosWorkspace } from '../../lib/pos-context';
import { conflictReason, describeFailure } from '../../lib/request-failure';
import { timedFailureKey } from '../../lib/timed-clock';
import { RemoteApprovalButton } from '../remote-approval-button';
import type { SellingWorkspace } from '../workspace-tabs';

// A room clock still counting (or paused) on an order about to be paid.
export type StopAndPay = {
  sessionId: string;
  // The order the clock bills; null when the board did not say.
  workspaceId: string | null;
  room: string;
  // The server's last quote of the time, until the dialog reads a fresh one.
  amount: string | null;
  currency: string;
};

// The clock an order still counts, paused included; null once it stopped or
// when the order has none. The order's own time line says first; the board's
// clock of its room counts when the order came without that line.
export function runningClockOf(
  workspace: PosWorkspace | null | undefined,
  room: { name?: string | null; timed?: BoardTimed | null; currency?: string | null } = {},
): StopAndPay | null {
  if (!workspace) return null;
  const sessions = (workspace.line_items ?? []).flatMap((line) =>
    line.kind === 'timed' && line.timed_session ? [line.timed_session] : [],
  );
  const counting = sessions.find((session) => session.status !== 'stopped');
  if (counting)
    return {
      sessionId: counting.id,
      workspaceId: workspace.id,
      room: room.name || counting.resource_name || '',
      amount: counting.quote?.amount ?? counting.amount ?? null,
      currency: counting.currency ?? workspace.totals?.currency ?? 'VND',
    };
  const timed = room.timed;
  if (
    !timed ||
    (timed.status !== 'running' && timed.status !== 'paused') ||
    (timed.workspace_id ?? workspace.id) !== workspace.id ||
    // The order's line of that clock is newer than the board: it stopped.
    sessions.some((session) => session.id === timed.id)
  )
    return null;
  return {
    sessionId: timed.id,
    workspaceId: workspace.id,
    room: room.name ?? '',
    amount: timed.quote_amount,
    currency: room.currency ?? workspace.totals?.currency ?? 'VND',
  };
}

// "Dừng giờ và thanh toán P101?": an order is never paid while its clock
// counts. The dialog shows the time charge the server quotes now; saying yes
// stops the clock on the server (which prices it on the order), then the
// payment opens on that order. A clock someone else stopped meanwhile goes
// straight to the payment; a long pause asks for a manager's approval.
export function StopAndPayDialog({
  request,
  selling,
  onStopped,
  onClose,
}: {
  request: StopAndPay;
  selling: SellingWorkspace;
  // The clock stopped: open the payment of this order.
  onStopped: (workspaceId: string) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  useModalFocus(card, onClose);
  const { workspaces, selection, locked, selectionComplete } = selling;
  const quote = useTimedQuote(request.sessionId, true);
  const commands = useTableCommands(selection.branchId);
  const amount = quote.data?.quote?.amount ?? request.amount;
  // A second tap while the stop is on its way sends nothing.
  const sending = useRef(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [ask, setAsk] = useState<ApprovalAsk | null>(null);
  const disabled = busy || locked || !selectionComplete;

  async function stop(granted?: string) {
    if (sending.current) return;
    sending.current = true;
    setBusy(true);
    setError('');
    const approval = granted ?? (approvalId.trim() || undefined);
    try {
      const stopped = await workspaces.clockCommand(
        'POST',
        `/pos/timed_sessions/${request.sessionId}/stop`,
        approval ? { approval_id: approval } : {},
      );
      onStopped(stopped.id);
    } catch (failure) {
      const reason = conflictReason(failure);
      // Stopped meanwhile (another device, or a retry): the time is billed.
      if (reason === 'timed_session_stopped' && request.workspaceId) {
        await workspaces.refresh();
        onStopped(request.workspaceId);
        return;
      }
      const asked = askFromFailure(failure);
      if (asked) setAsk(asked);
      const key = timedFailureKey(reason);
      setError(key ? t(key) : describeFailure(failure, t));
    } finally {
      sending.current = false;
      setBusy(false);
      void commands.refreshBoard();
    }
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card stop-pay-dialog"
      >
        <h4 id={titleId}>{t('stopPayTitle', { room: request.room })}</h4>
        <p className="stop-pay-amount">
          <span>{t('stopPayEstimate')}</span>{' '}
          <strong>{amount ? formatMoney(amount, request.currency) : '—'}</strong>
        </p>
        <p className="muted">{t('stopPayHint')}</p>
        {ask ? (
          <div className="stop-pay-approval">
            <label>
              {t('timedEditApproval')}
              <input
                value={approvalId}
                autoComplete="off"
                onChange={(event) => setApprovalId(event.target.value)}
              />
            </label>
            {request.workspaceId && selection.branchId ? (
              <RemoteApprovalButton
                branchId={selection.branchId}
                subject={{ workspace_id: request.workspaceId }}
                ask={ask}
                disabled={disabled}
                onGranted={(id) => {
                  setApprovalId(id);
                  void stop(id);
                }}
              />
            ) : null}
          </div>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="row stop-pay-actions">
          <button type="button" onClick={onClose}>
            {t('timedEditCancel')}
          </button>
          <button
            type="button"
            className="primary-button"
            disabled={disabled || (ask !== null && !approvalId.trim())}
            onClick={() => void stop()}
          >
            {t('stopPayConfirm')}
          </button>
        </div>
      </div>
    </div>
  );
}
