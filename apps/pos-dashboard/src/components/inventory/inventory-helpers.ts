import {
  type PosAdjustment,
  type PosLot,
  type PosTraceStatus,
  parseSerials,
  parseWholeQuantity,
} from '@parkviet/pos-shared/traceability'
import type { PaginationMeta } from '@spree/dashboard-ui'

// Pure helpers of the stock traceability screens: labels, the branch's
// calendar day for expiry badges, the server page meta in the table's shape,
// and the request bodies of the transfer and count forms. Every stock rule is
// still enforced by the server; these only refuse what it would refuse anyway.

export type Failure = { error: string; options?: Record<string, unknown> }
export type Built = { body: Record<string, unknown> } | Failure

export function quantity(value: number | null | undefined, unit: string | undefined): string {
  if (value === null || value === undefined) return '—'
  return unit ? `${value} ${unit}` : String(value)
}

export function variantLabel(variant: Pick<PosTraceStatus, 'name' | 'sku'>): string {
  return variant.sku ? `${variant.name} · ${variant.sku}` : variant.name
}

// The calendar day (YYYY-MM-DD) where the branch trades.
export function todayIn(timeZone: string, now = new Date()): string {
  let parts: Intl.DateTimeFormatPart[]
  try {
    parts = new Intl.DateTimeFormat('en-CA', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(now)
  } catch {
    return now.toISOString().slice(0, 10)
  }
  const part = (type: string) => parts.find((item) => item.type === type)?.value ?? ''
  return `${part('year')}-${part('month')}-${part('day')}`
}

// POS list endpoints answer `{page, pages, count}` (and sometimes `limit`);
// the shared table also wants the row range and neighbours.
export function tableMeta(
  meta: { page?: number; pages?: number; count?: number; limit?: number } | undefined,
  rows: number,
  fallbackLimit: number,
): PaginationMeta {
  const limit = Math.max(1, Number(meta?.limit) || fallbackLimit)
  const count = Math.max(0, Number(meta?.count) || 0)
  const pages = Math.max(1, Number(meta?.pages) || Math.ceil(count / limit) || 1)
  const page = Math.min(Math.max(1, Number(meta?.page) || 1), pages)
  const from = rows ? (page - 1) * limit + 1 : 0
  return {
    page,
    limit,
    count,
    pages,
    from,
    to: rows ? from + rows - 1 : 0,
    previous: page > 1 ? page - 1 : null,
    next: page < pages ? page + 1 : null,
  }
}

function serialFailure(tooLong: string[], duplicates: string[]): Failure | null {
  if (duplicates.length)
    return { error: 'inventorySerialDuplicate', options: { codes: duplicates.join(', ') } }
  if (tooLong.length)
    return { error: 'inventorySerialTooLong', options: { codes: tooLong.join(', ') } }
  return null
}

// A transfer moves serials by code, or amounts of the chosen lots. Amounts
// typed for lots hidden by the code filter are still sent.
export function transferBody(
  variant: Pick<PosTraceStatus, 'tracked_mode'> | null,
  serialText: string,
  amounts: Record<string, string>,
  lots: Pick<PosLot, 'id' | 'available'>[],
): Built {
  if (!variant) return { error: 'inventoryVariantRequired' }
  if (variant.tracked_mode === 'serial') {
    const parsed = parseSerials(serialText)
    if (parsed.tooLong.length)
      return {
        error: 'inventorySerialTooLong',
        options: { codes: [...parsed.tooLong, ...parsed.duplicates].join(', ') },
      }
    const refused = serialFailure([], parsed.duplicates)
    if (refused) return refused
    if (!parsed.codes.length) return { error: 'inventoryNothingEntered' }
    return { body: { serials: parsed.codes } }
  }
  const picked: { lot_id: string; quantity: number }[] = []
  for (const [lotId, text] of Object.entries(amounts)) {
    if (!text.trim()) continue
    const amount = parseWholeQuantity(text)
    if (amount === null) return { error: 'inventoryQuantityInvalid' }
    const lot = lots.find((row) => row.id === lotId)
    if (lot && amount > lot.available) return { error: 'inventoryQuantityTooMany' }
    picked.push({ lot_id: lotId, quantity: amount })
  }
  return picked.length ? { body: { lots: picked } } : { error: 'inventoryNothingEntered' }
}

export type CountDraft = { counted: string; quarantined: string }

// A count states each counted lot's whole quantity (quarantined units aside),
// or the serials missing from and found on the shelf.
export function countBody(
  variant: Pick<PosTraceStatus, 'tracked_mode'> | null,
  reason: string,
  counted: Record<string, CountDraft>,
  missing: string,
  found: string,
): Built {
  if (!variant) return { error: 'inventoryVariantRequired' }
  if (!reason.trim()) return { error: 'inventoryReasonRequired' }
  if (variant.tracked_mode === 'serial') {
    const gone = parseSerials(missing)
    const extra = parseSerials(found)
    const refused = serialFailure(
      [...gone.tooLong, ...extra.tooLong],
      [...gone.duplicates, ...extra.duplicates],
    )
    if (refused) return refused
    if (gone.codes.some((code) => extra.codes.includes(code)))
      return { error: 'traceReason_duplicate_serial' }
    if (!gone.codes.length && !extra.codes.length) return { error: 'inventoryNothingEntered' }
    return {
      body: {
        ...(gone.codes.length ? { missing_serials: gone.codes } : {}),
        ...(extra.codes.length ? { found_serials: extra.codes } : {}),
      },
    }
  }
  const rows: { lot_id: string; counted: number; counted_quarantined?: number }[] = []
  for (const [lotId, draft] of Object.entries(counted)) {
    if (!draft.counted.trim() && !draft.quarantined.trim()) continue
    if (!draft.counted.trim()) return { error: 'inventoryCountRequired' }
    const value = parseWholeQuantity(draft.counted, true)
    if (value === null) return { error: 'inventoryQuantityInvalid' }
    const held = draft.quarantined.trim() ? parseWholeQuantity(draft.quarantined, true) : null
    if (draft.quarantined.trim() && held === null) return { error: 'inventoryQuantityInvalid' }
    rows.push({
      lot_id: lotId,
      counted: value,
      ...(held !== null ? { counted_quarantined: held } : {}),
    })
  }
  return rows.length ? { body: { lots: rows } } : { error: 'inventoryNothingEntered' }
}

// Apply carries the approval it was granted, when one is active.
export function adjustmentCommandBody(
  adjustment: Pick<PosAdjustment, 'approval'>,
  action: 'approve' | 'apply',
): Record<string, unknown> {
  return action === 'apply' && adjustment.approval?.status === 'active'
    ? { approval_id: adjustment.approval.id }
    : {}
}
