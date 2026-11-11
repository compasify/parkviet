import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// Recipes of menu sizes and options, and a branch's low-stock thresholds.
// Quantities the server returns are in each ingredient's stock unit.

export type RecipeOwnerRef = { variant_id: string } | { modifier_option_id: string }

export type RecipeIngredient = {
  id: string
  variant_id: string
  name: string | null
  sku: string | null
  options_text: string | null
  quantity: string
  unit_code: string
  base_quantity: number
  base_unit: string
  unit_cost: string | null
  cost: string | null
}

export type RecipeOwner = {
  owner_type: 'variant' | 'modifier_option'
  owner_id: string
  track_inventory: boolean | null
  active: {
    id: string
    version: number
    active: boolean
    created_at: string
    estimated_cost: string | null
    ingredients: RecipeIngredient[]
  } | null
  versions: {
    id: string
    version: number
    active: boolean
    created_at: string
    ingredients: number
  }[]
}

export type RecipeRow = { variant_id: string; quantity: string; unit_code: string }

export type StockAlert = {
  id: string
  branch_id: string
  variant_id: string
  name: string | null
  sku: string | null
  options_text: string | null
  base_unit: string
  min_quantity: number
  on_hand: number
  low: boolean
}

export function useRecipe(owner: RecipeOwnerRef | null) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'recipes', owner),
    enabled: Boolean(owner),
    queryFn: async () =>
      (await posRequest<{ data: RecipeOwner }>('GET', '/pos/recipes', { params: owner ?? {} }))
        .data,
  })
}

export function useSaveRecipe() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: (
      body: RecipeOwnerRef & { ingredients: RecipeRow[]; confirm_stock_write_off?: boolean },
    ) =>
      posRequest<{ data: RecipeOwner }>('PUT', '/pos/recipes', {
        body,
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}

export function useStockAlerts(branchId: string | null) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'stock-alerts', branchId),
    enabled: Boolean(branchId),
    queryFn: async () =>
      (
        await posRequest<{ data: StockAlert[] }>('GET', '/pos/stock_alerts', {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  })
}

// `min_quantity: null` removes the threshold.
export function useSetStockAlert() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: (body: { branch_id: string; variant_id: string; min_quantity: number | null }) =>
      posRequest<{ data: StockAlert[] }>('PUT', '/pos/stock_alerts', {
        body,
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}
