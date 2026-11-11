import { describe, expect, it } from 'vitest';
import {
  draftLine,
  draftTotal,
  entryLines,
  lineValid,
  platformPriceValue,
} from './platform-order-draft';
import type { PosMenu } from './pos-context';

const menu: PosMenu = {
  branch_id: 'posbranch_1',
  currency: 'VND',
  business_date: '2026-11-11',
  module_enabled: true,
  categories: [],
  favorites: [],
  schedules: [],
  etag: 'e1',
  modifier_groups: [
    {
      id: 'posmgroup_1',
      name: 'Topping',
      min_select: 0,
      max_select: 3,
      allow_quantity: true,
      required: false,
      position: 0,
      options: [
        {
          id: 'posmopt_1',
          name: 'Trân châu',
          price_delta: '5000.0',
          variant_id: null,
          default_selected: false,
          position: 0,
          active: true,
        },
      ],
    },
  ],
  items: [
    {
      id: 'posmitem_1',
      product_id: 'prod_1',
      name: 'Trà sữa',
      kind: 'single',
      menu_category_id: null,
      kitchen_category: null,
      cup_label: false,
      show_components_on_kds: false,
      position: 0,
      active: true,
      tax_category_id: null,
      modifier_group_ids: ['posmgroup_1'],
      components: [],
      image_url: null,
      sold_out: false,
      variants: [
        {
          id: 'variant_m',
          name: 'M',
          sku: null,
          barcode: null,
          price: '30000.0',
          list_price: '30000.0',
          schedule_id: null,
        },
        {
          id: 'variant_l',
          name: 'L',
          sku: null,
          barcode: null,
          price: '36000.0',
          list_price: '36000.0',
          schedule_id: null,
        },
      ],
    },
  ],
};

describe('platform order draft', () => {
  it('makes a line from a menu pick with its options and the shop price', () => {
    const line = draftLine(
      menu,
      'variant_l',
      { modifiers: [{ option_id: 'posmopt_1', quantity: 2 }], note: ' Ít ngọt ' },
      'line-1',
    );
    expect(line).toMatchObject({
      name: 'Trà sữa · L',
      modifierNames: ['Trân châu x2'],
      note: 'Ít ngọt',
      quantity: 1,
      shopPrice: '46000.00',
      platformPrice: '',
    });
    expect(draftLine(menu, 'variant_gone', {}, 'line-2')).toBeNull();
  });

  it('reads platform prices as whole amounts, with or without thousands dots', () => {
    expect(platformPriceValue('')).toBeUndefined();
    expect(platformPriceValue('39000')).toBe('39000');
    expect(platformPriceValue('39.000')).toBe('39000');
    expect(platformPriceValue('-1')).toBeNull();
    expect(platformPriceValue('39,5')).toBeNull();
  });

  it('sends the platform price only where one is typed, and totals at it', () => {
    const first = draftLine(menu, 'variant_m', {}, 'a');
    const second = draftLine(menu, 'variant_l', {}, 'b');
    if (!first || !second) throw new Error('menu lines missing');
    const lines = [{ ...first, quantity: 2, platformPrice: '39.000' }, second];
    expect(entryLines(lines)).toEqual([
      { variant_id: 'variant_m', quantity: 2, platform_price: '39000' },
      { variant_id: 'variant_l', quantity: 1 },
    ]);
    expect(draftTotal(lines)).toBe('114000');
    expect(lines.every(lineValid)).toBe(true);
    expect(lineValid({ ...second, quantity: 0 })).toBe(false);
    expect(draftTotal([{ ...second, platformPrice: 'abc' }])).toBeNull();
  });
});
