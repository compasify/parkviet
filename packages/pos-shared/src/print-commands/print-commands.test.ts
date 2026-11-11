import { describe, expect, it, vi } from 'vitest';
import type { PrinterTarget } from '../types/print-adapter';
import { documentCommands, type PrintableDocument, printerColumns, wrapText } from './commands';
import {
  certainlyUnprinted,
  createFetchTransport,
  DirectTimeout,
  type DirectTransport,
  type FetchLike,
  printDirect,
  REACHABLE_TIMEOUT_MS,
} from './direct';
import { eposBody, eposSucceeded, xml } from './epson-epos';
import { starBinary, starBody, starMarkup, starSucceeded, starText } from './star-webprnt';

const HOSTILE = `</text><cut type="feed"/>&'\\`;

const document: PrintableDocument = {
  banners: ['BẢN SAO'],
  header: [
    { kind: 'title', title: 'PHIẾU', number: 'R1' },
    { kind: 'text', lines: [HOSTILE], align: 'center', bold: true, size: 'l' },
    { kind: 'image', src: '/l.png', alt: '', widthPct: 50, align: 'left', monochrome: false },
    { kind: 'divider', style: 'solid' },
    { kind: 'spacer', mm: 8 },
  ],
  meta: [{ label: 'Khách', value: HOSTILE }],
  lines: { layout: 'stacked', items: [{ index: 1, name: HOSTILE, amount: '1 ₫', details: ['d'] }] },
  totals: [{ label: 'Tổng', value: '1 ₫', strong: true }],
  payments: [],
  payQr: { value: 'QR&<', caption: 'Quét', lines: ['a'] },
  notes: [HOSTILE],
  footer: [
    { kind: 'qr', value: 'https://a.test/?a=1&b=2', caption: null, align: 'right' },
    { kind: 'barcode', value: 'R{1', align: 'center' },
    { kind: 'signatures', parties: [{ party: 'buyer', label: 'Khách' }] },
  ],
  disclaimer: 'x',
};

const printer = (over: Partial<PrinterTarget> = {}): PrinterTarget => ({
  connection: 'epson_epos',
  address: '10.0.0.5:8008',
  paper: '80mm',
  settings: {},
  ...over,
});

const commands = documentCommands(document, printer());

describe('documentCommands', () => {
  it('uses the paper width unless the printer sets one', () => {
    expect(printerColumns(printer({ paper: '58mm' }))).toBe(32);
    expect(printerColumns(printer())).toBe(48);
    expect(printerColumns(printer({ settings: { char_width: 42 } }))).toBe(42);
  });

  it('wraps by words and breaks words longer than the line', () => {
    expect(wrapText('một hai ba', 7)).toEqual(['một hai', 'ba']);
    expect(wrapText('abcdefgh', 3)).toEqual(['abc', 'def', 'gh']);
  });

  it('keeps every line within the paper', () => {
    for (const command of commands)
      if (command.type === 'text')
        expect([...command.text].length).toBeLessThanOrEqual(command.large ? 24 : 48);
  });

  it('removes control characters a document could carry', () => {
    const [line] = wrapText('a\u001b@b\nc', 48);
    expect(line).toBe('a @b c');
  });

  it('skips images and ends with a cut', () => {
    expect(commands.at(-1)).toEqual({ type: 'cut' });
  });

  it('leaves the cut out when the printer has no cutter', () => {
    const uncut = documentCommands(document, printer({ settings: { cut: false } }));
    expect(uncut.some((command) => command.type === 'cut')).toBe(false);
  });

  it('prints the right two columns of a row', () => {
    const [line] = documentCommands(
      { ...document, banners: [], header: [], meta: [{ label: 'A', value: 'B' }] },
      printer({ paper: '58mm' }),
    );
    expect(line).toMatchObject({ text: `A${' '.repeat(30)}B` });
  });
});

describe('Epson ePOS-Print', () => {
  it('escapes every document string', () => {
    const body = eposBody(commands);
    expect(body).not.toContain('</text><cut type="feed"/>&');
    expect(body).toContain('&lt;/text&gt;&lt;cut type=&quot;feed&quot;/&gt;&amp;&apos;\\');
    expect(body).toContain('https://a.test/?a=1&amp;b=2');
    expect(body.match(/<cut /g)).toHaveLength(1);
  });

  it('removes characters XML cannot carry', () => {
    expect(xml('a\u0001\u000bb')).toBe('ab');
  });

  it('doubles a brace in barcode data', () => {
    expect(eposBody(commands)).toContain('>{BR{{1</barcode>');
  });

  it('reads the printer answer', () => {
    expect(eposSucceeded('<response success="true" code="" status="1"/>')).toBe(true);
    expect(eposSucceeded('<response success="false" code="EPTR_REC_EMPTY"/>')).toBe(false);
    expect(eposSucceeded('nothing')).toBe(false);
  });
});

describe('Star WebPRNT', () => {
  it('escapes markup and spaces in text', () => {
    expect(starText('a<b>&c d\\')).toBe('a\\x3cb\\x3e\\x26c\\x20d\\\\');
  });

  it('keeps Vietnamese text as it is', () => {
    expect(starText('Tiếng')).toBe('Tiếng');
  });

  it('sends codes as bytes', () => {
    expect(starBinary('é<')).toBe('\\xc3\\xa9\\x3c');
  });

  it('cannot be broken out of by a document string', () => {
    const markup = starMarkup(commands);
    expect(markup).not.toContain('</text><cut');
    expect(markup.match(/<cutpaper /g)).toHaveLength(1);
  });

  it('escapes the markup again inside the envelope', () => {
    const body = starBody(commands);
    expect(body.match(/<text/g)).toBeNull();
    expect(body).toContain('&lt;root&gt;');
  });

  it('reads an escaped or plain answer', () => {
    expect(
      starSucceeded('<Response>&lt;root&gt;&lt;success&gt;true&lt;/success&gt;</Response>'),
    ).toBe(true);
    expect(starSucceeded('<root><success>false</success></root>')).toBe(false);
  });
});

describe('printDirect', () => {
  const transport = (over: Partial<DirectTransport>): DirectTransport => ({
    send: vi.fn(async () => ({ status: 200, body: '<response success="true"/>' })),
    reachable: vi.fn(async () => false),
    ...over,
  });
  const run = (target: PrinterTarget, used: DirectTransport, pageProtocol = 'http:') =>
    printDirect(target, document, { transport: used, pageProtocol });

  it('prints and addresses the Epson service', async () => {
    const used = transport({});
    await expect(run(printer(), used)).resolves.toEqual({ ok: true });
    expect(vi.mocked(used.send).mock.calls[0]?.[0].url).toBe(
      'http://10.0.0.5:8008/cgi-bin/epos/service.cgi?devid=local_printer&timeout=10000',
    );
  });

  it('addresses the Star service', async () => {
    const used = transport({
      send: vi.fn(async () => ({ status: 200, body: '<success>true</success>' })),
    });
    await expect(run(printer({ connection: 'star_webprnt' }), used)).resolves.toEqual({ ok: true });
    expect(vi.mocked(used.send).mock.calls[0]?.[0].url).toBe(
      'http://10.0.0.5:8008/StarWebPRNT/SendMessage',
    );
  });

  it('reports mixed content without attempting it', async () => {
    const used = transport({});
    await expect(run(printer(), used, 'https:')).resolves.toEqual({
      ok: false,
      reason: 'mixed_content',
    });
    expect(used.send).not.toHaveBeenCalled();
  });

  it('allows an https page when the printer serves https', async () => {
    const used = transport({});
    await expect(run(printer({ settings: { https: true } }), used, 'https:')).resolves.toEqual({
      ok: true,
    });
    expect(vi.mocked(used.send).mock.calls[0]?.[0].url).toMatch(/^https:/);
  });

  it('tells a CORS refusal from an unreachable printer', async () => {
    const send = vi.fn(async () => {
      throw new TypeError('Failed to fetch');
    });
    await expect(
      run(printer(), transport({ send, reachable: vi.fn(async () => true) })),
    ).resolves.toEqual({ ok: false, reason: 'cors' });
    await expect(run(printer(), transport({ send }))).resolves.toEqual({
      ok: false,
      reason: 'unreachable',
    });
  });

  it('maps a refused answer and a bad status to a printer error', async () => {
    const refused = { status: 200, body: '<response success="false"/>' };
    const broken = { status: 500, body: '<response success="true"/>' };
    for (const answer of [refused, broken])
      await expect(run(printer(), transport({ send: vi.fn(async () => answer) }))).resolves.toEqual(
        { ok: false, reason: 'printer_error' },
      );
  });

  it('reports a timeout, which may still have printed', async () => {
    const send = vi.fn(async () => {
      throw new DirectTimeout();
    });
    const outcome = await run(printer(), transport({ send }));
    expect(outcome).toEqual({ ok: false, reason: 'timeout' });
    expect(certainlyUnprinted(outcome)).toBe(false);
  });

  it('reports a missing address without attempting it', async () => {
    const used = transport({});
    const outcome = await run(printer({ address: null }), used);
    expect(outcome).toEqual({ ok: false, reason: 'no_address' });
    expect(used.send).not.toHaveBeenCalled();
    expect(certainlyUnprinted(outcome)).toBe(true);
  });

  it('counts only failures known to leave no paper as certainly unprinted', () => {
    for (const reason of ['mixed_content', 'no_address', 'printer_error'] as const)
      expect(certainlyUnprinted({ ok: false, reason })).toBe(true);
    expect(certainlyUnprinted({ ok: true })).toBe(false);
  });

  it('never counts a rejected request as certainly unprinted', () => {
    for (const reason of ['cors', 'unreachable', 'timeout', 'failed'] as const)
      expect(certainlyUnprinted({ ok: false, reason })).toBe(false);
  });
});

describe('createFetchTransport', () => {
  const hanging: FetchLike = (_url, init) =>
    new Promise((_resolve, reject) => {
      init.signal.addEventListener('abort', () => reject(new Error('aborted')));
    });

  it('posts the request and returns the answer', async () => {
    const fetchFn = vi.fn<FetchLike>(async () => ({ status: 200, text: async () => 'ok' }));
    const answer = await createFetchTransport(fetchFn).send({
      url: 'http://p/x',
      headers: { a: 'b' },
      body: 'data',
      timeoutMs: 1000,
    });
    expect(answer).toEqual({ status: 200, body: 'ok' });
    expect(fetchFn.mock.calls[0]?.[1]).toMatchObject({ method: 'POST', body: 'data' });
  });

  it('turns an expired send into a timeout', async () => {
    await expect(
      createFetchTransport(hanging).send({ url: 'u', headers: {}, body: '', timeoutMs: 1 }),
    ).rejects.toBeInstanceOf(DirectTimeout);
  });

  it('gives up on a silent address instead of waiting forever', async () => {
    vi.useFakeTimers();
    try {
      const pending = createFetchTransport(hanging).reachable('http://p');
      const settled = expect(pending).rejects.toThrow('aborted');
      await vi.advanceTimersByTimeAsync(REACHABLE_TIMEOUT_MS);
      await settled;
    } finally {
      vi.useRealTimers();
    }
  });

  it('counts an opaque answer as reachable', async () => {
    const fetchFn = vi.fn<FetchLike>(async () => ({ status: 0, text: async () => '' }));
    await expect(createFetchTransport(fetchFn).reachable('http://p')).resolves.toBe(true);
    expect(fetchFn.mock.calls[0]?.[1].mode).toBe('no-cors');
  });
});
