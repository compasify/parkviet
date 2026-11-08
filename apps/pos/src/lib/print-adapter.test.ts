import { describe, expect, it, vi } from 'vitest';
import i18n from '../i18n';
import type { PosWorkspace } from './pos-context';
import {
  createBrowserPrintAdapter,
  formatDocumentDate,
  formatDocumentTime,
  formatQuantity,
  isPaperSize,
  PAPER_SIZES,
  PRINTING_ATTRIBUTE,
  pageRule,
  prebillPrintDocument,
  printTitle,
  type ReceiptPrint,
  type ReceiptSnapshot,
  receiptPrintDocument,
  receiptPrintTitle,
  SKIPPED_IMAGE_ATTRIBUTE,
  settleImages,
} from './print-adapter';
import { DEFAULT_TEMPLATES } from './receipt-template/defaults';
import type { PrintDocument, TemplateConfig } from './receipt-template/types';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

// The printed content of a stacked document, read in print order.
function flat(document: PrintDocument) {
  const title = document.header.find((block) => block.kind === 'title');
  return {
    banner: document.banners[0] ?? null,
    title: title?.kind === 'title' ? title.title : '',
    number: title?.kind === 'title' ? title.number : null,
    header: document.header.flatMap((block) => (block.kind === 'text' ? block.lines : [])),
    meta: document.meta,
    lines:
      document.lines.layout === 'stacked'
        ? document.lines.items.map((line) => ({
            name: line.index === null ? line.name : `${line.index}. ${line.name}`,
            details: line.details,
            amount: line.amount ?? '',
          }))
        : [],
    totals: document.totals,
    payments: document.payments,
    notes: document.notes,
    disclaimer: document.disclaimer ?? '',
  };
}

const formatReceipt = (
  receipt: ReceiptSnapshot,
  print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null,
  config?: TemplateConfig,
) => flat(receiptPrintDocument(receipt, print, t, config));

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
    const doc = formatReceipt(sale(), null);
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
    const original = formatReceipt(sale(), { copy: false, copy_number: 0 });
    const copy = formatReceipt(sale(), { copy: true, copy_number: 2 });
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
    const doc = flat(
      prebillPrintDocument(
        workspace,
        { branchName: 'Quận 1' },
        t,
        new Date('2026-11-07T03:00:00Z'),
      ),
    );
    expect(doc.banner).toBe('TẠM TÍNH – CHƯA THANH TOÁN');
    expect(doc.number).toBeNull();
    expect(doc.payments.at(-1)).toEqual({ label: 'Còn phải thu', value: '15.000 ₫', strong: true });
  });

  it('lays a posted receipt out by its template but keeps the copy label and the total', () => {
    const config: TemplateConfig = {
      ...DEFAULT_TEMPLATES.sale,
      header: [
        { type: 'text', value: 'Mẫu riêng' },
        { type: 'title', label: 'HÓA ĐƠN BÁN LẺ' },
      ],
      totals: { fields: [], labels: {} },
      payments: { fields: ['methods'], labels: {} },
    };
    const doc = formatReceipt(sale(), { copy: true, copy_number: 1 }, config);
    expect(doc.banner).toBe('BẢN SAO – lần 1');
    expect(doc.header).toEqual(['Mẫu riêng']);
    expect(doc.title).toBe('HÓA ĐƠN BÁN LẺ');
    expect(doc.number).toBe('R100');
    expect(doc.totals).toEqual([{ label: 'Tổng cộng', value: '5.230.000 ₫', strong: true }]);
    expect(doc.payments.map((row) => row.label)).toEqual(['Tiền mặt', 'Chuyển khoản']);
    expect(doc.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  });

  it('keeps the pre-bill banner under any pre-bill template', () => {
    const workspace = {
      id: 'ws_1',
      order_id: 'or_1',
      line_items: [],
      totals: { item_total: '0', discount_total: '0', total: '0', currency: 'VND' },
      financial: { allocated: '0', remaining: '0' },
    } as unknown as PosWorkspace;
    const doc = prebillPrintDocument(
      workspace,
      {},
      t,
      new Date('2026-11-07T03:00:00Z'),
      'Asia/Ho_Chi_Minh',
      {
        ...DEFAULT_TEMPLATES.prebill,
        header: [],
        footer: [{ type: 'text', value: 'Chân phiếu' }],
      },
    );
    expect(doc.banners).toEqual(['TẠM TÍNH – CHƯA THANH TOÁN']);
    expect(doc.footer).toEqual([
      { kind: 'text', lines: ['Chân phiếu'], align: 'center', bold: false, size: 'm' },
    ]);
  });

  it('sets the page size for rolls and A4/A5/A6 sheets', () => {
    expect(pageRule('58mm')).toContain('size: 58mm 297mm');
    expect(pageRule('80mm')).toContain('size: 80mm 297mm');
    expect(pageRule('a4')).toContain('size: A4');
    expect(pageRule('a5')).toContain('size: A5');
    expect(pageRule('a6')).toContain('size: A6');
  });

  it('recognises only the supported paper sizes', () => {
    expect(PAPER_SIZES.every(isPaperSize)).toBe(true);
    expect(isPaperSize('a3')).toBe(false);
    expect(isPaperSize(null)).toBe(false);
  });

  it('uses Vietnamese date, time and decimal formats in the branch timezone', () => {
    expect(formatDocumentTime('2026-11-07T03:05:00Z', 'Asia/Ho_Chi_Minh')).toBe('07/11/2026 10:05');
    expect(formatDocumentTime('2026-11-07T18:30:00Z', 'Asia/Ho_Chi_Minh')).toBe('08/11/2026 01:30');
    expect(formatDocumentDate('2027-01-31')).toBe('31/01/2027');
    expect(formatQuantity('1.25')).toBe('1,25');
    expect(formatQuantity('2.0')).toBe('2');
    expect(formatQuantity(24)).toBe('24');
    expect(formatReceipt(sale(), null).meta[0]).toEqual({
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

  it('names the print after the document and its order, and restores the page title', async () => {
    expect(receiptPrintTitle(sale({ order_number: 'R250' }), t)).toBe('Hóa đơn R100 - Đơn R250');
    expect(receiptPrintTitle(sale({ order_number: 'R100' }), t)).toBe('Hóa đơn R100');
    expect(printTitle('Tạm tính', null, 'R/7', t)).toBe('Tạm tính - Đơn R-7');

    let titleDuringPrint = '';
    const doc = {
      title: 'ParkViet POS',
      createElement: () => ({ id: '', textContent: '', remove: () => {} }),
      getElementById: () => null,
      head: { append: () => {} },
      documentElement: { setAttribute: () => {}, removeAttribute: () => {} },
    };
    const fakeWindow = {
      document: doc,
      addEventListener: () => {},
      removeEventListener: () => {},
      matchMedia: () => ({ matches: false }),
      print: () => {
        titleDuringPrint = doc.title;
      },
    } as unknown as Window;
    await createBrowserPrintAdapter(fakeWindow).deliver('a5', { title: 'Hóa đơn R100 - Đơn R250' });
    expect(titleDuringPrint).toBe('Hóa đơn R100 - Đơn R250');
    expect(doc.title).toBe('ParkViet POS');
  });
});

describe('logo images before printing', () => {
  type FakeImage = {
    decode: () => Promise<void>;
    attrs: Set<string>;
    setAttribute: (name: string) => void;
    removeAttribute: (name: string) => void;
  };
  const image = (decode: () => Promise<void>): FakeImage => {
    const attrs = new Set<string>();
    return {
      decode,
      attrs,
      setAttribute: (name) => attrs.add(name),
      removeAttribute: (name) => attrs.delete(name),
    };
  };
  const timers = { setTimeout, clearTimeout } as unknown as Pick<
    Window,
    'setTimeout' | 'clearTimeout'
  >;
  const docWith = (images: FakeImage[]) =>
    ({ querySelectorAll: () => images }) as unknown as Document;

  it('returns the images that failed or did not decode in time', async () => {
    const ready = image(() => Promise.resolve());
    const broken = image(() => Promise.reject(new Error('broken')));
    const slow = image(() => new Promise(() => {}));
    const skipped = await settleImages(docWith([ready, broken, slow]), timers, 20);
    expect(skipped).toEqual([broken, slow]);
  });

  it('prints without the images that are not ready and restores them afterwards', async () => {
    const broken = image(() => Promise.reject(new Error('broken')));
    let skippedDuringPrint = false;
    const doc = {
      title: '',
      querySelectorAll: () => [broken],
      createElement: () => ({ id: '', textContent: '', remove: () => {} }),
      getElementById: () => null,
      head: { append: () => {} },
      documentElement: { setAttribute: () => {}, removeAttribute: () => {} },
    };
    const fakeWindow = {
      document: doc,
      setTimeout,
      clearTimeout,
      addEventListener: () => {},
      removeEventListener: () => {},
      matchMedia: () => ({ matches: false }),
      print: () => {
        skippedDuringPrint = broken.attrs.has(SKIPPED_IMAGE_ATTRIBUTE);
      },
    } as unknown as Window;
    expect(await createBrowserPrintAdapter(fakeWindow).deliver('80mm')).toEqual({ ok: true });
    expect(skippedDuringPrint).toBe(true);
    expect(broken.attrs.has(SKIPPED_IMAGE_ATTRIBUTE)).toBe(false);
  });
});
