import { normalizeResourceBoard } from '@parkviet/pos-shared/tables';
import { describe, expect, it } from 'vitest';
import type { OpenTab } from '../hooks/use-tabs';
import { searchTabs, tabColumnRows } from './tab-search';

const rows = [
  { id: 'a', name: 'Anh Tuấn áo xanh', place: null, orderNumber: 12 },
  { id: 'b', name: 'VIP 2', place: 'Tầng lửng', orderNumber: null },
  { id: 'c', name: 'Linh Hà', place: 'Sân vườn', orderNumber: 3 },
];
const ids = (query: string) => searchTabs(rows, query).map((row) => row.id);

describe('searchTabs', () => {
  it('keeps every row for an empty query', () => {
    expect(ids('')).toEqual(['a', 'b', 'c']);
    expect(ids('   ')).toEqual(['a', 'b', 'c']);
  });

  it('finds a guest by name without accents or case', () => {
    expect(ids('tuan')).toEqual(['a']);
    expect(ids('AO XANH')).toEqual(['a']);
    expect(ids('Tuấn')).toEqual(['a']);
  });

  it('finds a row by its table, its area or its call number', () => {
    expect(ids('vip')).toEqual(['b']);
    expect(ids('tang lung')).toEqual(['b']);
    expect(ids('san vuon')).toEqual(['c']);
    expect(ids('12')).toEqual(['a']);
    expect(ids('1')).toEqual([]);
  });
});

function tab(id: string, openedAt: string | null): OpenTab {
  return {
    id,
    tabName: `Tab ${id}`,
    table: null,
    orderNumber: null,
    openedAt,
    total: '10000',
    unsent: 1,
  };
}

const board = normalizeResourceBoard({
  branch_id: 'br_1',
  areas: [{ id: 'ar_vip', name: 'Tầng VIP', position: 0, floor_width: 10, floor_height: 10 }],
  resources: [
    {
      id: 'rs_1',
      area_id: 'ar_vip',
      name: 'VIP 1',
      state: 'payment_requested',
      orders: [
        {
          id: 'ws_table',
          table_label: 'B',
          total: '70000',
          payment_requested: true,
          unsent_kitchen_items: 2,
          opened_at: '2026-11-13T15:00:00Z',
        },
        // A tab never sits at a table; an id seen twice stays one row.
        { id: 'ws_new', total: '5000', opened_at: '2026-11-13T18:00:00Z' },
      ],
    },
  ],
});

describe('tabColumnRows', () => {
  it('lists tabs and table orders once each, newest first, undated last', () => {
    const result = tabColumnRows(
      [
        tab('ws_new', '2026-11-13T17:00:00Z'),
        tab('ws_old', null),
        tab('ws_mid', '2026-11-13T16:00:00Z'),
      ],
      board,
    );
    expect(result.map((row) => row.id)).toEqual(['ws_new', 'ws_mid', 'ws_table', 'ws_old']);
    expect(result[0]).toMatchObject({ kind: 'tab', name: 'Tab ws_new', paymentRequested: false });
  });

  it('names a table order by its table and letter, with the area and the bill asked for', () => {
    const [row] = tabColumnRows([], board).filter((entry) => entry.id === 'ws_table');
    expect(row).toEqual({
      id: 'ws_table',
      kind: 'table',
      name: 'VIP 1 · B',
      place: 'Tầng VIP',
      orderNumber: null,
      openedAt: '2026-11-13T15:00:00Z',
      total: '70000',
      unsent: 2,
      paymentRequested: true,
    });
  });

  it('shows only the tabs while the floor is not read yet', () => {
    expect(tabColumnRows([tab('ws_a', null)], undefined).map((row) => row.id)).toEqual(['ws_a']);
  });
});
