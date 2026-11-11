import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// E-invoices of completed sales and the store's e-invoice settings
// (`/pos/einvoices`, `/pos/einvoice_settings`). Credentials are write-only:
// the server returns only the names of the fields it holds.

export type EinvoiceType = 'none' | 'cash_register' | 'coded'
export type EinvoiceStatus =
  | 'pending'
  | 'issuing'
  | 'issued'
  | 'failed'
  | 'canceled'
  | 'replaced'
  | 'adjusted'

export type EinvoiceBuyer = {
  tax_code?: string | null
  name?: string | null
  address?: string | null
  personal_id?: string | null
  phone?: string | null
  passport_no?: string | null
  nationality?: string | null
  email?: string | null
  buyer_note?: string | null
  label?: string | null
}

export type Einvoice = {
  id: string
  order_id: string
  order_number: string
  branch_id: string
  branch_name: string
  relation: 'original' | 'replacement'
  original_einvoice_id: string | null
  invoice_type: 'cash_register' | 'coded'
  provider: string | null
  status: EinvoiceStatus
  buyer: EinvoiceBuyer
  template_code: string | null
  symbol: string | null
  number: string | null
  lookup_code: string | null
  lookup_url: string | null
  issued_at: string | null
  attempts: number
  next_attempt_at: string | null
  last_error: string | null
  buyer_link_open: boolean
  cancel_reason: string | null
  completed_at: string | null
  total: string | null
  currency: string
  created_at: string
}

export type EinvoiceSummary = {
  einvoice_type: EinvoiceType
  outstanding: number
  counts: Record<EinvoiceStatus, number>
  oldest_outstanding_at: string | null
  revenue: {
    year: number
    total: string
    threshold: string
    share: string
    level: 'ok' | 'warning' | 'reached'
  }
}

export type EinvoiceProvider = {
  key: string
  label: string
  sandbox: boolean
  credential_fields: string[]
  tax_code_lookup: boolean
}

export type EinvoiceSetting = {
  id: string
  branch_id: string | null
  branch_name: string | null
  provider: string
  status: 'active' | 'disabled'
  template_code: string | null
  symbol: string | null
  seller_name: string | null
  seller_tax_code: string | null
  seller_address: string | null
  consumer_label: string | null
  lookup_url: string | null
  buyer_link_hours: number | null
  credential_fields: string[]
}

export type EinvoiceSettings = {
  einvoice_type: EinvoiceType
  providers: EinvoiceProvider[]
  settings: EinvoiceSetting[]
  public_link: boolean
}

// What a save sends; leave `credentials` out to keep the stored ones.
export type EinvoiceSettingInput = Partial<
  Pick<
    EinvoiceSetting,
    | 'provider'
    | 'status'
    | 'template_code'
    | 'symbol'
    | 'seller_name'
    | 'seller_tax_code'
    | 'seller_address'
    | 'consumer_label'
    | 'lookup_url'
    | 'buyer_link_hours'
  >
> & { credentials?: Record<string, string> }

export type EinvoiceSample = {
  provider: string
  template_code: string | null
  symbol: string | null
  number: string | null
  lookup_code: string | null
  lookup_url: string | null
  issued_at: string | null
}

export type EinvoiceFilter = { branchId: string | null; status: string; q: string; page: number }

export function useEinvoices(filter: EinvoiceFilter) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'einvoices', filter),
    enabled: Boolean(filter.branchId),
    queryFn: () =>
      posRequest<{ data: Einvoice[]; meta?: { page?: number; pages?: number; count?: number } }>(
        'GET',
        '/pos/einvoices',
        {
          params: {
            branch_id: filter.branchId ?? undefined,
            status: filter.status || undefined,
            q: filter.q || undefined,
            page: String(filter.page),
          },
        },
      ),
  })
}

export function useEinvoiceSummary(branchId: string | null) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'einvoices', 'summary', branchId),
    enabled: Boolean(branchId),
    queryFn: async () =>
      (
        await posRequest<{ data: EinvoiceSummary }>('GET', '/pos/einvoices/summary', {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  })
}

function useEinvoiceWrite<Body, Result>(request: (body: Body) => Promise<Result>) {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: request,
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}

export const useUpdateEinvoiceBuyer = () =>
  useEinvoiceWrite(({ id, buyer }: { id: string; buyer: EinvoiceBuyer }) =>
    posRequest<{ data: Einvoice }>('PUT', `/pos/einvoices/${id}/buyer`, {
      body: { buyer },
      idempotencyKey: crypto.randomUUID(),
    }),
  )

export const useReplaceEinvoice = () =>
  useEinvoiceWrite(({ id, buyer, reason }: { id: string; buyer: EinvoiceBuyer; reason: string }) =>
    posRequest<{ data: Einvoice }>('POST', `/pos/einvoices/${id}/replace`, {
      body: { buyer, reason },
      idempotencyKey: crypto.randomUUID(),
    }),
  )

export const useCancelEinvoice = () =>
  useEinvoiceWrite(({ id, reason }: { id: string; reason: string }) =>
    posRequest<{ data: Einvoice }>('POST', `/pos/einvoices/${id}/cancel`, {
      body: { reason },
      idempotencyKey: crypto.randomUUID(),
    }),
  )

// Every failed invoice of the branch, or the listed ones.
export const useRetryEinvoices = () =>
  useEinvoiceWrite((body: { branch_id: string } | { ids: string[] }) =>
    posRequest<{ data: { queued: string[]; skipped: number } }>('POST', '/pos/einvoices/retry', {
      body,
      idempotencyKey: crypto.randomUUID(),
    }),
  )

export function useEinvoiceSettings() {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'einvoice-settings'),
    queryFn: async () =>
      (await posRequest<{ data: EinvoiceSettings }>('GET', '/pos/einvoice_settings')).data,
  })
}

export const useSaveEinvoiceSettings = () =>
  useEinvoiceWrite(
    (body: { einvoice_type?: EinvoiceType; branch_id?: string; setting?: EinvoiceSettingInput }) =>
      posRequest<{ data: EinvoiceSettings }>('PUT', '/pos/einvoice_settings', {
        body,
        idempotencyKey: crypto.randomUUID(),
      }),
  )

export const useEinvoiceSample = () =>
  useEinvoiceWrite((body: { branch_id?: string }) =>
    posRequest<{ data: EinvoiceSample }>('POST', '/pos/einvoice_settings/test', { body }),
  )
