import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { posWorkspacesKey } from '../lib/query-keys';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// An open bar tab as the list shows it (`GET /pos/workspaces?service_mode=tab`).
export type OpenTab = {
  id: string;
  tabName: string;
  table: string | null;
  orderNumber: number | null;
  openedAt: string | null;
  total: string;
};

const FALLBACK_POLL_MS = 15_000;

function text(value: unknown): string | null {
  return typeof value === 'string' && value ? value : null;
}

export function normalizeTabs(rows: unknown): OpenTab[] {
  if (!Array.isArray(rows)) return [];
  return rows.flatMap((row) => {
    const source = (row ?? {}) as Record<string, unknown>;
    const id = text(source.id);
    const tabName = text(source.tab_name);
    if (!id || !tabName) return [];
    const resource = (source.resource ?? null) as Record<string, unknown> | null;
    return [
      {
        id,
        tabName,
        table: text(resource?.name),
        orderNumber: Number.isInteger(source.order_number) ? (source.order_number as number) : null,
        openedAt: text(source.opened_at),
        total: text(source.total) ?? '0',
      },
    ];
  });
}

// The open tabs of a branch, found by guest name, table or call number. The
// key sits under the workspace list, so every workspace refresh reads it again.
export function useOpenTabs(
  branchId: string | null,
  storeId: string | null,
  query: string,
  enabled: boolean,
) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  const q = query.trim();
  return useQuery({
    queryKey: [...posWorkspacesKey(snapshot.generation, storeId), 'tabs', branchId, q] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: pollInterval(realtime, FALLBACK_POLL_MS),
    placeholderData: (previous) => previous,
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown }>('GET', '/pos/workspaces', {
          params: {
            branch_id: branchId ?? undefined,
            service_mode: 'tab',
            status: 'editing,parked',
            limit: '100',
            ...(q ? { q } : {}),
          },
        });
        return normalizeTabs(result.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}
