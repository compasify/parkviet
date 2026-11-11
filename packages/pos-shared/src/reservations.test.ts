import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import {
  DEPOSIT_STATUSES,
  depositStatusKey,
  normalizeAvailableTables,
  normalizeReservation,
  normalizeReservations,
  RESERVATION_STATUSES,
  reservationActions,
  reservationStatusKey,
  timelineSpan,
} from './reservations';

const booking = {
  id: 'posresv_1',
  branch_id: 'posbranch_1',
  status: 'booked',
  source: 'phone',
  guest_name: 'Chị Lan',
  phone: '0901',
  party_size: 4,
  note: null,
  starts_at: '2026-11-12T12:00:00Z',
  ends_at: '2026-11-12T14:00:00Z',
  revision: 1,
  workspace_id: null,
  resources: [{ id: 'posres_1', name: 'Bàn 5', kind: 'table', area_id: null }],
  deposits: [
    {
      id: 'posdeposit_1',
      kind: 'cash',
      amount: '200000.0',
      currency: 'VND',
      status: 'held',
      available: '200000.0',
    },
  ],
  deposit_held: '200000.0',
};

describe('reservations', () => {
  it('reads a booking tolerantly and orders the day', () => {
    const later = { ...booking, id: 'posresv_2', starts_at: '2026-11-12T13:00:00Z' };
    const rows = normalizeReservations([later, booking, { id: 'broken' }]);
    expect(rows.map((row) => row.id)).toEqual(['posresv_1', 'posresv_2']);
    expect(rows[0]?.deposits[0]).toMatchObject({ status: 'held', available: '200000.0' });
    expect(normalizeReservation({ ...booking, status: 'weird' })?.status).toBe('booked');
    expect(normalizeAvailableTables([{ id: 'posres_2', name: 'Bàn 8', capacity: 8 }])).toEqual([
      { id: 'posres_2', name: 'Bàn 8', kind: 'table', area_id: null, capacity: 8 },
    ]);
  });

  it('offers the actions of each status', () => {
    const waiting = normalizeReservation(booking);
    expect(waiting && reservationActions(waiting)).toMatchObject({
      seat: true,
      cancel: true,
      refundDeposit: true,
      forfeitDeposit: false,
    });
    const missed = normalizeReservation({ ...booking, status: 'no_show' });
    expect(missed && reservationActions(missed)).toMatchObject({
      seat: false,
      forfeitDeposit: true,
      refundDeposit: true,
    });
    const seated = normalizeReservation({ ...booking, status: 'seated' });
    expect(seated && reservationActions(seated)).toMatchObject({
      seat: false,
      refundDeposit: false,
      takeDeposit: true,
    });
  });

  it('places a booking on the day timeline', () => {
    expect(timelineSpan(booking, '2026-11-12T00:00:00Z')).toEqual({ start: 720, end: 840 });
    expect(timelineSpan(booking, '2026-11-12T13:00:00Z')).toEqual({ start: 0, end: 60 });
    expect(timelineSpan(booking, '2026-11-13T00:00:00Z')).toBeNull();
  });

  it('has a label for every status', () => {
    for (const bundle of [vi, en] as unknown as Record<string, string>[]) {
      for (const status of RESERVATION_STATUSES)
        expect(bundle[reservationStatusKey(status)]).toBeTruthy();
      for (const status of DEPOSIT_STATUSES) expect(bundle[depositStatusKey(status)]).toBeTruthy();
    }
  });
});
