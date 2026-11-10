import { describe, expect, it } from 'vitest'
import en from './locales/en.json'
import vi from './locales/vi.json'

function leafKeys(value: unknown, prefix = ''): string[] {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) return [prefix]
  return Object.entries(value).flatMap(([key, child]) =>
    leafKeys(child, prefix ? `${prefix}.${key}` : key),
  )
}

// i18next plural variants (`_one`, `_other`, ...) are locale-specific
// spellings of the same key, so compare the base keys they cover.
function baseLeafKeys(value: unknown): string[] {
  return [
    ...new Set(leafKeys(value).map((key) => key.replace(/_(zero|one|two|few|many|other)$/, ''))),
  ]
}

describe('POS administration translation contract', () => {
  it('ships every application key in both Vietnamese and English', () => {
    expect(baseLeafKeys(vi).sort()).toEqual(baseLeafKeys(en).sort())
  })
})
