import { describe, expect, it } from 'vitest'
import { voidReasonCode } from './void-reasons'

describe('voidReasonCode', () => {
  it('turns a typed Vietnamese reason into a code', () => {
    expect(voidReasonCode('Đổ vỡ  khi bưng')).toBe('do_vo_khi_bung')
    expect(voidReasonCode('  Món nguội! ')).toBe('mon_nguoi')
  })

  it('keeps codes within 40 characters and never ends on a separator', () => {
    const code = voidReasonCode(`${'a'.repeat(39)} b`)
    expect(code.length).toBeLessThanOrEqual(40)
    expect(code.endsWith('_')).toBe(false)
  })

  it('gives nothing for text without letters or digits', () => {
    expect(voidReasonCode('!!!')).toBe('')
  })
})
