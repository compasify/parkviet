import { beforeEach, describe, expect, it } from 'vitest'
import { clearEditorDraft, editorDraftKey, readEditorDraft, writeEditorDraft } from './editor-draft'

class MemoryStorage implements Storage {
  private items = new Map<string, string>()
  failWrites = false
  get length() {
    return this.items.size
  }
  clear() {
    this.items.clear()
  }
  getItem(key: string) {
    return this.items.get(key) ?? null
  }
  key(index: number) {
    return [...this.items.keys()][index] ?? null
  }
  removeItem(key: string) {
    this.items.delete(key)
  }
  setItem(key: string, value: string) {
    if (this.failWrites) throw new Error('QuotaExceededError')
    this.items.set(key, value)
  }
}

type Value = { name: string }
const parse = (value: unknown): Value | null =>
  value !== null && typeof value === 'object' && typeof (value as Value).name === 'string'
    ? (value as Value)
    : null

describe('editor drafts', () => {
  let storage: MemoryStorage
  const key = editorDraftKey('receipt-template', 'user_1', 'store_1', 'tpl_1')
  beforeEach(() => {
    storage = new MemoryStorage()
  })

  it('scopes keys by kind, store and record', () => {
    expect(key).not.toBe(editorDraftKey('receipt-template', 'user_1', 'store_2', 'tpl_1'))
    expect(key).not.toBe(editorDraftKey('receipt-template', 'user_2', 'store_1', 'tpl_1'))
    expect(key).not.toBe(editorDraftKey('receipt-template', 'user_1', 'store_1', 'tpl_2'))
    expect(editorDraftKey('a', 'u', 'b:c', 'd')).not.toBe(editorDraftKey('a', 'u', 'b', 'c:d'))
  })

  it('restores a draft based on the same server version', () => {
    expect(writeEditorDraft(storage, key, 3, { name: 'Draft' })).toBe(true)
    expect(readEditorDraft(storage, key, 3, parse)).toEqual({ name: 'Draft' })
  })

  it('discards a draft when the server version moved on', () => {
    writeEditorDraft(storage, key, 3, { name: 'Draft' })
    expect(readEditorDraft(storage, key, 4, parse)).toBeNull()
    expect(storage.getItem(key)).toBeNull()
  })

  it('discards corrupt or invalid stored data', () => {
    storage.setItem(key, '{not json')
    expect(readEditorDraft(storage, key, 1, parse)).toBeNull()
    expect(storage.getItem(key)).toBeNull()
    storage.setItem(key, JSON.stringify({ version: 1, value: { name: 5 } }))
    expect(readEditorDraft(storage, key, 1, parse)).toBeNull()
    expect(storage.getItem(key)).toBeNull()
    storage.setItem(key, JSON.stringify({ value: { name: 'x' } }))
    expect(readEditorDraft(storage, key, 1, parse)).toBeNull()
    expect(storage.getItem(key)).toBeNull()
  })

  it('clears a draft and tolerates missing or failing storage', () => {
    writeEditorDraft(storage, key, 1, { name: 'Draft' })
    clearEditorDraft(storage, key)
    expect(readEditorDraft(storage, key, 1, parse)).toBeNull()
    storage.failWrites = true
    expect(writeEditorDraft(storage, key, 1, { name: 'Draft' })).toBe(false)
    expect(writeEditorDraft(null, key, 1, { name: 'Draft' })).toBe(false)
    expect(readEditorDraft(null, key, 1, parse)).toBeNull()
    expect(() => clearEditorDraft(null, key)).not.toThrow()
  })
})
