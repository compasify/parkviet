import { describe, expect, it, vi } from 'vitest'

vi.mock('./pos-request', () => ({ posRequest: vi.fn() }))

import { runMoneyCommand } from './money-command'

const failure = (status: number) => Object.assign(new Error('failed'), { status })

describe('money commands', () => {
  it('reuses the key of an intent whose outcome is unknown', async () => {
    let n = 0
    const keys: string[] = []
    const send = vi.fn(
      async (_method: string, _path: string, options: { idempotencyKey?: string }) => {
        keys.push(options.idempotencyKey ?? '')
        if (keys.length === 1) throw failure(503)
        return { data: 'ok' }
      },
    )
    const newKey = () => `k${++n}`
    await expect(runMoneyCommand('a', '/pos/x', {}, send as never, newKey)).rejects.toThrow()
    await expect(runMoneyCommand('a', '/pos/x', {}, send as never, newKey)).resolves.toEqual({
      data: 'ok',
      recovered: false,
    })
    expect(keys).toEqual(['k1', 'k1'])
    await runMoneyCommand('a', '/pos/x', {}, send as never, newKey)
    expect(keys[2]).toBe('k2')
  })

  it('returns the committed result when a conflicting key already has a receipt', async () => {
    const send = vi.fn(async (method: string) => {
      if (method === 'POST') throw failure(409)
      return { data: 'earlier' }
    })
    await expect(runMoneyCommand('b', '/pos/x', {}, send as never)).resolves.toEqual({
      data: 'earlier',
      recovered: true,
    })
  })

  it('drops the key after a definitive refusal', async () => {
    let n = 0
    const keys: string[] = []
    const send = vi.fn(
      async (_method: string, _path: string, options: { idempotencyKey?: string }) => {
        keys.push(options.idempotencyKey ?? '')
        throw failure(422)
      },
    )
    const newKey = () => `r${++n}`
    await expect(runMoneyCommand('c', '/pos/x', {}, send as never, newKey)).rejects.toThrow()
    await expect(runMoneyCommand('c', '/pos/x', {}, send as never, newKey)).rejects.toThrow()
    expect(keys).toEqual(['r1', 'r2'])
  })
})
