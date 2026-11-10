import { ORDER_SOURCES } from '@parkviet/pos-shared/order-source'
import { resourceSearchSchema } from '@spree/dashboard-core'
import { z } from 'zod'

const id = z.string().max(64).optional().catch(undefined)
const day = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/)
  .optional()
  .catch(undefined)

// Report filters kept in the URL beside the table's page. The day range,
// register, shift and "mine" carry over between report tabs; the rest belong
// to one report and reset when another is opened.
export const reportSearchSchema = resourceSearchSchema.extend({
  from: day,
  to: day,
  registerId: id,
  shiftId: id,
  mine: z.boolean().optional().catch(undefined),
  section: z.enum(['returns']).optional().catch(undefined),
  orderSource: z.enum(ORDER_SOURCES).optional().catch(undefined),
  kind: z.enum(['cash', 'bank_manual']).optional().catch(undefined),
  source: z.enum(['sale', 'collection', 'unsolicited']).optional().catch(undefined),
  status: z.enum(['overdue', 'settled', 'all']).optional().catch(undefined),
  shiftPage: z.coerce.number().int().min(1).optional().catch(undefined),
})
export type ReportSearch = z.infer<typeof reportSearchSchema>
