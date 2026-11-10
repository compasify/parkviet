import { type BusinessProfiles, normalizeBusinessProfiles } from '@parkviet/pos-shared/pos-modules';
import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export const businessProfilesKey = (generation: number, storeId: string | null) =>
  ['pos', 'business-profiles', generation, storeId] as const;

// The catalogue only changes with a server release, so it is cached for the
// whole session; the store id keeps two stores of one login apart.
const ONE_HOUR = 60 * 60 * 1000;

// Industry profiles and modules the server offers (`GET /pos/business_profiles`,
// readable by every POS session). Labels come from `profiles.<key>.label` /
// `.description`; the list itself is never kept in the client.
export function useBusinessProfiles(storeId: string | null, enabled = true) {
  const snapshot = useSession();
  return useQuery({
    queryKey: businessProfilesKey(snapshot.generation, storeId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId),
    staleTime: ONE_HOUR,
    gcTime: ONE_HOUR,
    queryFn: async (): Promise<BusinessProfiles> => {
      try {
        const response = await session.request<{ data?: unknown }>(
          'GET',
          '/pos/business_profiles',
          {},
        );
        return normalizeBusinessProfiles(response.data);
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
}
