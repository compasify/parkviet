import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import { normalizeProfile, tableSurfaceOf } from './pos-modules';
import {
  ATTENTION_REASONS,
  attentionReasons,
  boardCounts,
  buffetMinutesLeft,
  buffetTiming,
  clampPlacement,
  clockAttention,
  clockPlayedSeconds,
  clockSecondsLeft,
  countStates,
  filterTables,
  fitsArea,
  inBoardChip,
  needsAttention,
  normalizeResource,
  normalizeResourceBoard,
  ROOM_TONES,
  roomTone,
  TABLE_STATES,
  tableStateKey,
  tileAlert,
  tileTone,
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
      outside_operating_hours: false,
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

  it('reads a room clock and drops a malformed one', () => {
    const read = normalizeResourceBoard({
      resources: [
        {
          id: 'posres_9',
          state: 'playing',
          timed: {
            id: 'postimed_1',
            workspace_id: 'w9',
            status: 'running',
            started_at: '2026-11-12T14:30:00Z',
            played_minutes: 40,
            quote_amount: '75000.0',
          },
        },
        { id: 'posres_10', state: 'ending_soon', timed: { id: 'postimed_2' } },
      ],
    });
    expect(read.resources[0]).toMatchObject({
      state: 'playing',
      timed: {
        id: 'postimed_1',
        status: 'running',
        played_minutes: 40,
        quote_amount: '75000.0',
        planned_end_at: null,
        ending_soon: false,
      },
    });
    expect(read.resources[1]).toMatchObject({ state: 'ending_soon', timed: null });
    expect(board.resources[0].timed).toBeNull();
  });

  it('counts a paused clock still and a package down on the server clock', () => {
    const read = normalizeResourceBoard({
      server_now: '2026-11-12T20:00:00Z',
      outside_operating_hours: true,
      resources: [
        {
          id: 'posres_1',
          timed: {
            id: 't1',
            status: 'running',
            started_at: '2026-11-12T19:00:00Z',
            planned_end_at: '2026-11-12T21:10:00Z',
            prepaid_minutes: 120,
            played_seconds: 50 * 60,
          },
        },
        {
          id: 'posres_2',
          timed: {
            id: 't2',
            status: 'paused',
            started_at: '2026-11-12T19:00:00Z',
            paused_at: '2026-11-12T19:45:00Z',
            played_seconds: 45 * 60,
            pause_too_long: true,
          },
        },
      ],
    });
    expect(read.outside_operating_hours).toBe(true);
    const [running, paused] = read.resources.flatMap((row) => (row.timed ? [row.timed] : []));
    expect(running).toMatchObject({
      prepaid_minutes: 120,
      package_ended: false,
      pause_too_long: false,
    });
    expect(paused).toMatchObject({ paused_at: '2026-11-12T19:45:00Z', pause_too_long: true });
    const later = Date.parse('2026-11-12T20:05:00Z');
    expect(clockPlayedSeconds(running, read.server_now, later)).toBe(55 * 60);
    expect(clockPlayedSeconds(paused, read.server_now, later)).toBe(45 * 60);
    expect(clockSecondsLeft(running, later)).toBe(65 * 60);
    expect(clockSecondsLeft(paused, later)).toBeNull();
    // Without the board's count: from the start.
    expect(clockPlayedSeconds({ ...running, played_seconds: null }, null, later)).toBe(65 * 60);
  });

  it('shows a stopped clock as played, its pauses left out', () => {
    // An hour played with a half-hour pause, then stopped: 1:00, not 1:30.
    const [stopped] = normalizeResourceBoard({
      server_now: '2026-11-12T21:00:00Z',
      resources: [
        {
          id: 'posres_1',
          timed: {
            id: 't1',
            status: 'stopped',
            started_at: '2026-11-12T19:00:00Z',
            stopped_at: '2026-11-12T20:30:00Z',
            played_minutes: 60,
            played_seconds: null,
            rate_per_hour: null,
          },
        },
      ],
    }).resources.flatMap((row) => (row.timed ? [row.timed] : []));
    expect(
      clockPlayedSeconds(stopped, '2026-11-12T21:00:00Z', Date.parse('2026-11-12T22:00:00Z')),
    ).toBe(60 * 60);
    expect(clockPlayedSeconds(stopped, null, Date.parse('2026-11-12T22:00:00Z'))).toBe(60 * 60);
    expect(stopped.rate_per_hour).toBeNull();
  });

  it('reads the hourly price a clock runs at', () => {
    const [timed] = normalizeResourceBoard({
      resources: [
        {
          id: 'posres_1',
          timed: {
            id: 't1',
            status: 'running',
            started_at: '2026-11-12T19:00:00Z',
            rate_per_hour: '150000.0',
          },
        },
      ],
    }).resources.flatMap((row) => (row.timed ? [row.timed] : []));
    expect(timed.rate_per_hour).toBe('150000.0');
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

describe('buffet timing', () => {
  it('warns in the last ten minutes and once over, on the server clock', () => {
    const ends = '2026-11-12T13:30:00Z';
    expect(buffetTiming(ends, '2026-11-12T13:00:00Z')).toBe('running');
    expect(buffetTiming(ends, '2026-11-12T13:20:00Z')).toBe('ending');
    expect(buffetTiming(ends, '2026-11-12T13:31:00Z')).toBe('over');
    expect(buffetTiming(null, '2026-11-12T13:31:00Z')).toBe('none');
    expect(buffetMinutesLeft(ends, '2026-11-12T13:20:30Z')).toBe(9);
  });

  it('reads the next booking and buffet end of a tile', () => {
    const board = normalizeResourceBoard({
      resources: [
        {
          id: 'posres_1',
          state: 'reserved',
          next_reservation: {
            id: 'posresv_1',
            starts_at: '2026-11-12T13:00:00Z',
            guest_name: 'Chị Lan',
            party_size: 4,
          },
          buffet_ends_at: null,
          orders: [],
        },
      ],
    });
    expect(board.resources[0]).toMatchObject({
      state: 'reserved',
      next_reservation: { id: 'posresv_1', guest_name: 'Chị Lan', party_size: 4 },
      buffet_ends_at: null,
    });
  });
});

describe('table board', () => {
  // One table as the board reads it; an order is open when `orders` is given.
  const tile = (
    state: string,
    extra: Record<string, unknown> = {},
    orders: Array<Record<string, unknown>> = [],
  ) =>
    normalizeResourceBoard({
      resources: [
        {
          id: `posres_${state}`,
          name: state,
          state,
          subtotal: orders.length ? '120000.0' : null,
          seated_minutes: orders.length ? 30 : null,
          orders: orders.map((order, index) => ({ id: `w${index}`, total: '120000.0', ...order })),
          ...extra,
        },
      ],
    }).resources[0];
  const one = [{}];

  it('paints five tones, strongest need first', () => {
    expect(tileTone(tile('available'))).toBe('free');
    expect(tileTone(tile('reserved'))).toBe('free');
    expect(tileTone(tile('cleaning'))).toBe('free');
    expect(tileTone(tile('ordered', {}, one))).toBe('serving');
    expect(tileTone(tile('waiting_long', {}, one))).toBe('serving');
    // Dishes on the order and nothing sent yet.
    expect(tileTone(tile('occupied', {}, one))).toBe('unsent');
    // Seated with nothing ordered yet is served, not unsent.
    expect(tileTone(tile('occupied', { subtotal: '0.0' }, one))).toBe('serving');
    expect(tileTone(tile('prebilled', {}, [{ prebilled: true }]))).toBe('prebilled');
    expect(
      tileTone(
        tile('payment_requested', { payment_requested: true }, [
          { payment_requested: true, prebilled: true },
        ]),
      ),
    ).toBe('payment');
    // One of two orders asking for the bill is enough.
    expect(tileTone(tile('occupied', {}, [{}, { payment_requested: true }]))).toBe('payment');
  });

  it('never calls dishes unsent at a branch without a kitchen', () => {
    expect(tileTone(tile('occupied', {}, one), { kitchen: false })).toBe('serving');
    expect(tileTone(tile('ordered', {}, [{ unsent_kitchen_items: 2 }]), { kitchen: false })).toBe(
      'serving',
    );
  });

  it('reads unsent dishes per order when the server counts them, after a send too', () => {
    // Dishes added after the first send.
    expect(tileTone(tile('ordered', {}, [{ unsent_kitchen_items: 2 }]))).toBe('unsent');
    expect(tileTone(tile('waiting_long', {}, [{ unsent_kitchen_items: 1 }]))).toBe('unsent');
    // Seated with dishes, all sent: served, whatever the state says.
    expect(tileTone(tile('occupied', {}, [{ unsent_kitchen_items: 0 }]))).toBe('serving');
    // One order of two waiting is enough.
    expect(
      tileTone(tile('ordered', {}, [{ unsent_kitchen_items: 0 }, { unsent_kitchen_items: 3 }])),
    ).toBe('unsent');
    // The bill still wins.
    expect(
      tileTone(tile('ordered', {}, [{ unsent_kitchen_items: 2, payment_requested: true }])),
    ).toBe('payment');
    expect(
      needsAttention(tile('ordered', {}, [{ unsent_kitchen_items: 1 }]), { alertMinutes: 60 }),
    ).toBe(true);
  });

  it('falls back to guessing from the state when an order has no count', () => {
    expect(tile('occupied', {}, one).orders[0].unsent_kitchen_items).toBeNull();
    expect(tileTone(tile('ordered', {}, [{ unsent_kitchen_items: 2 }, {}]))).toBe('serving');
    expect(tileTone(tile('occupied', {}, [{ unsent_kitchen_items: 0 }, {}]))).toBe('unsent');
  });

  it('flags a table seated past the branch threshold or waiting on the kitchen', () => {
    const seated = tile('ordered', { seated_minutes: 60 }, one);
    expect(tileAlert(seated, { alertMinutes: 60 })).toBe(true);
    expect(tileAlert(seated, { alertMinutes: 61 })).toBe(false);
    // No threshold: no seated alert.
    expect(tileAlert(seated, { alertMinutes: null })).toBe(false);
    expect(tileAlert(tile('waiting_long', {}, one), { alertMinutes: null })).toBe(true);
    // A free table never is, whatever its minutes.
    expect(tileAlert(tile('available', { seated_minutes: 999 }), { alertMinutes: 1 })).toBe(false);
  });

  it('needs attention for the bill, a late kitchen, a long stay or unsent dishes', () => {
    const options = { alertMinutes: 60 };
    expect(
      needsAttention(tile('payment_requested', { payment_requested: true }, one), options),
    ).toBe(true);
    expect(needsAttention(tile('waiting_long', {}, one), options)).toBe(true);
    expect(needsAttention(tile('ordered', { seated_minutes: 75 }, one), options)).toBe(true);
    expect(needsAttention(tile('occupied', {}, one), options)).toBe(true);
    expect(needsAttention(tile('occupied', {}, one), { ...options, kitchen: false })).toBe(false);
    expect(needsAttention(tile('ordered', {}, one), options)).toBe(false);
    expect(needsAttention(tile('prebilled', {}, [{ prebilled: true }]), options)).toBe(false);
    expect(needsAttention(tile('available'), options)).toBe(false);
  });

  it('counts the chips and filters by them', () => {
    const tables = [
      tile('available'),
      tile('reserved'),
      tile('cleaning'),
      tile('ordered', {}, one),
      tile('occupied', {}, one),
      tile('payment_requested', { payment_requested: true }, one),
    ];
    const options = { alertMinutes: 60 };
    expect(boardCounts(tables, options)).toEqual({ all: 6, in_use: 3, free: 2, attention: 2 });
    expect(boardCounts([], options)).toEqual({ all: 0, in_use: 0, free: 0, attention: 0 });
    const names = (chip: Parameters<typeof inBoardChip>[1]) =>
      tables.filter((row) => inBoardChip(row, chip, options)).map((row) => row.name);
    expect(names('all')).toHaveLength(6);
    expect(names('in_use')).toEqual(['ordered', 'occupied', 'payment_requested']);
    expect(names('free')).toEqual(['available', 'reserved']);
    expect(names('attention')).toEqual(['occupied', 'payment_requested']);
  });
});

describe('timed room tones', () => {
  const START = '2026-11-12T14:00:00Z';
  const at = (time: string) => Date.parse(time);
  // A room (or a restaurant's billiard table) with an open order and its clock.
  const room = (timed: Record<string, unknown> | null, extra: Record<string, unknown> = {}) =>
    normalizeResourceBoard({
      resources: [
        {
          id: 'posres_room',
          name: 'P101',
          kind: 'room',
          state: timed ? 'playing' : 'occupied',
          orders: [{ id: 'ws_1', total: '0.0' }],
          timed: timed
            ? { id: 'postimed_1', started_at: START, status: 'running', ...timed }
            : null,
          ...extra,
        },
      ],
    }).resources[0];

  it('is free without guests and idle with guests but no clock counting', () => {
    const free = normalizeResourceBoard({ resources: [{ id: 'posres_free', kind: 'room' }] })
      .resources[0];
    expect(roomTone(free)).toBe('free');
    expect(roomTone(free, at('2026-11-12T14:30:00Z'))).toBe('free');
    expect(roomTone(room(null))).toBe('idle');
    // Stopped and waiting for its payment.
    expect(roomTone(room({ status: 'stopped', stopped_at: '2026-11-12T14:40:00Z' }))).toBe('idle');
  });

  it('counts up, turns amber in the last ten minutes and red once past its end', () => {
    const open = room({});
    expect(roomTone(open, at('2026-11-12T18:00:00Z'))).toBe('running');
    const plan = room({ planned_end_at: '2026-11-12T15:00:00Z', prepaid_minutes: 60 });
    expect(roomTone(plan, at('2026-11-12T14:49:59Z'))).toBe('running');
    expect(roomTone(plan, at('2026-11-12T14:50:00Z'))).toBe('ending');
    expect(roomTone(plan, at('2026-11-12T14:59:59Z'))).toBe('ending');
    expect(roomTone(plan, at('2026-11-12T15:00:00Z'))).toBe('over');
    expect(roomTone(plan, at('2026-11-12T15:30:00Z'))).toBe('over');
    // Without a clock of its own the screen trusts the server's flags.
    expect(roomTone(plan)).toBe('running');
    expect(roomTone(room({ ending_soon: true }))).toBe('ending');
    expect(roomTone(room({ package_ended: true, ending_soon: true }))).toBe('over');
  });

  it('says a room is being cleaned or out of service, not free', () => {
    const empty = (state: string) =>
      normalizeResourceBoard({ resources: [{ id: 'posres_x', kind: 'room', state }] }).resources[0];
    expect(roomTone(empty('cleaning'))).toBe('cleaning');
    expect(roomTone(empty('out_of_service'))).toBe('out_of_service');
    expect(roomTone(empty('available'))).toBe('free');
    expect(roomTone(empty('reserved'))).toBe('free');
    expect(ROOM_TONES).toContain('cleaning');
  });

  it('is grey while paused, its countdown stopped with it', () => {
    const paused = room({
      status: 'paused',
      paused_at: '2026-11-12T14:40:00Z',
      planned_end_at: '2026-11-12T14:45:00Z',
    });
    expect(roomTone(paused, at('2026-11-12T16:00:00Z'))).toBe('paused');
    expect(clockAttention(paused, at('2026-11-12T16:00:00Z'))).toBe(false);
    expect(clockAttention(room({ status: 'paused', pause_too_long: true }))).toBe(true);
  });

  it('needs attention when the clock is about to end or has ended', () => {
    const plan = room({ planned_end_at: '2026-11-12T15:00:00Z' });
    expect(needsAttention(plan, { kitchen: false, now: at('2026-11-12T14:30:00Z') })).toBe(false);
    expect(needsAttention(plan, { kitchen: false, now: at('2026-11-12T14:55:00Z') })).toBe(true);
    expect(needsAttention(plan, { kitchen: false, now: at('2026-11-12T15:05:00Z') })).toBe(true);
    expect(needsAttention(room({ ending_soon: true }), { kitchen: false })).toBe(true);
    expect(attentionReasons(room({ ending_soon: true }), { kitchen: false })).toEqual(['clock']);
    expect(
      boardCounts([plan, room(null)], { kitchen: false, now: at('2026-11-12T14:55:00Z') })
        .attention,
    ).toBe(1);
  });

  it('names every reason a room needs attention', () => {
    const asked = room(null, {
      payment_requested: true,
      seated_minutes: 200,
      orders: [{ id: 'ws_1', unsent_kitchen_items: 0 }],
    });
    expect(attentionReasons(asked, { alertMinutes: 120 })).toEqual(['payment', 'long']);
    const unsentDishes = room(null, { orders: [{ id: 'ws_1', unsent_kitchen_items: 2 }] });
    expect(attentionReasons(unsentDishes)).toEqual(['unsent']);
    expect(attentionReasons(unsentDishes, { kitchen: false })).toEqual([]);
    expect(needsAttention(unsentDishes, { kitchen: false })).toBe(false);
    expect(ATTENTION_REASONS).toEqual(['payment', 'unsent', 'long', 'clock']);
  });

  it('paints a timed billiard table in a restaurant board with both tones', () => {
    const billiard = room(
      { planned_end_at: '2026-11-12T15:00:00Z' },
      { kind: 'billiard', state: 'ordered', orders: [{ id: 'ws_2', unsent_kitchen_items: 0 }] },
    );
    const now = at('2026-11-12T14:52:00Z');
    // The table keeps its service tone; the clock adds its own.
    expect(tileTone(billiard)).toBe('serving');
    expect(roomTone(billiard, now)).toBe('ending');
    expect(inBoardChip(billiard, 'attention', { now })).toBe(true);
    expect(inBoardChip(billiard, 'attention', { now: at('2026-11-12T14:00:00Z') })).toBe(false);
  });
});
