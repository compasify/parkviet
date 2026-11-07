import { describe, expect, it, vi } from 'vitest';
import { resolveScan } from './measured-label';
import {
  createCalibrationRecorder,
  DEFAULT_CALIBRATION,
  readCalibration,
  saveCalibration,
} from './scanner-calibration';
import { createScannerKeyBuffer, createScannerQueue } from './scanner-queue';

function memoryStorage() {
  const map = new Map<string, string>();
  return {
    getItem: (key: string) => map.get(key) ?? null,
    setItem: (key: string, value: string) => void map.set(key, value),
    removeItem: (key: string) => void map.delete(key),
  };
}

function type(
  buffer: ReturnType<typeof createScannerKeyBuffer>,
  keys: string[],
  gap: number,
  start = 0,
) {
  let at = start;
  let result: string | null = null;
  for (const key of keys) {
    at += gap;
    result = buffer.push({ key, timeStamp: at }, true) ?? result;
  }
  return result;
}

describe('scanner calibration', () => {
  it('learns the terminator and timing of one test scan', () => {
    const recorder = createCalibrationRecorder(() => '2026-11-07T10:00:00Z');
    let at = 0;
    let result = null;
    for (const key of [...'2012345012345', 'Tab']) {
      at += 18;
      result = recorder.push({ key, timeStamp: at }) ?? result;
    }
    expect(result).toEqual({
      ok: true,
      code: '2012345012345',
      slowestGapMs: 18,
      calibration: { terminator: 'Tab', maxGapMs: 37, calibratedAt: '2026-11-07T10:00:00Z' },
    });
  });

  it('rejects typing by hand and too-short scans', () => {
    const recorder = createCalibrationRecorder();
    for (const [key, at] of [
      ['1', 0],
      ['2', 400],
      ['3', 800],
    ] as const)
      recorder.push({ key, timeStamp: at });
    expect(recorder.push({ key: 'Enter', timeStamp: 820 })).toEqual({
      ok: false,
      reason: 'too_slow',
    });
    recorder.push({ key: '1', timeStamp: 900 });
    expect(recorder.push({ key: 'Enter', timeStamp: 910 })).toEqual({
      ok: false,
      reason: 'too_short',
    });
  });

  it('drops a test scan on IME composition and refuses pasted codes', () => {
    const recorder = createCalibrationRecorder();
    recorder.push({ key: '8', timeStamp: 10 });
    recorder.push({ key: '9', timeStamp: 20 });
    recorder.push({ key: 'Process', timeStamp: 30, isComposing: true });
    recorder.push({ key: '3', timeStamp: 40 });
    expect(recorder.push({ key: 'Enter', timeStamp: 50 })).toEqual({
      ok: false,
      reason: 'too_short',
    });
    for (const key of '8930001') recorder.push({ key, timeStamp: 100 });
    expect(recorder.push({ key: 'Enter', timeStamp: 100 })).toEqual({
      ok: false,
      reason: 'pasted',
    });
  });

  it('stores calibration per register and falls back to the default for bad data', () => {
    const storage = memoryStorage();
    const calibration = { terminator: 'Tab' as const, maxGapMs: 60, calibratedAt: null };
    expect(saveCalibration('reg_1', calibration, storage)).toBe(true);
    expect(readCalibration('reg_1', storage)).toEqual(calibration);
    expect(readCalibration('reg_2', storage)).toEqual(DEFAULT_CALIBRATION);
    storage.setItem('parkviet-pos:scanner:reg_3', '{"terminator":"Space","maxGapMs":5}');
    expect(readCalibration('reg_3', storage)).toEqual(DEFAULT_CALIBRATION);
    expect(saveCalibration('reg_1', { ...calibration, maxGapMs: 5000 }, storage)).toBe(false);
  });

  it('applies the calibrated terminator and gap to scanner input', () => {
    const tab = createScannerKeyBuffer({ terminator: 'Tab', maxGapMs: 40 });
    expect(type(tab, [...'8930001', 'Tab'], 20)).toBe('8930001');
    // Enter is not this device's terminator.
    expect(type(tab, [...'8930001', 'Enter'], 20, 1000)).toBeNull();
    // Slower than the calibrated gap: a person typing, never a scan.
    expect(type(tab, [...'8930001', 'Tab'], 60, 2000)).toBeNull();
  });

  it('drops a burst when focus is in a text field or an IME is composing', () => {
    const buffer = createScannerKeyBuffer();
    buffer.push({ key: '8', timeStamp: 1 }, true);
    buffer.push({ key: '9', timeStamp: 2 }, false);
    expect(buffer.push({ key: 'Enter', timeStamp: 3 }, true)).toBeNull();
  });
});

describe('measurement barcodes', () => {
  it('lets the server parser read a scale label and never sends a client price', async () => {
    const parse = vi.fn().mockResolvedValue({
      kind: 'measured_label',
      barcode: '2100012012508',
      variant_id: 'variant_1',
      name: 'Thịt heo',
      sku: 'TH-1',
      sale_quantity: '1.25',
      sale_unit: 'kg',
      base_quantity: 1250,
      base_unit: 'g',
      unit_price: '120000.0',
      line_amount: '150000.0',
      label_amount: null,
      label_kind: 'weight',
      format_version: 1,
    });
    const fetchPage = vi.fn();
    const outcome = await resolveScan(' 2100012012508 ', parse, fetchPage);
    expect(parse).toHaveBeenCalledWith('2100012012508');
    expect(fetchPage).not.toHaveBeenCalled();
    expect(outcome).toMatchObject({ kind: 'label', label: { barcode: '2100012012508' } });
  });

  it('falls back to the exact catalog lookup for an ordinary code', async () => {
    const parse = vi.fn().mockResolvedValue({ kind: 'ordinary' });
    const fetchPage = vi.fn().mockResolvedValue({
      data: [{ id: 'v1', name: 'Nước', sku: 'N1', barcode: '893', price: '10000.0' }],
      meta: { count: 1 },
    });
    expect(await resolveScan('893', parse, fetchPage)).toMatchObject({ kind: 'match' });
  });

  it('refuses a malformed parser answer instead of guessing', async () => {
    const parse = vi.fn().mockResolvedValue({ kind: 'measured_label', barcode: 1 });
    expect(await resolveScan('2100012', parse, vi.fn())).toEqual({
      kind: 'label_invalid',
      message: null,
    });
  });

  it('retries a scan whose outcome was unknown with the same intent and key', async () => {
    const send = vi.fn().mockResolvedValueOnce('unknown').mockResolvedValue('applied');
    const queue = createScannerQueue(send, () => 'scan-key');
    const intent = queue.enqueue('ws_a', '2100012012508');
    await new Promise((resolve) => setTimeout(resolve, 0));
    queue.retry('ws_a');
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(send).toHaveBeenCalledTimes(2);
    expect(send.mock.calls[1][0]).toBe(intent);
    expect(send.mock.calls[1][0].idempotencyKey).toBe('scan-key');
    expect(queue.snapshot('ws_a').pending).toHaveLength(0);
  });
});
