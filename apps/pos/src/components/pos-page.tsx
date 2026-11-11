import { RESERVATIONS_MODULE } from '@parkviet/pos-shared/reservations';
import { Link } from '@tanstack/react-router';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { useRealtimeStatus } from '../hooks/use-branch-events';
import { administrationAccess } from '../lib/pos-administration';
import { posDashboardUrl } from '../lib/pos-dashboard-url';
import { canReadReceivables } from '../lib/receivables';
import { canProcessReturns } from '../lib/returns';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';

export function PosPage({
  title,
  description,
  children,
}: {
  title: string;
  description: string;
  children: ReactNode;
}) {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const capabilities = context.data?.capabilities ?? [];
  // Administration is a separate app; it opens in a new tab (see UserMenu).
  const administrationUrl = administrationAccess(context.data).read
    ? posDashboardUrl(context.data?.store.id, '', selection.branchId)
    : null;
  return (
    <div className="pos-page">
      <nav className="pos-page-nav" aria-label={t('pageNavigation')}>
        <Link to="/" activeOptions={{ exact: true }}>
          <PosIcon name="grid" />
          {t('sellingArea')}
        </Link>
        {administrationUrl ? (
          <a href={administrationUrl} target="_blank" rel="noopener">
            <PosIcon name="settings" />
            {t('settingsNav')}
          </a>
        ) : null}
        {canProcessReturns(capabilities) ? (
          <Link to="/returns" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
            <PosIcon name="back" />
            {t('returnsNav')}
          </Link>
        ) : null}
        {capabilities.length > 0 ? (
          <>
            <Link to="/receipts" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
              <PosIcon name="list" />
              {t('receiptsTitle')}
            </Link>
            <Link to="/shifts" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
              <PosIcon name="cash" />
              {t('myShiftNav')}
            </Link>
          </>
        ) : null}
        {canReadReceivables(capabilities) && capabilities.includes('pos.payment.collect') ? (
          <Link to="/collect" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
            <PosIcon name="cash" />
            {t('collectNav')}
          </Link>
        ) : null}
        {context.data?.modules?.[RESERVATIONS_MODULE] === true && capabilities.length > 0 ? (
          <Link to="/reservations" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
            <PosIcon name="list" />
            {t('reservationsNav')}
          </Link>
        ) : null}
      </nav>
      <div className="page-heading">
        <div>
          <h1 id="pos-page-title" tabIndex={-1}>
            {title}
          </h1>
          <p>{description}</p>
        </div>
        <Link className="button-link" to="/">
          <PosIcon name="back" />
          {t('back')}
        </Link>
      </div>
      {children}
    </div>
  );
}

const REALTIME_LABELS = {
  connected: 'realtimeConnected',
  connecting: 'realtimeConnecting',
  offline: 'realtimeOffline',
} as const;

// Whether changes from other screens arrive live or only by polling.
export function RealtimeDot() {
  const { t } = useTranslation();
  const status = useRealtimeStatus();
  const label = t(REALTIME_LABELS[status]);
  return (
    <span
      className="realtime-status"
      data-status={status}
      role="img"
      aria-label={label}
      title={label}
    >
      <span className="connection-dot" />
    </span>
  );
}

export function PageState({
  title,
  description,
  kind = 'empty',
  children,
}: {
  title: string;
  description?: string;
  kind?: 'empty' | 'error' | 'loading' | 'success';
  children?: ReactNode;
}) {
  return (
    <div className={`page-state page-state--${kind}`} role={kind === 'error' ? 'alert' : 'status'}>
      <span className="page-state-icon">
        <PosIcon name={kind === 'error' ? 'alert' : kind === 'success' ? 'check' : 'box'} />
      </span>
      <strong>{title}</strong>
      {description ? <p>{description}</p> : null}
      {children}
    </div>
  );
}
