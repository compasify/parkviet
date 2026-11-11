import { kitchenSent } from './kitchen';
import type { PosBranch, PosLineItem, PosWorkspace } from './pos-context';
import { conflictReason } from './request-failure';
import { isTableOrder } from './tables';

// Several people working one table: anyone serving it adds items and edits
// the lines the kitchen has not heard about without holding the order, and
// takes back sent items only through a void with a reason.

// A void reason the branch did not list; it always needs a note.
export const VOID_OTHER = 'khac';
export const VOID_NOTE_MAX = 200;
export const DEFAULT_VOID_REASONS = ['khach_doi_y', 'het_mon', 'nhap_nham', 'lam_hong'];

// The reasons a branch voids sent items for, with "other" last.
export function voidReasons(branch: PosBranch | null | undefined): string[] {
  const listed = branch?.void_reasons ?? DEFAULT_VOID_REASONS;
  return [...listed.filter((code) => code !== VOID_OTHER), VOID_OTHER];
}

// Whether this page may add to the order and edit its unsent lines without
// the lease: a table order that is open and has no money recorded yet.
export function appendable(
  workspace: PosWorkspace | null | undefined,
  tablesOn: boolean,
  locked: boolean,
): boolean {
  return Boolean(
    workspace &&
      tablesOn &&
      !locked &&
      isTableOrder(workspace) &&
      !workspace.payments &&
      (workspace.operational_status === 'editing' || workspace.operational_status === 'parked'),
  );
}

// Fields a table addition carries; anything else (a lot, a serial, a price)
// is a counter sale's add and goes through the lease.
const APPEND_FIELDS = new Set(['modifiers', 'note', 'merge']);

export function addsByAppend(workspace: PosWorkspace, extra: Record<string, unknown>): boolean {
  return (
    isTableOrder(workspace) &&
    Object.entries(extra).every(([key, value]) => value === undefined || APPEND_FIELDS.has(key))
  );
}

// An unsent table line is changed by its own version, not the order's.
export function editsByVersion(workspace: PosWorkspace, line: PosLineItem | undefined): boolean {
  return Boolean(
    line &&
      isTableOrder(workspace) &&
      line.sale_line_id &&
      typeof line.row_version === 'number' &&
      kitchenSent(line) === 0,
  );
}

export function findLine(workspace: PosWorkspace, lineId: string): PosLineItem | undefined {
  return (workspace.line_items ?? []).find(
    (line) => line.id === lineId || line.sale_line_id === lineId,
  );
}

// Someone else changed the line first: reload it before trying again.
export const lineChanged = (error: unknown) => conflictReason(error) === 'line_changed';
// The kitchen has the line: the change must be a void.
export const lineSent = (error: unknown) => conflictReason(error) === 'line_sent';
