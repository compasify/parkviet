import { parseVndInput } from '@parkviet/pos-shared/money'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'

// A rest stop's coach commission set-up: the bus operators (nhà xe), the
// branch's rules (an amount per coach type and per guest, minimums and dates,
// general or for one operator) and how long a visit stays open. The commission
// is the stop's expense, worked out on the server when a visit closes.

export const VEHICLE_COMMISSION_MODULE = 'fnb.vehicle_commission'
export const VEHICLE_TYPES = ['seat_16', 'seat_29', 'seat_45', 'other'] as const
export type VehicleType = (typeof VEHICLE_TYPES)[number]
export type SetupStatus = 'active' | 'archived'

export type BusOperator = {
  id: string
  name: string
  phone: string | null
  note: string | null
  status: SetupStatus
  updated_at: string | null
}

export type CommissionRule = {
  id: string
  name: string
  bus_operator: { id: string; name: string } | null
  per_vehicle_amounts: Record<VehicleType, string>
  per_guest_amount: string
  min_guests: number
  min_revenue: string
  starts_on: string | null
  ends_on: string | null
  status: SetupStatus
  revision: number
  updated_at: string | null
}

export type VisitSettings = { branch_id: string; visit_window_minutes: number }

export type RuleDraft = {
  name: string
  busOperatorId: string
  amounts: Record<VehicleType, string>
  perGuest: string
  minGuests: string
  minRevenue: string
  startsOn: string
  endsOn: string
}

const whole = (value: string) => String(Math.round(Number(value) || 0))

export function ruleDraft(rule?: CommissionRule): RuleDraft {
  return {
    name: rule?.name ?? '',
    busOperatorId: rule?.bus_operator?.id ?? '',
    amounts: Object.fromEntries(
      VEHICLE_TYPES.map((type) => {
        const amount = rule?.per_vehicle_amounts?.[type]
        return [type, amount && Number(amount) > 0 ? whole(amount) : '']
      }),
    ) as Record<VehicleType, string>,
    perGuest: rule && Number(rule.per_guest_amount) > 0 ? whole(rule.per_guest_amount) : '',
    minGuests: rule && rule.min_guests > 0 ? String(rule.min_guests) : '',
    minRevenue: rule && Number(rule.min_revenue) > 0 ? whole(rule.min_revenue) : '',
    startsOn: rule?.starts_on ?? '',
    endsOn: rule?.ends_on ?? '',
  }
}

// The request body of a rule, or the first field that cannot be sent. Blank
// amounts are zero; something must be paid, per coach or per guest.
export function ruleBody(
  draft: RuleDraft,
): { body: Record<string, unknown> } | { invalid: 'name' | 'amount' | 'nothing' | 'dates' } {
  if (!draft.name.trim()) return { invalid: 'name' }
  const money = (text: string) => (text.trim() === '' ? '0' : parseVndInput(text))
  const amounts: Record<string, string> = {}
  for (const type of VEHICLE_TYPES) {
    const value = money(draft.amounts[type])
    if (value === null) return { invalid: 'amount' }
    amounts[type] = value
  }
  const perGuest = money(draft.perGuest)
  const minRevenue = money(draft.minRevenue)
  const minGuests = draft.minGuests.trim() === '' ? 0 : Number(draft.minGuests)
  if (perGuest === null || minRevenue === null || !Number.isInteger(minGuests) || minGuests < 0)
    return { invalid: 'amount' }
  if ([...Object.values(amounts), perGuest].every((value) => Number(value) === 0))
    return { invalid: 'nothing' }
  if (draft.startsOn && draft.endsOn && draft.endsOn < draft.startsOn) return { invalid: 'dates' }
  return {
    body: {
      name: draft.name.trim(),
      bus_operator_id: draft.busOperatorId || '',
      per_vehicle_amounts: amounts,
      per_guest_amount: perGuest,
      min_guests: minGuests,
      min_revenue: minRevenue,
      starts_on: draft.startsOn || '',
      ends_on: draft.endsOn || '',
    },
  }
}

const REFUSALS = [
  'bus_operator_taken',
  'bus_operator_invalid',
  'bus_operator_archived',
  'commission_rule_invalid',
  'vehicle_type_invalid',
  'vehicle_visit_window_invalid',
] as const

type Translate = (key: string, options?: Record<string, unknown>) => string

export function describeVehicleFailure(error: unknown, t: Translate): string {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`vehicleCommission.failure_${reason}`)
    : describeFailure(error, t)
}
