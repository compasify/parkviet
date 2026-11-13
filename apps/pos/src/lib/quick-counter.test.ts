import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { PosWorkspace } from './pos-context';
import {
  blankOrder,
  heldOrdersOf,
  ownBlankCandidates,
  ownDraftsOf,
  quickPayKey,
  saveOwnDrafts,
} from './quick-counter';

function order(id: string, extra: Partial<PosWorkspace> = {}): PosWorkspace {
  return {
    id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: `R${id}`,
    revision: 1,
    lease_generation: 1,
    operational_status: 'editing',
    payments: false,
    ...extra,
  };
}

const key = (value: string, modifiers: Partial<KeyboardEvent> = {}) => ({
  key: value,
  ctrlKey: false,
  metaKey: false,
  altKey: false,
  shiftKey: false,
  ...modifiers,
});

describe('quick counter payment keys', () => {
  it('maps F1, F2 and F3 to cash, VietQR and the other methods', () => {
    expect(quickPayKey(key('F1'))).toBe('cash');
    expect(quickPayKey(key('F2'))).toBe('vietqr');
    expect(quickPayKey(key('F3'))).toBe('other');
  });

  it('leaves other keys and modified presses alone', () => {
    expect(quickPayKey(key('F4'))).toBeNull();
    expect(quickPayKey(key('Enter'))).toBeNull();
    expect(quickPayKey(key('toString'))).toBeNull();
    expect(quickPayKey(key('F1', { ctrlKey: true }))).toBeNull();
    expect(quickPayKey(key('F2', { altKey: true }))).toBeNull();
    expect(quickPayKey(key('F3', { shiftKey: true }))).toBeNull();
    expect(quickPayKey(key('F1', { metaKey: true }))).toBeNull();
  });
});

describe('quick counter orders', () => {
  const line = {
    id: 'li_1',
    variant_id: 'v_1',
    name: 'Trà sữa',
    quantity: 1,
  } as unknown as NonNullable<PosWorkspace['line_items']>[number];

  it('reads a fresh draft as blank, from its lines or from a list row', () => {
    expect(blankOrder(order('1', { line_items: [] }))).toBe(true);
    expect(blankOrder(order('1', { total: '0.0' }))).toBe(true);
    expect(blankOrder(order('1'))).toBe(true);
  });

  it('counts an order with dishes, money, a number or a name as started', () => {
    expect(blankOrder(order('1', { line_items: [line] }))).toBe(false);
    expect(blankOrder(order('1', { total: '45000.0' }))).toBe(false);
    expect(blankOrder(order('1', { order_number: 3 }))).toBe(false);
    expect(blankOrder(order('1', { order_number: 3, line_items: [] }))).toBe(false);
    expect(blankOrder(order('1', { guest_name: 'Lan', line_items: [] }))).toBe(false);
    expect(blankOrder(order('1', { guest_name: 'Lan' }))).toBe(false);
    expect(blankOrder(order('1', { note: 'ít đá' }))).toBe(false);
    expect(blankOrder(order('1', { payments: true }))).toBe(false);
    expect(blankOrder(order('1', { operational_status: 'parked' }))).toBe(false);
  });

  it("holds every open order but the ticket and this device's own blank drafts", () => {
    const rows = [
      order('a', { total: '30000.0' }),
      order('b', { total: '0.0' }),
      order('c', { line_items: [line] }),
      order('d', { operational_status: 'completed', payments: true }),
      order('e', { operational_status: 'parked' }),
      // Another device's draft that looks blank in the list may hold 0 ₫ dishes.
      order('f', { total: '0.0' }),
      // This device's draft that got dishes since.
      order('g', { total: '15000.0' }),
    ];
    const own = new Set(['b', 'g']);
    expect(heldOrdersOf(rows, 'c', own).map((row) => row.id)).toEqual(['a', 'e', 'f', 'g']);
    expect(heldOrdersOf(rows, null, own).map((row) => row.id)).toEqual(['a', 'c', 'e', 'f', 'g']);
    expect(heldOrdersOf(rows, null, new Set()).map((row) => row.id)).toContain('b');
  });

  it("offers only this device's blank drafts for the next guest", () => {
    const rows = [
      order('a', { total: '30000.0' }),
      order('b', { total: '0.0' }),
      order('c', { total: '0.0' }),
      order('d', { total: '45000.0' }),
    ];
    const own = new Set(['b', 'd']);
    expect(ownBlankCandidates(rows, 'a', own).map((row) => row.id)).toEqual(['b']);
    expect(ownBlankCandidates(rows, 'b', own)).toEqual([]);
    expect(ownBlankCandidates([], null, own)).toEqual([]);
  });
});

describe('quick counter own drafts', () => {
  let store: Map<string, string>;
  beforeEach(() => {
    store = new Map<string, string>();
    vi.stubGlobal('window', {
      localStorage: {
        getItem: (key: string) => store.get(key) ?? null,
        setItem: (key: string, value: string) => store.set(key, value),
        removeItem: (key: string) => store.delete(key),
      },
    });
  });
  afterEach(() => vi.unstubAllGlobals());

  it('remembers the drafts per register across reloads', () => {
    saveOwnDrafts('reg_1', ['ws_1', 'ws_2']);
    expect([...ownDraftsOf('reg_1')]).toEqual(['ws_1', 'ws_2']);
    expect(ownDraftsOf('reg_2').size).toBe(0);
    saveOwnDrafts('reg_1', []);
    expect(ownDraftsOf('reg_1').size).toBe(0);
  });

  it('reads damaged storage as none and keeps only the latest few', () => {
    store.set('parkviet-pos:quick-own-drafts:reg_1', '{oops');
    expect(ownDraftsOf('reg_1').size).toBe(0);
    store.set('parkviet-pos:quick-own-drafts:reg_1', '[1,"ws_1",null]');
    expect([...ownDraftsOf('reg_1')]).toEqual(['ws_1']);
    saveOwnDrafts(
      'reg_1',
      Array.from({ length: 30 }, (_, index) => `ws_${index}`),
    );
    const kept = [...ownDraftsOf('reg_1')];
    expect(kept).toHaveLength(20);
    expect(kept.at(-1)).toBe('ws_29');
  });
});
