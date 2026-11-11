import { useQueryClient } from '@tanstack/react-query';
import { useEffect, useRef, useSyncExternalStore } from 'react';
import { session } from '../lib/app-session';
import {
  invalidationsFor,
  openBranchStream,
  type RealtimeEvent,
  realtimeStatus,
  selectedWorkspaceFilter,
  unreadWorkspaceListFilter,
  workspaceListFilter,
} from '../lib/realtime';
import { useSession } from './use-session';

// Events of a busy branch arrive in bursts; one refetch answers all of them.
const COALESCE_MS = 150;
// The list is the heaviest read and any workspace of the branch dirties it.
export const LIST_REFETCH_MS = 1_000;

export function useRealtimeStatus() {
  return useSyncExternalStore(realtimeStatus.subscribe, realtimeStatus.get, realtimeStatus.get);
}

// Holds the branch stream open for this session and turns events into
// refetches through the API. A connection may have missed events, so each one
// refetches everything on screen.
export function useBranchEvents(branchId: string | null, storeId: string | null) {
  const { status, generation } = useSession();
  const queryClient = useQueryClient();
  // The store id goes blank while a selection loads. It only names query keys,
  // so it must not reopen the socket: the last known one stays in use.
  const knownStoreId = useRef(storeId);

  useEffect(() => {
    if (storeId) knownStoreId.current = storeId;
  }, [storeId]);

  useEffect(() => {
    if (status !== 'authenticated' || !branchId) return;
    const scope = () => ({ generation, storeId: knownStoreId.current });
    const pending = new Map<string, RealtimeEvent>();
    let timer: ReturnType<typeof setTimeout> | undefined;
    let listTimer: ReturnType<typeof setTimeout> | undefined;
    let stopped = false;

    function refreshSelected(event: RealtimeEvent) {
      const filter = selectedWorkspaceFilter(event, scope());
      void queryClient.invalidateQueries(filter, { cancelRefetch: false }).then(() => {
        // Joining a read already in flight can return data older than this
        // event; one forced read then catches up.
        if (queryClient.getQueryCache().findAll(filter).length > 0)
          void queryClient.invalidateQueries(filter);
      });
    }

    function refreshList() {
      const filter = workspaceListFilter(scope());
      // A list read in flight may predate the event, so wait it out.
      if (queryClient.isFetching(filter) > 0) {
        listTimer = setTimeout(refreshList, LIST_REFETCH_MS);
        return;
      }
      listTimer = undefined;
      void queryClient.invalidateQueries(filter, { cancelRefetch: false }).then(() => {
        if (stopped) return;
        if (queryClient.getQueryCache().findAll(unreadWorkspaceListFilter(scope())).length > 0)
          listTimer ??= setTimeout(refreshList, LIST_REFETCH_MS);
      });
    }

    function flush() {
      timer = undefined;
      const events = [...pending.values()];
      pending.clear();
      for (const event of events) {
        if (event.event === 'workspace.updated') refreshSelected(event);
        for (const filter of invalidationsFor(event, scope()))
          void queryClient.invalidateQueries(filter);
      }
    }

    const close = openBranchStream({
      branchId,
      token: () => session.socketToken(),
      onStatus: realtimeStatus.set,
      onConnected: () => void queryClient.invalidateQueries({ refetchType: 'active' }),
      onEvent: (event) => {
        if (event.branch_id !== branchId) return;
        pending.set(`${event.event}:${event.id}`, event);
        timer ??= setTimeout(flush, COALESCE_MS);
        if (event.event === 'workspace.updated')
          listTimer ??= setTimeout(refreshList, LIST_REFETCH_MS);
      },
    });

    return () => {
      stopped = true;
      close();
      clearTimeout(timer);
      clearTimeout(listTimer);
      realtimeStatus.set('offline');
    };
  }, [status, generation, branchId, queryClient]);
}
