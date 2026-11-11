import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import { normalizeProfile, tableSurfaceOf } from './pos-modules';
import {
  clampPlacement,
  countStates,
  filterTables,
  fitsArea,
  normalizeResource,
  normalizeResourceBoard,
  TABLE_STATES,
  tableStateKey,
} from './tables';

const board = normalizeResourceBoard({
  branch_id: 'posbranch_1',
  server_now: '2026-11-11T10:00:00Z',
  areas: [
    { id: 'posarea_2', name: 'Sân', position: 2, floor_width: 12, floor_height: 8 },
    { id: 'posarea_1', name: 'Tầng 1', position: 1, floor_width: 24, floor_height: 16 },
    { name: 'no id' },
  ],
  resources: [
    {
      id: 'posres_1',
      area_id: 'posarea_1',
      name: 'B1',
      state: 'ordered',
      orders: [{ id: 'w1', total: '50000.0' }],
    },
    { id: 'posres_2', area_id: 'posarea_1', name: 'B2', state: 'available', orders: [] },
    { id: 'posres_3', area_id: 'posarea_2', name: 'S1', state: 'teleported', shape: 'star', w: 0 },
    'junk',
  ],
});

describe('resource board', () => {
  it('reads the board tolerantly and orders the areas', () => {
    expect(board.areas.map((row) => row.id)).toEqual(['posarea_1', 'posarea_2']);
    expect(board.resources.map((row) => row.id)).toEqual(['posres_1', 'posres_2', 'posres_3']);
    expect(board.resources[2]).toMatchObject({
      state: 'available',
      shape: 'rect',
      w: 1,
      orders: [],
    });
    expect(board.resources[0].orders[0]).toMatchObject({
      id: 'w1',
      total: '50000.0',
      prebilled: false,
    });
    expect(normalizeResourceBoard(null)).toEqual({
      branch_id: '',
      server_now: null,
      areas: [],
      resources: [],
    });
  });

  it('filters by area and state, and counts the states', () => {
    expect(filterTables(board.resources, { areaId: 'posarea_1' }).map((row) => row.id)).toEqual([
      'posres_1',
      'posres_2',
    ]);
    expect(filterTables(board.resources, { state: 'open' }).map((row) => row.id)).toEqual([
      'posres_1',
    ]);
    expect(filterTables(board.resources, { state: 'available' }).map((row) => row.id)).toEqual([
      'posres_2',
      'posres_3',
    ]);
    expect(countStates(board.resources)).toMatchObject({ ordered: 1, available: 2, cleaning: 0 });
  });

  it('labels every state in both languages', () => {
    for (const state of TABLE_STATES)
      for (const bundle of [vi, en])
        expect((bundle as Record<string, unknown>)[tableStateKey(state)]).toEqual(
          expect.any(String),
        );
  });
});

describe('floor plan grid', () => {
  const area = { floor_width: 10, floor_height: 6 };

  it('checks a table fits its area as the server does', () => {
    expect(fitsArea({ x: 8, y: 4, w: 2, h: 2, rotation: 0 }, area)).toBe(true);
    expect(fitsArea({ x: 9, y: 4, w: 2, h: 2, rotation: 0 }, area)).toBe(false);
    expect(fitsArea({ x: -1, y: 0, w: 2, h: 2, rotation: 0 }, area)).toBe(false);
  });

  it('keeps a dragged table on whole cells inside the area', () => {
    expect(clampPlacement({ x: 9.6, y: -2, w: 2.2, h: 3, rotation: 90 }, area)).toEqual({
      x: 8,
      y: 0,
      w: 2,
      h: 3,
      rotation: 90,
    });
    expect(clampPlacement({ x: 0, y: 0, w: 30, h: 1, rotation: 0 }, area)).toMatchObject({
      x: 0,
      w: 10,
    });
  });

  it('reads a table record for the editor', () => {
    expect(
      normalizeResource({
        id: 'posres_9',
        area_id: 'posarea_1',
        name: 'VIP',
        kind: 'vip',
        capacity: 10,
      }),
    ).toMatchObject({
      kind: 'vip',
      capacity: 10,
      manual_status: 'available',
      resource_type_code: null,
    });
    expect(normalizeResource({ name: 'no id' })).toBeNull();
  });
});

describe('table surface', () => {
  const profile = (surface?: string) => normalizeProfile({ key: 'p', display: { surface } });
  const on = { 'fnb.tables': true };

  it('shows the floor only with fnb.tables, the device choice first', () => {
    expect(tableSurfaceOf({ modules: {}, profile: profile('floor_plan') })).toBeNull();
    expect(tableSurfaceOf({ modules: on, profile: profile('floor_plan') })).toBe('floor_plan');
    expect(tableSurfaceOf({ modules: on, profile: profile('menu_grid') })).toBe('table_grid');
    expect(tableSurfaceOf({ modules: on, profile: profile('floor_plan') }, 'table_grid')).toBe(
      'table_grid',
    );
    expect(tableSurfaceOf({ modules: on, profile: profile() }, 'kiosk')).toBe('table_grid');
  });
});
