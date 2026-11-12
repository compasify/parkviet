import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// A branch's self-ordering kiosks (GET /pos/kiosk_settings): how long a kiosk
// waits for a touch, how long its bank QR stays open, whether orders left
// for the counter reach the kitchen before they are paid, and each kiosk
// register with its paired device, open shift and orders waiting at the counter.
export type KioskRow = {
  register_id: string
  register_name: string
  register_status: string
  device_name: string | null
  device_seen_at: string | null
  provisioned: boolean
  shift_opened_at: string | null
  shift_open: boolean
  waiting_orders: number
}

export type KioskSettings = {
  branch_id: string
  kiosk_idle_seconds: number
  kiosk_qr_timeout_seconds: number
  kiosk_kitchen_before_payment: boolean
  kiosks: KioskRow[]
}

// The ranges the server accepts, in seconds.
export const KIOSK_IDLE_RANGE = { min: 15, max: 600 } as const
export const KIOSK_QR_TIMEOUT_RANGE = { min: 60, max: 900 } as const

type Row = Record<string, unknown>
const record = (value: unknown): Row | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Row) : null
const text = (value: unknown) => (typeof value === 'string' ? value : '')
const textOrNull = (value: unknown) => (typeof value === 'string' && value ? value : null)

export function normalizeKioskSettings(value: unknown): KioskSettings {
  const row = record(value) ?? {}
  const kiosks = (Array.isArray(row.kiosks) ? row.kiosks : []).flatMap((item): KioskRow[] => {
    const kiosk = record(item)
    const register = record(kiosk?.register)
    const id = text(register?.id)
    if (!kiosk || !register || !id) return []
    const device = record(kiosk.device)
    const shift = record(kiosk.shift)
    return [
      {
        register_id: id,
        register_name: text(register.name),
        register_status: text(register.status),
        device_name: device ? textOrNull(device.name) : null,
        device_seen_at: device ? textOrNull(device.last_seen_at) : null,
        provisioned: kiosk.provisioned === true,
        shift_opened_at: shift ? textOrNull(shift.opened_at) : null,
        shift_open: Boolean(shift),
        waiting_orders: Number(kiosk.waiting_orders) || 0,
      },
    ]
  })
  return {
    branch_id: text(row.branch_id),
    kiosk_idle_seconds: Number(row.kiosk_idle_seconds) || 60,
    kiosk_qr_timeout_seconds: Number(row.kiosk_qr_timeout_seconds) || 180,
    kiosk_kitchen_before_payment: row.kiosk_kitchen_before_payment === true,
    kiosks,
  }
}

// A whole number of seconds within the range, or null.
export function secondsWithin(value: string, range: { min: number; max: number }): number | null {
  if (!/^\d+$/.test(value.trim())) return null
  const seconds = Number(value.trim())
  return seconds >= range.min && seconds <= range.max ? seconds : null
}

export function useKioskSettings(branchId: string, enabled: boolean) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'kiosk-settings', branchId),
    enabled,
    queryFn: async () =>
      normalizeKioskSettings(
        (
          await posRequest<{ data?: unknown }>('GET', '/pos/kiosk_settings', {
            params: { branch_id: branchId },
          })
        ).data,
      ),
  })
}

export function useKioskWrite() {
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
    onSuccess: () => client.invalidateQueries({ queryKey: posKey(storeId, 'kiosk-settings') }),
  })
}
