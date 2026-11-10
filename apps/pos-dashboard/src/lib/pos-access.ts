import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries'
import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import type { PosContext } from '@parkviet/pos-shared/types/pos-context'

export type PosAccess = { permissionKeys: readonly string[]; context?: PosContext }
export type PosPage =
  | 'orders'
  | 'deliveries'
  | 'branches'
  | 'registers'
  | 'staff'
  | 'products'
  | 'labels'
  | 'features'
  | 'business-model'
  | 'receipt-templates'
  | 'setup'
export function canAdminister(access: PosAccess, write = false) {
  return (
    access.permissionKeys.includes('write_pos_topology') ||
    (!write && access.permissionKeys.includes('read_pos_topology'))
  )
}
export function canManageBranch(
  access: PosAccess,
  branchId: string | null = access.context?.selection.branch_id ?? null,
) {
  return (
    canAdminister(access, true) ||
    Boolean(
      branchId &&
        access.context?.selection.branch_id === branchId &&
        access.context.capabilities.includes('pos.topology.manage'),
    )
  )
}
// Operational screens act on the selected branch with the reader's membership
// there; the server checks the same capabilities on every request.
export const hasCapability = (access: PosAccess, capability: string) =>
  Boolean(access.context?.capabilities.includes(capability))
// Order history is read by any staff member of the branch.
export const canReadOrders = (access: PosAccess) => (access.context?.capabilities.length ?? 0) > 0
export function visibleNav(page: PosPage, access: PosAccess) {
  if (page === 'orders') return canReadOrders(access)
  // The list stays reachable with delivery switched off, so orders already
  // marked for delivery can still be handed over; only the entry is hidden.
  if (page === 'deliveries')
    return (
      canHandleDeliveries(access.context?.capabilities) &&
      access.context?.features?.delivery === true
    )
  if (page === 'labels')
    return (
      canAdminister(access) &&
      branchSettingVisible(
        access.context && {
          ...access.context,
          administration: { read: canAdminister(access), write: canAdminister(access, true) },
        },
        'label-formats',
      )
    )
  if (page === 'features' || page === 'business-model')
    return canAdminister(access) || canManageBranch(access)
  if (page === 'setup') return canAdminister(access, true)
  return canAdminister(access)
}
// Direct URLs. Setup is reachable by readers: the page shows ask-admin
// guidance instead of a wizard, while nav keeps it write-only. Label formats
// stay reachable with the measured-goods module off so existing formats can
// be seen, and deliveries with the delivery feature off.
export function routeAllowed(page: PosPage, access: PosAccess) {
  if (page === 'setup' || page === 'labels') return canAdminister(access)
  if (page === 'deliveries') return canHandleDeliveries(access.context?.capabilities)
  return visibleNav(page, access)
}
