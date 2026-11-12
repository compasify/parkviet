import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosTimedSegment } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { approvalAction } from '../lib/tables';
import { fromLocalInput, timedFailureKey, toLocalInput } from '../lib/timed-clock';
import { PosIcon } from './pos-icon';

export type SegmentEditInput = {
  started_at?: string;
  ended_at?: string;
  reason: string;
  approval_id?: string;
};

// Corrects when one stretch of a room's clock started or ended: a clock
// started late or left running. It needs a reason and, for someone who may
// not correct times, the code of a manager's approval. A running stretch only
// moves its start; the server refuses times later than its own clock.
export function SegmentEditDialog({
  segment,
  canEdit,
  onSave,
  onClose,
}: {
  segment: PosTimedSegment;
  // The person may correct times without an approval.
  canEdit: boolean;
  onSave: (input: SegmentEditInput) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  useModalFocus(card, onClose);
  const running = segment.ended_at === null;
  const [start, setStart] = useState(() => toLocalInput(segment.started_at));
  const [end, setEnd] = useState(() => toLocalInput(segment.ended_at));
  const [reason, setReason] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [needsApproval, setNeedsApproval] = useState(!canEdit);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const startChanged = start !== toLocalInput(segment.started_at);
  const endChanged = !running && end !== toLocalInput(segment.ended_at);
  const valid =
    (startChanged || endChanged) &&
    (!startChanged || fromLocalInput(start) !== null) &&
    (!endChanged || fromLocalInput(end) !== null) &&
    reason.trim().length > 0 &&
    (!needsApproval || approvalId.trim().length > 0);

  async function submit() {
    if (!valid || busy) return;
    setBusy(true);
    setError('');
    try {
      await onSave({
        ...(startChanged ? { started_at: fromLocalInput(start) as string } : {}),
        ...(endChanged ? { ended_at: fromLocalInput(end) as string } : {}),
        reason: reason.trim(),
        ...(approvalId.trim() ? { approval_id: approvalId.trim() } : {}),
      });
      onClose();
    } catch (failure) {
      if (approvalAction(failure)) {
        setNeedsApproval(true);
        setError(t('timedEditNeedsApproval'));
      } else {
        const key = timedFailureKey(conflictReason(failure));
        setError(key ? t(key) : describeFailure(failure, t));
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card segment-edit-dialog"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('timedEditTitle', { room: segment.resource_name ?? '' })}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <form
          className="void-item-form"
          onSubmit={(event) => {
            event.preventDefault();
            void submit();
          }}
        >
          <label>
            {t('timedEditStart')}
            <input
              type="datetime-local"
              value={start}
              required
              onChange={(event) => setStart(event.target.value)}
            />
          </label>
          {running ? (
            <p className="muted">{t('timedEditRunningHint')}</p>
          ) : (
            <label>
              {t('timedEditEnd')}
              <input
                type="datetime-local"
                value={end}
                required
                onChange={(event) => setEnd(event.target.value)}
              />
            </label>
          )}
          <label>
            {t('timedEditReason')}
            <input
              value={reason}
              maxLength={200}
              required
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          {needsApproval ? (
            <label>
              {t('timedEditApproval')}
              <input
                value={approvalId}
                required
                onChange={(event) => setApprovalId(event.target.value)}
              />
            </label>
          ) : null}
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <div className="row">
            <button type="button" onClick={onClose}>
              {t('timedEditCancel')}
            </button>
            <button type="submit" className="primary-button" disabled={!valid || busy}>
              {t('timedEditSubmit')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
