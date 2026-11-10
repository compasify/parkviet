import { adminClient } from '@spree/dashboard-core'

// Installed @spree/admin-sdk 6.0.3 exposes request(method, path, options).
// Paths are relative to /api/v3/admin; options support body, params, headers
// and native idempotencyKey (which also informs the SDK's safe retry policy).
// Reuse its JWT refresh/401 handler, store header, structured SpreeError and retry policy.
export type PosRequestOptions = {
  body?: unknown
  params?: Record<string, string | undefined>
  idempotencyKey?: string
  headers?: Record<string, string>
}
export function posRequest<T>(
  method: string,
  path: string,
  options: PosRequestOptions = {},
): Promise<T> {
  return adminClient.request<T>(method, path, options)
}
