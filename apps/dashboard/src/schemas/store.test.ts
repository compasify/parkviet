import { describe, expect, it } from 'vitest'
import { EMPTY_NEW_STORE, newStorePayload, withStore } from './store'

describe('newStorePayload', () => {
  it('trims the name and leaves blank emails to the API', () => {
    expect(
      newStorePayload({ ...EMPTY_NEW_STORE, name: '  Nhà hàng  ', mail_from_address: ' ' }),
    ).toEqual({
      name: 'Nhà hàng',
      country_code: 'VN',
    })
  })

  it('sends the emails that were filled in', () => {
    expect(
      newStorePayload({
        ...EMPTY_NEW_STORE,
        name: 'Nhà hàng',
        mail_from_address: 'no-reply@nhahang.vn',
        customer_support_email: 'hotro@nhahang.vn ',
      }),
    ).toEqual({
      name: 'Nhà hàng',
      country_code: 'VN',
      mail_from_address: 'no-reply@nhahang.vn',
      customer_support_email: 'hotro@nhahang.vn',
    })
  })
})

describe('withStore', () => {
  const shop = { id: 'store_1', name: 'Shop', code: 'shop' }

  it('adds the new store in name order', () => {
    const created = { id: 'store_2', name: 'Nhà hàng', code: 'nha-hang' }
    expect(withStore([shop], created).map((store) => store.id)).toEqual(['store_2', 'store_1'])
  })

  it('does not list a store twice', () => {
    expect(withStore([shop], shop)).toHaveLength(1)
  })
})
