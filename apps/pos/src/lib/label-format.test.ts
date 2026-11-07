import { describe, expect, it } from 'vitest';
import {
  type LabelFormatDraft,
  labelDigitsUsed,
  labelFormatBody,
  labelFormatDraft,
  labelFormatProblems,
} from './label-format';

const draft = (overrides: Partial<LabelFormatDraft> = {}): LabelFormatDraft => ({
  ...labelFormatDraft(),
  name: 'Cân thịt',
  prefix: '21',
  ...overrides,
});

describe('label format layout', () => {
  it('accepts a weight layout whose parts fill the 12 digits', () => {
    expect(labelDigitsUsed(draft())).toBe(12);
    expect(labelFormatProblems(draft())).toEqual([]);
    expect(labelFormatBody(draft())).toEqual({
      name: 'Cân thịt',
      prefix: '21',
      kind: 'weight',
      item_code_length: 5,
      value_length: 5,
      value_decimals: 0,
      value_unit_code: 'g',
      price_tolerance: '0',
    });
  });

  it('blocks a layout that is shorter or longer than 12 digits', () => {
    expect(labelFormatProblems(draft({ item_code_length: '4' }))).toEqual(['layout']);
    expect(labelFormatProblems(draft({ prefix: '2', value_length: '7' }))).toEqual(['layout']);
    expect(labelDigitsUsed(draft({ prefix: '2', value_length: '7' }))).toBe(13);
    expect(labelFormatBody(draft({ item_code_length: '4' }))).toBeNull();
  });

  it('rejects unreadable parts without guessing a sum', () => {
    expect(labelFormatProblems(draft({ prefix: '21a', item_code_length: '0' }))).toEqual([
      'prefix',
      'itemCodeLength',
    ]);
    expect(labelDigitsUsed(draft({ value_length: '1.5' }))).toBeNull();
    expect(labelFormatProblems(draft({ prefix: '12345' }))).toContain('prefix');
    expect(labelFormatProblems(draft({ name: '  ' }))).toEqual(['name']);
    expect(labelFormatProblems(draft({ value_decimals: '5' }))).toEqual(['decimals']);
  });

  it('requires a unit for weight labels and none for price labels', () => {
    expect(labelFormatProblems(draft({ value_unit_code: '' }))).toEqual(['unit']);
    const price = draft({ kind: 'price', value_unit_code: 'kg', price_tolerance: '500' });
    expect(labelFormatProblems(price)).toEqual([]);
    expect(labelFormatBody(price)).toMatchObject({ value_unit_code: null, price_tolerance: '500' });
    expect(labelFormatProblems(draft({ kind: 'price', price_tolerance: '-1' }))).toEqual([
      'tolerance',
    ]);
  });

  it('starts an edit from the stored format', () => {
    expect(
      labelFormatDraft({
        id: 'poslabel_1',
        name: 'Tem giá',
        prefix: '2',
        kind: 'price',
        item_code_length: 6,
        value_length: 5,
        value_decimals: 0,
        value_unit_code: null,
        price_tolerance: '100.0',
        version: 3,
        status: 'active',
      }),
    ).toEqual({
      name: 'Tem giá',
      prefix: '2',
      kind: 'price',
      item_code_length: '6',
      value_length: '5',
      value_decimals: '0',
      value_unit_code: '',
      price_tolerance: '100.0',
    });
  });
});
