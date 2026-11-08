import { describe, expect, it } from 'vitest';
import i18n from '../i18n';
import { formatInvoiceTicket } from './invoice-ticket';
import type { PosFinancialAttempt, PosWorkspace } from './pos-context';
import { pageRule } from './print-adapter';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

const workspace = {
  id: 'ws_1',
  order_id: 'R1001',
  customer: null,
  coupon: null,
  line_items: [
    {
      id: 'li_1',
      name: 'Nước suối',
      quantity: 2,
      price: '10000.0',
      amount: '20000.0',
      item_net_amount: '18000.0',
      discounts: [],
      item_discount: {
        amount: '2000.0',
        source: 'manual',
        value_type: 'flat',
        value: '1000',
        labels: [],
      },
    },
    {
      id: 'li_2',
      name: 'Bánh mì',
      quantity: 1,
      price: '15000.0',
      amount: '15000.0',
      discounts: [],
      line_discount: {
        id: 'd',
        value_type: 'unit_price',
        value: '12000.0',
        reason: '',
        amount: '3000.0',
      },
    },
  ],
  totals: {
    item_total: '35000.0',
    discount_total: '2000.0',
    manual_discount_total: '0',
    included_tax_total: '0',
    additional_tax_total: '0',
    total: '30000.0',
    currency: 'VND',
  },
} as unknown as PosWorkspace;

const cash = { id: 'a1', kind: 'cash', amount: '30000.0', currency: 'VND' } as PosFinancialAttempt;

describe('formatInvoiceTicket', () => {
  it('lays items out as table rows with a per-item discount column', () => {
    const ticket = formatInvoiceTicket(
      {
        workspace,
        attempts: [cash],
        handed: '50000',
        change: '20000',
        names: { storeName: 'ParkViet' },
      },
      t,
      new Date('2026-11-07T03:00:00Z'),
    );
    expect(ticket.header).toEqual(['ParkViet']);
    expect(ticket.title).toBe('HÓA ĐƠN THANH TOÁN');
    expect(ticket.lines[0]).toEqual({
      name: 'Nước suối',
      quantity: '2',
      price: '10.000',
      discount: '2.000',
      total: '18.000',
    });
    // A price override shows the overridden unit price and no discount cell.
    expect(ticket.lines[1]).toMatchObject({ price: '12.000', discount: '' });
    expect(ticket.totals.at(-1)).toEqual({ label: 'Tổng cộng', value: '30.000 ₫', strong: true });
    expect(ticket.payments).toEqual([
      { label: 'Tiền mặt', value: '30.000 ₫' },
      { label: 'Khách đưa', value: '50.000 ₫' },
      { label: 'Tiền thừa trả khách', value: '20.000 ₫' },
    ]);
  });

  it('leaves handed cash off until the cashier enters it', () => {
    const ticket = formatInvoiceTicket(
      { workspace, attempts: [cash], handed: null, change: null, names: {} },
      t,
    );
    expect(ticket.payments).toEqual([{ label: 'Tiền mặt', value: '30.000 ₫' }]);
  });

  it('sizes the page for 58mm rolls', () => {
    expect(pageRule('58mm')).toContain('size: 58mm 297mm');
  });
});
