import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  DEFAULT_MENU_DENSITY,
  MENU_DENSITY_KEY,
  MENU_IMAGES_KEY,
  savedMenuDensity,
  savedMenuImages,
  saveMenuDensity,
  saveMenuImages,
} from './menu-density';

describe('menu density of this device', () => {
  let store: Map<string, string>;
  beforeEach(() => {
    store = new Map<string, string>();
    vi.stubGlobal('window', {
      localStorage: {
        getItem: (key: string) => store.get(key) ?? null,
        setItem: (key: string, value: string) => store.set(key, value),
      },
    });
  });
  afterEach(() => vi.unstubAllGlobals());

  it('starts at the regular density', () => {
    expect(DEFAULT_MENU_DENSITY).toBe('regular');
    expect(savedMenuDensity()).toBe('regular');
  });

  it('remembers the chosen density', () => {
    saveMenuDensity('dense');
    expect(store.get(MENU_DENSITY_KEY)).toBe('dense');
    expect(savedMenuDensity()).toBe('dense');
    saveMenuDensity('airy');
    expect(savedMenuDensity()).toBe('airy');
  });

  it('ignores a value it does not know', () => {
    store.set(MENU_DENSITY_KEY, 'huge');
    expect(savedMenuDensity()).toBe('regular');
  });

  it('falls back to the default when storage is blocked', () => {
    vi.stubGlobal('window', {
      localStorage: {
        getItem: () => {
          throw new Error('blocked');
        },
        setItem: () => {
          throw new Error('blocked');
        },
      },
    });
    expect(() => saveMenuDensity('dense')).not.toThrow();
    expect(savedMenuDensity()).toBe('regular');
    expect(() => saveMenuImages(false)).not.toThrow();
    expect(savedMenuImages(true)).toBe(true);
  });

  it('shows pictures as the layout prefers until the device chooses', () => {
    expect(savedMenuImages(true)).toBe(true);
    expect(savedMenuImages(false)).toBe(false);
    saveMenuImages(false);
    expect(store.get(MENU_IMAGES_KEY)).toBe('off');
    expect(savedMenuImages(true)).toBe(false);
    saveMenuImages(true);
    expect(savedMenuImages(false)).toBe(true);
    store.set(MENU_IMAGES_KEY, 'maybe');
    expect(savedMenuImages(true)).toBe(true);
  });
});
