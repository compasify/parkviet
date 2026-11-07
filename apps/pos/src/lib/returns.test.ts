import { describe, expect, it } from 'vitest';
import {
  canCancelRefund,
  canCancelReturn,
  canFailRefund,
  compareMoney,
  dateRangeInvalid,
  defaultRefundAmount,
  fromUnits,
  minMoney,
  type PosOrderLine,
  parseQuantityInput,
  prepareIntent,
  saleQuantityLabel,
  selectionError,
  selectionLines,
  subtractMoney,
  sumMoney,
  toUnits,
} from './returns';

function line(id: string, returnable: number): PosOrderLine {
  return {
    sale_line_id: id,
    name: id,
    sku: null,
    sale_quantity: '5',
    sale_unit: 'item',
    base_quantity: 5,
    base_unit: 'item',
    unit_price: '0.4',
    lot_code: null,
    serial_codes: [],
    original: { total: '2', net: '2', tax: '0', discount: '0', gross: '2' },
    returned_quantity: 5 - returnable,
    posted_quantity: 0,
    returnable_quantity: returnable,
    handed_over: true,
    entitlement_used: '0',
    entitlement_reserved: '0',
  };
}

describe('return money helpers', () => {
  it('adds fractional base-unit values exactly, without floating point', () => {
    expect(sumMoney(['0.4', '0.4', '0.4', '0.4', '0.4'])).toBe('2');
    expect(sumMoney(['0.1', '0.2'])).toBe('0.3');
    expect(sumMoney(['0', '1', '1'])).toBe('2');
    expect(sumMoney(['999999999999999999.9999', '0.0001'])).toBe('1000000000000000000');
  });

  it('reads canonical server strings and refuses anything else', () => {
    expect(toUnits('150000.0')).toBe(1_500_000_000n);
    expect(fromUnits(toUnits('-12.3456'))).toBe('-12.3456');
    expect(() => toUnits('1,5')).toThrow();
    expect(() => toUnits('1e3')).toThrow();
    expect(subtractMoney('300000.0', '300000')).toBe('0');
    expect(minMoney('300000', '120000.5', '999999')).toBe('120000.5');
    expect(compareMoney('2', '1.9999')).toBe(1);
  });

  it('defaults a refund to the smaller of the entitlement left and the receipt left', () => {
    expect(
      defaultRefundAmount({ refundable_remaining: '300000.0' }, { refundable: '200000.0' }),
    ).toBe('200000');
    expect(defaultRefundAmount({ refundable_remaining: '0' }, { refundable: '200000.0' })).toBe(
      '0',
    );
  });
});

describe('return selection', () => {
  const lines = [line('a', 3), line('b', 0)];

  it('sends only positive whole quantities within the remaining returnable units', () => {
    expect(selectionLines(lines, { a: { quantity: 2, condition: 'damaged' } })).toEqual([
      { sale_line_id: 'a', quantity: 2, condition: 'damaged' },
    ]);
    expect(selectionLines(lines, { a: { quantity: 4, condition: 'resellable' } })).toEqual([]);
    expect(selectionError(lines, { a: { quantity: 4, condition: 'resellable' } })).toBe(
      'returnQuantityTooMany',
    );
    expect(selectionError(lines, { b: { quantity: 1, condition: 'resellable' } })).toBe(
      'returnQuantityTooMany',
    );
    expect(selectionError(lines, {})).toBe('returnNothingSelected');
    expect(selectionError(lines, { a: { quantity: 1, condition: 'resellable' } })).toBeNull();
  });

  it('parses typed quantities as whole base units only', () => {
    expect(parseQuantityInput('3')).toBe(3);
    expect(parseQuantityInput('')).toBe(0);
    expect(parseQuantityInput('1.5')).toBeNull();
    expect(parseQuantityInput('-1')).toBeNull();
  });
});

describe('return permissions and intents', () => {
  const refund = { status: 'reserved' as const, approval: null, requester_id: 'stf_1' };
  const returnCaps = ['pos.return.process'];

  it('lets the requester or an approver cancel a refund only before any approval', () => {
    expect(canCancelRefund(refund, 'stf_1', returnCaps)).toBe(true);
    expect(canCancelRefund(refund, 'stf_2', returnCaps)).toBe(false);
    expect(canCancelRefund(refund, 'stf_2', ['pos.approval.grant'])).toBe(true);
    const approved = { ...refund, approval: { id: 'a', status: 'active', expires_at: '' } };
    expect(canCancelRefund(approved, 'stf_1', ['pos.approval.grant'])).toBe(false);
    expect(canFailRefund({ status: 'unknown' }, ['pos.payment.resolve'])).toBe(true);
    expect(canFailRefund({ status: 'unknown' }, returnCaps)).toBe(false);
    expect(canCancelReturn({ status: 'ready', requester_id: 'stf_1' }, 'stf_2', returnCaps)).toBe(
      false,
    );
    expect(
      canCancelReturn({ status: 'received', requester_id: 'stf_1' }, 'stf_1', returnCaps),
    ).toBe(false);
  });

  it('derives one prepare intent per order and lines, whatever their order', () => {
    const a = prepareIntent('or_1', [
      { sale_line_id: 'b', quantity: 1, condition: 'damaged' },
      { sale_line_id: 'a', quantity: 2, condition: 'resellable' },
    ]);
    const b = prepareIntent('or_1', [
      { sale_line_id: 'a', quantity: 2, condition: 'resellable' },
      { sale_line_id: 'b', quantity: 1, condition: 'damaged' },
    ]);
    expect(a).toBe(b);
    expect(
      prepareIntent('or_1', [{ sale_line_id: 'a', quantity: 3, condition: 'resellable' }]),
    ).not.toBe(a);
  });

  it('shows weighed lines in their sale unit and validates date ranges', () => {
    expect(
      saleQuantityLabel({
        sale_quantity: '1.25',
        sale_unit: 'kg',
        base_quantity: 1250,
        base_unit: 'g',
      }),
    ).toBe('1,25 kg (1250 g)');
    expect(
      saleQuantityLabel({
        sale_quantity: '3.0',
        sale_unit: 'item',
        base_quantity: 3,
        base_unit: 'item',
      }),
    ).toBe('3 item');
    expect(dateRangeInvalid('2026-11-07', '2026-11-01')).toBe(true);
    expect(dateRangeInvalid('2026-11-01', '')).toBe(false);
  });
});
