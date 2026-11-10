import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const { request } = vi.hoisted(() => ({ request: vi.fn() }))
vi.mock('@spree/dashboard-core', () => ({ adminClient: { request } }))

import { posRequest } from './pos-request'

describe('custom SDK request', () => {
  beforeEach(() => request.mockReset())
  it('retains params, body and the idempotency header', async () => {
    request.mockResolvedValue({ data: { id: 'b' } })
    await expect(
      posRequest('POST', '/pos/onboarding', {
        body: { name: 'Branch' },
        params: { branch_id: 'b' },
        idempotencyKey: 'repeat-safe',
      }),
    ).resolves.toEqual({ data: { id: 'b' } })
    expect(request).toHaveBeenCalledWith('POST', '/pos/onboarding', {
      body: { name: 'Branch' },
      params: { branch_id: 'b' },
      idempotencyKey: 'repeat-safe',
    })
  })
  it('preserves conflict reasons and validation errors for existing consumers', async () => {
    const conflict = Object.assign(new Error('Changed elsewhere'), {
      status: 409,
      details: { reason: 'profile_conflict' },
    })
    request.mockRejectedValueOnce(conflict)
    let caught: unknown
    try {
      await posRequest('PUT', '/pos/store_profile')
    } catch (error) {
      caught = error
    }
    expect(caught).toBe(conflict)
    expect(conflictReason(conflict)).toBe('profile_conflict')
    const invalid = Object.assign(new Error('Invalid input'), {
      status: 422,
      details: { name: ['is required'] },
    })
    expect(describeFailure(invalid, (key) => key)).toContain('name: is required')
  })
})
