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
