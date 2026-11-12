import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { resourceBoardKey, timedSessionKey } from '../lib/query-keys';
import { TIMED_QUOTE_POLL_MS } from '../lib/timed-clock';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// The server's quote of one clock, refreshed every minute while it runs.
export type TimedQuote = {
  played_minutes: number;
  billed_minutes: number;
  amount: string;
  final: boolean;
};

export type TimedSessionView = {
  id: string;
  status: string;
  started_at: string;
  stopped_at: string | null;
  quote: TimedQuote | null;
};

function readSession(value: unknown): TimedSessionView | null {
  const source = (value ?? {}) as Record<string, unknown>;
  if (typeof source.id !== 'string') return null;
  const quote = (source.quote ?? null) as Record<string, unknown> | null;
  return {
    id: source.id,
    status: typeof source.status === 'string' ? source.status : 'running',
    started_at: typeof source.started_at === 'string' ? source.started_at : '',
    stopped_at: typeof source.stopped_at === 'string' ? source.stopped_at : null,
    quote:
      quote && typeof quote.amount === 'string'
        ? {
            played_minutes: Number(quote.played_minutes) || 0,
            billed_minutes: Number(quote.billed_minutes) || 0,
            amount: quote.amount,
            final: quote.final === true,
          }
        : null,
  };
}

export function useTimedQuote(sessionId: string | null, running: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: timedSessionKey(snapshot.generation, sessionId),
    enabled: snapshot.status === 'authenticated' && Boolean(sessionId),
    refetchInterval: running ? TIMED_QUOTE_POLL_MS : false,
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown }>(
          'GET',
          `/pos/timed_sessions/${sessionId}/quote`,
        );
        return readSession(result.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

// Stop and move run on the room, without the order's lease: the server
// takes the time and prices it.
export function useTimedCommands() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = () =>
    Promise.all([
      queryClient.invalidateQueries({ queryKey: resourceBoardKey(snapshot.generation) }),
      queryClient.invalidateQueries({ queryKey: timedSessionKey(snapshot.generation) }),
      // The room's order carries the clock on its time line, priced once it stops.
      queryClient.invalidateQueries({ queryKey: ['pos', 'workspaces', snapshot.generation] }),
    ]);
  async function post(path: string, body: Record<string, unknown> = {}) {
    const key = crypto.randomUUID();
    try {
      return await session.request<{ data: unknown }>('POST', path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      });
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      await refresh();
    }
  }
  const approval = (approvalId?: string) => (approvalId ? { approval_id: approvalId } : {});
  return {
    stop: (sessionId: string, approvalId?: string) =>
      post(`/pos/timed_sessions/${sessionId}/stop`, approval(approvalId)),
    move: (sessionId: string, resourceId: string) =>
      post(`/pos/timed_sessions/${sessionId}/move`, { resource_id: resourceId }),
    pause: (sessionId: string) => post(`/pos/timed_sessions/${sessionId}/pause`),
    // A pause longer than the branch allows needs a manager's approval.
    resume: (sessionId: string, approvalId?: string) =>
      post(`/pos/timed_sessions/${sessionId}/resume`, approval(approvalId)),
    // A minutes card read at the counter; it pays the time when the clock stops.
    minutesCard: (sessionId: string, cardToken: string) =>
      post(`/pos/timed_sessions/${sessionId}/minutes_card`, { card_token: cardToken }),
  };
}

// A prepaid package of a branch's rate plan, as the start of a clock offers it.
export type RatePackage = {
  code: string;
  name: string;
  minutes: number;
  price: string;
  planName: string;
  typeCode: string;
};

export function readPackages(value: unknown): RatePackage[] {
  const rows = Array.isArray(value) ? value : [];
  return rows.flatMap((plan) => {
    const source = (plan ?? {}) as Record<string, unknown>;
    if (source.status !== 'active' || !Array.isArray(source.packages)) return [];
    return source.packages.flatMap((row) => {
      const item = (row ?? {}) as Record<string, unknown>;
      if (typeof item.code !== 'string' || typeof item.name !== 'string') return [];
      return [
        {
          code: item.code,
          name: item.name,
          minutes: Number(item.minutes) || 0,
          price: String(item.price ?? '0'),
          planName: typeof source.name === 'string' ? source.name : '',
          typeCode: typeof source.resource_type_code === 'string' ? source.resource_type_code : '',
        },
      ];
    });
  });
}

// The packages the branch's active rate plans sell.
export function useRatePackages(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'rate-packages', snapshot.generation, branchId] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    staleTime: 5 * 60_000,
    queryFn: async () => {
      const result = await session.request<{ data: unknown }>(
        'GET',
        `/pos/rate_plans?branch_id=${encodeURIComponent(branchId ?? '')}&limit=100`,
      );
      return readPackages(result.data);
    },
  });
}

// One turn in the attendants book: who serves a room since when.
export type AttendantTurn = { id: string; staffId: string; staffName: string; startedAt: string };
export type AttendantCandidate = { id: string; name: string };

export function readTurns(value: unknown): AttendantTurn[] {
  const rows = Array.isArray(value) ? value : [];
  return rows.flatMap((row) => {
    const source = (row ?? {}) as Record<string, unknown>;
    const staff = (source.staff ?? {}) as Record<string, unknown>;
    if (typeof source.id !== 'string' || typeof staff.id !== 'string') return [];
    return [
      {
        id: source.id,
        staffId: staff.id,
        staffName: typeof staff.name === 'string' ? staff.name : '',
        startedAt: typeof source.started_at === 'string' ? source.started_at : '',
      },
    ];
  });
}

// The open turns on one room, and the branch staff who may serve it.
export function useAttendants(
  branchId: string | null,
  resourceId: string | null,
  enabled: boolean,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const key = ['pos', 'attendants', snapshot.generation, branchId, resourceId] as const;
  const ready = enabled && snapshot.status === 'authenticated' && Boolean(branchId && resourceId);
  const turns = useQuery({
    queryKey: key,
    enabled: ready,
    queryFn: async () => {
      const query = `branch_id=${encodeURIComponent(branchId ?? '')}&resource_id=${encodeURIComponent(resourceId ?? '')}`;
      const result = await session.request<{ data: unknown }>(
        'GET',
        `/pos/attendant_assignments?${query}`,
      );
      return readTurns(result.data);
    },
  });
  const candidates = useQuery({
    queryKey: ['pos', 'attendant-candidates', snapshot.generation, branchId] as const,
    enabled: ready,
    staleTime: 5 * 60_000,
    queryFn: async () => {
      const result = await session.request<{ data: AttendantCandidate[] }>(
        'GET',
        `/pos/attendant_assignments/candidates?branch_id=${encodeURIComponent(branchId ?? '')}`,
      );
      return Array.isArray(result.data) ? result.data : [];
    },
  });
  async function post(path: string, body: Record<string, unknown> = {}) {
    const idempotency = crypto.randomUUID();
    try {
      await session.request('POST', path, {
        body: { ...body, idempotency_key: idempotency },
        idempotencyKey: idempotency,
      });
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      await queryClient.invalidateQueries({ queryKey: key });
    }
  }
  return {
    turns,
    candidates,
    assign: (staffId: string) =>
      post('/pos/attendant_assignments', {
        branch_id: branchId,
        resource_id: resourceId,
        staff_id: staffId,
      }),
    end: (turnId: string) => post(`/pos/attendant_assignments/${turnId}/stop`),
  };
}
