import { describe, expect, it } from 'vitest';
import vi from '../../../apps/pos/src/locales/vi.json';
import {
  adjustmentActions,
  canOpenInventory,
  daysUntil,
  describeInventoryFailure,
  describeTraceFailure,
  expiryState,
  formatExpiry,
  inventoryReasonKey,
  inventoryTabs,
  lotChoiceRequired,
  type OrderLineTrace,
  parseLotRows,
  parseSerials,
  parseWholeQuantity,
  paymentBlock,
  returnableLots,
  returnableSerials,
  serialListAfterTab,
  stockEntryPayload,
  traceReasonKey,
} from './traceability';

const translate = (key: string, options: Record<string, unknown> = {}) =>
  ((vi as unknown as Record<string, string>)[key] ?? key).replace(/{{(\w+)}}/g, (_, name) =>
    String(options[name]),
  );
const conflict = (reason: string, message = 'Conflict') => ({
  status: 409,
  message,
  details: { reason },
});

describe('trace refusal reasons', () => {
  it('has a Vietnamese sentence for every reason the sale, stock and return flows name', () => {
    for (const reason of [
      'trace_serial_unavailable',
      'trace_unreconciled',
      'trace_not_enrolled',
      'trace_serial_duplicate',
      'trace_lot_pick_forbidden',
      'trace_lot_invalid',
      'trace_insufficient',
      'trace_serial_released',
      'trace_serial_required',
      'trace_stock_exists',
      'trace_serial_mismatch',
      'trace_lot_mismatch',
      'trace_already_returned',
      'trace_return_detail_required',
      'trace_serial_unit_mismatch',
      'trace_condition_required',
      'trace_allocation_missing',
      'trace_fulfillment_mismatch',
      'trace_count_below_held',
      'trace_serial_invalid',
      'trace_mode_mismatch',
    ]) {
      const key = traceReasonKey(reason);
      expect(key).toBe(`traceReason_${reason}`);
      expect(translate(key ?? '')).not.toBe(key);
    }
    expect(traceReasonKey('lease_busy')).toBeNull();
    expect(traceReasonKey(null)).toBeNull();
  });

  it('names stock command refusals only on stock screens', () => {
    for (const reason of [
      'opening_unreconciled',
      'already_enrolled',
      'enrollment_allocated',
      'lot_expiry_mismatch',
      'lot_quarantined',
      'recall_query_invalid',
      'count_no_change',
      'count_stale',
      'duplicate_lot',
      'duplicate_serial',
      'nothing_to_receive',
      'nothing_to_transfer',
      'self_approval',
      'not_pending',
      'approval_required',
      'already_applied',
      'adjustment_canceled',
    ]) {
      const key = inventoryReasonKey(reason);
      expect(key).toBe(`traceReason_${reason}`);
      expect(translate(key ?? '')).not.toBe(key);
      // The same names in other flows keep their own wording.
      expect(traceReasonKey(reason)).toBeNull();
    }
    expect(inventoryReasonKey('trace_insufficient')).toBe('traceReason_trace_insufficient');
    expect(inventoryReasonKey('trace_checkout_refused')).toBeNull();
  });

  it('describes a refusal with its sentence, and an opening mismatch from its numbers', () => {
    expect(describeTraceFailure(conflict('trace_serial_unavailable'), translate)).toBe(
      translate('traceReason_trace_serial_unavailable'),
    );
    expect(
      describeInventoryFailure(
        {
          status: 409,
          message: 'Typed 3, core 5',
          details: { reason: 'opening_unreconciled', typed_on_hand: 3, core_on_hand: 5 },
        },
        translate,
      ),
    ).toBe('Tồn đầu kỳ không khớp: đã khai báo 3, tồn kho đang ghi 5.');
    // Without the numbers the sentence stands alone; the payload text is not appended.
    expect(describeInventoryFailure(conflict('opening_unreconciled', 'Typed 3'), translate)).toBe(
      translate('traceReason_opening_unreconciled'),
    );
    expect(describeTraceFailure(conflict('approval_required', 'Needs approval'), translate)).toBe(
      'Needs approval',
    );
  });

  it('falls back to the server explanation for other conflicts', () => {
    expect(describeTraceFailure(conflict('something_else', 'Server says no'), translate)).toBe(
      'Server says no',
    );
    expect(describeTraceFailure({ status: 403 }, translate)).toBe(translate('forbidden'));
  });
});

describe('expiry', () => {
  it('counts calendar days and marks expired, near and ok lots', () => {
    expect(daysUntil('2026-11-08', '2026-11-07')).toBe(1);
    expect(daysUntil('2027-01-01', '2026-12-31')).toBe(1);
    expect(daysUntil('not-a-date', '2026-11-07')).toBeNull();
    expect(expiryState('2026-11-06', '2026-11-07')).toBe('expired');
    expect(expiryState('2026-11-07', '2026-11-07')).toBe('near');
    expect(expiryState('2026-12-07', '2026-11-07')).toBe('near');
    expect(expiryState('2026-12-08', '2026-11-07')).toBe('ok');
    expect(expiryState(null, '2026-11-07')).toBe('none');
  });

  it('prints dates the Vietnamese way', () => {
    expect(formatExpiry('2026-12-31')).toBe('31/12/2026');
    expect(formatExpiry(null)).toBe('—');
  });
});

describe('serial entry', () => {
  it('reads one serial per line or scan, keeps order and reports repeats once', () => {
    expect(parseSerials('SN-1\nSN-2\r\n SN-1 ,SN-3;SN-2\n\n')).toEqual({
      codes: ['SN-1', 'SN-2', 'SN-3'],
      duplicates: ['SN-1', 'SN-2'],
      tooLong: [],
    });
    expect(parseSerials('   ').codes).toEqual([]);
    expect(parseSerials('x'.repeat(101)).tooLong).toHaveLength(1);
  });

  it('builds a serial body only from clean input', () => {
    expect(stockEntryPayload('serial', 'A\nB', [])).toEqual({
      body: { serials: ['A', 'B'] },
      error: null,
      codes: [],
    });
    expect(stockEntryPayload('serial', 'A\nA', [])).toMatchObject({
      body: null,
      error: 'inventorySerialDuplicate',
      codes: ['A'],
    });
    expect(stockEntryPayload('serial', '', [])).toMatchObject({ error: 'inventoryNothingEntered' });
    expect(stockEntryPayload('none', 'A', [])).toMatchObject({ error: 'traceReason_not_tracked' });
  });
});

describe('lot rows', () => {
  it('ignores blank rows and sends whole base-unit quantities with optional expiry', () => {
    expect(
      parseLotRows([
        { lot_code: ' L1 ', expiry_on: '2027-01-31', quantity: '12' },
        { lot_code: '', expiry_on: '', quantity: '' },
        { lot_code: 'L2', expiry_on: '', quantity: '500' },
      ]),
    ).toEqual({
      lots: [
        { lot_code: 'L1', expiry_on: '2027-01-31', quantity: 12 },
        { lot_code: 'L2', quantity: 500 },
      ],
      error: null,
    });
  });

  it('refuses missing codes, bad quantities, bad dates and repeated codes', () => {
    const row = (lot_code: string, quantity: string, expiry_on = '') => ({
      lot_code,
      quantity,
      expiry_on,
    });
    expect(parseLotRows([row('', '1')]).error).toBe('inventoryLotCodeInvalid');
    expect(parseLotRows([row('L1', '0')]).error).toBe('inventoryQuantityInvalid');
    expect(parseLotRows([row('L1', '1.5')]).error).toBe('inventoryQuantityInvalid');
    expect(parseLotRows([row('L1', '1', '31/01/2027')]).error).toBe('inventoryExpiryInvalid');
    expect(parseLotRows([row('L1', '1'), row('l1', '2')]).error).toBe('inventoryLotDuplicate');
    expect(parseLotRows([row('', '')]).error).toBe('inventoryNothingEntered');
  });

  it('parses whole quantities, with zero only for counts', () => {
    expect(parseWholeQuantity('7')).toBe(7);
    expect(parseWholeQuantity('0')).toBeNull();
    expect(parseWholeQuantity('0', true)).toBe(0);
    expect(parseWholeQuantity('-1', true)).toBeNull();
    expect(parseWholeQuantity('')).toBeNull();
  });
});

describe('returnable serials and lots', () => {
  const serialTrace: OrderLineTrace = {
    mode: 'serial',
    allocations: [
      { serial: 'SN-1', lot_code: null, expiry_on: null, quantity: 1, returned_quantity: 1 },
      { serial: 'SN-2', lot_code: null, expiry_on: null, quantity: 1, returned_quantity: 0 },
      { serial: 'SN-3', lot_code: null, expiry_on: null, quantity: 1, returned_quantity: 0 },
    ],
  };
  const lotTrace = (allocations: OrderLineTrace['allocations']): OrderLineTrace => ({
    mode: 'lot',
    allocations,
  });

  it('offers only serials not yet returned', () => {
    expect(returnableSerials(serialTrace)).toEqual(['SN-2', 'SN-3']);
    expect(returnableSerials(null)).toEqual([]);
  });

  it('merges lots by code and asks for the lot only when several remain', () => {
    const several = lotTrace([
      { serial: null, lot_code: 'L1', expiry_on: '2027-01-01', quantity: 2, returned_quantity: 1 },
      { serial: null, lot_code: 'L2', expiry_on: '2027-02-01', quantity: 3, returned_quantity: 0 },
      { serial: null, lot_code: 'L1', expiry_on: '2027-01-01', quantity: 1, returned_quantity: 0 },
    ]);
    expect(returnableLots(several)).toEqual([
      { lot_code: 'L1', expiry_on: '2027-01-01', remaining: 2 },
      { lot_code: 'L2', expiry_on: '2027-02-01', remaining: 3 },
    ]);
    expect(lotChoiceRequired(several)).toBe(true);
    const one = lotTrace([
      { serial: null, lot_code: 'L1', expiry_on: null, quantity: 2, returned_quantity: 2 },
      { serial: null, lot_code: 'L2', expiry_on: null, quantity: 3, returned_quantity: 0 },
    ]);
    expect(lotChoiceRequired(one)).toBe(false);
    expect(lotChoiceRequired(serialTrace)).toBe(false);
  });
});

describe('payment block', () => {
  const lines = [{ id: 'li_1', sale_line_id: 'sl_1', name: 'Điện thoại' }];

  it('treats payloads without trace as ready', () => {
    expect(paymentBlock({ line_items: lines })).toEqual({
      ready: true,
      issues: [],
      fixable: false,
    });
    expect(paymentBlock({ trace: null, line_items: lines }).ready).toBe(true);
    expect(paymentBlock({ trace: { ready: true, issues: [] }, line_items: lines }).ready).toBe(
      true,
    );
  });

  it('names the lines and reasons that keep payment closed', () => {
    expect(
      paymentBlock({
        trace: {
          ready: false,
          issues: [
            { sale_line_id: 'sl_1', reason: 'trace_serial_released' },
            { sale_line_id: 'sl_9', reason: 'trace_insufficient' },
          ],
        },
        line_items: lines,
      }),
    ).toEqual({
      ready: false,
      issues: [
        { saleLineId: 'sl_1', name: 'Điện thoại', reason: 'trace_serial_released' },
        { saleLineId: 'sl_9', name: 'sl_9', reason: 'trace_insufficient' },
      ],
      fixable: true,
    });
    // Unreconciled stock needs a stock keeper; holding again cannot fix it.
    expect(
      paymentBlock({
        trace: { ready: false, issues: [{ sale_line_id: 'sl_1', reason: 'trace_unreconciled' }] },
        line_items: lines,
      }).fixable,
    ).toBe(false);
  });
});

describe('inventory permissions', () => {
  it('opens the page for stock managers and tracers', () => {
    expect(canOpenInventory(['pos.inventory.manage'])).toBe(true);
    expect(canOpenInventory(['pos.inventory.trace'])).toBe(true);
    expect(canOpenInventory(['pos.shift.open'])).toBe(false);
    expect(canOpenInventory(undefined)).toBe(false);
    expect(canOpenInventory(['pos.approval.grant'])).toBe(true);
  });

  it('shows approvers only the adjustment tab', () => {
    expect(inventoryTabs(['pos.approval.grant'])).toEqual(['adjust']);
    expect(inventoryTabs(['pos.inventory.trace'])).toEqual([
      'variants',
      'lots',
      'serials',
      'recall',
    ]);
    expect(inventoryTabs(['pos.inventory.manage'])).toEqual([
      'variants',
      'lots',
      'serials',
      'receive',
      'transfer',
      'adjust',
    ]);
    expect(inventoryTabs(['pos.shift.open'])).toEqual([]);
  });

  it('turns a Tab after a scanned serial into a line break', () => {
    expect(serialListAfterTab('SN-1', false)).toBe('SN-1\n');
    expect(serialListAfterTab('SN-1\n', false)).toBeNull();
    expect(serialListAfterTab('', false)).toBeNull();
    expect(serialListAfterTab('SN-1', true)).toBeNull();
  });

  it('lets another approver approve, the requester apply, and either cancel', () => {
    const pending = {
      status: 'pending_approval' as const,
      requester_id: 'stf_1',
      approval: null,
      requires_approval: true,
    };
    const approver = ['pos.approval.grant', 'pos.inventory.manage'];
    expect(adjustmentActions(pending, 'stf_2', approver)).toEqual({
      approve: true,
      apply: false,
      cancel: true,
    });
    expect(adjustmentActions(pending, 'stf_1', approver)).toEqual({
      approve: false,
      apply: false,
      cancel: true,
    });
    const approved = {
      ...pending,
      approval: { id: 'ap_1', status: 'active', expires_at: '2026-11-07T10:00:00Z' },
    };
    expect(adjustmentActions(approved, 'stf_1', ['pos.inventory.manage'])).toEqual({
      approve: false,
      apply: true,
      cancel: true,
    });
    expect(adjustmentActions(approved, 'stf_2', approver).approve).toBe(false);
    expect(adjustmentActions({ ...pending, status: 'applied' }, 'stf_1', approver)).toEqual({
      approve: false,
      apply: false,
      cancel: false,
    });
    expect(adjustmentActions(pending, 'stf_3', ['pos.inventory.manage']).cancel).toBe(false);
  });
});
