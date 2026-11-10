import { z } from 'zod'

const position = z
  .string()
  .trim()
  .refine(
    (v) => v === '' || (/^\d{1,5}$/.test(v) && Number(v) <= 10_000),
    'paymentMethods.positionInvalid',
  )
export const paymentMethodSchema = z.object({
  kind: z.enum(['cash', 'bank_manual', 'vietqr']),
  name: z.string().trim().min(1, 'invalid').max(120, 'invalid'),
  code: z
    .string()
    .trim()
    .refine((v) => v === '' || /^[a-z0-9][a-z0-9_]{0,31}$/.test(v), 'paymentMethods.codeHint'),
  position,
})
export type PaymentMethodFormValues = z.infer<typeof paymentMethodSchema>
// Kind and code are fixed once created; a blank code or position lets the
// server choose.
export function paymentMethodBody(value: PaymentMethodFormValues, create: boolean) {
  return {
    ...(create ? { kind: value.kind, ...(value.code ? { code: value.code } : {}) } : {}),
    name: value.name,
    ...(value.position ? { position: Number(value.position) } : {}),
  }
}

export const unitSchema = z
  .object({
    code: z
      .string()
      .trim()
      .regex(/^[a-z][a-z0-9_]{0,15}$/, 'units.codeHint'),
    name: z.string().trim().min(1, 'invalid').max(64, 'invalid'),
    dimension: z.enum(['mass', 'volume', 'count']),
    base_code: z.string(),
    factor_to_base: z
      .string()
      .trim()
      .refine(
        (v) => /^\d{1,7}$/.test(v) && Number(v) >= 1 && Number(v) <= 1_000_000,
        'units.factorInvalid',
      ),
    sale_precision: z.enum(['0', '1', '2', '3']),
  })
  // A unit is canonical (its own base, factor 1) or converts to a canonical unit.
  .refine((v) => v.base_code !== '' || v.factor_to_base === '1', {
    path: ['factor_to_base'],
    message: 'units.canonicalFactor',
  })
export type UnitFormValues = z.infer<typeof unitSchema>
// A blank base makes the unit the canonical unit of its dimension.
export function unitBody(value: UnitFormValues, create: boolean) {
  return create
    ? {
        code: value.code,
        name: value.name,
        dimension: value.dimension,
        base_code: value.base_code || value.code,
        factor_to_base: value.base_code ? Number(value.factor_to_base) : 1,
        sale_precision: Number(value.sale_precision),
      }
    : { name: value.name, sale_precision: Number(value.sale_precision) }
}

export const staffRoleSchema = z.object({
  name: z.string().trim().min(1, 'invalid').max(80, 'invalid'),
  capabilities: z.array(z.string()),
})
export type StaffRoleFormValues = z.infer<typeof staffRoleSchema>
