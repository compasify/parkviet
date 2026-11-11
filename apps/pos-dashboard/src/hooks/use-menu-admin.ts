import type {
  PosMenu,
  PosMenuCategory,
  PosMenuItem,
  PosMenuModifierGroup,
} from '@parkviet/pos-shared/types/pos-context'
import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

// The store's menu (categories, items, option groups, time-of-day menus)
// and a branch's favourites and sold-out marks. The menu belongs to the
// store; favourites and sold out belong to one branch.

export type MenuItemConfig = Omit<PosMenuItem, 'image_url' | 'sold_out' | 'variants'> & {
  variants: { id: string; name: string | null; sku: string | null; price: string | null }[]
}

export type MenuSchedule = {
  id: string
  branch_id: string | null
  name: string
  // Shown on the menu while the schedule runs ("Happy hour").
  label?: string | null
  days_of_week: number[]
  starts_at: string
  ends_at: string
  active: boolean
  items: {
    id: string
    menu_item_id: string
    variant_id: string | null
    price: string | null
    hidden: boolean
  }[]
}

export type MenuResource = 'menu_categories' | 'menu_items' | 'modifier_groups' | 'menu_schedules'

function useMenuQuery<T>(resource: MenuResource, enabled: boolean) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'menu-admin', resource),
    enabled,
    queryFn: async () => (await posRequest<{ data: T[] }>('GET', `/pos/${resource}`)).data,
  })
}

export const useMenuCategories = (enabled: boolean) =>
  useMenuQuery<PosMenuCategory>('menu_categories', enabled)
// Tax categories new items start with (chosen in the F&B setup step): ids, or
// null when the store never chose one.
export type MenuTaxDefaults = { food: string | null; alcohol: string | null }

type MenuItemsBody = { data: MenuItemConfig[]; meta?: { tax_defaults?: MenuTaxDefaults } }

// Items and the tax defaults come in one answer; both hooks share it.
function useMenuItemsBody<T>(enabled: boolean, select: (body: MenuItemsBody) => T) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'menu-admin', 'menu_items'),
    enabled,
    queryFn: () => posRequest<MenuItemsBody>('GET', '/pos/menu_items'),
    select,
  })
}

export const useMenuItems = (enabled: boolean) => useMenuItemsBody(enabled, (body) => body.data)
export const useMenuTaxDefaults = (enabled: boolean) =>
  useMenuItemsBody(
    enabled,
    (body): MenuTaxDefaults => body.meta?.tax_defaults ?? { food: null, alcohol: null },
  )
export const useModifierGroups = (enabled: boolean) =>
  useMenuQuery<PosMenuModifierGroup>('modifier_groups', enabled)
export const useMenuSchedules = (enabled: boolean) =>
  useMenuQuery<MenuSchedule>('menu_schedules', enabled)

// What the counter of a branch sells from now, with today's sold-out marks.
export function useBranchMenu(branchId: string | null) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'menu-admin', 'branch', branchId),
    enabled: Boolean(branchId),
    queryFn: async () =>
      (
        await posRequest<{ data: PosMenu }>('GET', '/pos/menu', {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  })
}

// One menu command. Every write is audited under its own idempotency key;
// refusals reach the caller untouched so 409 reasons and 422 fields stay readable.
export function useMenuWrite() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest<{ data?: unknown }>(method, path, {
        body: body ?? {},
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}
