import { isTableSurface, type PosTableSurface } from '@parkviet/pos-shared/pos-modules';
import type { BoardTable } from '@parkviet/pos-shared/tables';
import type { PosContext, PosWorkspace } from './pos-context';
import { conflictReason, describeFailure } from './request-failure';

// Table service at the counter: the table fields a workspace carries, which
// orders the selling page may show, the device's floor view and the wording
// of the server's table refusals. The floor itself is read with
// `@parkviet/pos-shared/tables`.

export type WorkspaceTable = { id: string; name: string; area_id: string | null };

export type WorkspaceServiceCharge = {
  rate: string | null;
  amount: string;
  waived: boolean;
  applies: boolean;
};

export type WorkspacePrebill = {
  id: string;
  sequence: number;
  status: 'current' | 'superseded' | 'canceled';
  // The order changed after this pre-bill.
  stale: boolean;
};

export type WorkspacePaymentRequest = { id: string; status: 'open' | 'done' | 'canceled' };

export type TableOrder = {
  table: WorkspaceTable | null;
  guestCount: number | null;
  label: string | null;
  serviceCharge: WorkspaceServiceCharge | null;
  prebill: WorkspacePrebill | null;
  paymentRequest: WorkspacePaymentRequest | null;
};

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

const text = (value: unknown) => (typeof value === 'string' && value ? value : null);

// The table fields of a workspace, read tolerantly: a counter order and a
// server without table service give nulls.
export function tableOrderOf(workspace: PosWorkspace | null | undefined): TableOrder {
  const source = (workspace ?? {}) as Record<string, unknown>;
  const resource = record(source.resource);
  const charge = record(source.service_charge);
  const prebill = record(source.prebill);
  const request = record(source.payment_request);
  const prebillStatus = prebill?.status;
  const requestStatus = request?.status;
  return {
    table:
      resource && text(resource.id)
        ? {
            id: resource.id as string,
            name: text(resource.name) ?? '',
            area_id: text(resource.area_id),
          }
        : null,
    guestCount: Number.isInteger(source.guest_count) ? (source.guest_count as number) : null,
    label: text(source.table_label),
    serviceCharge:
      charge && typeof charge.amount === 'string'
        ? {
            rate: text(charge.rate),
            amount: charge.amount,
            waived: charge.waived === true,
            applies: charge.applies === true,
          }
        : null,
    prebill:
      prebill &&
      text(prebill.id) &&
      (prebillStatus === 'current' ||
        prebillStatus === 'superseded' ||
        prebillStatus === 'canceled')
        ? {
            id: prebill.id as string,
            sequence: Number.isInteger(prebill.sequence) ? (prebill.sequence as number) : 1,
            status: prebillStatus,
            stale: prebill.stale === true,
          }
        : null,
    paymentRequest:
      request &&
      text(request.id) &&
      (requestStatus === 'open' || requestStatus === 'done' || requestStatus === 'canceled')
        ? { id: request.id as string, status: requestStatus }
        : null,
  };
}

export function isTableOrder(workspace: PosWorkspace | null | undefined): boolean {
  return tableOrderOf(workspace).table !== null;
}

// Whether an order belongs on the selling page of this branch and register.
// A table order is booked on the branch's table register, which may not be
// the one selected here, so the branch is enough for it.
export function inSelection(
  workspace: PosWorkspace,
  selection: { branchId: string | null; registerId: string | null },
): boolean {
  return (
    workspace.branch_id === selection.branchId &&
    (workspace.register_id === selection.registerId || isTableOrder(workspace))
  );
}

// Who may seat guests: people serving tables and cashiers.
export function canServeTables(context: PosContext | undefined): boolean {
  return Boolean(
    context?.capabilities.includes('pos.table.serve') ||
      context?.capabilities.includes('pos.shift.open'),
  );
}

// "Bàn 4 · B": the table and, beside another order there, the order's letter.
export function tableOrderName(table: string, label: string | null | undefined): string {
  return label ? `${table} · ${label}` : table;
}

// Tables a table order may move to: free and serving.
export function moveTargets(tables: BoardTable[], fromTableId: string | null): BoardTable[] {
  return tables.filter((row) => row.id !== fromTableId && row.state === 'available');
}

// Open orders another order may join, by table and letter.
export function mergeTargets(
  tables: BoardTable[],
  workspaceId: string,
): Array<{ id: string; name: string }> {
  return tables.flatMap((row) =>
    row.orders
      .filter((order) => order.id !== workspaceId)
      .map((order) => ({ id: order.id, name: tableOrderName(row.name, order.table_label) })),
  );
}

// The floor as tiles or as a plan is a choice of this device.
export const TABLE_SURFACE_KEY = 'parkviet-pos:table-surface';

export function savedTableSurface(): PosTableSurface | null {
  try {
    const saved = window.localStorage.getItem(TABLE_SURFACE_KEY);
    return isTableSurface(saved) ? saved : null;
  } catch {
    return null;
  }
}

export function saveTableSurface(surface: PosTableSurface) {
  try {
    window.localStorage.setItem(TABLE_SURFACE_KEY, surface);
  } catch {
    // A preference only: the profile's surface shows next time.
  }
}

// Refusals of the table commands that have their own wording; anything else
// is a workspace refusal.
export const TABLE_FAILURE_REASONS = [
  'table_occupied',
  'table_unavailable',
  'table_archived',
  'table_register_missing',
  'no_open_shift',
  'guest_count_invalid',
  'table_full',
  'table_in_use',
  'same_table',
  'same_order',
  'not_table_order',
  'discount_present',
  'traced_line',
  'split_lines_invalid',
  'split_all_lines',
  'workspace_closed',
  'prebill_missing',
  'manual_status_invalid',
  'payment_request_status_invalid',
] as const;

export function describeTableFailure(error: unknown, translate: (key: string) => string): string {
  const reason = conflictReason(error);
  if (reason && (TABLE_FAILURE_REASONS as readonly string[]).includes(reason))
    return translate(`tableFailure_${reason}`);
  return describeFailure(error, translate);
}

// A pre-bill printed again or taken back needs a manager's approval of this action.
export function approvalAction(error: unknown): string | null {
  if (conflictReason(error) !== 'approval_required') return null;
  const action = (error as { details?: { action?: unknown } }).details?.action;
  return typeof action === 'string' ? action : null;
}
