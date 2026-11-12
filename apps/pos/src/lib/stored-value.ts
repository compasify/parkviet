// Prepaid money and minutes cards as the counter reads them.

import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';

export type StoredValueKind = 'money' | 'minutes';

export type StoredValueCard = {
  id: string;
  kind: StoredValueKind;
  cardHint: string;
  holderName: string | null;
  status: string;
  currency: string;
  balance: string;
  minutesBalance: number | null;
  revision: number;
};

export type StoredValueEntry = {
  id: string;
  kind: string;
  amount: string;
  minutes: number | null;
  orderNumber: string | null;
  actor: string | null;
  note: string | null;
  createdAt: string;
};

export type StoredValuePaymentInput = {
  kind: 'cash' | 'bank_manual';
  amount: string;
  minutes?: number;
  handedAmount?: string;
  reference?: string;
  receivingAccount?: string;
};

export type StoredValueSaleInput = StoredValuePaymentInput & {
  cardKind: StoredValueKind;
  cardToken: string;
  holderName?: string;
};

export type StoredValueResult = { card: StoredValueCard | null; document: PrintDocument | null };

function text(value: unknown) {
  return typeof value === 'string' ? value : null;
}

export function normalizeStoredValueCard(value: unknown): StoredValueCard | null {
  if (!value || typeof value !== 'object') return null;
  const row = value as Record<string, unknown>;
  if (typeof row.id !== 'string') return null;
  return {
    id: row.id,
    kind: row.kind === 'minutes' ? 'minutes' : 'money',
    cardHint: text(row.card_hint) ?? '',
    holderName: text(row.holder_name),
    status: text(row.status) ?? 'active',
    currency: text(row.currency) ?? 'VND',
    balance: text(row.balance) ?? '0',
    minutesBalance: typeof row.minutes_balance === 'number' ? row.minutes_balance : null,
    revision: typeof row.revision === 'number' ? row.revision : 0,
  };
}

export function normalizeStoredValueEntries(value: unknown): StoredValueEntry[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((item) => {
    if (!item || typeof item !== 'object') return [];
    const row = item as Record<string, unknown>;
    if (typeof row.id !== 'string') return [];
    const actor = row.actor as { name?: unknown } | null | undefined;
    return [
      {
        id: row.id,
        kind: text(row.kind) ?? '',
        amount: text(row.amount) ?? '0',
        minutes: typeof row.minutes === 'number' ? row.minutes : null,
        orderNumber: text(row.order_number),
        actor: text(actor?.name),
        note: text(row.note),
        createdAt: text(row.created_at) ?? '',
      },
    ];
  });
}

// The refusals of a card command the counter words itself.
export const STORED_VALUE_REASONS = [
  'stored_value_card_taken',
  'stored_value_card_invalid',
  'stored_value_card_unknown',
  'stored_value_closed',
  'stored_value_kind_invalid',
  'stored_value_minutes_invalid',
  'stored_value_amount_invalid',
  'stored_value_nothing_due',
  'stored_value_insufficient',
] as const;

export function storedValueReasonKey(reason: string | null) {
  return reason && (STORED_VALUE_REASONS as readonly string[]).includes(reason)
    ? `storedValueFailure_${reason}`
    : null;
}
