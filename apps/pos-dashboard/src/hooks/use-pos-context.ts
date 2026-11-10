import { useAuth, useStore } from '@spree/dashboard-core'
import { useQuery } from '@tanstack/react-query'
import { normalizeContext, type PosContext, type PosSelection } from '../lib/pos-context'
import { posRequest } from '../lib/pos-request'
import { posContextKey } from '../lib/query-keys'

export function usePosContext(selection: PosSelection = { branchId: null, registerId: null }) {
  const { storeId } = useStore()
  const { isAuthenticated } = useAuth()
  return useQuery({
    queryKey: posContextKey(storeId, selection),
    enabled: isAuthenticated,
    queryFn: async (): Promise<PosContext> =>
      normalizeContext(
        await posRequest<PosContext>('GET', '/pos/context', {
          params: {
            branch_id: selection.branchId ?? undefined,
            register_id: selection.registerId ?? undefined,
          },
        }),
      ),
  })
}
