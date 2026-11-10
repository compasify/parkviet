import { parseMoneyInput } from '@parkviet/pos-shared/money'
import type { PosLiabilityPayout, PosReceivedFunds } from '@parkviet/pos-shared/types/pos-context'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { runMoneyCommand } from '../lib/money-command'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { type Page, pageParams } from '../lib/table-params'
import { localList } from '../tables/local-list'
import { useSession } from './use-session'

// Received money that is not fully applied or not yet identified.
export const needsAttention = (fund: PosReceivedFunds) =>
  fund.status === 'attention' || parseMoneyInput(fund.available) !== '0'

// The branch ledger, newest first, paged on the server.
export function fetchFunds(branchId: string, params: Record<string, unknown>) {
  return request<Page<PosReceivedFunds>>('GET', '/pos/received_funds', {
    params: { branch_id: branchId, ...pageParams(params) },
  })
}

// The attention view reads the newest hundred records (as the home count
// does) and keeps the ones still waiting, so its pages hold only those.
export async function fetchFundsAttention(branchId: string, params: Record<string, unknown>) {
  const rows = await request<Page<PosReceivedFunds>>('GET', '/pos/received_funds', {
    params: { branch_id: branchId, page: '1', limit: '100' },
  })
  return localList(rows.data.filter(needsAttention), params, {
    searchParam: 'search',
    text: (fund) => [fund.reference, fund.id].join(' '),
  })
}

export function useFundDetail(fundsId: string | null, branchId: string | null) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'received-funds', 'detail', fundsId),
    enabled: status === 'authenticated' && Boolean(fundsId && branchId),
    queryFn: async () =>
      (await request<{ data: PosReceivedFunds }>('GET', `/pos/received_funds/${fundsId}`)).data,
  })
}

export type PayoutInput =
  | {
      action: 'request'
      amount: string
      beneficiaryName: string
      beneficiaryReference?: string
      reason: string
      approvalId?: string
    }
  | {
      action: 'confirm'
      payoutId: string
      evidenceKind: string
      reference?: string
      paidFrom?: 'custody'
    }
  | {
      action: 'resolve'
      payoutId: string
      outcome: 'unknown' | 'failed_no_effect' | 'cancel'
      reference?: string
    }

// Refunds of received money paid back to a beneficiary: request, confirm the
// payment with evidence, or resolve one whose outcome is unknown.
export function useLiabilityPayouts(funds: PosReceivedFunds) {
  const { storeId } = useSession()
  const client = useQueryClient()
  const base = `/pos/received_funds/${funds.id}/payouts`
  return useMutation({
    mutationFn: async (input: PayoutInput) => {
      if (input.action === 'request') {
        const body = {
          amount: input.amount,
          beneficiary_name: input.beneficiaryName,
          beneficiary_reference: input.beneficiaryReference || undefined,
          reason: input.reason,
          approval_id: input.approvalId || undefined,
        }
        return runMoneyCommand<PosLiabilityPayout>(
          `${storeId}:${funds.id}:payout.request:${JSON.stringify(body)}`,
          base,
          body,
        )
      }
      if (input.action === 'confirm') {
        const body = {
          evidence_kind: input.evidenceKind,
          reference: input.reference || undefined,
          paid_from: input.paidFrom,
        }
        return runMoneyCommand<PosLiabilityPayout>(
          `${storeId}:${input.payoutId}:payout.confirm:${JSON.stringify(body)}`,
          `${base}/${input.payoutId}/confirm`,
          body,
        )
      }
      const body = { outcome: input.outcome, reference: input.reference || undefined }
      return runMoneyCommand<PosLiabilityPayout>(
        `${storeId}:${input.payoutId}:payout.resolve:${JSON.stringify(body)}`,
        `${base}/${input.payoutId}/resolve`,
        body,
      )
    },
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'received-funds'] }),
  })
}
