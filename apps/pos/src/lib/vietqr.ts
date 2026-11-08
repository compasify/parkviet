// A VietQR tender at the counter. Preparing it reserves a receiving account
// and returns a QR; the server learns about the transfer from the bank's
// webhook (spree_vietqr) and the cashier then confirms the tender with that
// webhook as evidence — or attests the transfer by hand when it never comes.

export type VietqrStatus = 'allocated' | 'confirmed';

// GET /pos/workspaces/:id/tender_attempts/:attempt/vietqr
export type VietqrTenderSummary = {
  status: VietqrStatus;
  amount: string | number;
  currency?: string;
  qr_url?: string | null;
  bank_name?: string | null;
  account_number?: string | null;
  account_name?: string | null;
  transfer_content?: string | null;
  expires_at?: string | null;
  confirmed_at?: string | null;
  attempt_id: string;
  attempt_status: string;
};

export type VietqrEvidenceKind = 'vietqr_webhook' | 'vietqr_manual';

// How often the cashier screen asks whether the bank has reported the money.
export const VIETQR_POLL_MS = 3000;

export function vietqrReceived(summary: VietqrTenderSummary | null | undefined): boolean {
  return summary?.status === 'confirmed';
}

// The evidence to confirm with: the webhook once the bank reported the
// transfer, otherwise the cashier's attestation when they chose to give one.
export function vietqrEvidence(
  summary: VietqrTenderSummary | null | undefined,
  manual: { reference: string; account: string } | null,
):
  | { evidenceKind: 'vietqr_webhook' }
  | { evidenceKind: 'vietqr_manual'; reference: string; receivingAccount: string }
  | null {
  if (vietqrReceived(summary)) return { evidenceKind: 'vietqr_webhook' };
  if (!manual) return null;
  const reference = manual.reference.trim();
  const receivingAccount = manual.account.trim();
  if (reference === '' || receivingAccount === '') return null;
  return { evidenceKind: 'vietqr_manual', reference, receivingAccount };
}

// Whole minutes and seconds left on the QR, or null once it expired.
export function vietqrTimeLeft(expiresAt: string | null | undefined, now: number): string | null {
  if (!expiresAt) return null;
  const left = Math.floor((Date.parse(expiresAt) - now) / 1000);
  if (!Number.isFinite(left) || left <= 0) return null;
  const minutes = Math.floor(left / 60);
  const seconds = String(left % 60).padStart(2, '0');
  return `${minutes}:${seconds}`;
}

export const VIETQR_CONFLICT_REASONS = [
  'vietqr_unavailable',
  'vietqr_provider_error',
  'vietqr_evidence_required',
  'vietqr_missing',
  'vietqr_not_received',
  'vietqr_confirm_failed',
  'vietqr_already_received',
  'vietqr_open',
] as const;

export function vietqrConflictKey(reason: string | null): string | null {
  return reason && (VIETQR_CONFLICT_REASONS as readonly string[]).includes(reason)
    ? `conflictReason_${reason}`
    : null;
}
