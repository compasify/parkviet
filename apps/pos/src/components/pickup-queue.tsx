import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePickupQueue } from '../hooks/use-kitchen';
import { describeFailure } from '../lib/request-failure';

// The counter's pickup queue: the call numbers the kitchen is still making,
// and those ready to hand over with "Đã giao", which serves every ready item
// of the order and takes the number off the call board.
export function PickupQueue({ branchId }: { branchId: string | null }) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [message, setMessage] = useState('');
  const { query, serve } = usePickupQueue(branchId, open);
  const ready = query.data?.ready ?? [];
  const preparing = query.data?.preparing ?? [];

  return (
    <section className="pickup-queue" aria-label={t('pickupTitle')}>
      <button
        type="button"
        aria-expanded={open}
        data-testid="pickup-toggle"
        onClick={() => setOpen((value) => !value)}
      >
        {t('pickupTitle')}
        {open && ready.length > 0 ? ` (${ready.length})` : ''}
      </button>
      {open ? (
        query.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : query.isError ? (
          <p role="alert">{t('pickupFailed')}</p>
        ) : (
          <div className="pickup-columns">
            <div>
              <h4>{t('pickupPreparing')}</h4>
              {preparing.length === 0 ? (
                <p className="muted">{t('pickupNone')}</p>
              ) : (
                <ul className="pickup-numbers" data-testid="pickup-preparing">
                  {preparing.map((row) => (
                    <li key={row.workspace_id}>{row.number}</li>
                  ))}
                </ul>
              )}
            </div>
            <div>
              <h4>{t('pickupReady')}</h4>
              {ready.length === 0 ? (
                <p className="muted">{t('pickupNone')}</p>
              ) : (
                <ul className="pickup-numbers pickup-ready" data-testid="pickup-ready">
                  {ready.map((row) => (
                    <li key={row.workspace_id}>
                      <strong>{row.number}</strong>
                      {row.guest_name ? <span> · {row.guest_name}</span> : null}
                      <button
                        type="button"
                        disabled={serve.isPending}
                        aria-label={t('pickupServeNumber', { number: row.number })}
                        onClick={() => {
                          setMessage('');
                          serve
                            .mutateAsync(row.workspace_id)
                            .catch((error: unknown) => setMessage(describeFailure(error, t)));
                        }}
                      >
                        {t('pickupServe')}
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        )
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </section>
  );
}
