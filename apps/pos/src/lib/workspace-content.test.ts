import { describe, expect, it } from 'vitest';
import type { PosWorkspace } from './pos-context';
import { workspaceHasContent, workspaceIsSettled, workspacePhase } from './workspace-content';

const blank: PosWorkspace = {
  id: 'ws_1',
  branch_id: 'br_1',
  register_id: 'rg_1',
  shift_id: 'sh_1',
  order_id: 'or_1',
  revision: 1,
  lease_generation: 1,
  operational_status: 'editing',
  payments: false,
  note: null,
  customer: null,
  line_items: [],
  discount: null,
  coupon: null,
};

describe('workspaceHasContent', () => {
  it('treats a freshly opened invoice as blank', () => {
    expect(workspaceHasContent(blank)).toBe(false);
    expect(workspaceHasContent({ ...blank, note: '   ' })).toBe(false);
  });

  it('keeps any entered work', () => {
    const line = { id: 'li_1', quantity: 1 } as NonNullable<PosWorkspace['line_items']>[number];
    expect(workspaceHasContent({ ...blank, line_items: [line] })).toBe(true);
    expect(
      workspaceHasContent({
        ...blank,
        customer: {
          id: null,
          name: 'An',
          phone: null,
          email: null,
          customer_id: null,
          has_account: false,
        } as PosWorkspace['customer'],
      }),
    ).toBe(true);
    expect(workspaceHasContent({ ...blank, note: 'giao sau' })).toBe(true);
    expect(workspaceHasContent({ ...blank, coupon: { code: 'X', amount: '1' } })).toBe(true);
    expect(workspaceHasContent({ ...blank, payments: true })).toBe(true);
  });
});

describe('workspacePhase', () => {
  it('splits an open invoice into selling and paying', () => {
    expect(workspacePhase(blank)).toBe('editing');
    expect(workspacePhase({ ...blank, payments: true })).toBe('paying');
    expect(workspacePhase({ ...blank, operational_status: 'parked' })).toBe('parked');
    expect(workspacePhase({ ...blank, operational_status: 'completed', payments: true })).toBe(
      'completed',
    );
    expect(workspacePhase({ ...blank, operational_status: 'canceled' })).toBe('canceled');
  });
});

describe('workspaceIsSettled', () => {
  it('only finished or canceled invoices are settled', () => {
    expect(workspaceIsSettled({ operational_status: 'canceled' })).toBe(true);
    expect(workspaceIsSettled({ operational_status: 'completed' })).toBe(true);
    expect(workspaceIsSettled({ operational_status: 'editing' })).toBe(false);
    expect(workspaceIsSettled({ operational_status: 'parked' })).toBe(false);
  });
});
