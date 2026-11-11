import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export type KitchenStationKind = 'prep' | 'bar' | 'expo'
export type KitchenSendTrigger = 'on_complete' | 'manual'

export type KitchenStation = {
  id: string
  branch_id: string
  name: string
  kind: KitchenStationKind
  printer_id: string | null
  printer_name: string | null
  kds_enabled: boolean
  is_default: boolean
  warn_after_minutes: number
  late_after_minutes: number
  position: number
  active: boolean
}

export type StationRoute = {
  id: string
  branch_id: string
  kitchen_station_id: string
  product_id: string | null
  product_name: string | null
  kitchen_category: string | null
  service_mode: string | null
}

export type KitchenSettings = {
  branch_id: string
  kitchen_send_trigger: KitchenSendTrigger
  module_enabled: boolean
}

export type CupLabelSize = '40x30' | '50x30' | '58x40'
export type CupLabelField =
  | 'call_number'
  | 'options'
  | 'note'
  | 'guest_name'
  | 'time'
  | 'store_name'

// The branch's cup label printer and label, and how long a ready call
// number stays on the call board.
export type CupLabelSettings = {
  branch_id: string
  printer_id: string | null
  size: CupLabelSize
  fields: CupLabelField[]
  pickup_minutes: number
  module_enabled: boolean
  sizes: CupLabelSize[]
  available_fields: CupLabelField[]
}

function useBranchList<T>(resource: string, path: string, branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'kitchen', resource, branchId),
    queryFn: async () =>
      (await posRequest<{ data: T }>('GET', path, { params: { branch_id: branchId } })).data,
  })
}

export const useKitchenStations = (branchId: string) =>
  useBranchList<KitchenStation[]>('stations', '/pos/kitchen_stations', branchId)
export const useStationRoutes = (branchId: string) =>
  useBranchList<StationRoute[]>('routes', '/pos/station_routes', branchId)
export const useKitchenSettings = (branchId: string) =>
  useBranchList<KitchenSettings>('settings', '/pos/kitchen_settings', branchId)
export const useCupLabelSettings = (branchId: string) =>
  useBranchList<CupLabelSettings>('cup-labels', '/pos/cup_label_settings', branchId)

// Every kitchen setup write is a command with its own idempotency key.
export function useKitchenWrite() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest<{ data: unknown }>(method, path, {
        body: body ?? {},
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: posKey(storeId, 'kitchen') }),
  })
}
