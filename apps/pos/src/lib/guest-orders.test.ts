import { describe, expect, it } from 'vitest';
import { normalizeGuestOrders, normalizeGuestRequests, waitingCount } from './guest-orders';

describe('guest orders from the table QR', () => {
  it('reads orders with their options, outcomes and defaults, skipping rows without an id', () => {
    const [order, ...rest] = normalizeGuestOrders([
      {
        id: 'posguestorder_1',
        workspace_id: 'ws_1',
        resource_id: 'res_1',
        table_name: 'Bàn 4',
        area_id: 'area_1',
        status: 'pending',
        automatic: false,
        quoted_total: '75000.0',
        currency: 'VND',
        items: [
          {
            name: 'Trà đào',
            size: 'L',
            quantity: 2,
            amount: '70000.0',
            note: 'ít đá',
            modifiers: [
              { name: 'Trân châu', quantity: 1 },
              { name: 'Thạch', quantity: 2 },
            ],
          },
          {
            name: 'Bánh',
            quantity: 1,
            amount: '5000.0',
            outcome: 'left_out',
            reason: 'item_sold_out',
          },
          { quantity: 3 },
        ],
        created_at: '2026-11-12T03:00:00Z',
      },
      { status: 'pending' },
      'nonsense',
    ]);
    expect(rest).toEqual([]);
    expect(order.items).toHaveLength(2);
    expect(order.items[0]).toMatchObject({
      options: ['Trân châu', 'Thạch x2'],
      outcome: null,
      note: 'ít đá',
    });
    expect(order.items[1]).toMatchObject({
      outcome: 'left_out',
      reason: 'item_sold_out',
      size: null,
    });
    expect(normalizeGuestOrders(undefined)).toEqual([]);
  });

  it('counts pending orders and open requests as waiting for staff', () => {
    const orders = normalizeGuestOrders([
      { id: 'a', status: 'pending' },
      { id: 'b', status: 'accepted' },
    ]);
    const requests = normalizeGuestRequests([
      { id: 'r1', kind: 'call_staff', status: 'open' },
      { id: 'r2', kind: 'request_bill', status: 'done' },
      { kind: 'call_staff', status: 'open' },
    ]);
    expect(requests).toHaveLength(2);
    expect(waitingCount(orders, requests)).toBe(2);
  });
});
