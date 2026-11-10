import { resourceSearchSchema } from '@spree/dashboard-core'
import { z } from 'zod'

export const INVENTORY_TABS = [
  'variants',
  'lots',
  'serials',
  'receive',
  'transfer',
  'adjust',
  'recall',
] as const

export const LOT_STATUSES = ['active', 'quarantined', 'expired'] as const

// The lot list's single status filter, kept in the URL beside the table's
// own search and page.
export const inventorySearchSchema = resourceSearchSchema.extend({
  status: z.enum(LOT_STATUSES).optional().catch(undefined),
})
export type InventorySearch = z.infer<typeof inventorySearchSchema>
