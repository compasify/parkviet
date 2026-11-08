import { Link } from '@tanstack/react-router';
import { type ReactNode, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { administrationAccess } from '../lib/pos-administration';
import type { PosContext } from '../lib/pos-context';
import { canReadReceivables } from '../lib/receivables';
import { canProcessReturns } from '../lib/returns';
import { navVisible } from '../modules/registry';
import { PosIcon } from './pos-icon';

// The header account menu: every POS page, devices and sign out.
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
  const canAccessFunds = has('pos.payment.resolve') || has('pos.payment.collect');
  const creditManage = has('pos.credit.manage');
  const approve = has('pos.approval.grant');
  const staffed = Boolean(data && capabilities.length > 0);
  // Stock tracking belongs to `retail.traceability`; it stays reachable with
  // the module off while the store still has tracked SKUs to receive.
  const inventory = navVisible(data, 'inventory');

  const groups: ReactNode[] = [];
  if (data) {
    groups.push(
      <MenuGroup key="sales" label={t('sellingArea')}>
        <Link to="/orders" {...item}>
          {t('ordersNav')}
        </Link>
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
      </MenuGroup>,
    );
  }
  if (canAccessFunds || canReadReceivables(capabilities) || approve) {
    groups.push(
      <MenuGroup key="money" label={t('menuMoney')}>
        {canAccessFunds ? (
          <>
            <Link to="/funds" {...item}>
              {t('fundsTitle')}
            </Link>
            <Link to="/payment-attention" {...item}>
              {t('fundsAttentionTitle')}
            </Link>
          </>
        ) : null}
        {canReadReceivables(capabilities) ? (
          <Link to="/receivables" {...item}>
            {t('receivablesTitle')}
          </Link>
        ) : null}
        {canReadReceivables(capabilities) && creditManage ? (
          <Link to="/credit-accounts" {...item}>
            {t('creditAccountsNav')}
          </Link>
        ) : null}
        {approve && (!creditManage || canReadReceivables(capabilities)) ? (
          <Link to="/credit-approvals" {...item}>
            {t('creditApprovalsNav')}
          </Link>
        ) : null}
      </MenuGroup>,
    );
  }
  if (staffed || inventory) {
    groups.push(
      <MenuGroup key="operations" label={t('menuOperations')}>
        {staffed ? (
          <>
            <Link to="/shifts" {...item}>
              {t('shiftsNav')}
            </Link>
            <Link to="/reports" {...item}>
              {t('reportsNav')}
            </Link>
          </>
        ) : null}
        {inventory ? (
          <Link to="/inventory" {...item}>
            {t('inventoryNav')}
          </Link>
        ) : null}
      </MenuGroup>,
    );
  }
  const canConfigure = administrationAccess(data).read;
  const branchSettings = !canConfigure && branchId && has('pos.topology.manage');
  if (canConfigure || branchSettings || (staffed && registerId)) {
    groups.push(
      <MenuGroup key="setup" label={t('menuSetup')}>
        {canConfigure ? (
          <Link to="/settings" {...item} className="user-menu-item header-settings">
            <PosIcon name="cog" />
            {t('settings')}
          </Link>
        ) : branchSettings && branchId ? (
          <Link
            to="/settings/branches/$branchId/features"
            params={{ branchId }}
            {...item}
            className="user-menu-item header-settings"
          >
            <PosIcon name="cog" />
            {t('branchFeaturesTitle')}
          </Link>
        ) : null}
        {staffed && registerId ? (
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
        ) : null}
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
