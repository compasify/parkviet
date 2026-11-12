import { describe, expect, it } from 'vitest';
import {
  addLine,
  type CartLine,
  cartProblem,
  cartTotal,
  itemCount,
  MAX_LINE_QUANTITY,
  orderBody,
  setQuantity,
} from './cart';

const tea = (overrides: Partial<Omit<CartLine, 'key'>> = {}): Omit<CartLine, 'key'> => ({
  itemId: 'mi_tea',
  variantId: 'v_tea_l',
  name: 'Trà đào',
  size: 'L',
  quantity: 1,
  picks: { opt_pearl: 1 },
  options: ['Trân châu'],
  note: '',
  unitPrice: '35000.00',
  ...overrides,
});

describe('the guest cart', () => {
  it('merges the same dish with the same picks and note, keeps others apart', () => {
    let cart = addLine([], tea());
    cart = addLine(cart, tea({ quantity: 2 }));
    cart = addLine(cart, tea({ note: 'ít đá' }));
    cart = addLine(cart, tea({ picks: {} }));
    expect(cart).toHaveLength(3);
    expect(cart[0].quantity).toBe(3);
    expect(itemCount(cart)).toBe(5);
  });

  it('caps a line, removes it at zero and totals in hundredths', () => {
    let cart = addLine([], tea({ unitPrice: '10000.50' }));
    cart = setQuantity(cart, cart[0].key, 99);
    expect(cart[0].quantity).toBe(MAX_LINE_QUANTITY);
    cart = setQuantity(cart, cart[0].key, 3);
    expect(cartTotal(cart)).toBe('30001.50');
    expect(setQuantity(cart, cart[0].key, 0)).toEqual([]);
  });

  it('refuses more lines or items than one order takes', () => {
    const many = Array.from({ length: 21 }, (_, index) => tea({ variantId: `v_${index}` })).reduce(
      (cart: CartLine[], line) => addLine(cart, line),
      [],
    );
    expect(cartProblem(many)).toBe('too_many_lines');
    const heavy = [1, 2, 3].reduce(
      (cart: CartLine[], index) => addLine(cart, tea({ variantId: `v_${index}`, quantity: 20 })),
      [],
    );
    expect(cartProblem(heavy)).toBe('too_many_items');
    expect(cartProblem(addLine([], tea()))).toBeNull();
  });

  it('sends variants, quantities, picks and notes, never a price', () => {
    const cart = addLine(
      addLine([], tea({ note: '  ít đá ' })),
      tea({ variantId: 'v_flan', picks: {} }),
    );
    const body = orderBody(cart);
    expect(body).toEqual({
      items: [
        {
          variant_id: 'v_tea_l',
          quantity: 1,
          modifiers: [{ option_id: 'opt_pearl', quantity: 1 }],
          note: 'ít đá',
        },
        { variant_id: 'v_flan', quantity: 1, modifiers: [] },
      ],
    });
    expect(JSON.stringify(body)).not.toContain('price');
  });
});
