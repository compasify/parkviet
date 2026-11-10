import { describe, expect, it } from 'vitest';
import i18n from '../test-support/i18n';
import type { ReceiptSnapshot } from '../types/print-adapter';
import { snapshotData, type TemplateData } from './data';
import {
  interpolate,
  isTemplateVariable,
  MAX_VARIABLE_LENGTH,
  resolveText,
  TEMPLATE_VARIABLES,
  variableValues,
} from './variables';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

function data(document: Record<string, unknown>): TemplateData {
  return snapshotData(
    {
      id: 'posreceipt_1',
      source_type: 'sale',
      number: 'R100',
      branch_id: 'br_1',
      issued_at: '2026-11-07T03:00:00Z',
      issued_late: false,
      disclaimer: 'D',
      printed: false,
      copy_count: 0,
      document: { timezone: 'Asia/Ho_Chi_Minh', at: '2026-11-07T03:00:00Z', ...document },
    } as ReceiptSnapshot,
    t,
  );
}

const full = data({
  store: { name: 'Park Việt', contact_phone: '0901 234 567' },
  branch: { name: 'Quận 1', code: 'q1', return_window_days: 7 },
  register: 'Quầy 1',
  cashier: 'Lan',
  customer: { name: 'N••• A•', phone: '•••567' },
});

describe('template variables', () => {
  it('fills every whitelisted variable from the document data', () => {
    expect(Object.keys(variableValues(full)).sort()).toEqual([...TEMPLATE_VARIABLES].sort());
    expect(
      interpolate(
        '{store.name} · {branch.name} ({branch.code}) · {register.name} · {cashier} · {document.number} · {document.time} · {customer.name}',
        full,
      ),
    ).toBe('Park Việt · Quận 1 (q1) · Quầy 1 · Lan · R100 · 07/11/2026 10:00 · N••• A•');
    expect(interpolate('Đổi trả trong {branch.return_window_days} ngày', full)).toBe(
      'Đổi trả trong 7 ngày',
    );
  });

  it('leaves unknown names and stray braces as written', () => {
    expect(interpolate('{order.total} {store.secret} {store.name} {}', full)).toBe(
      '{order.total} {store.secret} Park Việt {}',
    );
    expect(isTemplateVariable('store.name')).toBe(true);
    expect(isTemplateVariable('store.tax_code')).toBe(false);
  });

  it('marks text blank when every variable it names is empty', () => {
    const bare = data({ store: { name: 'Park Việt' } });
    expect(resolveText('ĐT: {store.phone}', bare)).toEqual({ text: 'ĐT: ', blank: true });
    expect(resolveText('ĐT: {store.phone}', full).blank).toBe(false);
    expect(resolveText('{store.email} {store.phone}', full).blank).toBe(false);
    expect(resolveText('Cảm ơn quý khách!', bare).blank).toBe(false);
    expect(resolveText('   ', bare).blank).toBe(true);
  });

  it('inserts values as text, clipped to a safe length', () => {
    const long = data({ store: { name: 'x'.repeat(500) }, cashier: '<b>Lan</b>' });
    expect(interpolate('{store.name}', long)).toHaveLength(MAX_VARIABLE_LENGTH);
    expect(interpolate('{cashier}', long)).toBe('<b>Lan</b>');
  });
});
