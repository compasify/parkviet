// Admin API wrappers for opening another store (server: StoresController).
import { adminClient, i18n, useAuth, useResourceKey, useResourceMutation } from '@spree/dashboard'
import { useQuery } from '@tanstack/react-query'
import { type StoreSummary, withStore } from '../schemas/store'

/** ISO codes of every country a store can sell from; the page names them. */
export function useCountryCodes() {
  return useQuery({
    queryKey: useResourceKey('store-country-codes'),
    queryFn: () =>
      adminClient
        .request<{ data: { iso: string }[] }>('GET', '/countries')
        .then((response) => response.data.map((country) => country.iso)),
    staleTime: Number.POSITIVE_INFINITY,
  })
}

export function useCreateStore() {
  const { user, updateUser } = useAuth()
  return useResourceMutation({
    mutationFn: (body: Record<string, unknown>) =>
      adminClient.request<StoreSummary>('POST', '/stores', { body }),
    successMessage: i18n.t('admin.multi_store.messages.created'),
    onSuccess: (created) => updateUser({ stores: withStore(user?.stores ?? [], created) }),
  })
}
