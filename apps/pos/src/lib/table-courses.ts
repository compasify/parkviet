import type { PosLineItem, PosWorkspace } from './pos-context';

// Where a table dish goes: its course, held back until the course is fired,
// its seat, and the buffet cover a free buffet dish is eaten on.
export type TablePlacement = {
  course?: number | null;
  seat?: number | null;
  hold?: boolean;
  buffetCoverLineId?: string | null;
};

export const DEFAULT_COURSE_LABELS: Record<number, string> = {
  1: 'Khai vị',
  2: 'Món chính',
  3: 'Tráng miệng',
};

// The append item's fields for a placement; nothing for an empty one.
export function placementFields(placement: TablePlacement | undefined): Record<string, unknown> {
  if (!placement) return {};
  return {
    ...(placement.course ? { course: placement.course } : {}),
    ...(placement.seat ? { seat: placement.seat } : {}),
    ...(placement.course && placement.hold ? { hold: true } : {}),
    ...(placement.buffetCoverLineId ? { buffet_cover_line_id: placement.buffetCoverLineId } : {}),
  };
}

export type HeldCourse = { course: number; lines: PosLineItem[] };

// The courses of an order still waiting for their fire, first course first.
export function heldCourses(
  workspace: Pick<PosWorkspace, 'line_items'> | null | undefined,
): HeldCourse[] {
  const held = new Map<number, PosLineItem[]>();
  for (const line of workspace?.line_items ?? []) {
    if (line.course_status !== 'held' || !line.course) continue;
    held.set(line.course, [...(held.get(line.course) ?? []), line]);
  }
  return [...held.entries()]
    .sort(([a], [b]) => a - b)
    .map(([course, lines]) => ({ course, lines }));
}

// The buffet tickets on an order (`cover` lines).
export function coverLines(
  workspace: Pick<PosWorkspace, 'line_items'> | null | undefined,
): PosLineItem[] {
  return (workspace?.line_items ?? []).filter((line) => line.kind === 'cover' && line.sale_line_id);
}

// The seats an order's dishes name, in order.
export function seatsOf(workspace: Pick<PosWorkspace, 'line_items'> | null | undefined): number[] {
  const seats = new Set<number>();
  for (const line of workspace?.line_items ?? []) if (line.seat) seats.add(line.seat);
  return [...seats].sort((a, b) => a - b);
}

// Dishes without a seat; a split by seat puts each on the seat picked for it.
export function sharedLines(
  workspace: Pick<PosWorkspace, 'line_items'> | null | undefined,
): PosLineItem[] {
  return (workspace?.line_items ?? []).filter((line) => line.sale_line_id && !line.seat);
}

// A split by seat needs dishes of two seats at least.
export function canSplitBySeat(
  workspace: Pick<PosWorkspace, 'line_items'> | null | undefined,
): boolean {
  return seatsOf(workspace).length >= 2;
}

export function courseName(course: number, labels: Record<number, string> = DEFAULT_COURSE_LABELS) {
  return labels[course] ?? `#${course}`;
}

// What the held deposits of the seated booking may still take off the bill.
export function depositToApply(
  workspace: Pick<PosWorkspace, 'reservation'> | null | undefined,
): number {
  return (workspace?.reservation?.deposits ?? [])
    .filter((row) => row.status === 'held')
    .reduce((sum, row) => sum + (Number(row.available) || 0), 0);
}
