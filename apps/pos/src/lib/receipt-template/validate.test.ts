import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { DEFAULT_TEMPLATES } from './defaults';
import { DOCUMENT_TYPES, type DocumentType, type TemplateConfig } from './types';
import {
  BLOCK_TYPES,
  charsPerLine,
  editableConfig,
  issueTarget,
  overlongLines,
  SECTION_RULES,
  serverIssues,
  unknownVariables,
  validateTemplate,
} from './validate';

const draft = (config: TemplateConfig, name = 'Phiếu K80') => ({
  name,
  paper: '80mm' as const,
  config,
});
const codes = (config: TemplateConfig, type: DocumentType = 'sale', name?: string) =>
  validateTemplate(draft(config, name), type).map((issue) => `${issue.pointer} ${issue.code}`);
const sale = () => editableConfig(DEFAULT_TEMPLATES.sale, 'sale');

describe('template validation mirrors the server', () => {
  it.each(DOCUMENT_TYPES)('accepts the built-in %s template', (type) => {
    expect(validateTemplate(draft(DEFAULT_TEMPLATES[type]), type)).toEqual([]);
    expect(validateTemplate(draft(editableConfig(DEFAULT_TEMPLATES[type], type)), type)).toEqual(
      [],
    );
  });

  it('offers exactly the sections and fields the server schema allows', () => {
    const schema = readFileSync(
      new URL(
        '../../../../../server/app/services/spree/pos/receipt_template_schema.rb',
        import.meta.url,
      ),
      'utf8',
    );
    const words = (literal: string) => literal.slice(3, -1).trim().split(/\s+/);
    const constants = Object.fromEntries(
      [...schema.matchAll(/^\s*([A-Z_]+_ALL) = (%w\[[^\]]*\])/gm)].map(([, name, list]) => [
        name,
        words(list ?? ''),
      ]),
    );
    const start = schema.indexOf('SECTIONS = {');
    const body = schema.slice(start, schema.indexOf('}.freeze', start));
    const server = Object.fromEntries(
      [...body.matchAll(/'(\w+)' => \{([^}]*)\}/g)].map(([, type, sections]) => [
        type,
        Object.fromEntries(
          [...(sections ?? '').matchAll(/'(\w+)' => (%w\[[^\]]*\]|[A-Z_]+)/g)].map(
            ([, section, list]) => [
              section,
              list?.startsWith('%w') ? words(list) : constants[list ?? ''],
            ],
          ),
        ),
      ]),
    );
    expect(Object.keys(server).sort()).toEqual([...DOCUMENT_TYPES].sort());
    expect(server).toEqual(JSON.parse(JSON.stringify(SECTION_RULES)));
  });

  it('marks a blank or too long name', () => {
    expect(codes(sale(), 'sale', '  ')).toEqual(['/name blank']);
    expect(codes(sale(), 'sale', 'x'.repeat(61))).toEqual(['/name too_long']);
  });

  it('points at the block whose text names an unknown variable or is empty', () => {
    const config = sale();
    config.footer = [
      { type: 'text', value: 'Cảm ơn {store.name}' },
      { type: 'text', value: 'Hotline {store.hotline}' },
      { type: 'text', value: '   ' },
    ];
    expect(codes(config)).toEqual([
      '/config/footer/1/value unknown_variable',
      '/config/footer/2/value blank',
    ]);
    expect(unknownVariables('{store.hotline} {cashier} {Store.Name}')).toEqual(['store.hotline']);
  });

  it('refuses a misplaced or second title, too many blocks and out of range settings', () => {
    const config = sale();
    config.header = [...config.header, { type: 'title' }];
    config.footer = [{ type: 'title' }, { type: 'spacer', mm: 20 }, { type: 'logo', width_pct: 5 }];
    expect(codes(config)).toEqual([
      '/config/header/3 duplicate',
      '/config/footer/0 misplaced',
      '/config/footer/1/mm invalid_value',
      '/config/footer/2/width_pct invalid_value',
    ]);
    config.header = Array.from({ length: 9 }, () => ({ type: 'divider' as const }));
    expect(codes(config)).toContain('/config/header too_many');
  });

  it('accepts a field only on a document type that has its data', () => {
    const config = editableConfig(DEFAULT_TEMPLATES.prebill, 'prebill');
    config.totals = { fields: ['item_total', 'tax', 'total'], labels: { tax: 'Thuế' } };
    expect(codes(config, 'prebill')).toEqual([
      '/config/totals/fields/1 field_unavailable',
      '/config/totals/labels/tax field_unavailable',
    ]);
    const closure = editableConfig(DEFAULT_TEMPLATES.shift_closure, 'shift_closure');
    expect(codes({ ...closure, lines: sale().lines }, 'shift_closure')).toEqual([
      '/config/lines section_unavailable',
    ]);
  });

  it('keeps the payment method labels fixed and labels short', () => {
    const config = sale();
    config.payments = { fields: ['methods'], labels: { methods: 'Tiền' } };
    config.meta = { fields: ['time'], labels: { time: 'x'.repeat(41) } };
    expect(codes(config)).toEqual([
      '/config/meta/labels/time too_long',
      '/config/payments/labels/methods field_unavailable',
    ]);
  });
});

describe('editable config', () => {
  it('fills a missing section with every field it prints and keeps the locked ones', () => {
    const config = editableConfig(
      {
        schema: 1,
        page: DEFAULT_TEMPLATES.sale.page,
        header: [{ type: 'title' }, null as never, { type: 'html' } as never],
        totals: { fields: ['item_total'], labels: {} },
        lines: { layout: 'table', columns: ['qty'], show_trace: false, show_conversion: false },
        footer: [],
      },
      'sale',
    );
    expect(config.header).toEqual([{ type: 'title' }]);
    expect(config.meta?.fields).toEqual(SECTION_RULES.sale.meta);
    expect(config.payments?.fields).toEqual(SECTION_RULES.sale.payments);
    expect(config.totals?.fields).toEqual(['item_total', 'total']);
    expect(config.lines?.columns).toEqual(['qty', 'name']);
  });

  it('drops sections the document type does not have', () => {
    const config = editableConfig(DEFAULT_TEMPLATES.sale, 'refund');
    expect(Object.keys(config).sort()).toEqual([
      'footer',
      'header',
      'meta',
      'page',
      'payments',
      'schema',
    ]);
  });
});

describe('server errors', () => {
  it('reads the pointers of a 422 and maps them to the editor', () => {
    const error = {
      status: 422,
      details: {
        errors: [
          { pointer: '/config/footer/1/value', code: 'unknown_variable', message: 'Unknown.' },
          { pointer: '/name', code: 'blank' },
          { code: 'no_pointer' },
        ],
      },
    };
    expect(serverIssues(error)).toEqual([
      { pointer: '/config/footer/1/value', code: 'unknown_variable', message: 'Unknown.' },
      { pointer: '/name', code: 'blank' },
    ]);
    expect(serverIssues(new Error('offline'))).toEqual([]);
    expect(issueTarget('/config/footer/1/value')).toEqual({ area: 'footer', index: 1 });
    expect(issueTarget('/config/header')).toEqual({ area: 'header', index: null });
    expect(issueTarget('/config/payments/labels/debt')).toEqual({ area: 'payments', index: null });
    expect(issueTarget('/name')).toEqual({ area: 'name', index: null });
    expect(issueTarget('/config')).toEqual({ area: 'config', index: null });
  });
});

describe('line width', () => {
  it('estimates the characters a roll fits and flags longer lines', () => {
    expect(charsPerLine('58mm', 'm')).toBe(32);
    expect(charsPerLine('80mm', 's')).toBeGreaterThan(48);
    expect(charsPerLine('58mm', 'm', 'l')).toBeLessThan(32);
    expect(charsPerLine('a4', 'm')).toBeNull();
    expect(overlongLines(['ngắn', 'x'.repeat(40)], 32)).toEqual(['x'.repeat(40)]);
    expect(overlongLines(['x'.repeat(400)], null)).toEqual([]);
  });
});

describe('QR, barcode and signature blocks and copies', () => {
  const serverSchema = () =>
    readFileSync(
      new URL(
        '../../../../../server/app/services/spree/pos/receipt_template_schema.rb',
        import.meta.url,
      ),
      'utf8',
    );

  it('offers exactly the block types the server schema accepts', () => {
    const schema = serverSchema();
    const start = schema.indexOf('BLOCK_KEYS = {');
    const body = schema.slice(start, schema.indexOf('}.freeze', start));
    const server = [...body.matchAll(/'(\w+)' => %w\[/g)].map(([, type]) => type);
    expect(server.sort()).toEqual([...BLOCK_TYPES].sort());
  });

  it('marks a QR link that is not http(s), a store page that does not exist and long captions', () => {
    const config = sale();
    config.footer = [
      { type: 'qr', source: 'url', value: 'https://zalo.me/parkviet', caption: 'Zalo' },
      { type: 'qr', source: 'url', value: 'javascript:alert(1)' },
      { type: 'qr', source: 'url', value: `https://${'a'.repeat(300)}.vn` },
      { type: 'qr', source: 'store_social', field: 'zalo' as never, caption: 'x'.repeat(61) },
      { type: 'qr', source: 'vietqr_payment' } as never,
    ];
    expect(codes(config)).toEqual([
      '/config/footer/1/value invalid_url',
      '/config/footer/2/value too_long',
      '/config/footer/3/caption too_long',
      '/config/footer/3/field invalid_value',
      '/config/footer/4/source invalid_value',
    ]);
  });

  it('needs at least one signature box and short labels', () => {
    const config = sale();
    config.footer = [
      { type: 'signatures', parties: ['buyer'], labels: { buyer: 'Khách' } },
      { type: 'signatures', parties: [], labels: { seller: 'x'.repeat(41) } },
      { type: 'barcode', align: 'left' },
      { type: 'logo', monochrome: true },
    ];
    expect(codes(config)).toEqual([
      '/config/footer/1/parties blank',
      '/config/footer/1/labels/seller too_long',
    ]);
  });

  it('takes one to three copies on sale templates only', () => {
    const config = sale();
    config.page = { ...config.page, copies: 3 };
    expect(codes(config)).toEqual([]);
    config.page = { ...config.page, copies: 4 };
    expect(codes(config)).toEqual(['/config/page/copies invalid_value']);
    const prebill = editableConfig(DEFAULT_TEMPLATES.prebill, 'prebill');
    prebill.page = { ...prebill.page, copies: 2 };
    expect(codes(prebill, 'prebill')).toEqual(['/config/page/copies field_unavailable']);
  });

  it('keeps the copies of a sale template and drops them from other documents', () => {
    const source = {
      ...DEFAULT_TEMPLATES.sale,
      page: { ...DEFAULT_TEMPLATES.sale.page, copies: 2 },
    };
    expect(editableConfig(source, 'sale').page.copies).toBe(2);
    expect(editableConfig(source, 'refund').page).not.toHaveProperty('copies');
    expect(editableConfig(DEFAULT_TEMPLATES.sale, 'sale').page).not.toHaveProperty('copies');
  });
});
