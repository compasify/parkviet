import { describe, expect, it } from 'vitest';
import i18n from '../../i18n';
import type { PosFinancialAttempt, PosWorkspace } from '../pos-context';
import type { ReceiptSnapshot } from '../print-adapter';
import { paymentTicketData, prebillData, snapshotData } from './data';
import { DEFAULT_TEMPLATES, defaultTemplate, TEST_PRINT_BANNER } from './defaults';
import { renderDocument } from './render';
import { DOCUMENT_TYPES, type PrintBlock, type PrintDocument, type TemplateConfig } from './types';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

function snapshot(
  source_type: string,
  document: Record<string, unknown>,
  extra: Partial<ReceiptSnapshot> = {},
): ReceiptSnapshot {
  return {
    id: 'posreceipt_1',
    source_type,
    number: 'R100',
    branch_id: 'br_1',
    issued_at: '2026-11-07T03:00:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: false,
    copy_count: 0,
    document,
    ...extra,
  } as ReceiptSnapshot;
}

const saleDocument = {
  title: 'PHIẾU BÁN HÀNG',
  store: { name: 'Park Việt', address: '12 Lê Lợi, Quận 1', contact_phone: '0901 234 567' },
  branch: { name: 'Quận 1', code: 'q1', return_window_days: 7 },
  register: 'Quầy 1',
  timezone: 'Asia/Ho_Chi_Minh',
  at: '2026-11-07T03:00:00Z',
  currency: 'VND',
  cashier: 'Lan',
  order_number: 'R250',
  lines: [
    {
      name: 'Bia lon',
      sku: 'BIA',
      quantity: 24,
      sale_quantity: '1',
      sale_unit: 'Thùng',
      conversion: '1 Thùng = 24 Lon',
      unit_price: '240000.0',
      amount: '240000.0',
      discount: '-10000.0',
      net_amount: '230000.0',
      trace: [{ lot_code: 'L01' }],
    },
  ],
  totals: {
    item_total: '240000.0',
    discount_total: '-10000.0',
    included_tax_total: '0.0',
    additional_tax_total: '0.0',
    total: '230000.0',
  },
  receipts: [{ method: 'cash', amount: '230000.0', handed: '300000.0', change: '70000.0' }],
  paid_total: '230000.0',
  note: 'Giao trước 5 giờ',
};

const text = (blocks: PrintBlock[]) =>
  blocks.flatMap((block) => (block.kind === 'text' ? block.lines : []));
const title = (document: PrintDocument) => document.header.find((block) => block.kind === 'title');
const stacked = (document: PrintDocument) =>
  document.lines.layout === 'stacked' ? document.lines.items : [];

// A template that switches off everything a template may switch off.
const stripped: TemplateConfig = {
  schema: 1,
  page: DEFAULT_TEMPLATES.sale.page,
  header: [],
  meta: { fields: [] },
  lines: { layout: 'stacked', columns: [], show_trace: false, show_conversion: false },
  totals: { fields: [] },
  payments: { fields: [] },
  footer: [],
};

describe('built-in templates', () => {
  it('cover every document type as plain JSON data', () => {
    expect(Object.keys(DEFAULT_TEMPLATES).sort()).toEqual([...DOCUMENT_TYPES].sort());
    expect(JSON.parse(JSON.stringify(DEFAULT_TEMPLATES))).toEqual(DEFAULT_TEMPLATES);
    for (const type of DOCUMENT_TYPES) expect(defaultTemplate(type).schema).toBe(1);
  });

  it('print a sale in the slip order with the store address and phone under its name', () => {
    const doc = renderDocument(
      defaultTemplate('sale'),
      snapshotData(snapshot('sale', saleDocument), t),
    );
    expect(doc.banners).toEqual([]);
    expect(text(doc.header)).toEqual([
      'Park Việt',
      '12 Lê Lợi, Quận 1',
      '0901 234 567',
      'Quận 1',
      'Quầy 1',
    ]);
    expect(doc.header.at(-1)).toEqual({ kind: 'title', title: 'PHIẾU BÁN HÀNG', number: 'R100' });
    expect(doc.meta.map((row) => row.label)).toEqual(['Thời gian', 'Thu ngân', 'Đơn gốc']);
    expect(stacked(doc)).toEqual([
      {
        index: null,
        name: 'Bia lon (BIA)',
        amount: '230.000 ₫',
        details: ['1 Thùng × 240.000 ₫', '1 Thùng = 24 Lon', 'Giảm -10.000 ₫', 'Lô: L01'],
      },
    ]);
    expect(doc.totals.map((row) => row.label)).toEqual(['Tổng tiền hàng', 'Giảm giá', 'Tổng cộng']);
    expect(doc.payments.map((row) => row.value)).toEqual([
      '230.000 ₫',
      '300.000 ₫',
      '70.000 ₫',
      '230.000 ₫',
    ]);
    expect(doc.notes).toEqual(['Giao trước 5 giờ']);
    expect(doc.footer).toEqual([]);
    expect(doc.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  });

  it('hide store details an older snapshot does not carry', () => {
    const doc = renderDocument(
      defaultTemplate('sale'),
      snapshotData(
        snapshot('sale', { ...saleDocument, store: { name: 'Park Việt' }, register: null }),
        t,
      ),
    );
    expect(text(doc.header)).toEqual(['Park Việt', 'Quận 1']);
  });

  it('print return, refund and shift closing slips from their snapshots', () => {
    const returned = renderDocument(
      defaultTemplate('return'),
      snapshotData(
        snapshot('return', {
          title: 'PHIẾU TRẢ HÀNG',
          currency: 'VND',
          order_number: 'R100',
          lines: [{ name: 'Gạo', sku: 'G', quantity: 2, condition: 'damaged', amount: '200000.0' }],
          entitlement_posted: true,
          entitlement_total: '200000.0',
          credit_note_amount: '0.0',
          refund_entitlement: '200000.0',
        }),
        t,
      ),
    );
    expect(stacked(returned)).toEqual([
      { index: null, name: 'Gạo', amount: '200.000 ₫', details: ['SL trả: 2', 'Hàng lỗi'] },
    ]);
    expect(returned.totals.map((row) => row.value)).toEqual(['200.000 ₫', '200.000 ₫']);

    const refund = renderDocument(
      defaultTemplate('refund'),
      snapshotData(snapshot('refund', { method: 'cash', amount: '50000.0', currency: 'VND' }), t),
    );
    expect(refund.payments).toEqual([
      { label: 'Đã hoàn tiền mặt', value: '50.000 ₫', strong: true },
    ]);

    const closing = renderDocument(
      defaultTemplate('shift_closure'),
      snapshotData(
        snapshot('shift_closure', {
          currency: 'VND',
          cashier: 'Lan',
          closer: 'Minh',
          expected: '360000.0',
          counted: '350000.0',
          variance: '-10000.0',
        }),
        t,
      ),
    );
    expect(closing.meta.map((row) => row.value)).toContain('Minh');
    expect(closing.totals.map((row) => row.value).slice(-3)).toEqual([
      '360.000 ₫',
      '350.000 ₫',
      '-10.000 ₫',
    ]);
  });

  it('print a return supplement with the return template and, as before, no figures', () => {
    const data = snapshotData(
      snapshot('return_supplement', { title: 'PHIẾU BỔ SUNG TRẢ HÀNG', credit_note_amount: '5.0' }),
      t,
    );
    expect(data.documentType).toBe('return');
    const doc = renderDocument(defaultTemplate('return'), data);
    expect(title(doc)).toEqual({ kind: 'title', title: 'PHIẾU BỔ SUNG TRẢ HÀNG', number: 'R100' });
    expect([...doc.totals, ...doc.payments]).toEqual([]);
  });

  it('print a pre-bill with the store details of the POS context and its banner', () => {
    const workspace = {
      id: 'ws_1',
      line_items: [
        { id: 'li', name: 'Nước', sku: 'N', quantity: 2, price: '10000.0', amount: '20000.0' },
      ],
      totals: { item_total: '20000.0', discount_total: '0.0', total: '20000.0', currency: 'VND' },
    } as unknown as PosWorkspace;
    const doc = renderDocument(
      defaultTemplate('prebill'),
      prebillData(
        workspace,
        {
          storeName: 'Park Việt',
          branchName: 'Quận 1',
          storeProfile: {
            address: '12 Lê Lợi',
            contact_phone: null,
            customer_support_email: null,
            url: null,
            facebook: null,
            instagram: null,
            logo_url: 'https://cdn.example/logo.png',
          },
        },
        t,
        new Date('2026-11-07T03:00:00Z'),
      ),
    );
    expect(doc.banners).toEqual(['TẠM TÍNH – CHƯA THANH TOÁN']);
    expect(text(doc.header)).toEqual(['Park Việt', '12 Lê Lợi', 'Quận 1']);
    // The built-in template has no logo block: the slip looks as it did.
    expect(doc.header.some((block) => block.kind === 'image')).toBe(false);
    expect(stacked(doc)[0]).toMatchObject({ name: 'Nước', details: ['2 × 10.000 ₫'] });
    expect(doc.notes).toEqual(['Phiếu tạm tính không phải biên nhận thanh toán.']);
    expect(doc.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  });

  it('print the payment ticket as a numbered table with a thank-you footer and no disclaimer', () => {
    const workspace = {
      id: 'ws_1',
      order_id: 'R1001',
      line_items: [
        {
          id: 'li',
          name: 'Nước suối',
          quantity: 2,
          price: '10000.0',
          amount: '20000.0',
          item_net_amount: '18000.0',
          item_discount: { amount: '2000.0' },
        },
      ],
      totals: {
        item_total: '20000.0',
        discount_total: '2000.0',
        additional_tax_total: '0',
        total: '18000.0',
        currency: 'VND',
      },
    } as unknown as PosWorkspace;
    const cash = {
      id: 'a',
      kind: 'cash',
      amount: '18000.0',
      currency: 'VND',
    } as PosFinancialAttempt;
    const doc = renderDocument(
      defaultTemplate('payment_ticket'),
      paymentTicketData(
        {
          workspace,
          attempts: [cash],
          handed: '20000',
          change: '2000',
          names: { storeName: 'ParkViet' },
        },
        t,
      ),
    );
    expect(doc.lines).toEqual({
      layout: 'table',
      columns: [
        { key: 'qty', label: 'SL' },
        { key: 'price', label: 'Đ.giá' },
        { key: 'discount', label: 'Giảm' },
        { key: 'amount', label: 'T.tiền' },
      ],
      rows: [
        { index: 1, name: 'Nước suối', cells: ['2', '10.000', '2.000', '18.000'], details: [] },
      ],
    });
    expect(doc.payments.map((row) => row.label)).toEqual([
      'Tiền mặt',
      'Khách đưa',
      'Tiền thừa trả khách',
    ]);
    expect(text(doc.footer)).toEqual(['Cảm ơn quý khách!']);
    expect(doc.disclaimer).toBeNull();
  });
});

describe('locked parts', () => {
  it('keep the copy banner, title, number, total and disclaimer when a template switches everything off', () => {
    const doc = renderDocument(stripped, snapshotData(snapshot('sale', saleDocument), t), {
      banner: 'BẢN SAO – lần 1',
    });
    expect(doc.banners).toEqual(['BẢN SAO – lần 1']);
    expect(doc.header).toEqual([{ kind: 'title', title: 'PHIẾU BÁN HÀNG', number: 'R100' }]);
    expect(doc.meta).toEqual([]);
    expect(doc.totals).toEqual([{ label: 'Tổng cộng', value: '230.000 ₫', strong: true }]);
    expect(doc.payments).toEqual([]);
    expect(stacked(doc)).toEqual([{ index: null, name: 'Bia lon', amount: null, details: [] }]);
    expect(doc.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  });

  it('keep the refunded amount when a refund template switches every payment field off', () => {
    const doc = renderDocument(
      stripped,
      snapshotData(snapshot('refund', { method: 'cash', amount: '50000.0', currency: 'VND' }), t),
    );
    expect(doc.payments).toEqual([{ label: 'Đã hoàn tiền mặt', value: '50.000 ₫', strong: true }]);
  });

  it('keep the pre-bill banner and note, and label a test print as worthless', () => {
    const workspace = { id: 'w', line_items: [], totals: null } as unknown as PosWorkspace;
    const doc = renderDocument(stripped, prebillData(workspace, {}, t), { testPrint: true });
    expect(doc.banners).toEqual(['TẠM TÍNH – CHƯA THANH TOÁN', TEST_PRINT_BANNER]);
    expect(doc.notes).toEqual(['Phiếu tạm tính không phải biên nhận thanh toán.']);
    expect(title(doc)).toEqual({ kind: 'title', title: 'PHIẾU TẠM TÍNH', number: null });
  });

  it('relabel fields but never the payment methods, and keep a relabelled title numbered', () => {
    const config: TemplateConfig = {
      ...defaultTemplate('sale'),
      header: [
        { type: 'title', label: 'HÓA ĐƠN BÁN LẺ' },
        { type: 'title', label: 'Thứ hai' },
      ],
      totals: { fields: ['item_total'], labels: { total: 'Phải trả', item_total: 'Cộng' } },
      payments: {
        fields: ['methods', 'paid_total'],
        labels: { methods: 'Thanh toán', paid_total: 'Đã trả' },
      },
    };
    const doc = renderDocument(config, snapshotData(snapshot('sale', saleDocument), t));
    expect(doc.header).toEqual([{ kind: 'title', title: 'HÓA ĐƠN BÁN LẺ', number: 'R100' }]);
    expect(doc.totals.map((row) => row.label)).toEqual(['Cộng', 'Phải trả']);
    expect(doc.payments.map((row) => row.label)).toEqual(['Tiền mặt', 'Đã trả']);
  });
});

describe('template blocks', () => {
  const data = () => snapshotData(snapshot('sale', saleDocument), t);

  it('resolve text with variables and drop text whose variables are all empty', () => {
    const doc = renderDocument(
      {
        ...defaultTemplate('sale'),
        footer: [
          { type: 'text', value: 'Đổi trả trong {branch.return_window_days} ngày', bold: true },
          { type: 'text', value: 'Email: {store.email}' },
          { type: 'divider', style: 'solid' },
          { type: 'spacer', mm: 40 },
        ],
      },
      data(),
    );
    expect(doc.footer).toEqual([
      { kind: 'text', lines: ['Đổi trả trong 7 ngày'], align: 'center', bold: true, size: 'm' },
      { kind: 'divider', style: 'solid' },
      { kind: 'spacer', mm: 10 },
    ]);
  });

  it('hide only the lines of a text block whose variables are all empty', () => {
    const empty = { ...data(), branch: { ...data().branch, returnWindowDays: null } };
    const doc = renderDocument(
      {
        ...defaultTemplate('sale'),
        footer: [
          {
            type: 'text',
            value: 'Cảm ơn quý khách!\nĐổi trả trong {branch.return_window_days} ngày',
          },
        ],
      },
      empty,
    );
    expect(text(doc.footer)).toEqual(['Cảm ơn quý khách!']);
  });

  it('print a logo only from a web address and skip unknown or malformed blocks', () => {
    const withLogo = {
      ...data(),
      store: { ...data().store, logoUrl: 'https://cdn.example/l.png' },
    };
    const config = {
      ...defaultTemplate('sale'),
      header: [{ type: 'logo', width_pct: 5 }, { type: 'qr' }, null, 'x', 7, { type: 'title' }],
    } as unknown as TemplateConfig;
    expect(renderDocument(config, withLogo).header[0]).toEqual({
      kind: 'image',
      src: 'https://cdn.example/l.png',
      alt: 'Park Việt',
      widthPct: 20,
      align: 'center',
    });
    const unsafe = { ...data(), store: { ...data().store, logoUrl: 'javascript:alert(1)' } };
    expect(renderDocument(config, unsafe).header).toHaveLength(1);
    expect(() =>
      renderDocument({ schema: 1, header: 'x', footer: 3 } as unknown as TemplateConfig, data()),
    ).not.toThrow();
  });

  it('switch line columns and lay lines out as a table', () => {
    const doc = renderDocument(
      {
        ...defaultTemplate('sale'),
        lines: {
          layout: 'table',
          columns: ['index', 'name', 'qty', 'amount'],
          show_trace: true,
          show_conversion: false,
        },
      },
      data(),
    );
    expect(doc.lines).toEqual({
      layout: 'table',
      columns: [
        { key: 'qty', label: 'SL' },
        { key: 'amount', label: 'T.tiền' },
      ],
      rows: [{ index: 1, name: 'Bia lon', cells: ['1', '230.000'], details: ['Lô: L01'] }],
    });
  });
});
