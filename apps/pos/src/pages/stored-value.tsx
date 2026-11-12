import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintPortal } from '../components/receipt-sheet';
import { usePrintRoute } from '../hooks/use-print-jobs';
import {
  lookupStoredValueCard,
  useStoredValueCard,
  useStoredValueCommands,
  useStoredValueEntries,
} from '../hooks/use-stored-value';
import { writesLocked } from '../lib/pos-context';
import { createBrowserPrintAdapter } from '../lib/print-adapter';
import { deliverDirect } from '../lib/print-adapters';
import { conflictReason, describeFailure } from '../lib/request-failure';
import {
  type StoredValueCard,
  type StoredValueKind,
  type StoredValuePaymentInput,
  storedValueReasonKey,
} from '../lib/stored-value';

const printer = createBrowserPrintAdapter();
const SLIP_PAPER = '80mm';

function useExplain() {
  const { t } = useTranslation();
  return (failure: unknown) => {
    const key = storedValueReasonKey(conflictReason(failure));
    return key ? t(key) : describeFailure(failure, t);
  };
}

export function StoredValuePage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <StoredValue key={scope} />;
}

// Prepaid money and minutes cards at the counter: read a card to see its
// balance and history and top it up, or sell a new one. Money comes in as a
// cash or bank tender on the cashier's own shift.
function StoredValue() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const enabled = data?.modules?.timed_billing === true;
  const canCollect = Boolean(
    data?.capabilities.includes('pos.payment.collect') &&
      data?.shift &&
      data.shift.owner_id === data.staff.id,
  );
  const locked = writesLocked(data, selection);
  const explain = useExplain();
  const [reading, setReading] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [cardId, setCardId] = useState<string | null>(null);
  const [selling, setSelling] = useState(false);
  const input = useRef<HTMLInputElement>(null);

  useEffect(() => {
    input.current?.focus();
  }, []);

  async function find(event: FormEvent) {
    event.preventDefault();
    const token = reading.trim();
    if (!branchId || !token || busy) return;
    setBusy(true);
    setMessage('');
    try {
      const card = await lookupStoredValueCard(branchId, token);
      setReading('');
      setSelling(false);
      setCardId(card?.id ?? null);
      if (!card) setMessage(t('storedValueNotFound'));
    } catch (failure) {
      setMessage(explain(failure));
    } finally {
      setBusy(false);
    }
  }

  return (
    <PosPage title={t('storedValueTitle')} description={t('storedValueHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.timed_billing.off')} />
      ) : (
        <div className="meal-accounts">
          <form
            className="page-toolbar"
            aria-label={t('storedValueLookup')}
            onSubmit={(event) => void find(event)}
          >
            <label className="tab-list-search">
              {t('storedValueReading')}
              <input
                ref={input}
                value={reading}
                autoComplete="off"
                maxLength={120}
                placeholder={t('storedValueReadingHint')}
                onChange={(event) => setReading(event.target.value)}
              />
            </label>
            <button type="submit" disabled={busy || !reading.trim()}>
              {t('storedValueLookup')}
            </button>
            {canCollect ? (
              <button
                type="button"
                className="primary-button"
                onClick={() => {
                  setSelling(true);
                  setCardId(null);
                  setMessage('');
                }}
              >
                {t('storedValueSell')}
              </button>
            ) : null}
          </form>
          {message ? <p role="status">{message}</p> : null}
          {!canCollect ? <p className="muted">{t('storedValueNeedsShift')}</p> : null}
          {selling && canCollect ? (
            <SellForm
              branchId={branchId}
              disabled={locked}
              onSold={(id) => {
                setSelling(false);
                setCardId(id);
              }}
              onClose={() => setSelling(false)}
            />
          ) : null}
          {cardId ? (
            <CardDetail
              key={cardId}
              id={cardId}
              branchId={branchId}
              registerId={selection.registerId}
              canTopUp={canCollect && !locked}
              onClose={() => setCardId(null)}
            />
          ) : null}
        </div>
      )}
    </PosPage>
  );
}

// Prints a card slip on the register's LAN printer, else through the browser.
function useSlipPrinter(branchId: string, registerId: string | null) {
  const { t } = useTranslation();
  const route = usePrintRoute(branchId, registerId, 'receipt').route;
  const [slip, setSlip] = useState<PrintDocument | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!slip) return;
    void printer.deliver(SLIP_PAPER).then((outcome) => {
      if (!outcome.ok) setError(t('storedValuePrintFailed'));
      setSlip(null);
    });
  }, [slip, t]);

  async function print(document: PrintDocument) {
    setError('');
    if (route.kind === 'direct') {
      const outcome = await deliverDirect(route.printer, document);
      if (outcome.ok) return;
      setError(t(`printOutcome_${outcome.reason}`, { printer: route.printer.name }));
    }
    setSlip(document);
  }

  const portal = slip ? <ReceiptPrintPortal document={slip} paper={SLIP_PAPER} /> : null;
  return { print, error, portal };
}

function SellForm({
  branchId,
  disabled,
  onSold,
  onClose,
}: {
  branchId: string;
  disabled: boolean;
  onSold: (id: string | null) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const commands = useStoredValueCommands(
    branchId,
    context.data?.staff.id ?? null,
    context.data?.store.id ?? null,
  );
  const slips = useSlipPrinter(branchId, selection.registerId);
  const [cardKind, setCardKind] = useState<StoredValueKind>('minutes');
  const [cardToken, setCardToken] = useState('');
  const [holderName, setHolderName] = useState('');
  return (
    <section className="meal-account-detail" aria-label={t('storedValueSell')}>
      <div className="pos-popup-header">
        <h3>{t('storedValueSell')}</h3>
        <button type="button" onClick={onClose}>
          {t('adminClose')}
        </button>
      </div>
      <div className="reservation-form">
        <label>
          {t('storedValueKind')}
          <select
            value={cardKind}
            disabled={disabled}
            onChange={(event) => setCardKind(event.target.value as StoredValueKind)}
          >
            <option value="minutes">{t('storedValueKind_minutes')}</option>
            <option value="money">{t('storedValueKind_money')}</option>
          </select>
        </label>
        <label>
          {t('storedValueReading')}
          <input
            value={cardToken}
            autoComplete="off"
            maxLength={120}
            disabled={disabled}
            placeholder={t('storedValueReadingHint')}
            onChange={(event) => setCardToken(event.target.value)}
          />
        </label>
        <label>
          {t('storedValueHolder')}
          <input
            value={holderName}
            maxLength={120}
            disabled={disabled}
            onChange={(event) => setHolderName(event.target.value)}
          />
        </label>
      </div>
      <PaymentForm
        title={t('storedValuePayment')}
        submitLabel={t('storedValueSellSubmit')}
        minutes={cardKind === 'minutes'}
        disabled={disabled || !cardToken.trim()}
        onSubmit={async (payment) => {
          const result = await commands.sell({
            ...payment,
            cardKind,
            cardToken: cardToken.trim(),
            holderName: holderName.trim() || undefined,
          });
          setCardToken('');
          if (result.document) await slips.print(result.document);
          onSold(result.card?.id ?? null);
        }}
      />
      {slips.error ? (
        <p className="error" role="alert">
          {slips.error}
        </p>
      ) : null}
      {slips.portal}
    </section>
  );
}

function CardDetail({
  id,
  branchId,
  registerId,
  canTopUp,
  onClose,
}: {
  id: string;
  branchId: string;
  registerId: string | null;
  canTopUp: boolean;
  onClose: () => void;
}) {
  const { t, i18n } = useTranslation();
  const { context } = usePosSelection();
  const query = useStoredValueCard(branchId, id);
  const entries = useStoredValueEntries(branchId, id);
  const commands = useStoredValueCommands(
    branchId,
    context.data?.staff.id ?? null,
    context.data?.store.id ?? null,
  );
  const slips = useSlipPrinter(branchId, registerId);
  const [notice, setNotice] = useState('');
  const card = query.data ?? null;

  if (query.isLoading) return <PageState kind="loading" title={t('waiting')} />;
  if (!card) return <PageState kind="error" title={describeFailure(query.error, t)} />;
  return (
    <section
      className="meal-account-detail"
      aria-label={t('storedValueDetail', { hint: card.cardHint })}
    >
      <div className="pos-popup-header">
        <h3>
          {t(`storedValueKind_${card.kind}`)} ···{card.cardHint}
          {card.holderName ? ` · ${card.holderName}` : ''}
        </h3>
        <button type="button" onClick={onClose}>
          {t('adminClose')}
        </button>
      </div>
      <CardSummary card={card} />
      {canTopUp && card.status === 'active' ? (
        <PaymentForm
          title={t('storedValueTopUp')}
          submitLabel={t('storedValueTopUpSubmit')}
          minutes={card.kind === 'minutes'}
          disabled={false}
          onSubmit={async (payment) => {
            const result = await commands.topUp(card, payment);
            setNotice(t('storedValueTopUpDone'));
            await Promise.all([query.refetch(), entries.refetch()]);
            if (result.document) await slips.print(result.document);
          }}
        />
      ) : null}
      {notice ? <p role="status">{notice}</p> : null}
      {slips.error ? (
        <p className="error" role="alert">
          {slips.error}
        </p>
      ) : null}
      <h4>{t('storedValueHistory')}</h4>
      {entries.isError ? (
        <p className="error" role="alert">
          {describeFailure(entries.error, t)}
        </p>
      ) : null}
      {entries.isSuccess && entries.data.length === 0 ? (
        <p className="muted">{t('storedValueHistoryEmpty')}</p>
      ) : null}
      <ol className="record-list meal-account-history">
        {(entries.data ?? []).map((entry) => (
          <li key={entry.id}>
            <strong>{t(`storedValueEntry_${entry.kind}`, { defaultValue: entry.kind })}</strong>{' '}
            {formatMoney(entry.amount, card.currency)}
            {entry.minutes ? ` · ${t('storedValueMinutes', { count: entry.minutes })}` : ''}
            {entry.orderNumber ? ` · ${entry.orderNumber}` : ''}
            <small className="muted">
              {' '}
              · {entry.createdAt ? new Date(entry.createdAt).toLocaleString(i18n.language) : ''}
              {entry.actor ? ` · ${entry.actor}` : ''}
            </small>
            {entry.note ? <div className="muted">{entry.note}</div> : null}
          </li>
        ))}
      </ol>
      {slips.portal}
    </section>
  );
}

function CardSummary({ card }: { card: StoredValueCard }) {
  const { t } = useTranslation();
  return (
    <dl className="meal-account-summary">
      <dt>{t('storedValueBalance')}</dt>
      <dd data-testid="stored-value-balance">{formatMoney(card.balance, card.currency)}</dd>
      {card.kind === 'minutes' ? (
        <>
          <dt>{t('storedValueMinutesLeft')}</dt>
          <dd data-testid="stored-value-minutes">
            {t('storedValueMinutes', { count: card.minutesBalance ?? 0 })}
          </dd>
        </>
      ) : null}
      <dt>{t('storedValueStatus')}</dt>
      <dd>{t(`storedValueStatus_${card.status}`, { defaultValue: card.status })}</dd>
    </dl>
  );
}

// What the customer pays for a card or a top-up: cash (with what was handed
// over) or a bank transfer with its reference, and the minutes it buys.
function PaymentForm({
  title,
  submitLabel,
  minutes: withMinutes,
  disabled,
  onSubmit,
}: {
  title: string;
  submitLabel: string;
  minutes: boolean;
  disabled: boolean;
  onSubmit: (input: StoredValuePaymentInput) => Promise<void>;
}) {
  const { t } = useTranslation();
  const explain = useExplain();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [kind, setKind] = useState<'cash' | 'bank_manual'>('cash');
  const [amountInput, setAmountInput] = useState('');
  const [minutesInput, setMinutesInput] = useState('');
  const [handedInput, setHandedInput] = useState('');
  const [reference, setReference] = useState('');
  const [receivingAccount, setReceivingAccount] = useState('');
  const amount = parseVndInput(amountInput);
  const handed = handedInput.trim() ? parseVndInput(handedInput) : undefined;
  const minutes = Number.parseInt(minutesInput, 10);
  const bank = kind === 'bank_manual';
  const ready =
    amount !== null &&
    amount !== '0' &&
    handed !== null &&
    (!handed || BigInt(handed) >= BigInt(amount)) &&
    (!withMinutes || (Number.isInteger(minutes) && minutes > 0)) &&
    (!bank || (reference.trim() !== '' && receivingAccount.trim() !== ''));
  const off = disabled || busy;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready || amount === null || off) return;
    setBusy(true);
    setMessage('');
    try {
      await onSubmit({
        kind,
        amount,
        minutes: withMinutes ? minutes : undefined,
        handedAmount: !bank && handed ? handed : undefined,
        reference: bank ? reference.trim() : undefined,
        receivingAccount: bank ? receivingAccount.trim() : undefined,
      });
      setAmountInput('');
      setMinutesInput('');
      setHandedInput('');
      setReference('');
    } catch (failure) {
      setMessage(explain(failure));
    } finally {
      setBusy(false);
    }
  }

  return (
    <form className="reservation-form" aria-label={title} onSubmit={(event) => void submit(event)}>
      <h4>{title}</h4>
      {withMinutes ? (
        <label>
          {t('storedValueMinutesBought')}
          <input
            inputMode="numeric"
            value={minutesInput}
            disabled={off}
            aria-invalid={minutesInput.trim() !== '' && !(minutes > 0)}
            onChange={(event) => setMinutesInput(event.target.value)}
          />
        </label>
      ) : null}
      <label>
        {t('mealTopUpKind')}
        <select
          value={kind}
          disabled={off}
          onChange={(event) => setKind(event.target.value as 'cash' | 'bank_manual')}
        >
          <option value="cash">{t('cash')}</option>
          <option value="bank_manual">{t('bankTransfer')}</option>
        </select>
      </label>
      <label>
        {t('storedValueAmount')}
        <input
          inputMode="numeric"
          className="money-input"
          value={amountInput}
          disabled={off}
          aria-invalid={amountInput.trim() !== '' && amount === null}
          onChange={(event) => setAmountInput(event.target.value)}
        />
      </label>
      {bank ? (
        <>
          <label>
            {t('paymentReference')}
            <input
              value={reference}
              maxLength={120}
              disabled={off}
              onChange={(event) => setReference(event.target.value)}
            />
          </label>
          <label>
            {t('mealTopUpReceivingAccount')}
            <input
              value={receivingAccount}
              maxLength={120}
              disabled={off}
              onChange={(event) => setReceivingAccount(event.target.value)}
            />
          </label>
        </>
      ) : (
        <label>
          {t('mealTopUpHanded')}
          <input
            inputMode="numeric"
            className="money-input"
            value={handedInput}
            disabled={off}
            aria-invalid={handed === null}
            onChange={(event) => setHandedInput(event.target.value)}
          />
        </label>
      )}
      <button type="submit" className="primary-button" disabled={off || !ready}>
        {busy ? t('waiting') : submitLabel}
      </button>
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </form>
  );
}
