import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  AUTO_PRINT_KEY,
  autoPrintEnabled,
  LEGACY_PAPER_KEYS,
  rememberedTemplate,
  rememberedTemplateKey,
  rememberTemplate,
  setAutoPrint,
} from './receipt-preferences';

describe('device receipt preferences', () => {
  beforeEach(() => {
    const store = new Map<string, string>();
    vi.stubGlobal('window', {
      localStorage: {
        getItem: (key: string) => store.get(key) ?? null,
        setItem: (key: string, value: string) => store.set(key, value),
        removeItem: (key: string) => store.delete(key),
      },
    });
  });
  afterEach(() => vi.unstubAllGlobals());

  it('remembers the last template per document type and drops the old paper preferences', () => {
    for (const key of LEGACY_PAPER_KEYS) window.localStorage.setItem(key, '58mm');
    rememberTemplate('sale', 'postpl_b');
    expect(window.localStorage.getItem(rememberedTemplateKey('sale'))).toBe('postpl_b');
    expect(rememberedTemplate('sale')).toBe('postpl_b');
    expect(rememberedTemplate('return')).toBeNull();
    for (const key of LEGACY_PAPER_KEYS) expect(window.localStorage.getItem(key)).toBeNull();
  });

  it('only enables auto-print for an explicit on preference, and removes it when disabled', () => {
    expect(autoPrintEnabled()).toBe(false);
    window.localStorage.setItem(AUTO_PRINT_KEY, 'true');
    expect(autoPrintEnabled()).toBe(false);
    setAutoPrint(true);
    expect(window.localStorage.getItem(AUTO_PRINT_KEY)).toBe('on');
    expect(autoPrintEnabled()).toBe(true);
    setAutoPrint(false);
    expect(window.localStorage.getItem(AUTO_PRINT_KEY)).toBeNull();
    expect(autoPrintEnabled()).toBe(false);
  });

  it('falls back to manual printing when storage access throws', () => {
    vi.stubGlobal('window', {
      get localStorage() {
        throw new Error('Storage unavailable');
      },
    });
    expect(rememberedTemplate('sale')).toBeNull();
    expect(autoPrintEnabled()).toBe(false);
    expect(() => rememberTemplate('sale', 'postpl_b')).not.toThrow();
    expect(() => setAutoPrint(true)).not.toThrow();
    expect(() => setAutoPrint(false)).not.toThrow();
  });

  it('tolerates failed storage reads, writes and removals', () => {
    const unavailable = () => {
      throw new Error('Storage operation denied');
    };
    vi.stubGlobal('window', {
      localStorage: { getItem: unavailable, setItem: unavailable, removeItem: unavailable },
    });
    expect(rememberedTemplate('sale')).toBeNull();
    expect(autoPrintEnabled()).toBe(false);
    expect(() => rememberTemplate('sale', 'postpl_b')).not.toThrow();
    expect(() => setAutoPrint(true)).not.toThrow();
    expect(() => setAutoPrint(false)).not.toThrow();
  });
});
