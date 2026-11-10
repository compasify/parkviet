import { describe, expect, it, vi } from 'vitest'
import { copyMessage, shareMessage } from './share-message'

describe('reminder sharing', () => {
  it('copies when no share sheet exists', async () => {
    const writeText = vi.fn(async () => undefined)
    const clipboard = { writeText } as unknown as Clipboard
    expect(await shareMessage('Nhắc nợ', null, 'title', { clipboard })).toBe('copied')
    expect(writeText).toHaveBeenCalledWith('Nhắc nợ')
  })
  it('reports a dismissed share sheet without copying', async () => {
    const writeText = vi.fn(async () => undefined)
    const share = vi.fn(async () => {
      throw new DOMException('dismissed', 'AbortError')
    })
    const nav = { share, clipboard: { writeText } as unknown as Clipboard }
    expect(await shareMessage('Nhắc nợ', null, 'title', nav)).toBe('cancelled')
    expect(writeText).not.toHaveBeenCalled()
  })
  it('fails without a clipboard', async () => {
    expect(await copyMessage('Nhắc nợ', {})).toBe('failed')
  })
})
