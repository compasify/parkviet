import { z } from 'zod'
export const membershipSchema = z.object({
  branch_id: z.string().min(1, 'chooseBranch'),
  staff_id: z.string().min(1, 'adminChooseStaff'),
  capabilities: z.array(z.string()),
})
export type MembershipFormValues = z.infer<typeof membershipSchema>
