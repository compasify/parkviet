export type PosFailure =
  | 'unauthorized'
  | 'forbidden'
  | 'invalid'
  | 'missing'
  | 'conflict'
  | 'offline';

export function posFailureKey(error: unknown): PosFailure {
  const status = statusOf(error);
  if (status === 401) return 'unauthorized';
  if (status === 403) return 'forbidden';
  if (status === 404) return 'missing';
  if (status === 409) return 'conflict';
  if (status === 422) return 'invalid';
  return 'offline';
}

export function leaseConflict(
  error: unknown,
): { reason: 'lease_busy' | 'lease_stale'; seconds: number } | null {
  if (
    statusOf(error) !== 409 ||
    typeof error !== 'object' ||
    error === null ||
    !('details' in error)
  )
    return null;
  const details = error.details;
  if (typeof details !== 'object' || details === null || !('reason' in details)) return null;
  if (details.reason !== 'lease_busy' && details.reason !== 'lease_stale') return null;
  const seconds =
    'retry_after_seconds' in details &&
    typeof details.retry_after_seconds === 'number' &&
    Number.isFinite(details.retry_after_seconds)
      ? Math.min(120, Math.max(1, Math.ceil(details.retry_after_seconds)))
      : 120;
  return { reason: details.reason, seconds };
}

function statusOf(error: unknown): number | undefined {
  if (typeof error !== 'object' || error === null) return undefined;
  if ('status' in error && typeof error.status === 'number') return error.status;
  if (
    'response' in error &&
    typeof error.response === 'object' &&
    error.response !== null &&
    'status' in error.response
  ) {
    const status = error.response.status;
    if (typeof status === 'number') return status;
  }
  return undefined;
}
