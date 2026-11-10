import { definitiveRejection } from '@parkviet/pos-shared/request-failure'
import type { OnboardingPayload } from '@parkviet/pos-shared/setup-wizard'
import { useQuery } from '@tanstack/react-query'
import { useRef, useState } from 'react'
import { posRequest } from '../lib/pos-request'
import { queryClient } from '../lib/query-client'
import { createSubmissionKey } from '../lib/submission-key'
import { useSession } from './use-session'

// Everything setup or a business model change touches: the context (modules,
// profile, onboarding, branches), the per-branch module reads, the topology
// lists and the store profile.
export async function refreshBusinessModel(storeId?: string) {
  await queryClient.invalidateQueries({ queryKey: storeId ? ['pos', storeId] : ['pos'] })
}

// `POST /pos/onboarding`, once per wizard. The key belongs to the content
// sent (submission-key.ts): pressing again, or checking again after a lost
// response, replays the same key with the same body, so the server answers
// with the first result instead of creating a second branch. A refusal
// (4xx) is final; a transport failure, a timeout or a 5xx leaves the result
// unknown, and the form stays locked on that content until it is checked.
export function useOnboarding() {
  const keys = useRef(createSubmissionKey())
  const [pending, setPending] = useState(false)
  const [uncertain, setUncertain] = useState<OnboardingPayload | null>(null)

  async function send(payload: OnboardingPayload): Promise<unknown> {
    const content = JSON.stringify(payload)
    const key = keys.current.keyFor(content)
    setPending(true)
    try {
      const response = await posRequest<{ data?: unknown }>('POST', '/pos/onboarding', {
        body: payload,
        idempotencyKey: key,
      })
      keys.current.settle(content)
      setUncertain(null)
      return response.data
    } catch (error) {
      setUncertain(definitiveRejection(error) ? null : payload)
      throw error
    } finally {
      setPending(false)
    }
  }

  return {
    submit: send,
    pending,
    uncertain: uncertain !== null,
    // The same content again: same key, so a committed setup is replayed.
    recheck: () => (uncertain ? send(uncertain) : Promise.resolve(undefined)),
  }
}

export type StoreProfile = {
  id: string | null
  profile_key: string
  wholesale: boolean
  interests: string[]
  onboarded_at: string | null
  changed_by_name: string | null
  updated_at: string | null
}

function toStoreProfile(value: unknown): StoreProfile | null {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return null
  const row = value as Record<string, unknown>
  if (typeof row.profile_key !== 'string' || !row.profile_key) return null
  const text = (field: unknown) => (typeof field === 'string' ? field : null)
  return {
    id: text(row.id),
    profile_key: row.profile_key,
    wholesale: row.wholesale === true,
    interests: Array.isArray(row.interests)
      ? row.interests.filter((item): item is string => typeof item === 'string')
      : [],
    onboarded_at: text(row.onboarded_at),
    changed_by_name: text(row.changed_by_name),
    updated_at: text(row.updated_at),
  }
}

export const storeProfileKey = (scope: string, storeId: string | null) =>
  ['pos', scope, 'store-profile', storeId] as const

// The store's main profile (`GET /pos/store_profile`): the default industry of
// new branches. Null before setup, or on a server without profiles.
export function useStoreProfile(storeId: string | null, enabled: boolean) {
  const snapshot = useSession()
  return useQuery({
    queryKey: storeProfileKey(snapshot.generation, storeId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId),
    retry: false,
    queryFn: async (): Promise<StoreProfile | null> => {
      const response = await posRequest<{ data?: unknown }>('GET', '/pos/store_profile', {})
      return toStoreProfile(response.data)
    },
  })
}

// `PUT /pos/store_profile`: changes the default of branches created from now
// on, never an existing branch. Needs `write_pos_topology` and a reason.
export async function saveStoreProfile(body: {
  profile_key: string
  wholesale: boolean
  interests: string[]
  reason: string
}): Promise<StoreProfile | null> {
  const response = await posRequest<{ data?: unknown }>('PUT', '/pos/store_profile', {
    body,
  })
  return toStoreProfile(response.data)
}
