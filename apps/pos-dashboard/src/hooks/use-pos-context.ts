import { useAuth, useStore } from '@spree/dashboard-core'
import { useQuery } from '@tanstack/react-query'
import { normalizeContext, type PosContext, type PosSelection } from '../lib/pos-context'
import { posRequest } from '../lib/pos-request'
import { posContextKey } from '../lib/query-keys'

export const NO_SELECTION: PosSelection = { branchId: null, registerId: null }

export function usePosContext(
  selection: PosSelection = NO_SELECTION,
  options: { enabled?: boolean; retry?: false } = {},
) {
  const { storeId } = useStore()
  const { isAuthenticated } = useAuth()
  return useQuery({
    queryKey: posContextKey(storeId, selection),
    enabled: isAuthenticated && options.enabled !== false,
    ...(options.retry === false ? { retry: false } : {}),
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
