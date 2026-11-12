import { Link } from '@tanstack/react-router';
import { useTranslation } from 'react-i18next';
import {
  useConnectivity,
  useOfflineReviews,
  useOfflineSnapshotRefresh,
  useOfflineSync,
  useStoredSnapshot,
} from '../hooks/use-offline';
import { snapshotState } from '../lib/offline-sales';

// The offline line of the sale shell: the way into offline selling when the
// server is away, the sales still waiting to be sent, those the server
// refused, and those it holds for review. It also keeps the register's
// offline snapshot fresh and sends the queue while the server answers.
export function OfflineBanner({
  staffId,
  storeId,
  branchId,
  registerId,
  shiftId,
  menuOn,
  offline,
}: {
  staffId: string | null;
  storeId: string | null;
  branchId: string | null;
  registerId: string | null;
  shiftId: string | null;
  menuOn: boolean;
  offline: boolean;
}) {
  const { t } = useTranslation();
  const { online } = useConnectivity();
  useOfflineSnapshotRefresh(registerId, shiftId, menuOn);
  const stored = useStoredSnapshot();
  const sync = useOfflineSync(staffId, storeId);
  const reviews = useOfflineReviews(branchId, menuOn && online && !offline);
  const pending = sync.queue.sales.filter((sale) => sale.status === 'pending').length;
  const failed = sync.queue.sales.filter((sale) => sale.status === 'failed');
  const waiting = reviews.data?.filter((sale) => sale.status === 'needs_review').length ?? 0;
  const away = offline || !online;
  const state = snapshotState(stored.snapshot);
  const ownSnapshot =
    stored.snapshot?.data.register.id === registerId && stored.snapshot?.data.staff.id === staffId;

  if (!(away && menuOn) && pending === 0 && failed.length === 0 && waiting === 0) return null;

  return (
    <div className="offline-banner" role="status">
      {away && menuOn ? (
        state === 'ready' && ownSnapshot ? (
          <Link className="offline-banner-sell" to="/offline">
            {t('offlineSellLink')}
          </Link>
        ) : (
          <span>{t(`offlineState_${state}`)}</span>
        )
      ) : null}
      {pending > 0 ? (
        <span>
          {t('offlineQueued', { count: pending })}{' '}
          {sync.syncing ? (
            t('offlineSyncing')
          ) : (
            <button type="button" disabled={away} onClick={() => void sync.run()}>
              {t('offlineSyncNow')}
            </button>
          )}
        </span>
      ) : null}
      {failed.length > 0 ? (
        <span className="error">
          {t('offlineFailedCount', { count: failed.length })}{' '}
          <button type="button" disabled={sync.syncing || away} onClick={() => void sync.run(true)}>
            {t('offlineRetryFailed')}
          </button>
        </span>
      ) : null}
      {waiting > 0 ? (
        <Link to="/offline-review">{t('offlineReviewLink', { count: waiting })}</Link>
      ) : null}
    </div>
  );
}
