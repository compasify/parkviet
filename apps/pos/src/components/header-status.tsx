import { useTranslation } from 'react-i18next';
import { useRealtimeStatus } from '../hooks/use-branch-events';
import { PosIcon } from './pos-icon';

type Health = 'live' | 'connecting' | 'polling' | 'offline';

const HEALTH_LABELS: Record<Health, { short: string; long: string }> = {
  live: { short: 'statusLive', long: 'statusLiveHint' },
  connecting: { short: 'statusConnecting', long: 'statusConnectingHint' },
  polling: { short: 'statusPolling', long: 'statusPollingHint' },
  offline: { short: 'statusOffline', long: 'connectionOffline' },
};

// One badge for the counter's link to the server: whether it can reach the
// API at all, and whether changes from other screens arrive live or only on
// the periodic reload.
export function ConnectionBadge({ offline, loading }: { offline: boolean; loading: boolean }) {
  const { t } = useTranslation();
  const realtime = useRealtimeStatus();
  const health: Health = offline
    ? 'offline'
    : loading || realtime === 'connecting'
      ? 'connecting'
      : realtime === 'offline'
        ? 'polling'
        : 'live';
  const label = HEALTH_LABELS[health];
  return (
    <span
      className="header-badge realtime-status"
      data-status={realtime}
      data-health={health}
      role="status"
      title={t(label.long)}
    >
      <span className="header-badge-dot" aria-hidden />
      <span className="header-badge-text">{t(label.short)}</span>
      <span className="visually-hidden">{t(label.long)}</span>
    </span>
  );
}

export function ShiftBadge({ open }: { open: boolean }) {
  const { t } = useTranslation();
  return (
    <span
      className="header-badge shift-badge"
      data-open={open}
      title={t(open ? 'shiftOpenHint' : 'shiftNotOpen')}
    >
      <PosIcon name="clock" />
      <span className="header-badge-text">
        {t(open ? 'shiftOpenCompact' : 'shiftClosedCompact')}
      </span>
    </span>
  );
}
