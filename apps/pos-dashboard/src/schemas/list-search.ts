import { resourceSearchSchema } from '@spree/dashboard-core'
import { z } from 'zod'
import { ORDER_STATUSES } from '../hooks/use-orders'

const id = z.string().max(64).optional().catch(undefined)

// Single-choice filters of the order history, kept in the URL beside the
// table's own search, date filter and page.
export const orderSearchSchema = resourceSearchSchema.extend({
  status: z.enum(ORDER_STATUSES).optional().catch(undefined),
  registerId: id,
  cashierId: id,
})
export type OrderSearch = z.infer<typeof orderSearchSchema>

export const deliverySearchSchema = resourceSearchSchema.extend({
  status: z.enum(['pending', 'delivered']).optional().catch(undefined),
})
export type DeliverySearch = z.infer<typeof deliverySearchSchema>
