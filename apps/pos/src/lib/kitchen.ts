import type { PosLineItem, PosWorkspace } from './pos-context';

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
