import { afterEach, describe, expect, it, vi } from 'vitest'
import { branchHint, preferredStore } from './store-selection'

const retail = { id: 'st_retail' }
const restaurant = { id: 'st_food' }

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('preferredStore', () => {
  it('opens the default store the user works in when none is remembered', () => {
    expect(preferredStore([restaurant, { ...retail, default: true }])).toBe('st_retail')
  })

  it('keeps the remembered store over the default one', () => {
    vi.stubGlobal('localStorage', { getItem: () => 'st_food' })
    expect(preferredStore([{ ...retail, default: true }, restaurant])).toBe('st_food')
  })

  it('falls back to the first store when the default one is not the user’s', () => {
    expect(preferredStore([restaurant, retail])).toBe('st_food')
    expect(preferredStore([])).toBeNull()
  })
})

describe('branchHint', () => {
  const remembered = (value: Record<string, string>) =>
    vi.stubGlobal('localStorage', { getItem: () => JSON.stringify(value) })

  it('asks for the URL branch of this store', () => {
    remembered({ st_food: 'br_food' })
    expect(branchHint('st_retail', 'br_retail')).toBe('br_retail')
  })

  it('ignores a branch carried over from another store', () => {
    remembered({ st_food: 'br_food', st_retail: 'br_retail' })
    expect(branchHint('st_retail', 'br_food')).toBe('br_retail')
    remembered({ st_food: 'br_food' })
    expect(branchHint('st_retail', 'br_food')).toBeNull()
  })

  it('reopens the branch last used in the store', () => {
    remembered({ st_retail: 'br_retail' })
    expect(branchHint('st_retail', undefined)).toBe('br_retail')
    expect(branchHint('st_food', undefined)).toBeNull()
  })
})
