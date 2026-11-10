import type { PosBranch, PosMembership, PosRegister } from '@parkviet/pos-shared/types/pos-context'
import { queryClient } from '@spree/dashboard-core'
import { useMutation, useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export type StaffOption = { id: string; email: string; full_name: string | null }
export type LocationOption = { id: string; name: string; active: boolean }
export async function allPages<T>(path: string, params: Record<string, string | undefined> = {}) {
  const data: T[] = []
  let page: number | null = 1
  while (page !== null) {
    const result: { data: T[]; meta?: { next: number | null } } = await posRequest('GET', path, {
      params: { ...params, limit: '100', page: String(page) },
    })
    data.push(...result.data)
    page = result.meta?.next ?? null
  }
  return { data }
}
function useTopology<T>(resource: string, enabled: boolean) {
  const snapshot = useSession()
  return useQuery({
    queryKey: posKey(snapshot.storeId, 'topology', resource),
    enabled: enabled && snapshot.status === 'authenticated',
    queryFn: () => allPages<T>(`/pos/${resource}`),
  })
}
export const useBranches = (enabled = true) => useTopology<PosBranch>('branches', enabled)
export const useRegisters = (enabled = true) => useTopology<PosRegister>('registers', enabled)
export const useMemberships = (enabled = true) =>
  useTopology<PosMembership & { staff?: StaffOption; branch_name?: string }>('memberships', enabled)
export const useStaffOptions = (enabled = true) =>
  useTopology<StaffOption>('configuration/staff', enabled)
export const useLocationOptions = (enabled = true) =>
  useTopology<LocationOption>('configuration/locations', enabled)
export function useTopologyMutation() {
  const { storeId } = useSession()
  return useMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest(method, path, { body }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}
