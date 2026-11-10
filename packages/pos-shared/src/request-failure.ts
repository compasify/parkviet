import { isPosFeature } from './pos-features';
import { moduleTextKey } from './pos-modules';

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

// The machine-readable reason of a 409 conflict, when the server gave one.
export function conflictReason(error: unknown): string | null {
  if (
    statusOf(error) !== 409 ||
    typeof error !== 'object' ||
    error === null ||
    !('details' in error)
  )
    return null;
  const details = error.details;
  if (typeof details !== 'object' || details === null || !('reason' in details)) return null;
  return typeof details.reason === 'string' ? details.reason : null;
}

// The browser could not persist a financial intent before sending it.
export const FINANCIAL_STORAGE_UNAVAILABLE = 'financial-storage-unavailable';

export function financialStorageFailure(error: unknown): boolean {
  return error instanceof Error && error.message === FINANCIAL_STORAGE_UNAVAILABLE;
}

// The server answered the command itself with a client error, so its
// transaction rolled back. Transport failures, timeouts and 5xx stay unknown.
export function definitiveRejection(error: unknown): boolean {
  const status = statusOf(error);
  return status !== undefined && status >= 400 && status < 500 && status !== 408;
}

export function failureStatus(error: unknown): number | undefined {
  return statusOf(error);
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

// The SDK substitutes this text when the response body carried no error object.
const GENERIC_SDK_MESSAGE = /^Request failed with status \d+$/;
const MAX_DETAIL_LENGTH = 500;

function detailMessages(details: unknown): string[] {
  if (typeof details !== 'object' || details === null) return [];
  return Object.entries(details).flatMap(([field, entries]) => {
    if (!Array.isArray(entries)) return [];
    return entries.flatMap((entry: unknown) => {
      const text =
        typeof entry === 'string'
          ? entry
          : typeof entry === 'object' &&
              entry !== null &&
              'message' in entry &&
              typeof entry.message === 'string'
            ? entry.message
            : '';
      if (!text.trim()) return [];
      return [field === 'base' ? text.trim() : `${field}: ${text.trim()}`];
    });
  });
}

// For conflicts and validation failures the server explains what went wrong;
// show that text instead of a fixed bucket. Other statuses stay generic.
export function serverFailureDetail(error: unknown): string | null {
  const status = statusOf(error);
  if ((status !== 409 && status !== 422) || typeof error !== 'object' || error === null)
    return null;
  const raw = 'message' in error && typeof error.message === 'string' ? error.message.trim() : '';
  const message = GENERIC_SDK_MESSAGE.test(raw) ? '' : raw;
  const details = 'details' in error ? detailMessages(error.details) : [];
  const parts = [...new Set([message, ...details].filter(Boolean))];
  if (!parts.length) return null;
  const text = parts.join(' ');
  return text.length > MAX_DETAIL_LENGTH ? `${text.slice(0, MAX_DETAIL_LENGTH - 1)}…` : text;
}

// One wording for every workspace command: lease problems use the lease
// guidance, otherwise the server's own explanation, otherwise a local message.
export function describeFailure(
  error: unknown,
  translate: (key: string) => string,
  fallbackKey?: string,
): string {
  if (financialStorageFailure(error)) return translate('financialStorageUnavailable');
  const lease = leaseConflict(error);
  if (lease) return translate(lease.reason === 'lease_busy' ? 'leaseBusy' : 'leaseStale');
  if (snapshotLocked(error)) return translate('editLockedPayments');
  const channelReason = conflictReason(error);
  if (
    channelReason &&
    [
      'pos_channel_missing',
      'pos_channel_inactive',
      'pos_channel_mismatch',
      'pos_product_unavailable',
    ].includes(channelReason)
  )
    return translate(channelReason);
  const disabled = featureDisabledText(error, translate) ?? moduleDisabledText(error, translate);
  if (disabled) return disabled;
  return serverFailureDetail(error) ?? translate(fallbackKey ?? posFailureKey(error));
}

// A manager switched the feature off for this branch: the server refused the
// command before recording anything. Every describer of this app uses this text.
export function featureDisabledText(
  error: unknown,
  translate: (key: string) => string,
): string | null {
  if (conflictReason(error) !== 'feature_disabled') return null;
  const details = (error as { details?: { feature?: unknown } }).details;
  const feature = details?.feature;
  return isPosFeature(feature)
    ? translate(`featureDisabled_${feature}`)
    : translate('featureDisabled');
}

// The branch has the module of a setup command off (409 `module_disabled`,
// `details.module`): nothing was recorded. Selling never gets this refusal.
export function moduleDisabledText(
  error: unknown,
  translate: (key: string) => string,
): string | null {
  if (conflictReason(error) !== 'module_disabled') return null;
  const details = (error as { details?: { module?: unknown } }).details;
  const text = typeof details?.module === 'string' ? moduleTextKey(details.module) : null;
  return translate(text ? `posModules.${text}.disabled` : 'moduleDisabled');
}

// The server froze the basket because a tender is prepared or a payment exists.
export function snapshotLocked(error: unknown): boolean {
  if (statusOf(error) !== 409 || typeof error !== 'object' || error === null) return false;
  const details = 'details' in error ? error.details : undefined;
  return (
    typeof details === 'object' &&
    details !== null &&
    'reason' in details &&
    details.reason === 'snapshot_locked'
  );
}
