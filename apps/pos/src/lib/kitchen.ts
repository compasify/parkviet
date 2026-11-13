import type { KitchenLineState, PosLineItem, PosWorkspace } from './pos-context';

export function kitchenSent(line: PosLineItem): number {
  const sent = Number(line.kitchen_sent_quantity ?? 0);
  return Number.isFinite(sent) ? sent : 0;
}

// Menu units the kitchen has not been told about yet.
export function unsentKitchenQuantity(workspace: PosWorkspace): number {
  return (workspace.line_items ?? [])
    .filter((line) => line.kind === 'menu')
    .reduce((sum, line) => sum + Math.max(0, line.quantity - kitchenSent(line)), 0);
}

const KITCHEN_STATES: KitchenLineState[] = ['new', 'preparing', 'ready', 'served'];

// How much of a table line is new, cooking, ready and served, in that order,
// leaving out the states it has none of.
export function kitchenStates(line: PosLineItem): { state: KitchenLineState; count: number }[] {
  return KITCHEN_STATES.map((state) => ({
    state,
    count: Number(line.kitchen_status?.[state] ?? 0),
  })).filter((row) => Number.isFinite(row.count) && row.count > 0);
}

// Units the kitchen got from one send: the items of its fire tickets, read
// from the send's answer; null when the answer carries no tickets.
export function sentUnits(meta: unknown): number | null {
  const tickets = (meta as { tickets?: unknown } | null | undefined)?.tickets;
  if (!Array.isArray(tickets)) return null;
  let units = 0;
  for (const ticket of tickets) {
    const row = (ticket ?? {}) as { kind?: unknown; items?: unknown };
    if (row.kind === 'void' || !Array.isArray(row.items)) continue;
    for (const item of row.items) {
      const quantity = Number((item as { quantity?: unknown } | null)?.quantity);
      if (Number.isFinite(quantity) && quantity > 0) units += quantity;
    }
  }
  return units;
}
