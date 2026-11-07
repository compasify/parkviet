import { type KeyboardEvent, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parseVndAmount, parseVndInput } from '../lib/money';
import type { PosFinancialAttempt, PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

export type TenderEvidenceItemInput = {
  attemptId: string;
  evidenceKind: 'cash_count' | 'bank_manual';
  handedAmount?: string;
  receivedAmount?: string;
  reference?: string;
  receivingAccount?: string;
  terminalRef?: string;
};

const FOCUSABLE =
  'button:not(:disabled), input:not(:disabled), select:not(:disabled), textarea:not(:disabled), [href], [tabindex]:not([tabindex="-1"])';

// Whole VND typed by the cashier compared with a canonical server amount.
function shortOf(typed: string | null, amount: string): boolean | null {
  const expected = parseVndAmount(amount);
  if (typed === null || expected === null) return null;
  return BigInt(typed) < BigInt(expected);
}

export function TenderEvidenceDialog({
  workspace,
  attempts,
  disabled,
  busy,
  error,
  onConfirm,
  onCancel,
  onHold,
}: {
  workspace: PosWorkspace;
  attempts: PosFinancialAttempt[];
  disabled: boolean;
  busy: boolean;
  error: string;
  onConfirm: (inputs: TenderEvidenceItemInput[]) => Promise<boolean>;
  onCancel: () => Promise<boolean>;
  // Closes the dialog and keeps the prepared tenders for later.
  onHold: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const cashAttempt = attempts.find((item) => item.kind === 'cash');
  const bankAttempt = attempts.find((item) => item.kind === 'bank_manual');
  const currency = workspace.totals?.currency ?? attempts[0]?.currency ?? 'VND';
  const [handedInput, setHandedInput] = useState('');
  const [reference, setReference] = useState('');
  const [account, setAccount] = useState('');
  const [receivedInput, setReceivedInput] = useState('');
  const [confirmingCancel, setConfirmingCancel] = useState(false);
  const locked = disabled || busy;

  const handed = parseVndInput(handedInput);
  const handedInvalid = handedInput.trim() !== '' && handed === null;
  const handedShort = cashAttempt ? shortOf(handed, cashAttempt.amount) : null;
  const cashAmount = cashAttempt ? parseVndAmount(cashAttempt.amount) : null;
  const change =
    handed !== null && cashAmount !== null && handedShort === false
      ? String(BigInt(handed) - BigInt(cashAmount))
      : null;

  const received = parseVndInput(receivedInput);
  const receivedInvalid =
    receivedInput.trim() !== '' &&
    (received === null || (bankAttempt ? shortOf(received, bankAttempt.amount) !== false : false));

  const cashReady = !cashAttempt || (handed !== null && handedShort === false);
  const bankReady =
    !bankAttempt || (reference.trim() !== '' && account.trim() !== '' && !receivedInvalid);
  const ready = cashReady && bankReady;

  // Hold focus on the dialog itself while the command that opened it settles,
  // then move it to the first evidence field once the fields are enabled.
  useEffect(() => {
    const root = card.current;
    if (!root) return;
    const focused = document.activeElement;
    if (focused && focused !== root && root.contains(focused)) return;
    if (locked) {
      root.focus();
      return;
    }
    (
      root.querySelector<HTMLElement>('input:not(:disabled)') ??
      root.querySelector<HTMLElement>('button:not(:disabled)')
    )?.focus();
  }, [locked]);

  function trapFocus(event: KeyboardEvent<HTMLFormElement>) {
    if (event.key === 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      onHold();
      return;
    }
    if (event.key !== 'Tab' || !card.current) return;
    const items = [...card.current.querySelectorAll<HTMLElement>(FOCUSABLE)];
    if (items.length === 0) return;
    const first = items[0];
    const last = items[items.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }

  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="tender-evidence pos-popup-card payment-invoice-popup"
        onKeyDown={trapFocus}
        onSubmit={(event) => {
          event.preventDefault();
          if (locked || !ready) return;
          const inputs: TenderEvidenceItemInput[] = attempts.map((attempt) =>
            attempt.kind === 'cash'
              ? { attemptId: attempt.id, evidenceKind: 'cash_count', handedAmount: handed ?? '' }
              : {
                  attemptId: attempt.id,
                  evidenceKind: 'bank_manual',
                  reference: reference.trim(),
                  receivingAccount: account.trim(),
                  receivedAmount: received ?? undefined,
                },
          );
          void onConfirm(inputs);
        }}
      >
        <div className="pos-popup-header">
          <div>
            <h4 id={titleId}>
              {bankAttempt && !cashAttempt ? t('paymentBankTitle') : t('paymentInvoiceTitle')}
            </h4>
            <small className="muted">
              {workspace.order_id} · {workspace.customer?.name || t('customerWalkIn')}
            </small>
          </div>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onHold}
            aria-label={t('paymentHold')}
            title={t('paymentHold')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        {workspace.line_items?.length ? (
          <div className="invoice-items-scroll">
            <table className="invoice-items-table">
              <thead>
                <tr>
                  <th scope="col">{t('itemIndexColumn')}</th>
                  <th scope="col">{t('itemNameColumn')}</th>
                  <th scope="col">{t('itemQuantityColumn')}</th>
                  <th scope="col">{t('itemPriceColumn')}</th>
                  <th scope="col">{t('itemTotalColumn')}</th>
                </tr>
              </thead>
              <tbody>
                {workspace.line_items.map((line, index) => (
                  <tr key={line.id}>
                    <td>{index + 1}</td>
                    <td>{line.name}</td>
                    <td>{line.sale_quantity ?? line.quantity}</td>
                    <td>{formatMoney(line.unit_price ?? line.price, currency)}</td>
                    <td>
                      {formatMoney(
                        line.item_net_amount ?? line.net_amount ?? line.amount,
                        currency,
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}
        <div className="invoice-totals">
          {workspace.totals ? (
            <>
              <div className="invoice-line">
                <span>{t('subtotal')}</span>
                <span>{formatMoney(workspace.totals.item_total, currency)}</span>
              </div>
              <div className="invoice-line">
                <span>
                  {t('discount')}
                  {workspace.coupon ? ` (${workspace.coupon.code})` : ''}
                </span>
                <span>{formatMoney(workspace.totals.discount_total, currency)}</span>
              </div>
              <div className="invoice-line">
                <span>{t('orderTotal')}</span>
                <strong>{formatMoney(workspace.totals.total, currency)}</strong>
              </div>
            </>
          ) : null}
          {attempts.map((attempt) => (
            <div className="invoice-line invoice-line-highlight" key={attempt.id}>
              <span>{attempt.kind === 'cash' ? t('cash') : t('bankTransfer')}</span>
              <strong>{formatMoney(attempt.amount, attempt.currency)}</strong>
            </div>
          ))}
        </div>
        {cashAttempt ? (
          <>
            <label>
              {t('paymentHanded')}
              <input
                className="money-input"
                name="handed_amount"
                inputMode="numeric"
                autoComplete="off"
                value={handedInput}
                onChange={(event) => setHandedInput(event.target.value)}
                placeholder={cashAmount ?? undefined}
                aria-invalid={handedInvalid || handedShort === true}
                required
                disabled={locked}
              />
            </label>
            <div className="invoice-line" aria-live="polite">
              <span>{t('paymentChange')}</span>
              <strong>
                {handedInvalid
                  ? t('paymentAmountInvalid')
                  : handedShort
                    ? t('paymentHandedShort')
                    : change !== null
                      ? formatMoney(change, cashAttempt.currency)
                      : '—'}
              </strong>
            </div>
          </>
        ) : null}
        {bankAttempt ? (
          <>
            <div className="payment-qr-box">
              <div className="payment-qr-info">
                <strong>{formatMoney(bankAttempt.amount, bankAttempt.currency)}</strong>
                <span>
                  {t('paymentTransferContent')}: <strong>{workspace.order_id}</strong>
                </span>
                <small className="muted">{t('paymentBankCaption')}</small>
              </div>
            </div>
            <div className="payment-bank-fields">
              <label>
                {t('paymentReference')}
                <input
                  name="reference"
                  autoComplete="off"
                  value={reference}
                  onChange={(event) => setReference(event.target.value)}
                  required
                  disabled={locked}
                />
              </label>
              <label>
                {t('paymentAccount')}
                <input
                  name="receiving_account"
                  autoComplete="off"
                  value={account}
                  onChange={(event) => setAccount(event.target.value)}
                  required
                  disabled={locked}
                />
              </label>
              <label>
                {t('paymentReceivedAmount')}
                <input
                  className="money-input"
                  name="received_amount"
                  inputMode="numeric"
                  autoComplete="off"
                  value={receivedInput}
                  onChange={(event) => setReceivedInput(event.target.value)}
                  placeholder={parseVndAmount(bankAttempt.amount) ?? undefined}
                  aria-invalid={receivedInvalid}
                  aria-describedby={`${titleId}-received`}
                  disabled={locked}
                />
                <small className="muted" id={`${titleId}-received`}>
                  {receivedInvalid ? t('paymentReceivedInvalid') : t('paymentReceivedHint')}
                </small>
              </label>
            </div>
          </>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="payment-popup-actions">
          <button className="checkout-submit" type="submit" disabled={locked || !ready}>
            {t('paymentFinish')}
          </button>
          <button type="button" disabled={locked} onClick={() => window.print()}>
            {t('paymentPrint')}
          </button>
          <button
            type="button"
            className="primary-button"
            disabled={locked || !ready}
            onClick={(event) => {
              window.print();
              event.currentTarget.form?.requestSubmit();
            }}
          >
            {t('paymentPrintAndFinish')}
          </button>
        </div>
        <div className="payment-popup-secondary">
          <button type="button" onClick={onHold}>
            {t('paymentHoldAction')}
          </button>
          {confirmingCancel ? (
            <fieldset className="payment-cancel-confirm">
              <legend>{t('paymentCancelConfirm', { count: attempts.length })}</legend>
              <button
                type="button"
                className="danger-button"
                disabled={locked}
                onClick={() =>
                  void onCancel().then((done) => {
                    if (!done) setConfirmingCancel(false);
                  })
                }
              >
                {t('paymentCancelYes')}
              </button>
              <button type="button" onClick={() => setConfirmingCancel(false)}>
                {t('paymentCancelNo')}
              </button>
            </fieldset>
          ) : (
            <button type="button" disabled={locked} onClick={() => setConfirmingCancel(true)}>
              {t('paymentCancel')}
            </button>
          )}
        </div>
      </form>
    </div>
  );
}
