import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { commandDigest } from '../lib/command-queue';
import {
  financialScope,
  forgetFinancialRecord,
  saveFinancialRecord,
  scopedFinancialRecords,
} from '../lib/financial-recovery';
import type {
  PosLiabilityPayout,
  PosPaymentMethod,
  PosReceivedFunds,
  PosWorkspace,
} from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export type TenderCommandInput = {
  expectedRevision?: number;
  paymentMethodId?: string;
  amount?: string;
  attemptId?: string;
  handedAmount?: string;
  evidenceKind?: 'cash_count' | 'bank_manual';
  reference?: string;
  receivingAccount?: string;
  terminalRef?: string;
  fundsId?: string;
  allocationId?: string;
};

type Page<T> = { data: T[]; meta: { page: number; pages: number; count: number } };

function abandonIfNeeded(error: unknown) {
  if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized') {
    session.abandon();
  }
}

export function usePaymentMethods(workspace: PosWorkspace | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [
      'pos',
      'payment-methods',
      snapshot.generation,
      workspace?.id ?? null,
      workspace?.revision ?? null,
    ],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(workspace),
    queryFn: async (): Promise<PosPaymentMethod[]> => {
      try {
        const result = await session.request<{ data: PosPaymentMethod[] }>(
          'GET',
          `/pos/workspaces/${workspace?.id}/payment_methods`,
        );
        return result.data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

export function useReceivedFunds(
  storeId: string | null,
  branchId: string | null,
  workspaceId: string | null,
  enabled: boolean,
  page = 1,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'received-funds', snapshot.generation, storeId, branchId, workspaceId, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: async (): Promise<Page<PosReceivedFunds>> => {
      try {
        return await session.request<Page<PosReceivedFunds>>('GET', '/pos/received_funds', {
          params: {
            branch_id: branchId ?? undefined,
            workspace_id: workspaceId ?? undefined,
            limit: '25',
            page: String(page),
          },
        });
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

export function useReceivedFundDetail(fundsId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'received-funds', snapshot.generation, 'detail', fundsId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(fundsId),
    queryFn: async (): Promise<PosReceivedFunds> => {
      try {
        const result = await session.request<{ data: PosReceivedFunds }>(
          'GET',
          `/pos/received_funds/${fundsId}`,
        );
        return result.data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

export function useTenders(
  staffId: string | null,
  storeId: string | null,
  workspace: PosWorkspace | null,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();

  async function refresh() {
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: ['pos', 'workspaces', snapshot.generation, storeId],
      }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'received-funds', snapshot.generation] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'payment-methods', snapshot.generation] }),
    ]);
  }

  async function runFinancial(
    action: string,
    path: string,
    body: Record<string, unknown>,
  ): Promise<PosWorkspace> {
    if (!workspace) throw new Error('workspace-required');
    const digest = commandDigest(body);
    const scope = financialScope(staffId, storeId, workspace.id, action, digest);
    const existing =
      staffId && storeId
        ? (await scopedFinancialRecords(staffId, storeId)).find((record) => record.scope === scope)
        : undefined;
    const key = existing?.idempotencyKey ?? crypto.randomUUID();
    try {
      await saveFinancialRecord({
        scope,
        idempotencyKey: key,
        workspaceId: workspace.id,
        path,
        body,
        savedAt: Date.now(),
      });
    } catch {
      throw new Error('financial-storage-unavailable');
    }
    try {
      const result = await session.request<{ data: PosWorkspace }>('POST', path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      });
      await forgetFinancialRecord(scope).catch(() => undefined);
      await refresh();
      return result.data;
    } catch (error) {
      if (posFailureKey(error) === 'conflict') {
        try {
          const receipt = await session.request<{ data: PosWorkspace }>(
            'GET',
            '/pos/command_receipts',
            { params: { idempotency_key: key } },
          );
          await forgetFinancialRecord(scope).catch(() => undefined);
          await refresh();
          return receipt.data;
        } catch {
          // Keep the record: server state is still unknown, do not mint a new key.
        }
      }
      if (posFailureKey(error) !== 'offline' && posFailureKey(error) !== 'conflict') {
        await forgetFinancialRecord(scope).catch(() => undefined);
      }
      abandonIfNeeded(error);
      throw error;
    }
  }

  function workspaceBody(input: TenderCommandInput) {
    if (!workspace) throw new Error('workspace-required');
    return {
      expected_revision: input.expectedRevision ?? workspace.revision,
      lease_generation: workspace.lease_generation,
      editor_id: undefined,
      payment_method_id: input.paymentMethodId,
      amount: input.amount,
      handed_amount: input.handedAmount,
      evidence_kind: input.evidenceKind,
      reference: input.reference,
      receiving_account: input.receivingAccount,
      terminal_ref: input.terminalRef,
      funds_id: input.fundsId,
      allocation_id: input.allocationId,
    };
  }

  return {
    refresh,
    async prepare(editorId: string, input: TenderCommandInput) {
      if (!workspace) throw new Error('workspace-required');
      return runFinancial('tender.prepare', `/pos/workspaces/${workspace.id}/tender_attempts`, {
        ...workspaceBody(input),
        editor_id: editorId,
      });
    },
    async confirm(editorId: string, input: TenderCommandInput) {
      if (!workspace || !input.attemptId) throw new Error('attempt-required');
      return runFinancial(
        'tender.confirm',
        `/pos/workspaces/${workspace.id}/tender_attempts/${input.attemptId}/confirm`,
        { ...workspaceBody(input), editor_id: editorId },
      );
    },
    async cancel(editorId: string, input: TenderCommandInput) {
      if (!workspace || !input.attemptId) throw new Error('attempt-required');
      return runFinancial(
        'tender.cancel',
        `/pos/workspaces/${workspace.id}/tender_attempts/${input.attemptId}/cancel`,
        { ...workspaceBody(input), editor_id: editorId },
      );
    },
    async allocate(editorId: string, input: TenderCommandInput) {
      if (!workspace) throw new Error('workspace-required');
      return runFinancial('funds.allocate', `/pos/workspaces/${workspace.id}/funds/allocate`, {
        ...workspaceBody(input),
        editor_id: editorId,
      });
    },
    async reverse(editorId: string, input: TenderCommandInput) {
      if (!workspace) throw new Error('workspace-required');
      return runFinancial('funds.reverse', `/pos/workspaces/${workspace.id}/funds/reverse`, {
        ...workspaceBody(input),
        editor_id: editorId,
      });
    },
    async complete(editorId: string) {
      if (!workspace) throw new Error('workspace-required');
      return runFinancial('workspace.complete', `/pos/workspaces/${workspace.id}/complete`, {
        ...workspaceBody({}),
        editor_id: editorId,
      });
    },
    async handover() {
      if (!workspace) throw new Error('workspace-required');
      return runFinancial('order.handover', `/pos/workspaces/${workspace.id}/handover`, {});
    },
    async recordUnsolicited(input: {
      branchId: string;
      shiftId: string;
      kind: 'cash' | 'bank_manual';
      handedAmount: string;
      reference?: string;
      workspaceId?: string;
    }) {
      const action = 'funds.record_unsolicited';
      const body = {
        branch_id: input.branchId,
        shift_id: input.shiftId,
        kind: input.kind,
        handed_amount: input.handedAmount,
        reference: input.reference || undefined,
        workspace_id: input.workspaceId || undefined,
      };
      const digest = commandDigest(body);
      const workspaceScope = input.workspaceId ?? `branch:${input.branchId}`;
      const scope = financialScope(staffId, storeId, workspaceScope, action, digest);
      const existing =
        staffId && storeId
          ? (await scopedFinancialRecords(staffId, storeId)).find(
              (record) => record.scope === scope,
            )
          : undefined;
      const key = existing?.idempotencyKey ?? crypto.randomUUID();
      try {
        await saveFinancialRecord({
          scope,
          idempotencyKey: key,
          workspaceId: workspaceScope,
          path: '/pos/received_funds',
          body,
          savedAt: Date.now(),
        });
      } catch {
        throw new Error('financial-storage-unavailable');
      }
      try {
        const result = await session.request<{ data: PosReceivedFunds }>(
          'POST',
          '/pos/received_funds',
          { body: { ...body, idempotency_key: key }, idempotencyKey: key },
        );
        await forgetFinancialRecord(scope).catch(() => undefined);
        await refresh();
        return result.data;
      } catch (error) {
        if (posFailureKey(error) !== 'offline' && posFailureKey(error) !== 'conflict') {
          await forgetFinancialRecord(scope).catch(() => undefined);
        }
        abandonIfNeeded(error);
        throw error;
      }
    },
  };
}

export function useLiabilityPayouts(staffId: string | null, storeId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();

  async function run(
    funds: PosReceivedFunds,
    action: string,
    path: string,
    body: Record<string, unknown>,
  ): Promise<PosLiabilityPayout> {
    const digest = commandDigest(body);
    const scope = financialScope(staffId, storeId, funds.id, action, digest);
    const existing =
      staffId && storeId
        ? (await scopedFinancialRecords(staffId, storeId)).find((record) => record.scope === scope)
        : undefined;
    const key = existing?.idempotencyKey ?? crypto.randomUUID();
    try {
      await saveFinancialRecord({
        scope,
        idempotencyKey: key,
        workspaceId: funds.workspace_id ?? funds.id,
        path,
        body,
        savedAt: Date.now(),
      });
    } catch {
      throw new Error('financial-storage-unavailable');
    }
    try {
      const result = await session.request<{ data: PosLiabilityPayout }>('POST', path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      });
      await forgetFinancialRecord(scope).catch(() => undefined);
      await queryClient.invalidateQueries({
        queryKey: ['pos', 'received-funds', snapshot.generation],
      });
      return result.data;
    } catch (error) {
      if (posFailureKey(error) !== 'offline' && posFailureKey(error) !== 'conflict') {
        await forgetFinancialRecord(scope).catch(() => undefined);
      }
      abandonIfNeeded(error);
      throw error;
    }
  }

  return useMutation({
    mutationFn: async (input: {
      funds: PosReceivedFunds;
      action: 'request' | 'confirm' | 'resolve';
      payoutId?: string;
      amount?: string;
      beneficiaryName?: string;
      beneficiaryReference?: string;
      reason?: string;
      approvalId?: string;
      evidenceKind?: string;
      reference?: string;
      outcome?: string;
    }) => {
      if (input.action === 'request') {
        return run(
          input.funds,
          'liability_payout.request',
          `/pos/received_funds/${input.funds.id}/payouts`,
          {
            amount: input.amount,
            beneficiary_name: input.beneficiaryName,
            beneficiary_reference: input.beneficiaryReference || undefined,
            reason: input.reason,
            approval_id: input.approvalId || undefined,
          },
        );
      }
      if (!input.payoutId) throw new Error('payout-required');
      if (input.action === 'confirm') {
        return run(
          input.funds,
          'liability_payout.confirm',
          `/pos/received_funds/${input.funds.id}/payouts/${input.payoutId}/confirm`,
          { evidence_kind: input.evidenceKind, reference: input.reference || undefined },
        );
      }
      return run(
        input.funds,
        'liability_payout.resolve',
        `/pos/received_funds/${input.funds.id}/payouts/${input.payoutId}/resolve`,
        { outcome: input.outcome, reference: input.reference || undefined },
      );
    },
  });
}
