import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  beginIntent,
  clearIntents,
  finishIntent,
  forgetIntent,
  hasIntent,
  hasPendingIntents,
  hasUncertainIntents,
  intentKey,
  scopedIntents,
} from './uncertain-intents';

afterEach(() => {
  clearIntents();
  vi.unstubAllGlobals();
});

function installStorage() {
  const data = new Map<string, string>();
  vi.stubGlobal('sessionStorage', {
    getItem: (key: string) => data.get(key) ?? null,
    setItem: (key: string, value: string) => data.set(key, value),
    removeItem: (key: string) => data.delete(key),
  });
}

describe('uncertain command intentions', () => {
  it('persists in-flight evidence without showing an uncertainty warning until the attempt ends', () => {
    installStorage();
    const scope = JSON.stringify(['staff', 'store', 'workspace', 'add']);
    const key = beginIntent(scope);
    expect(hasIntent(scope)).toBe(true);
    expect(hasPendingIntents()).toBe(true);
    expect(hasUncertainIntents('staff', 'store')).toBe(false);
    expect(scopedIntents('staff', 'store')).toEqual([]);
    finishIntent(scope); // Network failure: keep durable evidence.
    expect(hasPendingIntents()).toBe(false);
    expect(hasUncertainIntents('staff', 'store')).toBe(true);
    expect(beginIntent(scope)).toBe(key);
    expect(hasUncertainIntents('staff', 'store')).toBe(true); // Retrying must not hide existing uncertainty.
    forgetIntent(scope);
    finishIntent(scope);
    expect(hasUncertainIntents()).toBe(false);
  });

  it('treats an interrupted in-flight operation as uncertain after a new page/module loads', async () => {
    installStorage();
    const scope = JSON.stringify(['staff', 'store', 'workspace', 'add']);
    const key = beginIntent(scope);
    expect(hasUncertainIntents()).toBe(false);
    vi.resetModules();
    const restored = await import('./uncertain-intents');
    expect(restored.hasPendingIntents()).toBe(false);
    expect(restored.hasUncertainIntents('staff', 'store')).toBe(true);
    expect(restored.intentKey(scope)).toBe(key);
  });
  it('retains an idempotency key for the same scoped intent across module use and clears it', () => {
    const data = new Map<string, string>();
    vi.stubGlobal('sessionStorage', {
      getItem: (key: string) => data.get(key) ?? null,
      setItem: (key: string, value: string) => data.set(key, value),
      removeItem: (key: string) => data.delete(key),
    });
    const key = intentKey('staff:store:workspace:command');
    expect(intentKey('staff:store:workspace:command')).toBe(key);
    expect(intentKey('different-staff')).not.toBe(key);
    forgetIntent('staff:store:workspace:command');
    expect(intentKey('staff:store:workspace:command')).not.toBe(key);
    clearIntents();
    expect(data.size).toBe(0);
  });
});
