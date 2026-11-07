// Holds one idempotency key per submitted content. Resubmitting the same content
// after a lost response reuses the key, so the server replays its first answer
// instead of creating a second record. Changed content or a confirmed success
// starts a new key.
export function createSubmissionKey(newKey: () => string = () => crypto.randomUUID()) {
  let current: { content: string; key: string } | null = null;
  return {
    keyFor(content: string): string {
      if (current?.content !== content) current = { content, key: newKey() };
      return current.key;
    },
    settle(content: string) {
      if (current?.content === content) current = null;
    },
  };
}

// Blank optional fields are omitted from the request, so they compare equal.
export function customerSubmissionContent(input: {
  branchId: string;
  name: string;
  phone?: string;
  email?: string;
}): string {
  return JSON.stringify([input.branchId, input.name, input.phone || '', input.email || '']);
}
