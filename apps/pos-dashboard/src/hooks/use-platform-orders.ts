import type {
  Platform,
  PlatformOrder,
  PlatformSetting,
  PlatformSettings,
} from '@parkviet/pos-shared/platform-orders'
import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export type PlatformOrderPage = {
  data: PlatformOrder[]
  meta: { page: number; pages: number; count: number; limit: number }
}

export type UnsettledFilters = { platform?: Platform; from?: string; to?: string; page: number }

// The delivery platforms of one branch, configured or not.
export function usePlatformSettings(branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'platforms', 'settings', branchId),
    queryFn: async () =>
      (
        await posRequest<{ data: PlatformSettings }>('GET', '/pos/platform_settings', {
          params: { branch_id: branchId },
        })
      ).data,
  })
}

export function usePlatformSettingWrite(branchId: string) {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: (body: Pick<PlatformSetting, 'platform' | 'status' | 'commission_rate'>) =>
      posRequest<{ data: PlatformSetting }>('PUT', '/pos/platform_settings', {
        body: { ...body, branch_id: branchId },
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: posKey(storeId, 'platforms') }),
  })
}

// Completed orders the platforms have not paid for yet, newest first.
export function useUnsettledPlatformOrders(branchId: string, filters: UnsettledFilters) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'platforms', 'unsettled', branchId, filters),
    queryFn: () =>
      posRequest<PlatformOrderPage>('GET', '/pos/platform_orders', {
        params: {
          branch_id: branchId,
          status: 'unsettled',
          platform: filters.platform,
          from: filters.from,
          to: filters.to,
          page: String(filters.page),
          limit: '50',
        },
      }),
  })
}

export type SettleInput = {
  reference: string
  orders: { id: string; commission_amount?: string }[]
}

// Records that the platform paid for the orders, at the commission it kept.
export function useSettlePlatformOrders(branchId: string) {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: (input: SettleInput) =>
      posRequest<{ data: PlatformOrder[] }>('POST', '/pos/platform_orders/settle', {
        body: {
          branch_id: branchId,
          reference: input.reference.trim() || undefined,
          orders: input.orders,
        },
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: posKey(storeId, 'platforms') })
      void client.invalidateQueries({ queryKey: posKey(storeId, 'reports') })
    },
  })
}
