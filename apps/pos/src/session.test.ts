import { beforeEach, describe, expect, it, vi } from 'vitest'

const sdk = vi.hoisted(() => ({ create: vi.fn() }))
vi.mock('@spree/admin-sdk', () => ({ createAdminClient: sdk.create }))
import { createSession } from './session'

function client() {
  return {
    auth: { login: vi.fn().mockResolvedValue({ token: 'access' }), logout: vi.fn().mockResolvedValue(undefined) },
    setToken: vi.fn(),
    me: { get: vi.fn().mockResolvedValue({ user: { email: 'staff@example.test' } }) },
  }
}

beforeEach(() => {
  vi.stubGlobal('window', { location: { origin: 'http://localhost' } })
  sdk.create.mockReset()
})

describe('phiên nhân viên', () => {
  it('passes the SDK access token to the identity request', async () => {
    const api = client()
    sdk.create.mockReturnValue(api)
    const session = createSession()
    const result = await session.login('staff@example.test', 'password')
    expect(result.user.email).toBe('staff@example.test')
    expect(api.setToken).toHaveBeenCalledWith('access')
    expect(api.auth.login).toHaveBeenCalledWith({ email: 'staff@example.test', password: 'password' })
  })

  it('discards the client if fetching identity fails', async () => {
    const first = client()
    const next = client()
    first.me.get.mockRejectedValue(new Error('network'))
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next)
    const session = createSession()
    await expect(session.login('staff@example.test', 'password')).rejects.toThrow('network')
    await session.login('staff@example.test', 'password')
    expect(next.auth.login).toHaveBeenCalledOnce()
  })

  it('drops the local client before attempting remote logout', async () => {
    const first = client()
    const next = client()
    first.auth.logout.mockRejectedValue(new Error('offline'))
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next)
    const session = createSession()
    await expect(session.logout()).rejects.toThrow('offline')
    await session.login('staff@example.test', 'password')
    expect(next.auth.login).toHaveBeenCalledOnce()
  })
})
