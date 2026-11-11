import { describe, expect, it } from 'vitest';
import {
  addsInOneTap,
  defaultPicks,
  drinksFirst,
  estimatePrice,
  favoriteItems,
  groupProblem,
  itemGroups,
  linePicks,
  picksReady,
  soldOutVariantIds,
  stepPick,
  togglePick,
  toSelections,
  visibleItems,
} from './menu-selection';
import type { PosLineItem, PosMenu, PosMenuItem, PosMenuModifierGroup } from './pos-context';

function group(overrides: Partial<PosMenuModifierGroup> = {}): PosMenuModifierGroup {
  return {
    id: 'posmodgroup_1',
    name: 'Topping',
    min_select: 0,
    max_select: 2,
    allow_quantity: false,
    required: false,
    position: 0,
    options: [
      {
        id: 'opt_a',
        name: 'Trân châu',
        price_delta: '5000.0',
        variant_id: null,
        default_selected: false,
        position: 0,
        active: true,
      },
      {
        id: 'opt_b',
        name: 'Thạch',
        price_delta: '4000.0',
        variant_id: null,
        default_selected: true,
        position: 1,
        active: true,
      },
      {
        id: 'opt_c',
        name: 'Cũ',
        price_delta: '1000.0',
        variant_id: null,
        default_selected: false,
        position: 2,
        active: false,
      },
    ],
    ...overrides,
  };
}

type Option = PosMenuModifierGroup['options'][number];
const [pearl, jelly] = group().options as [Option, Option, Option];

function item(overrides: Partial<PosMenuItem> = {}): PosMenuItem {
  return {
    id: 'posmenuitem_1',
    product_id: 'prod_1',
    name: 'Trà đào',
    kind: 'single',
    menu_category_id: 'posmenucat_1',
    kitchen_category: null,
    cup_label: false,
    show_components_on_kds: false,
    position: 0,
    active: true,
    tax_category_id: null,
    modifier_group_ids: ['posmodgroup_1'],
    components: [],
    image_url: null,
    sold_out: false,
    variants: [
      {
        id: 'var_m',
        name: 'M',
        sku: 'TD-M',
        barcode: '893001',
        price: '30000.0',
        list_price: '30000.0',
        schedule_id: null,
      },
    ],
    ...overrides,
  };
}

function menu(items: PosMenuItem[], groups = [group()]): PosMenu {
  return {
    branch_id: 'posbranch_1',
    currency: 'VND',
    business_date: '2026-11-11',
    module_enabled: true,
    categories: [],
    items,
    modifier_groups: groups,
    schedules: [],
    favorites: ['posmenuitem_2', 'posmenuitem_gone', 'posmenuitem_1'],
    etag: 'e',
  };
}

describe('menu picks', () => {
  it('offers only active options and starts from the defaults', () => {
    const groups = itemGroups(menu([item()]), item());
    expect(groups[0]?.options.map((option) => option.id)).toEqual(['opt_a', 'opt_b']);
    expect(defaultPicks(groups)).toEqual({ opt_b: 1 });
  });

  it('swaps the pick of a single-choice group and stops a group at its max', () => {
    const single = group({ max_select: 1 });
    expect(togglePick(single, { opt_b: 1 }, 'opt_a')).toEqual({ opt_a: 1 });
    expect(togglePick(single, { opt_a: 1 }, 'opt_a')).toEqual({});
    const pair = group({ max_select: 2, options: [pearl, jelly, { ...pearl, id: 'opt_d' }] });
    const full = togglePick(pair, togglePick(pair, {}, 'opt_a'), 'opt_b');
    expect(full).toEqual({ opt_a: 1, opt_b: 1 });
    expect(togglePick(pair, full, 'opt_d')).toBe(full);
  });

  it('counts summed quantities where quantities are allowed', () => {
    const counted = group({ allow_quantity: true, max_select: 3 });
    let picks = stepPick(counted, {}, 'opt_a', 1);
    picks = stepPick(counted, picks, 'opt_a', 1);
    picks = stepPick(counted, picks, 'opt_b', 1);
    expect(picks).toEqual({ opt_a: 2, opt_b: 1 });
    expect(stepPick(counted, picks, 'opt_b', 1)).toBe(picks);
    expect(stepPick(counted, picks, 'opt_b', -1)).toEqual({ opt_a: 2 });
  });

  it('holds back the add button until every required group is met', () => {
    const required = group({ min_select: 1, max_select: 1, required: true });
    expect(groupProblem(required, {})).toBe('min');
    expect(picksReady([required], {})).toBe(false);
    expect(picksReady([required], { opt_a: 1 })).toBe(true);
    expect(groupProblem(group({ max_select: 1 }), { opt_a: 1, opt_b: 1 })).toBe('max');
  });

  it('sends picks in a stable order and reads them back from a line', () => {
    expect(toSelections({ opt_b: 1, opt_a: 2, opt_c: 0 })).toEqual([
      { option_id: 'opt_a', quantity: 2 },
      { option_id: 'opt_b', quantity: 1 },
    ]);
    const line = {
      modifiers: [
        {
          id: 'm1',
          option_id: 'opt_a',
          name: 'Trân châu',
          group_name: 'Topping',
          price_delta: '5000.0',
          quantity: 2,
        },
        {
          id: 'm2',
          option_id: null,
          name: 'Đã xoá',
          group_name: 'Topping',
          price_delta: '0',
          quantity: 1,
        },
      ],
    } as PosLineItem;
    expect(linePicks(line)).toEqual({ opt_a: 2 });
  });

  it('estimates the price without float drift', () => {
    const groups = [group({ options: [{ ...pearl, price_delta: '0.1' }, jelly] })];
    expect(estimatePrice('0.2', groups, { opt_a: 1 })).toBe('0.30');
    expect(estimatePrice('30000.0', [group()], { opt_a: 2, opt_b: 1 })).toBe('44000.00');
    expect(estimatePrice(null, [group()], {})).toBeNull();
  });
});

describe('menu tiles', () => {
  const tea = item();
  const teaSize = tea.variants[0] as PosMenuItem['variants'][number];
  const coffee = item({
    id: 'posmenuitem_2',
    name: 'Cà phê đen',
    menu_category_id: 'posmenucat_2',
    modifier_group_ids: [],
    variants: [{ ...teaSize, id: 'var_cf', sku: 'CF', barcode: null }],
  });

  it('filters by category and by name without accents, sku or barcode', () => {
    const data = menu([tea, coffee]);
    expect(visibleItems(data, 'posmenucat_2', '').map((row) => row.id)).toEqual(['posmenuitem_2']);
    expect(visibleItems(data, null, 'ca phe').map((row) => row.id)).toEqual(['posmenuitem_2']);
    expect(visibleItems(data, null, 'td-m').map((row) => row.id)).toEqual(['posmenuitem_1']);
    expect(visibleItems(data, null, '893001').map((row) => row.id)).toEqual(['posmenuitem_1']);
  });

  it('lists favourites in their order, skipping items no longer on the menu', () => {
    expect(favoriteItems(menu([tea, coffee])).map((row) => row.id)).toEqual([
      'posmenuitem_2',
      'posmenuitem_1',
    ]);
  });

  it('adds in one tap only when there is nothing to choose', () => {
    const data = menu([tea, coffee]);
    expect(addsInOneTap(data, coffee)).toBe(true);
    expect(addsInOneTap(data, tea)).toBe(false);
  });
});

describe('sold-out dishes in the catalogue', () => {
  it('names the variants of every dish sold out today', () => {
    const soldOut = item({ id: 'posmenuitem_9', sold_out: true });
    const ids = soldOutVariantIds(menu([item(), soldOut]));
    expect([...ids]).toEqual(soldOut.variants.map((variant) => variant.id));
    expect(soldOutVariantIds(null).size).toBe(0);
  });
});

describe('drinksFirst', () => {
  it('leads with drinks and their categories, keeping each order', () => {
    const food = item({ id: 'food', menu_category_id: 'cat_food' });
    const beer = item({ id: 'beer', menu_category_id: 'cat_bar', kitchen_category: 'do_uong' });
    const shot = item({ id: 'shot', menu_category_id: 'cat_bar', kitchen_category: 'do_uong' });
    const category = (id: string, position: number) => ({
      id,
      name: id,
      position,
      color: null,
      active: true,
    });
    const result = drinksFirst({
      ...menu([food, beer, shot]),
      categories: [category('cat_food', 0), category('cat_bar', 1)],
    });
    expect(result.items.map((row) => row.id)).toEqual(['beer', 'shot', 'food']);
    expect(result.categories.map((row) => row.id)).toEqual(['cat_bar', 'cat_food']);
  });
});
