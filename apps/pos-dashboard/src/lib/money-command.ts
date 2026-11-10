import { definitiveRejection, failureStatus } from '@parkviet/pos-shared/request-failure'
import { posRequest } from './pos-request'

export type MoneyResult<T> = { data: T; recovered: boolean }
type Send = <T>(
  method: 'GET' | 'POST',
  path: string,
  options: {
    body?: Record<string, unknown>
    params?: Record<string, string>
    idempotencyKey?: string
  },
) => Promise<T>

// Keys of money commands whose outcome this page does not know yet, by intent.
const pendingKeys = new Map<string, string>()

// Sends one money command (payout, drawer decision, count, close,
// reconciliation) so that a lost response can never post it twice: the same
// intent reuses its key until the outcome is known, and a 409 on that key is
// checked against its command receipt, which may show it already committed.
export async function runMoneyCommand<T>(
  intent: string,
  path: string,
  body: Record<string, unknown>,
  send: Send = posRequest,
  newKey: () => string = () => crypto.randomUUID(),
): Promise<MoneyResult<T>> {
  const key = pendingKeys.get(intent) ?? newKey()
  pendingKeys.set(intent, key)
  try {
    const result = await send<{ data: T }>('POST', path, {
      body: { ...body, idempotency_key: key },
      idempotencyKey: key,
    })
    pendingKeys.delete(intent)
    return { data: result.data, recovered: false }
  } catch (error) {
    if (failureStatus(error) === 409) {
      try {
        const receipt = await send<{ data: T }>('GET', '/pos/command_receipts', {
          params: { idempotency_key: key },
        })
        pendingKeys.delete(intent)
        return { data: receipt.data, recovered: true }
      } catch (lookup) {
        if (failureStatus(lookup) === 404) pendingKeys.delete(intent)
      }
      throw error
    }
    if (definitiveRejection(error)) pendingKeys.delete(intent)
    throw error
  }
}
