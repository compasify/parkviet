// Admin API wrappers for spree_vietqr: VietQR payment methods, their
// receiving accounts, and the bank webhooks they received.
import { adminClient, i18n, useResourceKey, useResourceMutation } from '@spree/dashboard'
import { keepPreviousData, useQuery } from '@tanstack/react-query'
import type { VietqrReceivingAccount } from '../schemas/vietqr-receiving-account'

export const VIETQR_PAYMENT_METHOD_TYPE = 'vietqr'

export interface VietqrPaymentMethod {
  id: string
  name: string
  type: string
  active: boolean
}

export interface VietqrBank {
  bin: string
  name: string
}

export const VIETQR_WEBHOOK_STATUSES = [
  'received',
  'verified',
  'matched',
  'confirmed',
  'rejected',
  'unmatched',
  'duplicate',
  'error',
] as const
export type VietqrWebhookStatus = (typeof VIETQR_WEBHOOK_STATUSES)[number]

export interface VietqrWebhookEvent {
  id: string
  provider: string
  status: VietqrWebhookStatus
  provider_transaction_id: string | null
  amount: number | null
  parsed_order_code: string | null
  matched_order_number: string | null
  account_number: string | null
  bank_bin: string | null
  error_message: string | null
  payment_method_id: string | null
  processed_at: string | null
  created_at: string
  raw_payload?: Record<string, unknown>
}

export interface VietqrPage<T> {
  data: T[]
  meta: { page: number; per_page: number; count: number; pages: number }
}

export interface VietqrWebhookEventFilters {
  status?: string
  provider?: string
  q?: string
  page?: number
}

/** States an admin can resolve by hand — the API refuses the others. */
export const RESOLVABLE_WEBHOOK_STATUSES: VietqrWebhookStatus[] = ['unmatched', 'error']

export function isResolvableWebhookEvent(event: Pick<VietqrWebhookEvent, 'status'>): boolean {
  return RESOLVABLE_WEBHOOK_STATUSES.includes(event.status)
}

/** Drops empty filters so they never reach the query string or the cache key. */
export function webhookEventParams(
  filters: VietqrWebhookEventFilters,
): Record<string, string | number> {
  const params: Record<string, string | number> = {}
  for (const [key, value] of Object.entries(filters)) {
    if (value !== undefined && value !== '' && value !== 'all') params[key] = value
  }
  return params
}

export function useVietqrPaymentMethods() {
  return useQuery({
    queryKey: useResourceKey('vietqr-payment-methods'),
    queryFn: async () => {
      const response = await adminClient.request<{ data: VietqrPaymentMethod[] }>(
        'GET',
        '/payment_methods',
        {
          params: { per_page: 100 },
        },
      )
      return response.data.filter((method) => method.type === VIETQR_PAYMENT_METHOD_TYPE)
    },
    staleTime: 30_000,
  })
}

export function useVietqrBanks() {
  return useQuery({
    queryKey: useResourceKey('vietqr-banks'),
    queryFn: () =>
      adminClient.request<{ data: VietqrBank[] }>('GET', '/vietqr/banks').then((r) => r.data),
    staleTime: Number.POSITIVE_INFINITY,
  })
}

export function useVietqrReceivingAccounts(paymentMethodId: string | undefined) {
  return useQuery({
    queryKey: useResourceKey('vietqr-receiving-accounts', { paymentMethodId }),
    queryFn: () =>
      adminClient.request<VietqrPage<VietqrReceivingAccount>>('GET', '/vietqr/receiving_accounts', {
        params: { payment_method_id: paymentMethodId, per_page: 100 },
      }),
    enabled: Boolean(paymentMethodId),
  })
}

const ACCOUNTS_KEY = ['vietqr-receiving-accounts']

export function useCreateVietqrReceivingAccount(paymentMethodId: string) {
  return useResourceMutation({
    mutationFn: (body: Record<string, unknown>) =>
      adminClient.request<VietqrReceivingAccount>('POST', '/vietqr/receiving_accounts', {
        body: { ...body, payment_method_id: paymentMethodId },
      }),
    invalidate: [ACCOUNTS_KEY],
    successMessage: i18n.t('admin.vietqr.accounts.messages.created'),
  })
}

export function useUpdateVietqrReceivingAccount(id: string) {
  return useResourceMutation({
    mutationFn: (body: Record<string, unknown>) =>
      adminClient.request<VietqrReceivingAccount>('PATCH', `/vietqr/receiving_accounts/${id}`, {
        body,
      }),
    invalidate: [ACCOUNTS_KEY],
    successMessage: i18n.t('admin.vietqr.accounts.messages.updated'),
  })
}

export function useDeleteVietqrReceivingAccount() {
  return useResourceMutation({
    mutationFn: (id: string) => adminClient.request('DELETE', `/vietqr/receiving_accounts/${id}`),
    invalidate: [ACCOUNTS_KEY],
    successMessage: i18n.t('admin.vietqr.accounts.messages.removed'),
  })
}

export function useVietqrWebhookEvents(filters: VietqrWebhookEventFilters) {
  const params = webhookEventParams(filters)
  return useQuery({
    queryKey: useResourceKey('vietqr-webhook-events', params),
    queryFn: () =>
      adminClient.request<VietqrPage<VietqrWebhookEvent>>('GET', '/vietqr/webhook_events', {
        params,
      }),
    placeholderData: keepPreviousData,
  })
}

export function useVietqrWebhookEvent(id: string | undefined) {
  return useQuery({
    queryKey: useResourceKey('vietqr-webhook-event', id),
    queryFn: () => adminClient.request<VietqrWebhookEvent>('GET', `/vietqr/webhook_events/${id}`),
    enabled: Boolean(id),
  })
}

const EVENTS_KEYS = [['vietqr-webhook-events'], ['vietqr-webhook-event']]

export function useManualMatchVietqrWebhookEvent(id: string) {
  return useResourceMutation({
    mutationFn: (orderNumber: string) =>
      adminClient.request<VietqrWebhookEvent>('POST', `/vietqr/webhook_events/${id}/manual_match`, {
        body: { order_number: orderNumber },
      }),
    invalidate: EVENTS_KEYS,
    successMessage: i18n.t('admin.vietqr.events.messages.matched'),
    showValidationErrors: true,
  })
}

export function useRetryVietqrWebhookEvent(id: string) {
  return useResourceMutation({
    mutationFn: () =>
      adminClient.request<VietqrWebhookEvent>(
        'POST',
        `/vietqr/webhook_events/${id}/retry_processing`,
      ),
    invalidate: EVENTS_KEYS,
    successMessage: i18n.t('admin.vietqr.events.messages.retried'),
    showValidationErrors: true,
  })
}
