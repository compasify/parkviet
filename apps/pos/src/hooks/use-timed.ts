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
  return {
    stop: (sessionId: string) => post(`/pos/timed_sessions/${sessionId}/stop`),
    move: (sessionId: string, resourceId: string) =>
      post(`/pos/timed_sessions/${sessionId}/move`, { resource_id: resourceId }),
  };
}
