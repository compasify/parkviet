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
  // Menu units the kitchen has not been told about; null from a server that
  // does not say.
  unsent: number | null;
};

// One page of open tabs, newest first, with how many are open in all.
export type OpenTabPage = { tabs: OpenTab[]; total: number };

// How many tabs one read brings: the server's page maximum.
export const OPEN_TAB_PAGE = 100;

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
        unsent: Number.isInteger(source.unsent_kitchen_items)
          ? (source.unsent_kitchen_items as number)
          : null,
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
    queryFn: async (): Promise<OpenTabPage> => {
      try {
        const result = await session.request<{ data: unknown; meta?: { count?: unknown } }>(
          'GET',
          '/pos/workspaces',
          {
            params: {
              branch_id: branchId ?? undefined,
              service_mode: 'tab',
              status: 'editing,parked',
              limit: String(OPEN_TAB_PAGE),
              ...(q ? { q } : {}),
            },
          },
        );
        const tabs = normalizeTabs(result.data);
        const count = result.meta?.count;
        return {
          tabs,
          total: Number.isInteger(count) ? Math.max(count as number, tabs.length) : tabs.length,
        };
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}
