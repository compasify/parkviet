import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'

// The prices of play time at a branch: one plan per kind of room, its time
// bands per kind of day, a new version once a clock was priced on it. The
// server checks everything again; these helpers only spare a round trip.

export const DAY_TYPES = ['weekday', 'weekend', 'holiday'] as const
export type DayType = (typeof DAY_TYPES)[number]
export const DAY_MINUTES = 1440

export type RateRule = {
  id?: string
  day_type: DayType
  start_minute: number
  end_minute: number
  price_per_hour: string
  label: string | null
}

export type RatePlan = {
  id: string
  name: string
  resource_type_code: string
  variant_id: string
  variant_name: string | null
  block_minutes: number
  grace_minutes: number
  minimum_minutes: number
  status: 'active' | 'archived'
  version: number
  rules: RateRule[]
}

export type SpecialDay = {
  id: string
  date: string
  name: string
  holiday_surcharge_percent: string | null
}

export type RatePreview = {
  currency?: string
  played_minutes: number
  billed_minutes: number
  amount: string
  lines: Array<{
    starts_at: string
    label: string | null
    minutes: number
    price_per_hour: string
    amount: string
  }>
}

// "18:00" from 1080; "24:00" for the end of the day.
export function minutesToClock(minutes: number): string {
  const hours = Math.floor(minutes / 60)
  return `${String(hours).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`
}

// Minutes of the day from "HH:MM" ("24:00" is the end of the day); null when unreadable.
export function clockToMinutes(value: string): number | null {
  const match = /^(\d{1,2}):(\d{2})$/.exec(value.trim())
  if (!match) return null
  const minutes = Number(match[1]) * 60 + Number(match[2])
  return Number(match[2]) < 60 && minutes >= 0 && minutes <= DAY_MINUTES ? minutes : null
}

// The minutes a band covers; a band ending before it starts runs past midnight.
function bandMinutes(rule: Pick<RateRule, 'start_minute' | 'end_minute'>): number[] {
  const { start_minute: start, end_minute: end } = rule
  if (start === end) return []
  const span = end > start ? end - start : DAY_MINUTES - start + end
  return Array.from({ length: span }, (_, index) => (start + index) % DAY_MINUTES)
}

// Kinds of day whose bands leave hours unpriced or price them twice, as the
// server refuses them. Weekdays and weekends must always be priced; holidays
// without bands are priced as weekends plus the holiday's surcharge.
export function coverageProblems(
  rules: Array<Pick<RateRule, 'day_type' | 'start_minute' | 'end_minute'>>,
): DayType[] {
  return DAY_TYPES.filter((dayType) => {
    const own = rules.filter((rule) => rule.day_type === dayType)
    if (own.length === 0) return dayType !== 'holiday'
    const counts = new Array<number>(DAY_MINUTES).fill(0)
    for (const rule of own) for (const minute of bandMinutes(rule)) counts[minute] += 1
    return counts.some((count) => count !== 1)
  })
}

export const RATE_PLAN_REFUSALS = [
  'rate_plan_invalid',
  'rate_plan_duplicate',
  'rate_plan_archived',
  'variant_unavailable',
  'special_day_duplicate',
  'special_day_invalid',
  'weekend_days_invalid',
  'module_disabled',
  'time_invalid',
] as const

type T = (key: string, options?: Record<string, unknown>) => string

export function ratePlanFailure(error: unknown, t: T): string {
  const reason = conflictReason(error)
  return reason && (RATE_PLAN_REFUSALS as readonly string[]).includes(reason)
    ? t(`ratePlans.failure_${reason}`)
    : describeFailure(error, t)
}
