import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useApprovalRequest, useApprovalRequestCommands } from '../hooks/use-approval-requests';
import type { ApprovalAsk, ApprovalSubject } from '../lib/approval-requests';
import { describeFailure } from '../lib/request-failure';

// "Gửi chủ duyệt": sends the approval the counter was refused for to the
// managers' phones and waits. A grant hands its approval to `onGranted`,
// which carries on as with a typed code; a refusal or a lapse is told here
// and may be asked again. Closing the form withdraws a request still waiting.
export function RemoteApprovalButton({
  branchId,
  subject,
  ask,
  reason,
  disabled,
  onGranted,
}: {
  branchId: string;
  subject: ApprovalSubject;
  // Null until the server refused the command for want of an approval.
  ask: ApprovalAsk | null;
  reason?: string;
  disabled?: boolean;
  onGranted: (approvalId: string) => void;
}) {
  const { t } = useTranslation();
  const { ask: send, cancel } = useApprovalRequestCommands();
  const [requestId, setRequestId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const request = useApprovalRequest(requestId);
  const status = request.data?.status;
  const handed = useRef<string | null>(null);
  const waiting = useRef<string | null>(null);
  const cancelRequest = useRef(cancel.mutate);
  cancelRequest.current = cancel.mutate;

  useEffect(() => {
    const approvalId = request.data?.approval_id;
    if (status !== 'granted' || !approvalId || handed.current === approvalId) return;
    handed.current = approvalId;
    waiting.current = null;
    onGranted(approvalId);
  }, [status, request.data?.approval_id, onGranted]);

  useEffect(() => {
    waiting.current = status === 'pending' ? requestId : null;
  }, [status, requestId]);

  // A request left waiting when the form closes is withdrawn.
  useEffect(
    () => () => {
      if (waiting.current) cancelRequest.current(waiting.current);
    },
    [],
  );

  if (!ask) return null;

  async function submit() {
    if (!ask) return;
    setError('');
    try {
      const created = await send.mutateAsync({ branchId, subject, ask, reason });
      setRequestId(created.id);
    } catch (failure) {
      setError(describeFailure(failure, t));
    }
  }

  const pending = status === 'pending' || send.isPending;
  const answer =
    status === 'declined'
      ? request.data?.reason
        ? t('remoteApprovalDeclinedReason', { reason: request.data.reason })
        : t('remoteApprovalDeclined')
      : status === 'expired' || status === 'canceled'
        ? t('remoteApprovalExpired')
        : '';

  return (
    <div className="remote-approval">
      {status === 'pending' ? (
        <p className="remote-approval-waiting" role="status">
          {t('remoteApprovalWaiting')}
        </p>
      ) : (
        <button
          type="button"
          className="remote-approval-button"
          disabled={disabled || pending}
          onClick={() => void submit()}
        >
          {t('remoteApprovalAsk')}
        </button>
      )}
      {status === 'granted' ? <p role="status">{t('remoteApprovalGranted')}</p> : null}
      {answer ? (
        <p className="error" role="alert">
          {answer}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  );
}
