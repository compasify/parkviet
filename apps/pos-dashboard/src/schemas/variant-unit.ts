import { z } from 'zod'
export function unitRatio(input: string): number | null {
  if (!/^\d{1,7}$/.test(input.trim())) return null
  const value = Number(input.trim())
  return value >= 1 && value <= 1_000_000 ? value : null
}
export const variantUnitSchema = z.object({
  sale_unit: z.string().min(1, 'invalid'),
  price_unit: z.string().min(1, 'invalid'),
  ratio_numerator: z.string().refine((v) => unitRatio(v) !== null, 'variantUnitRatioInvalid'),
  ratio_denominator: z.string().refine((v) => unitRatio(v) !== null, 'variantUnitRatioInvalid'),
  tracked_mode: z.enum(['none', 'lot', 'serial']),
  label_code: z
    .string()
    .trim()
    .regex(/^\d{0,8}$/, 'variantUnitLabelCodeInvalid'),
})
export type VariantUnitFormValues = z.infer<typeof variantUnitSchema>
