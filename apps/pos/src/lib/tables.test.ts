import { normalizeResourceBoard } from '@parkviet/pos-shared/tables';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { PosContext, PosWorkspace } from './pos-context';
import {
  approvalAction,
  canServeTables,
  describeTableFailure,
  inSelection,
  isTableOrder,
  mergeTargets,
  moveTargets,
  savedTableSurface,
  saveTableSurface,
  TABLE_SURFACE_KEY,
  tableOrderName,
  tableOrderOf,
} from './tables';

const workspace = (extra: Record<string, unknown> = {}) =>
  ({
    id: 'ws_1',
    branch_id: 'br_1',
    register_id: 'reg_2',
    shift_id: 'sh_2',
    order_id: 'R100',
    revision: 1,
    lease_generation: 1,
    operational_status: 'editing',
    payments: false,
    ...extra,
  }) as PosWorkspace;

const conflict = (reason: string, extra: Record<string, unknown> = {}) => ({
  status: 409,
  message: 'Refused.',
  details: { reason, ...extra },
});

describe('table orders', () => {
  it('reads the table fields of a workspace and ignores malformed ones', () => {
    const order = tableOrderOf(
      workspace({
        resource: { id: 'posres_4', name: 'Bàn 4', kind: 'table', area_id: 'posarea_1' },
        guest_count: 3,
        table_label: 'B',
        service_charge: { rate: '5.0', amount: '5000.0', waived: false, applies: true },
        prebill: { id: 'pospre_1', sequence: 2, status: 'current', stale: true },
        payment_request: { id: 'pospayreq_1', status: 'open' },
      }),
    );
    expect(order).toEqual({
      table: { id: 'posres_4', name: 'Bàn 4', area_id: 'posarea_1' },
      guestCount: 3,
      label: 'B',
      serviceCharge: { rate: '5.0', amount: '5000.0', waived: false, applies: true },
      prebill: { id: 'pospre_1', sequence: 2, status: 'current', stale: true },
      paymentRequest: { id: 'pospayreq_1', status: 'open' },
    });
    expect(
      tableOrderOf(
        workspace({ resource: 'Bàn 4', guest_count: '3', prebill: { id: 'x', status: 'odd' } }),
      ),
    ).toEqual({
      table: null,
      guestCount: null,
      label: null,
      serviceCharge: null,
      prebill: null,
      paymentRequest: null,
    });
    expect(isTableOrder(workspace())).toBe(false);
    expect(isTableOrder(null)).toBe(false);
  });

  it('keeps a table order on the selling page whatever register it is booked on', () => {
    const selection = { branchId: 'br_1', registerId: 'reg_1' };
    expect(inSelection(workspace(), selection)).toBe(false);
    expect(inSelection(workspace({ register_id: 'reg_1' }), selection)).toBe(true);
    const atTable = workspace({ resource: { id: 'posres_4', name: 'Bàn 4' } });
    expect(inSelection(atTable, selection)).toBe(true);
    expect(inSelection(atTable, { ...selection, branchId: 'br_2' })).toBe(false);
  });

  it('lets people serving tables and cashiers seat guests', () => {
    const context = (capabilities: string[]) => ({ capabilities }) as PosContext;
    expect(canServeTables(undefined)).toBe(false);
    expect(canServeTables(context(['pos.table.serve']))).toBe(true);
    expect(canServeTables(context(['pos.shift.open']))).toBe(true);
    expect(canServeTables(context(['pos.payment.collect']))).toBe(false);
  });

  it('offers free tables to move to and the other open orders to merge into', () => {
    const board = normalizeResourceBoard({
      resources: [
        {
          id: 'posres_1',
          name: 'Bàn 1',
          state: 'ordered',
          orders: [{ id: 'ws_1', table_label: null }],
        },
        {
          id: 'posres_2',
          name: 'Bàn 2',
          state: 'occupied',
          orders: [
            { id: 'ws_2', table_label: 'A' },
            { id: 'ws_3', table_label: 'B' },
          ],
        },
        { id: 'posres_3', name: 'Bàn 3', state: 'available', orders: [] },
        { id: 'posres_4', name: 'Bàn 4', state: 'cleaning', orders: [] },
      ],
    });
    expect(moveTargets(board.resources, 'posres_1').map((row) => row.id)).toEqual(['posres_3']);
    expect(mergeTargets(board.resources, 'ws_1')).toEqual([
      { id: 'ws_2', name: 'Bàn 2 · A' },
      { id: 'ws_3', name: 'Bàn 2 · B' },
    ]);
    expect(tableOrderName('Bàn 1', null)).toBe('Bàn 1');
  });

  it('words the table refusals and falls back to the workspace wording', () => {
    const t = (key: string) => key;
    expect(describeTableFailure(conflict('table_occupied'), t)).toBe('tableFailure_table_occupied');
    expect(describeTableFailure(conflict('no_open_shift'), t)).toBe('tableFailure_no_open_shift');
    expect(describeTableFailure(conflict('lease_stale'), t)).toBe('leaseStale');
    expect(describeTableFailure({ status: 403 }, t)).toBe('forbidden');
  });

  it('reads the approval a refused pre-bill needs', () => {
    expect(
      approvalAction(conflict('approval_required', { action: 'workspace.reprint_prebill' })),
    ).toBe('workspace.reprint_prebill');
    expect(approvalAction(conflict('approval_required'))).toBeNull();
    expect(approvalAction(conflict('workspace_closed'))).toBeNull();
  });
});

describe('device floor view', () => {
  beforeEach(() => {
    const store = new Map<string, string>();
    vi.stubGlobal('window', {
      localStorage: {
        getItem: (key: string) => store.get(key) ?? null,
        setItem: (key: string, value: string) => store.set(key, value),
      },
    });
  });
  afterEach(() => vi.unstubAllGlobals());

  it('remembers tiles or the plan and ignores anything else', () => {
    expect(savedTableSurface()).toBeNull();
    saveTableSurface('floor_plan');
    expect(window.localStorage.getItem(TABLE_SURFACE_KEY)).toBe('floor_plan');
    expect(savedTableSurface()).toBe('floor_plan');
    window.localStorage.setItem(TABLE_SURFACE_KEY, 'menu_grid');
    expect(savedTableSurface()).toBeNull();
  });

  it('keeps working when storage is unavailable', () => {
    vi.stubGlobal('window', {
      get localStorage() {
        throw new Error('Storage unavailable');
      },
    });
    expect(savedTableSurface()).toBeNull();
    expect(() => saveTableSurface('table_grid')).not.toThrow();
  });
});
