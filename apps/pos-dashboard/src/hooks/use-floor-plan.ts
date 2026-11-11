import {
  type AreaRecord,
  normalizeArea,
  normalizeResource,
  type ResourceRecord,
} from '@parkviet/pos-shared/tables'
import { SERVICE_MODES, type ServiceMode } from '@parkviet/pos-shared/types/pos-context'
import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// The register table orders are booked on and the service charge of a branch.
export type TableSettings = {
  branch_id: string
  table_register_id: string | null
  service_charge_rate: string | null
  service_charge_applies_to: ServiceMode[]
  service_charge_tax_category_id: string | null
  // Bar settings: how long a guest's bottle is kept, whether tips count as
  // revenue, and how tips are split (role ids empty: every staff member).
  bottle_keep_days: number | null
  tips_as_revenue: boolean
  tip_split: TipSplit
  // The store's tax categories, sent with the settings so a branch manager
  // without the store's tax settings can still choose the charge's.
  tax_categories: TaxCategoryOption[]
}

export type TaxCategoryOption = { id: string; name: string }

export const TIP_SPLIT_MODES = ['equal', 'by_hours', 'manual'] as const
export type TipSplit = { mode: (typeof TIP_SPLIT_MODES)[number]; role_codes: string[] }

const rows = (value: unknown): unknown[] => (Array.isArray(value) ? value : [])

const getData = async (path: string, params: Record<string, string>) =>
  (await posRequest<{ data?: unknown }>('GET', path, { params })).data

function useFloorList<T>(
  resource: string,
  path: string,
  branchId: string,
  read: (data: unknown) => T,
) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'floor-plan', resource, branchId),
    queryFn: async () => read(await getData(path, { branch_id: branchId })),
  })
}

// Active areas by position, and the active tables of the branch.
export const useAreas = (branchId: string) =>
  useFloorList('areas', '/pos/areas', branchId, (data): AreaRecord[] =>
    rows(data)
      .flatMap((row) => {
        const area = normalizeArea(row)
        return area && area.status === 'active' ? [area] : []
      })
      .sort((left, right) => left.position - right.position),
  )
export const useResources = (branchId: string) =>
  useFloorList('resources', '/pos/resources', branchId, (data): ResourceRecord[] =>
    rows(data).flatMap((row) => {
      const table = normalizeResource(row)
      return table && table.status === 'active' ? [table] : []
    }),
  )
const tipSplitOf = (value: unknown): TipSplit => {
  const source = (typeof value === 'object' && value ? value : {}) as Record<string, unknown>
  const mode = TIP_SPLIT_MODES.find((name) => name === source.mode) ?? 'equal'
  return {
    mode,
    role_codes: rows(source.role_codes).filter((code): code is string => typeof code === 'string'),
  }
}
const textOrNull = (value: unknown) => (typeof value === 'string' && value ? value : null)
export const useTableSettings = (branchId: string) =>
  useFloorList('settings', '/pos/table_settings', branchId, (data): TableSettings => {
    // Fields of anything but an object read as absent.
    const source = (typeof data === 'object' && data ? data : {}) as Record<string, unknown>
    return {
      branch_id: textOrNull(source.branch_id) ?? branchId,
      table_register_id: textOrNull(source.table_register_id),
      service_charge_rate: textOrNull(source.service_charge_rate),
      service_charge_applies_to: rows(source.service_charge_applies_to).filter(
        (mode): mode is ServiceMode => (SERVICE_MODES as readonly unknown[]).includes(mode),
      ),
      service_charge_tax_category_id: textOrNull(source.service_charge_tax_category_id),
      bottle_keep_days: Number.isInteger(source.bottle_keep_days)
        ? (source.bottle_keep_days as number)
        : null,
      tips_as_revenue: source.tips_as_revenue === true,
      tip_split: tipSplitOf(source.tip_split),
      tax_categories: rows(source.tax_categories).flatMap((row) => {
        const item = row as { id?: unknown; name?: unknown }
        return typeof item.id === 'string' && typeof item.name === 'string'
          ? [{ id: item.id, name: item.name }]
          : []
      }),
    }
  })

// Every floor plan write is a command with its own idempotency key.
export function useFloorPlanWrite() {
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
    onSuccess: () => client.invalidateQueries({ queryKey: posKey(storeId, 'floor-plan') }),
  })
}
