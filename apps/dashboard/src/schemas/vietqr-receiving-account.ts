// Form values of a VietQR receiving account and their mapping to the
// spree_vietqr Admin API. Secrets arrive masked (`••••1234`); a masked or
// blank secret is left out of the payload so the stored value is kept.

export const VIETQR_PROVIDERS = ['sepay', 'payos', 'manual'] as const
export type VietqrProvider = (typeof VIETQR_PROVIDERS)[number]

export const VIETQR_SECRET_FIELDS = [
  'webhook_secret',
  'payos_api_key',
  'payos_checksum_key',
] as const
type SecretField = (typeof VIETQR_SECRET_FIELDS)[number]

const SECRET_MASK = '••••'

/** What the Admin API returns for one receiving account. */
export interface VietqrReceivingAccount {
  id: string
  payment_method_id: string
  provider: VietqrProvider
  bank_bin: string
  bank_name: string | null
  account_number: string
  account_name: string
  keyword_init: string | null
  sub_account: string | null
  virtual_account_number: string | null
  active: boolean
  priority: number
  routing_weight: number
  monthly_quota_amount: number | null
  monthly_threshold_amount: number | null
  period_allocated_amount: number
  period_confirmed_amount: number
  last_allocated_at: string | null
  payos_client_id: string | null
  webhook_secret: string | null
  payos_api_key: string | null
  payos_checksum_key: string | null
  webhook_url: string | null
}

export interface VietqrReceivingAccountFormValues {
  provider: VietqrProvider
  bank_bin: string
  bank_name: string
  account_number: string
  account_name: string
  keyword_init: string
  sub_account: string
  virtual_account_number: string
  active: boolean
  priority: string
  routing_weight: string
  monthly_quota_amount: string
  monthly_threshold_amount: string
  payos_client_id: string
  webhook_secret: string
  payos_api_key: string
  payos_checksum_key: string
}

export const EMPTY_RECEIVING_ACCOUNT: VietqrReceivingAccountFormValues = {
  provider: 'sepay',
  bank_bin: '',
  bank_name: '',
  account_number: '',
  account_name: '',
  keyword_init: '',
  sub_account: '',
  virtual_account_number: '',
  active: true,
  priority: '0',
  routing_weight: '1',
  monthly_quota_amount: '',
  monthly_threshold_amount: '',
  payos_client_id: '',
  webhook_secret: '',
  payos_api_key: '',
  payos_checksum_key: '',
}

/** Which secrets a provider needs. */
export function secretFieldsFor(provider: VietqrProvider): SecretField[] {
  if (provider === 'sepay') return ['webhook_secret']
  if (provider === 'payos') return ['payos_api_key', 'payos_checksum_key']
  return []
}

export function isMaskedSecret(value: string | null | undefined): boolean {
  return typeof value === 'string' && value.startsWith(SECRET_MASK)
}

const text = (value: string | null | undefined) => value ?? ''
const amount = (value: number | null | undefined) => (value == null ? '' : String(value))

export function receivingAccountToForm(
  account: VietqrReceivingAccount,
): VietqrReceivingAccountFormValues {
  return {
    provider: account.provider,
    bank_bin: account.bank_bin,
    bank_name: text(account.bank_name),
    account_number: account.account_number,
    account_name: account.account_name,
    keyword_init: text(account.keyword_init),
    sub_account: text(account.sub_account),
    virtual_account_number: text(account.virtual_account_number),
    active: account.active,
    priority: String(account.priority),
    routing_weight: String(account.routing_weight),
    monthly_quota_amount: amount(account.monthly_quota_amount),
    monthly_threshold_amount: amount(account.monthly_threshold_amount),
    payos_client_id: text(account.payos_client_id),
    webhook_secret: text(account.webhook_secret),
    payos_api_key: text(account.payos_api_key),
    payos_checksum_key: text(account.payos_checksum_key),
  }
}

const blankToNull = (value: string) => (value.trim() === '' ? null : value.trim())
const integerOr = (value: string, fallback: number) => {
  const parsed = Number.parseInt(value, 10)
  return Number.isFinite(parsed) ? parsed : fallback
}
const amountOrNull = (value: string) => {
  const digits = value.replace(/[^\d]/g, '')
  return digits === '' ? null : Number(digits)
}

export function receivingAccountPayload(
  values: VietqrReceivingAccountFormValues,
): Record<string, unknown> {
  const payload: Record<string, unknown> = {
    provider: values.provider,
    bank_bin: values.bank_bin.trim(),
    bank_name: blankToNull(values.bank_name),
    account_number: values.account_number.replace(/\s/g, ''),
    account_name: values.account_name.trim(),
    keyword_init: blankToNull(values.keyword_init),
    sub_account: blankToNull(values.sub_account),
    virtual_account_number: blankToNull(values.virtual_account_number),
    active: values.active,
    priority: integerOr(values.priority, 0),
    routing_weight: integerOr(values.routing_weight, 1),
    monthly_quota_amount: amountOrNull(values.monthly_quota_amount),
    monthly_threshold_amount: amountOrNull(values.monthly_threshold_amount),
    payos_client_id: values.provider === 'payos' ? blankToNull(values.payos_client_id) : null,
  }
  for (const field of secretFieldsFor(values.provider)) {
    const value = values[field].trim()
    if (value !== '' && !isMaskedSecret(value)) payload[field] = value
  }
  return payload
}
