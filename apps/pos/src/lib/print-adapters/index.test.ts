import { DirectTimeout } from '@parkviet/pos-shared/print-commands/direct';
import type { Printer, PrintJob } from '@parkviet/pos-shared/types/print-adapter';
import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  BROWSER_ROUTE,
  choosePrintRoute,
  fetchTransport,
  openPrintJobs,
  stuckPrintJob,
} from './index';

const printer = (over: Partial<Printer> = {}): Printer => ({
  id: 'posprinter_1',
  branch_id: 'br_1',
  name: 'Quầy',
  connection: 'sunmi_builtin',
  address: null,
  bluetooth_id: null,
  paper: '58mm',
  command_language: 'escpos',
  roles: ['receipt'],
  print_station_device_id: 'posdevice_1',
  register_id: null,
  status: 'active',
  settings: {},
  ...over,
});

const job = (over: Partial<PrintJob> = {}): PrintJob => ({
  id: 'posprintjob_1',
  branch_id: 'br_1',
  printer_id: 'posprinter_1',
  printer_name: 'Quầy',
  kind: 'receipt',
  status: 'failed',
  attempts: 5,
  label: null,
  last_error: null,
  copy_of_id: null,
  created_at: '2026-11-08T03:00:00Z',
  printed_at: null,
  workspace_id: null,
  source_revision: null,
  printer_available: true,
  reprinted: false,
  ...over,
});

describe('openPrintJobs', () => {
  it('drops a failed job that was reprinted and keeps the rest', () => {
    const kept = [job({ id: 'a' }), job({ id: 'b', status: 'queued', reprinted: true })];
    expect(openPrintJobs([...kept, job({ id: 'c', reprinted: true })])).toEqual(kept);
  });
});

describe('stuckPrintJob', () => {
  it('is a job waiting on an unavailable printer', () => {
    expect(stuckPrintJob(job({ status: 'queued', printer_available: false }))).toBe(true);
    expect(stuckPrintJob(job({ status: 'claimed', printer_available: false }))).toBe(true);
    expect(stuckPrintJob(job({ status: 'queued' }))).toBe(false);
    expect(stuckPrintJob(job({ status: 'failed', printer_available: false }))).toBe(false);
  });
});

describe('choosePrintRoute', () => {
  it('uses the browser without a printer for the role', () => {
    expect(choosePrintRoute([], 'receipt', 'reg_1')).toEqual(BROWSER_ROUTE);
    expect(choosePrintRoute([printer({ roles: ['prebill'] })], 'receipt', null)).toEqual(
      BROWSER_ROUTE,
    );
  });

  it('ignores a disabled printer', () => {
    expect(choosePrintRoute([printer({ status: 'disabled' })], 'receipt', null)).toEqual(
      BROWSER_ROUTE,
    );
  });

  it('prefers the register printer to the branch printer', () => {
    const branch = printer({ id: 'branch' });
    const own = printer({ id: 'own', register_id: 'reg_1' });
    expect(choosePrintRoute([branch, own], 'receipt', 'reg_1')).toEqual({
      kind: 'queue',
      printer: own,
    });
  });

  it('does not borrow another register printer', () => {
    expect(choosePrintRoute([printer({ register_id: 'reg_2' })], 'receipt', 'reg_1')).toEqual(
      BROWSER_ROUTE,
    );
  });

  it('routes by connection', () => {
    const epson = printer({ connection: 'epson_epos', address: '10.0.0.5' });
    const star = printer({ connection: 'star_webprnt', address: '10.0.0.6' });
    expect(choosePrintRoute([epson], 'receipt', null).kind).toBe('direct');
    expect(choosePrintRoute([star], 'receipt', null).kind).toBe('direct');
    expect(choosePrintRoute([printer({ connection: 'browser' })], 'receipt', null)).toEqual(
      BROWSER_ROUTE,
    );
    for (const connection of ['escpos_lan', 'escpos_bluetooth', 'sunmi_builtin'] as const)
      expect(choosePrintRoute([printer({ connection })], 'receipt', null).kind).toBe('queue');
  });
});

describe('fetchTransport', () => {
  afterEach(() => vi.unstubAllGlobals());
  const request = { url: 'http://p/', headers: {}, body: '<x/>', timeoutMs: 5 };

  it('returns the status and body', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => new Response('ok', { status: 201 })),
    );
    await expect(fetchTransport.send(request)).resolves.toEqual({ status: 201, body: 'ok' });
  });

  it('reports an abort as a timeout', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(
        (_url: string, init: RequestInit) =>
          new Promise((_resolve, reject) => {
            init.signal?.addEventListener('abort', () =>
              reject(new DOMException('', 'AbortError')),
            );
          }),
      ),
    );
    await expect(fetchTransport.send(request)).rejects.toBeInstanceOf(DirectTimeout);
  });

  it('passes a network failure on for diagnosis', async () => {
    const failure = new TypeError('Failed to fetch');
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => Promise.reject(failure)),
    );
    await expect(fetchTransport.send(request)).rejects.toBe(failure);
  });
});
