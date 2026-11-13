import { describe, expect, it } from 'vitest'
import { posSellingConfigured, posSellingUrl } from './pos-selling-url'

describe('POS selling links', () => {
  it('uses the development port only in development', () => {
    expect(posSellingUrl('store_1', null, { development: true })).toBe(
      'http://localhost:5175/?store=store_1',
    )
    expect(posSellingUrl('store_1', 'branch_1', { development: true })).toBe(
      'http://localhost:5175/?store=store_1&branch=branch_1',
    )
    expect(posSellingConfigured({ development: true })).toBe(true)
    expect(posSellingUrl('store_1', null, { development: false })).toBeNull()
    expect(posSellingConfigured({ development: false })).toBe(false)
  })

  it('resolves a path-only base against the server this app is served from', () => {
    const location = { baseUrl: '/pos/', origin: 'http://192.168.1.10' }
    expect(posSellingUrl('store_1', 'branch_1', location)).toBe(
      'http://192.168.1.10/pos/?store=store_1&branch=branch_1',
    )
    expect(posSellingConfigured(location)).toBe(true)
    expect(posSellingConfigured({ baseUrl: '/pos/' })).toBe(false)
    expect(posSellingConfigured({ baseUrl: '//other.test/', origin: 'http://192.168.1.10' })).toBe(
      false,
    )
  })

  it('keeps a configured origin and drops anything already on that address', () => {
    expect(
      posSellingUrl('store_1', null, { baseUrl: 'https://pos.example.test/pos/?old=1#old' }),
    ).toBe('https://pos.example.test/pos/?store=store_1')
  })

  it('fails closed on missing identity and unsafe configuration', () => {
    expect(posSellingUrl(null, null, { development: true })).toBeNull()
    expect(posSellingUrl('..', null, { development: true })).toBeNull()
    expect(posSellingUrl('store_1', '../branch', { development: true })).toBe(
      'http://localhost:5175/?store=store_1',
    )
    for (const baseUrl of ['invalid', 'javascript:alert(1)', 'https://user:pass@example.test']) {
      expect(posSellingUrl('store_1', null, { baseUrl })).toBeNull()
      expect(posSellingConfigured({ baseUrl })).toBe(false)
    }
  })
})
