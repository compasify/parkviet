import { describe, expect, it } from 'vitest';
import type { PosLineItem, PosWorkspace } from './pos-context';
import {
  canSplitBySeat,
  courseName,
  coverLines,
  depositToApply,
  heldCourses,
  placementFields,
  seatsOf,
  sharedLines,
} from './table-courses';

function line(overrides: Partial<PosLineItem>): PosLineItem {
  return {
    id: overrides.sale_line_id ?? 'line',
    variant_id: 'variant_1',
    product_id: 'prod_1',
    name: 'Dish',
    sku: '',
    quantity: 1,
    price: '10000',
    amount: '10000',
    discounts: [],
    sale_line_id: 'posline_1',
    ...overrides,
  };
}

const order = (line_items: PosLineItem[]) => ({ line_items }) as Pick<PosWorkspace, 'line_items'>;

describe('placementFields', () => {
  it('sends only what was chosen', () => {
    expect(placementFields(undefined)).toEqual({});
    expect(placementFields({})).toEqual({});
    expect(
      placementFields({ course: 2, seat: 3, hold: true, buffetCoverLineId: 'posline_9' }),
    ).toEqual({
      course: 2,
      seat: 3,
      hold: true,
      buffet_cover_line_id: 'posline_9',
    });
  });

  it('never holds a dish without a course', () => {
    expect(placementFields({ hold: true, seat: 1 })).toEqual({ seat: 1 });
  });
});

describe('heldCourses', () => {
  it('groups the held dishes by course, first course first', () => {
    const held = heldCourses(
      order([
        line({ sale_line_id: 'a', course: 3, course_status: 'held' }),
        line({ sale_line_id: 'b', course: 2, course_status: 'held' }),
        line({ sale_line_id: 'c', course: 2, course_status: 'fired' }),
        line({ sale_line_id: 'd', course: 2, course_status: 'held' }),
      ]),
    );
    expect(held.map((row) => [row.course, row.lines.map((item) => item.sale_line_id)])).toEqual([
      [2, ['b', 'd']],
      [3, ['a']],
    ]);
  });
});

describe('seats and covers', () => {
  const lines = order([
    line({ sale_line_id: 'a', seat: 2 }),
    line({ sale_line_id: 'b', seat: 1 }),
    line({ sale_line_id: 'c' }),
    line({ sale_line_id: 'cover', kind: 'cover' }),
  ]);

  it('lists the seats in order and the dishes without one', () => {
    expect(seatsOf(lines)).toEqual([1, 2]);
    expect(sharedLines(lines).map((row) => row.sale_line_id)).toEqual(['c', 'cover']);
    expect(canSplitBySeat(lines)).toBe(true);
    expect(canSplitBySeat(order([line({ seat: 1 })]))).toBe(false);
  });

  it('finds the buffet tickets', () => {
    expect(coverLines(lines).map((row) => row.sale_line_id)).toEqual(['cover']);
  });
});

describe('courseName', () => {
  it('names the usual courses and numbers the rest', () => {
    expect(courseName(1)).toBe('Khai vị');
    expect(courseName(5)).toBe('#5');
  });
});

describe('depositToApply', () => {
  it('adds what the held deposits have left', () => {
    const deposit = (status: 'held' | 'applied', available: string) => ({
      id: status,
      kind: 'cash',
      amount: '100000',
      status,
      available,
    });
    expect(
      depositToApply({
        reservation: {
          id: 'res_1',
          guest_name: 'An',
          party_size: 4,
          status: 'seated',
          revision: 1,
          deposit_held: '150000',
          deposits: [deposit('held', '100000'), deposit('held', '50000'), deposit('applied', '0')],
        },
      }),
    ).toBe(150000);
    expect(depositToApply({ reservation: null })).toBe(0);
  });
});
