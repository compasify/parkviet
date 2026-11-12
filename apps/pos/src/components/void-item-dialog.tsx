import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { KitchenVoidInput } from '../hooks/use-workspaces';
import { type ApprovalAsk, askFromFailure } from '../lib/approval-requests';
import { useModalFocus } from '../lib/dialog-focus';
import { kitchenSent } from '../lib/kitchen';
import type { PosLineItem, PosWorkspace } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { VOID_NOTE_MAX, VOID_OTHER } from '../lib/table-kitchen';
import { approvalAction } from '../lib/tables';

const KITCHEN_VOID_ACTION = 'kitchen.void_sent';

import { PosIcon } from './pos-icon';
import { RemoteApprovalButton } from './remote-approval-button';

// Takes back items the kitchen was told about: how many, why (the branch's
// list, or "other" with a note) and, for someone who may not void, the code
// of a manager's approval, typed in or granted from the manager's phone. The
// station prints a void ticket.
export function VoidItemDialog({
  workspace,
  line,
  reasons,
  canVoid,
  onVoid,
  onClose,
}: {
  // The order, for asking the manager's phone.
  workspace?: PosWorkspace;
  line: PosLineItem;
  reasons: string[];
  // The person may void without an approval.
  canVoid: boolean;
  onVoid: (input: KitchenVoidInput) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  useModalFocus(card, onClose);
  const sent = kitchenSent(line);
  const [quantity, setQuantity] = useState(1);
  const [reason, setReason] = useState(reasons[0] ?? VOID_OTHER);
  const [note, setNote] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [needsApproval, setNeedsApproval] = useState(!canVoid);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [ask, setAsk] = useState<ApprovalAsk | null>(null);
  const noteRequired = reason === VOID_OTHER;
  const valid =
    Number.isInteger(quantity) &&
    quantity >= 1 &&
    quantity <= sent &&
    (!noteRequired || note.trim().length > 0) &&
    (!needsApproval || approvalId.trim().length > 0);

  async function submit(granted?: string) {
    const approval = granted ?? approvalId.trim();
    if (!(valid || (granted && quantity >= 1 && quantity <= sent)) || busy) return;
    setBusy(true);
    setError('');
    try {
      await onVoid({
        quantity,
        reason_code: reason,
        note: note.trim() || undefined,
        approval_id: approval || undefined,
      });
      onClose();
    } catch (failure) {
      if (approvalAction(failure)) {
        setNeedsApproval(true);
        setAsk(
          askFromFailure(failure, { revision: workspace ? String(workspace.revision) : undefined }),
        );
        setError(t('kitchenVoidNeedsApproval'));
      } else {
        const reasonKey = conflictReason(failure);
        setError(
          reasonKey?.startsWith('void_')
            ? t(`kitchenVoidFailure_${reasonKey}`)
            : describeFailure(failure, t),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  // Granted on the manager's phone: the code goes in and the void goes through.
  function granted(id: string) {
    setApprovalId(id);
    void submit(id);
  }
  // Asked before trying, by someone who may not void, the order as it stands.
  const remoteAsk =
    ask ??
    (workspace ? { action: KITCHEN_VOID_ACTION, revision: String(workspace.revision) } : null);

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card void-item-dialog"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('kitchenVoidTitle', { name: line.name })}</h4>
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
          <p className="muted">{t('kitchenVoidSent', { count: sent })}</p>
          <label>
            {t('kitchenVoidQuantity')}
            <input
              type="number"
              inputMode="numeric"
              min={1}
              max={sent}
              value={quantity}
              aria-invalid={!(quantity >= 1 && quantity <= sent)}
              onChange={(event) => setQuantity(Number(event.target.value))}
            />
          </label>
          <fieldset>
            <legend>{t('kitchenVoidReason')}</legend>
            {reasons.map((code) => (
              <label key={code} className="void-reason">
                <input
                  type="radio"
                  name="void-reason"
                  value={code}
                  checked={reason === code}
                  onChange={() => setReason(code)}
                />
                {t(`kitchenVoidReason_${code}`, { defaultValue: code })}
              </label>
            ))}
          </fieldset>
          <label>
            {t(noteRequired ? 'kitchenVoidNoteRequired' : 'kitchenVoidNote')}
            <input
              value={note}
              maxLength={VOID_NOTE_MAX}
              required={noteRequired}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
          {needsApproval ? (
            <label>
              {t('kitchenVoidApproval')}
              <input
                value={approvalId}
                required
                onChange={(event) => setApprovalId(event.target.value)}
              />
            </label>
          ) : null}
          {needsApproval && workspace ? (
            <RemoteApprovalButton
              branchId={workspace.branch_id}
              subject={{ workspace_id: workspace.id }}
              ask={remoteAsk}
              reason={note.trim() || t(`kitchenVoidReason_${reason}`, { defaultValue: reason })}
              onGranted={granted}
            />
          ) : null}
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <div className="row">
            <button type="button" onClick={onClose}>
              {t('kitchenVoidCancel')}
            </button>
            <button type="submit" className="danger" disabled={!valid || busy}>
              {t('kitchenVoidSubmit', { count: quantity })}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
