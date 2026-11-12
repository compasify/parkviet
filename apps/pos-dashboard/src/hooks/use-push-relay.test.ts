import { describe, expect, it } from 'vitest'
import { normalizePushRelay, relayInputProblem } from './use-push-relay'

describe('push relay', () => {
  it('reads the relay the server sends, never a key, and none for a missing one', () => {
    expect(
      normalizePushRelay({
        url: 'https://relay.example.test/push',
        key_set: true,
        relay_key: 'never-shown',
        last_error: null,
        last_error_at: null,
        last_delivered_at: '2026-11-12T03:00:00Z',
        updated_at: '2026-11-12T02:00:00Z',
      }),
    ).toEqual({
      url: 'https://relay.example.test/push',
      key_set: true,
      last_error: null,
      last_error_at: null,
      last_delivered_at: '2026-11-12T03:00:00Z',
      updated_at: '2026-11-12T02:00:00Z',
    })
    expect(normalizePushRelay(null)).toBeNull()
  })

  it('wants an HTTPS address, and a key of the right length the first time only', () => {
    const key = 'k'.repeat(40)
    expect(relayInputProblem('http://relay.example.test', key, false)).toBe('url')
    expect(relayInputProblem(`https://${'a'.repeat(300)}`, key, false)).toBe('url')
    expect(relayInputProblem('https://relay.example.test/push', '', false)).toBe('key')
    expect(relayInputProblem('https://relay.example.test/push', 'short', true)).toBe('key')
    expect(relayInputProblem('https://relay.example.test/push', '', true)).toBeNull()
    expect(relayInputProblem('https://relay.example.test/push', key, false)).toBeNull()
  })
})
