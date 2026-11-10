import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import type { PosContext } from '@parkviet/pos-shared/types/pos-context'

export type PosAccess = { permissionKeys: readonly string[]; context?: PosContext }
export type PosPage =
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
export function visibleNav(page: PosPage, access: PosAccess) {
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
