import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { CollectInput } from '../hooks/use-receivables';
import { useModalFocus } from '../lib/dialog-focus';
import { formatMoney, parseVndInput } from '../lib/money';
import { payLaterQr } from '../lib/pay-later';
import type { PosCollection, PosReceivable, PosReceivableAccount } from '../lib/pos-context';
import {
  type AllocationDraft,
  cashChange,
  formatDueDate,
  planAllocations,
  previewAllocations,
} from '../lib/receivables';
import { PayLaterShareButton } from './pay-later-share-button';
import { PosIcon } from './pos-icon';

type Kind = 'cash' | 'bank_manual';

// One actual receipt from the customer, split across their open credit orders.
// The preview mirrors the server's bounds: never more than was collected,
// never more than an order still owes; the rest stays on the receipt.
export function CollectionDialog({
  account,
  debts,
  branchId,
  busy,
  error,
  done,
  onSubmit,
  onClose,
}: {
  account: PosReceivableAccount;
  debts: PosReceivable[];
  branchId: string;
  busy: boolean;
  error: string;
  // The recorded collection; the dialog then only reports it.
  done: { collection: PosCollection; recovered: boolean } | null;
  onSubmit: (input: CollectInput) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const inFlight = useRef(false);
  const [kind, setKind] = useState<Kind>('cash');
  const [amountInput, setAmountInput] = useState('');
  const [handedInput, setHandedInput] = useState('');
  const [reference, setReference] = useState('');
  const [receivingAccount, setReceivingAccount] = useState('');
  const [note, setNote] = useState('');
  const [rows, setRows] = useState<Record<string, string>>({});
  const [edited, setEdited] = useState(false);
  const currency = account.currency;
  const debtRows = debts.map((debt) => ({ orderId: debt.order_id, balance: debt.balance }));
  const locked = busy || done !== null;

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  const amount = parseVndInput(amountInput);
  const amountInvalid = amountInput.trim() !== '' && (amount === null || amount === '0');
  const handedTyped = handedInput.trim() !== '';
  const handedParsed = handedTyped ? parseVndInput(handedInput) : amount;
  const handedFormatInvalid = handedTyped && handedParsed === null;
  const change = kind === 'cash' ? cashChange(handedParsed, amount) : '0';
  const handedShort =
    kind === 'cash' && !handedFormatInvalid && handedTyped && amount !== null && change === null;

  function autoFill(value: string | null) {
    const plan = value ? planAllocations(value, debtRows) : [];
    setRows(Object.fromEntries(plan.map((row) => [row.orderId, row.amount])));
  }

  // Only orders still listed as open debts can receive money.
  const drafts: AllocationDraft[] = debts
    .map((debt) => [debt.order_id, rows[debt.order_id] ?? ''] as const)
    .filter(([, raw]) => raw.trim() !== '')
    .map(([orderId, raw]) => ({ orderId, amount: parseVndInput(raw) ?? 'invalid' }));
  const preview = previewAllocations(amount ?? '0', drafts, debtRows);
  const bankReady = kind === 'cash' || (reference.trim() !== '' && receivingAccount.trim() !== '');
  const ready =
    amount !== null &&
    amount !== '0' &&
    change !== null &&
    bankReady &&
    !preview.exceedsReceipt &&
    preview.overDebt.length === 0 &&
    preview.invalid.length === 0;

  let changeText = '—';
  if (handedFormatInvalid) changeText = t('paymentAmountInvalid');
  else if (handedShort) changeText = t('paymentHandedShort');
  else if (change !== null) changeText = formatMoney(change, currency);

  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card collection-dialog"
        onSubmit={(event) => {
          event.preventDefault();
          if (locked || !ready || amount === null || inFlight.current) return;
          inFlight.current = true;
          void onSubmit({
            branchId,
            creditAccountId: account.credit_account_id,
            kind,
            amount,
            handedAmount: kind === 'cash' ? (handedParsed ?? amount) : undefined,
            reference: reference.trim() || undefined,
            receivingAccount: receivingAccount.trim() || undefined,
            note: note.trim() || undefined,
            allocations: drafts,
          }).finally(() => {
            inFlight.current = false;
          });
        }}
      >
        <div className="pos-popup-header">
          <div>
            <h4 id={titleId}>{t('collectionTitle', { name: account.customer.name })}</h4>
            <small className="muted">
              {t('receivablesBalance')}: {formatMoney(account.balance, currency)}
            </small>
          </div>
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
        {done ? (
          <div className="payment-held" role="status">
            <p>
              {t(done.recovered ? 'collectionRecovered' : 'collectionDone', {
                amount: formatMoney(
                  done.collection.funds.received_net,
                  done.collection.funds.currency,
                ),
              })}
            </p>
            <p className="muted">
              {t('collectionUnallocated')}:{' '}
              {formatMoney(done.collection.funds.available, done.collection.funds.currency)}
            </p>
          </div>
        ) : (
          <>
            <fieldset className="payment-methods" aria-label={t('collectionKind')}>
              {(['cash', 'bank_manual'] as const).map((value) => (
                <button
                  type="button"
                  key={value}
                  aria-pressed={kind === value}
                  disabled={locked}
                  onClick={() => setKind(value)}
                >
                  <PosIcon name={value === 'cash' ? 'cash' : 'bank'} />
                  {t(value === 'cash' ? 'cash' : 'bankTransfer')}
                </button>
              ))}
            </fieldset>
            <label>
              {t('collectionAmount')}
              <input
                className="money-input"
                inputMode="numeric"
                autoComplete="off"
                value={amountInput}
                aria-invalid={amountInvalid}
                disabled={locked}
                required
                onChange={(event) => {
                  setAmountInput(event.target.value);
                  if (!edited) autoFill(parseVndInput(event.target.value));
                }}
              />
            </label>
            {kind === 'cash' ? (
              <>
                <label>
                  {t('paymentHanded')}
                  <input
                    className="money-input"
                    inputMode="numeric"
                    autoComplete="off"
                    value={handedInput}
                    placeholder={amount ?? undefined}
                    aria-invalid={handedShort || handedFormatInvalid}
                    disabled={locked}
                    onChange={(event) => setHandedInput(event.target.value)}
                  />
                </label>
                <div className="invoice-line" aria-live="polite">
                  <span>{t('collectionChange')}</span>
                  <strong>{changeText}</strong>
                </div>
              </>
            ) : (
              <div className="payment-bank-fields">
                <label>
                  {t('paymentReference')}
                  <input
                    autoComplete="off"
                    value={reference}
                    required
                    disabled={locked}
                    onChange={(event) => setReference(event.target.value)}
                  />
                </label>
                <label>
                  {t('paymentAccount')}
                  <input
                    autoComplete="off"
                    value={receivingAccount}
                    required
                    disabled={locked}
                    onChange={(event) => setReceivingAccount(event.target.value)}
                  />
                </label>
              </div>
            )}
            <fieldset className="collection-allocations">
              <legend>{t('collectionAllocations')}</legend>
              <button
                type="button"
                disabled={locked || amount === null}
                onClick={() => {
                  setEdited(false);
                  autoFill(amount);
                }}
              >
                {t('collectionAutoFill')}
              </button>
              <table className="invoice-items-table">
                <thead>
                  <tr>
                    <th scope="col">{t('receivablesOrders')}</th>
                    <th scope="col">{t('receivablesDue')}</th>
                    <th scope="col">{t('receivablesBalance')}</th>
                    <th scope="col">{t('collectionAllocated')}</th>
                  </tr>
                </thead>
                <tbody>
                  {debts.map((debt) => {
                    const invalid =
                      preview.invalid.includes(debt.order_id) ||
                      preview.overDebt.includes(debt.order_id);
                    const payQr = payLaterQr(debt.pay_later);
                    return (
                      <tr key={debt.order_id}>
                        <td>
                          {debt.order_number}
                          {payQr ? (
                            <PayLaterShareButton qr={payQr} label={t('payLaterShareShort')} />
                          ) : null}
                        </td>
                        <td>{formatDueDate(debt.due_on)}</td>
                        <td>{formatMoney(debt.balance, debt.currency)}</td>
                        <td>
                          <input
                            className="money-input"
                            inputMode="numeric"
                            autoComplete="off"
                            aria-label={`${t('collectionAllocated')} ${debt.order_number}`}
                            value={rows[debt.order_id] ?? ''}
                            aria-invalid={invalid}
                            disabled={locked}
                            onChange={(event) => {
                              setEdited(true);
                              setRows((current) => ({
                                ...current,
                                [debt.order_id]: event.target.value,
                              }));
                            }}
                          />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </fieldset>
            <div className="invoice-totals" aria-live="polite">
              <div className="invoice-line">
                <span>{t('collectionAllocated')}</span>
                <strong>{formatMoney(preview.allocated, currency)}</strong>
              </div>
              <div className="invoice-line">
                <span>{t('collectionUnallocated')}</span>
                <strong>{formatMoney(preview.unallocated, currency)}</strong>
              </div>
            </div>
            {preview.exceedsReceipt ? (
              <p className="error">{t('collectionExceedsReceipt')}</p>
            ) : null}
            {preview.overDebt.length > 0 ? (
              <p className="error">{t('collectionOverDebt')}</p>
            ) : null}
            {preview.invalid.length > 0 || amountInvalid ? (
              <p className="error">{t('collectionInvalidRow')}</p>
            ) : null}
            <label>
              {t('collectionNote')}
              <input
                value={note}
                maxLength={200}
                disabled={locked}
                onChange={(event) => setNote(event.target.value)}
              />
            </label>
            <p className="muted">{t('collectionNoSales')}</p>
          </>
        )}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="payment-popup-actions">
          {done ? null : (
            <button className="checkout-submit" type="submit" disabled={locked || !ready}>
              {busy ? t('waiting') : t('collectionSubmit')}
            </button>
          )}
          <button type="button" disabled={busy} onClick={onClose}>
            {t('creditClose')}
          </button>
        </div>
      </form>
    </div>
  );
}
