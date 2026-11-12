// Asking a manager on their own phone for the approval a command was refused
// for, instead of the manager walking over to type a code. The grant is an
// ordinary approval bound to the subject as it was when asked, spent like a
// typed code.

export type ApprovalRequestStatus = 'pending' | 'granted' | 'declined' | 'expired' | 'canceled';

export type ApprovalRequest = {
  id: string;
  action: string;
  status: ApprovalRequestStatus;
  approval_id: string | null;
  reason: string | null;
  decided_by_name: string | null;
  expires_at: string;
};

// What the approval is bound to: an order, or one of the records approved on
// their own.
export type ApprovalSubject =
  | { workspace_id: string }
  | { reservation_id: string }
  | { bottle_keep_id: string }
  | { meal_account_id: string }
  | { vehicle_visit_id: string }
  | { stored_value_account_id: string };

export type ApprovalAsk = {
  action: string;
  revision: string;
  amount?: string;
};

const STATUSES: readonly ApprovalRequestStatus[] = [
  'pending',
  'granted',
  'declined',
  'expired',
  'canceled',
];

function text(value: unknown): string | null {
  return typeof value === 'string' && value !== '' ? value : null;
}

export function normalizeApprovalRequest(value: unknown): ApprovalRequest | null {
  if (typeof value !== 'object' || value === null) return null;
  const row = value as Record<string, unknown>;
  const id = text(row.id);
  const action = text(row.action);
  const status = STATUSES.find((item) => item === row.status);
  if (!id || !action || !status) return null;
  return {
    id,
    action,
    status,
    approval_id: text(row.approval_id),
    reason: text(row.reason),
    decided_by_name: text(row.decided_by_name),
    expires_at: text(row.expires_at) ?? '',
  };
}

// What to ask for, from the `approval_required` refusal of an order command:
// its action, the order's revision and the amount it named. A record approved
// on its own passes its action and revision instead.
export function askFromFailure(
  failure: unknown,
  fallback?: Partial<ApprovalAsk>,
): ApprovalAsk | null {
  const details =
    typeof failure === 'object' && failure !== null && 'details' in failure
      ? (failure as { details?: Record<string, unknown> }).details
      : undefined;
  const fromFailure = details?.reason === 'approval_required' ? details : undefined;
  const action = text(fromFailure?.action) ?? fallback?.action;
  // An order names its revision `current_revision`; a record approved on its own, `revision`.
  const revisionValue =
    fromFailure?.current_revision ?? fromFailure?.revision ?? fallback?.revision;
  const revision =
    typeof revisionValue === 'number' || typeof revisionValue === 'string'
      ? String(revisionValue)
      : null;
  if (!action || !revision) return null;
  const amount = text(fromFailure?.amount) ?? fallback?.amount;
  return amount ? { action, revision, amount } : { action, revision };
}

export function approvalRequestBody(
  branchId: string,
  subject: ApprovalSubject,
  ask: ApprovalAsk,
  reason?: string,
): Record<string, string> {
  return {
    branch_id: branchId,
    ...subject,
    action_name: ask.action,
    revision: ask.revision,
    ...(ask.amount ? { amount: ask.amount } : {}),
    ...(reason?.trim() ? { reason: reason.trim().slice(0, 200) } : {}),
  };
}
