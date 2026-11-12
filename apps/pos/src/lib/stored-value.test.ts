import { describe, expect, it } from 'vitest';
import en from '../locales/en.json';
import vi from '../locales/vi.json';
import {
  normalizeStoredValueCard,
  normalizeStoredValueEntries,
  STORED_VALUE_REASONS,
  storedValueReasonKey,
} from './stored-value';

describe('prepaid cards', () => {
  it('reads a card as the server sends it', () => {
    expect(
      normalizeStoredValueCard({
        id: 'possv_1',
        kind: 'minutes',
        card_hint: '4242',
        holder_name: 'Chị Hoa',
        status: 'active',
        currency: 'VND',
        balance: '250000.0',
        minutes_balance: 300,
        revision: 2,
      }),
    ).toEqual({
      id: 'possv_1',
      kind: 'minutes',
      cardHint: '4242',
      holderName: 'Chị Hoa',
      status: 'active',
      currency: 'VND',
      balance: '250000.0',
      minutesBalance: 300,
      revision: 2,
    });
    expect(normalizeStoredValueCard({ id: 'possv_2', kind: 'money' })).toMatchObject({
      kind: 'money',
      minutesBalance: null,
      balance: '0',
    });
    expect(normalizeStoredValueCard(null)).toBeNull();
    expect(normalizeStoredValueCard({ kind: 'money' })).toBeNull();
  });

  it('reads the history and skips broken rows', () => {
    expect(
      normalizeStoredValueEntries([
        {
          id: 'e1',
          kind: 'spend',
          amount: '-75000.0',
          minutes: -90,
          order_number: 'R100',
          actor: { id: 's', name: 'Lan' },
          note: null,
          created_at: '2026-11-12T12:00:00Z',
        },
        { kind: 'top_up' },
        'nope',
      ]),
    ).toEqual([
      {
        id: 'e1',
        kind: 'spend',
        amount: '-75000.0',
        minutes: -90,
        orderNumber: 'R100',
        actor: 'Lan',
        note: null,
        createdAt: '2026-11-12T12:00:00Z',
      },
    ]);
    expect(normalizeStoredValueEntries(undefined)).toEqual([]);
  });

  it('words every card refusal in both languages', () => {
    expect(storedValueReasonKey('something_else')).toBeNull();
    expect(storedValueReasonKey(null)).toBeNull();
    for (const reason of STORED_VALUE_REASONS)
      for (const bundle of [vi, en])
        expect((bundle as Record<string, unknown>)[`storedValueFailure_${reason}`]).toEqual(
          expect.any(String),
        );
  });
});
