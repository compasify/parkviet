import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useRef } from 'react';
import { session } from '../lib/app-session';
import type { PosCustomerProfile } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { createSubmissionKey, customerSubmissionContent } from '../lib/submission-key';
import { useSession } from './use-session';

type CustomerPage = {
  data: PosCustomerProfile[];
  meta: { page: number; pages: number; count: number; duplicate_candidates: number };
};

function abandonIfNeeded(error: unknown) {
  if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
    session.abandon();
}

export function useCustomerSearch(storeId: string | null, branchId: string | null, query: string) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'customers', snapshot.generation, storeId, branchId, query],
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId && query.trim()),
    queryFn: async (): Promise<CustomerPage> => {
      try {
        return await session.request<CustomerPage>('GET', '/pos/customers', {
          params: { branch_id: branchId ?? undefined, q: query.trim(), page: '1' },
        });
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

export function useCreateCustomer(storeId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const keys = useRef(createSubmissionKey());
  return useMutation({
    mutationFn: async (input: {
      branchId: string;
      name: string;
      phone?: string;
      email?: string;
    }): Promise<PosCustomerProfile> => {
      const content = customerSubmissionContent(input);
      // A retry of the same form content after a lost response must replay the
      // first creation, not create a second profile.
      const key = keys.current.keyFor(content);
      try {
        const result = await session.request<{ data: PosCustomerProfile }>(
          'POST',
          '/pos/customers',
          {
            body: {
              branch_id: input.branchId,
              name: input.name,
              phone: input.phone || undefined,
              email: input.email || undefined,
              idempotency_key: key,
            },
            idempotencyKey: key,
          },
        );
        keys.current.settle(content);
        return result.data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({
        queryKey: ['pos', 'customers', snapshot.generation, storeId],
      });
    },
  });
}
