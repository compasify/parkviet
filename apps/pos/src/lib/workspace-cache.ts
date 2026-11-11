import type { QueryClient } from '@tanstack/react-query';
import type { PosWorkspace } from './pos-context';
import { posWorkspacesKey } from './query-keys';

type Page = { data: PosWorkspace[]; meta: { page: number; pages: number; count: number } };

// Writes the full workspace a mutation returned into every cached list page
// and selected-tab entry that holds an older copy of it. No GET is needed to
// show the new state; an entry already at a newer revision is kept.
export function writeWorkspaceToCache(
  queryClient: QueryClient,
  generation: number,
  storeId: string | null,
  workspace: PosWorkspace,
) {
  const base = posWorkspacesKey(generation, storeId);
  queryClient.setQueriesData<Page | { data: PosWorkspace }>({ queryKey: base }, (current) => {
    // Derived lists under the same key (the open bar tabs) hold their own shape.
    if (!current || !('data' in current)) return current;
    const update = (previous: PosWorkspace) =>
      previous.id === workspace.id &&
      previous.revision <= workspace.revision &&
      previous.lease_generation <= workspace.lease_generation
        ? workspace
        : previous;
    return 'meta' in current
      ? { ...current, data: current.data.map(update) }
      : { ...current, data: update(current.data) };
  });
}

// Selected-tab entries hold the canonical workspace already; only the list
// pages (which may drop a completed or parked tab) need a background reload.
export function refreshWorkspaceLists(
  queryClient: QueryClient,
  generation: number,
  storeId: string | null,
) {
  const base = posWorkspacesKey(generation, storeId);
  return queryClient.invalidateQueries({
    queryKey: base,
    predicate: (query) => query.queryKey[base.length] !== 'selected',
  });
}
