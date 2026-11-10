import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import type { DocumentType, PaperSize } from '@parkviet/pos-shared/receipt-template/types'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'
import { allPages } from './use-topology'

// Store-wide POS master data (payment methods, units, staff roles, scale
// label formats) and the per-branch choices made from it.

export type PaymentMethodKind = 'cash' | 'bank_manual' | 'vietqr'
export const PAYMENT_METHOD_KINDS: readonly PaymentMethodKind[] = ['cash', 'bank_manual', 'vietqr']
export type PosPaymentMethod = {
  id: string
  code: string
  name: string
  kind: PaymentMethodKind
  payment_method_id: string | null
  status: 'active' | 'disabled'
  position: number
}
export type BranchPaymentMethods = {
  branch_id: string
  // False while the branch offers every active method of the store.
  customized: boolean
  payment_methods: (PosPaymentMethod & { enabled: boolean })[]
}

export type UnitDimension = 'mass' | 'volume' | 'count'
export const UNIT_DIMENSIONS: readonly UnitDimension[] = ['count', 'mass', 'volume']
export type StoreUnit = {
  id: string
  code: string
  name: string
  dimension: UnitDimension
  base_code: string
  factor_to_base: number
  sale_precision: number
  version: number
  status: 'active' | 'disabled'
}

export type StaffRole = {
  id: string
  name: string
  capabilities: string[]
  status: 'active' | 'disabled'
  membership_count: number
}

export type StoreLabelFormat = LabelFormat & { branch_ids: string[] }

export type TemplateSummary = {
  id: string
  name: string
  paper: PaperSize
  status: 'active' | 'disabled'
  is_default: boolean
}
export type BranchTemplateAssignment = {
  document_type: DocumentType
  receipt_template: TemplateSummary | null
  effective_template: TemplateSummary | null
  uses_store_default: boolean
}

const withDisabled = (includeDisabled: boolean) => ({
  include_disabled: includeDisabled ? 'true' : undefined,
})

export const readPaymentMethods = async (includeDisabled: boolean) =>
  (
    await posRequest<{ data: PosPaymentMethod[] }>('GET', '/pos/payment_methods', {
      params: withDisabled(includeDisabled),
    })
  ).data
export const readUnits = async (includeDisabled: boolean) =>
  (
    await posRequest<{ data: StoreUnit[] }>('GET', '/pos/units', {
      params: withDisabled(includeDisabled),
    })
  ).data
export const readStaffRoles = async (includeDisabled: boolean) =>
  (await allPages<StaffRole>('/pos/staff_roles', withDisabled(includeDisabled))).data
export const readStoreLabelFormats = async () =>
  (await allPages<StoreLabelFormat>('/pos/label_formats')).data

function useStoreQuery<T>(
  [resource, ...parts]: [string, ...string[]],
  enabled: boolean,
  read: () => Promise<T>,
) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, resource, ...parts),
    enabled: enabled && status === 'authenticated',
    queryFn: read,
  })
}
export const useStaffRoles = (enabled: boolean) =>
  useStoreQuery(['staff-roles'], enabled, () => readStaffRoles(false))
export const useStoreLabelFormats = (enabled: boolean) =>
  useStoreQuery(['label-formats'], enabled, readStoreLabelFormats)
export const useActivePaymentMethods = (enabled: boolean) =>
  useStoreQuery(['payment-methods'], enabled, () => readPaymentMethods(false))

const branchPath = (branchId: string, resource: string) =>
  `/pos/branches/${encodeURIComponent(branchId)}/${resource}`
export const useBranchPaymentMethods = (branchId: string, enabled: boolean) =>
  useStoreQuery(['branch-payment-methods', branchId], enabled, async () => {
    const result = await posRequest<{ data: BranchPaymentMethods }>(
      'GET',
      branchPath(branchId, 'payment_methods'),
    )
    return result.data
  })
export const useBranchLabelFormats = (branchId: string, enabled: boolean) =>
  useStoreQuery(
    ['branch-label-formats', branchId],
    enabled,
    async () => (await allPages<StoreLabelFormat>(branchPath(branchId, 'label_formats'))).data,
  )
export const useBranchReceiptTemplates = (branchId: string, enabled: boolean) =>
  useStoreQuery(['branch-receipt-templates', branchId], enabled, async () => {
    const result = await posRequest<{
      data: { branch_id: string; templates: BranchTemplateAssignment[] }
    }>('GET', branchPath(branchId, 'receipt_templates'))
    return result.data.templates
  })
// One write against the store's POS data; every POS query of the store is
// refreshed afterwards. Refusals reach the caller untouched so 409 reasons
// and 422 field details stay readable.
export function useStoreWrite() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest<{ data?: unknown }>(method, path, body === undefined ? {} : { body }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}

const REFUSALS = [
  'last_cash_method',
  'payment_method_in_use',
  'unit_in_use',
  'staff_role_in_use',
] as const
// The refusal text of a master-data write: the known 409 reasons in the
// reader's language, anything else as the shared POS failure text.
export function masterFailure(error: unknown, t: (key: string) => string) {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`masterData.failure_${reason}`)
    : describeFailure(error, t)
}
