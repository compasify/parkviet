import { describe, expect, it } from 'vitest';
import { approvalRequestBody, askFromFailure, normalizeApprovalRequest } from './approval-requests';

const refusal = (details: Record<string, unknown>) => ({ status: 409, details });

describe('askFromFailure', () => {
  it('asks for the action, revision and amount an order command was refused for', () => {
    expect(
      askFromFailure(
        refusal({
          reason: 'approval_required',
          action: 'workspace.apply_discount',
          amount: '20000.0',
          current_revision: 7,
        }),
      ),
    ).toEqual({ action: 'workspace.apply_discount', revision: '7', amount: '20000.0' });
  });

  it('reads the revision a record approved on its own names', () => {
    expect(
      askFromFailure(
        refusal({ reason: 'approval_required', action: 'bottle_keep.adjust', revision: 3 }),
      ),
    ).toEqual({ action: 'bottle_keep.adjust', revision: '3' });
  });

  it('falls back to what the form knows, and asks nothing for another refusal', () => {
    expect(
      askFromFailure(refusal({ reason: 'approval_required', action: 'kitchen.void_sent' }), {
        revision: '4',
      }),
    ).toEqual({ action: 'kitchen.void_sent', revision: '4' });
    expect(askFromFailure(refusal({ reason: 'lease_busy', current_revision: 2 }))).toBeNull();
    expect(askFromFailure(new Error('offline'))).toBeNull();
  });
});

describe('approvalRequestBody', () => {
  it('names the branch, the subject and what to approve, with a short reason', () => {
    expect(
      approvalRequestBody(
        'posbranch_1',
        { reservation_id: 'posres_1' },
        { action: 'reservation.refund_deposit', revision: '2', amount: '100000.0' },
        `  ${'x'.repeat(250)} `,
      ),
    ).toEqual({
      branch_id: 'posbranch_1',
      reservation_id: 'posres_1',
      action_name: 'reservation.refund_deposit',
      revision: '2',
      amount: '100000.0',
      reason: 'x'.repeat(200),
    });
  });
});

describe('normalizeApprovalRequest', () => {
  it('keeps what the counter shows and drops a malformed answer', () => {
    expect(
      normalizeApprovalRequest({
        id: 'posapprovalreq_1',
        action: 'kitchen.void_sent',
        status: 'granted',
        approval_id: 'posappr_1',
        reason: null,
        decided_by_name: 'Chủ',
        expires_at: '2026-11-12T10:10:00Z',
        requester_name: 'ignored',
      }),
    ).toEqual({
      id: 'posapprovalreq_1',
      action: 'kitchen.void_sent',
      status: 'granted',
      approval_id: 'posappr_1',
      reason: null,
      decided_by_name: 'Chủ',
      expires_at: '2026-11-12T10:10:00Z',
    });
    expect(normalizeApprovalRequest({ id: 'x', action: 'a', status: 'lost' })).toBeNull();
  });
});
