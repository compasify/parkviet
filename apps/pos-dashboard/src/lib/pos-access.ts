import { canRemindDebt } from '@parkviet/pos-shared/debt-reminder'
import { canHandleDeliveries } from '@parkviet/pos-shared/deliveries'
import { branchSettingVisible, navVisible } from '@parkviet/pos-shared/module-registry'
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
// be seen, deliveries with the delivery feature off, and traceable stock
// with the traceability module off.
export function routeAllowed(page: PosPage, access: PosAccess) {
  if (page === 'setup' || page === 'labels') return canAdminister(access)
  if (page === 'deliveries') return canHandleDeliveries(access.context?.capabilities)
  if (page === 'inventory') return canOpenStock(access)
  return visibleNav(page, access)
}
