import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries';
import { navVisible } from '@parkviet/pos-shared/module-registry';
import { canReadReceivables } from '@parkviet/pos-shared/receivables';
import { canMoveCash, canReconcileCash } from '@parkviet/pos-shared/shifts';
import type { PosContext } from '@parkviet/pos-shared/types/pos-context';
import { administrationAccess } from './pos-administration';

// A back-office page of the POS dashboard, listed in the account menu.
export type DashboardPage = { key: string; labelKey: string; path: string };

// Back-office work lives in the POS dashboard. Each page is listed for the
// staff who could open it here before, so the menu does not promise a page
// the dashboard would refuse; the dashboard checks the capabilities again.
export function dashboardPages(
  data: PosContext | undefined,
  branchId: string | null | undefined,
): DashboardPage[] {
  if (!data) return [];
  const capabilities = data.capabilities ?? [];
  const has = (capability: string) => capabilities.includes(capability);
  const funds = has('pos.payment.resolve') || has('pos.payment.collect');
  const receivables = canReadReceivables(capabilities);
  const creditManage = has('pos.credit.manage');
  const approve = has('pos.approval.grant');
  const shifts =
    has('pos.topology.recover') ||
    canMoveCash(capabilities) ||
    approve ||
    canReconcileCash(capabilities);
  const pages: (DashboardPage | false)[] = [
    { key: 'orders', labelKey: 'ordersNav', path: 'orders' },
    data.features?.delivery === true &&
      canHandleDeliveries(capabilities) && {
        key: 'deliveries',
        labelKey: 'deliveriesNav',
        path: 'deliveries',
      },
    funds && { key: 'funds', labelKey: 'fundsTitle', path: 'funds' },
    funds && { key: 'attention', labelKey: 'fundsAttentionTitle', path: 'funds/attention' },
    shifts && { key: 'shifts', labelKey: 'shiftsManageNav', path: 'shifts' },
    receivables && { key: 'receivables', labelKey: 'receivablesTitle', path: 'receivables' },
    receivables &&
      creditManage && {
        key: 'credit-accounts',
        labelKey: 'creditAccountsNav',
        path: 'credit-accounts',
      },
    approve &&
      (!creditManage || receivables) && {
        key: 'credit-approvals',
        labelKey: 'creditApprovalsNav',
        path: 'credit-approvals',
      },
    navVisible(data, 'inventory') && {
      key: 'inventory',
      labelKey: 'inventoryNav',
      path: 'inventory',
    },
    capabilities.length > 0 && { key: 'reports', labelKey: 'reportsNav', path: 'reports' },
    administrationAccess(data).read
      ? { key: 'settings', labelKey: 'settings', path: '' }
      : Boolean(branchId) &&
        has('pos.topology.manage') && {
          key: 'branch-features',
          labelKey: 'branchFeaturesTitle',
          path: 'features',
        },
  ];
  return pages.filter((page): page is DashboardPage => page !== false);
}
