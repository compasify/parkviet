import type { PosWorkspace } from './pos-context';

// A tab is blank when the cashier has entered nothing yet: closing it loses no work.
export function workspaceHasContent(workspace: PosWorkspace): boolean {
  return Boolean(
    workspace.payments ||
      (workspace.line_items?.length ?? 0) > 0 ||
      workspace.customer ||
      workspace.note?.trim() ||
      workspace.discount ||
      workspace.coupon,
  );
}

// Finished or canceled invoices have nothing left to lose; closing only hides them.
export function workspaceIsSettled(workspace: Pick<PosWorkspace, 'operational_status'>): boolean {
  return (
    workspace.operational_status === 'canceled' || workspace.operational_status === 'completed'
  );
}
