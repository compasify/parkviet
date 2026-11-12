import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// The store's push relay (GET /pos/push_relay_settings): the HTTPS address
// that forwards notifications to owners' phones, whether its signing key is
// set (the key itself is never read back) and how the last delivery went.
// Without one the owner app hears events only while it is open.
export type PushRelay = {
  url: string
  key_set: boolean
  last_error: string | null
  last_error_at: string | null
  last_delivered_at: string | null
  updated_at: string | null
}

// What the server accepts.
export const RELAY_URL_MAX = 300
export const RELAY_KEY_RANGE = { min: 32, max: 512 } as const

type Row = Record<string, unknown>
const record = (value: unknown): Row | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Row) : null
const textOrNull = (value: unknown) => (typeof value === 'string' && value ? value : null)

export function normalizePushRelay(value: unknown): PushRelay | null {
  const row = record(value)
  const url = textOrNull(row?.url)
  if (!row || !url) return null
  return {
    url,
    key_set: row.key_set === true,
    last_error: textOrNull(row.last_error),
    last_error_at: textOrNull(row.last_error_at),
    last_delivered_at: textOrNull(row.last_delivered_at),
    updated_at: textOrNull(row.updated_at),
  }
}

// Why the form cannot be sent yet, or null. A key is needed only the first time.
export function relayInputProblem(url: string, key: string, keySet: boolean): 'url' | 'key' | null {
  const address = url.trim()
  if (!/^https:\/\/[^\s/]+/i.test(address) || address.length > RELAY_URL_MAX) return 'url'
  const secret = key.trim()
  if (!secret) return keySet ? null : 'key'
  return secret.length < RELAY_KEY_RANGE.min || secret.length > RELAY_KEY_RANGE.max ? 'key' : null
}

export function usePushRelay(enabled = true) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'push-relay'),
    enabled,
    queryFn: async () =>
      normalizePushRelay(
        (await posRequest<{ data?: unknown }>('GET', '/pos/push_relay_settings')).data,
      ),
  })
}

export function usePushRelayWrite() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest<{ data: unknown }>(method, path, { body: body ?? {} }),
    successMessage: false,
    errorMessage: false,
    onSettled: () => client.invalidateQueries({ queryKey: posKey(storeId, 'push-relay') }),
  })
}
