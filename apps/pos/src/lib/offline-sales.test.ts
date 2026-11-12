import { describe, expect, it } from 'vitest';
import {
  addLine,
  changeDue,
  changeQuantity,
  ingestBody,
  MAX_ITEMS,
  MAX_PENDING_AGE_MS,
  MAX_QUEUED_SALES,
  menuLine,
  provisionalNumber,
  queueBlock,
  saleTotal,
  snapshotState,
} from './offline-sales';
import type { OfflineSaleLine, OfflineSnapshot, QueuedSale, StoredSnapshot } from './offline-store';
import type { PosMenu } from './pos-context';

const menu: PosMenu = {
  branch_id: 'posbranch_1',
  currency: 'VND',
  business_date: '2026-11-12',
  module_enabled: true,
  categories: [],
  items: [
    {
      id: 'posmenuitem_tea',
      product_id: 'prod_1',
      name: 'Trà sữa',
      kind: 'single',
      menu_category_id: 'posmenucat_1',
      kitchen_category: null,
      cup_label: false,
      show_components_on_kds: false,
      position: 0,
      active: true,
      tax_category_id: null,
      modifier_group_ids: ['posmodgroup_topping'],
      components: [],
      image_url: null,
      sold_out: false,
      variants: [
        {
          id: 'variant_tea',
          name: '',
          sku: 'TS',
          barcode: null,
          price: '30000.0',
          list_price: '30000.0',
          schedule_id: null,
        },
      ],
    },
    {
      id: 'posmenuitem_flan',
      product_id: 'prod_2',
      name: 'Bánh flan',
      kind: 'single',
      menu_category_id: 'posmenucat_1',
      kitchen_category: null,
      cup_label: false,
      show_components_on_kds: false,
      position: 1,
      active: true,
      tax_category_id: null,
      modifier_group_ids: [],
      components: [],
      image_url: null,
      sold_out: true,
      variants: [
        {
          id: 'variant_flan',
          name: '',
          sku: 'BF',
          barcode: null,
          price: '15000.0',
          list_price: '15000.0',
          schedule_id: null,
        },
      ],
    },
  ],
  modifier_groups: [
    {
      id: 'posmodgroup_topping',
      name: 'Topping',
      min_select: 0,
      max_select: 3,
      allow_quantity: true,
      required: false,
      position: 0,
      options: [
        {
          id: 'opt_pearl',
          name: 'Trân châu',
          price_delta: '5000.0',
          variant_id: null,
          default_selected: true,
          position: 0,
          active: true,
        },
      ],
    },
  ],
  schedules: [],
  favorites: [],
  etag: 'e',
};

function snapshot(overrides: Partial<OfflineSnapshot> = {}): StoredSnapshot {
  return {
    savedAt: 1_000_000,
    data: {
      store: { id: 'store_1', name: 'ParkViet', currency: 'VND' },
      branch: { id: 'posbranch_1', name: 'CN1', code: 'CN1', timezone: 'Asia/Ho_Chi_Minh' },
      register: { id: 'posreg_1', name: 'Quầy 1', code: 'Q1' },
      staff: { id: 'staff_1', name: 'Lan' },
      shift: { id: 'posshift_1', opened_at: '2026-11-12T01:00:00Z' },
      offline: { allowed: true, reason: null },
      menu,
      etag: 'x',
      generated_at: '2026-11-12T01:00:00Z',
      max_age_seconds: 12 * 3600,
      ...overrides,
    },
  };
}

function sale(soldAt: string): QueuedSale {
  return {
    offlineId: crypto.randomUUID(),
    staffId: 'staff_1',
    storeId: 'store_1',
    branchId: 'posbranch_1',
    registerId: 'posreg_1',
    shiftId: 'posshift_1',
    provisionalNumber: 'OFF-Q1-261112-001',
    soldAt,
    total: '35000.00',
    handedAmount: '50000',
    currency: 'VND',
    lines: [],
    status: 'pending',
    attempts: 0,
    lastError: null,
    savedAt: 1,
  };
}

describe('offline snapshot', () => {
  it('sells only from a fresh snapshot of an open shift that allows it', () => {
    expect(snapshotState(null)).toBe('missing');
    expect(snapshotState(snapshot(), 1_000_000 + 60_000)).toBe('ready');
    expect(snapshotState(snapshot(), 1_000_000 + 12 * 3600 * 1000 + 1)).toBe('stale');
    // A clock set back before the snapshot arrived is not trusted either.
    expect(snapshotState(snapshot(), 999_999)).toBe('stale');
    expect(snapshotState(snapshot({ shift: null }), 1_000_000)).toBe('shift_closed');
    expect(
      snapshotState(
        snapshot({ offline: { allowed: false, reason: 'cash_unavailable' } }),
        1_000_000,
      ),
    ).toBe('cash_unavailable');
  });

  it('never trusts a snapshot past twelve hours, whatever the server said', () => {
    expect(
      snapshotState(snapshot({ max_age_seconds: 48 * 3600 }), 1_000_000 + 13 * 3600 * 1000),
    ).toBe('stale');
  });
});

describe('offline queue bounds', () => {
  it('stops taking sales when the queue is full or a sale waited a day', () => {
    const now = Date.parse('2026-11-12T10:00:00Z');
    expect(queueBlock([sale('2026-11-12T09:00:00Z')], now)).toBeNull();
    expect(
      queueBlock(
        Array.from({ length: MAX_QUEUED_SALES }, () => sale('2026-11-12T09:00:00Z')),
        now,
      ),
    ).toBe('queue_full');
    expect(queueBlock([sale(new Date(now - MAX_PENDING_AGE_MS - 1).toISOString())], now)).toBe(
      'queue_too_old',
    );
  });
});

describe('offline lines', () => {
  it('prices a pick like the menu shows it, defaults included', () => {
    const line = menuLine(menu, 'variant_tea', undefined, undefined) as OfflineSaleLine;
    expect(line).toMatchObject({
      unit_price: '35000.00',
      modifiers: [{ option_id: 'opt_pearl', quantity: 1 }],
      modifier_names: ['Trân châu'],
      quantity: 1,
    });
    const two = menuLine(menu, 'variant_tea', [{ option_id: 'opt_pearl', quantity: 2 }], ' ít đá ');
    expect(two).toMatchObject({ unit_price: '40000.00', note: 'ít đá' });
  });

  it('refuses an item sold out or not on the menu', () => {
    expect(menuLine(menu, 'variant_flan', undefined, undefined)).toBeNull();
    expect(menuLine(menu, 'variant_gone', undefined, undefined)).toBeNull();
  });

  it('joins the same pick, sums in hundredths and keeps the server limits', () => {
    const line = menuLine(menu, 'variant_tea', undefined, undefined) as OfflineSaleLine;
    let lines = addLine([], line).lines;
    lines = addLine(lines, line).lines;
    expect(lines).toHaveLength(1);
    expect(lines[0]?.quantity).toBe(2);
    expect(saleTotal(lines)).toBe('70000.00');
    expect(changeDue('70000.00', '100000')).toBe('30000.00');
    expect(changeDue('70000.00', '50000')).toBeNull();
    expect(changeQuantity(lines, 0, -2)).toEqual([]);
    const full = [
      { ...line, quantity: 20 },
      { ...line, note: 'a', quantity: 20 },
      { ...line, note: 'b', quantity: MAX_ITEMS - 40 },
    ];
    expect(addLine(full, line).refused).toBe('too_many');
  });
});

describe('provisional numbers and replay', () => {
  it('numbers by register, branch day and sequence within the server pattern', () => {
    const number = provisionalNumber(
      'Quầy #1!',
      new Date('2026-11-12T18:30:00Z'),
      'Asia/Ho_Chi_Minh',
      7,
    );
    // 18:30 UTC is already the 13th in Saigon.
    expect(number).toBe('OFF-Quy1-261113-007');
    expect(number).toMatch(/^OFF-[A-Za-z0-9-]{1,32}$/);
    expect(provisionalNumber(null, new Date('2026-11-12T01:00:00Z'), null, 1)).toBe(
      'OFF-Q-261112-001',
    );
  });

  it('replays the sale as recorded, without display-only fields', () => {
    const line = menuLine(menu, 'variant_tea', undefined, undefined) as OfflineSaleLine;
    const queued = { ...sale('2026-11-12T09:00:00Z'), lines: [line] };
    const body = ingestBody(queued, new Date('2026-11-12T09:05:00Z'));
    expect(body).toMatchObject({
      offline_id: queued.offlineId,
      client_sold_at: '2026-11-12T09:00:00Z',
      client_now: '2026-11-12T09:05:00.000Z',
      total: '35000.00',
      handed_amount: '50000',
    });
    expect(body.lines[0]).not.toHaveProperty('modifier_names');
  });
});
