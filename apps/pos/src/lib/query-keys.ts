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

export function posWorkspacesKey(generation: number, storeId: string | null) {
  return ['pos', 'workspaces', generation, storeId] as const;
}
