import { formatMoney } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useDecideCashRequest } from '../hooks/use-shift-close';
import { definitiveRejection } from '../lib/request-failure';
import { type CashMovementRequest, describeShiftFailure, formatInZone } from '../lib/shifts';

// Cash out / safe drop requests. A confirmer (someone other than the
// requester) confirms or declines; the requester can only withdraw their own.
export function CashRequestList({
  requests,
  actor,
  locked,
  timeZone,
  mode,
}: {
  requests: CashMovementRequest[];
  actor: { staffId: string | null; storeId: string | null };
  locked: boolean;
  timeZone: string;
  mode: 'confirm' | 'own';
}) {
  const { t, i18n } = useTranslation();
  const decide = useDecideCashRequest(actor);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [uncertainId, setUncertainId] = useState<string | null>(null);
  const [cancelId, setCancelId] = useState<string | null>(null);
  const [note, setNote] = useState('');

  function run(request: CashMovementRequest, decision: 'confirm' | 'cancel', withNote?: string) {
    setError('');
    decide.mutate(
      { request, decision, note: withNote },
      {
        onSuccess: () => {
          setUncertainId(null);
          setCancelId(null);
          setNote('');
          setNotice(
            t(decision === 'confirm' ? 'cashRequestConfirmed' : 'cashRequestCanceled', {
              kind: t(`cashMovement_${request.kind}`),
              amount: formatMoney(request.amount, request.currency),
            }),
          );
        },
        onError: (failure) => {
          setUncertainId(definitiveRejection(failure) ? null : request.id);
          setError(describeShiftFailure(failure, t));
        },
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
        {requests.map((request) => {
          const own = request.requester_id === actor.staffId;
          return (
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
                      if (note.trim()) run(request, 'cancel', note.trim());
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
                    {mode === 'confirm' && !own ? (
                      <button
                        type="button"
                        className="checkout-submit"
                        disabled={locked || decide.isPending}
                        onClick={() => run(request, 'confirm')}
                      >
                        {uncertainId === request.id
                          ? t('shiftCommandRecheck')
                          : t('cashRequestConfirm')}
                      </button>
                    ) : null}
                    {mode === 'own' || !own ? (
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
                    ) : null}
                    {mode === 'confirm' && own ? (
                      <small className="muted">{t('cashRequestOwn')}</small>
                    ) : null}
                  </div>
                )
              ) : null}
            </li>
          );
        })}
      </ul>
    </>
  );
}
