import { describe, expect, it } from 'vitest'
import { paymentMethodBody, paymentMethodSchema, unitBody, unitSchema } from './master-data'

describe('payment method form', () => {
  it('sends kind and code only on create and leaves blanks to the server', () => {
    const value = paymentMethodSchema.parse({
      kind: 'bank_manual',
      name: ' Chuyển khoản ',
      code: '',
      position: '',
    })
    expect(paymentMethodBody(value, true)).toEqual({ kind: 'bank_manual', name: 'Chuyển khoản' })
    expect(paymentMethodBody({ ...value, code: 'ck', position: '3' }, false)).toEqual({
      name: 'Chuyển khoản',
      position: 3,
    })
  })
  it('refuses codes and positions the server would reject', () => {
    const base = { kind: 'cash', name: 'Tiền mặt', code: '', position: '' }
    expect(paymentMethodSchema.safeParse({ ...base, code: 'Tiền' }).success).toBe(false)
    expect(paymentMethodSchema.safeParse({ ...base, position: '10001' }).success).toBe(false)
    expect(paymentMethodSchema.safeParse({ ...base, kind: 'card' }).success).toBe(false)
  })
})

describe('unit form', () => {
  const base = {
    code: 'hop',
    name: 'Hộp',
    dimension: 'count',
    base_code: '',
    factor_to_base: '1',
    sale_precision: '0',
  }
  it('makes a unit without a base canonical', () => {
    expect(unitBody(unitSchema.parse(base), true)).toEqual({
      code: 'hop',
      name: 'Hộp',
      dimension: 'count',
      base_code: 'hop',
      factor_to_base: 1,
      sale_precision: 0,
    })
    expect(unitSchema.safeParse({ ...base, factor_to_base: '6' }).success).toBe(false)
  })
  it('converts to a base unit and edits only name and precision', () => {
    const value = unitSchema.parse({ ...base, base_code: 'chai', factor_to_base: '24' })
    expect(unitBody(value, true)).toMatchObject({ base_code: 'chai', factor_to_base: 24 })
    expect(unitBody(value, false)).toEqual({ name: 'Hộp', sale_precision: 0 })
    expect(unitSchema.safeParse({ ...base, code: '1hop' }).success).toBe(false)
  })
})
