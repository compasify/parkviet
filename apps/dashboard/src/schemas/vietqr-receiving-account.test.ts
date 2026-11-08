import { describe, expect, it } from 'vitest'
import {
  EMPTY_RECEIVING_ACCOUNT,
  receivingAccountPayload,
  receivingAccountToForm,
  secretFieldsFor,
  type VietqrReceivingAccount,
} from './vietqr-receiving-account'

const stored: VietqrReceivingAccount = {
  id: 'vqracct_1',
  payment_method_id: 'pm_1',
  provider: 'sepay',
  bank_bin: '970436',
  bank_name: 'Vietcombank',
  account_number: '0123456789',
  account_name: 'PARK VIET',
  keyword_init: 'PV',
  sub_account: null,
  virtual_account_number: null,
  active: true,
  priority: 2,
  routing_weight: 3,
  monthly_quota_amount: 500000000,
  monthly_threshold_amount: null,
  period_allocated_amount: 0,
  period_confirmed_amount: 0,
  last_allocated_at: null,
  payos_client_id: null,
  webhook_secret: '••••1234',
  payos_api_key: null,
  payos_checksum_key: null,
  webhook_url: 'https://shop.test/webhooks/payments/sepay',
}

describe('receivingAccountPayload', () => {
  it('keeps a stored secret by leaving its mask out', () => {
    const payload = receivingAccountPayload(receivingAccountToForm(stored))
    expect(payload).not.toHaveProperty('webhook_secret')
    expect(payload).toMatchObject({
      priority: 2,
      routing_weight: 3,
      monthly_quota_amount: 500000000,
    })
  })

  it('sends a new secret, strips spaces from the account number and reads amounts as digits', () => {
    const payload = receivingAccountPayload({
      ...EMPTY_RECEIVING_ACCOUNT,
      bank_bin: '970436',
      account_number: '0123 456 789',
      account_name: ' PARK VIET ',
      monthly_quota_amount: '500.000.000',
      webhook_secret: 'new-secret',
    })
    expect(payload).toMatchObject({
      account_number: '0123456789',
      account_name: 'PARK VIET',
      monthly_quota_amount: 500000000,
      monthly_threshold_amount: null,
      webhook_secret: 'new-secret',
    })
  })

  it('only sends the secrets of the chosen provider', () => {
    const payload = receivingAccountPayload({
      ...EMPTY_RECEIVING_ACCOUNT,
      provider: 'payos',
      payos_client_id: 'client',
      payos_api_key: 'api',
      payos_checksum_key: 'checksum',
      webhook_secret: 'ignored',
    })
    expect(payload).toMatchObject({
      payos_client_id: 'client',
      payos_api_key: 'api',
      payos_checksum_key: 'checksum',
    })
    expect(payload).not.toHaveProperty('webhook_secret')
    expect(secretFieldsFor('manual')).toEqual([])
  })
})
