import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import type { Page } from '../lib/table-params'
import type { BusOperator, CommissionRule, VisitSettings } from '../lib/vehicle-commission'
import { useSession } from './use-session'

// Bus operators belong to the store, rules and the visit window to a branch;
// every call names the branch, where coach visits must be on.

async function write<T>(method: 'POST' | 'PATCH', path: string, body: Record<string, unknown>) {
  const key = crypto.randomUUID()
  const result = await request<{ data: T }>(method, path, {
    body: { ...body, idempotency_key: key },
    idempotencyKey: key,
  })
  return result.data
}

export function useBusOperators(branchId: string) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'bus-operators', branchId),
    enabled: status === 'authenticated',
    queryFn: () =>
      request<Page<BusOperator>>('GET', '/pos/bus_operators', {
        params: { branch_id: branchId, limit: '100' },
      }),
  })
}

export function useCommissionRules(branchId: string) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'commission-rules', branchId),
    enabled: status === 'authenticated',
    queryFn: () =>
      request<Page<CommissionRule>>('GET', '/pos/commission_rules', {
        params: { branch_id: branchId, limit: '100' },
      }),
  })
}

export function useVisitSettings(branchId: string) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'vehicle-visit-settings', branchId),
    enabled: status === 'authenticated',
    queryFn: () =>
      request<{ data: VisitSettings }>('GET', '/pos/vehicle_visits/settings', {
        params: { branch_id: branchId },
      }),
  })
}

function useSave<T>(branchId: string, resource: string, path: string) {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: { id?: string; values: Record<string, unknown> }) =>
      write<T>(input.id ? 'PATCH' : 'POST', input.id ? `${path}/${input.id}` : path, {
        branch_id: branchId,
        ...input.values,
      }),
    onSettled: () => client.invalidateQueries({ queryKey: posKey(storeId, resource) }),
  })
}

export const useSaveBusOperator = (branchId: string) =>
  useSave<BusOperator>(branchId, 'bus-operators', '/pos/bus_operators')

export const useSaveCommissionRule = (branchId: string) =>
  useSave<CommissionRule>(branchId, 'commission-rules', '/pos/commission_rules')

export function useSaveVisitSettings(branchId: string) {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (minutes: number) =>
      write<VisitSettings>('PATCH', '/pos/vehicle_visits/settings', {
        branch_id: branchId,
        visit_window_minutes: minutes,
      }),
    onSettled: () =>
      client.invalidateQueries({ queryKey: posKey(storeId, 'vehicle-visit-settings') }),
  })
}
