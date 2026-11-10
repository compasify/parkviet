import { Link } from '@tanstack/react-router';
import { type ReactNode, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { dashboardPages } from '../lib/dashboard-pages';
import type { PosContext } from '../lib/pos-context';
import { posDashboardUrl } from '../lib/pos-dashboard-url';
import { canReadReceivables } from '../lib/receivables';
import { canProcessReturns } from '../lib/returns';
import { PosIcon } from './pos-icon';

// The header account menu: the counter pages, the POS dashboard pages,
// devices and sign out.
//
// From the sale screen the pages open in a new browser tab. Leaving the sale
// page unmounts the open invoice tabs and gives up their edit lease, so coming
// back would mean claiming (or taking over) editing again in the middle of a
// payment.
export function UserMenu({
  name,
  data,
  branchId,
  registerId,
  isSale,
  busy,
  onCalibrate,
  onLogout,
}: {
  name: string | null | undefined;
  data: PosContext | undefined;
  branchId: string | null | undefined;
  registerId: string | null | undefined;
  isSale: boolean;
  busy: boolean;
  onCalibrate: () => void;
  onLogout: () => void;
}) {
  const { t } = useTranslation();
  const menu = useRef<HTMLDetailsElement>(null);
  const close = () => {
    if (menu.current) menu.current.open = false;
  };

  useEffect(() => {
    const close = () => {
      if (menu.current) menu.current.open = false;
    };
    const dismiss = (event: Event) => {
      if (event.target instanceof Node && !menu.current?.contains(event.target)) close();
    };
    const onEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && menu.current?.open) {
        close();
        menu.current.querySelector('summary')?.focus();
      }
    };
    document.addEventListener('pointerdown', dismiss);
    document.addEventListener('focusin', dismiss);
    document.addEventListener('keydown', onEscape);
    return () => {
      document.removeEventListener('pointerdown', dismiss);
      document.removeEventListener('focusin', dismiss);
      document.removeEventListener('keydown', onEscape);
    };
  }, []);

  const capabilities = data?.capabilities ?? [];
  const has = (capability: string) => capabilities.includes(capability);
  const newTab = isSale ? ({ target: '_blank', rel: 'noopener' } as const) : {};
  const item = { className: 'user-menu-item', onClick: close, ...newTab };
  const staffed = Boolean(data && capabilities.length > 0);
  const collect = canReadReceivables(capabilities) && has('pos.payment.collect');

  const groups: ReactNode[] = [];
  if (data) {
    groups.push(
      <MenuGroup key="counter" label={t('sellingArea')}>
        {canProcessReturns(capabilities) ? (
          <Link to="/returns" {...item}>
            {t('returnsNav')}
          </Link>
        ) : null}
        {staffed ? (
          <Link to="/receipts" {...item}>
            {t('receiptsTitle')}
          </Link>
        ) : null}
        {staffed ? (
          <Link to="/shifts" {...item}>
            {t('myShiftNav')}
          </Link>
        ) : null}
        {collect ? (
          <Link to="/collect" {...item}>
            {t('collectNav')}
          </Link>
        ) : null}
      </MenuGroup>,
    );
  }
  // Back office lives in the POS dashboard app. Its pages open in a new tab
  // from every page so the open invoices and this session stay as they are.
  const storeId = data?.store.id;
  const dashboard = dashboardPages(data, branchId).flatMap((page) => {
    const url = posDashboardUrl(storeId, page.path, branchId);
    return url ? [{ ...page, url }] : [];
  });
  if (dashboard.length > 0) {
    groups.push(
      <MenuGroup key="dashboard" label={t('menuDashboard')}>
        {dashboard.map((page) => (
          <a
            key={page.key}
            href={page.url}
            className="user-menu-item"
            onClick={close}
            target="_blank"
            rel="noopener"
          >
            {t(page.labelKey)}
          </a>
        ))}
      </MenuGroup>,
    );
  }
  if (staffed && registerId) {
    groups.push(
      <MenuGroup key="setup" label={t('menuSetup')}>
        <button
          type="button"
          className="user-menu-item"
          onClick={() => {
            close();
            onCalibrate();
          }}
        >
          {t('scannerCalibrationOpen')}
        </button>
      </MenuGroup>,
    );
  }

  return (
    <details className="user-menu" ref={menu}>
      <summary className="header-user" title={t('accountMenu')}>
        <PosIcon name="user" />
        <span className="header-user-name">{name}</span>
        <PosIcon name="chevron" />
      </summary>
      <div className="user-menu-popover">
        <p className="user-menu-account">
          <PosIcon name="user" />
          <b>{name}</b>
        </p>
        {groups}
        <div className="user-menu-group">
          <button
            type="button"
            className="user-menu-item user-menu-logout"
            onClick={() => {
              close();
              onLogout();
            }}
            disabled={busy}
          >
            <PosIcon name="lock" />
            {busy ? t('waiting') : t('logout')}
          </button>
        </div>
      </div>
    </details>
  );
}

function MenuGroup({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="user-menu-group">
      <p className="user-menu-label">{label}</p>
      {children}
    </div>
  );
}
