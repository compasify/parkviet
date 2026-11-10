import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Names typed lately at the branch, for a quick pick on the sale screen.
export function useRecentDeliverers(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'deliverers', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    staleTime: 60_000,
    queryFn: async () =>
      (
        await read<{ data: string[] }>('/pos/deliveries/deliverers', {
          branch_id: branchId ?? undefined,
        })
      ).data,
  });
}
