import type { PosWorkspace } from './pos-context';
import { workspaceHasContent, workspaceIsSettled } from './workspace-content';

// The quick counter's payment keys: F1 takes the exact amount in cash, F2
// shows the VietQR, F3 opens the other methods.
export type QuickPayKind = 'cash' | 'vietqr' | 'other';

const PAY_KEYS: Readonly<Record<string, QuickPayKind>> = { F1: 'cash', F2: 'vietqr', F3: 'other' };

// The payment a key press asks for; a key held with a modifier is the
// browser's or the system's, not the counter's.
export function quickPayKey(
  event: Pick<KeyboardEvent, 'key' | 'ctrlKey' | 'metaKey' | 'altKey' | 'shiftKey'>,
): QuickPayKind | null {
  if (event.ctrlKey || event.metaKey || event.altKey || event.shiftKey) return null;
  return Object.hasOwn(PAY_KEYS, event.key) ? PAY_KEYS[event.key] : null;
}

// What the counter takes in cash, in whole VND: what the order still owes
// less a canteen sponsor's part (charged as the order completes), or the
// note the guest hands over when it is smaller (it pays its part). Nothing
// when the sponsor's part is all that is left.
export function quickCashAmount(
  remaining: bigint,
  sponsorDue: bigint,
  handed: bigint | null,
): bigint {
  const owed = remaining > sponsorDue ? remaining - sponsorDue : 0n;
  return handed !== null && handed < owed ? handed : owed;
}

// An order nobody started yet: open for editing, no payment, no call number,
// guest name or coach, nothing on it. A row of the open orders list has no lines,
// customer or note, so only an order's full detail can confirm it is blank.
export function blankOrder(workspace: PosWorkspace): boolean {
  if (workspace.payments || workspace.operational_status !== 'editing') return false;
  if (workspace.order_number != null || workspace.guest_name) return false;
  // Put on a coach: it counts for that coach's commission, so it is kept
  // for its guest, not taken for the next one.
  if (workspace.vehicle_visit_id) return false;
  if (workspace.line_items) return !workspaceHasContent(workspace);
  const total = Number(workspace.totals?.total ?? workspace.total ?? '0');
  return !(total > 0) && !workspace.customer && !workspace.note?.trim();
}

// The orders put aside at the counter: every open order of the register
// but the one on the ticket. Only a blank draft this device opened for its
// next guest stays out; anyone else's order, blank-looking or not, shows.
export function heldOrdersOf(
  rows: PosWorkspace[],
  currentId: string | null,
  ownDrafts: ReadonlySet<string>,
): PosWorkspace[] {
  return rows.filter(
    (row) =>
      row.id !== currentId &&
      !workspaceIsSettled(row) &&
      !(ownDrafts.has(row.id) && blankOrder(row)),
  );
}

// The drafts this device opened that may still be blank, to take for the
// next guest before another is created; the caller confirms each from its
// full detail. Another device's order is never taken: it would be claimed
// away from that device.
export function ownBlankCandidates(
  rows: PosWorkspace[],
  currentId: string | null,
  ownDrafts: ReadonlySet<string>,
): PosWorkspace[] {
  return rows.filter((row) => row.id !== currentId && ownDrafts.has(row.id) && blankOrder(row));
}

// The drafts this device opened for its next guests, per register, kept
// across reloads.
const OWN_DRAFTS_KEY = 'parkviet-pos:quick-own-drafts:';
const OWN_DRAFTS_MAX = 20;

export function ownDraftsOf(registerId: string): Set<string> {
  try {
    const parsed: unknown = JSON.parse(
      window.localStorage.getItem(OWN_DRAFTS_KEY + registerId) ?? '[]',
    );
    return new Set(
      Array.isArray(parsed) ? parsed.filter((id): id is string => typeof id === 'string') : [],
    );
  } catch {
    return new Set();
  }
}

export function saveOwnDrafts(registerId: string, ids: Iterable<string>) {
  const list = [...ids].slice(-OWN_DRAFTS_MAX);
  try {
    if (list.length === 0) window.localStorage.removeItem(OWN_DRAFTS_KEY + registerId);
    else window.localStorage.setItem(OWN_DRAFTS_KEY + registerId, JSON.stringify(list));
  } catch {
    // Storage full or blocked: the drafts are only remembered for this page.
  }
}
