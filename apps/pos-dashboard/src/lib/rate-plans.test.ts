import { describe, expect, it } from 'vitest'
import en from '../locales/en.json'
import vi from '../locales/vi.json'
import {
  clockToMinutes,
  coverageProblems,
  minutesToClock,
  packagesInput,
  RATE_PLAN_REFUSALS,
  ratePlanFailure,
  windowsInput,
} from './rate-plans'

const band = (day_type: 'weekday' | 'weekend' | 'holiday', start: number, end: number) => ({
  day_type,
  start_minute: start,
  end_minute: end,
})

describe('rate plans', () => {
  it('reads and writes times of day', () => {
    expect(clockToMinutes('18:00')).toBe(1080)
    expect(clockToMinutes('24:00')).toBe(1440)
    expect(clockToMinutes('9:30')).toBe(570)
    expect(clockToMinutes('24:30')).toBeNull()
    expect(clockToMinutes('18:75')).toBeNull()
    expect(clockToMinutes('six')).toBeNull()
    expect(minutesToClock(1080)).toBe('18:00')
    expect(minutesToClock(1440)).toBe('24:00')
  })

  it('finds the kinds of day the server would refuse', () => {
    const week = [band('weekday', 0, 1080), band('weekday', 1080, 1440), band('weekend', 0, 1440)]
    expect(coverageProblems(week)).toEqual([])
    // A band past midnight closes the day with the one before it.
    expect(
      coverageProblems([
        band('weekday', 600, 1320),
        band('weekday', 1320, 600),
        band('weekend', 0, 1440),
      ]),
    ).toEqual([])
    expect(coverageProblems([band('weekday', 0, 1080), band('weekend', 0, 1440)])).toEqual([
      'weekday',
    ])
    expect(coverageProblems([...week, band('weekend', 1000, 1100)])).toEqual(['weekend'])
    expect(coverageProblems([band('weekday', 0, 1440)])).toEqual(['weekend'])
    expect(coverageProblems([...week, band('holiday', 0, 600)])).toEqual(['holiday'])
  })

  it('words every refusal in both languages', () => {
    const t = (key: string) => key
    expect(ratePlanFailure({ details: { reason: 'rate_plan_duplicate' }, status: 409 }, t)).toBe(
      'ratePlans.failure_rate_plan_duplicate',
    )
    for (const reason of RATE_PLAN_REFUSALS)
      for (const bundle of [vi, en])
        expect((bundle.ratePlans as Record<string, unknown>)[`failure_${reason}`]).toEqual(
          expect.any(String),
        )
  })
})

describe('operating windows and packages', () => {
  it('takes windows of the week, overnight ones too', () => {
    expect(windowsInput([{ days: [5, 1, 5], from: '08:00', to: '24:00' }])).toEqual([
      { days: [1, 5], from: '08:00', to: '24:00' },
    ])
    expect(windowsInput([{ days: [6], from: '18:00', to: '02:00' }])).not.toBeNull()
    expect(windowsInput([])).toEqual([])
  })

  it('refuses windows the server refuses', () => {
    expect(windowsInput([{ days: [], from: '08:00', to: '12:00' }])).toBeNull()
    expect(windowsInput([{ days: [1], from: '24:00', to: '02:00' }])).toBeNull()
    expect(windowsInput([{ days: [1], from: '08:00', to: '08:00' }])).toBeNull()
    expect(windowsInput([{ days: [7], from: '08:00', to: '09:00' }])).toBeNull()
    expect(windowsInput([{ days: [1], from: '8:00', to: '09:00' }])).toBeNull()
  })

  it('takes packages with a unique code, minutes and a price', () => {
    expect(
      packagesInput([{ code: ' Goi2H ', name: 'Gói 2 giờ', minutes: '120', price: '250000' }]),
    ).toEqual([{ code: 'goi2h', name: 'Gói 2 giờ', minutes: 120, price: '250000' }])
    const row = { code: 'goi', name: 'Gói', minutes: '60', price: '100000' }
    expect(packagesInput([row, row])).toBeNull()
    expect(packagesInput([{ ...row, minutes: '0' }])).toBeNull()
    expect(packagesInput([{ ...row, price: 'free' }])).toBeNull()
    expect(packagesInput([{ ...row, code: '-x' }])).toBeNull()
    expect(packagesInput([{ ...row, name: ' ' }])).toBeNull()
  })
})
