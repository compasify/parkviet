import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'

// Refusals the e-invoice endpoints explain with a reason of their own.
const REASONS = [
  'einvoice_buyer_invalid',
  'einvoice_setting_invalid',
  'einvoice_provider_unknown',
  'einvoice_not_configured',
  'store_profile_required',
  'einvoice_sample_sandbox_only',
  'einvoice_sample_failed',
  'einvoice_issuing',
  'einvoice_already_issued',
  'einvoice_replacement_pending',
  'einvoice_reason_required',
  'einvoice_not_issued',
  'einvoice_type_invalid',
]

function detailField(error: unknown): string | null {
  if (typeof error !== 'object' || error === null || !('details' in error)) return null
  const details = error.details
  if (typeof details !== 'object' || details === null || !('field' in details)) return null
  return typeof details.field === 'string' ? details.field : null
}

export function einvoiceFailure(
  error: unknown,
  t: (key: string, options?: Record<string, unknown>) => string,
) {
  const reason = conflictReason(error)
  if (reason && REASONS.includes(reason)) {
    const field = detailField(error)
    return t(`einvoices.failure_${reason}`, {
      field: field ? t(`einvoices.field_${field}`, { defaultValue: field }) : '',
    })
  }
  return describeFailure(error, t)
}
