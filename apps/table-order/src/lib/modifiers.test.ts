import { describe, expect, it } from 'vitest';
import {
  defaultPicks,
  groupProblem,
  itemGroups,
  pickNames,
  picksReady,
  stepPick,
  togglePick,
  toSelections,
  unitPrice,
} from './modifiers';
import type { GuestMenu, ModifierGroup } from './types';

const sugar: ModifierGroup = {
  id: 'grp_sugar',
  name: 'Đường',
  min_select: 1,
  max_select: 1,
  allow_quantity: false,
  required: true,
  options: [
    { id: 'opt_full', name: '100%', price_delta: '0.0', default_selected: true },
    { id: 'opt_half', name: '50%', price_delta: '0.0', default_selected: false },
  ],
};

const toppings: ModifierGroup = {
  id: 'grp_top',
  name: 'Topping',
  min_select: 0,
  max_select: 3,
  allow_quantity: true,
  required: false,
  options: [
    { id: 'opt_pearl', name: 'Trân châu', price_delta: '5000.0', default_selected: false },
    { id: 'opt_jelly', name: 'Thạch', price_delta: '3000.5', default_selected: false },
  ],
};

describe('modifier rules', () => {
  it('starts from the defaults and swaps the pick of a single-choice group', () => {
    const picks = defaultPicks([sugar, toppings]);
    expect(picks).toEqual({ opt_full: 1 });
    expect(togglePick(sugar, picks, 'opt_half')).toEqual({ opt_half: 1 });
  });

  it('flags a required group left empty and a group past its max', () => {
    expect(groupProblem(sugar, {})).toBe('min');
    expect(picksReady([sugar], {})).toBe(false);
    expect(groupProblem(toppings, { opt_pearl: 4 })).toBe('max');
    expect(picksReady([sugar, toppings], { opt_full: 1, opt_pearl: 3 })).toBe(true);
  });

  it('counts quantities against the max where the group allows them', () => {
    let picks = togglePick(toppings, {}, 'opt_pearl');
    picks = stepPick(toppings, picks, 'opt_pearl', 1);
    picks = stepPick(toppings, picks, 'opt_pearl', 1);
    expect(picks).toEqual({ opt_pearl: 3 });
    expect(stepPick(toppings, picks, 'opt_pearl', 1)).toBe(picks);
    expect(togglePick(toppings, picks, 'opt_jelly')).toBe(picks);
    expect(stepPick(toppings, { opt_pearl: 1 }, 'opt_pearl', -1)).toEqual({});
  });

  it('sends picks in a stable order and names them for the cart', () => {
    const picks = { opt_pearl: 2, opt_full: 1, opt_half: 0 };
    expect(toSelections(picks)).toEqual([
      { option_id: 'opt_full', quantity: 1 },
      { option_id: 'opt_pearl', quantity: 2 },
    ]);
    expect(pickNames([sugar, toppings], picks)).toEqual(['100%', 'Trân châu x2']);
  });

  it('adds option prices to the size price without rounding drift', () => {
    expect(unitPrice('30000.0', [sugar, toppings], { opt_pearl: 2, opt_jelly: 1 })).toBe(
      '43000.50',
    );
    expect(unitPrice('bad', [], {})).toBeNull();
  });

  it("lists an item's groups in its own order and skips unknown ones", () => {
    const menu = { modifier_groups: [toppings, sugar] } as GuestMenu;
    const item = { modifier_group_ids: ['grp_sugar', 'grp_gone', 'grp_top'] } as Parameters<
      typeof itemGroups
    >[1];
    expect(itemGroups(menu, item).map((group) => group.id)).toEqual(['grp_sugar', 'grp_top']);
  });
});
