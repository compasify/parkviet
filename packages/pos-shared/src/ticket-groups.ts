// The table ticket of the table-service selling screen: an order's lines in
// groups, by kitchen send, by course or by seat, and what the kitchen does
// with each line. Pure: the screen draws what these return.

import type {
  KitchenLineState,
  PosKitchenSend,
  PosLineItem,
  PosWorkspace,
} from './types/pos-context';

export const TICKET_GROUP_MODES = ['round', 'course', 'seat'] as const;
export type TicketGroupMode = (typeof TICKET_GROUP_MODES)[number];

// What a line's tag says: not sent yet, held for its course's fire, being
// made, out of the kitchen, sent and not started yet (or its state unknown),
// or a line that never goes to the kitchen.
export type TicketLineTag = 'new' | 'held' | 'cooking' | 'done' | 'sent' | 'none';

export type TicketGroupKind = 'new' | 'held' | 'round' | 'course' | 'seat' | 'shared' | 'other';

export type TicketGroup = {
  key: string;
  kind: TicketGroupKind;
  lines: PosLineItem[];
  // Units on the group's lines.
  quantity: number;
  // `round`: the send's sequence (null for sent lines of an older server)
  // and the send itself when the order lists it. `course`: the first send
  // that carried one of its dishes.
  sequence?: number | null;
  send?: PosKitchenSend | null;
  // `course`: the course (null: dishes sent without one) and how far it got.
  course?: number | null;
  courseStatus?: 'held' | 'fired' | 'done';
  // `seat` and `shared`: the seat (null for the table) and what its lines cost.
  seat?: number | null;
  amount?: number;
};

type Workspace = Pick<PosWorkspace, 'line_items' | 'kitchen_sends'>;

function amountOf(value: unknown): number {
  const parsed = Number(value ?? 0);
  return Number.isFinite(parsed) ? parsed : 0;
}

// Only menu lines go to the kitchen.
const kitchenLine = (line: PosLineItem) => line.kind === 'menu';
const sentOf = (line: PosLineItem) => amountOf(line.kitchen_sent_quantity);
const held = (line: PosLineItem) => line.course_status === 'held';

// A dish the kitchen has not heard of and that goes with the next send.
export function isNewTicketLine(line: PosLineItem): boolean {
  return kitchenLine(line) && sentOf(line) <= 0 && !held(line);
}

// What a line costs on the bill, its own discounts taken off.
export function ticketLineAmount(line: PosLineItem): number {
  return amountOf(line.item_net_amount ?? line.net_amount ?? line.amount);
}

const OUT_STATES: KitchenLineState[] = ['ready', 'served'];

// The least advanced part of a sent line wins: one dish cooking makes the
// line cooking, one not started yet makes it sent.
export function ticketLineTag(line: PosLineItem): TicketLineTag {
  if (!kitchenLine(line)) return 'none';
  if (sentOf(line) <= 0) return held(line) ? 'held' : 'new';
  const status = line.kitchen_status;
  if (!status) return 'sent';
  const count = (states: KitchenLineState[]) =>
    states.reduce((sum, state) => sum + amountOf(status[state]), 0);
  if (count(['new']) > 0) return 'sent';
  if (count(['preparing']) > 0) return 'cooking';
  return count(OUT_STATES) > 0 ? 'done' : 'sent';
}

// Units a kitchen send would take now: the server's count per line, else
// what a menu line not held has above its sent part.
export function pendingKitchenUnits(workspace: Workspace | null | undefined): number {
  return (workspace?.line_items ?? []).reduce((sum, line) => {
    if (line.pending_kitchen_quantity !== undefined)
      return sum + Math.max(0, amountOf(line.pending_kitchen_quantity));
    if (!kitchenLine(line) || held(line)) return sum;
    return sum + Math.max(0, line.quantity - sentOf(line));
  }, 0);
}

function group(
  key: string,
  kind: TicketGroupKind,
  lines: PosLineItem[],
  extra: Partial<TicketGroup> = {},
): TicketGroup {
  return {
    key,
    kind,
    lines,
    quantity: lines.reduce((sum, line) => sum + line.quantity, 0),
    ...extra,
  };
}

// Lines by a key, the keys sorted; a null key comes last.
function bucket<K extends number>(
  lines: PosLineItem[],
  keyOf: (line: PosLineItem) => K | null,
  direction: 1 | -1,
): Array<[K | null, PosLineItem[]]> {
  const buckets = new Map<K | null, PosLineItem[]>();
  for (const line of lines) {
    const key = keyOf(line);
    buckets.set(key, [...(buckets.get(key) ?? []), line]);
  }
  return [...buckets.entries()].sort(([left], [right]) => {
    if (left === null) return right === null ? 0 : 1;
    if (right === null) return -1;
    return (left - right) * direction;
  });
}

const sequenceOf = (line: PosLineItem) =>
  typeof line.kitchen_send_sequence === 'number' ? line.kitchen_send_sequence : null;

function sendOf(workspace: Workspace, sequence: number | null): PosKitchenSend | null {
  if (sequence === null) return null;
  return (workspace.kitchen_sends ?? []).find((send) => send.sequence === sequence) ?? null;
}

function courseStatusOf(lines: PosLineItem[]): 'held' | 'fired' | 'done' {
  if (lines.some(held)) return 'held';
  return lines.every((line) => ticketLineTag(line) === 'done') ? 'done' : 'fired';
}

// An order's lines in the groups of a mode. Groups without lines are left
// out; a line voided to nothing is not drawn.
//
// - `round`: dishes not sent yet first, then dishes held for their course,
//   then every send, newest first; lines that never go to the kitchen last.
// - `course`: dishes not sent yet first, then each course in order (held,
//   called or out), dishes sent without a course after them.
// - `seat`: each seat in order with what it costs, the table's shared
//   lines last.
export function groupTicketLines(
  workspace: Workspace | null | undefined,
  mode: TicketGroupMode,
): TicketGroup[] {
  if (!workspace) return [];
  const lines = (workspace.line_items ?? []).filter((line) => line.quantity > 0);
  if (mode === 'seat')
    return bucket(lines, (line) => line.seat ?? null, 1).map(([seat, rows]) =>
      group(seat === null ? 'shared' : `seat:${seat}`, seat === null ? 'shared' : 'seat', rows, {
        seat,
        amount: rows.reduce((sum, line) => sum + ticketLineAmount(line), 0),
      }),
    );

  const fresh = lines.filter(isNewTicketLine);
  const groups: TicketGroup[] = fresh.length ? [group('new', 'new', fresh)] : [];
  const kitchen = lines.filter((line) => kitchenLine(line) && !isNewTicketLine(line));
  if (mode === 'round') {
    const waiting = kitchen.filter((line) => sentOf(line) <= 0);
    if (waiting.length) groups.push(group('held', 'held', waiting));
    for (const [sequence, rows] of bucket(
      kitchen.filter((line) => sentOf(line) > 0),
      sequenceOf,
      -1,
    ))
      groups.push(
        group(`round:${sequence ?? 'sent'}`, 'round', rows, {
          sequence,
          send: sendOf(workspace, sequence),
        }),
      );
  } else {
    for (const [course, rows] of bucket(kitchen, (line) => line.course ?? null, 1)) {
      const first = rows
        .map(sequenceOf)
        .filter((value): value is number => value !== null)
        .sort((left, right) => left - right)[0];
      groups.push(
        group(`course:${course ?? 'none'}`, 'course', rows, {
          course,
          courseStatus: courseStatusOf(rows),
          sequence: first ?? null,
          send: sendOf(workspace, first ?? null),
        }),
      );
    }
  }
  const other = lines.filter((line) => !kitchenLine(line));
  if (other.length) groups.push(group('other', 'other', other));
  return groups;
}
