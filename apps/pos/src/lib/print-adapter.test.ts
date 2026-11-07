import { describe, expect, it, vi } from 'vitest';
import i18n from '../i18n';
import type { PosWorkspace } from './pos-context';
import {
  createBrowserPrintAdapter,
  formatDocumentDate,
  formatDocumentTime,
  formatPrebill,
  formatQuantity,
  formatReceipt,
  PRINTING_ATTRIBUTE,
  pageRule,
  type ReceiptSnapshot,
} from './print-adapter';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

function sale(document: Record<string, unknown> = {}): ReceiptSnapshot {
  return {
    id: 'posreceipt_1',
    source_type: 'sale',
    number: 'R100',
    branch_id: 'br_1',
    issued_at: '2026-11-07T03:00:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: true,
    copy_count: 1,
    document: {
      kind: 'sale',
      title: 'PHIẾU BÁN HÀNG',
      number: 'R100',
      store: { name: 'Park Việt' },
      branch: { name: 'Quận 1', code: 'q1' },
      register: 'Quầy 1',
      timezone: 'Asia/Ho_Chi_Minh',
      at: '2026-11-07T03:00:00Z',
      currency: 'VND',
      cashier: 'Lan',
      customer: { name: 'N••• V•• A•', phone: '•••••••567' },
      lines: [
        {
          name: 'Bia lon',
          sku: 'BIA',
          quantity: 24,
          sale_quantity: '1',
          sale_unit: 'Thùng',
          base_quantity: 24,
          base_unit: 'Lon',
          conversion: '1 Thùng = 24 Lon',
          unit_price: '240000.0',
          amount: '240000.0',
          discount: '-10000.0',
          net_amount: '230000.0',
          trace: [{ lot_code: 'L01', expiry_on: '2027-01-31', quantity: 24 }],
        },
        {
          name: 'Điện thoại',
          sku: null,
          quantity: 1,
          unit_price: '5000000.0',
          amount: '5000000.0',
          discount: '0.0',
          net_amount: '5000000.0',
          trace: [{ serial: '356789012345678' }],
        },
      ],
      totals: {
        item_total: '5240000.0',
        discount_total: '-10000.0',
        included_tax_total: '0.0',
        additional_tax_total: '0.0',
        total: '5230000.0',
      },
      receipts: [
        { method: 'cash', amount: '230000.0', handed: '300000.0', change: '70000.0' },
        { method: 'bank_manual', amount: '3000000.0', reference: '••••1234' },
      ],
      paid_total: '3230000.0',
      credit: { debt: '2000000.0', due_on: '2026-12-07' },
      ...document,
    },
  };
}

describe('receipt formatting', () => {
  it('prints sale units, conversion, discounts, traceability, receipts by method and approved debt', () => {
    const doc = formatReceipt(sale(), null, t);
    expect(doc.banner).toBeNull();
    expect(doc.title).toBe('PHIẾU BÁN HÀNG');
    expect(doc.header).toEqual(['Park Việt', 'Quận 1', 'Quầy 1']);
    expect(doc.lines[0]).toEqual({
      name: 'Bia lon (BIA)',
      details: [
        '1 Thùng × 240.000 ₫',
        '1 Thùng = 24 Lon',
        'Giảm -10.000 ₫',
        'Lô: L01 · HSD: 31/01/2027',
      ],
      amount: '230.000 ₫',
    });
    expect(doc.lines[1].details).toContain('Serial/IMEI: 356789012345678');
    expect(doc.totals.at(-1)).toEqual({ label: 'Tổng cộng', value: '5.230.000 ₫', strong: true });
    expect(doc.payments).toEqual([
      { label: 'Tiền mặt', value: '230.000 ₫' },
      { label: 'Khách đưa', value: '300.000 ₫' },
      { label: 'Tiền thừa trả khách', value: '70.000 ₫' },
      { label: 'Chuyển khoản', value: '3.000.000 ₫' },
      { label: 'Mã giao dịch', value: '••••1234' },
      { label: 'Đã thanh toán', value: '3.230.000 ₫', strong: true },
      { label: 'Ghi nợ được duyệt', value: '2.000.000 ₫', strong: true },
      { label: 'Hạn thanh toán', value: '07/12/2026' },
    ]);
    expect(doc.meta).toContainEqual({ label: 'Khách hàng', value: 'N••• V•• A• · •••••••567' });
    expect(doc.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  });

  it('labels a reprint as a numbered copy with the same content', () => {
    const original = formatReceipt(sale(), { copy: false, copy_number: 0 }, t);
    const copy = formatReceipt(sale(), { copy: true, copy_number: 2 }, t);
    expect(copy.banner).toBe('BẢN SAO – lần 2');
    expect({ ...copy, banner: null }).toEqual(original);
  });

  it('formats return, refund and shift closing slips without inventing amounts', () => {
    const pending = formatReceipt(
      {
        ...sale(),
        source_type: 'return',
        document: {
          title: 'PHIẾU TRẢ HÀNG',
          currency: 'VND',
          order_number: 'R100',
          lines: [{ name: 'Gạo', quantity: 2, condition: 'damaged', amount: '200000.0' }],
          entitlement_posted: false,
          entitlement_total: '200000.0',
          refund_entitlement: null,
        },
      },
      null,
      t,
    );
    expect(pending.totals).toEqual([
      { label: 'Giá trị hàng trả', value: '200.000 ₫', strong: true },
    ]);
    expect(pending.notes).toContain('Giá trị trả hàng đang chờ ghi nhận');
    expect(pending.lines[0].details).toEqual(['SL trả: 2', 'Hàng lỗi']);

    const closing = formatReceipt(
      {
        ...sale(),
        source_type: 'shift_closure',
        document: {
          title: 'PHIẾU ĐÓNG CA',
          currency: 'VND',
          expected: '360000.0',
          counted: '350000.0',
          variance: '-10000.0',
        },
      },
      null,
      t,
    );
    expect(closing.totals.map((row) => row.value).slice(-3)).toEqual([
      '360.000 ₫',
      '350.000 ₫',
      '-10.000 ₫',
    ]);
  });

  it('marks a provisional bill as not paid and gives it no receipt number', () => {
    const workspace = {
      id: 'ws_1',
      order_id: 'or_1',
      line_items: [
        { id: 'li', name: 'Nước', quantity: 2, price: '10000.0', amount: '20000.0', discounts: [] },
      ],
      totals: { item_total: '20000.0', discount_total: '0.0', total: '20000.0', currency: 'VND' },
      financial: { allocated: '5000.0', remaining: '15000.0' },
    } as unknown as PosWorkspace;
    const doc = formatPrebill(
      workspace,
      { branchName: 'Quận 1' },
      t,
      new Date('2026-11-07T03:00:00Z'),
    );
    expect(doc.banner).toBe('TẠM TÍNH – CHƯA THANH TOÁN');
    expect(doc.number).toBeNull();
    expect(doc.payments.at(-1)).toEqual({ label: 'Còn phải thu', value: '15.000 ₫', strong: true });
  });

  it('sets the page size for 80mm rolls and A4 sheets', () => {
    expect(pageRule('80mm')).toContain('size: 80mm 297mm');
    expect(pageRule('a4')).toContain('size: A4');
  });

  it('uses Vietnamese date, time and decimal formats in the branch timezone', () => {
    expect(formatDocumentTime('2026-11-07T03:05:00Z', 'Asia/Ho_Chi_Minh')).toBe('07/11/2026 10:05');
    expect(formatDocumentTime('2026-11-07T18:30:00Z', 'Asia/Ho_Chi_Minh')).toBe('08/11/2026 01:30');
    expect(formatDocumentDate('2027-01-31')).toBe('31/01/2027');
    expect(formatQuantity('1.25')).toBe('1,25');
    expect(formatQuantity('2.0')).toBe('2');
    expect(formatQuantity(24)).toBe('24');
    expect(formatReceipt(sale(), null, t).meta[0]).toEqual({
      label: 'Thời gian',
      value: '07/11/2026 10:00',
    });
  });

  it('prints receipts only under the printing marker and removes it and the page size afterwards', async () => {
    const listeners = new Map<string, () => void>();
    const head = { append: vi.fn() };
    const attributes = new Map<string, string>();
    const style = { id: '', textContent: '', remove: vi.fn() };
    let seenDuringPrint: string | undefined;
    const fakeWindow = {
      document: {
        createElement: () => style,
        getElementById: () => null,
        head,
        documentElement: {
          setAttribute: (key: string, value: string) => attributes.set(key, value),
          removeAttribute: (key: string) => attributes.delete(key),
        },
      },
      addEventListener: (name: string, fn: () => void) => listeners.set(name, fn),
      removeEventListener: (name: string) => listeners.delete(name),
      matchMedia: () => ({ matches: false }),
      print: () => {
        seenDuringPrint = attributes.get(PRINTING_ATTRIBUTE);
      },
    } as unknown as Window;
    const outcome = await createBrowserPrintAdapter(fakeWindow).deliver('80mm');
    expect(outcome).toEqual({ ok: true });
    expect(seenDuringPrint).toBe('80mm');
    expect(style.textContent).toContain('80mm 297mm');
    expect(attributes.has(PRINTING_ATTRIBUTE)).toBe(false);
    expect(style.remove).toHaveBeenCalled();
    expect(listeners.size).toBe(0);
  });
});
