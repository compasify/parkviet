import { adminClient, setApiClient } from '@spree/dashboard-core'

setApiClient({
  auth: adminClient.auth,
  setToken: (token) => adminClient.setToken(token),
  onUnauthorized: (handler) => adminClient.onUnauthorized(handler),
  clearTenant: () => adminClient.setStore(''),
  fetchPermissions: async () => {
    const me = await adminClient.me.get()
    return { rules: me.permissions, keys: me.permission_keys ?? [] }
  },
  updateAccount: (params) => adminClient.me.update(params),
})

export { adminClient }
