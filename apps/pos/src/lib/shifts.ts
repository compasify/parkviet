import type { ChecklistItem } from '@parkviet/pos-shared/shifts';
import { readLayout, writeLayout } from './workspace-storage';

// Shift types, drawer and reconciliation rules are shared with the POS
// administration app; reports and counter navigation stay here.
export * from '@parkviet/pos-shared/shifts';

export const REPORT_TYPES = ['sales', 'receipts', 'cashbook', 'receivables', 'closures'] as const;
export type ReportType = (typeof REPORT_TYPES)[number];

export type ReportRow = Record<string, string | number | boolean | null>;

export type ReportPage = {
  data: ReportRow[];
  meta: {
    page: number;
    pages: number;
    count: number;
    limit: number;
    scope: 'branch' | 'own';
    timezone: string;
    from: string | null;
    to: string | null;
    summary: Record<string, unknown>;
  };
};

export type ExportRequest = {
  id: string;
  branch_id: string;
  report_type: ReportType;
  filters: Record<string, string>;
  status: 'queued' | 'processing' | 'ready' | 'failed' | 'expired';
  row_count: number | null;
  error_message: string | null;
  expires_at: string;
  completed_at: string | null;
  created_at: string | null;
};

export function canExportReports(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.includes('pos.report.export'));
}

// Any branch member reads reports (their own shifts unless they hold report access).
export function canOpenReports(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities && capabilities.length > 0);
}

// Where a checklist item sends the cashier: the sale screen with that draft
// as the active tab, the received-funds item, the return, or this page.
export type ChecklistTarget =
  | { to: '/'; workspaceId: string }
  | { to: '/funds'; search: { fundsId: string } }
  | { to: '/returns'; search: { returnId: string } }
  | { to: '/shifts' };

export function checklistTarget(item: ChecklistItem): ChecklistTarget | null {
  if (item.type === 'liability_payout' && item.funds_id)
    return { to: '/funds', search: { fundsId: item.funds_id } };
  if (item.type === 'refund_request' && item.return_id)
    return { to: '/returns', search: { returnId: item.return_id } };
  if (item.type === 'cash_movement_request') return { to: '/shifts' };
  if ((item.type === 'tender_attempt' || item.type === 'workspace_money') && item.workspace_id)
    return { to: '/', workspaceId: item.workspace_id };
  return null;
}

// Makes a draft the active tab the next time the sale screen opens (the tabs
// restore the remembered view of this branch and register).
export function activateWorkspaceTab(
  scope: { staffId: string; storeId: string; branchId: string; registerId: string | null },
  workspaceId: string,
) {
  const current = readLayout(scope.staffId, scope.storeId);
  const sameContext =
    current?.branchId === scope.branchId && current.registerId === scope.registerId;
  writeLayout({
    staffId: scope.staffId,
    storeId: scope.storeId,
    savedAt: Date.now(),
    branchId: scope.branchId,
    registerId: scope.registerId,
    openWorkspaceIds: [
      workspaceId,
      ...(sameContext ? current.openWorkspaceIds.filter((id) => id !== workspaceId) : []),
    ],
    closedWorkspaceIds: sameContext
      ? (current.closedWorkspaceIds ?? []).filter((id) => id !== workspaceId)
      : [],
    activeWorkspaceId: workspaceId,
    workspacePage: 1,
    tabNumbers: sameContext ? current.tabNumbers : undefined,
  });
}

// Report dates are branch days, entered as YYYY-MM-DD.
export function validReportRange(from: string, to: string, maxDays = 366): boolean {
  const pattern = /^\d{4}-\d{2}-\d{2}$/;
  if (!pattern.test(from) || !pattern.test(to)) return false;
  const start = Date.parse(`${from}T00:00:00Z`);
  const end = Date.parse(`${to}T00:00:00Z`);
  if (Number.isNaN(start) || Number.isNaN(end) || end < start) return false;
  return (end - start) / 86_400_000 < maxDays;
}

// Today's date in a timezone, as YYYY-MM-DD.
// Business date in a timezone: a wall-clock time before the cutoff (04:00
// unless the branch says otherwise) belongs to the previous date.
export function businessDate(timeZone: string, cutoff = '04:00', now = new Date()): string {
  const parts = new Intl.DateTimeFormat('en-GB', {
    timeZone,
    hourCycle: 'h23',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  }).formatToParts(now);
  const part = (type: string) => parts.find((item) => item.type === type)?.value ?? '';
  const date = `${part('year')}-${part('month')}-${part('day')}`;
  const [hour, minute] = cutoff.split(':');
  const cutoffMinutes = (Number(hour) || 0) * 60 + (Number(minute) || 0);
  const minutes = (Number(part('hour')) || 0) * 60 + (Number(part('minute')) || 0);
  if (minutes >= cutoffMinutes) return date;
  const previous = new Date(`${date}T00:00:00Z`);
  previous.setUTCDate(previous.getUTCDate() - 1);
  return previous.toISOString().slice(0, 10);
}

export function todayIn(timeZone: string, now = new Date()): string {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(now);
  const part = (type: string) => parts.find((item) => item.type === type)?.value ?? '';
  return `${part('year')}-${part('month')}-${part('day')}`;
}

// Formats an instant in the given timezone (the branch's, from the server).
export function formatInZone(value: string | null | undefined, locale: string, timeZone: string) {
  if (!value) return '—';
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString(locale, { timeZone });
}

// Starts a browser download of a signed export link; the file streams from
// the server and is never held in page memory.
export function startDownload(url: string, filename: string) {
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.rel = 'noopener';
  document.body.append(link);
  link.click();
  link.remove();
}
