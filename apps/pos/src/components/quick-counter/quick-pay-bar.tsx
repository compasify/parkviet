import { formatMoney, parseVndAmount } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { pendingKitchenUnits } from '@parkviet/pos-shared/ticket-groups';
import { describeTraceFailure, paymentBlock } from '@parkviet/pos-shared/traceability';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useWorkspaceMeal } from '../../hooks/use-meal-accounts';
import { usePaymentMethods, useTenders } from '../../hooks/use-tenders';
import { cashSuggestions, groupVndDigits } from '../../lib/cash-suggestions';
import { mealDue, mealReasonKey } from '../../lib/meal-accounts';
import type { PosWorkspace } from '../../lib/pos-context';
import {
  blankOrder,
  type QuickPayKind,
  quickCashAmount,
  quickPayKey,
} from '../../lib/quick-counter';
import { conflictReason, describeFailure } from '../../lib/request-failure';
import { DisplayPinControl } from '../display-pin-control';
import { popupOpen, typingTarget } from '../menu-grid';
import { paidInFull } from '../payment-panel';
import { idleScanField } from '../scan-input';
import { activePaymentProps, type SellingWorkspace } from '../workspace-tabs';

// What the order still owes, in whole VND.
function dueOf(workspace: PosWorkspace): bigint {
  const value = parseVndAmount(workspace.financial?.remaining ?? workspace.totals?.total ?? '');
  return BigInt(value ?? '0');
}

// A key typed into a text field is the field's. The canteen's meal code
// field holds the focus between orders: empty, it is not being typed in.
function typingIn(target: EventTarget | null) {
  return typingTarget(target) && !idleScanField(target);
}

// The counter's payment keys wait while the cashier is busy elsewhere: a
// dialog or popup is open, or a dish's options are being chosen.
function quickKeysPaused() {
  return (
    popupOpen() ||
    document.querySelector('[role="dialog"][aria-modal="true"], .modifier-panel') !== null
  );
}

// The foot of the quick counter's ticket: the total, then payment in one
// tap. "Tiền mặt" (F1) takes exactly what is due in cash, a note the guest
// hands over takes that note and leaves the change; VietQR (F2) and the
// other methods (F3, "⋯") open the full payment screen. With dishes the
// kitchen has not had yet, cash opens the payment screen too, which sends
// them first. F1 to F3 never reach the browser (help, search); they act
// unless the cashier is typing or busy in a dialog or a dish's options.
// "Giữ đơn" puts the order aside and starts the next one. On a canteen
// meal with a sponsor, cash takes only the eater's part and completing the
// order charges the sponsor's; while a meal code is being looked up or
// recorded, or until the meal of the order's latest change is known, cash
// waits and says so.
export function QuickPayBar({
  selling,
  active,
  onOpen,
  onPaid,
  onHold,
  mealPending = false,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  // A meal code typed at the head of the ticket is still being answered.
  mealPending?: boolean;
  // The full payment screen, starting on VietQR or on cash and the rest.
  onOpen: (tender: 'vietqr' | 'cash') => void;
  // The order was paid in cash here and completed.
  onPaid: (workspace: PosWorkspace) => void;
  onHold: () => void;
}) {
  const { t } = useTranslation();
  const {
    data,
    staffId,
    storeId,
    workspaces,
    command,
    run,
    busy,
    editDisabled,
    isEditor,
    kitchenOn,
    callNumbers,
    mealAccounts,
  } = selling;
  const payment = activePaymentProps(selling, active);
  // The same query as the selling screen's: one request, read here for
  // whether it answers the order's latest change.
  const mealQuery = useWorkspaceMeal(active, mealAccounts);
  // A code was answered: until the meal of the order as it is now is read,
  // the earlier "no meal" may be out of date.
  const [mealSettling, setMealSettling] = useState(false);
  const mealFresh = mealQuery.isSuccess && !mealQuery.isPlaceholderData;
  useEffect(() => {
    if (mealPending) setMealSettling(true);
    else if (mealFresh) setMealSettling(false);
  }, [mealPending, mealFresh]);
  // Cash knows the sponsor's part: no code is being answered, and the meal
  // read is the order's latest, or an earlier one saying there is no meal
  // (only a code typed here puts one on the order, and then it is read again).
  const mealKnown =
    !mealAccounts ||
    (!mealPending &&
      !mealSettling &&
      mealQuery.isSuccess &&
      (!mealQuery.isPlaceholderData || mealQuery.data?.meal == null));
  const plan = mealAccounts ? (mealQuery.data?.meal?.plan ?? null) : null;
  const tenders = useTenders(staffId, storeId);
  const methodsQuery = usePaymentMethods(active, payment.canCollect && !payment.disabled);
  const methods = methodsQuery.data ?? [];
  const cashMethod = methods.find((method) => method.kind === 'cash');
  const vietqrOffered = methods.some((method) => method.kind === 'vietqr');
  const [paying, setPaying] = useState(false);
  // A second press before the first one re-renders the bar starts nothing.
  const payingNow = useRef(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const currency = active.totals?.currency ?? 'VND';
  const count = (active.line_items ?? []).reduce(
    (sum, line) => sum + Math.max(0, line.quantity),
    0,
  );
  const due = dueOf(active);
  const { sponsor: sponsorDue, eater: eaterDue } = mealDue(String(due), plan);
  const sponsorBlocked = sponsorDue > 0n && plan?.sponsor_unavailable === true;
  const unresolved = (active.financial?.attempts ?? []).some(
    (attempt) => attempt.status === 'prepared' || attempt.status === 'unknown',
  );
  // Payment may start: the order is open with dishes, the cashier may take
  // money into their own open drawer, and traced stock is ready.
  const open =
    payment.canCollect &&
    !payment.disabled &&
    payment.drawerOpen &&
    paymentBlock(active).ready &&
    count > 0 &&
    active.operational_status === 'editing' &&
    !paying;
  const branch = data?.branches.find((row) => row.id === active.branch_id);
  const canSend = kitchenOn && branch?.kitchen_send_trigger !== 'on_complete';
  const pending = canSend ? pendingKitchenUnits(active) : 0;
  const cashPayable = open && Boolean(cashMethod) && !unresolved && eaterDue > 0n && mealKnown;
  // A completed order cannot go to the kitchen any more: dishes still to
  // send are sent from the payment screen before the cash is taken; a
  // sponsor that cannot take its part is explained there too.
  const cashReady = cashPayable && pending === 0 && !sponsorBlocked;
  const vietqrReady = open && vietqrOffered && !unresolved && eaterDue > 0n && mealKnown;
  // The full screen explains whatever stops a payment, so it opens whenever
  // there is something to pay or a payment to finish.
  const otherReady = payment.canCollect && count > 0 && !paying && !busy;
  // Paid in full but not completed yet (the completion was refused or cut
  // off): the payment screen finishes it.
  const toFinish =
    unresolved || (paidInFull(active, sponsorDue) && active.operational_status !== 'completed');

  async function payCash(handed: bigint | null) {
    const method = cashMethod;
    if (!method || !cashPayable || payingNow.current) return;
    if (!cashReady) {
      onOpen('cash');
      return;
    }
    payingNow.current = true;
    setPaying(true);
    setError('');
    try {
      let latest = await command(active, async (current) => {
        // A note smaller than what is owed (the order changed meanwhile) pays its part.
        const amount = quickCashAmount(dueOf(current), sponsorDue, handed);
        if (amount <= 0n) return current;
        const prepared = await tenders.prepare(current, {
          paymentMethodId: method.id,
          amount: String(amount),
        });
        const attempt = (prepared.financial?.attempts ?? []).find(
          (item) => item.kind === 'cash' && item.status === 'prepared',
        );
        if (!attempt) return prepared;
        return tenders.confirm(prepared, {
          attemptId: attempt.id,
          evidenceKind: 'cash_count',
          handedAmount: String(handed ?? amount),
        });
      });
      if (paidInFull(latest, sponsorDue))
        latest = await command(active, (current) =>
          tenders.complete(current, undefined, undefined, { mealSponsor: sponsorDue > 0n }),
        );
      if (latest.operational_status === 'completed') onPaid(latest);
    } catch (failure) {
      const key = mealReasonKey(conflictReason(failure));
      setError(key ? t(key) : describeTraceFailure(failure, t));
      // Whatever part went through is on the server now: show it.
      void tenders.refresh();
    } finally {
      payingNow.current = false;
      setPaying(false);
    }
  }

  async function send() {
    if (sending) return;
    setSending(true);
    try {
      await run(() => command(active, (current) => workspaces.sendToKitchen(current)));
    } finally {
      setSending(false);
    }
  }

  const keys = useRef<Record<QuickPayKind, (() => void) | null>>({
    cash: null,
    vietqr: null,
    other: null,
  });
  keys.current = {
    cash: cashPayable ? () => void payCash(null) : null,
    vietqr: vietqrReady ? () => onOpen('vietqr') : null,
    other: otherReady ? () => onOpen('cash') : null,
  };
  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      const kind = quickPayKey(event);
      if (!kind || event.defaultPrevented) return;
      event.preventDefault();
      if (typingIn(event.target) || quickKeysPaused()) return;
      keys.current[kind]?.();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  return (
    <footer className="ticket-footer quick-pay">
      <p className="quick-pay-total">
        <span>
          {t('payTotal')} · {t('ticketSummary', { count })}
        </span>
        <strong data-testid="quick-total">
          {formatMoney(active.payments ? String(due) : (active.totals?.total ?? '0'), currency)}
        </strong>
      </p>
      {sponsorDue > 0n ? (
        <p className="quick-pay-total quick-pay-eater" data-testid="quick-eater-due">
          <span>{t('mealEaterPart')}</span>
          <strong>{formatMoney(String(eaterDue), currency)}</strong>
        </p>
      ) : null}
      {cashPayable ? (
        <fieldset className="quick-pay-notes">
          <legend className="visually-hidden">{t('quickPayNotes')}</legend>
          {cashSuggestions(eaterDue, 3).map((value) => (
            <button
              key={String(value)}
              type="button"
              aria-label={t('quickPayHanded', { amount: groupVndDigits(String(value)) })}
              onClick={() => void payCash(value)}
            >
              {groupVndDigits(String(value))}
            </button>
          ))}
        </fieldset>
      ) : null}
      <div className="quick-pay-methods">
        <button
          type="button"
          className="quick-pay-cash"
          aria-keyshortcuts="F1"
          disabled={!cashPayable}
          onClick={() => void payCash(null)}
        >
          {paying ? t('waiting') : t('quickPayCash')} <kbd>F1</kbd>
        </button>
        {vietqrOffered ? (
          <button
            type="button"
            className="quick-pay-qr"
            aria-keyshortcuts="F2"
            disabled={!vietqrReady}
            onClick={() => onOpen('vietqr')}
          >
            {t('vietqr')} <kbd>F2</kbd>
          </button>
        ) : null}
        <button
          type="button"
          className="quick-pay-other"
          aria-keyshortcuts="F3"
          aria-label={toFinish ? t('quickPayContinue') : t('quickPayOther')}
          title={toFinish ? t('quickPayContinue') : t('quickPayOther')}
          disabled={!otherReady}
          onClick={() => onOpen('cash')}
        >
          {toFinish ? t('quickPayContinue') : <span aria-hidden="true">⋯</span>} <kbd>F3</kbd>
        </button>
      </div>
      {open && !mealKnown ? (
        mealQuery.isError && !mealPending ? (
          <p className="error ticket-hint" role="alert">
            {t('quickMealFailed', { reason: describeFailure(mealQuery.error, t) })}{' '}
            <button type="button" onClick={() => void mealQuery.refetch()}>
              {t('retry')}
            </button>
          </p>
        ) : (
          <p className="muted ticket-hint" role="status" data-testid="quick-meal-checking">
            {t('quickMealChecking')}
          </p>
        )
      ) : null}
      {payment.drawerOpen ? null : (
        <p className="muted ticket-hint" role="note">
          {t('paymentNeedsOpenShift')}
        </p>
      )}
      {error ? (
        <p className="error ticket-hint" role="alert">
          {error}
        </p>
      ) : null}
      <div className="ticket-tools">
        <button
          type="button"
          disabled={busy || paying || active.operational_status !== 'editing' || blankOrder(active)}
          title={t('quickHoldHint')}
          onClick={onHold}
        >
          {t('quickHold')}
        </button>
        {canSend ? (
          <button
            type="button"
            disabled={sending || pending <= 0 || editDisabled || !isEditor}
            onClick={() => void send()}
          >
            {t('ticketSend', { count: pending })}
          </button>
        ) : null}
        <details className="quick-display">
          <summary>{t('displayTitle')}</summary>
          <DisplayPinControl
            shiftId={data?.shift?.id ?? null}
            ownsShift={Boolean(data?.shift && data.shift.owner_id === data.staff.id)}
            enabled={contextFeature(data, 'customer_display')}
            callBoard={callNumbers}
            workspace={active}
          />
        </details>
      </div>
    </footer>
  );
}
