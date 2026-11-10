import { type NavEntry, nav, settingsNav, usePermissions } from '@spree/dashboard-core'
import { ListChecks, Settings, Settings2, ShoppingCart, Wallet } from 'lucide-react'
import { useLayoutEffect } from 'react'
import { usePosSession } from './hooks/use-pos-session'
import { type PosAccess, type PosPage, visibleNav } from './lib/pos-access'

type Leaf = { key: PosPage; labelKey: string; path: string }
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
    ],
  },
  {
    key: 'money',
    labelKey: 'navMoney',
    icon: Wallet,
    children: [
      { key: 'funds', labelKey: 'fundsNav', path: '/funds' },
      { key: 'shifts', labelKey: 'shiftsNav', path: '/shifts' },
    ],
  },
  {
    key: 'configuration',
    labelKey: 'navConfiguration',
    icon: Settings2,
    children: [
      { key: 'branches', labelKey: 'adminResource_branches', path: '/branches' },
      { key: 'registers', labelKey: 'adminResource_registers', path: '/registers' },
      { key: 'staff', labelKey: 'adminResource_memberships', path: '/staff' },
      { key: 'products', labelKey: 'branchProductsTitle', path: '/products' },
      { key: 'labels', labelKey: 'labelFormatsTitle', path: '/label-formats' },
      { key: 'features', labelKey: 'branchFeaturesTitle', path: '/features' },
      { key: 'business-model', labelKey: 'businessModel.title', path: '/business-model' },
      {
        key: 'receipt-templates',
        labelKey: 'receiptTemplates.title',
        path: '/settings/receipt-templates',
      },
    ],
  },
]
const settings = [
  { key: 'setup', labelKey: 'setup.title', path: '/setup', icon: Settings },
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
      const children = group.children.filter((child) => visibleNav(child.key, access))
      if (children.length === 0) return
      nav.add({
        key: group.key,
        labelKey: group.labelKey,
        icon: group.icon,
        path: children[0].path,
        position: 200 + index * 100,
        children: children.map((child, order) => ({ ...child, position: order })),
      })
    })
    for (const entry of settings) {
      settingsNav.remove(entry.key)
      if (visibleNav(entry.key, access)) settingsNav.add({ ...entry, group: 'pos' })
    }
    nav.add({
      key: 'pos-settings',
      labelKey: 'posDashboard.settings',
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
