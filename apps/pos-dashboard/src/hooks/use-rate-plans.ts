import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import type { RatePlan, RatePreview, RateRule, SpecialDay } from '../lib/rate-plans'
import { useSession } from './use-session'

export type RatePlanList = { data: RatePlan[]; meta: { weekend_days?: number[] } }
export type RatePlanInput = Partial<
  Pick<
    RatePlan,
    | 'name'
    | 'resource_type_code'
    | 'variant_id'
    | 'block_minutes'
    | 'grace_minutes'
    | 'minimum_minutes'
    | 'status'
  >
> & { rules?: Omit<RateRule, 'id'>[] }

// A branch's rate plans, newest version of each first, with its weekend days.
export function useRatePlans(branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'rate-plans', branchId),
    queryFn: () =>
      posRequest<RatePlanList>('GET', '/pos/rate_plans', {
        params: { branch_id: branchId, limit: '100' },
      }),
  })
}

export function useSpecialDays(branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'rate-plans', branchId, 'special-days'),
    queryFn: async () =>
      (
        await posRequest<{ data: SpecialDay[] }>('GET', '/pos/rate_plans/special_days', {
          params: { branch_id: branchId, limit: '100' },
        })
      ).data,
  })
}

// What a stay would cost on a plan, with nothing written.
export function useRatePreview(
  branchId: string,
  planId: string | null,
  range: { startedAt: string; endedAt: string } | null,
) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'rate-plans', branchId, 'preview', planId, range),
    enabled: Boolean(planId && range),
    queryFn: async () =>
      (
        await posRequest<{ data: RatePreview }>('GET', `/pos/rate_plans/${planId}/preview`, {
          params: {
            branch_id: branchId,
            started_at: range?.startedAt ?? '',
            ended_at: range?.endedAt ?? '',
          },
        })
      ).data,
  })
}

type Write =
  | { kind: 'plan'; id?: string; input: RatePlanInput }
  | { kind: 'special_day'; date: string; name: string; holiday_surcharge_percent: string }
  | { kind: 'remove_special_day'; id: string }
  | { kind: 'weekend_days'; days: number[] }

// Every write of the tab: a plan (a used one comes back as its next
// version), a holiday added or removed, the weekend days.
export function useRatePlanWrite(branchId: string) {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: (write: Write) => {
      const idempotencyKey = crypto.randomUUID()
      const branch = { branch_id: branchId }
      switch (write.kind) {
        case 'plan':
          return posRequest<{ data: RatePlan }>(
            write.id ? 'PATCH' : 'POST',
            write.id ? `/pos/rate_plans/${write.id}` : '/pos/rate_plans',
            { body: { ...write.input, ...branch }, idempotencyKey },
          )
        case 'special_day':
          return posRequest('POST', '/pos/rate_plans/special_days', {
            body: {
              ...branch,
              date: write.date,
              name: write.name,
              ...(write.holiday_surcharge_percent
                ? { holiday_surcharge_percent: write.holiday_surcharge_percent }
                : {}),
            },
            idempotencyKey,
          })
        case 'remove_special_day':
          return posRequest('DELETE', `/pos/rate_plans/special_days/${write.id}`, {
            body: branch,
            idempotencyKey,
          })
        case 'weekend_days':
          return posRequest('PATCH', '/pos/rate_plans/weekend_days', {
            body: { ...branch, weekend_days: write.days },
            idempotencyKey,
          })
      }
    },
    successMessage: false,
    errorMessage: false,
    onSuccess: () =>
      client.invalidateQueries({ queryKey: posKey(storeId, 'rate-plans', branchId) }),
  })
}
