import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosFinancialAttempt, PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

export type TenderEvidenceItemInput = {
  attemptId: string;
  evidenceKind: 'cash_count' | 'bank_manual';
  handedAmount?: string;
  reference?: string;
  receivingAccount?: string;
  terminalRef?: string;
};

export function TenderEvidenceDialog({
  workspace,
  attempts,
  disabled,
  busy,
  onConfirm,
  onCancel,
  labels,
}: {
  workspace: PosWorkspace;
  attempts: PosFinancialAttempt[];
  disabled: boolean;
  busy: boolean;
  onConfirm: (inputs: TenderEvidenceItemInput[]) => Promise<void>;
  onCancel: () => Promise<void>;
  labels: {
    cancel: string;
    handed: string;
    reference: string;
    account: string;
  };
}) {
  const { t } = useTranslation();
  const cashAttempt = attempts.find((item) => item.kind === 'cash');
  const bankAttempt = attempts.find((item) => item.kind === 'bank_manual');
  const currency = workspace.totals?.currency ?? attempts[0]?.currency ?? 'VND';
  const [handedInput, setHandedInput] = useState(
    () => (cashAttempt ? parseVndAmount(cashAttempt.amount) : '') ?? '',
  );
  const parsedHanded = Number(
    parseVndAmount(handedInput) ?? (cashAttempt ? cashAttempt.amount : 0),
  );
  const changePreview = cashAttempt ? Math.max(parsedHanded - Number(cashAttempt.amount), 0) : 0;

  return (
    <div className="pos-popup-backdrop">
      <form
        className="tender-evidence pos-popup-card payment-invoice-popup"
        onSubmit={(event) => {
          event.preventDefault();
          const form = new FormData(event.currentTarget);
          const inputs: TenderEvidenceItemInput[] = [];
          for (const attempt of attempts) {
            if (attempt.kind === 'cash') {
              inputs.push({
                attemptId: attempt.id,
                evidenceKind: 'cash_count',
                handedAmount: String(form.get('handed_amount') ?? '') || undefined,
              });
            } else {
              inputs.push({
                attemptId: attempt.id,
                evidenceKind: 'bank_manual',
                reference: String(form.get('reference') ?? '') || undefined,
                receivingAccount: String(form.get('receiving_account') ?? '') || undefined,
              });
            }
          }
          void onConfirm(inputs);
        }}
      >
        <div className="pos-popup-header">
          <div>
            <h4>{bankAttempt && !cashAttempt ? t('paymentQrTitle') : t('paymentInvoiceTitle')}</h4>
            <small className="muted">
              {workspace.order_id} · {workspace.customer?.name || t('customerWalkIn')}
            </small>
          </div>
          <button
            type="button"
            className="cell-edit-button"
            disabled={disabled || busy}
            onClick={() => void onCancel()}
            aria-label={labels.cancel}
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
              {labels.handed}
              <input
                className="money-input"
                name="handed_amount"
                inputMode="numeric"
                value={handedInput}
                onChange={(event) => setHandedInput(event.target.value)}
                placeholder={parseVndAmount(cashAttempt.amount) ?? cashAttempt.amount}
                required
                disabled={disabled || busy}
              />
            </label>
            <div className="invoice-line">
              <span>{t('paymentChange')}</span>
              <strong>{formatMoney(String(changePreview), cashAttempt.currency)}</strong>
            </div>
          </>
        ) : null}
        {bankAttempt ? (
          <>
            <div className="payment-qr-box">
              <svg
                className="payment-qr-svg"
                viewBox="0 0 120 120"
                role="img"
                aria-label={t('paymentQrTitle')}
              >
                <rect width="120" height="120" rx="8" fill="#ffffff" stroke="#d5e0e8" />
                <rect
                  x="10"
                  y="10"
                  width="32"
                  height="32"
                  fill="none"
                  stroke="#172d40"
                  strokeWidth="6"
                />
                <rect x="20" y="20" width="12" height="12" fill="#172d40" />
                <rect
                  x="78"
                  y="10"
                  width="32"
                  height="32"
                  fill="none"
                  stroke="#172d40"
                  strokeWidth="6"
                />
                <rect x="88" y="20" width="12" height="12" fill="#172d40" />
                <rect
                  x="10"
                  y="78"
                  width="32"
                  height="32"
                  fill="none"
                  stroke="#172d40"
                  strokeWidth="6"
                />
                <rect x="20" y="88" width="12" height="12" fill="#172d40" />
                <rect x="52" y="12" width="6" height="6" fill="#172d40" />
                <rect x="64" y="12" width="6" height="18" fill="#172d40" />
                <rect x="52" y="26" width="8" height="8" fill="#172d40" />
                <rect x="12" y="52" width="18" height="6" fill="#172d40" />
                <rect x="36" y="48" width="12" height="12" fill="#0d65a8" />
                <rect x="54" y="46" width="16" height="16" fill="#172d40" />
                <rect x="76" y="52" width="12" height="6" fill="#172d40" />
                <rect x="94" y="48" width="14" height="12" fill="#172d40" />
                <rect x="48" y="68" width="12" height="12" fill="#172d40" />
                <rect x="66" y="68" width="18" height="6" fill="#172d40" />
                <rect x="90" y="68" width="18" height="18" fill="#172d40" />
                <rect x="52" y="86" width="14" height="6" fill="#172d40" />
                <rect x="72" y="82" width="12" height="14" fill="#172d40" />
                <rect x="50" y="98" width="22" height="10" fill="#172d40" />
                <rect x="80" y="102" width="28" height="6" fill="#172d40" />
              </svg>
              <div className="payment-qr-info">
                <strong>{formatMoney(bankAttempt.amount, bankAttempt.currency)}</strong>
                <span>
                  {t('paymentTransferContent')}: <strong>{workspace.order_id}</strong>
                </span>
                <small className="muted">{t('paymentQrCaption')}</small>
              </div>
            </div>
            <div className="payment-bank-fields">
              <label>
                {labels.reference}
                <input
                  name="reference"
                  defaultValue={`CK-${workspace.order_id}`}
                  required
                  disabled={disabled || busy}
                />
              </label>
              <label>
                {labels.account}
                <input
                  name="receiving_account"
                  defaultValue="VCB - ParkViet POS"
                  required
                  disabled={disabled || busy}
                />
              </label>
            </div>
          </>
        ) : null}
        <div className="payment-popup-actions">
          <button className="checkout-submit" type="submit" disabled={disabled || busy}>
            {t('paymentFinish')}
          </button>
          <button type="button" disabled={disabled || busy} onClick={() => window.print()}>
            {t('paymentPrint')}
          </button>
          <button
            type="button"
            className="primary-button"
            disabled={disabled || busy}
            onClick={(event) => {
              window.print();
              event.currentTarget.form?.requestSubmit();
            }}
          >
            {t('paymentPrintAndFinish')}
          </button>
        </div>
      </form>
    </div>
  );
}
