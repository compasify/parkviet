import { describe, expect, it } from 'vitest'
import { exportFileUrl } from './report-download'
import {
  dashboardReportTypes,
  dayText,
  exportFilters,
  knownShifts,
  matchesTerm,
  RETURN_COLUMNS,
  reportColumns,
  reportFigures,
  reportPagination,
  reportRequest,
  summaryEntries,
} from './report-table'

describe('report requests', () => {
  it('sends today, the shared filters and only the filters of the open report', () => {
    const request = reportRequest(
      'sales',
      { registerId: 'reg_1', mine: true, section: 'returns', kind: 'cash', orderSource: 'zalo' },
      '2026-11-10',
      'staff_1',
    )
    expect(request.rangeValid).toBe(true)
    expect(request.filters).toEqual({
      from: '2026-11-10',
      to: '2026-11-10',
      register_id: 'reg_1',
      cashier_id: 'staff_1',
      section: 'returns',
      order_source: 'zalo',
    })
  })

  it('leaves the day range off receivables and pages the cashbook shift summary', () => {
    expect(
      reportRequest('receivables', { from: '2026-11-01', status: 'overdue' }, '2026-11-10', 's')
        .filters,
    ).toEqual({ status: 'overdue' })
    const cashbook = reportRequest('cashbook', { shiftPage: 2, shiftId: 'sh_1' }, '2026-11-10', 's')
    expect(cashbook.filters).toMatchObject({ shift_id: 'sh_1', shift_page: '2' })
    expect(exportFilters(cashbook.filters)).toEqual({
      from: '2026-11-10',
      to: '2026-11-10',
      shift_id: 'sh_1',
    })
  })

  it('sends the meal result and waits for a sponsor on the statement', () => {
    const day = '2026-11-10'
    const meals = reportRequest('meals', { result: 'duplicate', sponsorId: 's1' }, day, 's')
    expect(meals.filters).toEqual({ from: day, to: day, result: 'duplicate' })
    expect(meals.needsSponsor).toBe(false)
    const waiting = reportRequest('meal_statement', { result: 'ok' }, day, 's')
    expect(waiting.needsSponsor).toBe(true)
    expect(waiting.filters).not.toHaveProperty('result')
    const statement = reportRequest('meal_statement', { sponsorId: 's1' }, day, 's')
    expect(statement.needsSponsor).toBe(false)
    expect(statement.filters).toMatchObject({ meal_sponsor_id: 's1' })
  })

  it('lists the canteen reports while the branch runs meal accounts', () => {
    const modules = { 'fnb.meal_accounts': true }
    expect(dashboardReportTypes(modules, true)).toEqual(
      expect.arrayContaining(['sales', 'meals', 'meal_statement']),
    )
    expect(dashboardReportTypes(modules, false)).not.toContain('meal_statement')
    expect(dashboardReportTypes({}, true)).not.toContain('meals')
  })

  it('refuses a reversed or too long range', () => {
    expect(
      reportRequest('receipts', { from: '2026-11-10', to: '2026-11-01' }, 'x', 's').rangeValid,
    ).toBe(false)
    expect(
      reportRequest('receipts', { from: '2025-01-01', to: '2026-11-01' }, 'x', 's').rangeValid,
    ).toBe(false)
  })
})

describe('report presentation', () => {
  it('uses the returns columns for the returns section of sales only', () => {
    expect(reportColumns('sales', 'returns')).toBe(RETURN_COLUMNS)
    expect(reportColumns('receipts', 'returns')).not.toBe(RETURN_COLUMNS)
  })

  it('fills the shared pagination from the report meta', () => {
    expect(reportPagination({ page: 2, pages: 3, count: 120, limit: 50 }, 50)).toEqual({
      page: 2,
      limit: 50,
      count: 120,
      pages: 3,
      from: 51,
      to: 100,
      previous: 1,
      next: 3,
    })
    expect(reportPagination({ page: 1, pages: 0, count: 0, limit: 50 }, 0)).toMatchObject({
      from: 0,
      to: 0,
      previous: null,
      next: null,
    })
  })

  it('keeps plain summary figures and drops lists and shift paging', () => {
    expect(
      summaryEntries({
        orders: 2,
        total: '1.0',
        shifts: [],
        shift_page: 1,
        shift_pages: 2,
        shift_count: 3,
      }),
    ).toEqual([
      ['orders', 2],
      ['total', '1.0'],
      ['shift_count', 3],
    ])
  })

  it('shows each refusal reason of the meals summary as its own figure', () => {
    const summary = { meals: 12, refused: { duplicate: 2, limit: 1 } }
    expect(summaryEntries(reportFigures('meals', summary))).toEqual([
      ['meals', 12],
      ['refused_duplicate', 2],
      ['refused_limit', 1],
    ])
    expect(reportFigures('sales', summary)).toBe(summary)
  })

  it('collects each shift once across cashbook pages', () => {
    const line = (shift_id: string) => ({ shift_id, cashier: 'Lan' })
    expect(
      knownShifts([{ shifts: [line('a')] }, undefined, { shifts: [line('b'), line('a')] }]).map(
        (row) => row.shift_id,
      ),
    ).toEqual(['a', 'b'])
  })

  it('formats days, narrows rows by text and resolves export links on the API', () => {
    expect(dayText('2026-11-07')).toBe('07/11/2026')
    expect(matchesTerm({ order_number: 'R100', total: '1.0' }, 'r10')).toBe(true)
    expect(matchesTerm({ order_number: 'R100' }, 'zzz')).toBe(false)
    expect(exportFileUrl('/api/v3/admin/pos/export_files/x', 'https://api.test')).toBe(
      'https://api.test/api/v3/admin/pos/export_files/x',
    )
    expect(exportFileUrl('https://cdn.test/f.csv', 'https://api.test')).toBe(
      'https://cdn.test/f.csv',
    )
  })
})
