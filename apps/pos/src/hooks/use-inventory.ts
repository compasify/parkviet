import type {
  AdjustmentStatus,
  PosAdjustment,
  PosLot,
  PosSerialUnit,
  PosTraceStatus,
  RecallResult,
} from '@parkviet/pos-shared/traceability';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useRef, useState } from 'react';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import { definitiveRejection, financialStorageFailure } from '../lib/request-failure';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';

type Meta = { page: number; pages: number; count: number };
type Page<T> = { data: T[]; meta: Meta };

const inventoryKey = (generation: number) => ['pos', 'inventory', generation] as const;

// Lists the forms pick from are capped by the server; a code filter narrows them.
export const FORM_LIST_LIMIT = 100;

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Tracked variants of the branch with their enrolment and reconciliation.
export function useInventoryVariants(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...inventoryKey(snapshot.generation), 'variants', branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<{ data: PosTraceStatus[] }>('/pos/inventory/variants', {
        branch_id: branchId ?? undefined,
      }),
  });
}

export type LotFilters = {
  variantId?: string;
  q?: string;
  status?: string;
  page?: number;
  limit?: number;
};

export function useLots(branchId: string | null, filters: LotFilters, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...inventoryKey(snapshot.generation), 'lots', branchId, filters],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<Page<PosLot>>('/pos/lots', {
        branch_id: branchId ?? undefined,
        variant_id: filters.variantId || undefined,
        q: filters.q?.trim() || undefined,
        status: filters.status || undefined,
        page: String(filters.page ?? 1),
        limit: String(filters.limit ?? 50),
      }),
  });
}

export function useSerialUnits(
  branchId: string | null,
  filters: { q: string; status?: string; page?: number },
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...inventoryKey(snapshot.generation), 'serials', branchId, filters],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<Page<PosSerialUnit>>('/pos/serial_units', {
        branch_id: branchId ?? undefined,
        q: filters.q.trim() || undefined,
        status: filters.status || undefined,
        page: String(filters.page ?? 1),
        limit: '50',
      }),
  });
}

export const ADJUSTMENT_POLL_MS = 12_000;

// Pending counts wait for someone else to approve or apply them, so the list
// refreshes on its own while any is shown.
export function useAdjustments(
  branchId: string | null,
  status: AdjustmentStatus | '',
  page: number,
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...inventoryKey(snapshot.generation), 'adjustments', branchId, status, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: (query) =>
      query.state.data?.data.some((row) => row.status === 'pending_approval')
        ? ADJUSTMENT_POLL_MS
        : false,
    queryFn: () =>
      read<Page<PosAdjustment>>('/pos/inventory/adjustments', {
        branch_id: branchId ?? undefined,
        status: status || undefined,
        page: String(page),
        limit: '25',
      }),
  });
}

export type RecallQuery = { kind: 'lot_code' | 'serial'; value: string; page: number };

export type RecallPage = {
  data: RecallResult;
  meta: { page: number; limit: number; count: number; pages: number; truncated: boolean };
};

// Where a lot or serial went: stock that still holds it and the sales that
// took it, a page of sales at a time. Customers come masked from the server.
export function useRecall(query: RecallQuery | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...inventoryKey(snapshot.generation), 'recall', query],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(query?.value),
    queryFn: () =>
      read<RecallPage>('/pos/inventory/recall', {
        [query?.kind ?? 'lot_code']: query?.value,
        page: String(query?.page ?? 1),
        limit: '50',
      }),
  });
}

export type InventoryCommandInput = {
  branchId: string;
  // Names the command in the local recovery record, e.g. 'receive'.
  action: string;
  path: string;
  body: Record<string, unknown>;
};

type Handlers<T> = { onSuccess?: (data: T) => void; onError?: (error: unknown) => void };

// One stock command with a durable intent: the key is stored per branch,
// action and content before sending, so a lost response is checked against
// its receipt and resent under the same key, never as a second receipt or
// transfer. While the outcome is unknown the form stays locked on that
// content until "check again" settles it.
export function useInventoryCommand<T>(actor: { staffId: string | null; storeId: string | null }) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const [uncertain, setUncertain] = useState<InventoryCommandInput | null>(null);
  const handlers = useRef<Handlers<T>>({});
  const mutation = useMutation({
    mutationFn: async (input: InventoryCommandInput) => {
      try {
        return (
          await runFinancialCommand<T>(financialRequest, {
            staffId: actor.staffId,
            storeId: actor.storeId,
            scopeId: input.branchId,
            action: `inventory.${input.action}`,
            path: input.path,
            body: input.body,
          })
        ).data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        await Promise.all([
          queryClient.invalidateQueries({ queryKey: inventoryKey(snapshot.generation) }),
          queryClient.invalidateQueries({ queryKey: ['pos', 'traceability'] }),
        ]);
      }
    },
  });

  function run(input: InventoryCommandInput, next: Handlers<T> = {}) {
    handlers.current = next;
    mutation.mutate(input, {
      onSuccess: (data) => {
        setUncertain(null);
        handlers.current.onSuccess?.(data);
      },
      onError: (error) => {
        // A refusal rolled the command back; anything else may have committed.
        setUncertain(definitiveRejection(error) || financialStorageFailure(error) ? null : input);
        handlers.current.onError?.(error);
      },
    });
  }

  return {
    run,
    isPending: mutation.isPending,
    uncertain: uncertain !== null,
    recheck() {
      if (uncertain) run(uncertain, handlers.current);
    },
  };
}
