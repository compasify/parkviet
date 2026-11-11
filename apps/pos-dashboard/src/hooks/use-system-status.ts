import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// GET /pos/system_status (SystemStatus in server/openapi/pos-staff.yaml).
export type SystemStatus = {
  generated_at: string
  version: { app: string; spree: string; rails: string }
  server: { public_base_url: string | null; tls_mode: 'none' | 'internal' | 'public' | 'unset' }
  database: { ok: boolean; latency_ms: number | null }
  jobs: {
    ok: boolean
    in_puma: boolean | null
    processes: number | null
    ready: number | null
    oldest_ready_age_seconds: number | null
    failed: number | null
  }
  realtime: { ok: boolean; adapter: string; probe_ms: number | null; measured_at: string }
  printing: {
    pending: number
    oldest_pending_age_seconds: number | null
    failed_last_24h: number
    failed_window_hours: number
  }
  outbound: { pending: number; failed: number; oldest_pending_age_seconds: number | null }
  vietqr: { last_received_at: string | null; unmatched: number }
  backup: { configured: boolean; last_at: string | null; count: number }
}

// Server health for store administrators, refreshed while the page is open.
export function useSystemStatus(enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'system-status'),
    enabled: enabled && status === 'authenticated',
    refetchInterval: 30_000,
    queryFn: () => posRequest<{ data: SystemStatus }>('GET', '/pos/system_status'),
  })
}
