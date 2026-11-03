import { createAdminClient } from '@spree/admin-sdk'

// Tokens live only in this client instance; no storage or secret API key.
export function createSession() {
  let client = createAdminClient({ baseUrl: window.location.origin })

  return {
    async login(email: string, password: string) {
      try {
        const { token } = await client.auth.login({ email, password })
        client.setToken(token)
        return await client.me.get()
      } catch (error) {
        // Discard any access token if identity lookup fails. The refresh cookie
        // may still exist; it is not used to restore a session in this preview.
        client = createAdminClient({ baseUrl: window.location.origin })
        throw error
      }
    },
    async logout() {
      const previous = client
      client = createAdminClient({ baseUrl: window.location.origin })
      await previous.auth.logout()
    },
  }
}
