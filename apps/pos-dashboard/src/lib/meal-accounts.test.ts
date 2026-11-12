import { describe, expect, it } from 'vitest'
import {
  describeMealFailure,
  importProblems,
  parseMealWindows,
  refusedField,
  statementPeriod,
  validEmployeeCode,
  wholeNumber,
  windowDraft,
} from './meal-accounts'

const conflict = (details: Record<string, unknown>, message = 'Refused.') => ({
  status: 409,
  message,
  details,
})

describe('meal account form checks', () => {
  it('reads blank as no value and refuses numbers out of range', () => {
    expect(wholeNumber('', 0, 20)).toBeNull()
    expect(wholeNumber(' 3 ', 0, 20)).toBe(3)
    expect(wholeNumber('21', 0, 20)).toBeUndefined()
    expect(wholeNumber('2.5', 0, 20)).toBeUndefined()
    expect(wholeNumber('-1', 0, 20)).toBeUndefined()
  })

  it('accepts employee codes the server can store', () => {
    expect(validEmployeeCode('nv-001')).toBe(true)
    expect(validEmployeeCode('A.B_C')).toBe(true)
    expect(validEmployeeCode('')).toBe(false)
    expect(validEmployeeCode('-001')).toBe(false)
    expect(validEmployeeCode('NV 001')).toBe(false)
  })

  it('sends meal times with a limit only when one is given, past midnight allowed', () => {
    expect(
      parseMealWindows([
        { key: 'lunch', from: '11:00', to: '13:30', limit: '1' },
        { key: 'night', from: '22:00', to: '02:00', limit: '' },
      ]),
    ).toEqual([
      { key: 'lunch', from: '11:00', to: '13:30', limit: 1 },
      { key: 'night', from: '22:00', to: '02:00' },
    ])
    expect(parseMealWindows([])).toEqual([])
    expect(windowDraft({ key: 'lunch', from: '11:00', to: '13:00', limit: 2 })).toEqual({
      key: 'lunch',
      from: '11:00',
      to: '13:00',
      limit: '2',
    })
  })

  it('refuses invalid, repeated or too many meal times', () => {
    const row = { key: 'lunch', from: '11:00', to: '13:00', limit: '' }
    expect(parseMealWindows([{ ...row, key: 'Lunch' }])).toBeNull()
    expect(parseMealWindows([{ ...row, to: '11:00' }])).toBeNull()
    expect(parseMealWindows([{ ...row, from: '25:00' }])).toBeNull()
    expect(parseMealWindows([{ ...row, limit: '21' }])).toBeNull()
    expect(parseMealWindows([row, row])).toBeNull()
    expect(
      parseMealWindows(Array.from({ length: 7 }, (_, index) => ({ ...row, key: `m${index}` }))),
    ).toBeNull()
  })
})

describe('sponsor statement period', () => {
  it('is the last closed cycle, still open on the statement day itself', () => {
    expect(statementPeriod(25, '2026-11-12')).toEqual({ from: '2026-09-26', to: '2026-10-25' })
    expect(statementPeriod(25, '2026-11-25')).toEqual({ from: '2026-09-26', to: '2026-10-25' })
    expect(statementPeriod(25, '2026-11-26')).toEqual({ from: '2026-10-26', to: '2026-11-25' })
  })

  it('rolls over the year and keeps February whole', () => {
    expect(statementPeriod(5, '2026-01-03')).toEqual({ from: '2025-11-06', to: '2025-12-05' })
    expect(statementPeriod(28, '2026-03-01')).toEqual({ from: '2026-01-29', to: '2026-02-28' })
  })
})

describe('meal command refusals', () => {
  const t = (key: string, options?: Record<string, unknown>) =>
    options ? `${key}:${JSON.stringify(options)}` : key

  it('names the refused field of an account or sponsor', () => {
    const account = conflict({ reason: 'meal_account_invalid', field: 'phone' })
    const sponsor = conflict({ reason: 'meal_sponsor_invalid', field: 'statement_day' })
    expect(refusedField(account)).toBe('phone')
    expect(refusedField(sponsor)).toBe('statement_day')
    expect(refusedField(conflict({ reason: 'module_disabled', field: 'phone' }))).toBeNull()
    expect(refusedField({ status: 422, details: { reason: 'meal_account_invalid' } })).toBeNull()
    expect(describeMealFailure(account, t)).toContain('mealAccounts.fieldProblem')
    expect(describeMealFailure(account, t)).toContain('Refused.')
  })

  it('lists the refused rows of an import', () => {
    const failure = conflict({
      reason: 'meal_import_invalid',
      errors: [
        { line: 3, field: 'sponsor', message: 'No sponsor has this name.' },
        { line: 4, message: 'Bad row.' },
        { line: 5 },
        'junk',
      ],
    })
    expect(importProblems(failure)).toEqual([
      { line: 3, field: 'sponsor', message: 'No sponsor has this name.' },
      { line: 4, field: null, message: 'Bad row.' },
    ])
    expect(importProblems(conflict({ reason: 'meal_import_invalid' }))).toEqual([])
    expect(importProblems(conflict({ reason: 'meal_account_invalid', errors: [] }))).toEqual([])
  })
})
