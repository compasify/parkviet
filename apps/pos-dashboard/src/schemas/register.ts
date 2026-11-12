import { z } from 'zod'
export const registerSchema = z.object({
  name: z.string().trim().min(1, 'invalid').max(100, 'invalid'),
  code: z
    .string()
    .trim()
    .regex(/^[a-z0-9][a-z0-9_-]{0,31}$/, 'adminCodeHint'),
  branch_id: z.string().min(1, 'chooseBranch'),
  // A counter is worked by cashiers; a kiosk only by its self-ordering device.
  kind: z.enum(['counter', 'kiosk']).default('counter'),
})
export type RegisterFormValues = z.infer<typeof registerSchema>
