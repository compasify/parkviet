import { useQuery } from '@tanstack/react-query';
import { usePosSelection } from '../components/pos-selection';
import { session } from '../lib/app-session';
import { normalizeModules, type PosModules } from '../lib/pos-modules';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export const branchModulesKey = (generation: number, branchId: string | null) =>
  ['pos', 'branch-modules', generation, branchId] as const;

// Modules on at a branch, for settings pages that show a branch by URL. The
// selected branch reads them from the context; any other branch asks
// `GET /pos/branches/:id/modules`. Null means unknown (loading, refused, a
// server without modules): the caller then hides nothing and lets the server
// decide, the same rule as a context without `modules`.
export function useBranchModules(branchId: string | null | undefined): PosModules | null {
  const snapshot = useSession();
  const { context, selection } = usePosSelection();
  const id = branchId || null;
  const selected =
    id !== null && selection.branchId === id && context.data?.selection.branch_id === id;
  const query = useQuery({
    queryKey: branchModulesKey(snapshot.generation, id),
    enabled: !selected && id !== null && snapshot.status === 'authenticated',
    staleTime: 30_000,
    retry: false,
    queryFn: async (): Promise<PosModules | null> => {
      try {
        const response = await session.request<{ data?: unknown }>(
          'GET',
          `/pos/branches/${encodeURIComponent(id ?? '')}/modules`,
          {},
        );
        const data = response.data;
        return typeof data === 'object' && data !== null && !Array.isArray(data)
          ? normalizeModules((data as { modules?: unknown }).modules)
          : null;
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
  if (selected) return context.data?.modules ?? null;
  return query.data ?? null;
}
