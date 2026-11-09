import { describe, expect, it } from 'vitest';
import {
  canHandleDeliveries,
  deliveryFailureKey,
  hasOwed,
  normalizeDeliverer,
  normalizeDeliveryFee,
  telHref,
} from './deliveries';
import type { PosWorkspace } from './pos-context';
import type { ReceiptSnapshot } from './print-adapter';
import { paymentTicketData, prebillData, snapshotData } from './receipt-template/data';

const t = (key: string, options?: Record<string, unknown>) =>
  options ? `${key}:${JSON.stringify(options)}` : key;

describe('delivery helpers', () => {
  it('lets sellers and collectors handle deliveries', () => {
    expect(canHandleDeliveries(['pos.shift.open'])).toBe(true);
    expect(canHandleDeliveries(['pos.payment.collect'])).toBe(true);
    expect(canHandleDeliveries(['pos.report.read'])).toBe(false);
    expect(canHandleDeliveries(undefined)).toBe(false);
  });

  it('makes a phone link the phone app opens', () => {
    expect(telHref('0901 234 567')).toBe('tel:0901234567');
    expect(telHref('+84 90-123-4567')).toBe('tel:+84901234567');
    expect(telHref('  ')).toBeNull();
    expect(telHref(null)).toBeNull();
  });

  it('reads the fee as typed in whole đồng', () => {
    expect(normalizeDeliveryFee('')).toBe('0');
    expect(normalizeDeliveryFee('20.000')).toBe('20000');
    expect(normalizeDeliveryFee('20,000')).toBe('20000');
    expect(normalizeDeliveryFee(' 15 000 ')).toBe('15000');
    expect(normalizeDeliveryFee('015000')).toBe('15000');
    expect(normalizeDeliveryFee('-5')).toBeNull();
    expect(normalizeDeliveryFee('abc')).toBeNull();
    expect(normalizeDeliveryFee('1234567890')).toBeNull();
  });

  it('keeps the deliverer as the server will', () => {
    expect(normalizeDeliverer('  Chị   Lan ')).toBe('Chị Lan');
    expect(normalizeDeliverer('x'.repeat(90))).toHaveLength(80);
  });

  it('names delivery refusals and spots an open debt', () => {
    expect(deliveryFailureKey('delivery_fee_invalid')).toBe('deliveryFeeInvalid');
    expect(deliveryFailureKey('deliverer_invalid')).toBe('deliveryDelivererInvalid');
    expect(deliveryFailureKey('delivery_not_placed')).toBe('deliveriesNotPlaced');
    expect(deliveryFailureKey('lease_stale')).toBeNull();
    expect(hasOwed({ owed: '0.0' })).toBe(false);
    expect(hasOwed({ owed: '75000.0' })).toBe(true);
  });
});

const delivery = {
  id: 'posdelivery_1',
  status: 'pending' as const,
  deliverer: 'Bố',
  fee: '20000.0',
  delivered_at: null,
  delivered_by: null,
};

const workspace: PosWorkspace = {
  id: 'posworkspace_1',
  branch_id: 'br_1',
  register_id: null,
  shift_id: 'sh_1',
  order_id: 'R100',
  revision: 3,
  lease_generation: 1,
  operational_status: 'editing',
  payments: false,
  line_items: [],
  totals: {
    item_total: '100000.0',
    discount_total: '0.0',
    manual_discount_total: '0.0',
    included_tax_total: '0.0',
    additional_tax_total: '0.0',
    fee_total: '20000.0',
    total: '120000.0',
    currency: 'VND',
  },
  delivery,
};

const labels = (rows: { label: string }[]) => rows.map((row) => row.label);

describe('delivery on printed documents', () => {
  it('prints the deliverer and the fee just before the total on a sale receipt', () => {
    const receipt: ReceiptSnapshot = {
      id: 'rcpt_1',
      source_type: 'sale',
      number: 'R100',
      branch_id: 'br_1',
      issued_at: '2026-11-09T08:00:00Z',
      issued_late: false,
      disclaimer: 'x',
      printed: false,
      copy_count: 0,
      document: {
        currency: 'VND',
        totals: { item_total: '100000.0', discount_total: '0.0', total: '120000.0' },
        receipts: [],
        paid_total: '120000.0',
        delivery: { deliverer: 'Bố', fee: '20000.0' },
      },
    };
    const data = snapshotData(receipt, t);
    expect(data.meta.find((row) => row.label === 'receiptDelivery')).toMatchObject({
      field: null,
      value: 'Bố',
    });
    expect(labels(data.totals)).toEqual(['receiptItemTotal', 'receiptDeliveryFee', 'receiptTotal']);
    expect(data.totals[1]).toMatchObject({ field: null });
  });

  it('leaves a counter sale and a free delivery without a fee row', () => {
    const receipt = {
      source_type: 'sale',
      number: 'R101',
      issued_at: '2026-11-09T08:00:00Z',
      issued_late: false,
      disclaimer: 'x',
      document: {
        totals: { item_total: '50000.0', total: '50000.0' },
        delivery: { deliverer: null, fee: '0.0' },
      },
    } as unknown as ReceiptSnapshot;
    const data = snapshotData(receipt, t);
    expect(data.meta.find((row) => row.label === 'receiptDelivery')?.value).toBe(
      'receiptDeliveryYes',
    );
    expect(labels(data.totals)).not.toContain('receiptDeliveryFee');
    const counter = snapshotData({ ...receipt, document: { totals: {} } }, t);
    expect(labels(counter.meta)).not.toContain('receiptDelivery');
  });

  it('prints the delivery on the pre-bill and the payment ticket', () => {
    const prebill = prebillData(workspace, {}, t);
    expect(labels(prebill.meta)).toContain('receiptDelivery');
    expect(labels(prebill.totals)).toEqual([
      'receiptItemTotal',
      'receiptDeliveryFee',
      'receiptTotal',
    ]);
    const ticket = paymentTicketData(
      { workspace, attempts: [], handed: null, change: null, names: {} },
      t,
    );
    expect(labels(ticket.meta)).toContain('receiptDelivery');
    expect(labels(ticket.totals)).toContain('receiptDeliveryFee');
    const plain = prebillData({ ...workspace, delivery: null }, {}, t);
    expect(labels(plain.totals)).not.toContain('receiptDeliveryFee');
  });
});
