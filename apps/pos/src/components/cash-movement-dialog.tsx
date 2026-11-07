import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePostCashMovement } from '../hooks/use-shift-close';
import { useModalFocus } from '../lib/dialog-focus';
import { formatMoney, parseVndInput } from '../lib/money';
import { definitiveRejection } from '../lib/request-failure';
import { type CashMovementKind, describeShiftFailure, isOutflow } from '../lib/shifts';
import { PosIcon } from './pos-icon';

const KINDS: CashMovementKind[] = ['cash_in', 'cash_out', 'safe_drop'];

// Manual drawer movement on the cashier's own open shift: money put in, taken
// out, or dropped into the safe. Always with a reason; it is not a sale and
// not a customer payment. Cash out and safe drops need an evidence reference
// and a second person's confirmation before the drawer changes. One intent
// per dialog: a retry after a lost response rechecks the same key.
export function CashMovementDialog({
  shiftId,
  currency,
  actor,
  onClose,
  onDone,
}: {
  shiftId: string;
  currency: string;
  actor: { staffId: string | null; storeId: string | null };
  onClose: () => void;
  onDone: (message: string) => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const intent = useRef(crypto.randomUUID());
  const [kind, setKind] = useState<CashMovementKind>('cash_in');
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [evidence, setEvidence] = useState('');
  const [error, setError] = useState('');
  const [uncertain, setUncertain] = useState(false);
  const post = usePostCashMovement(actor);
  const busy = post.isPending;
  const parsed = parseVndInput(amount);
  const outflow = isOutflow(kind);

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  function submit() {
    if (busy) return;
    if (parsed === null || parsed === '0') {
      setError(t('shiftAmountInvalid'));
      return;
    }
    if (!reason.trim()) {
      setError(t('shiftReason_reason_required'));
      return;
    }
    if (outflow && !evidence.trim()) {
      setError(t('shiftReason_evidence_required'));
      return;
    }
    setError('');
    post.mutate(
      {
        shiftId,
        intent: intent.current,
        kind,
        amount: parsed,
        reason: reason.trim(),
        evidence: evidence.trim(),
      },
      {
        onSuccess: (result) => {
          setUncertain(false);
          const money = formatMoney(result.data.amount.replace(/^-/, ''), currency);
          onDone(
            t(result.data.status === 'requested' ? 'cashMovementRequested' : 'cashMovementDone', {
              kind: t(`cashMovement_${result.data.kind}`),
              amount: money,
            }),
          );
        },
        onError: (failure) => {
          setUncertain(!definitiveRejection(failure));
          setError(describeShiftFailure(failure, t));
        },
      },
    );
  }

  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card cash-movement-dialog"
        onSubmit={(event) => {
          event.preventDefault();
          submit();
        }}
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('cashMovementTitle')}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            disabled={busy}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <fieldset className="segmented" disabled={busy || uncertain}>
          <legend>{t('cashMovementKind')}</legend>
          {KINDS.map((value) => (
            <label key={value} className="checkbox-row">
              <input
                type="radio"
                name="cash-movement-kind"
                value={value}
                checked={kind === value}
                onChange={() => setKind(value)}
              />
              {t(`cashMovement_${value}`)}
            </label>
          ))}
        </fieldset>
        <p className="muted">{t(outflow ? 'cashMovementOutHint' : 'cashMovementInHint')}</p>
        <label>
          {t('cashMovementAmount')}
          <input
            inputMode="numeric"
            autoComplete="off"
            value={amount}
            disabled={busy}
            onChange={(event) => setAmount(event.target.value)}
          />
        </label>
        <label>
          {t('cashMovementReason')}
          <input
            value={reason}
            maxLength={200}
            required
            disabled={busy}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
        <label>
          {t(outflow ? 'cashMovementEvidenceRequired' : 'cashMovementEvidence')}
          <input
            value={evidence}
            maxLength={120}
            disabled={busy}
            onChange={(event) => setEvidence(event.target.value)}
          />
        </label>
        {uncertain ? (
          <p className="status-tag" data-warning="true" role="status">
            {t('shiftCommandChecking')}
          </p>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="row">
          <button type="button" disabled={busy} onClick={onClose}>
            {t('paymentCancelNo')}
          </button>
          <button type="submit" className="checkout-submit" disabled={busy}>
            {busy ? t('waiting') : uncertain ? t('shiftCommandRecheck') : t('cashMovementSubmit')}
          </button>
        </div>
      </form>
    </div>
  );
}
