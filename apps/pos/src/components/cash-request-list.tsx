import { formatMoney } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useDecideCashRequest } from '../hooks/use-shift-close';
import { type CashMovementRequest, describeShiftFailure, formatInZone } from '../lib/shifts';

// The cashier's own cash out / safe drop requests, which they can withdraw.
// Someone else confirms them from the POS dashboard.
export function CashRequestList({
  requests,
  actor,
  locked,
  timeZone,
}: {
  requests: CashMovementRequest[];
  actor: { staffId: string | null; storeId: string | null };
  locked: boolean;
  timeZone: string;
}) {
  const { t, i18n } = useTranslation();
  const decide = useDecideCashRequest(actor);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [cancelId, setCancelId] = useState<string | null>(null);
  const [note, setNote] = useState('');

  function withdraw(request: CashMovementRequest, withNote: string) {
    setError('');
    decide.mutate(
      { request, decision: 'cancel', note: withNote },
      {
        onSuccess: () => {
          setCancelId(null);
          setNote('');
          setNotice(
            t('cashRequestCanceled', {
              kind: t(`cashMovement_${request.kind}`),
              amount: formatMoney(request.amount, request.currency),
            }),
          );
        },
        onError: (failure) => setError(describeShiftFailure(failure, t)),
      },
    );
  }

  // The outcome notice stays after the decided request leaves the list.
  if (requests.length === 0 && !notice && !error) return null;
  return (
    <>
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
      <ul className="record-list" aria-label={t('cashRequestsTitle')}>
        {requests.map((request) => (
          <li key={request.id}>
            <div className="record-copy">
              <strong>
                {t(`cashMovement_${request.kind}`)} ·{' '}
                {formatMoney(request.amount, request.currency)}
              </strong>
              <small>
                {request.reason} · {request.evidence_reference} · {request.requester_name} ·{' '}
                {formatInZone(request.created_at, i18n.language, timeZone)}
              </small>
              <span className="status-tag" data-warning={String(request.status === 'requested')}>
                {t(`cashRequestStatus_${request.status}`)}
              </span>
            </div>
            {request.status === 'requested' ? (
              cancelId === request.id ? (
                <form
                  className="row"
                  onSubmit={(event) => {
                    event.preventDefault();
                    if (note.trim()) withdraw(request, note.trim());
                  }}
                >
                  <label>
                    {t('cashRequestCancelNote')}
                    <input
                      value={note}
                      maxLength={200}
                      required
                      onChange={(event) => setNote(event.target.value)}
                    />
                  </label>
                  <button type="submit" disabled={locked || decide.isPending || !note.trim()}>
                    {t('cashRequestCancel')}
                  </button>
                </form>
              ) : (
                <div className="row">
                  <button
                    type="button"
                    disabled={locked || decide.isPending}
                    onClick={() => {
                      setCancelId(request.id);
                      setNote('');
                    }}
                  >
                    {t('cashRequestCancel')}
                  </button>
                </div>
              )
            ) : null}
          </li>
        ))}
      </ul>
    </>
  );
}
