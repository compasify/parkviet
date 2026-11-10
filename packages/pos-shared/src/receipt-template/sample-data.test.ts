import { describe, expect, it } from 'vitest';
import en from '../../../../apps/pos/src/locales/en.json';
import vi from '../../../../apps/pos/src/locales/vi.json';
import i18n from '../test-support/i18n';
import { DEFAULT_TEMPLATES, TEST_PRINT_BANNER } from './defaults';
import { renderDocument } from './render';
import { sampleData, withLogo } from './sample-data';
import { DOCUMENT_TYPES } from './types';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;
const now = new Date('2026-11-08T03:30:00Z');
const place = {
  storeName: 'Park Việt',
  storeProfile: {
    address: '12 Lê Lợi, Quận 1',
    contact_phone: '0901 234 567',
    customer_support_email: null,
    url: 'https://parkviet.vn',
    facebook: null,
    instagram: null,
    logo_url: 'https://cdn.example/logo.png',
  },
  branchName: 'Chi nhánh Quận 1',
  branchCode: 'q1',
  returnWindowDays: 7,
  registerName: 'Quầy 2',
  cashier: 'Lan',
  timeZone: 'Asia/Ho_Chi_Minh',
};

const texts = (document: ReturnType<typeof renderDocument>) =>
  [...document.header, ...document.footer].flatMap((block) =>
    block.kind === 'text' ? block.lines : block.kind === 'title' ? [block.title] : [],
  );

describe('template preview sample data', () => {
  it.each(DOCUMENT_TYPES)('renders a %s sample at the chosen branch and register', (type) => {
    const data = sampleData(type, place, t, now);
    expect(data.documentType).toBe(type);
    expect(data.store).toMatchObject({ name: 'Park Việt', address: '12 Lê Lợi, Quận 1' });
    expect(data.store.logoUrl).toBe('https://cdn.example/logo.png');
    expect(data.branch).toEqual({ name: 'Chi nhánh Quận 1', code: 'q1', returnWindowDays: 7 });
    expect(data.register).toBe('Quầy 2');
    expect(data.time).toBe('08/11/2026 10:30');
    const document = renderDocument(DEFAULT_TEMPLATES[type], data);
    expect(texts(document)).toContain('Park Việt');
    expect(texts(document)).toContain('Quầy 2');
  });

  it('fills every section the document type prints', () => {
    const sale = renderDocument(DEFAULT_TEMPLATES.sale, sampleData('sale', place, t, now));
    expect(sale.lines.layout === 'stacked' && sale.lines.items).toHaveLength(2);
    expect(sale.totals.at(-1)).toMatchObject({ label: 'Tổng cộng', strong: true });
    expect(sale.payments.length).toBeGreaterThan(0);
    expect(sale.disclaimer).toBe('Phiếu bán hàng POS — không phải hóa đơn điện tử');

    const ticket = renderDocument(
      DEFAULT_TEMPLATES.payment_ticket,
      sampleData('payment_ticket', place, t, now),
    );
    expect(ticket.lines.layout).toBe('table');
    expect(ticket.disclaimer).toBeNull();

    const prebill = renderDocument(DEFAULT_TEMPLATES.prebill, sampleData('prebill', place, t, now));
    expect(prebill.banners).toEqual(['TẠM TÍNH – CHƯA THANH TOÁN']);

    const closure = renderDocument(
      DEFAULT_TEMPLATES.shift_closure,
      sampleData('shift_closure', place, t, now),
    );
    expect(closure.totals.map((row) => row.label)).toContain('Chênh lệch');
  });

  it('marks a test print as worthless', () => {
    const document = renderDocument(DEFAULT_TEMPLATES.sale, sampleData('sale', place, t, now), {
      testPrint: true,
    });
    expect(document.banners).toEqual([TEST_PRINT_BANNER]);
  });

  it('prints without store details the context does not have', () => {
    const data = sampleData('refund', { storeName: 'Park Việt' }, t, now);
    expect(data.store.address).toBeNull();
    expect(data.store.logoUrl).toBeNull();
    expect(withLogo(data, {}).store.logoUrl).toBeNull();
  });
});

type Tree = { [key: string]: string | Tree };
const flatten = (tree: Tree, prefix = ''): string[] =>
  Object.entries(tree).flatMap(([key, value]) =>
    typeof value === 'string'
      ? [`${prefix}${key.replace(/_(one|other)$/, '')}`]
      : flatten(value, `${prefix}${key}.`),
  );

describe('print template labels', () => {
  it('has every Vietnamese label in English too', () => {
    const keys = (tree: unknown) => [...new Set(flatten(tree as Tree))].sort();
    expect(keys(en.receiptTemplates)).toEqual(keys(vi.receiptTemplates));
  });
});
