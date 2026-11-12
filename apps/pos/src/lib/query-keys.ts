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

// The server's quote of one room clock (`GET /pos/timed_sessions/:id/quote`).
export function timedSessionKey(generation: number, sessionId?: string | null) {
  return sessionId === undefined
    ? (['pos', 'timed-session', generation] as const)
    : (['pos', 'timed-session', generation, sessionId] as const);
}

// A branch's bookings of one day (`GET /pos/reservations`).
export function reservationsKey(generation: number, branchId: string | null, date: string) {
  return ['pos', 'reservations', generation, branchId, date] as const;
}

export function posWorkspacesKey(generation: number, storeId: string | null) {
  return ['pos', 'workspaces', generation, storeId] as const;
}
