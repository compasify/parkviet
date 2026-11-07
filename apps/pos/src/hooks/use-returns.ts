import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useRef, useState } from 'react';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import {
  FINANCIAL_RECOVERY_CHANGED,
  type FinancialRecoveryRecord,
  forgetFinancialRecord,
  scopedFinancialRecords,
} from '../lib/financial-recovery';
import { conflictReason, failureStatus } from '../lib/request-failure';
import {
  type PosExchange,
  type PosOrderDetail,
  type PosOrderRow,
  type PosRefundRequest,
  type PosReturn,
  type PosReturnRow,
  prepareIntent,
  type ReturnCondition,
  type ReturnPreview,
  returnWaits,
} from '../lib/returns';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';
import { workspaceEditorId } from './use-workspaces';

type Page<T> = { data: T[]; meta: { page: number; pages: number; count: number } };

export type OrderFilters = {
  number: string;
  from: string;
  to: string;
  registerId: string;
  cashierId: string;
  status: 'all' | 'debt' | 'returned' | 'refund_pending';
  page: number;
};

export type ReturnLineInput = {
  sale_line_id: string;
  quantity: number;
  condition: ReturnCondition;
};

// Paths of commands sent through runFinancialCommand from this module; their
// local recovery records are rechecked by `usePendingReturnCommands`.
export const RETURNS_PATH = '/pos/returns';
export const EXCHANGES_PATH = '/pos/exchanges';
export const REFUNDS_PATH = '/pos/refund_requests';

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Non-money writes carry one idempotency key per user action.
async function write<T>(path: string, body: Record<string, unknown>): Promise<T> {
  const key = crypto.randomUUID();
  try {
    return (
      await session.request<{ data: T }>('POST', path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      })
    ).data;
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

function useInvalidate() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return () =>
    Promise.all(
      ['orders', 'order', 'returns', 'refund-requests', 'exchange'].map((kind) =>
        queryClient.invalidateQueries({ queryKey: ['pos', kind, snapshot.generation] }),
      ),
    );
}

export function useOrders(branchId: string | null, filters: OrderFilters, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'orders', snapshot.generation, branchId, filters],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<Page<PosOrderRow>>('/pos/orders', {
        branch_id: branchId ?? undefined,
        number: filters.number.trim() || undefined,
        from: filters.from || undefined,
        to: filters.to || undefined,
        register_id: filters.registerId || undefined,
        cashier_id: filters.cashierId || undefined,
        status: filters.status,
        page: String(filters.page),
        limit: '25',
      }),
  });
}

// One order's timeline. A sale of another branch is read through the exact
// number lookup, which the server allows to return staff of `branchId`.
export function useOrder(
  ref: { orderId?: string; number?: string } | null,
  branchId: string | null,
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [
      'pos',
      'order',
      snapshot.generation,
      branchId,
      ref?.orderId ?? null,
      ref?.number ?? null,
    ],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(ref?.orderId || ref?.number),
    queryFn: async () =>
      (
        await read<{ data: PosOrderDetail }>(
          ref?.orderId ? `/pos/orders/${ref.orderId}` : '/pos/orders/lookup',
          { branch_id: branchId ?? undefined, number: ref?.orderId ? undefined : ref?.number },
        )
      ).data,
  });
}

// A resolver finishes a short handover once the shelf was corrected.
export function useReconcileHandover() {
  const invalidate = useInvalidate();
  return useMutation({
    mutationFn: async (orderId: string) => {
      try {
        return await write<{ stock_discrepancies: unknown[] }>(
          `/pos/orders/${orderId}/reconcile_handover`,
          {},
        );
      } finally {
        await invalidate();
      }
    },
  });
}

export function useReturnPreview() {
  return useMutation({
    mutationFn: async (input: { branchId: string; orderId: string; lines: ReturnLineInput[] }) => {
      try {
        return (
          await session.request<{ data: ReturnPreview }>('POST', '/pos/returns/preview', {
            body: { branch_id: input.branchId, order_id: input.orderId, lines: input.lines },
          })
        ).data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

export function useReturn(returnId: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'returns', snapshot.generation, returnId],
    enabled: snapshot.status === 'authenticated' && Boolean(returnId),
    refetchInterval: (query) => (query.state.data && returnWaits(query.state.data) ? 5000 : false),
    queryFn: async () => (await read<{ data: PosReturn }>(`/pos/returns/${returnId}`)).data,
  });
}

export function useExchange(exchangeId: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'exchange', snapshot.generation, exchangeId],
    enabled: snapshot.status === 'authenticated' && Boolean(exchangeId),
    queryFn: async () => (await read<{ data: PosExchange }>(`/pos/exchanges/${exchangeId}`)).data,
  });
}

// Return commands. Prepare and exchange create records, so they run through
// runFinancialCommand with a stable intent: a retry after a lost response
// rechecks the first key instead of opening a second return or sale.
export function useReturnCommands(staffId: string | null, storeId: string | null) {
  const invalidate = useInvalidate();
  const after = async <T>(promise: Promise<T>) => {
    try {
      return await promise;
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      await invalidate();
    }
  };
  return {
    prepare: useMutation({
      mutationFn: (input: {
        branchId: string;
        orderId: string;
        lines: ReturnLineInput[];
        reason: string;
      }) =>
        after(
          runFinancialCommand<PosReturn>(financialRequest, {
            staffId,
            storeId,
            scopeId: input.orderId,
            action: 'return.prepare',
            path: RETURNS_PATH,
            intent: prepareIntent(input.orderId, input.lines),
            body: {
              branch_id: input.branchId,
              order_id: input.orderId,
              lines: input.lines,
              reason: input.reason,
            },
          }),
        ),
    }),
    // A receive whose response was lost and is retried meets
    // `already_received`: the goods are in, so the return is simply reloaded.
    receive: useMutation({
      mutationFn: (operation: PosReturn) =>
        after(
          write<PosReturn>(`/pos/returns/${operation.id}/receive`, {
            approval_id:
              operation.approval?.status === 'active' ? operation.approval.id : undefined,
          }).catch(async (error: unknown) => {
            if (conflictReason(error) !== 'already_received') throw error;
            return (await read<{ data: PosReturn }>(`/pos/returns/${operation.id}`)).data;
          }),
        ),
    }),
    cancel: useMutation({
      mutationFn: (input: { returnId: string; reason: string }) =>
        after(write<PosReturn>(`/pos/returns/${input.returnId}/cancel`, { reason: input.reason })),
    }),
    approve: useMutation({
      mutationFn: (returnId: string) =>
        after(write<PosReturn>(`/pos/returns/${returnId}/approve`, {})),
    }),
    exchange: useMutation({
      mutationFn: (input: { returnId: string; registerId: string | null; branchId: string }) =>
        after(
          runFinancialCommand<PosExchange>(financialRequest, {
            staffId,
            storeId,
            scopeId: input.returnId,
            action: 'exchange.execute',
            path: EXCHANGES_PATH,
            intent: 'exchange',
            body: {
              return_id: input.returnId,
              register_id: input.registerId ?? undefined,
              branch_id: input.registerId ? undefined : input.branchId,
              editor_id: workspaceEditorId,
            },
          }),
        ),
    }),
  };
}

export function useBranchReturns(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'returns', snapshot.generation, 'branch', branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 5000,
    queryFn: () =>
      read<Page<PosReturnRow>>('/pos/returns', {
        branch_id: branchId ?? undefined,
        status: 'pending_approval',
        limit: '100',
      }),
  });
}

export function useRefundRequests(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'refund-requests', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 5000,
    queryFn: () =>
      read<Page<PosRefundRequest>>('/pos/refund_requests', {
        branch_id: branchId ?? undefined,
        status: 'reserved,unknown',
        limit: '100',
      }),
  });
}

// Money commands: every refund request, confirmation and resolution runs
// through runFinancialCommand with a named intent per refund, so a retry after
// a lost response replays the first key instead of paying twice.
export function useRefundCommands(staffId: string | null, storeId: string | null) {
  const invalidate = useInvalidate();
  const money = async <T>(command: {
    scopeId: string;
    action: string;
    path: string;
    intent: string;
    body: Record<string, unknown>;
  }) => {
    try {
      return await runFinancialCommand<T>(financialRequest, { staffId, storeId, ...command });
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      await invalidate();
    }
  };
  return {
    request: useMutation({
      mutationFn: (input: {
        returnId: string;
        allocationId: string;
        amount: string;
        method: 'cash' | 'bank_manual';
        beneficiaryReference?: string;
      }) =>
        money<PosRefundRequest>({
          scopeId: input.returnId,
          action: 'refund.request',
          path: REFUNDS_PATH,
          intent: `refund:${input.allocationId}`,
          body: {
            return_id: input.returnId,
            allocation_id: input.allocationId,
            amount: input.amount,
            method: input.method,
            beneficiary_reference: input.beneficiaryReference || undefined,
          },
        }),
    }),
    confirm: useMutation({
      mutationFn: (input: { refund: PosRefundRequest; reference?: string }) =>
        money<PosRefundRequest>({
          scopeId: input.refund.id,
          action: 'refund.confirm',
          path: `${REFUNDS_PATH}/${input.refund.id}/confirmation`,
          intent: 'payout',
          body: {
            evidence_kind: input.refund.method === 'cash' ? 'cash_count' : 'bank_manual',
            reference: input.reference || undefined,
            approval_id:
              input.refund.approval?.status === 'active' ? input.refund.approval.id : undefined,
          },
        }),
    }),
    resolve: useMutation({
      mutationFn: (input: {
        refund: PosRefundRequest;
        outcome: 'unknown' | 'failed_no_effect' | 'cancel';
        reference?: string;
        reason?: string;
      }) =>
        money<PosRefundRequest>({
          scopeId: input.refund.id,
          action: 'refund.resolve',
          path: `${REFUNDS_PATH}/${input.refund.id}/resolution`,
          intent: input.outcome,
          body: {
            outcome: input.outcome,
            reference: input.reference || undefined,
            reason: input.reason || undefined,
          },
        }),
    }),
    approve: useMutation({
      mutationFn: async (refundId: string) => {
        try {
          return await write<PosRefundRequest>(`${REFUNDS_PATH}/${refundId}/approve`, {});
        } finally {
          await invalidate();
        }
      },
    }),
  };
}

export type PendingRecheck = { committed: boolean; data?: unknown };

// A recovery record also exists while its command is still in flight. It only
// counts as unconfirmed once it is older than this, or if it was already
// there when the screen opened (a reload or a lost response earlier).
export const PENDING_GRACE_MS = 3000;

// Return, exchange and refund commands this browser sent without learning
// the outcome, keyed by the record they belong to (order, return or refund).
// `recheck` asks the server for the stored key's receipt; only when the
// server never committed it is the very same body sent again under that key.
export function usePendingReturnCommands(staffId: string | null, storeId: string | null) {
  const invalidate = useInvalidate();
  const [records, setRecords] = useState<FinancialRecoveryRecord[]>([]);
  const [unavailable, setUnavailable] = useState(false);
  const [version, setVersion] = useState(0);
  const [atMount, setAtMount] = useState<FinancialRecoveryRecord[] | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  useEffect(() => {
    const changed = () => setVersion((value) => value + 1);
    window.addEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
    return () => {
      window.removeEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
      if (timer.current) clearTimeout(timer.current);
    };
  }, []);
  useEffect(() => {
    void version;
    if (!staffId || !storeId) return;
    let active = true;
    scopedFinancialRecords(staffId, storeId).then(
      (all) => {
        if (!active) return;
        const ours = all.filter((record) =>
          [RETURNS_PATH, EXCHANGES_PATH, REFUNDS_PATH].some((path) => record.path.startsWith(path)),
        );
        setRecords(ours);
        setAtMount((current) => current ?? ours);
        setUnavailable(false);
        // Re-render once young records pass the grace period.
        if (ours.some((record) => Date.now() - record.savedAt < PENDING_GRACE_MS)) {
          if (timer.current) clearTimeout(timer.current);
          timer.current = setTimeout(() => setVersion((value) => value + 1), PENDING_GRACE_MS);
        }
      },
      () => {
        if (active) setUnavailable(true);
      },
    );
    return () => {
      active = false;
    };
  }, [staffId, storeId, version]);

  const recheck = useCallback(
    async (record: FinancialRecoveryRecord): Promise<PendingRecheck> => {
      try {
        try {
          const receipt = await financialRequest<{ data: unknown }>(
            'GET',
            '/pos/command_receipts',
            {
              params: { idempotency_key: record.idempotencyKey },
            },
          );
          await forgetFinancialRecord(record.scope);
          return { committed: true, data: receipt.data };
        } catch (error) {
          if (failureStatus(error) !== 404) throw error;
        }
        const result = await financialRequest<{ data: unknown }>('POST', record.path, {
          body: { ...record.body, idempotency_key: record.idempotencyKey },
          idempotencyKey: record.idempotencyKey,
        });
        await forgetFinancialRecord(record.scope);
        return { committed: false, data: result.data };
      } catch (error) {
        abandonIfNeeded(error);
        const status = failureStatus(error);
        // The server refused the resent command: nothing of it took effect.
        if (status !== undefined && status >= 400 && status < 500 && status !== 408) {
          await forgetFinancialRecord(record.scope);
        }
        throw error;
      } finally {
        setVersion((value) => value + 1);
        await invalidate();
      }
    },
    [invalidate],
  );

  const startScopes = new Set((atMount ?? []).map((record) => record.scope));
  const unconfirmed = records.filter(
    (record) => startScopes.has(record.scope) || Date.now() - record.savedAt >= PENDING_GRACE_MS,
  );
  return {
    records: unconfirmed,
    unavailable,
    pendingFor: (id: string) => unconfirmed.filter((record) => record.workspaceId === id),
    // Records left from before this screen opened, checked once on arrival.
    startedWith: (id: string) =>
      (atMount ?? []).filter(
        (record) => record.workspaceId === id && records.some((row) => row.scope === record.scope),
      ),
    recheck,
  };
}
