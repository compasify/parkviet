import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// The hardware checklist of a branch (`GET /pos/hardware_status`), read from
// what the server knows: nothing here is ticked by hand.
export type HardwareCheckStatus = 'ok' | 'attention' | 'not_needed'

export const HARDWARE_CHECKS = [
  'receipt_printer',
  'kitchen_printer',
  'cup_label_printer',
  'kitchen_stations',
  'print_station',
  'customer_display',
  'server',
  'einvoice',
] as const
export type HardwareCheckKey = (typeof HARDWARE_CHECKS)[number]

export type HardwareStatus = {
  branch_id: string
  generated_at: string
  checks: { key: HardwareCheckKey; status: HardwareCheckStatus }[]
  printers: {
    id: string
    name: string
    connection: string
    roles: string[]
    via_print_station: boolean
    last_job_status: string | null
    last_job_kind: string | null
    last_job_at: string | null
    last_error: string | null
  }[]
  stations: {
    id: string
    name: string
    kind: string
    printer_id: string | null
    kds_devices: number
    ok: boolean
  }[]
  devices: {
    id: string
    name: string
    mode: 'kds' | 'expo' | 'print_station'
    kitchen_station_id: string | null
    last_seen_at: string | null
    online: boolean
  }[]
  customer_displays: { live: number }
  server: {
    public_base_url: string | null
    tls_mode: string
    outbound_pending: number
    outbound_failed: number
    outbound_oldest_pending_age_seconds: number | null
    vietqr_last_received_at: string | null
  }
  einvoice: {
    type: 'none' | 'cash_register' | 'coded'
    provider: string | null
    configured: boolean
    missing_fields: string[]
  }
}

// Read again every 30 seconds while open: printers and stations come online
// while the owner works through the list.
export function useHardwareStatus(branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'hardware-status', branchId),
    refetchInterval: 30_000,
    queryFn: async () =>
      (
        await posRequest<{ data: HardwareStatus }>('GET', '/pos/hardware_status', {
          params: { branch_id: branchId },
        })
      ).data,
  })
}
