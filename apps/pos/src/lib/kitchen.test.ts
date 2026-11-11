import { describe, expect, it } from 'vitest';
import { kitchenSent, unsentKitchenQuantity } from './kitchen';
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
});
