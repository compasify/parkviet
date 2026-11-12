import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import {
  normalizeStoredValueCard,
  normalizeStoredValueEntries,
  type StoredValueCard,
  type StoredValuePaymentInput,
  type StoredValueResult,
  type StoredValueSaleInput,
} from '../lib/stored-value';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';

function paymentBody(input: StoredValuePaymentInput) {
  return {
    kind: input.kind,
    amount: input.amount,
    ...(input.minutes ? { minutes: input.minutes } : {}),
    ...(input.kind === 'cash' && input.handedAmount ? { handed_amount: input.handedAmount } : {}),
    ...(input.kind === 'bank_manual'
      ? { reference: input.reference, receiving_account: input.receivingAccount }
      : {}),
  };
}

const cardsKey = (generation: number) => ['pos', 'stored-value', generation] as const;

// Finds a card by what its QR code or tag reads. The reading goes in the
// request body only and is never kept on this device.
export async function lookupStoredValueCard(branchId: string, cardToken: string) {
  try {
    const result = await session.request<{ data: unknown }>(
      'POST',
      '/pos/stored_value_accounts/lookup',
      { body: { branch_id: branchId, card_token: cardToken } },
    );
    return normalizeStoredValueCard(result.data);
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export function useStoredValueCard(branchId: string | null, id: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...cardsKey(snapshot.generation), 'one', branchId, id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(branchId && id),
    queryFn: async () => {
      const result = await session.request<{ data: unknown }>(
        'GET',
        `/pos/stored_value_accounts/${id}`,
        { params: { branch_id: branchId ?? '' } },
      );
      return normalizeStoredValueCard(result.data);
    },
  });
}

// The card's history, newest first.
export function useStoredValueEntries(branchId: string | null, id: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...cardsKey(snapshot.generation), 'entries', branchId, id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(branchId && id),
    queryFn: async () => {
      const result = await session.request<{ data: unknown }>(
        'GET',
        `/pos/stored_value_accounts/${id}/entries`,
        { params: { branch_id: branchId ?? '' } },
      );
      return normalizeStoredValueEntries(result.data);
    },
  });
}

// Selling a card and topping one up. A top-up is a money command on the
// card: a lost answer is checked against its receipt before anything is
// resent. A sale carries the card's reading, which is never kept on this
// device, so it is sent once; resending a sale that went through is refused
// as a card already sold, and the card is then found by reading it again.
export function useStoredValueCommands(
  branchId: string | null,
  staffId: string | null,
  storeId: string | null,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = () => queryClient.invalidateQueries({ queryKey: cardsKey(snapshot.generation) });
  function result(data: { card?: unknown; document?: PrintDocument } | undefined) {
    return { card: normalizeStoredValueCard(data?.card), document: data?.document ?? null };
  }
  return {
    async sell(input: StoredValueSaleInput): Promise<StoredValueResult> {
      try {
        const response = await session.request<{
          data: { card?: unknown; document?: PrintDocument };
        }>('POST', '/pos/stored_value_accounts', {
          idempotencyKey: crypto.randomUUID(),
          body: {
            branch_id: branchId,
            card_kind: input.cardKind,
            card_token: input.cardToken,
            ...(input.holderName ? { holder_name: input.holderName } : {}),
            ...paymentBody(input),
          },
        });
        return result(response.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        void refresh();
      }
    },
    async topUp(card: StoredValueCard, input: StoredValuePaymentInput): Promise<StoredValueResult> {
      try {
        const response = await runFinancialCommand<{ card?: unknown; document?: PrintDocument }>(
          financialRequest,
          {
            staffId,
            storeId,
            scopeId: card.id,
            action: 'stored_value.top_up',
            path: `/pos/stored_value_accounts/${card.id}/top_ups`,
            body: { branch_id: branchId, ...paymentBody(input) },
          },
        );
        return result(response.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        void refresh();
      }
    },
  };
}
