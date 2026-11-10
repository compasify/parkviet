import { parseVndInput } from '@parkviet/pos-shared/money'
import { z } from 'zod'

const nullableDigits = (max: number, message: string) =>
  z
    .string()
    .trim()
    .refine((value) => value === '' || (/^\d+$/.test(value) && Number(value) <= max), message)
export const branchSchema = z.object({
  name: z.string().trim().min(1, 'invalid').max(100, 'invalid'),
  code: z
    .string()
    .trim()
    .regex(/^[a-z0-9][a-z0-9_-]{0,31}$/, 'adminCodeHint'),
  timezone: z.string().trim().min(1, 'invalid').max(64, 'invalid'),
  business_day_cutoff: z
    .string()
    .trim()
    .regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'businessDayCutoffInvalid'),
  stock_location_id: z.string().min(1, 'adminChooseWarehouse'),
  receiving_stock_location_id: z.string(),
  receiving_note: z.string().trim().max(200, 'invalid'),
  return_window_days: nullableDigits(3650, 'adminReturnWindowInvalid'),
  adjustment_approval_threshold: z
    .string()
    .trim()
    .refine((v) => v === '' || /^\d{1,9}$/.test(v), 'adminAdjustmentThresholdInvalid'),
  variance_threshold: z
    .string()
    .trim()
    .refine(
      (v) => v === '' || parseVndInput(v.replace(/\.0+$/, '')) !== null,
      'adminVarianceThresholdInvalid',
    ),
  lot_selection: z.enum(['fefo', 'cashier_pick']),
  profile_key: z.string(),
})
export type BranchFormValues = z.infer<typeof branchSchema>
export function branchBody(value: BranchFormValues, create: boolean) {
  return {
    ...value,
    receiving_stock_location_id: value.receiving_stock_location_id || null,
    receiving_note: value.receiving_note || null,
    return_window_days: value.return_window_days === '' ? null : Number(value.return_window_days),
    adjustment_approval_threshold:
      value.adjustment_approval_threshold === ''
        ? null
        : Number(value.adjustment_approval_threshold),
    variance_threshold:
      value.variance_threshold === ''
        ? null
        : parseVndInput(value.variance_threshold.replace(/\.0+$/, '')),
    profile_key: create && value.profile_key ? value.profile_key : undefined,
  }
}
