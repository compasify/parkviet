import { type BusinessProfiles, normalizeBusinessProfiles } from '@parkviet/pos-shared/pos-modules'
import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export const businessProfilesKey = (scope: string, storeId: string | null) =>
  posKey(scope, 'business-profiles', storeId)
export function useBusinessProfiles(storeId: string | null, enabled = true) {
  const snapshot = useSession()
  return useQuery({
    queryKey: businessProfilesKey(snapshot.storeId, storeId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId),
    staleTime: 3600000,
    gcTime: 3600000,
    queryFn: async (): Promise<BusinessProfiles> =>
      normalizeBusinessProfiles(
        (await posRequest<{ data?: unknown }>('GET', '/pos/business_profiles')).data,
      ),
  })
}
