import { useEffect, useId, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useRequestCredit, useWorkspaceCredit } from '../hooks/use-receivables';
import { useModalFocus } from '../lib/dialog-focus';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosWorkspace, PosWorkspaceCredit } from '../lib/pos-context';
import {
  approvalExpired,
  describeCreditFailure,
  formatDueDate,
  formatInstant,
} from '../lib/receivables';
import { PosIcon } from './pos-icon';

function sameVnd(left: string | null | undefined, right: string | null | undefined) {
  const a = left == null ? null : parseVndAmount(left);
  const b = right == null ? null : parseVndAmount(right);
  return a !== null && a === b;
}

// Credit is never a tender. Opening the dialog asks a manager to approve the
// unpaid remainder; the dialog polls until that approval holds for this exact
// snapshot and only then offers "Hoàn tất & ghi nợ".
export function CreditApprovalDialog({
  workspace,
  busy,
  error,
  onComplete,
  onClose,
}: {
  workspace: PosWorkspace;
  busy: boolean;
  error: string;
  onComplete: (approvalId: string) => Promise<boolean>;
  onClose: () => void;
}) {
  const { t, i18n } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const requestCredit = useRequestCredit();
  const currency = workspace.totals?.currency ?? 'VND';
  const remaining = workspace.financial?.remaining ?? workspace.totals?.total ?? '0';
  const usableFor = (data: PosWorkspaceCredit | undefined) => {
    const held = data?.reservation;
    return Boolean(
      held?.usable &&
        held.workspace_revision === workspace.revision &&
        sameVnd(held.amount, remaining) &&
        !approvalExpired(held.expires_at),
    );
  };
  const blockerFor = (data: PosWorkspaceCredit | undefined): string | null => {
    if (!data) return null;
    if (!data.customer) return 'creditCustomerRequired';
    if (!data.account) return 'creditNoAccount';
    if (data.account.status === 'suspended') return 'creditAccountSuspended';
    return null;
  };
  // Keep polling while a manager may still answer.
  const firstLook = useWorkspaceCredit(
    workspace,
    true,
    (data) =>
      Boolean(data) &&
      !blockerFor(data) &&
      !usableFor(data) &&
      data?.request?.status !== 'rejected',
  );
  const credit = firstLook.data;
  const account = credit?.account ?? null;
  const reservation = credit?.reservation ?? null;
  const request = credit?.request ?? null;
  const usable = usableFor(credit);
  const blockerKey = blockerFor(credit);
  const blocker = blockerKey ? t(blockerKey) : null;

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  // One request per workspace revision; the server answers repeats with the same one.
  const askedRevision = useRef<number | null>(null);
  // biome-ignore lint/correctness/useExhaustiveDependencies: asks once per revision while nothing answers it yet
  useEffect(() => {
    if (askedRevision.current === workspace.revision || !credit || blocker || usable || request)
      return;
    askedRevision.current = workspace.revision;
    requestCredit.mutate(workspace);
  }, [credit, blocker, usable, request, workspace.revision]);

  const overLimit =
    account !== null &&
    !reservation &&
    BigInt(parseVndAmount(account.available) ?? '0') < BigInt(parseVndAmount(remaining) ?? '0');

  let waitingText: string | null = null;
  if (!blocker && credit && !usable) {
    if (request?.status === 'rejected')
      waitingText = t('creditRequestRejected', { reason: request.reason ?? '—' });
    else if (reservation || request?.status === 'approved' || request?.status === 'stale')
      waitingText = t('creditApprovalStale');
    else waitingText = t('creditWaitingApproval', { amount: formatMoney(remaining, currency) });
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card credit-approval"
      >
        <div className="pos-popup-header">
          <div>
            <h4 id={titleId}>{t('creditTitle')}</h4>
            <small className="muted">
              {workspace.order_id} ·{' '}
              {credit?.customer?.name ?? workspace.customer?.name ?? t('customerWalkIn')}
            </small>
          </div>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            disabled={busy}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <div className="invoice-totals">
          <div className="invoice-line">
            <span>{t('orderTotal')}</span>
            <span>{formatMoney(workspace.totals?.total, currency)}</span>
          </div>
          <div className="invoice-line">
            <span>{t('paymentReceived')}</span>
            <span>{formatMoney(workspace.financial?.allocated ?? '0', currency)}</span>
          </div>
          <div className="invoice-line invoice-line-highlight">
            <span>{t('creditAmount')}</span>
            <strong>{formatMoney(remaining, currency)}</strong>
          </div>
        </div>
        {firstLook.isLoading ? <p role="status">{t('waiting')}</p> : null}
        {firstLook.isError ? (
          <p className="error" role="alert">
            {describeCreditFailure(firstLook.error, t)}
          </p>
        ) : null}
        {account ? (
          <dl className="payment-summary credit-terms">
            <div>
              <dt>{t('creditLimit')}</dt>
              <dd>{formatMoney(account.credit_limit, account.currency)}</dd>
            </div>
            <div>
              <dt>{t('creditOpenDebt')}</dt>
              <dd>{formatMoney(account.open_debt, account.currency)}</dd>
            </div>
            <div>
              <dt>{t('creditAvailable')}</dt>
              <dd>{formatMoney(account.available, account.currency)}</dd>
            </div>
            <div>
              <dt>{t('creditDueDate')}</dt>
              <dd>{formatDueDate(account.due_on)}</dd>
            </div>
          </dl>
        ) : null}
        {blocker ? (
          <p className="error" role="alert">
            {blocker}
          </p>
        ) : null}
        {!blocker && usable && reservation ? (
          <dl className="payment-summary" aria-live="polite">
            <div>
              <dt>{t('creditApprover')}</dt>
              <dd>{reservation.approver.name}</dd>
            </div>
            <div>
              <dt>{t('creditApprovalExpires')}</dt>
              <dd>{formatInstant(reservation.expires_at, i18n.language)}</dd>
            </div>
          </dl>
        ) : null}
        {waitingText ? (
          <div className="payment-held" role="status" aria-live="polite">
            <p>{waitingText}</p>
            {request?.status === 'pending' ? (
              <p className="muted">
                {t('creditRequestSent', {
                  name: request.requester.name,
                  time: formatInstant(request.created_at, i18n.language),
                })}
              </p>
            ) : null}
            {overLimit ? <p className="error">{t('creditOverLimit')}</p> : null}
          </div>
        ) : null}
        {requestCredit.isError ? (
          <p className="error" role="alert">
            {describeCreditFailure(requestCredit.error, t)}
          </p>
        ) : null}
        {!usable ? (
          <button
            type="button"
            disabled={firstLook.isFetching}
            onClick={() => void firstLook.refetch()}
          >
            {firstLook.isFetching ? t('waiting') : t('creditCheckApproval')}
          </button>
        ) : null}
        <p className="muted">{t('creditNotTender')}</p>
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="payment-popup-actions">
          <button
            type="button"
            className="checkout-submit"
            disabled={busy || !usable || Boolean(blocker) || !reservation}
            onClick={() => {
              if (!reservation) return;
              void onComplete(reservation.approval_id).then((done) => {
                if (!done) void firstLook.refetch();
              });
            }}
          >
            {busy ? t('waiting') : t('creditCompleteAction')}
          </button>
          <button type="button" disabled={busy} onClick={onClose}>
            {t('creditClose')}
          </button>
        </div>
      </div>
    </div>
  );
}
