import type { ChecklistItem } from '@parkviet/pos-shared/shifts';
import { readLayout, writeLayout } from './workspace-storage';

// Shift types, drawer and reconciliation rules and the report rules are
// shared with the POS administration app; counter navigation stays here.
export * from '@parkviet/pos-shared/reports';
export * from '@parkviet/pos-shared/shifts';

// Where a checklist item sends the cashier: the sale screen with that draft
// as the active tab, the received-funds item (in the POS dashboard), the
// return, or this page.
export type ChecklistTarget =
  | { to: '/'; workspaceId: string }
  | { to: 'dashboard'; path: 'funds'; search: { fundsId: string } }
  | { to: '/returns'; search: { returnId: string } }
  | { to: '/shifts' };

export function checklistTarget(item: ChecklistItem): ChecklistTarget | null {
  if (item.type === 'liability_payout' && item.funds_id)
    return { to: 'dashboard', path: 'funds', search: { fundsId: item.funds_id } };
  if (item.type === 'refund_request' && item.return_id)
    return { to: '/returns', search: { returnId: item.return_id } };
  if (item.type === 'cash_movement_request') return { to: '/shifts' };
  if ((item.type === 'tender_attempt' || item.type === 'workspace_money') && item.workspace_id)
    return { to: '/', workspaceId: item.workspace_id };
  return null;
}

// The table an open order on the shift is served at ("Bàn 4 · B"), so the
// close dialog says which table still holds it. Null for a counter order or a
// server that does not send it.
export function checklistTableName(item: ChecklistItem): string | null {
  const table = (item as { table?: unknown }).table;
  if (typeof table !== 'object' || table === null) return null;
  const { name, label } = table as { name?: unknown; label?: unknown };
  if (typeof name !== 'string' || !name) return null;
  return typeof label === 'string' && label ? `${name} · ${label}` : name;
}

// Makes a draft the active tab the next time the sale screen opens (the tabs
// restore the remembered view of this branch and register).
export function activateWorkspaceTab(
  scope: { staffId: string; storeId: string; branchId: string; registerId: string | null },
  workspaceId: string,
) {
  const current = readLayout(scope.staffId, scope.storeId);
  const sameContext =
    current?.branchId === scope.branchId && current.registerId === scope.registerId;
  writeLayout({
    staffId: scope.staffId,
    storeId: scope.storeId,
    savedAt: Date.now(),
    branchId: scope.branchId,
    registerId: scope.registerId,
    openWorkspaceIds: [
      workspaceId,
      ...(sameContext ? current.openWorkspaceIds.filter((id) => id !== workspaceId) : []),
    ],
    closedWorkspaceIds: sameContext
      ? (current.closedWorkspaceIds ?? []).filter((id) => id !== workspaceId)
      : [],
    activeWorkspaceId: workspaceId,
    workspacePage: 1,
    tabNumbers: sameContext ? current.tabNumbers : undefined,
  });
}
