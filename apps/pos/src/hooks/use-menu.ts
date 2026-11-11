import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosMenu } from '../lib/pos-context';
import { pollInterval } from '../lib/realtime';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';

// Without the branch stream the menu is read again every minute, so sold-out
// marks and time-of-day prices still reach the counter.
export const MENU_FALLBACK_POLL_MS = 60_000;

export function posMenuKey(generation: number, branchId: string | null) {
  return ['pos', 'menu', generation, branchId] as const;
}

// The menu of the selected branch. `menu.sold_out` invalidates it through the
// branch stream; the poll covers a dropped stream and schedules that start.
export function useMenu(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  return useQuery({
    queryKey: posMenuKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: pollInterval(realtime, MENU_FALLBACK_POLL_MS),
    queryFn: () => fetchMenu(branchId),
  });
}

export async function fetchMenu(branchId: string | null): Promise<PosMenu> {
  try {
    const result = await session.request<{ data: PosMenu }>('GET', '/pos/menu', {
      params: { branch_id: branchId ?? undefined },
    });
    return result.data;
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}

// Staff with pos.menu.sold_out mark an item sold out for today at the branch.
export function useSoldOutToggle(branchId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return async (menuItemId: string, soldOut: boolean) => {
    const key = crypto.randomUUID();
    try {
      await session.request('PUT', '/pos/menu_availabilities', {
        body: {
          branch_id: branchId,
          menu_item_id: menuItemId,
          sold_out: soldOut,
          idempotency_key: key,
        },
        idempotencyKey: key,
      });
    } catch (error) {
      if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
        session.abandon();
      throw error;
    } finally {
      await queryClient.invalidateQueries({ queryKey: posMenuKey(snapshot.generation, branchId) });
    }
  };
}
