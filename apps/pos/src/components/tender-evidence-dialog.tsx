import { type KeyboardEvent, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useVietqrTender } from '../hooks/use-tenders';
import {
  invoiceTicketPrintDocument,
  lineDiscount,
  lineUnitPrice,
  type TicketPaper,
} from '../lib/invoice-ticket';
import { formatMoney, parseVndAmount, parseVndInput } from '../lib/money';
import type { PosFinancialAttempt, PosWorkspace } from '../lib/pos-context';
import { createBrowserPrintAdapter, printTitle } from '../lib/print-adapter';
import {
  type VietqrEvidenceKind,
  vietqrEvidence,
  vietqrReceived,
  vietqrTimeLeft,
} from '../lib/vietqr';
import { InvoiceTicketPrintPortal, InvoiceTicketSheet } from './invoice-ticket-sheet';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';

const printer = createBrowserPrintAdapter();
const PAPER_KEY = 'parkviet-pos:ticket-paper';

function savedPaper(): TicketPaper {
  try {
    return window.localStorage.getItem(PAPER_KEY) === '58mm' ? '58mm' : '80mm';
  } catch {
    return '80mm';
  }
}

export type TicketNames = {
  storeName?: string | null;
  branchName?: string | null;
  registerName?: string | null;
  cashier?: string | null;
};

export type TenderEvidenceItemInput = {
  attemptId: string;
  evidenceKind: 'cash_count' | 'bank_manual' | VietqrEvidenceKind;
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
  onShowVietqr,
  names = {},
  timeZone = 'Asia/Ho_Chi_Minh',
}: {
  names?: TicketNames;
  timeZone?: string;
  workspace: PosWorkspace;
  attempts: PosFinancialAttempt[];
  disabled: boolean;
  busy: boolean;
  error: string;
  onConfirm: (inputs: TenderEvidenceItemInput[]) => Promise<boolean>;
  onCancel: () => Promise<boolean>;
  // Closes the dialog and keeps the prepared tenders for later.
  onHold: () => void;
  // Present when VietQR is offered: turns the manual bank tender into a
  // VietQR tender of the same amount, so the QR shows here.
  onShowVietqr?: () => Promise<boolean>;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const cashAttempt = attempts.find((item) => item.kind === 'cash');
  const bankAttempt = attempts.find((item) => item.kind === 'bank_manual');
  const qrAttempt = attempts.find((item) => item.kind === 'vietqr');
  const qrQuery = useVietqrTender(workspace.id, qrAttempt?.id ?? null);
  const qr = qrQuery.data ?? null;
  const qrReceived = vietqrReceived(qr);
  const [qrManual, setQrManual] = useState(false);
  const [qrReference, setQrReference] = useState('');
  const [qrAccount, setQrAccount] = useState('');
  const qrInput = vietqrEvidence(
    qr,
    qrManual ? { reference: qrReference, account: qrAccount || (qr?.account_number ?? '') } : null,
  );
  const [now, setNow] = useState(() => Date.now());
  const qrTimeLeft = vietqrTimeLeft(qr?.expires_at, now);
  const finishButton = useRef<HTMLButtonElement>(null);
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
  const qrReady = !qrAttempt || qrInput !== null;
  const ready = cashReady && bankReady && qrReady;

  const handedId = useId();
  const [paper, setPaper] = useState<TicketPaper>(savedPaper);
  const [printError, setPrintError] = useState('');
  // The store's address and phone, and the branch, from the POS context.
  const context = usePosSelection().context.data;
  const branch = context?.branches.find((row) => row.id === workspace.branch_id);
  const ticket = invoiceTicketPrintDocument(
    {
      workspace,
      attempts,
      handed: handed !== null && handedShort === false ? handed : null,
      change,
      names: {
        ...names,
        storeProfile: context?.store.profile,
        branchCode: branch?.code,
        returnWindowDays: branch?.return_window_days,
      },
    },
    t,
    new Date(now),
    timeZone,
  );

  function choosePaper(size: TicketPaper) {
    setPaper(size);
    try {
      window.localStorage.setItem(PAPER_KEY, size);
    } catch {
      // Storage may be unavailable; the choice still applies to this print.
    }
  }

  async function printTicket() {
    const outcome = await printer.deliver(paper, {
      title: printTitle(t('receiptPrintTitle_sale'), null, workspace.order_id, t),
    });
    setPrintError(
      outcome.ok
        ? ''
        : t(outcome.reason === 'blocked' ? 'ticketPrintBlocked' : 'ticketPrintFailed'),
    );
    return outcome.ok;
  }

  // The customer handed exactly the cash due: fill it and go to "Finish".
  const focusFinishNext = useRef(false);
  function handExact() {
    if (cashAmount === null) return;
    focusFinishNext.current = true;
    setHandedInput(cashAmount);
  }
  // "Finish" is only enabled after the render that fills the amount.
  useEffect(() => {
    if (!focusFinishNext.current) return;
    focusFinishNext.current = false;
    if (ready) finishButton.current?.focus();
  });

  // "Confirm transfer received": the cashier's word is enough, so finishing
  // is one key press away; the bank details below are optional notes.
  const qrSaveButton = useRef<HTMLButtonElement>(null);
  const focusQrSave = useRef(false);
  function startQrManual() {
    focusQrSave.current = true;
    setQrManual(true);
  }
  useEffect(() => {
    if (!qrManual || !focusQrSave.current) return;
    focusQrSave.current = false;
    // Still disabled while another tender (cash handed) is incomplete.
    (qrSaveButton.current?.disabled ? null : qrSaveButton.current)?.focus();
  }, [qrManual]);

  // The QR counts down while the bank has not reported the transfer.
  useEffect(() => {
    if (!qrAttempt || qrReceived) return;
    const timer = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, [qrAttempt, qrReceived]);

  // Once the bank reports the money, finishing is one key press away.
  useEffect(() => {
    if (qrReceived) finishButton.current?.focus();
  }, [qrReceived]);

  function label(kind: string) {
    return kind === 'cash' ? t('cash') : kind === 'vietqr' ? t('vietqr') : t('bankTransfer');
  }

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
              : attempt.kind === 'vietqr' && qrInput
                ? { attemptId: attempt.id, ...qrInput }
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
              {qrAttempt && attempts.length === 1
                ? t('paymentVietqrTitle')
                : bankAttempt && !cashAttempt
                  ? t('paymentBankTitle')
                  : t('paymentInvoiceTitle')}
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
        <div className="payment-invoice-body">
          <div className="payment-invoice-main">
            {workspace.line_items?.length ? (
              <div className="invoice-items-scroll">
                <table className="invoice-items-table">
                  <thead>
                    <tr>
                      <th scope="col">{t('itemIndexColumn')}</th>
                      <th scope="col">{t('itemNameColumn')}</th>
                      <th scope="col">{t('itemQuantityColumn')}</th>
                      <th scope="col">{t('itemPriceColumn')}</th>
                      <th scope="col">{t('itemDiscountColumn')}</th>
                      <th scope="col">{t('itemTotalColumn')}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {workspace.line_items.map((line, index) => {
                      const discount = lineDiscount(line);
                      return (
                        <tr key={line.id}>
                          <td>{index + 1}</td>
                          <td>{line.name}</td>
                          <td>{line.sale_quantity ?? line.quantity}</td>
                          <td>{formatMoney(lineUnitPrice(line), currency)}</td>
                          <td className={discount ? 'invoice-discount' : 'muted'}>
                            {discount ? `−${formatMoney(discount, currency)}` : '—'}
                          </td>
                          <td>
                            {formatMoney(
                              line.item_net_amount ?? line.net_amount ?? line.amount,
                              currency,
                            )}
                          </td>
                        </tr>
                      );
                    })}
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
                  <span>{label(attempt.kind)}</span>
                  <strong>{formatMoney(attempt.amount, attempt.currency)}</strong>
                </div>
              ))}
            </div>
            {cashAttempt ? (
              <>
                <div className="payment-handed-field">
                  <label htmlFor={handedId}>{t('paymentHanded')}</label>
                  <div className="payment-handed-row">
                    <input
                      id={handedId}
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
                    <button
                      type="button"
                      className="payment-handed-exact"
                      disabled={locked || cashAmount === null}
                      onClick={handExact}
                      title={t('paymentHandedExactHint')}
                    >
                      {t('paymentHandedExact')}
                    </button>
                  </div>
                </div>
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
                    {onShowVietqr ? (
                      <>
                        <button
                          type="button"
                          className="primary-button payment-show-vietqr"
                          disabled={locked}
                          onClick={() => void onShowVietqr()}
                        >
                          <PosIcon name="qr" />
                          {t('paymentShowVietqr')}
                        </button>
                        <small className="muted">{t('paymentShowVietqrHint')}</small>
                      </>
                    ) : null}
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
            {qrAttempt ? (
              <>
                <div className="payment-qr-box payment-vietqr">
                  {qr?.qr_url && !qrReceived ? (
                    <img
                      className="payment-qr-image"
                      src={qr.qr_url}
                      alt={t('vietqrImageAlt')}
                      width={220}
                      height={220}
                    />
                  ) : null}
                  <div className="payment-qr-info">
                    <strong>{formatMoney(qrAttempt.amount, qrAttempt.currency)}</strong>
                    {qr ? (
                      <>
                        <span>
                          {qr.bank_name} · <strong>{qr.account_number}</strong>
                        </span>
                        <span>{qr.account_name}</span>
                        <span>
                          {t('paymentTransferContent')}: <strong>{qr.transfer_content}</strong>
                        </span>
                      </>
                    ) : null}
                    <p
                      className={qrReceived ? 'vietqr-status received' : 'vietqr-status'}
                      role="status"
                    >
                      {qrQuery.isLoading
                        ? t('waiting')
                        : qrQuery.isError
                          ? t('vietqrStatusUnknown')
                          : qrReceived
                            ? t('vietqrReceived')
                            : qrTimeLeft
                              ? t('vietqrWaiting', { time: qrTimeLeft })
                              : t('vietqrExpired')}
                    </p>
                    {/* The bank has not reported the transfer: the cashier who
                        saw the money arrive attests it with the bank's ref. */}
                    {!qrReceived && !qrManual ? (
                      <button
                        type="button"
                        className="vietqr-manual-start"
                        disabled={locked}
                        onClick={startQrManual}
                      >
                        <PosIcon name="check" />
                        {t('vietqrManualConfirm')}
                      </button>
                    ) : null}
                  </div>
                </div>
                {!qrReceived && qrManual ? (
                  <div className="vietqr-manual">
                    <strong>{t('vietqrManual')}</strong>
                    <small className="muted">{t('vietqrManualHint')}</small>
                    <div className="payment-bank-fields">
                      <label>
                        {t('vietqrManualReference')}
                        <input
                          name="vietqr_reference"
                          autoComplete="off"
                          value={qrReference}
                          onChange={(event) => setQrReference(event.target.value)}
                          disabled={locked}
                        />
                      </label>
                      <label>
                        {t('vietqrManualAccount')}
                        <input
                          name="vietqr_receiving_account"
                          autoComplete="off"
                          value={qrAccount}
                          placeholder={qr?.account_number ?? undefined}
                          onChange={(event) => setQrAccount(event.target.value)}
                          disabled={locked}
                        />
                      </label>
                    </div>
                    {/* Saving confirms the payment, the same as "Finish". */}
                    <button
                      ref={qrSaveButton}
                      type="submit"
                      className="checkout-submit vietqr-manual-save"
                      disabled={locked || !ready}
                    >
                      {t('vietqrManualSave')}
                    </button>
                  </div>
                ) : null}
              </>
            ) : null}
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </div>
          <aside className="payment-invoice-preview" aria-label={t('ticketPreview')}>
            <div className="payment-invoice-preview-head">
              <strong>{t('ticketPreview')}</strong>
              <fieldset className="segmented ticket-paper">
                <legend className="visually-hidden">{t('receiptPaper')}</legend>
                {(['58mm', '80mm'] as const).map((size) => (
                  <button
                    key={size}
                    type="button"
                    aria-pressed={paper === size}
                    onClick={() => choosePaper(size)}
                  >
                    {size}
                  </button>
                ))}
              </fieldset>
            </div>
            <div className="receipt-preview">
              <InvoiceTicketSheet document={ticket} paper={paper} />
            </div>
            {printError ? (
              <p className="error" role="alert">
                {printError}
              </p>
            ) : null}
          </aside>
        </div>
        <InvoiceTicketPrintPortal document={ticket} paper={paper} />
        <div className="payment-popup-actions payment-popup-row">
          <button
            ref={finishButton}
            className="checkout-submit"
            type="submit"
            disabled={locked || !ready}
          >
            {t('paymentFinish')}
          </button>
          <button type="button" disabled={locked} onClick={() => void printTicket()}>
            {t('paymentPrint')}
          </button>
          <button
            type="button"
            className="primary-button"
            disabled={locked || !ready}
            onClick={(event) => {
              const form = event.currentTarget.form;
              // A blocked or failed print never stops the sale from finishing.
              void printTicket().then(() => form?.requestSubmit());
            }}
          >
            {t('paymentPrintAndFinish')}
          </button>
          {!confirmingCancel ? (
            <button type="button" disabled={locked} onClick={() => setConfirmingCancel(true)}>
              {t('paymentCancel')}
            </button>
          ) : null}
          {/* Only closes the dialog: the prepared tenders stay for later. */}
          <button type="button" onClick={onHold}>
            {t('paymentHoldAction')}
          </button>
        </div>
        {confirmingCancel ? (
          <div className="payment-popup-secondary">
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
          </div>
        ) : null}
      </form>
    </div>
  );
}
