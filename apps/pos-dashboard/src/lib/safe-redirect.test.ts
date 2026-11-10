import { describe, expect, it } from 'vitest'
import { loginRedirect, safeRedirect } from './safe-redirect'

describe('safeRedirect', () => {
  it('accepts same-app paths with search and hash', () => {
    expect(safeRedirect('/store_1/settings/receipt-templates/tpl_1?branch=b1')).toBe(
      '/store_1/settings/receipt-templates/tpl_1?branch=b1',
    )
    expect(safeRedirect('/store_1/branches#top')).toBe('/store_1/branches#top')
    expect(safeRedirect('/')).toBe('/')
  })

  it.each([
    ['empty', ''],
    ['non-string', 42],
    ['undefined', undefined],
    ['relative', 'store_1/branches'],
    ['absolute url', 'https://evil.test/store_1'],
    ['javascript scheme', 'javascript:alert(1)'],
    ['protocol-relative', '//evil.test/path'],
    ['backslash protocol-relative', '/\\evil.test'],
    ['backslash later in path', '/store_1\\..\\x'],
    ['tab smuggling', '/\t/evil.test'],
    ['newline smuggling', '/\n/evil.test'],
    ['too long', `/${'a'.repeat(2048)}`],
    ['login loop', '/login?redirect=%2Fstore_1'],
    ['forgot password', '/forgot-password'],
  ])('rejects %s', (_label, value) => {
    expect(safeRedirect(value)).toBeNull()
  })

  it('does not treat lookalike paths as auth pages', () => {
    expect(safeRedirect('/login-history')).toBe('/login-history')
  })
})

describe('loginRedirect', () => {
  it('omits the default landing page and unsafe targets', () => {
    expect(loginRedirect('/')).toBeUndefined()
    expect(loginRedirect('//evil.test')).toBeUndefined()
    expect(loginRedirect('/store_1/features?branch=b1')).toBe('/store_1/features?branch=b1')
  })
})
