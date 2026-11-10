import { canRemindDebt } from '@parkviet/pos-shared/debt-reminder'
import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries'
import { navVisible } from '@parkviet/pos-shared/module-registry'
import { contextFeature } from '@parkviet/pos-shared/pos-features'
import { canReadReceivables } from '@parkviet/pos-shared/receivables'
import { canMoveCash, canReconcileCash } from '@parkviet/pos-shared/shifts'
import { canOpenInventory } from '@parkviet/pos-shared/traceability'
import type { PosContext } from '@parkviet/pos-shared/types/pos-context'

export type PosAccess = { permissionKeys: readonly string[]; context?: PosContext }
export type PosPage =
  | 'orders'
  | 'deliveries'
  | 'funds'
  | 'funds-attention'
  | 'shifts'
  | 'late-cash'
  | 'receivables'
  | 'credit-accounts'
  | 'credit-approvals'
  | 'inventory'
  | 'reports'
  | 'branches'
  | 'branch'
  | 'registers'
  | 'staff'
  | 'products'
  | 'labels'
  | 'features'
  | 'business-model'
  | 'branch-payments'
  | 'branch-printing'
  | 'payment-methods'
  | 'units'
  | 'staff-roles'
  | 'receipt-templates'
  | 'setup'
  | 'store-model'
  | 'devices'
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
// The received-funds ledger is read by collectors and resolvers; only
// resolvers see the attention view and act on payouts.
export const canReadFunds = (access: PosAccess) =>
  hasCapability(access, 'pos.payment.resolve') || hasCapability(access, 'pos.payment.collect')
// Shift management: closing shifts left open needs recovery rights, drawer
// requests are confirmed by another cash mover or an approver, and approvers
// grant variance approvals.
export const canRecoverShifts = (access: PosAccess) => hasCapability(access, 'pos.topology.recover')
export const canConfirmCash = (access: PosAccess) =>
  canMoveCash(access.context?.capabilities) || hasCapability(access, 'pos.approval.grant')
export const canApproveCloses = (access: PosAccess) => hasCapability(access, 'pos.approval.grant')
export const canManageShifts = (access: PosAccess) =>
  canRecoverShifts(access) || canConfirmCash(access) || canApproveCloses(access)
// Receivables are read by branch members; credit managers among them set
// credit terms, and approvers decide credit sales, returns and refunds.
export const canReadDebts = (access: PosAccess) => canReadReceivables(access.context?.capabilities)
export const canManageCredit = (access: PosAccess) =>
  canReadDebts(access) && hasCapability(access, 'pos.credit.manage')
// Reminders belong to credit sales: hidden while `credit` is off. Staff who
// see contacts unmasked may send them, as the server checks.
export const canSendReminders = (access: PosAccess) =>
  Boolean(access.context && contextFeature(access.context, 'credit')) &&
  canRemindDebt(access.context?.capabilities)
export const canApproveSales = (access: PosAccess) =>
  hasCapability(access, 'pos.approval.grant') &&
  (!hasCapability(access, 'pos.credit.manage') || canReadDebts(access))
// Traceable stock belongs to the traceability module; its entry stays while
// the store still has tracked SKUs. Approvers open it to decide adjustments.
export const canOpenStock = (access: PosAccess) => canOpenInventory(access.context?.capabilities)
// Any branch member reads reports (their own shifts unless they hold report access).
export const canReadReports = canReadOrders
export function visibleNav(page: PosPage, access: PosAccess) {
  if (page === 'receivables') return canReadDebts(access)
  if (page === 'credit-accounts') return canManageCredit(access)
  if (page === 'credit-approvals') return canApproveSales(access)
  if (page === 'inventory') return navVisible(access.context, 'inventory')
  if (page === 'reports') return canReadReports(access)
  if (page === 'orders') return canReadOrders(access)
  if (page === 'funds') return canReadFunds(access)
  if (page === 'funds-attention') return hasCapability(access, 'pos.payment.resolve')
  if (page === 'shifts') return canManageShifts(access)
  if (page === 'late-cash') return canReconcileCash(access.context?.capabilities)
  // The list stays reachable with delivery switched off, so orders already
  // marked for delivery can still be handed over; only the entry is hidden.
  if (page === 'deliveries')
    return (
      canHandleDeliveries(access.context?.capabilities) &&
      access.context?.features?.delivery === true
    )
  // Administrators reach a branch from the branch list; a branch manager
  // without store administration gets a direct entry to their own branch.
  if (page === 'branch') return !canAdminister(access) && canManageBranch(access)
  if (page === 'features' || page === 'business-model')
    return canAdminister(access) || canManageBranch(access)
  if (page === 'setup' || page === 'store-model') return canAdminister(access, true)
  if (page === 'devices')
    return canAdminister(access) || hasCapability(access, 'pos.device.manage') || canReadOrders(access)
  return canAdminister(access)
}
// Direct URLs. Setup is reachable by readers: the page shows ask-admin
// guidance instead of a wizard, while nav keeps it write-only. Deliveries
// stay reachable with the delivery feature off, and traceable stock with the
// traceability module off.
export function routeAllowed(page: PosPage, access: PosAccess) {
  if (page === 'setup') return canAdminister(access)
  if (page === 'branch') return canAdminister(access) || canManageBranch(access)
  if (page === 'deliveries') return canHandleDeliveries(access.context?.capabilities)
  if (page === 'inventory') return canOpenStock(access)
  return visibleNav(page, access)
}

// Tabs of one branch's page, in display order, with the page each one gates on.
export const BRANCH_TABS = [
  { key: 'overview', page: 'branch', path: '' },
  { key: 'registers', page: 'registers', path: '/registers' },
  { key: 'staff', page: 'staff', path: '/staff' },
  { key: 'products', page: 'products', path: '/products' },
  { key: 'features', page: 'features', path: '/features' },
  { key: 'payments', page: 'branch-payments', path: '/payments' },
  { key: 'printing', page: 'branch-printing', path: '/printing' },
] as const satisfies readonly { key: string; page: PosPage; path: string }[]
export type BranchTab = (typeof BRANCH_TABS)[number]['key']
// The tabs open to this reader at the selected branch.
export const branchTabs = (access: PosAccess) =>
  BRANCH_TABS.filter((tab) => routeAllowed(tab.page, access))
