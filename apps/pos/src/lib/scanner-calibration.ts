// Per-register barcode scanner calibration: which key ends a scan and how
// fast the scanner types. It is a device setting of this browser, kept in
// local storage per register; it never decides prices or quantities, which
// the server reads from the code itself.

export type ScannerTerminator = 'Enter' | 'Tab';

export type ScannerCalibration = {
  terminator: ScannerTerminator;
  maxGapMs: number;
  calibratedAt: string | null;
};

export const DEFAULT_CALIBRATION: ScannerCalibration = {
  terminator: 'Enter',
  maxGapMs: 100,
  calibratedAt: null,
};

// Gaps slower than this are a person typing, not a scanner.
export const MAX_SCANNER_GAP_MS = 300;
const MIN_GAP_MS = 30;
const MIN_CODE_LENGTH = 3;
export const CALIBRATION_CHANGED = 'parkviet-pos-scanner-calibration';

const storageKey = (registerId: string) => `parkviet-pos:scanner:${registerId}`;

function valid(value: unknown): value is ScannerCalibration {
  if (typeof value !== 'object' || value === null) return false;
  const row = value as Record<string, unknown>;
  return (
    (row.terminator === 'Enter' || row.terminator === 'Tab') &&
    typeof row.maxGapMs === 'number' &&
    Number.isInteger(row.maxGapMs) &&
    row.maxGapMs >= MIN_GAP_MS &&
    row.maxGapMs <= MAX_SCANNER_GAP_MS &&
    (row.calibratedAt === null || typeof row.calibratedAt === 'string')
  );
}

export function readCalibration(
  registerId: string | null,
  storage: Pick<Storage, 'getItem'> | null = safeStorage(),
): ScannerCalibration {
  if (!registerId || !storage) return DEFAULT_CALIBRATION;
  try {
    const parsed: unknown = JSON.parse(storage.getItem(storageKey(registerId)) ?? 'null');
    return valid(parsed) ? parsed : DEFAULT_CALIBRATION;
  } catch {
    return DEFAULT_CALIBRATION;
  }
}

export function saveCalibration(
  registerId: string,
  calibration: ScannerCalibration,
  storage: Pick<Storage, 'setItem'> | null = safeStorage(),
): boolean {
  if (!valid(calibration) || !storage) return false;
  try {
    storage.setItem(storageKey(registerId), JSON.stringify(calibration));
  } catch {
    return false;
  }
  if (typeof window !== 'undefined') window.dispatchEvent(new Event(CALIBRATION_CHANGED));
  return true;
}

export function clearCalibration(
  registerId: string,
  storage: Pick<Storage, 'removeItem'> | null = safeStorage(),
) {
  try {
    storage?.removeItem(storageKey(registerId));
  } catch {
    // Storage unavailable: the default calibration applies anyway.
  }
  if (typeof window !== 'undefined') window.dispatchEvent(new Event(CALIBRATION_CHANGED));
}

function safeStorage(): Storage | null {
  try {
    return typeof window === 'undefined' ? null : window.localStorage;
  } catch {
    return null;
  }
}

export type CalibrationResult =
  | { ok: true; code: string; calibration: ScannerCalibration; slowestGapMs: number }
  | { ok: false; reason: 'too_short' | 'too_slow' | 'pasted' };

// Records one test scan: the characters, the gaps between them and the key
// that ended it. Call `push` for every keydown in the calibration field.
export function createCalibrationRecorder(now: () => string = () => new Date().toISOString()) {
  let code = '';
  let gaps: number[] = [];
  let last: number | null = null;

  function reset() {
    code = '';
    gaps = [];
    last = null;
  }

  return {
    reset,
    // An IME composition is never a scan: it drops the test scan in progress.
    push(event: {
      key: string;
      timeStamp: number;
      isComposing?: boolean;
    }): CalibrationResult | null {
      if (event.isComposing || event.key === 'Process') {
        reset();
        return null;
      }
      if (event.key === 'Enter' || event.key === 'Tab') {
        const result = finish(event.key, event.timeStamp);
        reset();
        return result;
      }
      if (event.key.length !== 1) return null;
      if (last !== null) gaps.push(event.timeStamp - last);
      code += event.key;
      last = event.timeStamp;
      return null;
    },
  };

  function finish(terminator: ScannerTerminator, at: number): CalibrationResult {
    if (code.length < MIN_CODE_LENGTH) return { ok: false, reason: 'too_short' };
    const all = last === null ? gaps : [...gaps, at - last];
    const slowest = Math.max(...all, 0);
    if (slowest > MAX_SCANNER_GAP_MS) return { ok: false, reason: 'too_slow' };
    // Every key at the same instant is a paste or a synthetic event, not a
    // scanner: there is no timing to learn from it.
    if (slowest <= 0) return { ok: false, reason: 'pasted' };
    // Head-room over the slowest gap seen, inside the scanner bounds.
    const maxGapMs = Math.min(
      MAX_SCANNER_GAP_MS,
      Math.max(MIN_GAP_MS, Math.ceil(slowest * 1.5) + 10),
    );
    return {
      ok: true,
      code,
      slowestGapMs: slowest,
      calibration: { terminator, maxGapMs, calibratedAt: now() },
    };
  }
}
