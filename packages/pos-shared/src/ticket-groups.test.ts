import { describe, expect, it } from 'vitest';
import {
  groupTicketLines,
  pendingKitchenUnits,
  ticketLineAmount,
  ticketLineTag,
} from './ticket-groups';
import type { PosLineItem, PosWorkspace } from './types/pos-context';

let next = 0;
// A menu line of a table order; `sent` units already went to the kitchen.
function line(name: string, fields: Partial<PosLineItem> & { sent?: number } = {}): PosLineItem {
  next += 1;
  const { sent = 0, ...rest } = fields;
  const quantity = rest.quantity ?? 1;
  return {
    id: `li_${next}`,
    sale_line_id: `sl_${next}`,
    variant_id: `v_${name}`,
    product_id: `p_${name}`,
    name,
    sku: '',
    quantity,
    price: '10000.0',
    amount: String(quantity * 10000),
    discounts: [],
    kind: 'menu',
    kitchen_sent_quantity: String(sent),
    ...rest,
  };
}

const order = (lines: PosLineItem[]): Pick<PosWorkspace, 'line_items' | 'kitchen_sends'> => ({
  line_items: lines,
  kitchen_sends: [
    {
      id: 'ks_1',
      sequence: 1,
      sent_at: '2026-11-13T07:05:00Z',
      staff_id: 's1',
      staff_name: 'Tuấn',
      device_id: null,
    },
    {
      id: 'ks_2',
      sequence: 2,
      sent_at: '2026-11-13T07:22:00Z',
      staff_id: 's2',
      staff_name: 'Lan',
      device_id: null,
    },
  ],
});

const names = (lines: PosLineItem[]) => lines.map((row) => row.name);

describe('groupTicketLines by send', () => {
  it('puts unsent dishes first, then each send newest first', () => {
    const groups = groupTicketLines(
      order([
        line('Phở bò', {
          quantity: 2,
          sent: 2,
          kitchen_send_sequence: 1,
          kitchen_status: { served: '2' },
        }),
        line('Nem rán', { sent: 1, kitchen_send_sequence: 2, kitchen_status: { preparing: '1' } }),
        line('Bia', { quantity: 2 }),
        line('Trứng'),
      ]),
      'round',
    );
    expect(groups.map((row) => row.key)).toEqual(['new', 'round:2', 'round:1']);
    expect(names(groups[0].lines)).toEqual(['Bia', 'Trứng']);
    expect(groups[0].quantity).toBe(3);
    expect(groups[1]).toMatchObject({ sequence: 2, send: { staff_name: 'Lan' } });
    expect(groups[2]).toMatchObject({ sequence: 1, quantity: 2, send: { staff_name: 'Tuấn' } });
  });

  it('keeps a held course apart from both the unsent dishes and the sends', () => {
    const groups = groupTicketLines(
      order([
        line('Phở cuốn', { course: 2, course_status: 'held' }),
        line('Quẩy', { sent: 1, kitchen_send_sequence: 1 }),
        line('Bia'),
      ]),
      'round',
    );
    expect(groups.map((row) => row.kind)).toEqual(['new', 'held', 'round']);
    expect(names(groups[1].lines)).toEqual(['Phở cuốn']);
  });

  it('sends lines of an older server without a send number to one sent group, last', () => {
    const groups = groupTicketLines(
      order([line('Quẩy', { sent: 1 }), line('Nem', { sent: 1, kitchen_send_sequence: 1 })]),
      'round',
    );
    expect(groups.map((row) => row.key)).toEqual(['round:1', 'round:sent']);
    expect(groups[1].send).toBeNull();
  });

  it('leaves out lines voided to nothing and puts lines no kitchen makes last', () => {
    const groups = groupTicketLines(
      order([
        line('Phở gà', { quantity: 0, sent: 0, kitchen_send_sequence: 1 }),
        line('Vé buffet', { kind: 'cover' }),
        line('Bia'),
      ]),
      'round',
    );
    expect(groups.map((row) => row.key)).toEqual(['new', 'other']);
    expect(names(groups.flatMap((row) => row.lines))).toEqual(['Bia', 'Vé buffet']);
  });

  it('has no group for an empty order', () => {
    expect(groupTicketLines(order([]), 'round')).toEqual([]);
    expect(groupTicketLines(null, 'seat')).toEqual([]);
  });
});

describe('groupTicketLines by course', () => {
  it('shows each course in order with how far it got, unsent dishes first', () => {
    const groups = groupTicketLines(
      order([
        line('Phở cuốn', { course: 2, course_status: 'held' }),
        line('Nem', {
          course: 1,
          sent: 1,
          kitchen_send_sequence: 1,
          kitchen_status: { served: '1' },
        }),
        line('Phở bò', {
          course: 2,
          course_status: 'fired',
          sent: 1,
          kitchen_send_sequence: 2,
          kitchen_status: { new: '1' },
        }),
        line('Quẩy', { sent: 1, kitchen_send_sequence: 1, kitchen_status: { ready: '1' } }),
        line('Bia'),
      ]),
      'course',
    );
    expect(groups.map((row) => row.key)).toEqual(['new', 'course:1', 'course:2', 'course:none']);
    expect(groups[1]).toMatchObject({ course: 1, courseStatus: 'done', sequence: 1 });
    // One held dish keeps the course waiting for its fire.
    expect(groups[2]).toMatchObject({ course: 2, courseStatus: 'held', sequence: 2 });
    expect(names(groups[2].lines)).toEqual(['Phở cuốn', 'Phở bò']);
    expect(groups[3]).toMatchObject({ course: null, courseStatus: 'done' });
  });

  it('calls a fired course still cooking fired', () => {
    const [course] = groupTicketLines(
      order([
        line('Phở', {
          course: 2,
          course_status: 'fired',
          sent: 1,
          kitchen_status: { preparing: '1' },
        }),
      ]),
      'course',
    );
    expect(course).toMatchObject({ courseStatus: 'fired', sequence: null, send: null });
  });
});

describe('groupTicketLines by seat', () => {
  it('groups by seat in order with each seat’s cost, the table’s shared lines last', () => {
    const groups = groupTicketLines(
      order([
        line('Nem', { sent: 1, kitchen_send_sequence: 1 }),
        line('Bia', { seat: 4, quantity: 2 }),
        line('Phở bò', { seat: 1, sent: 1, kitchen_send_sequence: 1 }),
        line('Trứng', { seat: 1 }),
        line('Vé buffet', { kind: 'cover', amount: '199000.0' }),
      ]),
      'seat',
    );
    expect(groups.map((row) => row.key)).toEqual(['seat:1', 'seat:4', 'shared']);
    expect(groups[0]).toMatchObject({ seat: 1, amount: 20000 });
    expect(names(groups[0].lines)).toEqual(['Phở bò', 'Trứng']);
    expect(groups[1]).toMatchObject({ seat: 4, amount: 20000, quantity: 2 });
    expect(groups[2]).toMatchObject({ kind: 'shared', seat: null, amount: 209000 });
  });
});

describe('ticket lines', () => {
  it('tags what the kitchen does with a line', () => {
    expect(ticketLineTag(line('a'))).toBe('new');
    expect(ticketLineTag(line('a', { course: 2, course_status: 'held' }))).toBe('held');
    expect(ticketLineTag(line('a', { sent: 1 }))).toBe('sent');
    expect(
      ticketLineTag(line('a', { sent: 2, kitchen_status: { preparing: '1', ready: '1' } })),
    ).toBe('cooking');
    expect(ticketLineTag(line('a', { sent: 2, kitchen_status: { ready: '1', served: '1' } }))).toBe(
      'done',
    );
    // Received by the kitchen and not started is sent, even beside a cooking one.
    expect(
      ticketLineTag(line('a', { sent: 2, kitchen_status: { new: '1', preparing: '1' } })),
    ).toBe('sent');
    expect(ticketLineTag(line('a', { kind: 'cover' }))).toBe('none');
  });

  it('counts the units the next send takes, held courses left out', () => {
    expect(
      pendingKitchenUnits(
        order([
          line('a', { quantity: 2, pending_kitchen_quantity: '2.0' }),
          line('b', { quantity: 3, sent: 1 }),
          line('c', { course: 2, course_status: 'held' }),
          line('d', { kind: 'cover' }),
        ]),
      ),
    ).toBe(4);
    expect(pendingKitchenUnits(null)).toBe(0);
  });

  it('prices a line with its own discounts', () => {
    expect(ticketLineAmount(line('a', { amount: '20000', item_net_amount: '18000.0' }))).toBe(
      18000,
    );
    expect(ticketLineAmount(line('a', { amount: 'x' }))).toBe(0);
  });
});
