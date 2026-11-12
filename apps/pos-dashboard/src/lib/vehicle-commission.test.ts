import { describe, expect, it } from 'vitest'
import { describeVehicleFailure, ruleBody, ruleDraft } from './vehicle-commission'

const t = (key: string) => key

describe('coach commission set-up', () => {
  it('sends a rule with blank amounts as zero and numbers as typed', () => {
    const draft = {
      ...ruleDraft(),
      name: ' Chung ',
      amounts: { seat_16: '', seat_29: '100.000', seat_45: '150000', other: '' },
      perGuest: '5.000',
      minGuests: '10',
    }
    expect(ruleBody(draft)).toEqual({
      body: {
        name: 'Chung',
        bus_operator_id: '',
        per_vehicle_amounts: { seat_16: '0', seat_29: '100000', seat_45: '150000', other: '0' },
        per_guest_amount: '5000',
        min_guests: 10,
        min_revenue: '0',
        starts_on: '',
        ends_on: '',
      },
    })
  })

  it('refuses a rule without a name, paying nothing, with a bad amount or reversed dates', () => {
    const base = { ...ruleDraft(), name: 'A', perGuest: '1000' }
    expect(ruleBody({ ...base, name: ' ' })).toEqual({ invalid: 'name' })
    expect(ruleBody({ ...base, perGuest: '' })).toEqual({ invalid: 'nothing' })
    expect(ruleBody({ ...base, perGuest: '1,5' })).toEqual({ invalid: 'amount' })
    expect(ruleBody({ ...base, startsOn: '2026-11-12', endsOn: '2026-11-01' })).toEqual({
      invalid: 'dates',
    })
  })

  it('reads a saved rule back into the form', () => {
    const draft = ruleDraft({
      id: 'r',
      name: 'Phương Trang',
      bus_operator: { id: 'op', name: 'Phương Trang' },
      per_vehicle_amounts: { seat_16: '0.0', seat_29: '100000.0', seat_45: '0.0', other: '0.0' },
      per_guest_amount: '0.0',
      min_guests: 0,
      min_revenue: '500000.0',
      starts_on: '2026-11-01',
      ends_on: null,
      status: 'active',
      revision: 2,
      updated_at: null,
    })
    expect(draft).toMatchObject({
      busOperatorId: 'op',
      amounts: { seat_16: '', seat_29: '100000', seat_45: '', other: '' },
      perGuest: '',
      minRevenue: '500000',
      startsOn: '2026-11-01',
      endsOn: '',
    })
  })

  it('names the refusals of the set-up', () => {
    const conflict = { status: 409, details: { reason: 'bus_operator_taken' } }
    expect(describeVehicleFailure(conflict, t)).toBe('vehicleCommission.failure_bus_operator_taken')
  })
})
