import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { useCreditRequests, useDecideCredit } from '../hooks/use-receivables';
import { formatMoney } from '../lib/money';
import type { PosCreditRequest } from '../lib/pos-context';
import { writesLocked } from '../lib/pos-context';
import { describeCreditFailure, formatInstant } from '../lib/receivables';
import { posFailureKey } from '../lib/request-failure';

function RequestRow({
  request,
  disabled,
  onDecide,
}: {
  request: PosCreditRequest;
  disabled: boolean;
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
              disabled={disabled}
              onClick={() => onDecide('approve')}
            >
              {t('creditApprove')}
            </button>
            <button type="button" disabled={disabled} onClick={() => setRejecting(true)}>
              {t('creditReject')}
            </button>
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

// The approver's own session: credit requests waiting for a decision and
// approvals that still hold exposure, which can be revoked.
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
  const allowed = Boolean(
    data?.capabilities.includes('pos.approval.grant') &&
      data.capabilities.includes('pos.credit.manage'),
  );
  const locked = !data || writesLocked(data, selection);

  return (
    <PosPage title={t('creditApprovalsTitle')} description={t('creditApprovalsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !allowed ? (
        <PageState title={t('forbidden')} />
      ) : (
        <CreditRequests branchId={branchId} locked={locked} />
      )}
    </PosPage>
  );
}

function CreditRequests({ branchId, locked }: { branchId: string; locked: boolean }) {
  const { t } = useTranslation();
  const requests = useCreditRequests(branchId, true);
  const decide = useDecideCredit();
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  return (
    <section className="page-card" aria-label={t('creditApprovalsTitle')}>
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
      <ul className="record-list" aria-label={t('creditApprovalsTitle')}>
        {(requests.data?.data ?? []).map((request) => (
          <RequestRow
            key={request.id}
            request={request}
            disabled={locked || decide.isPending}
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
