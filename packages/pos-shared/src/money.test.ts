import { describe, expect, it } from 'vitest';
import {
  formatMoney,
  parseMoneyInput,
  parsePercentageInput,
  parseVndAmount,
  parseVndInput,
} from './money';

describe('cashier VND input', () => {
  it('reads dot or space grouped thousands as whole VND', () => {
    expect(parseVndInput('100.000')).toBe('100000');
    expect(parseVndInput('1.500.000')).toBe('1500000');
    expect(parseVndInput('1 500 000')).toBe('1500000');
    expect(parseVndInput(' 150000 ')).toBe('150000');
    expect(parseVndInput('0')).toBe('0');
  });

  it('rejects commas, fractions, signs and malformed groups', () => {
    for (const input of [
      '200,000',
      '100.5',
      '100.00',
      '1.5000',
      '-100',
      '+100',
      '',
      '1..000',
      '1.000 000',
      '150000.0',
    ]) {
      expect(parseVndInput(input)).toBeNull();
    }
  });
});

describe('decimal input', () => {
  it('formats server amounts for Vietnamese readers without losing precision', () => {
    expect(formatMoney('125000.0')).toBe('125.000 ₫');
    expect(formatMoney('0.0')).toBe('0 ₫');
    expect(formatMoney('123456789012345678901.00000001', 'USD')).toBe(
      '123.456.789.012.345.678.901,00000001 USD',
    );
    expect(formatMoney('-12500.50')).toBe('-12.500,5 ₫');
    expect(formatMoney(null)).toBe('—');
    expect(formatMoney('NaN')).toBe('—');
  });
  it('preserves exact decimal prices without floating point or rounding', () => {
    expect(parseMoneyInput(' 0000.4000 ')).toBe('0.4');
    expect(parseMoneyInput('123456789012345678901.00000001')).toBe(
      '123456789012345678901.00000001',
    );
    expect(parseMoneyInput('0.0000')).toBe('0');
  });

  it('does not accept signs, exponent notation, separators or incomplete values', () => {
    for (const input of ['', '.4', '1.', '-1', '+1', '1e3', '1,000', '1 000', 'NaN', 'Infinity']) {
      expect(parseMoneyInput(input)).toBeNull();
    }
  });

  it('accepts only whole VND totals but not fractional VND', () => {
    expect(parseVndAmount('00100.00')).toBe('100');
    expect(parseVndAmount('100.01')).toBeNull();
    expect(parseMoneyInput('0.4')).toBe('0.4');
  });

  it('parses percentages separately and caps them at 100 without rounding', () => {
    expect(parsePercentageInput('100.000')).toBe('100');
    expect(parsePercentageInput('99.999999999999999')).toBe('99.999999999999999');
    expect(parsePercentageInput('100.00000000001')).toBeNull();
    expect(parsePercentageInput('101')).toBeNull();
  });
});
