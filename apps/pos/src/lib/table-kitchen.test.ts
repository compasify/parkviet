import { describe, expect, it } from 'vitest';
import type { PosBranch, PosLineItem, PosWorkspace } from './pos-context';
import {
  addsByAppend,
  appendable,
  editsByVersion,
  findLine,
  lineChanged,
  lineSent,
  VOID_OTHER,
  voidReasons,
} from './table-kitchen';

const line = (extra: Partial<PosLineItem> = {}) =>
  ({
    id: 'li_1',
    sale_line_id: 'posline_1',
    variant_id: 'variant_1',
    product_id: 'prod_1',
    name: 'Phở bò',
    sku: 'PHO',
    quantity: 2,
    price: '50000',
    amount: '100000',
    discounts: [],
    kind: 'menu',
    kitchen_sent_quantity: '0.0',
    row_version: 3,
    ...extra,
  }) as PosLineItem;

const workspace = (extra: Record<string, unknown> = {}) =>
  ({
    id: 'ws_1',
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: 'R100',
    revision: 4,
    lease_generation: 1,
    operational_status: 'editing',
    payments: false,
    resource: { id: 'posres_1', name: 'Bàn 1', area_id: null },
    line_items: [line()],
    ...extra,
  }) as PosWorkspace;

const counter = workspace({ resource: null });
const conflict = (reason: string) => ({ status: 409, message: 'No.', details: { reason } });

describe('several people at one table', () => {
  it('lets anyone add to an open table order with nothing paid, without the lease', () => {
    expect(appendable(workspace(), true, false)).toBe(true);
    expect(appendable(workspace({ operational_status: 'parked' }), true, false)).toBe(true);
    expect(appendable(workspace(), false, false)).toBe(false);
    expect(appendable(workspace(), true, true)).toBe(false);
    expect(appendable(workspace({ payments: true }), true, false)).toBe(false);
    expect(appendable(workspace({ operational_status: 'completed' }), true, false)).toBe(false);
    expect(appendable(counter, true, false)).toBe(false);
    expect(appendable(null, true, false)).toBe(false);
  });

  it('adds by append only menu-style additions to a table order', () => {
    expect(addsByAppend(workspace(), { merge: true })).toBe(true);
    expect(addsByAppend(workspace(), { modifiers: [], note: 'ít cay', merge: undefined })).toBe(
      true,
    );
    expect(addsByAppend(workspace(), { lot_code: 'L1' })).toBe(false);
    expect(addsByAppend(workspace(), { price_override: '1000' })).toBe(false);
    expect(addsByAppend(counter, { merge: true })).toBe(false);
  });

  it('edits a table line by its version only while the kitchen has none of it', () => {
    expect(editsByVersion(workspace(), line())).toBe(true);
    expect(editsByVersion(workspace(), line({ kitchen_sent_quantity: '1.0' }))).toBe(false);
    expect(editsByVersion(workspace(), line({ row_version: undefined }))).toBe(false);
    expect(editsByVersion(workspace(), line({ sale_line_id: null }))).toBe(false);
    expect(editsByVersion(counter, line())).toBe(false);
    expect(editsByVersion(workspace(), undefined)).toBe(false);
  });

  it('finds a line by its line item or sale line id', () => {
    expect(findLine(workspace(), 'li_1')?.name).toBe('Phở bò');
    expect(findLine(workspace(), 'posline_1')?.name).toBe('Phở bò');
    expect(findLine(workspace(), 'missing')).toBeUndefined();
  });

  it('lists the branch void reasons with "other" last, or the defaults', () => {
    expect(voidReasons(null)).toEqual([
      'khach_doi_y',
      'het_mon',
      'nhap_nham',
      'lam_hong',
      VOID_OTHER,
    ]);
    expect(voidReasons({ void_reasons: ['khac', 'het_mon'] } as PosBranch)).toEqual([
      'het_mon',
      VOID_OTHER,
    ]);
  });

  it('tells a line changed by someone else from a line the kitchen has', () => {
    expect(lineChanged(conflict('line_changed'))).toBe(true);
    expect(lineSent(conflict('line_sent'))).toBe(true);
    expect(lineChanged(conflict('line_sent'))).toBe(false);
    expect(lineSent(new Error('offline'))).toBe(false);
  });
});
