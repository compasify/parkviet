import { formatMoney, parseVndAmount } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { pendingKitchenUnits } from '@parkviet/pos-shared/ticket-groups';
import { describeTraceFailure, paymentBlock } from '@parkviet/pos-shared/traceability';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePaymentMethods, useTenders } from '../../hooks/use-tenders';
import { cashSuggestions, groupVndDigits } from '../../lib/cash-suggestions';
import type { PosWorkspace } from '../../lib/pos-context';
import { blankOrder, type QuickPayKind, quickPayKey } from '../../lib/quick-counter';
import { DisplayPinControl } from '../display-pin-control';
import { popupOpen, typingTarget } from '../menu-grid';
import { paidInFull } from '../payment-panel';
import { activePaymentProps, type SellingWorkspace } from '../workspace-tabs';

// What the order still owes, in whole VND.
function dueOf(workspace: PosWorkspace): bigint {
  const value = parseVndAmount(workspace.financial?.remaining ?? workspace.totals?.total ?? '');
  return BigInt(value ?? '0');
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
// "Giữ đơn" puts the order aside and starts the next one.
export function QuickPayBar({
  selling,
  active,
  onOpen,
  onPaid,
  onHold,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
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
  } = selling;
  const payment = activePaymentProps(selling, active);
  const tenders = useTenders(staffId, storeId);
  const methodsQuery = usePaymentMethods(active, payment.canCollect && !payment.disabled);
  const methods = methodsQuery.data ?? [];
  const cashMethod = methods.find((method) => method.kind === 'cash');
  const vietqrOffered = methods.some((method) => method.kind === 'vietqr');
  const [paying, setPaying] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const currency = active.totals?.currency ?? 'VND';
  const count = (active.line_items ?? []).reduce(
    (sum, line) => sum + Math.max(0, line.quantity),
    0,
  );
  const due = dueOf(active);
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
  const cashPayable = open && Boolean(cashMethod) && !unresolved && due > 0n;
  // A completed order cannot go to the kitchen any more: dishes still to
  // send are sent from the payment screen before the cash is taken.
  const cashReady = cashPayable && pending === 0;
  const vietqrReady = open && vietqrOffered && !unresolved && due > 0n;
  // The full screen explains whatever stops a payment, so it opens whenever
  // there is something to pay or a payment to finish.
  const otherReady = payment.canCollect && count > 0 && !paying && !busy;
  // Paid in full but not completed yet (the completion was refused or cut
  // off): the payment screen finishes it.
  const toFinish = unresolved || (paidInFull(active) && active.operational_status !== 'completed');

  async function payCash(handed: bigint | null) {
    const method = cashMethod;
    if (!method || !cashPayable) return;
    if (!cashReady) {
      onOpen('cash');
      return;
    }
    setPaying(true);
    setError('');
    try {
      let latest = await command(active, async (current) => {
        const owed = dueOf(current);
        if (owed <= 0n) return current;
        // A note smaller than what is owed (the order changed meanwhile) pays its part.
        const amount = handed !== null && handed < owed ? handed : owed;
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
      if (paidInFull(latest))
        latest = await command(active, (current) => tenders.complete(current));
      if (latest.operational_status === 'completed') onPaid(latest);
    } catch (failure) {
      setError(describeTraceFailure(failure, t));
      // Whatever part went through is on the server now: show it.
      void tenders.refresh();
    } finally {
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
      if (typingTarget(event.target) || quickKeysPaused()) return;
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
      {cashPayable ? (
        <fieldset className="quick-pay-notes">
          <legend className="visually-hidden">{t('quickPayNotes')}</legend>
          {cashSuggestions(due, 3).map((value) => (
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
