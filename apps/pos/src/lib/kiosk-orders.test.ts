import { describe, expect, it } from 'vitest';
import { canCollectKioskOrders, normalizeKioskOrders, waitingMinutes } from './kiosk-orders';

describe('kiosk orders', () => {
  it('reads the rows the server sends and skips malformed ones', () => {
    const rows = normalizeKioskOrders([
      {
        id: 'posws_1',
        order_number: 'R100',
        call_number: 7,
        status: 'parked',
        register: { id: 'posreg_1', name: 'Kiosk 1' },
        total: '30000.0',
        currency: 'VND',
        item_count: 2,
        waiting_since: '2026-11-12T03:00:00Z',
        abandoned: false,
      },
      { order_number: 'no id' },
      'junk',
      { id: 'posws_2', call_number: null, register: null, abandoned: 'yes' },
    ]);
    expect(rows).toHaveLength(2);
    expect(rows[0]).toMatchObject({ call_number: 7, register_name: 'Kiosk 1', item_count: 2 });
    expect(rows[1]).toMatchObject({
      call_number: null,
      register_name: null,
      total: '0',
      abandoned: false,
    });
    expect(normalizeKioskOrders(null)).toEqual([]);
  });

  it('counts the minutes an order has waited', () => {
    const [order] = normalizeKioskOrders([{ id: 'x', waiting_since: '2026-11-12T03:00:00Z' }]);
    expect(waitingMinutes(order, Date.parse('2026-11-12T03:12:30Z'))).toBe(12);
    expect(waitingMinutes(order, Date.parse('2026-11-12T02:00:00Z'))).toBe(0);
    expect(waitingMinutes({ ...order, waiting_since: '' }, Date.now())).toBe(0);
  });

  it('shows the tray only to staff who open a shift and collect payments', () => {
    expect(canCollectKioskOrders(['pos.shift.open', 'pos.payment.collect'])).toBe(true);
    expect(canCollectKioskOrders(['pos.shift.open'])).toBe(false);
    expect(canCollectKioskOrders(undefined)).toBe(false);
  });
});
