import { labelFormatProblems } from '@parkviet/pos-shared/label-format'
import { z } from 'zod'
export const labelFormatSchema = z
  .object({
    name: z.string(),
    prefix: z.string(),
    kind: z.enum(['weight', 'price']),
    item_code_length: z.string(),
    value_length: z.string(),
    value_decimals: z.string(),
    value_unit_code: z.string(),
    price_tolerance: z.string(),
  })
  .superRefine((draft, ctx) => {
    const fields = {
      name: 'name',
      prefix: 'prefix',
      itemCodeLength: 'item_code_length',
      valueLength: 'value_length',
      decimals: 'value_decimals',
      layout: 'prefix',
      unit: 'value_unit_code',
      tolerance: 'price_tolerance',
    }
    for (const problem of labelFormatProblems(draft))
      ctx.addIssue({
        code: 'custom',
        path: [fields[problem]],
        message: `labelFormatProblem_${problem}`,
      })
  })
export type LabelFormatFormValues = z.infer<typeof labelFormatSchema>
