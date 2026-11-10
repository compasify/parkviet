import { z } from 'zod'
export const membershipSchema = z.object({
  branch_id: z.string().min(1, 'chooseBranch'),
  staff_id: z.string().min(1, 'adminChooseStaff'),
  capabilities: z.array(z.string()),
  staff_role_id: z
    .string()
    .optional()
    .transform((value) => value || null),
})
export type MembershipFormValues = z.infer<typeof membershipSchema>
