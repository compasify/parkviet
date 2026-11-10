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

// The received funds open in the detail sheet, so a shift-close checklist
// or a shared link can point at one record.
export const fundsSearchSchema = resourceSearchSchema.extend({ fundsId: id })
export type FundsSearch = z.infer<typeof fundsSearchSchema>

// The closed shift whose snapshot is open beside the closure history.
export const closureSearchSchema = resourceSearchSchema.extend({ shiftId: id })
export type ClosureSearch = z.infer<typeof closureSearchSchema>
