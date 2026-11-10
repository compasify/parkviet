import { describe, expect, it } from 'vitest';
import {
  absoluteAmount,
  addsDrawerCash,
  blockedChecklist,
  canMoveCash,
  canReconcileCash,
  checklistTarget,
  describeShiftFailure,
  isOutflow,
  outcomeNeedsReference,
  outcomeTakesShift,
  reconcileAmountError,
  varianceKind,
  wholeAmount,
} from './shifts';

const conflict = (details: Record<string, unknown>) => ({ status: 409, details });

describe('shift close helpers', () => {
  it('names the variance direction so it is not shown by colour alone', () => {
    expect(varianceKind('-10000.0')).toBe('short');
    expect(varianceKind('5000.0')).toBe('over');
    expect(varianceKind('0.0')).toBe('even');
    expect(varianceKind('-0.0')).toBe('even');
    expect(varianceKind(null)).toBeNull();
    expect(varianceKind('abc')).toBeNull();
    expect(absoluteAmount('-10000.0')).toBe('10000.0');
    expect(absoluteAmount('10000.0')).toBe('10000.0');
  });

  it('reads the checklist from a blocked count and maps reasons to Vietnamese copy', () => {
    const checklist = { blocking: [{ type: 'tender_attempt', status: 'prepared' }], warnings: [] };
    expect(blockedChecklist(conflict({ reason: 'close_blocked', checklist }))).toEqual(checklist);
    expect(blockedChecklist(conflict({ reason: 'shift_closed' }))).toBeNull();
    expect(blockedChecklist({ status: 422 })).toBeNull();
    const translate = (key: string) => `[${key}]`;
    expect(describeShiftFailure(conflict({ reason: 'insufficient_cash' }), translate)).toBe(
      '[shiftReason_insufficient_cash]',
    );
    // An unknown server message never reaches the cashier verbatim.
    const unknown = {
      status: 409,
      message: 'Some English text',
      details: { reason: 'something_else' },
    };
    expect(describeShiftFailure(unknown, translate)).toBe('[shiftFailureGeneric]');
    expect(describeShiftFailure({ status: 403 }, translate)).toBe('[forbidden]');
  });

  it('sends each blocking item to the screen that resolves it', () => {
    expect(
      checklistTarget({ type: 'tender_attempt', status: 'prepared', workspace_id: 'ws_1' }),
    ).toEqual({ to: '/', workspaceId: 'ws_1' });
    expect(
      checklistTarget({ type: 'workspace_money', status: 'parked', workspace_id: 'ws_2' }),
    ).toEqual({ to: '/', workspaceId: 'ws_2' });
    expect(
      checklistTarget({ type: 'liability_payout', status: 'unknown', funds_id: 'posfunds_1' }),
    ).toEqual({ to: 'dashboard', path: 'funds', search: { fundsId: 'posfunds_1' } });
    expect(
      checklistTarget({ type: 'refund_request', status: 'unknown', return_id: 'posreturn_1' }),
    ).toEqual({ to: '/returns', search: { returnId: 'posreturn_1' } });
    expect(checklistTarget({ type: 'cash_movement_request', status: 'requested' })).toEqual({
      to: '/shifts',
    });
    expect(checklistTarget({ type: 'draft', status: 'parked', workspace_id: 'ws_3' })).toBeNull();
  });

  it('caps a closure-only reconciliation at the unexplained overage', () => {
    expect(wholeAmount('100000.0')).toBe(100000n);
    expect(wholeAmount('1.5')).toBeNull();
    expect(reconcileAmountError('', null, '100000.0')).toBe('shiftReason_amount_invalid');
    expect(reconcileAmountError('0', '0', '100000.0')).toBe('shiftReason_amount_invalid');
    expect(reconcileAmountError('150.000', '150000', '100000.0')).toBe(
      'shiftReason_exceeds_variance',
    );
    expect(reconcileAmountError('60.000', '60000', '100000.0')).toBeNull();
  });

  it('only adds drawer cash for cash newly put into an open drawer', () => {
    expect(addsDrawerCash('new_physical_inflow')).toBe(true);
    expect(addsDrawerCash('in_opening_float')).toBe(false);
    expect(addsDrawerCash('safe')).toBe(false);
    expect(addsDrawerCash('handed_over')).toBe(false);
    expect(outcomeNeedsReference('safe')).toBe(true);
    expect(outcomeNeedsReference('handed_over')).toBe(true);
    expect(outcomeNeedsReference('in_opening_float')).toBe(false);
    expect(outcomeTakesShift('in_opening_float')).toBe(true);
    expect(outcomeTakesShift('safe')).toBe(false);
    expect(isOutflow('cash_in')).toBe(false);
    expect(isOutflow('safe_drop')).toBe(true);
  });

  it('gates drawer and reconciliation actions by capability', () => {
    expect(canMoveCash(['pos.cash.move'])).toBe(true);
    expect(canMoveCash(['pos.shift.open'])).toBe(false);
    expect(canReconcileCash(['pos.approval.grant'])).toBe(false);
    expect(canReconcileCash(['pos.approval.grant', 'pos.payment.resolve'])).toBe(true);
  });
});
