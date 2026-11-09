import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { type FinancialRequest, runFinancialCommand } from '../lib/financial-command';
import type {
  PosLiabilityPayout,
  PosPaymentMethod,
  PosReceivedFunds,
  PosWorkspace,
} from '../lib/pos-context';
import { posWorkspacesKey } from '../lib/query-keys';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { VIETQR_POLL_MS, type VietqrEvidenceKind, type VietqrTenderSummary } from '../lib/vietqr';
import { refreshWorkspaceLists, writeWorkspaceToCache } from '../lib/workspace-cache';
import { useSession } from './use-session';
import { workspaceEditorId } from './use-workspaces';

export type TenderCommandInput = {
  paymentMethodId?: string;
  amount?: string;
  attemptId?: string;
  handedAmount?: string;
  receivedAmount?: string;
  evidenceKind?: 'cash_count' | 'bank_manual' | VietqrEvidenceKind;
  reference?: string;
  receivingAccount?: string;
  terminalRef?: string;
  fundsId?: string;
  allocationId?: string;
};

type Page<T> = { data: T[]; meta: { page: number; pages: number; count: number } };

export const financialRequest: FinancialRequest = <T>(
  method: 'GET' | 'POST',
  path: string,
  options?: Parameters<FinancialRequest>[2],
) => session.request<T>(method, path, options);

export function abandonIfNeeded(error: unknown) {
  if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized') {
    session.abandon();
  }
}

export function usePaymentMethods(workspace: PosWorkspace | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    // Methods do not change with the basket revision; keying on it made the list flicker.
    queryKey: ['pos', 'payment-methods', snapshot.generation, workspace?.id ?? null],
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

// The QR of a prepared VietQR tender, polled until the bank reports the
// transfer. Read-only: it never reserves an account.
export function useVietqrTender(workspaceId: string | null, attemptId: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'vietqr', snapshot.generation, workspaceId, attemptId],
    enabled: snapshot.status === 'authenticated' && Boolean(workspaceId && attemptId),
    refetchInterval: (query) => (query.state.data?.status === 'confirmed' ? false : VIETQR_POLL_MS),
    queryFn: async (): Promise<VietqrTenderSummary | null> => {
      try {
        const result = await session.request<{ data: VietqrTenderSummary | null }>(
          'GET',
          `/pos/workspaces/${workspaceId}/tender_attempts/${attemptId}/vietqr`,
        );
        return result.data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

// Every command takes the workspace the caller's serializer handed it, so the
// expected revision is always the newest one the server returned.
export function useTenders(staffId: string | null, storeId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();

  async function refresh() {
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: ['pos', 'workspaces', snapshot.generation, storeId],
      }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'received-funds', snapshot.generation] }),
    ]);
  }

  // The command returned the canonical workspace: show it at once and reload
  // the tab list and received funds in the background, instead of making the
  // cashier wait for three GETs before the payment dialog or receipt opens.
  async function accept(workspace: PosWorkspace) {
    await queryClient.cancelQueries({ queryKey: posWorkspacesKey(snapshot.generation, storeId) });
    writeWorkspaceToCache(queryClient, snapshot.generation, storeId, workspace);
    void refreshWorkspaceLists(queryClient, snapshot.generation, storeId);
    void queryClient.invalidateQueries({
      queryKey: ['pos', 'received-funds', snapshot.generation],
    });
  }

  async function runFinancial(
    workspace: PosWorkspace,
    action: string,
    path: string,
    body: Record<string, unknown>,
  ): Promise<PosWorkspace> {
    try {
      const result = await runFinancialCommand<PosWorkspace>(financialRequest, {
        staffId,
        storeId,
        scopeId: workspace.id,
        action,
        path,
        body,
      });
      await accept(result.data);
      return result.data;
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    }
  }

  function workspaceBody(workspace: PosWorkspace, input: TenderCommandInput) {
    return {
      expected_revision: workspace.revision,
      lease_generation: workspace.lease_generation,
      editor_id: workspaceEditorId,
      payment_method_id: input.paymentMethodId,
      amount: input.amount,
      handed_amount: input.handedAmount,
      received_amount: input.receivedAmount,
      evidence_kind: input.evidenceKind,
      reference: input.reference,
      receiving_account: input.receivingAccount,
      terminal_ref: input.terminalRef,
      funds_id: input.fundsId,
      allocation_id: input.allocationId,
    };
  }

  function attemptPath(workspace: PosWorkspace, input: TenderCommandInput, verb: string) {
    if (!input.attemptId) throw new Error('attempt-required');
    return `/pos/workspaces/${workspace.id}/tender_attempts/${input.attemptId}/${verb}`;
  }

  return {
    refresh,
    prepare(workspace: PosWorkspace, input: TenderCommandInput) {
      return runFinancial(
        workspace,
        'tender.prepare',
        `/pos/workspaces/${workspace.id}/tender_attempts`,
        workspaceBody(workspace, input),
      );
    },
    confirm(workspace: PosWorkspace, input: TenderCommandInput) {
      return runFinancial(
        workspace,
        'tender.confirm',
        attemptPath(workspace, input, 'confirm'),
        workspaceBody(workspace, input),
      );
    },
    cancel(workspace: PosWorkspace, input: TenderCommandInput) {
      return runFinancial(
        workspace,
        'tender.cancel',
        attemptPath(workspace, input, 'cancel'),
        workspaceBody(workspace, input),
      );
    },
    allocate(workspace: PosWorkspace, input: TenderCommandInput) {
      return runFinancial(
        workspace,
        'funds.allocate',
        `/pos/workspaces/${workspace.id}/funds/allocate`,
        workspaceBody(workspace, input),
      );
    },
    reverse(workspace: PosWorkspace, input: TenderCommandInput) {
      return runFinancial(
        workspace,
        'funds.reverse',
        `/pos/workspaces/${workspace.id}/funds/reverse`,
        workspaceBody(workspace, input),
      );
    },
    // With an approval id the unpaid remainder is sold on that approved credit.
    complete(workspace: PosWorkspace, creditApprovalId?: string) {
      return runFinancial(
        workspace,
        creditApprovalId ? 'workspace.complete_on_credit' : 'workspace.complete',
        `/pos/workspaces/${workspace.id}/complete`,
        creditApprovalId
          ? { ...workspaceBody(workspace, {}), credit_approval_id: creditApprovalId }
          : workspaceBody(workspace, {}),
      );
    },
    handover(workspace: PosWorkspace) {
      return runFinancial(
        workspace,
        'order.handover',
        `/pos/workspaces/${workspace.id}/handover`,
        {},
      );
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
    try {
      const result = await runFinancialCommand<PosLiabilityPayout>(financialRequest, {
        staffId,
        storeId,
        scopeId: funds.id,
        action,
        path,
        body,
      });
      await queryClient.invalidateQueries({
        queryKey: ['pos', 'received-funds', snapshot.generation],
      });
      return result.data;
    } catch (error) {
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
      paidFrom?: 'custody';
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
          {
            evidence_kind: input.evidenceKind,
            reference: input.reference || undefined,
            paid_from: input.paidFrom,
          },
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
