import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import { useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useReconcileCandidates,
  useReconcileLateCash,
  useReconciliations,
} from '../hooks/use-shift-close';
import { definitiveRejection, posFailureKey } from '../lib/request-failure';
import {
  addsDrawerCash,
  type CustodyOutcome,
  describeShiftFailure,
  formatInZone,
  outcomeNeedsReference,
  outcomeTakesShift,
  reconcileAmountError,
} from '../lib/shifts';
import { PageState } from './pos-page';

const OUTCOMES: CustodyOutcome[] = [
  'in_opening_float',
  'safe',
  'handed_over',
  'new_physical_inflow',
];

// Manager wizard for cash found after a shift closed: which closed shift's
// overage and/or which held receipt it is, and where that money is now. Only
// "put into a drawer now" adds cash to a current shift; the other outcomes
// record custody already counted elsewhere, so nothing is counted twice.
export function LateCashWizard({
  branchId,
  actor,
  locked,
  timeZone,
}: {
  branchId: string;
  actor: { staffId: string | null; storeId: string | null };
  locked: boolean;
  timeZone: string;
}) {
  const { t, i18n } = useTranslation();
  const candidates = useReconcileCandidates(branchId, true);
  const history = useReconciliations(branchId, true);
  const reconcile = useReconcileLateCash(actor);
  // One intent per filled-in wizard; renewed after a recorded reconciliation.
  const intent = useRef(crypto.randomUUID());
  const [closureId, setClosureId] = useState('');
  const [fundsId, setFundsId] = useState('');
  const [outcome, setOutcome] = useState<CustodyOutcome | ''>('');
  const [targetShiftId, setTargetShiftId] = useState('');
  const [reference, setReference] = useState('');
  const [reason, setReason] = useState('');
  const [amountText, setAmountText] = useState('');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [uncertain, setUncertain] = useState(false);
  const data = candidates.data;
  const closure = data?.closures.find((row) => row.id === closureId);
  const funds = data?.held_funds.find((row) => row.id === fundsId);
  const closureOnly = Boolean(closure && !funds);
  const targets = (data?.shifts ?? []).filter((row) =>
    outcome === 'new_physical_inflow' ? row.status === 'open' : true,
  );
  const parsedAmount = parseVndInput(amountText);
  const amountError =
    closureOnly && closure
      ? reconcileAmountError(amountText, parsedAmount, closure.unexplained)
      : null;
  const amount = funds?.amount ?? (closureOnly ? parsedAmount : null);
  const currency = funds?.currency ?? closure?.currency ?? 'VND';
  const time = (value: string | null | undefined) => formatInZone(value, i18n.language, timeZone);
  const ready =
    Boolean(closure || funds) &&
    !amountError &&
    outcome !== '' &&
    reason.trim() !== '' &&
    (!outcomeNeedsReference(outcome) || reference.trim() !== '') &&
    (!outcomeTakesShift(outcome) || targetShiftId !== '');

  function reset() {
    intent.current = crypto.randomUUID();
    setClosureId('');
    setFundsId('');
    setOutcome('');
    setTargetShiftId('');
    setReference('');
    setReason('');
    setAmountText('');
  }

  return (
    <section className="page-card late-cash" aria-labelledby="late-cash-title">
      <h2 id="late-cash-title">{t('lateCashTitle')}</h2>
      <p className="muted">{t('lateCashHint')}</p>
      {candidates.isError ? (
        <PageState kind="error" title={t(posFailureKey(candidates.error))} />
      ) : null}
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {data && data.closures.length === 0 && data.held_funds.length === 0 ? (
        <PageState kind="empty" title={t('lateCashEmpty')} />
      ) : null}
      {data && (data.closures.length > 0 || data.held_funds.length > 0) ? (
        <form
          className="late-cash-form"
          onSubmit={(event) => {
            event.preventDefault();
            if (!ready || !outcome || reconcile.isPending) return;
            setError('');
            reconcile.mutate(
              {
                branchId,
                intent: intent.current,
                outcome,
                reason: reason.trim(),
                amount: closureOnly ? (parsedAmount ?? undefined) : undefined,
                closureId: closureId || undefined,
                fundsId: fundsId || undefined,
                targetShiftId: outcomeTakesShift(outcome) ? targetShiftId || undefined : undefined,
                custodyReference: reference.trim() || undefined,
              },
              {
                onSuccess: ({ data: result }) => {
                  setUncertain(false);
                  setNotice(
                    t(result.cash_movement_id ? 'lateCashDoneInflow' : 'lateCashDoneCustody', {
                      amount: formatMoney(result.amount, result.currency),
                    }),
                  );
                  reset();
                },
                onError: (failure) => {
                  setUncertain(!definitiveRejection(failure));
                  setError(describeShiftFailure(failure, t));
                },
              },
            );
          }}
        >
          <fieldset disabled={locked || reconcile.isPending || uncertain}>
            <legend>{t('lateCashStepSource')}</legend>
            <label>
              {t('lateCashClosedShift')}
              <select value={closureId} onChange={(event) => setClosureId(event.target.value)}>
                <option value="">{t('lateCashNone')}</option>
                {data.closures.map((row) => (
                  <option key={row.id} value={row.id}>
                    {t('lateCashClosureOption', {
                      owner: row.owner_name,
                      register: row.register ?? '—',
                      time: time(row.closed_at),
                      amount: formatMoney(row.unexplained, row.currency),
                    })}
                  </option>
                ))}
              </select>
            </label>
            {closure ? (
              <p className="muted">
                {t('lateCashClosureFacts', {
                  counted: formatMoney(closure.counted, closure.currency),
                  expected: formatMoney(closure.expected, closure.currency),
                  variance: formatMoney(closure.variance, closure.currency),
                })}
              </p>
            ) : null}
            <label>
              {t('lateCashHeld')}
              <select value={fundsId} onChange={(event) => setFundsId(event.target.value)}>
                <option value="">{t('lateCashNone')}</option>
                {data.held_funds.map((row) => (
                  <option key={row.id} value={row.id} disabled={row.recorded_by_me}>
                    {t('lateCashHeldOption', {
                      amount: formatMoney(row.amount, row.currency),
                      note: row.custody_note ?? '',
                      time: time(row.received_at),
                    })}
                    {row.recorded_by_me ? ` (${t('lateCashRecordedByMe')})` : ''}
                  </option>
                ))}
              </select>
            </label>
            {funds ? (
              <p className="muted" role="status">
                {t('lateCashHeldShift', {
                  owner: funds.shift_owner_name ?? '—',
                  opened: time(funds.shift_opened_at),
                  status: t(
                    funds.shift_status === 'closed' ? 'lateCashShiftClosed' : 'lateCashShiftOpen',
                  ),
                })}
                {funds.closure_id
                  ? ` ${t('lateCashHeldClosure', {
                      counted: formatMoney(funds.closure_counted, funds.currency),
                      expected: formatMoney(funds.closure_expected, funds.currency),
                    })}`
                  : ''}
                {funds.overage_explained ? ` ${t('lateCashOverageExplained')}` : ''}
              </p>
            ) : null}
            {closureOnly && closure ? (
              <label>
                {t('lateCashAmountInput', {
                  max: formatMoney(closure.unexplained, closure.currency),
                })}
                <input
                  inputMode="numeric"
                  autoComplete="off"
                  value={amountText}
                  aria-invalid={Boolean(amountError && amountText)}
                  onChange={(event) => setAmountText(event.target.value)}
                />
                {amountError && amountText ? (
                  <small className="error">{t(amountError)}</small>
                ) : null}
              </label>
            ) : null}
            {amount ? (
              <p role="status">{t('lateCashAmount', { amount: formatMoney(amount, currency) })}</p>
            ) : null}
          </fieldset>
          <fieldset disabled={locked || reconcile.isPending || uncertain}>
            <legend>{t('lateCashStepCustody')}</legend>
            {OUTCOMES.map((value) => (
              <label key={value} className="checkbox-row">
                <input
                  type="radio"
                  name="late-cash-outcome"
                  value={value}
                  checked={outcome === value}
                  onChange={() => setOutcome(value)}
                />
                <span>
                  <strong>{t(`lateCashOutcome_${value}`)}</strong>
                  <small className="muted"> {t(`lateCashOutcomeHint_${value}`)}</small>
                </span>
              </label>
            ))}
            {outcome !== '' ? (
              <p
                className="status-tag"
                data-warning={String(addsDrawerCash(outcome))}
                role="status"
              >
                {t(addsDrawerCash(outcome) ? 'lateCashAddsDrawer' : 'lateCashNoDrawer')}
              </p>
            ) : null}
            {outcome !== '' && outcomeTakesShift(outcome) ? (
              <label>
                {t(
                  outcome === 'new_physical_inflow'
                    ? 'lateCashTargetDrawer'
                    : 'lateCashTargetFloat',
                )}
                <select
                  value={targetShiftId}
                  onChange={(event) => setTargetShiftId(event.target.value)}
                >
                  <option value="">{t('lateCashNone')}</option>
                  {targets.map((row) => (
                    <option key={row.id} value={row.id}>
                      {t('lateCashShiftOption', {
                        owner: row.owner_name,
                        register: row.register ?? '—',
                        float: formatMoney(row.opening_float, currency),
                        time: time(row.opened_at),
                      })}
                    </option>
                  ))}
                </select>
              </label>
            ) : null}
            {outcome !== '' && outcomeNeedsReference(outcome) ? (
              <label>
                {t('lateCashReference')}
                <input
                  value={reference}
                  maxLength={120}
                  onChange={(event) => setReference(event.target.value)}
                />
              </label>
            ) : null}
            <label>
              {t('lateCashReason')}
              <input
                value={reason}
                maxLength={200}
                onChange={(event) => setReason(event.target.value)}
              />
            </label>
          </fieldset>
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
          <button
            type="submit"
            className="checkout-submit"
            disabled={locked || (!ready && !uncertain) || reconcile.isPending}
          >
            {reconcile.isPending
              ? t('waiting')
              : uncertain
                ? t('shiftCommandRecheck')
                : t('lateCashSubmit')}
          </button>
        </form>
      ) : null}
      {(history.data?.data.length ?? 0) > 0 ? (
        <>
          <h3>{t('lateCashHistory')}</h3>
          <ul className="record-list" aria-label={t('lateCashHistory')}>
            {history.data?.data.map((row) => (
              <li key={row.id}>
                <div className="record-copy">
                  <strong>{t(`lateCashOutcome_${row.outcome}`)}</strong>
                  <small>
                    {row.reason} · {row.actor_name} · {time(row.created_at)}
                  </small>
                </div>
                <strong>{formatMoney(row.amount, row.currency)}</strong>
              </li>
            ))}
          </ul>
        </>
      ) : null}
    </section>
  );
}
