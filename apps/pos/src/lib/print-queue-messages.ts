import type { TFunction } from 'i18next';
import { conflictReason } from './request-failure';

const REFUSALS: Record<string, string> = {
  printer_disabled: 'printRefused_disabled',
  printer_station_unavailable: 'printRefused_station',
  printer_wrong_kind: 'printRefused_kind',
  print_job_already_reprinted: 'printRefused_reprinted',
};

// Why the server would not take a print, when it is about the printer or job.
export function printRefusal(failure: unknown, t: TFunction): string | null {
  const key = REFUSALS[conflictReason(failure) ?? ''];
  return key ? t(key) : null;
}
