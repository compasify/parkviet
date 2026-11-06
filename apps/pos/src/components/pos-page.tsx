import { Link } from '@tanstack/react-router';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { administrationAccess } from '../lib/pos-administration';
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
  const { context } = usePosSelection();
  const capabilities = context.data?.capabilities ?? [];
  return (
    <div className="pos-page">
      <nav className="pos-page-nav" aria-label={t('pageNavigation')}>
        <Link to="/" activeOptions={{ exact: true }}>
          <PosIcon name="grid" />
          {t('sellingArea')}
        </Link>
        {administrationAccess(context.data).read ? (
          <Link to="/settings" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
            <PosIcon name="settings" />
            {t('settingsNav')}
          </Link>
        ) : null}
        {capabilities.includes('pos.payment.collect') ||
        capabilities.includes('pos.payment.resolve') ? (
          <Link to="/funds" activeProps={{ className: 'is-active', 'aria-current': 'page' }}>
            <PosIcon name="cash" />
            {t('fundsNav')}
          </Link>
        ) : null}
        {capabilities.includes('pos.payment.resolve') ? (
          <Link
            to="/payment-attention"
            activeProps={{ className: 'is-active', 'aria-current': 'page' }}
          >
            <PosIcon name="alert" />
            {t('attentionNav')}
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
