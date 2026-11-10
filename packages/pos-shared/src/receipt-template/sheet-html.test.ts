import { describe, expect, it } from 'vitest';
import { escapeHtml, qrPath, renderSheetContentHtml, renderSheetHtml } from './sheet-html';
import golden from './sheet-html.golden.json';
import { sheetCases } from './sheet-html.test-cases';
import type { PaperSize, PrintBlock, PrintDocument } from './types';

const HOSTILE = `<img src=x onerror="alert('x')"> & more`;
const ESCAPED = '&lt;img src=x onerror=&quot;alert(&#x27;x&#x27;)&quot;&gt; &amp; more';

const base: PrintDocument = {
  documentType: 'sale',
  page: { margin_mm: 3, font: 'sans', font_size: 'm', line_spacing: 1.35 },
  banners: [],
  header: [],
  meta: [],
  lines: { layout: 'stacked', items: [] },
  totals: [],
  payments: [],
  payQr: null,
  notes: [],
  footer: [],
  disclaimer: null,
};

const header = (block: PrintBlock, paper: PaperSize = '80mm', markOverflow = false) =>
  renderSheetContentHtml({ ...base, header: [block] }, { paper, markOverflow });

describe('escapeHtml', () => {
  it('escapes every character that can open markup or end an attribute', () => {
    expect(escapeHtml(HOSTILE)).toBe(ESCAPED);
    expect(escapeHtml('a&amp;b')).toBe('a&amp;amp;b');
    expect(escapeHtml(12)).toBe('12');
    expect(escapeHtml('Việt — ₫')).toBe('Việt — ₫');
  });
});

// The golden is React's static markup of the sheet component. Two things
// in it are server-rendering artefacts, not sheet markup: React spells the
// HTML attribute `colspan` as `colSpan` (attribute names are
// case-insensitive, both parse to the same element), and it puts image
// preload hints in front of the element, which client rendering never adds.
const fromReact = (html: string) =>
  html
    .replace(/^(<link rel="preload" as="image" [^>]*\/>)+/, '')
    .replaceAll(' colSpan="', ' colspan="');

describe('renderSheetHtml', () => {
  it('matches the markup the POS sheet component printed, case by case', () => {
    const expected = golden as Record<string, string>;
    const cases = sheetCases();
    expect(cases.map((item) => item.name).sort()).toEqual(Object.keys(expected).sort());
    for (const item of cases)
      expect(
        renderSheetHtml(item.document, {
          paper: item.paper,
          markOverflow: item.markOverflow,
          testId: item.testId,
          printId: item.printId,
        }),
        item.name,
      ).toBe(fromReact(expected[item.name] ?? ''));
  });

  it('never lets document text or attributes become markup', () => {
    const html = renderSheetHtml(
      {
        ...base,
        banners: [HOSTILE],
        header: [
          { kind: 'text', lines: [HOSTILE], align: 'center', bold: false, size: 'm' },
          {
            kind: 'image',
            src: '/a"b',
            alt: HOSTILE,
            widthPct: 50,
            align: 'center',
            monochrome: false,
          },
        ],
        meta: [{ label: HOSTILE, value: HOSTILE }],
        notes: [HOSTILE],
        disclaimer: HOSTILE,
      },
      { paper: '80mm', testId: 'x"y', printId: '<p>' },
    );
    expect(html).not.toContain('<img src=x');
    expect(html).not.toContain('onerror="');
    expect(html).toContain(`<p class="receipt-banner">${ESCAPED}</p>`);
    expect(html).toContain(`alt="${ESCAPED}"`);
    expect(html).toContain('src="/a&quot;b"');
    expect(html).toContain('data-testid="x&quot;y"');
    expect(html).toContain('data-print-id="&lt;p&gt;"');
  });

  it('sets the sheet classes and the line height only when it differs from the default', () => {
    const plain = renderSheetHtml(base, { paper: '80mm', testId: 's' });
    expect(plain).toMatch(
      /^<article class="receipt-sheet receipt-80mm" data-testid="s" data-paper="80mm">/,
    );
    const styled = renderSheetHtml(
      {
        ...base,
        documentType: 'payment_ticket',
        page: { margin_mm: 3, font: 'mono', font_size: 'l', line_spacing: 1.5 },
      },
      { paper: 'a4', testId: 's', printId: 'p1' },
    );
    expect(styled).toMatch(
      /^<article class="receipt-sheet invoice-ticket receipt-a4 receipt-font-mono receipt-scale-l" style="line-height:1.5" data-testid="s" data-paper="a4" data-print-id="p1">/,
    );
  });
});

describe('blocks', () => {
  it('prints text lines with alignment, weight and size, underlining overflow only when asked', () => {
    const block: PrintBlock = {
      kind: 'text',
      lines: ['x'.repeat(40), 'short'],
      align: 'left',
      bold: true,
      size: 's',
    };
    expect(header(block, '58mm')).toContain(
      `<p class="receipt-align-left receipt-bold receipt-size-s">${'x'.repeat(40)}</p>`,
    );
    const marked = header(block, '58mm', true);
    // 58mm fits 32 characters, small text 1.2 times as many.
    expect(marked).toContain(
      `${'x'.repeat(38)}<span class="receipt-overflow" data-testid="receipt-overflow">xx</span></p>`,
    );
    expect(marked).toContain('<p class="receipt-align-left receipt-bold receipt-size-s">short</p>');
    expect(header(block, 'a4', true)).not.toContain('receipt-overflow');
  });

  it('prints an image, a title with and without number, dividers and spacers', () => {
    expect(
      header({
        kind: 'image',
        src: '/l.png',
        alt: 'Shop',
        widthPct: 40,
        align: 'right',
        monochrome: true,
      }),
    ).toContain(
      '<p class="receipt-logo receipt-align-right receipt-logo-mono"><img src="/l.png" alt="Shop" style="width:40%"/></p>',
    );
    expect(header({ kind: 'title', title: 'T', number: 'R1' })).toContain(
      '<h2>T</h2><p class="receipt-number">R1</p>',
    );
    expect(header({ kind: 'title', title: 'T', number: null })).toContain(
      '<header class="receipt-header"><h2>T</h2></header>',
    );
    expect(header({ kind: 'divider', style: 'dashed' })).toContain(
      '<div class="receipt-divider receipt-divider-dashed"></div>',
    );
    expect(header({ kind: 'spacer', mm: 5 })).toContain(
      '<div class="receipt-spacer" style="height:5mm"></div>',
    );
  });

  it('draws a QR code and leaves off one too long to encode', () => {
    const value = 'https://example.com/?a=1&b=2';
    const code = qrPath(value);
    expect(code).not.toBeNull();
    const html = header({ kind: 'qr', value, caption: 'Scan <me>', align: 'left' });
    expect(html).toContain(
      `<figure class="receipt-qr receipt-code-left" data-qr-value="https://example.com/?a=1&amp;b=2"><svg viewBox="0 0 ${code?.size} ${code?.size}" shape-rendering="crispEdges" role="img" aria-label="Scan &lt;me&gt;"><path d="${code?.path}" fill="#000"></path></svg><figcaption>Scan &lt;me&gt;</figcaption></figure>`,
    );
    expect(header({ kind: 'qr', value, caption: null, align: 'center' })).not.toContain(
      '<figcaption>',
    );
    expect(qrPath('x'.repeat(5000))).toBeNull();
    expect(header({ kind: 'qr', value: 'x'.repeat(5000), caption: null, align: 'center' })).toBe(
      '<header class="receipt-header"></header>',
    );
  });

  it('draws a Code 128 barcode with its number, and nothing for text it cannot encode', () => {
    const html = header({ kind: 'barcode', value: 'R100', align: 'right' });
    expect(html).toMatch(
      /^<header class="receipt-header"><figure class="receipt-barcode receipt-code-right" data-barcode-value="R100"><svg viewBox="0 0 \d+ 30" preserveAspectRatio="none" shape-rendering="crispEdges" style="width:\d+\.\dmm" role="img" aria-label="R100">(<rect x="\d+" y="0" width="\d" height="30" fill="#000"><\/rect>)+<\/svg><figcaption>R100<\/figcaption><\/figure><\/header>$/,
    );
    expect(header({ kind: 'barcode', value: 'Không', align: 'center' })).not.toContain('figure');
  });

  it('prints signature boxes on A4 and A5 only', () => {
    const block: PrintBlock = {
      kind: 'signatures',
      parties: [
        { party: 'buyer', label: 'Buyer & co' },
        { party: 'seller', label: 'Seller' },
      ],
    };
    const signatures =
      '<div class="receipt-signatures" style="grid-template-columns:repeat(2, minmax(0, 1fr))"><div class="receipt-signature"><strong>Buyer &amp; co</strong></div><div class="receipt-signature"><strong>Seller</strong></div></div>';
    expect(header(block, 'a4')).toContain(signatures);
    expect(header(block, 'a5')).toContain(signatures);
    expect(header(block, '80mm')).not.toContain('receipt-signatures');
    expect(header(block, 'a6')).not.toContain('receipt-signatures');
  });
});

describe('sections', () => {
  it('prints rows, stacked lines, pay QR, notes, footer and disclaimer in order', () => {
    const html = renderSheetContentHtml(
      {
        ...base,
        meta: [{ label: 'A', value: '1', strong: true }],
        lines: {
          layout: 'stacked',
          items: [{ index: 1, name: 'Tea', amount: '10', details: ['note'] }],
        },
        totals: [{ label: 'T', value: '10' }],
        payments: [{ label: 'Cash', value: '10' }],
        payQr: { value: 'pay', caption: 'Pay', lines: ['Ref 1'] },
        notes: ['n'],
        footer: [{ kind: 'divider', style: 'solid' }],
        disclaimer: 'd',
      },
      { paper: '80mm' },
    );
    const order = [
      '<dl class="receipt-meta"><div class="receipt-strong"><dt>A</dt><dd>1</dd></div></dl>',
      '<ol class="receipt-lines"><li><div class="receipt-line-head"><span>1. Tea</span><span class="receipt-money">10</span></div><p class="receipt-line-detail">note</p></li></ol>',
      '<dl class="receipt-totals"><div><dt>T</dt><dd>10</dd></div></dl>',
      '<dl class="receipt-payments">',
      '<section class="receipt-pay-qr" data-testid="receipt-pay-qr"><figure class="receipt-qr receipt-code-center" data-qr-value="pay">',
      '<p>Ref 1</p></section>',
      '<p class="receipt-note">n</p>',
      '<footer class="receipt-footer"><div class="receipt-divider receipt-divider-solid"></div></footer>',
      '<p class="receipt-disclaimer">d</p>',
    ];
    const positions = order.map((part) => html.indexOf(part));
    expect(positions.every((position) => position >= 0)).toBe(true);
    expect([...positions].sort((a, b) => a - b)).toEqual(positions);
  });

  it('lays a table template out as a ruled grid on sheets and as ticket rows on rolls', () => {
    const lines: PrintDocument['lines'] = {
      layout: 'table',
      headings: { index: '#', name: 'Item' },
      columns: [{ key: 'qty', label: 'Qty' }],
      rows: [{ index: 1, name: 'Tea', cells: ['2'], details: ['hot'] }],
    };
    expect(renderSheetContentHtml({ ...base, lines }, { paper: 'a4' })).toContain(
      '<table class="receipt-grid"><thead><tr><th scope="col" class="receipt-grid-index">#</th><th scope="col" class="receipt-grid-name">Item</th><th scope="col">Qty</th></tr></thead><tbody><tr><td class="receipt-grid-index">1</td><td class="receipt-grid-name">Tea<small>hot</small></td><td>2</td></tr></tbody></table>',
    );
    expect(renderSheetContentHtml({ ...base, lines }, { paper: '80mm' })).toContain(
      '<table class="ticket-table"><thead><tr><th scope="col">Qty</th></tr></thead><tbody><tr class="ticket-name"><td colspan="1">1. Tea</td></tr><tr class="ticket-detail"><td colspan="1">hot</td></tr><tr class="ticket-figures"><td>2</td></tr></tbody></table>',
    );
  });

  it('leaves out empty sections', () => {
    expect(renderSheetContentHtml(base, { paper: '80mm' })).toBe(
      '<header class="receipt-header"></header>',
    );
  });
});
