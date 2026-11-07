import { Link, useNavigate } from '@tanstack/react-router';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useCloseShift,
  useCountShift,
  usePendingShiftCommands,
  useShiftCloseState,
} from '../hooks/use-shift-close';
import { useModalFocus } from '../lib/dialog-focus';
import { formatMoney, parseVndInput } from '../lib/money';
import { definitiveRejection } from '../lib/request-failure';
import {
  absoluteAmount,
  activateWorkspaceTab,
  blockedChecklist,
  type ChecklistItem,
  checklistTarget,
  describeShiftFailure,
  formatInZone,
  type ShiftChecklist,
  type ShiftClosure,
  type ShiftCount,
  varianceKind,
} from '../lib/shifts';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';

type Actor = { staffId: string | null; storeId: string | null };

export function VarianceText({
  variance,
  currency,
}: {
  variance: string | null;
  currency: string;
}) {
  const { t } = useTranslation();
  const kind = varianceKind(variance);
  if (!kind || variance == null) return <span>—</span>;
  return (
    <span className="variance" data-variance={kind}>
      <span className="variance-word">{t(`shiftVariance_${kind}`)}</span>{' '}
      {kind === 'even' ? null : formatMoney(absoluteAmount(variance), currency)}
    </span>
  );
}

function ChecklistList({
  items,
  label,
  currency,
}: {
  items: ChecklistItem[];
  label: string;
  currency: string;
}) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { context, selection } = usePosSelection();
  if (items.length === 0) return null;
  return (
    <ul className="record-list shift-checklist" aria-label={label}>
      {items.map((item) => {
        const target = checklistTarget(item);
        return (
          <li key={`${item.type}-${item.id ?? item.workspace_id}`}>
            <div className="record-copy">
              <strong>
                {t(`shiftCheck_${item.type}`)}
                {item.order_number ? ` · ${item.order_number}` : ''}
              </strong>
              <small>
                {t(`shiftCheckStatus_${item.status}`, { defaultValue: item.status })}
                {item.amount ? ` · ${formatMoney(item.amount, currency)}` : ''}
              </small>
            </div>
            {target?.to === '/' ? (
              <button
                type="button"
                className="button-link"
                onClick={() => {
                  const staffId = context.data?.staff.id;
                  const storeId = context.data?.store.id;
                  if (staffId && storeId && selection.branchId) {
                    activateWorkspaceTab(
                      {
                        staffId,
                        storeId,
                        branchId: selection.branchId,
                        registerId: selection.registerId,
                      },
                      target.workspaceId,
                    );
                  }
                  void navigate({ to: '/' });
                }}
              >
                {t(`shiftCheckAction_${item.type}`)}
              </button>
            ) : target?.to === '/funds' ? (
              <Link className="button-link" to="/funds" search={target.search}>
                {t(`shiftCheckAction_${item.type}`)}
              </Link>
            ) : target?.to === '/returns' ? (
              <Link className="button-link" to="/returns" search={target.search}>
                {t(`shiftCheckAction_${item.type}`)}
              </Link>
            ) : null}
          </li>
        );
      })}
    </ul>
  );
}

function ClosedSnapshot({ closure, timeZone }: { closure: ShiftClosure; timeZone: string }) {
  const { t, i18n } = useTranslation();
  return (
    <div className="shift-snapshot" role="status" aria-live="polite">
      <p>
        <strong>{t('shiftClosedTitle')}</strong> ·{' '}
        {formatInZone(closure.closed_at, i18n.language, timeZone)}
      </p>
      <dl className="summary-grid">
        <dt>{t('shiftOpeningFloat')}</dt>
        <dd>{formatMoney(closure.opening_float, closure.currency)}</dd>
        <dt>{t('shiftInflow')}</dt>
        <dd>{formatMoney(closure.inflow_total, closure.currency)}</dd>
        <dt>{t('shiftOutflow')}</dt>
        <dd>{formatMoney(closure.outflow_total, closure.currency)}</dd>
        <dt>{t('shiftExpected')}</dt>
        <dd>{formatMoney(closure.expected, closure.currency)}</dd>
        <dt>{t('shiftCounted')}</dt>
        <dd>{formatMoney(closure.counted, closure.currency)}</dd>
        <dt>{t('shiftVarianceLabel')}</dt>
        <dd>
          <VarianceText variance={closure.variance} currency={closure.currency} />
        </dd>
        {closure.reason ? (
          <>
            <dt>{t('shiftReason')}</dt>
            <dd>{closure.reason}</dd>
          </>
        ) : null}
        {closure.approver_name ? (
          <>
            <dt>{t('shiftApprovedBy')}</dt>
            <dd>{closure.approver_name}</dd>
          </>
        ) : null}
      </dl>
      <p className="muted">{t('shiftClosedImmutable')}</p>
    </div>
  );
}

// Close wizard: checklist -> blind count -> expected and variance -> reason
// and approval when the variance exceeds the branch threshold -> immutable
// snapshot. Expected cash is shown only after the count is recorded. Count
// and close keys follow the shift revision; a lost response is rechecked
// under the same key, and a recovered earlier count is shown as such.
export function ShiftCloseDialog({
  shiftId,
  actor,
  timeZone,
  onClose,
}: {
  shiftId: string;
  actor: Actor;
  timeZone: string;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const [step, setStep] = useState<'checklist' | 'count'>('checklist');
  const [counted, setCounted] = useState('');
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [uncertain, setUncertain] = useState<null | (() => void)>(null);
  const [blocked, setBlocked] = useState<ShiftChecklist | null>(null);
  const [recounting, setRecounting] = useState(false);
  const countShift = useCountShift(actor);
  const closeShift = useCloseShift(actor);
  const pending = usePendingShiftCommands(actor, [shiftId]);
  const [rechecking, setRechecking] = useState(false);
  const peek = useShiftCloseState(shiftId);
  const peekCount = peek.data?.count;
  // Keep checking while a reasoned count waits for its approval (also after reopening).
  const waiting = Boolean(
    peekCount?.requires_approval && peekCount.reason && !peekCount.approval && !peekCount.stale,
  );
  const state = useShiftCloseState(shiftId, waiting);
  const busy = countShift.isPending || closeShift.isPending || rechecking;

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  const data = state.data;
  const currency = data?.shift.currency ?? 'VND';
  const revision = data?.shift.revision ?? 0;
  const count: ShiftCount | undefined = data?.count;
  const checklist = blocked ?? data?.checklist;
  const reviewing = Boolean(count?.counted && !count.stale && !data?.closure && !recounting);

  function fail(failure: unknown, retry: () => void) {
    const items = blockedChecklist(failure);
    if (items) {
      setBlocked(items);
      setStep('checklist');
    }
    setUncertain(definitiveRejection(failure) ? null : () => retry);
    setError(describeShiftFailure(failure, t));
  }

  // A retry keeps the revision (and so the key) of the attempt whose outcome
  // is unknown, even if the shift already moved on because it committed.
  function submitCount(withReason?: string, atRevision = revision, typed?: string) {
    const amount = typed ?? parseVndInput(counted || count?.counted?.replace(/\.0+$/, '') || '');
    if (amount === null) {
      setError(t('shiftCountedInvalid'));
      return;
    }
    setError('');
    setNotice('');
    const retry = () => submitCount(withReason, atRevision, amount);
    countShift.mutate(
      { shiftId, revision: atRevision, counted: amount, reason: withReason },
      {
        onSuccess: (result) => {
          setBlocked(null);
          setRecounting(false);
          setUncertain(null);
          // A recovered result can be an earlier count of this revision.
          if (result.recovered && result.data.counted?.replace(/\.0+$/, '') !== amount) {
            setNotice(
              t('shiftCountRecovered', { amount: formatMoney(result.data.counted, currency) }),
            );
          }
        },
        onError: (failure) => fail(failure, retry),
      },
    );
  }

  function close(atRevision = revision) {
    setError('');
    const retry = () => close(atRevision);
    closeShift.mutate(
      { shiftId, revision: atRevision, reason: reason.trim() || undefined },
      {
        onSuccess: () => setUncertain(null),
        onError: (failure) => fail(failure, retry),
      },
    );
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card shift-close-dialog"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('shiftCloseTitle')}</h4>
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
        {(pending.records.length > 0 && !countShift.isPending && !closeShift.isPending) ||
        uncertain ? (
          <div className="row" role="status">
            <span className="status-tag" data-warning="true">
              {t('shiftCommandChecking')}
            </span>
            <button
              type="button"
              disabled={busy}
              onClick={() => {
                setError('');
                if (uncertain) {
                  uncertain();
                  return;
                }
                setRechecking(true);
                void pending
                  .recheck()
                  .catch((failure) => setError(describeShiftFailure(failure, t)))
                  .finally(() => setRechecking(false));
              }}
            >
              {t('shiftCommandRecheck')}
            </button>
          </div>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        {notice ? (
          <p className="muted" role="status">
            {notice}
          </p>
        ) : null}
        {state.isLoading ? <p role="status">{t('waiting')}</p> : null}
        {data?.closure ? (
          <>
            <ClosedSnapshot closure={data.closure} timeZone={timeZone} />
            <div className="row">
              <button type="button" onClick={onClose}>
                {t('shiftCloseDone')}
              </button>
            </div>
          </>
        ) : data && !data.can_close ? (
          <p>{t('shiftCloseNotAllowed')}</p>
        ) : data && reviewing && count ? (
          <div className="shift-review">
            <ol className="wizard-steps" aria-label={t('shiftCloseSteps')}>
              <li>{t('shiftStepChecklist')}</li>
              <li>{t('shiftStepCount')}</li>
              <li aria-current="step">{t('shiftStepReview')}</li>
            </ol>
            <dl className="summary-grid">
              <dt>{t('shiftCounted')}</dt>
              <dd>{formatMoney(count.counted, currency)}</dd>
              <dt>{t('shiftExpected')}</dt>
              <dd>{formatMoney(count.expected, currency)}</dd>
              <dt>{t('shiftVarianceLabel')}</dt>
              <dd>
                <VarianceText variance={count.variance} currency={currency} />
              </dd>
            </dl>
            <p className="muted">{t('shiftExpectedExplained')}</p>
            {count.requires_approval ? (
              <>
                <p className="status-tag" data-warning="true">
                  {count.variance_threshold
                    ? t('shiftNeedsApprovalThreshold', {
                        threshold: formatMoney(count.variance_threshold, currency),
                      })
                    : t('shiftNeedsApproval')}
                </p>
                {count.approval ? (
                  <p role="status">
                    {t('shiftApprovedBy')}: {count.approval.approver_name}
                  </p>
                ) : count.reason ? (
                  <p role="status" aria-live="polite">
                    {t('shiftWaitingApproval', { reason: count.reason })}
                  </p>
                ) : (
                  <label>
                    {t('shiftReason')}
                    <input
                      value={reason}
                      maxLength={200}
                      required
                      disabled={busy}
                      onChange={(event) => setReason(event.target.value)}
                    />
                  </label>
                )}
              </>
            ) : count.variance && varianceKind(count.variance) !== 'even' ? (
              <label>
                {t('shiftReasonOptional')}
                <input
                  value={reason}
                  maxLength={200}
                  disabled={busy}
                  onChange={(event) => setReason(event.target.value)}
                />
              </label>
            ) : null}
            <div className="row">
              <button
                type="button"
                disabled={busy}
                onClick={() => {
                  setCounted('');
                  setReason('');
                  setNotice('');
                  setRecounting(true);
                  setStep('count');
                }}
              >
                {t('shiftRecount')}
              </button>
              {count.requires_approval && !count.approval && !count.reason ? (
                <button
                  type="button"
                  className="checkout-submit"
                  disabled={busy || !reason.trim()}
                  onClick={() => submitCount(reason.trim())}
                >
                  {t('shiftSendForApproval')}
                </button>
              ) : count.requires_approval && !count.approval ? (
                <button
                  type="button"
                  disabled={busy || state.isFetching}
                  onClick={() => void state.refetch()}
                >
                  {t('shiftCheckApproval')}
                </button>
              ) : (
                <button
                  type="button"
                  className="checkout-submit"
                  disabled={busy}
                  onClick={() => close()}
                >
                  {busy ? t('waiting') : t('shiftCloseConfirm')}
                </button>
              )}
            </div>
          </div>
        ) : data && step === 'count' ? (
          <form
            className="shift-count"
            onSubmit={(event) => {
              event.preventDefault();
              if (!busy) submitCount();
            }}
          >
            <ol className="wizard-steps" aria-label={t('shiftCloseSteps')}>
              <li>{t('shiftStepChecklist')}</li>
              <li aria-current="step">{t('shiftStepCount')}</li>
              <li>{t('shiftStepReview')}</li>
            </ol>
            <p>{t('shiftBlindCountHint')}</p>
            {count?.stale ? (
              <p className="status-tag" data-warning="true">
                {t('shiftCountStale')}
              </p>
            ) : null}
            <label>
              {t('shiftCountedInput')}
              <input
                inputMode="numeric"
                autoComplete="off"
                value={counted}
                disabled={busy}
                onChange={(event) => setCounted(event.target.value)}
              />
            </label>
            <div className="row">
              <button type="button" disabled={busy} onClick={() => setStep('checklist')}>
                {t('back')}
              </button>
              <button type="submit" className="checkout-submit" disabled={busy || !counted.trim()}>
                {busy ? t('waiting') : t('shiftRecordCount')}
              </button>
            </div>
          </form>
        ) : data && checklist ? (
          <div className="shift-checklist-step">
            <ol className="wizard-steps" aria-label={t('shiftCloseSteps')}>
              <li aria-current="step">{t('shiftStepChecklist')}</li>
              <li>{t('shiftStepCount')}</li>
              <li>{t('shiftStepReview')}</li>
            </ol>
            {checklist.blocking.length === 0 ? (
              <p role="status">{t('shiftChecklistClear')}</p>
            ) : (
              <p className="status-tag" data-warning="true" role="status">
                {t('shiftChecklistBlocked', { count: checklist.blocking.length })}
              </p>
            )}
            <ChecklistList
              items={checklist.blocking}
              label={t('shiftChecklistBlocking')}
              currency={currency}
            />
            {checklist.warnings.length > 0 ? (
              <>
                <p className="muted">{t('shiftChecklistWarnings')}</p>
                <ChecklistList
                  items={checklist.warnings}
                  label={t('shiftChecklistWarningList')}
                  currency={currency}
                />
              </>
            ) : null}
            <div className="row">
              <button
                type="button"
                disabled={state.isFetching}
                onClick={() => {
                  setBlocked(null);
                  void state.refetch();
                }}
              >
                {t('shiftChecklistRefresh')}
              </button>
              <button
                type="button"
                className="checkout-submit"
                disabled={checklist.blocking.length > 0}
                onClick={() => {
                  setError('');
                  setStep('count');
                }}
              >
                {t('shiftStartCount')}
              </button>
            </div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
