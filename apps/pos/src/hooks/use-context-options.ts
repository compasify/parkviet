import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosBranch, PosRegister } from '../lib/pos-context';
import type { ContextOptions } from '../lib/pos-selection-rules';
import { useSession } from './use-session';

export function useContextBranches(storeId: string | null, enabled: boolean, q = '', page = 1) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'context-branches', snapshot.generation, storeId, q, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId),
    queryFn: () =>
      session.request<ContextOptions<PosBranch>>('GET', '/pos/context/branches', {
        params: { q, page: String(page) },
      }),
  });
}

export function useContextRegisters(
  storeId: string | null,
  branchId: string | null,
  enabled: boolean,
  q = '',
  page = 1,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'context-registers', snapshot.generation, storeId, branchId, q, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId && branchId),
    queryFn: () =>
      session.request<ContextOptions<PosRegister>>('GET', '/pos/context/registers', {
        params: { branch_id: branchId ?? undefined, q, page: String(page) },
      }),
  });
}
