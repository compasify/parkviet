import { describe, expect, it } from 'vitest';
import {
  businessDate,
  canExportReports,
  canOpenReports,
  formatInZone,
  REPORT_TYPES,
  reportTypesFor,
  todayIn,
  validReportRange,
} from './reports';

describe('report access', () => {
  it('exports only with the export capability and opens for any branch member', () => {
    expect(canExportReports(['pos.report.read'])).toBe(false);
    expect(canExportReports(['pos.report.export'])).toBe(true);
    expect(canExportReports(undefined)).toBe(false);
    expect(canOpenReports(['pos.shift.open'])).toBe(true);
    expect(canOpenReports([])).toBe(false);
    expect(REPORT_TYPES).toEqual([
      'sales',
      'receipts',
      'cashbook',
      'receivables',
      'closures',
      'ingredient_usage',
      'menu_margin',
      'platforms',
    ]);
  });

  it('lists the recipe reports only while the branch runs recipes', () => {
    expect(reportTypesFor({ 'fnb.recipes': false })).toEqual([
      'sales',
      'receipts',
      'cashbook',
      'receivables',
      'closures',
    ]);
    expect(reportTypesFor(undefined)).not.toContain('menu_margin');
    expect(reportTypesFor({ 'fnb.recipes': true })).not.toContain('platforms');
    expect(reportTypesFor({ 'fnb.recipes': true, 'fnb.delivery_platforms': true })).toEqual(
      REPORT_TYPES,
    );
  });

  it('lists the platform report only while the branch takes platform orders', () => {
    expect(reportTypesFor({ 'fnb.delivery_platforms': true })).toContain('platforms');
    expect(reportTypesFor({ 'fnb.delivery_platforms': false })).not.toContain('platforms');
  });
});

describe('report dates', () => {
  it('accepts branch days at most 366 days apart', () => {
    expect(validReportRange('2026-11-01', '2026-11-07')).toBe(true);
    expect(validReportRange('2026-11-07', '2026-11-07')).toBe(true);
    expect(validReportRange('2026-11-07', '2026-11-01')).toBe(false);
    expect(validReportRange('2025-11-01', '2026-11-07')).toBe(false);
    expect(validReportRange('07/11/2026', '2026-11-07')).toBe(false);
  });

  it('takes today in the branch timezone, not the device timezone', () => {
    const instant = new Date('2026-11-06T18:30:00Z');
    expect(todayIn('Asia/Ho_Chi_Minh', instant)).toBe('2026-11-07');
    expect(todayIn('UTC', instant)).toBe('2026-11-06');
  });

  it('rolls the business date at the cutoff', () => {
    const zone = 'Asia/Ho_Chi_Minh';
    expect(businessDate(zone, '04:00', new Date('2026-11-05T20:59:00Z'))).toBe('2026-11-05');
    expect(businessDate(zone, '04:00', new Date('2026-11-05T21:00:00Z'))).toBe('2026-11-06');
    expect(businessDate(zone, '06:30', new Date('2026-11-05T23:29:00Z'))).toBe('2026-11-05');
  });

  it('shows an instant in the branch timezone and a dash when missing', () => {
    expect(formatInZone(null, 'en-GB', 'UTC')).toBe('—');
    expect(formatInZone('not a date', 'en-GB', 'UTC')).toBe('not a date');
    expect(formatInZone('2026-11-06T18:30:00Z', 'en-GB', 'Asia/Ho_Chi_Minh')).toContain(
      '07/11/2026',
    );
  });
});
