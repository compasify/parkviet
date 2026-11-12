import { describe, expect, it } from 'vitest';
import { GuestApiError } from './api';
import { errorKey, keepsKey } from './errors';
import {
  codeFromPath,
  forgetCode,
  pathWithoutCode,
  readCode,
  readToken,
  saveCode,
  saveToken,
} from './session';

function memory() {
  const values = new Map<string, string>();
  return {
    getItem: (key: string) => values.get(key) ?? null,
    setItem: (key: string, value: string) => void values.set(key, value),
    removeItem: (key: string) => void values.delete(key),
  };
}

const CODE = 'Zk3_9qLmT0aBcDeFgHiJkA';

describe('the table code in the address', () => {
  it('reads a well-formed code from /table/t/<code> and nothing else', () => {
    expect(codeFromPath(`/table/t/${CODE}`)).toBe(CODE);
    expect(codeFromPath(`/table/t/${CODE}/`)).toBe(CODE);
    expect(codeFromPath('/table/')).toBeNull();
    expect(codeFromPath('/table/t/short')).toBeNull();
    expect(codeFromPath('/table/t/<script>alert(1)</script>xxxxxxxx')).toBeNull();
  });

  it('leaves the page address without the code', () => {
    expect(pathWithoutCode(`/table/t/${CODE}`)).toBe('/table/');
    expect(pathWithoutCode('/table/')).toBe('/table/');
  });

  it("keeps the token and the code in the tab's storage only", () => {
    const storage = memory();
    saveToken('tok', storage);
    saveCode(CODE, storage);
    expect(readToken(storage)).toBe('tok');
    expect(readCode(storage)).toBe(CODE);
    saveToken(null, storage);
    forgetCode(storage);
    expect(readToken(storage)).toBeNull();
    expect(readCode(storage)).toBeNull();
    storage.setItem('parkviet.table.code', 'bad code');
    expect(readCode(storage)).toBeNull();
  });
});

describe('refusals', () => {
  it('explains known codes and keeps the order key only when nothing was recorded', () => {
    expect(errorKey(new GuestApiError(409, 'item_sold_out', 'x'))).toBe('error_item_sold_out');
    expect(errorKey(new GuestApiError(500, 'boom', 'x'))).toBe('error_unknown');
    expect(errorKey(new Error('x'))).toBe('error_unknown');
    expect(keepsKey(new GuestApiError(0, 'network', 'x'))).toBe(true);
    expect(keepsKey(new GuestApiError(409, 'item_sold_out', 'x'))).toBe(false);
  });
});
