import { formatMoney } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { Link } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FeatureOffNote } from '../components/feature-off-note';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { RefundActions } from '../components/refund-actions';
import { ShiftApprovals } from '../components/shift-approvals';
import { useCreditRequests, useDecideCredit } from '../hooks/use-receivables';
import {
  useBranchReturns,
  usePendingReturnCommands,
  useRefundCommands,
  useRefundRequests,
  useReturnCommands,
} from '../hooks/use-returns';
import type { PosCreditRequest } from '../lib/pos-context';
import { writesLocked } from '../lib/pos-context';
import { describeCreditFailure, formatInstant } from '../lib/receivables';
import { definitiveRejection, posFailureKey } from '../lib/request-failure';
import { canApprove, describeReturnFailure } from '../lib/returns';

function RequestRow({
  request,
  disabled,
  creditOff,
  onDecide,
}: {
  request: PosCreditRequest;
  disabled: boolean;
  // Credit is switched off at the request's branch: approving is refused by
  // the server; rejecting and revoking stay open.
  creditOff: boolean;
  onDecide: (decision: 'approve' | 'reject' | 'revoke', reason?: string) => void;
}) {
  const { t, i18n } = useTranslation();
  const [rejecting, setRejecting] = useState(false);
  const [reason, setReason] = useState('');
  return (
    <li className="credit-request-row">
      <div className="record-copy">
        <strong>
          {request.order_number} · {request.customer.name}
        </strong>
        <small>
          {t('creditRequestedBy', {
            name: request.requester.name,
            time: formatInstant(request.created_at, i18n.language),
          })}
        </small>
        <span className="status-tag" data-warning={request.status === 'pending'}>
          {t(`creditRequestStatus_${request.status}`)}
        </span>
      </div>
      <strong>{formatMoney(request.amount, request.currency)}</strong>
      {request.status === 'pending' ? (
        rejecting ? (
          <form
            className="row"
            onSubmit={(event) => {
              event.preventDefault();
              if (reason.trim()) onDecide('reject', reason.trim());
            }}
          >
            <label>
              {t('creditRejectReason')}
              <input
                value={reason}
                maxLength={200}
                required
                disabled={disabled}
                onChange={(event) => setReason(event.target.value)}
              />
            </label>
            <button type="submit" className="danger-button" disabled={disabled || !reason.trim()}>
              {t('creditReject')}
            </button>
            <button type="button" disabled={disabled} onClick={() => setRejecting(false)}>
              {t('paymentCancelNo')}
            </button>
          </form>
        ) : (
          <div className="row">
            <button
              type="button"
              className="checkout-submit"
              disabled={disabled || creditOff}
              aria-describedby={creditOff ? `credit-off-${request.id}` : undefined}
              onClick={() => onDecide('approve')}
            >
              {t('creditApprove')}
            </button>
            <button type="button" disabled={disabled} onClick={() => setRejecting(true)}>
              {t('creditReject')}
            </button>
            {creditOff ? <FeatureOffNote feature="credit" id={`credit-off-${request.id}`} /> : null}
          </div>
        )
      ) : null}
      {request.status === 'approved' && request.approval_active ? (
        <button type="button" disabled={disabled} onClick={() => onDecide('revoke')}>
          {t('creditRevoke')}
        </button>
      ) : null}
    </li>
  );
}

// The approver's own session: returns and refund payouts waiting for approval,
// and (for credit managers) credit requests and approvals that still hold
// exposure, which can be revoked.
export function CreditApprovalsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <CreditApprovals key={scope} />;
}

function CreditApprovals() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const approver = canApprove(data?.capabilities);
  const creditApprover = Boolean(approver && data?.capabilities.includes('pos.credit.manage'));
  const locked = !data || writesLocked(data, selection);

  return (
    <PosPage title={t('approvalsTitle')} description={t('approvalsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !approver ? (
        <PageState title={t('forbidden')} />
      ) : (
        <>
          <ShiftApprovals
            branchId={branchId}
            actor={{ staffId: data?.staff.id ?? null, storeId: data?.store.id ?? null }}
            locked={locked}
            timeZone={
              data?.branches.find((row) => row.id === branchId)?.timezone ??
              data?.store.timezone ??
              'Asia/Ho_Chi_Minh'
            }
            canConfirmCash={Boolean(
              data?.capabilities.includes('pos.cash.move') ||
                data?.capabilities.includes('pos.approval.grant'),
            )}
          />
          <ReturnApprovals branchId={branchId} locked={locked} />
          {creditApprover ? <CreditRequests branchId={branchId} locked={locked} /> : null}
        </>
      )}
    </PosPage>
  );
}

function CreditRequests({ branchId, locked }: { branchId: string; locked: boolean }) {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  // The context's flags are those of the selected branch.
  const creditOff = (request: PosCreditRequest) =>
    request.branch_id === selection.branchId && !contextFeature(context.data, 'credit');
  const requests = useCreditRequests(branchId, true);
  const decide = useDecideCredit();
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  return (
    <section className="page-card" aria-label={t('creditApprovalsCredit')}>
      <h2>{t('creditApprovalsCredit')}</h2>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {requests.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
      {requests.isError ? (
        <PageState kind="error" title={t(posFailureKey(requests.error))} />
      ) : null}
      {requests.isSuccess && requests.data.data.length === 0 ? (
        <PageState kind="empty" title={t('creditApprovalsEmpty')} />
      ) : null}
      <ul className="record-list" aria-label={t('creditApprovalsCredit')}>
        {(requests.data?.data ?? []).map((request) => (
          <RequestRow
            key={request.id}
            request={request}
            disabled={locked || decide.isPending}
            creditOff={creditOff(request)}
            onDecide={(decision, reason) => {
              setError('');
              setNotice('');
              decide.mutate(
                { requestId: request.id, decision, reason },
                {
                  onSuccess: () =>
                    setNotice(t(`creditDecision_${decision}`, { order: request.order_number })),
                  onError: (failure) => setError(describeCreditFailure(failure, t)),
                },
              );
            }}
          />
        ))}
      </ul>
    </section>
  );
}

// Returns waiting for an approver (cross-branch, outside the window, damaged
// goods) and refund payouts waiting for one. Approving binds the approval to
// the requester, the record, its revision and amount; nobody approves their
// own. Each row opens its return, where the payout is confirmed with
// evidence. Unknown payouts stay listed until resolved with evidence.
function ReturnApprovals({ branchId, locked }: { branchId: string; locked: boolean }) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const staffId = context.data?.staff.id ?? null;
  const storeId = context.data?.store.id ?? null;
  const capabilities = context.data?.capabilities ?? [];
  const returns = useBranchReturns(branchId, true);
  const refunds = useRefundRequests(branchId, true);
  const { approve, cancel } = useReturnCommands(staffId, storeId);
  const refundCommands = useRefundCommands(staffId, storeId);
  const pending = usePendingReturnCommands(staffId, storeId);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [rejecting, setRejecting] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const busy =
    approve.isPending ||
    cancel.isPending ||
    refundCommands.approve.isPending ||
    refundCommands.resolve.isPending;
  const fail = (failure: unknown) =>
    setError(
      definitiveRejection(failure) ? describeReturnFailure(failure, t) : t('pendingCheckingLost'),
    );
  const pendingReturns = (returns.data?.data ?? []).filter(
    (row) => row.approval?.status !== 'active',
  );
  const waitingRefunds = refunds.data?.data ?? [];

  return (
    <section className="page-card" aria-label={t('approvalsReturns')}>
      <h2>{t('approvalsReturns')}</h2>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {returns.isError || refunds.isError ? (
        <PageState kind="error" title={t(posFailureKey(returns.error ?? refunds.error))} />
      ) : null}
      {returns.isSuccess &&
      refunds.isSuccess &&
      pendingReturns.length === 0 &&
      waitingRefunds.length === 0 ? (
        <PageState kind="empty" title={t('approvalsReturnsEmpty')} />
      ) : null}
      <ul className="record-list" aria-label={t('approvalsReturnList')}>
        {pendingReturns.map((row) => (
          <li key={row.id} className="credit-request-row">
            <div className="record-copy">
              <Link to="/returns" search={{ returnId: row.id }}>
                <strong>
                  {row.return_number} · {row.order_number}
                </strong>
              </Link>
              <small>
                {[
                  row.cross_branch ? t('returnWhyCrossBranch') : null,
                  row.out_of_window ? t('returnWhyWindow') : null,
                  row.damaged ? t('returnWhyDamaged') : null,
                ]
                  .filter(Boolean)
                  .join(', ')}{' '}
                · {row.reason}
              </small>
            </div>
            <strong>{formatMoney(row.entitlement_total, row.currency)}</strong>
            {rejecting === row.id ? (
              <form
                className="row"
                onSubmit={(event) => {
                  event.preventDefault();
                  const reason = rejectReason.trim();
                  if (!reason) return;
                  setError('');
                  cancel.mutate(
                    { returnId: row.id, reason },
                    {
                      onSuccess: () => {
                        setRejecting(null);
                        setNotice(t('approvalsReturnRejected', { number: row.return_number }));
                      },
                      onError: fail,
                    },
                  );
                }}
              >
                <label>
                  {t('creditRejectReason')}
                  <input
                    value={rejectReason}
                    maxLength={200}
                    required
                    disabled={locked || busy}
                    onChange={(event) => setRejectReason(event.target.value)}
                  />
                </label>
                <button
                  type="submit"
                  className="danger-button"
                  disabled={locked || busy || !rejectReason.trim()}
                >
                  {t('approvalsReject')}
                </button>
                <button type="button" disabled={busy} onClick={() => setRejecting(null)}>
                  {t('paymentCancelNo')}
                </button>
              </form>
            ) : (
              <div className="row">
                <button
                  type="button"
                  className="checkout-submit"
                  disabled={locked || busy || row.requester_id === staffId}
                  title={row.requester_id === staffId ? t('returnReason_self_approval') : undefined}
                  onClick={() => {
                    setError('');
                    approve.mutate(row.id, {
                      onSuccess: () =>
                        setNotice(t('approvalsReturnApproved', { number: row.return_number })),
                      onError: fail,
                    });
                  }}
                >
                  {t('approvalsApprove')}
                </button>
                <button
                  type="button"
                  disabled={locked || busy}
                  onClick={() => {
                    setRejectReason('');
                    setRejecting(row.id);
                  }}
                >
                  {t('approvalsReject')}
                </button>
              </div>
            )}
          </li>
        ))}
      </ul>
      <ul className="record-list" aria-label={t('approvalsRefundList')}>
        {waitingRefunds.map((refund) => (
          <RefundActions
            key={refund.id}
            refund={refund}
            staffId={staffId}
            capabilities={capabilities}
            disabled={locked || busy}
            checking={pending.pendingFor(refund.id).length > 0}
            onRecheck={() => {
              for (const record of pending.pendingFor(refund.id)) {
                void pending
                  .recheck(record)
                  .then((result) => result.committed && setNotice(t('pendingRecovered')), fail);
              }
            }}
            onCancel={(reason) =>
              refundCommands.resolve.mutate(
                { refund, outcome: 'cancel', reason },
                { onError: fail },
              )
            }
            onFail={(reference) =>
              refundCommands.resolve.mutate(
                { refund, outcome: 'failed_no_effect', reference },
                { onError: fail },
              )
            }
            extra={
              <span className="row">
                <Link to="/returns" search={{ returnId: refund.return_id }}>
                  {t('approvalsOpenReturn')}
                </Link>
                {refund.status === 'reserved' && refund.approval?.status !== 'active' ? (
                  <button
                    type="button"
                    className="checkout-submit"
                    disabled={locked || busy || refund.requester_id === staffId}
                    onClick={() => {
                      setError('');
                      refundCommands.approve.mutate(refund.id, {
                        onSuccess: () =>
                          setNotice(t('approvalsRefundApproved', { order: refund.order_number })),
                        onError: fail,
                      });
                    }}
                  >
                    {t('approvalsApprove')}
                  </button>
                ) : null}
              </span>
            }
          />
        ))}
      </ul>
    </section>
  );
}
