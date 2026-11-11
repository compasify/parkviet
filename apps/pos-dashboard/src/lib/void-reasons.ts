// The reasons a branch offers unless it sets its own; `khac` (other) is
// always offered on the device and `platform_canceled` is the system's.
export const KNOWN_VOID_REASONS = ['khach_doi_y', 'het_mon', 'nhap_nham', 'lam_hong'] as const
export const RESERVED_VOID_REASONS: readonly string[] = ['khac', 'platform_canceled']

// A typed reason becomes a code: lower case, no accents, words joined by `_`.
export function voidReasonCode(text: string) {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[đĐ]/g, 'd')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 40)
    .replace(/_+$/, '')
}
