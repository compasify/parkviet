import { describe, expect, it } from 'vitest';
import { kitchenSent, kitchenStates, sentUnits, unsentKitchenQuantity } from './kitchen';
import type { PosLineItem, PosWorkspace } from './pos-context';

const line = (overrides: Partial<PosLineItem>): PosLineItem =>
  ({ id: 'l', kind: 'menu', quantity: 1, ...overrides }) as PosLineItem;

describe('kitchen quantities', () => {
  it('counts the menu units the kitchen has not heard about', () => {
    const workspace = {
      line_items: [
        line({ quantity: 3, kitchen_sent_quantity: '2.0' }),
        line({ quantity: 2 }),
        line({ quantity: 1, kitchen_sent_quantity: '1.0' }),
        line({ kind: 'ordinary', quantity: 5 }),
      ],
    } as PosWorkspace;
    expect(unsentKitchenQuantity(workspace)).toBe(3);
  });

  it('reads a missing or bad sent quantity as nothing sent', () => {
    expect(kitchenSent(line({}))).toBe(0);
    expect(kitchenSent(line({ kitchen_sent_quantity: 'x' }))).toBe(0);
    expect(kitchenSent(line({ kitchen_sent_quantity: '1.5' }))).toBe(1.5);
  });

  it('lists the kitchen states of a table line in order, without the empty ones', () => {
    expect(
      kitchenStates(line({ kitchen_status: { served: '1.0', new: '2.0', ready: '0' } })),
    ).toEqual([
      { state: 'new', count: 2 },
      { state: 'served', count: 1 },
    ]);
    expect(kitchenStates(line({}))).toEqual([]);
  });
});

describe('sentUnits', () => {
  it('counts the items of the fire tickets a send answered with', () => {
    expect(
      sentUnits({
        tickets: [
          { kind: 'fire', items: [{ quantity: '2.0' }, { quantity: '1.0' }] },
          { kind: 'fire', items: [{ quantity: '1.0' }] },
          { kind: 'void', items: [{ quantity: '5.0' }] },
        ],
      }),
    ).toBe(4);
    expect(sentUnits({ tickets: [], ticket_count: 0 })).toBe(0);
  });

  it('says nothing for an answer without tickets', () => {
    expect(sentUnits(undefined)).toBeNull();
    expect(sentUnits({ ticket_count: 1 })).toBeNull();
  });
});
