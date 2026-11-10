// Keep a key tied to submitted content across an uncertain transport result.
export function createSubmissionKey(newKey: () => string = () => crypto.randomUUID()) {
  let current: { content: string; key: string } | null = null
  return {
    keyFor(content: string) {
      if (current?.content !== content) current = { content, key: newKey() }
      return current.key
    },
    settle(content: string) {
      if (current?.content === content) current = null
    },
  }
}
