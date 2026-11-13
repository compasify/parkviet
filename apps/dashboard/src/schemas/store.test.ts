import { describe, expect, it } from 'vitest'
import { EMPTY_NEW_STORE, newStorePayload, pageStores, type StoreRow, withStore } from './store'

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

describe('pageStores', () => {
  const rows: StoreRow[] = [
    { id: 'store_shop', name: 'Bán lẻ', code: 'retail', current: true },
    { id: 'store_food', name: 'Nhà hàng', code: 'food', current: false },
    { id: 'store_bar', name: 'Quầy bar', code: 'bar', current: false },
  ]

  it('searches the name and the code, and sorts by name', () => {
    expect(pageStores(rows, { q: 'hàng' }).data.map((row) => row.id)).toEqual(['store_food'])
    expect(pageStores(rows, { q: 'BAR' }).data.map((row) => row.code)).toEqual(['bar'])
    expect(pageStores(rows, { sort: '-name' }).data.map((row) => row.name)).toEqual([
      'Quầy bar',
      'Nhà hàng',
      'Bán lẻ',
    ])
  })

  it('applies a column filter and pages the rest', () => {
    expect(pageStores(rows, { name_cont: 'à' }).data.map((row) => row.id)).toEqual(['store_food'])
    expect(pageStores(rows, { code_eq: 'retail' }).data.map((row) => row.id)).toEqual([
      'store_shop',
    ])
    const page = pageStores(rows, { page: 2, limit: 2 })
    expect(page.data.map((row) => row.id)).toEqual(['store_bar'])
    expect(page.meta).toMatchObject({ count: 3, pages: 2, previous: 1, next: null })
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
