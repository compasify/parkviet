import { describe, expect, it } from 'vitest';
import {
  minutesLeft,
  normalizeVehicleVisit,
  normalizeVehicleVisits,
  vehicleReasonKey,
  visitActions,
} from './vehicle-visits';

const base = {
  id: 'posvisit_1',
  plate: '51B12345',
  vehicle_type: 'seat_29',
  bus_operator: { id: 'posbusop_1', name: 'Phương Trang' },
  driver_name: 'Anh Tư',
  driver_phone: '••••••3456',
  guest_count: 20,
  arrived_at: '2026-11-12T05:00:00Z',
  closes_at: '2026-11-12T06:00:00Z',
  status: 'closed',
  business_date: '2026-11-12',
  revenue_amount: '360000.0',
  commission_amount: '200000.0',
  currency: 'VND',
  commission: {
    amount: '200000.0',
    vehicle_amount: '100000.0',
    guest_amount: '100000.0',
    qualified: true,
    reason: null,
    rule: { name: 'Chung' },
  },
  revision: 2,
  workspaces_count: 3,
};

describe('coach visits', () => {
  it('reads a visit and drops rows it cannot read', () => {
    const visit = normalizeVehicleVisit(base);
    expect(visit).toMatchObject({
      plate: '51B12345',
      vehicle_type: 'seat_29',
      bus_operator: { name: 'Phương Trang' },
      commission: { amount: '200000.0', rule_name: 'Chung', qualified: true },
      payout_status: null,
      warnings: [],
    });
    expect(normalizeVehicleVisit({ ...base, vehicle_type: 'seat_99' })?.vehicle_type).toBe('other');
    expect(normalizeVehicleVisits([base, { id: 'x' }, null])).toHaveLength(1);
  });

  it('counts the minutes left of an open visit', () => {
    const now = Date.parse('2026-11-12T05:30:30Z');
    expect(minutesLeft({ closes_at: '2026-11-12T06:00:00Z' }, now)).toBe(30);
    expect(minutesLeft({ closes_at: '2026-11-12T05:00:00Z' }, now)).toBe(0);
    expect(minutesLeft({ closes_at: '' }, now)).toBe(0);
  });

  it('offers paying, correcting and voiding only to managers, by state', () => {
    const closed = normalizeVehicleVisit(base);
    if (!closed) throw new Error('visit');
    expect(visitActions(closed, true)).toEqual({
      edit: false,
      close: false,
      pay: true,
      adjust: true,
      void: true,
    });
    expect(visitActions(closed, false)).toMatchObject({ pay: false, adjust: false, void: false });
    const zero = { ...closed, commission_amount: '0.0' };
    expect(visitActions(zero, true).pay).toBe(false);
    const requested = { ...closed, status: 'paid' as const, payout_status: 'requested' as const };
    expect(visitActions(requested, true)).toMatchObject({ pay: false, adjust: false, void: false });
    const canceled = { ...requested, payout_status: 'canceled' as const };
    expect(visitActions(canceled, true).pay).toBe(true);
    const open = { ...closed, status: 'open' as const };
    expect(visitActions(open, false)).toMatchObject({ edit: true, close: true });
  });

  it('names server refusals', () => {
    expect(vehicleReasonKey('vehicle_visit_paid')).toBe('vehicleReason_paid');
    expect(vehicleReasonKey('something_else')).toBeNull();
    expect(vehicleReasonKey(null)).toBeNull();
  });
});
