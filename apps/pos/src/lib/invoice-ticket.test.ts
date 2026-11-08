import { describe, expect, it } from 'vitest';
import i18n from '../i18n';
import { invoiceTicketPrintDocument } from './invoice-ticket';
import type { PosFinancialAttempt, PosWorkspace } from './pos-context';
import { pageRule } from './print-adapter';
import { DEFAULT_TEMPLATES } from './receipt-template/defaults';
import type { PrintBlock, PrintDocument, TemplateConfig } from './receipt-template/types';

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

const textLines = (blocks: PrintBlock[]) =>
  blocks.flatMap((block) => (block.kind === 'text' ? block.lines : []));
const titleOf = (document: PrintDocument) =>
  document.header.find((block) => block.kind === 'title');
const tableOf = (document: PrintDocument) => {
  if (document.lines.layout !== 'table') throw new Error('expected the table layout');
  return document.lines;
};
const cell = (document: PrintDocument, row: number, key: string) => {
  const table = tableOf(document);
  return table.rows[row].cells[table.columns.findIndex((column) => column.key === key)];
};

describe('invoiceTicketPrintDocument', () => {
  it('lays items out as table rows with a per-item discount column', () => {
    const ticket = invoiceTicketPrintDocument(
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
    expect(textLines(ticket.header)).toEqual(['ParkViet']);
    expect(titleOf(ticket)).toMatchObject({ title: 'HÓA ĐƠN THANH TOÁN' });
    expect(tableOf(ticket).rows[0]).toMatchObject({ index: 1, name: 'Nước suối' });
    expect(['qty', 'price', 'discount', 'amount'].map((key) => cell(ticket, 0, key))).toEqual([
      '2',
      '10.000',
      '2.000',
      '18.000',
    ]);
    // A price override shows the overridden unit price and no discount cell.
    expect(cell(ticket, 1, 'price')).toBe('12.000');
    expect(cell(ticket, 1, 'discount')).toBe('');
    expect(ticket.totals.at(-1)).toEqual({ label: 'Tổng cộng', value: '30.000 ₫', strong: true });
    expect(ticket.payments).toEqual([
      { label: 'Tiền mặt', value: '30.000 ₫' },
      { label: 'Khách đưa', value: '50.000 ₫' },
      { label: 'Tiền thừa trả khách', value: '20.000 ₫' },
    ]);
    expect(textLines(ticket.footer)).toEqual(['Cảm ơn quý khách!']);
  });

  it('leaves handed cash off until the cashier enters it', () => {
    const ticket = invoiceTicketPrintDocument(
      { workspace, attempts: [cash], handed: null, change: null, names: {} },
      t,
    );
    expect(ticket.payments).toEqual([{ label: 'Tiền mặt', value: '30.000 ₫' }]);
  });

  it('follows the store template: columns, labels and footer, never the total', () => {
    const base = DEFAULT_TEMPLATES.payment_ticket;
    const config: TemplateConfig = {
      ...base,
      lines: {
        ...(base.lines as NonNullable<TemplateConfig['lines']>),
        columns: ['name', 'qty', 'amount'],
      },
      totals: { fields: ['item_total'], labels: { item_total: 'Cộng hàng' } },
      footer: [{ type: 'text', value: 'Hẹn gặp lại', align: 'center' }],
    };
    const ticket = invoiceTicketPrintDocument(
      { workspace, attempts: [cash], handed: null, change: null, names: {} },
      t,
      new Date('2026-11-07T03:00:00Z'),
      'Asia/Ho_Chi_Minh',
      config,
    );
    expect(tableOf(ticket).columns.map((column) => column.key)).toEqual(['qty', 'amount']);
    expect(ticket.totals[0].label).toBe('Cộng hàng');
    expect(ticket.totals.at(-1)).toMatchObject({ label: 'Tổng cộng', value: '30.000 ₫' });
    expect(textLines(ticket.footer)).toEqual(['Hẹn gặp lại']);
  });

  it('sizes the page for 58mm rolls', () => {
    expect(pageRule('58mm')).toContain('size: 58mm 297mm');
  });
});
