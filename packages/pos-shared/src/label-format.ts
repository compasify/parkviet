import { parseMoneyInput } from './money';

// EAN-13 scale label: prefix | item code | value | check digit. The first three
// parts always fill the 12 digits before the check digit.
export const LABEL_BODY_LENGTH = 12;
export const LABEL_WEIGHT_UNITS = ['g', 'kg', 'ml', 'l'] as const;
export const LABEL_NAME_MAX = 80;

export type LabelFormatKind = 'weight' | 'price';

export type LabelFormat = {
  id: string;
  branch_id?: string;
  name: string;
  prefix: string;
  kind: LabelFormatKind;
  item_code_length: number;
  value_length: number;
  value_decimals: number;
  value_unit_code: string | null;
  price_tolerance: string;
  version: number;
  status: 'active' | 'disabled' | string;
};

// Form input as typed; numbers stay strings until validated.
export type LabelFormatDraft = {
  name: string;
  prefix: string;
  kind: LabelFormatKind;
  item_code_length: string;
  value_length: string;
  value_decimals: string;
  value_unit_code: string;
  price_tolerance: string;
};

export type LabelFormatProblem =
  | 'name'
  | 'prefix'
  | 'itemCodeLength'
  | 'valueLength'
  | 'layout'
  | 'decimals'
  | 'unit'
  | 'tolerance';

export function labelFormatDraft(format?: LabelFormat): LabelFormatDraft {
  return {
    name: format?.name ?? '',
    prefix: format?.prefix ?? '',
    kind: format?.kind ?? 'weight',
    item_code_length: format ? String(format.item_code_length) : '5',
    value_length: format ? String(format.value_length) : '5',
    value_decimals: format ? String(format.value_decimals) : '0',
    value_unit_code: format?.value_unit_code ?? (format ? '' : 'g'),
    price_tolerance: format?.price_tolerance ?? '0',
  };
}

function positiveInteger(input: string): number | null {
  const value = input.trim();
  if (!/^\d{1,2}$/.test(value)) return null;
  const number = Number(value);
  return number >= 1 ? number : null;
}

// Digits used by prefix, item code and value, or null while any part is unreadable.
export function labelDigitsUsed(draft: LabelFormatDraft): number | null {
  const prefix = draft.prefix.trim();
  const item = positiveInteger(draft.item_code_length);
  const value = positiveInteger(draft.value_length);
  if (!/^\d{1,4}$/.test(prefix) || item === null || value === null) return null;
  return prefix.length + item + value;
}

export function labelFormatProblems(draft: LabelFormatDraft): LabelFormatProblem[] {
  const problems: LabelFormatProblem[] = [];
  const name = draft.name.trim();
  if (!name || name.length > LABEL_NAME_MAX) problems.push('name');
  if (!/^\d{1,4}$/.test(draft.prefix.trim())) problems.push('prefix');
  if (positiveInteger(draft.item_code_length) === null) problems.push('itemCodeLength');
  if (positiveInteger(draft.value_length) === null) problems.push('valueLength');
  const used = labelDigitsUsed(draft);
  if (used !== null && used !== LABEL_BODY_LENGTH) problems.push('layout');
  if (!/^[0-4]$/.test(draft.value_decimals.trim())) problems.push('decimals');
  if (
    draft.kind === 'weight' &&
    !(LABEL_WEIGHT_UNITS as readonly string[]).includes(draft.value_unit_code)
  )
    problems.push('unit');
  if (draft.kind === 'price' && parseMoneyInput(draft.price_tolerance) === null)
    problems.push('tolerance');
  return problems;
}

// Request body for create/update, or null while the draft has problems.
export function labelFormatBody(draft: LabelFormatDraft): Record<string, unknown> | null {
  if (labelFormatProblems(draft).length) return null;
  const weight = draft.kind === 'weight';
  return {
    name: draft.name.trim(),
    prefix: draft.prefix.trim(),
    kind: draft.kind,
    item_code_length: Number(draft.item_code_length.trim()),
    value_length: Number(draft.value_length.trim()),
    value_decimals: Number(draft.value_decimals.trim()),
    // A price label carries no unit. A weight label ignores the tolerance, so an
    // unreadable one there is sent as zero instead of blocking the save.
    value_unit_code: weight ? draft.value_unit_code : null,
    price_tolerance: parseMoneyInput(draft.price_tolerance) ?? '0',
  };
}
