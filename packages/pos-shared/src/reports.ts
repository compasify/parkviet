// Report types, rows and the date rules the report screens apply before
// asking the server. Shared by the POS app and the POS administration app.

export const REPORT_TYPES = [
  'sales',
  'receipts',
  'cashbook',
  'receivables',
  'closures',
  'ingredient_usage',
  'menu_margin',
] as const;
export type ReportType = (typeof REPORT_TYPES)[number];

// Reports read from recipe consumptions, listed while the branch runs recipes.
export const RECIPE_REPORT_TYPES: readonly ReportType[] = ['ingredient_usage', 'menu_margin'];

export function reportTypesFor(modules: Record<string, boolean> | null | undefined): ReportType[] {
  return REPORT_TYPES.filter(
    (type) => !RECIPE_REPORT_TYPES.includes(type) || modules?.['fnb.recipes'] === true,
  );
}

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

// Report dates are branch days, entered as YYYY-MM-DD.
export function validReportRange(from: string, to: string, maxDays = 366): boolean {
  const pattern = /^\d{4}-\d{2}-\d{2}$/;
  if (!pattern.test(from) || !pattern.test(to)) return false;
  const start = Date.parse(`${from}T00:00:00Z`);
  const end = Date.parse(`${to}T00:00:00Z`);
  if (Number.isNaN(start) || Number.isNaN(end) || end < start) return false;
  return (end - start) / 86_400_000 < maxDays;
}

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

// Today's date in a timezone, as YYYY-MM-DD.
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
