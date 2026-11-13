// Opening another store (POST /stores): its form values, the request body,
// and how the new store joins the signed-in user's store list.

export interface StoreSummary {
  id: string
  name: string
  code: string
}

export interface NewStoreFormValues {
  name: string
  country_code: string
  mail_from_address: string
  customer_support_email: string
}

export const EMPTY_NEW_STORE: NewStoreFormValues = {
  name: '',
  country_code: 'VN',
  mail_from_address: '',
  customer_support_email: '',
}

/** Blank emails are left out so the API copies the current store's. */
export function newStorePayload(values: NewStoreFormValues): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    name: values.name.trim(),
    country_code: values.country_code,
  }
  for (const field of ['mail_from_address', 'customer_support_email'] as const) {
    const value = values[field].trim()
    if (value !== '') payload[field] = value
  }
  return payload
}

/**
 * The user's stores with `created` added, in the order the API lists them
 * (by name), so the store switcher shows it without signing in again.
 */
export function withStore(stores: StoreSummary[], created: StoreSummary): StoreSummary[] {
  const summary = { id: created.id, name: created.name, code: created.code }
  return [...stores.filter((store) => store.id !== created.id), summary].sort((a, b) =>
    a.name.localeCompare(b.name),
  )
}
