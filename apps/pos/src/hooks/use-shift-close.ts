import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useState } from 'react';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import {
  FINANCIAL_RECOVERY_CHANGED,
  type FinancialRecoveryRecord,
  forgetFinancialRecord,
  scopedFinancialRecords,
} from '../lib/financial-recovery';
import { failureStatus } from '../lib/request-failure';
import type {
  CashMovementKind,
  CashMovementRequest,
  PosCashMovement,
  ShiftCloseState,
  ShiftClosure,
  ShiftCount,
} from '../lib/shifts';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

type Actor = { staffId: string | null; storeId: string | null };
export type Recoverable<T> = { data: T; recovered: boolean };

// Drawer, count, close, approval and reconciliation commands all go through
// runFinancialCommand with a stable intent: the key is kept while the
// outcome is unknown and its receipt is checked before any resend, so a lost
// response never posts twice, and an edited retry reuses the same key.
async function command<T>(
  actor: Actor,
  scopeId: string,
  action: string,
  path: string,
  body: Record<string, unknown>,
  intent: string,
): Promise<Recoverable<T>> {
  try {
    return await runFinancialCommand<T>(financialRequest, {
      staffId: actor.staffId,
      storeId: actor.storeId,
      scopeId,
      action,
      path,
      body,
      intent,
    });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export const SHIFT_COMMAND_PATHS = [
  '/pos/shifts/',
  '/pos/cash_movement_requests/',
  '/pos/cash_reconciliations',
];

function useRefreshShift() {
  const queryClient = useQueryClient();
  return () =>
    Promise.all([
      queryClient.invalidateQueries({ queryKey: ['pos', 'shift-close'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'cash-movements'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'cash-requests'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'pending-closes'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'cash-reconcile'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'context'] }),
    ]);
}

export function shiftCloseKey(generation: number, shiftId: string | null) {
  return ['pos', 'shift-close', generation, shiftId] as const;
}

export function useShiftCloseState(shiftId: string | null, poll = false) {
  const snapshot = useSession();
  return useQuery({
    queryKey: shiftCloseKey(snapshot.generation, shiftId),
    enabled: snapshot.status === 'authenticated' && Boolean(shiftId),
    refetchInterval: poll ? 5000 : false,
    queryFn: async () =>
      (await read<{ data: ShiftCloseState }>(`/pos/shifts/${shiftId}/closure`)).data,
  });
}

export function useCashMovements(shiftId: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'cash-movements', snapshot.generation, shiftId],
    enabled: snapshot.status === 'authenticated' && Boolean(shiftId),
    queryFn: () =>
      read<{ data: PosCashMovement[]; meta: { count: number } }>(
        `/pos/shifts/${shiftId}/cash_movements`,
        { limit: '50' },
      ),
  });
}

export function useCashMovementRequests(
  branchId: string | null,
  options: { shiftId?: string | null; pendingOnly?: boolean },
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'cash-requests', snapshot.generation, branchId, options],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 15000,
    queryFn: () =>
      read<{ data: CashMovementRequest[] }>('/pos/cash_movement_requests', {
        branch_id: branchId ?? undefined,
        shift_id: options.shiftId ?? undefined,
        status: options.pendingOnly ? 'requested' : undefined,
        limit: '50',
      }),
  });
}

// `intent` is fixed per dialog instance: retrying the same dialog (even after
// editing it) rechecks the first key instead of posting a second movement.
export function usePostCashMovement(actor: Actor) {
  const refresh = useRefreshShift();
  return useMutation({
    mutationFn: (input: {
      shiftId: string;
      intent: string;
      kind: CashMovementKind;
      amount: string;
      reason: string;
      evidence: string;
    }) =>
      command<PosCashMovement | CashMovementRequest>(
        actor,
        input.shiftId,
        'shift_cash_movement',
        `/pos/shifts/${input.shiftId}/cash_movements`,
        {
          kind: input.kind,
          amount: input.amount,
          reason: input.reason,
          evidence_reference: input.evidence || undefined,
        },
        `movement:${input.intent}`,
      ),
    onSettled: refresh,
  });
}

export function useDecideCashRequest(actor: Actor) {
  const refresh = useRefreshShift();
  return useMutation({
    mutationFn: (input: {
      request: CashMovementRequest;
      decision: 'confirm' | 'cancel';
      note?: string;
    }) =>
      command<CashMovementRequest>(
        actor,
        input.request.shift_id,
        'shift_cash_request',
        `/pos/cash_movement_requests/${input.request.id}/${input.decision}`,
        { note: input.note || undefined },
        `${input.decision}:${input.request.id}`,
      ),
    onSettled: refresh,
  });
}

// One intent per shift revision: a recount after a lost response rechecks
// the pending key; a recovered result may be an earlier count, which the
// caller compares by revision. The fresh result is written into the cache.
export function useCountShift(actor: Actor) {
  const refresh = useRefreshShift();
  const queryClient = useQueryClient();
  const snapshot = useSession();
  return useMutation({
    mutationFn: (input: { shiftId: string; revision: number; counted: string; reason?: string }) =>
      command<ShiftCount>(
        actor,
        input.shiftId,
        'shift_count',
        `/pos/shifts/${input.shiftId}/count`,
        { counted: input.counted, reason: input.reason || undefined },
        `count:${input.revision}`,
      ),
    onSuccess: (result, input) => {
      queryClient.setQueryData<ShiftCloseState>(
        shiftCloseKey(snapshot.generation, input.shiftId),
        (state) =>
          state
            ? {
                ...state,
                count: result.data,
                shift: { ...state.shift, revision: result.data.revision },
              }
            : state,
      );
    },
    onSettled: refresh,
  });
}

export function useCloseShift(actor: Actor) {
  const refresh = useRefreshShift();
  return useMutation({
    mutationFn: (input: { shiftId: string; revision: number; reason?: string }) =>
      command<ShiftClosure>(
        actor,
        input.shiftId,
        'shift_close',
        `/pos/shifts/${input.shiftId}/close`,
        { reason: input.reason || undefined },
        `close:${input.revision}`,
      ),
    onSettled: refresh,
  });
}

// Shift commands whose outcome this browser does not know yet (a lost
// response, a closed tab). "Kiểm tra lại" looks the key up and, only when the
// server never committed it, resends it under the same key.
export function usePendingShiftCommands(actor: Actor, scopeIds: string[]) {
  const refresh = useRefreshShift();
  const [records, setRecords] = useState<FinancialRecoveryRecord[]>([]);
  const [version, setVersion] = useState(0);
  const scopes = scopeIds.join('|');
  useEffect(() => {
    const changed = () => setVersion((value) => value + 1);
    window.addEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
    return () => window.removeEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
  }, []);
  useEffect(() => {
    void version;
    if (!actor.staffId || !actor.storeId) return;
    let active = true;
    const wanted = new Set(scopes.split('|').filter(Boolean));
    scopedFinancialRecords(actor.staffId, actor.storeId).then(
      (all) => {
        if (!active) return;
        setRecords(
          all.filter(
            (record) =>
              wanted.has(record.workspaceId) &&
              SHIFT_COMMAND_PATHS.some((path) => record.path.startsWith(path)),
          ),
        );
      },
      () => {
        if (active) setRecords([]);
      },
    );
    return () => {
      active = false;
    };
  }, [actor.staffId, actor.storeId, scopes, version]);

  const recheck = useCallback(async () => {
    for (const record of records) {
      try {
        await financialRequest('GET', '/pos/command_receipts', {
          params: { idempotency_key: record.idempotencyKey },
        });
        await forgetFinancialRecord(record.scope);
      } catch (error) {
        abandonIfNeeded(error);
        if (failureStatus(error) !== 404) throw error;
        try {
          await financialRequest('POST', record.path, {
            body: { ...record.body, idempotency_key: record.idempotencyKey },
            idempotencyKey: record.idempotencyKey,
          });
          await forgetFinancialRecord(record.scope);
        } catch (resent) {
          const status = failureStatus(resent);
          // Refused outright: nothing of it took effect.
          if (status !== undefined && status >= 400 && status < 500 && status !== 408) {
            await forgetFinancialRecord(record.scope);
          } else {
            throw resent;
          }
        }
      }
    }
    setVersion((value) => value + 1);
    await refresh();
  }, [records, refresh]);

  return { records, recheck };
}
