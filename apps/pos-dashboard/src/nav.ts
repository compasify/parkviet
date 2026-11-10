import { nav, settingsNav, usePermissions } from '@spree/dashboard-core'
import { Building2, Layers, Printer, Settings, SlidersHorizontal, Users } from 'lucide-react'
import { useLayoutEffect } from 'react'
import { usePosSession } from './hooks/use-pos-session'
import { type PosAccess, type PosPage, visibleNav } from './lib/pos-access'

const entries = [
  { key: 'branches', labelKey: 'adminResource_branches', path: '/branches', icon: Building2 },
  { key: 'registers', labelKey: 'adminResource_registers', path: '/registers', icon: Layers },
  { key: 'staff', labelKey: 'adminResource_memberships', path: '/staff', icon: Users },
  { key: 'products', labelKey: 'branchProductsTitle', path: '/products', icon: Layers },
  { key: 'labels', labelKey: 'labelFormatsTitle', path: '/label-formats', icon: Printer },
  { key: 'features', labelKey: 'branchFeaturesTitle', path: '/features', icon: SlidersHorizontal },
  { key: 'business-model', labelKey: 'businessModel.title', path: '/business-model', icon: Layers },
] satisfies { key: PosPage; labelKey: string; path: string; icon: typeof Building2 }[]
const settings = [
  {
    key: 'receipt-templates',
    labelKey: 'receiptTemplates.title',
    path: '/receipt-templates',
    icon: Printer,
  },
  { key: 'setup', labelKey: 'setup.title', path: '/setup', icon: Settings },
] satisfies { key: PosPage; labelKey: string; path: string; icon: typeof Settings }[]
settingsNav.addGroup({ key: 'pos', labelKey: 'posDashboard.title' })

// 6.0.3 nav predicates receive CanCan permissions, not permissionKeys or POS
// context. Close over a per-render snapshot, update through the registry so the
// shell subscribes; never mutate framework context or rely on a global token.
export function PosNavigation() {
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  useLayoutEffect(() => {
    const access: PosAccess = { permissionKeys, context: context.data }
    for (const entry of entries) {
      nav.remove(entry.key)
      nav.add({ ...entry, if: () => visibleNav(entry.key, access) })
    }
    for (const entry of settings) {
      settingsNav.remove(entry.key)
      if (visibleNav(entry.key, access)) settingsNav.add({ ...entry, group: 'pos' })
    }
    nav.remove('pos-settings')
    nav.add({
      key: 'pos-settings',
      labelKey: 'posDashboard.settings',
      path: '/settings',
      icon: Settings,
      section: 'bottom',
      if: () => settings.some((entry) => visibleNav(entry.key, access)),
    })
    return () => {
      for (const entry of entries) nav.remove(entry.key)
      for (const entry of settings) settingsNav.remove(entry.key)
      nav.remove('pos-settings')
    }
  }, [permissionKeys, context.data])
  return null
}
