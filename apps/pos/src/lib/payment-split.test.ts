import { describe, expect, it } from 'vitest';
import { rebalanceRows, splitRowValues } from './payment-split';

describe('split payment rows', () => {
  it('gives the first row the target and later rows what is left', () => {
    expect(splitRowValues(['cash'], '100000', null)).toEqual({ cash: '100000' });
    expect(splitRowValues(['cash', 'vietqr'], '100000', null)).toEqual({
      cash: '100000',
      vietqr: '0',
    });
    expect(splitRowValues(['cash', 'bank_manual', 'vietqr'], '100000', { cash: '30000' })).toEqual({
      cash: '30000',
      bank_manual: '70000',
      vietqr: '0',
    });
  });

  it('rebalances the first row, or the last when the first was typed', () => {
    expect(rebalanceRows(['cash', 'vietqr'], '100000', null, 'cash', '40000')).toEqual({
      cash: '40000',
      vietqr: '60000',
    });
    expect(rebalanceRows(['cash', 'vietqr'], '100000', null, 'vietqr', '25.000')).toEqual({
      cash: '75000',
      vietqr: '25.000',
    });
    expect(
      rebalanceRows(['cash', 'bank_manual', 'vietqr'], '100000', null, 'bank_manual', '20000'),
    ).toEqual({ cash: '80000', bank_manual: '20000' });
  });

  it('never goes below zero and keeps a single row as typed', () => {
    expect(rebalanceRows(['cash', 'vietqr'], '100000', null, 'cash', '150000')).toEqual({
      cash: '150000',
      vietqr: '0',
    });
    expect(rebalanceRows(['vietqr'], '100000', null, 'vietqr', '5')).toEqual({ vietqr: '5' });
  });
});
