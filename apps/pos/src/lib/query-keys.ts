import type { PosSelection } from './pos-context';

export function posContextKey(generation: number, selection: Partial<PosSelection> = {}) {
  return [
    'pos',
    'context',
    generation,
    selection.branchId ?? null,
    selection.registerId ?? null,
  ] as const;
}

// The live floor of a branch (`GET /pos/resource_board`).
export function resourceBoardKey(generation: number, branchId?: string | null) {
  return branchId === undefined
    ? (['pos', 'resource-board', generation] as const)
    : (['pos', 'resource-board', generation, branchId] as const);
}

export function posWorkspacesKey(generation: number, storeId: string | null) {
  return ['pos', 'workspaces', generation, storeId] as const;
}
