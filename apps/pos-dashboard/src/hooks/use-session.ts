import { useAuth, useStore } from '@spree/dashboard-core'

// Migration adapter: generation is now a store identity, never a counter.
export function useSession() {
  const { storeId } = useStore()
  const { isAuthenticated } = useAuth()
  return { generation: storeId, storeId, status: isAuthenticated ? 'authenticated' : 'anonymous' }
}
