import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosBranch, PosMembership, PosRegister } from '../lib/pos-context';
import { useSession } from './use-session';

export type StaffOption = { id: string; email: string; full_name: string | null };
export type LocationOption = { id: string; name: string; active: boolean };

export async function allPages<T>(path: string) {
  const data: T[] = [];
  let page: number | null = 1;
  while (page !== null) {
    const result: { data: T[]; meta?: { next: number | null } } = await session.request(
      'GET',
      path,
      {
        params: { limit: '100', page: String(page) },
      },
    );
    data.push(...result.data);
    page = result.meta?.next ?? null;
  }
  return { data };
}

function useTopology<T>(resource: string, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'topology', resource, snapshot.generation],
    enabled: enabled && snapshot.status === 'authenticated',
    queryFn: () => allPages<T>(`/pos/${resource}`),
  });
}

export const useBranches = (enabled: boolean) => useTopology<PosBranch>('branches', enabled);
export const useRegisters = (enabled: boolean) => useTopology<PosRegister>('registers', enabled);
export const useMemberships = (enabled: boolean) =>
  useTopology<PosMembership & { staff?: StaffOption; branch_name?: string }>(
    'memberships',
    enabled,
  );
export const useStaffOptions = (enabled: boolean) =>
  useTopology<StaffOption>('configuration/staff', enabled);
export const useLocationOptions = (enabled: boolean) =>
  useTopology<LocationOption>('configuration/locations', enabled);
