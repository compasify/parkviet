import { type NavEntry, nav, settingsNav, usePermissions } from '@spree/dashboard-core'
import {
  ChartColumn,
  HandCoins,
  ListChecks,
  Package,
  ReceiptText,
  Server,
  Settings,
  Settings2,
  ShoppingCart,
  Store,
  UtensilsCrossed,
  Wallet,
} from 'lucide-react'
import { useLayoutEffect } from 'react'
import { usePosSession } from './hooks/use-pos-session'
import { type PosAccess, type PosPage, visibleNav } from './lib/pos-access'

// A path may depend on the access snapshot (a manager's own branch).
type Leaf = { key: PosPage; labelKey: string; path: string | ((access: PosAccess) => string) }
// 6.0.3 renders no group headings, so each sidebar group is a parent entry
// whose children are the group's screens; a parent without its own subject
// opens its first visible child and disappears when none is visible.
const groups: { key: string; labelKey: string; icon: NavEntry['icon']; children: Leaf[] }[] = [
  {
    key: 'sales',
    labelKey: 'navSales',
    icon: ShoppingCart,
    children: [
      { key: 'orders', labelKey: 'ordersTitle', path: '/orders' },
      { key: 'deliveries', labelKey: 'deliveriesTitle', path: '/deliveries' },
      { key: 'einvoices', labelKey: 'einvoices.title', path: '/einvoices' },
    ],
  },
  {
    key: 'money',
    labelKey: 'navMoney',
    icon: Wallet,
    children: [
      { key: 'funds', labelKey: 'fundsNav', path: '/funds' },
      { key: 'shifts', labelKey: 'shiftsNav', path: '/shifts' },
      {
        key: 'platform-settlement',
        labelKey: 'platformSettlement.title',
        path: '/platform-settlement',
      },
    ],
  },
  {
    key: 'debts',
    labelKey: 'navDebts',
    icon: HandCoins,
    children: [
      { key: 'receivables', labelKey: 'receivablesTitle', path: '/receivables' },
      { key: 'credit-accounts', labelKey: 'creditAccountsNav', path: '/credit-accounts' },
      { key: 'credit-approvals', labelKey: 'creditApprovalsNav', path: '/credit-approvals' },
    ],
  },
  {
    key: 'food-menu',
    labelKey: 'navMenu',
    icon: UtensilsCrossed,
    children: [{ key: 'menu', labelKey: 'menuAdmin.title', path: '/menu' }],
  },
  {
    key: 'stock',
    labelKey: 'navStock',
    icon: Package,
    children: [
      { key: 'inventory', labelKey: 'inventoryTitle', path: '/inventory' },
      { key: 'stock-alerts', labelKey: 'stockAlerts.title', path: '/stock-alerts' },
    ],
  },
  {
    key: 'reporting',
    labelKey: 'navReports',
    icon: ChartColumn,
    children: [{ key: 'reports', labelKey: 'reportsNav', path: '/reports' }],
  },
  {
    key: 'configuration',
    labelKey: 'navConfiguration',
    icon: Settings2,
    children: [
      { key: 'branches', labelKey: 'adminResource_branches', path: '/branches' },
      {
        key: 'branch',
        labelKey: 'adminResource_branches',
        path: (access) => `/branches/${access.context?.selection.branch_id ?? ''}`,
      },
      {
        key: 'receipt-templates',
        labelKey: 'receiptTemplates.title',
        path: '/settings/receipt-templates',
      },
      { key: 'payment-methods', labelKey: 'paymentMethods.title', path: '/payment-methods' },
      { key: 'units', labelKey: 'units.title', path: '/units' },
      { key: 'staff-roles', labelKey: 'staffRoles.title', path: '/staff-roles' },
      { key: 'labels', labelKey: 'labelFormatsTitle', path: '/scale-labels' },
      { key: 'devices', labelKey: 'devices.title', path: '/devices' },
    ],
  },
]
const settings = [
  { key: 'setup', labelKey: 'setup.title', path: '/setup', icon: Settings },
  {
    key: 'store-model',
    labelKey: 'businessModel.storeTitle',
    path: '/settings/business-model',
    icon: Store,
  },
  {
    key: 'einvoice-settings',
    labelKey: 'einvoiceSettings.title',
    path: '/settings/einvoice',
    icon: ReceiptText,
  },
  { key: 'system', labelKey: 'systemStatus.title', path: '/settings/system', icon: Server },
] satisfies { key: PosPage; labelKey: string; path: string; icon: typeof Settings }[]
settingsNav.addGroup({ key: 'pos', labelKey: 'posDashboard.title' })
const keys = ['home', ...groups.map((group) => group.key), 'pos-settings']

// 6.0.3 nav predicates receive CanCan permissions, not permissionKeys or POS
// context, and children have no `if` at all. Re-register from a per-render
// snapshot so the shell subscribes; never mutate framework context or rely on
// a global token.
export function PosNavigation() {
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  useLayoutEffect(() => {
    const access: PosAccess = { permissionKeys, context: context.data }
    for (const key of keys) nav.remove(key)
    nav.add({
      key: 'home',
      labelKey: 'attention.title',
      path: '/',
      icon: ListChecks,
      position: 100,
    })
    groups.forEach((group, index) => {
      const children = group.children
        .filter((child) => visibleNav(child.key, access))
        .map((child, order) => ({
          ...child,
          path: typeof child.path === 'function' ? child.path(access) : child.path,
          position: order,
        }))
      if (children.length === 0) return
      nav.add({
        key: group.key,
        labelKey: group.labelKey,
        icon: group.icon,
        path: children[0].path,
        position: 200 + index * 100,
        children,
      })
    })
    for (const entry of settings) {
      settingsNav.remove(entry.key)
      if (visibleNav(entry.key, access)) settingsNav.add({ ...entry, group: 'pos' })
    }
    nav.add({
      key: 'pos-settings',
      labelKey: 'storeSettings',
      path: '/settings',
      icon: Settings,
      section: 'bottom',
      if: () => settings.some((entry) => visibleNav(entry.key, access)),
    })
    return () => {
      for (const key of keys) nav.remove(key)
      for (const entry of settings) settingsNav.remove(entry.key)
    }
  }, [permissionKeys, context.data])
  return null
}
