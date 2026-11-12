import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintPortal } from '../components/receipt-sheet';
import {
  useMealAccount,
  useMealAccountCommands,
  useMealAccounts,
  useMealEntries,
} from '../hooks/use-meal-accounts';
import { usePrintRoute } from '../hooks/use-print-jobs';
import {
  MEAL_ACCOUNTS_MODULE,
  type MealAccount,
  mealReasonKey,
  parseSignedVnd,
} from '../lib/meal-accounts';
import { writesLocked } from '../lib/pos-context';
import { createBrowserPrintAdapter } from '../lib/print-adapter';
import { deliverDirect } from '../lib/print-adapters';
import { creditConflictKey } from '../lib/receivables';
import { conflictReason, describeFailure } from '../lib/request-failure';

const printer = createBrowserPrintAdapter();
const SLIP_PAPER = '80mm';

type StatusFilter = 'active' | 'locked' | 'all';

function when(iso: string, language: string) {
  return iso ? new Date(iso).toLocaleString(language) : '';
}

export function MealAccountsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <MealAccounts key={scope} />;
}

// A wallet command's refusal in the counter's words.
function useExplain() {
  const { t } = useTranslation();
  return (failure: unknown) => {
    const reason = conflictReason(failure);
    const key = mealReasonKey(reason) ?? creditConflictKey(reason);
    return key ? t(key) : describeFailure(failure, t);
  };
}

function MealAccounts() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const capabilities = data?.capabilities ?? [];
  const enabled = data?.modules?.[MEAL_ACCOUNTS_MODULE] === true;
  const [query, setQuery] = useState('');
  const [status, setStatus] = useState<StatusFilter>('active');
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const search = useRef<HTMLInputElement>(null);
  const list = useMealAccounts(branchId, query, status, enabled);
  const rows = list.data ?? [];

  useEffect(() => {
    search.current?.focus();
  }, []);

  return (
    <PosPage title={t('mealAccountsTitle')} description={t('mealAccountsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.fnb_meal_accounts.off')} />
      ) : (
        <div className="meal-accounts">
          <div className="page-toolbar">
            <label className="tab-list-search">
              {t('mealAccountsSearch')}
              <input
                ref={search}
                type="search"
                value={query}
                maxLength={60}
                placeholder={t('mealAccountsSearchPlaceholder')}
                onChange={(event) => setQuery(event.target.value)}
                onKeyDown={(event) => {
                  if (event.key === 'Enter' && rows.length === 1) setSelectedId(rows[0].id);
                }}
              />
            </label>
            <label>
              {t('mealAccountsStatus')}
              <select
                value={status}
                onChange={(event) => setStatus(event.target.value as StatusFilter)}
              >
                <option value="active">{t('mealAccountStatus_active')}</option>
                <option value="locked">{t('mealAccountStatus_locked')}</option>
                <option value="all">{t('mealAccountsAll')}</option>
              </select>
            </label>
          </div>
          {list.isError ? <PageState kind="error" title={describeFailure(list.error, t)} /> : null}
          {list.isSuccess && rows.length === 0 ? (
            <PageState
              kind="empty"
              title={query.trim() ? t('mealAccountsNoMatch') : t('mealAccountsEmpty')}
            />
          ) : null}
          {rows.length > 0 ? (
            <table className="tab-list-table" aria-label={t('mealAccountsList')}>
              <thead>
                <tr>
                  <th scope="col">{t('mealAccountCode')}</th>
                  <th scope="col">{t('mealAccountName')}</th>
                  <th scope="col">{t('mealAccountGroup')}</th>
                  <th scope="col">{t('mealAccountSponsor')}</th>
                  <th scope="col" className="numeric">
                    {t('mealBalance')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} aria-selected={row.id === selectedId}>
                    <td>
                      <button
                        type="button"
                        className="link-button"
                        onClick={() => setSelectedId(row.id)}
                      >
                        {row.employee_code}
                      </button>
                    </td>
                    <td>
                      {row.name}
                      {row.status === 'locked' ? (
                        <small className="muted"> · {t('mealAccountStatus_locked')}</small>
                      ) : null}
                    </td>
                    <td>{row.group_label ?? '—'}</td>
                    <td>{row.sponsor?.name ?? '—'}</td>
                    <td className="numeric">{formatMoney(row.balance, row.currency)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : null}
          {selectedId ? (
            <MealAccountDetail
              key={selectedId}
              id={selectedId}
              branchId={branchId}
              registerId={selection.registerId}
              locked={writesLocked(data, selection)}
              canTopUp={
                capabilities.includes('pos.payment.collect') &&
                Boolean(data?.shift && data.shift.owner_id === data.staff.id)
              }
              canRequest={
                capabilities.includes('pos.meal_account.manage') ||
                capabilities.includes('pos.shift.open')
              }
              canApprove={capabilities.includes('pos.approval.grant')}
              onClose={() => setSelectedId(null)}
            />
          ) : null}
        </div>
      )}
    </PosPage>
  );
}

function MealAccountDetail({
  id,
  branchId,
  registerId,
  locked,
  canTopUp,
  canRequest,
  canApprove,
  onClose,
}: {
  id: string;
  branchId: string;
  registerId: string | null;
  locked: boolean;
  canTopUp: boolean;
  canRequest: boolean;
  canApprove: boolean;
  onClose: () => void;
}) {
  const { t, i18n } = useTranslation();
  const { context } = usePosSelection();
  const query = useMealAccount(branchId, id);
  const entries = useMealEntries(branchId, id);
  const commands = useMealAccountCommands(
    branchId,
    context.data?.staff.id ?? null,
    context.data?.store.id ?? null,
  );
  const account = query.data ?? null;
  const route = usePrintRoute(branchId, registerId, 'receipt').route;
  const [slip, setSlip] = useState<PrintDocument | null>(null);
  const [notice, setNotice] = useState('');
  const [printError, setPrintError] = useState('');

  // A browser-printed slip prints once its sheet is on the page.
  useEffect(() => {
    if (!slip) return;
    void printer.deliver(SLIP_PAPER).then((outcome) => {
      if (!outcome.ok) setPrintError(t('mealTopUpPrintFailed'));
      setSlip(null);
    });
  }, [slip, t]);

  // The slip goes to the register's LAN printer when it has one, else the browser.
  async function printSlip(document: PrintDocument) {
    setPrintError('');
    if (route.kind === 'direct') {
      const outcome = await deliverDirect(route.printer, document);
      if (outcome.ok) return;
      setPrintError(t(`printOutcome_${outcome.reason}`, { printer: route.printer.name }));
    }
    setSlip(document);
  }

  async function done(text: string) {
    setNotice(text);
    await Promise.all([query.refetch(), entries.refetch()]);
  }

  if (query.isLoading) return <PageState kind="loading" title={t('waiting')} />;
  if (!account) return <PageState kind="error" title={describeFailure(query.error, t)} />;
  const writable = !locked && account.status === 'active';
  return (
    <section
      className="meal-account-detail"
      aria-label={t('mealAccountDetail', { code: account.employee_code })}
    >
      <div className="pos-popup-header">
        <h3>
          {account.employee_code} · {account.name}
        </h3>
        <button type="button" onClick={onClose}>
          {t('adminClose')}
        </button>
      </div>
      <dl className="meal-account-summary">
        <dt>{t('mealBalance')}</dt>
        <dd data-testid="meal-account-balance">{formatMoney(account.balance, account.currency)}</dd>
        <dt>{t('mealAccountGroup')}</dt>
        <dd>{account.group_label ?? '—'}</dd>
        <dt>{t('mealAccountSponsor')}</dt>
        <dd>{account.sponsor?.name ?? '—'}</dd>
        <dt>{t('mealAccountPayMode')}</dt>
        <dd>{t(`mealPayMode_${account.pay_mode}`)}</dd>
        <dt>{t('mealAccountDailyLimit')}</dt>
        <dd>{account.daily_meal_limit ?? t('mealNoLimit')}</dd>
        <dt>{t('mealAccountsStatus')}</dt>
        <dd>{t(`mealAccountStatus_${account.status}`)}</dd>
      </dl>
      {canTopUp ? (
        <TopUpForm
          disabled={!writable}
          onTopUp={async (input) => {
            const result = await commands.topUp(account, input);
            await done(t('mealTopUpDone'));
            if (result.document) await printSlip(result.document);
          }}
        />
      ) : (
        <p className="muted">{t('mealTopUpNeedsShift')}</p>
      )}
      {canRequest ? (
        <>
          <RefundForm
            account={account}
            disabled={locked}
            canApprove={canApprove}
            onRefund={async (input) => {
              await commands.refund(account, input);
              await done(t('mealRefundDone'));
            }}
          />
          <AdjustForm
            disabled={locked}
            canApprove={canApprove}
            onAdjust={async (input) => {
              await commands.adjust(account, input);
              await done(t('mealAdjustDone'));
            }}
          />
        </>
      ) : null}
      {notice ? <p role="status">{notice}</p> : null}
      {printError ? (
        <p className="error" role="alert">
          {printError}
        </p>
      ) : null}
      <h4>{t('mealHistory')}</h4>
      {entries.isError ? (
        <p className="error" role="alert">
          {describeFailure(entries.error, t)}
        </p>
      ) : null}
      {entries.isSuccess && entries.data.length === 0 ? (
        <p className="muted">{t('mealHistoryEmpty')}</p>
      ) : null}
      <ol className="record-list meal-account-history">
        {(entries.data ?? []).map((entry) => (
          <li key={entry.id}>
            <strong>{t(`mealEntry_${entry.kind}`)}</strong>{' '}
            {formatMoney(entry.amount, account.currency)}
            {entry.order_number ? ` · ${entry.order_number}` : ''}
            <small className="muted">
              {' '}
              · {when(entry.created_at, i18n.language)}
              {entry.actor ? ` · ${entry.actor}` : ''}
            </small>
            {entry.note ? <div className="muted">{entry.note}</div> : null}
          </li>
        ))}
      </ol>
      {slip ? <ReceiptPrintPortal document={slip} paper={SLIP_PAPER} /> : null}
    </section>
  );
}

function useCommandForm() {
  const explain = useExplain();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  async function submit(action: () => Promise<void>) {
    setBusy(true);
    setMessage('');
    try {
      await action();
      return true;
    } catch (failure) {
      setMessage(explain(failure));
      return false;
    } finally {
      setBusy(false);
    }
  }
  return { busy, message, submit };
}

function FormMessage({ text }: { text: string }) {
  return text ? (
    <p className="error" role="alert">
      {text}
    </p>
  ) : null;
}

function TopUpForm({
  disabled,
  onTopUp,
}: {
  disabled: boolean;
  onTopUp: (input: {
    kind: 'cash' | 'bank_manual';
    amount: string;
    handedAmount?: string;
    reference?: string;
    receivingAccount?: string;
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [kind, setKind] = useState<'cash' | 'bank_manual'>('cash');
  const [amountInput, setAmountInput] = useState('');
  const [handedInput, setHandedInput] = useState('');
  const [reference, setReference] = useState('');
  const [receivingAccount, setReceivingAccount] = useState('');
  const amount = parseVndInput(amountInput);
  const handed = handedInput.trim() ? parseVndInput(handedInput) : undefined;
  const bank = kind === 'bank_manual';
  const ready =
    amount !== null &&
    amount !== '0' &&
    handed !== null &&
    (!handed || amount === null || BigInt(handed) >= BigInt(amount)) &&
    (!bank || (reference.trim() !== '' && receivingAccount.trim() !== ''));
  const off = disabled || form.busy;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready || amount === null || off) return;
    const ok = await form.submit(() =>
      onTopUp({
        kind,
        amount,
        handedAmount: !bank && handed ? handed : undefined,
        reference: bank ? reference.trim() : undefined,
        receivingAccount: bank ? receivingAccount.trim() : undefined,
      }),
    );
    if (ok) {
      setAmountInput('');
      setHandedInput('');
      setReference('');
    }
  }

  return (
    <form
      className="reservation-form"
      aria-label={t('mealTopUp')}
      onSubmit={(event) => void submit(event)}
    >
      <h4>{t('mealTopUp')}</h4>
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
        {t('mealTopUpAmount')}
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
        {form.busy ? t('waiting') : t('mealTopUpSubmit')}
      </button>
      <FormMessage text={form.message} />
    </form>
  );
}

function ApprovalField({
  value,
  disabled,
  onChange,
}: {
  value: string;
  disabled: boolean;
  onChange: (value: string) => void;
}) {
  const { t } = useTranslation();
  return (
    <label>
      {t('discountApproval')}
      <input
        value={value}
        maxLength={64}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      />
    </label>
  );
}

function RefundForm({
  account,
  disabled,
  canApprove,
  onRefund,
}: {
  account: MealAccount;
  disabled: boolean;
  canApprove: boolean;
  onRefund: (input: {
    amount?: string;
    beneficiaryName?: string;
    reason?: string;
    approvalId?: string;
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [amountInput, setAmountInput] = useState('');
  const [beneficiary, setBeneficiary] = useState('');
  const [reason, setReason] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const amount = amountInput.trim() ? parseVndInput(amountInput) : undefined;
  const off = disabled || form.busy;
  const ready = amount !== null && amount !== '0' && (canApprove || approvalId.trim() !== '');

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready || off) return;
    const ok = await form.submit(() =>
      onRefund({
        amount: amount ?? undefined,
        beneficiaryName: beneficiary.trim() || undefined,
        reason: reason.trim() || undefined,
        approvalId: approvalId.trim() || undefined,
      }),
    );
    if (ok) {
      setAmountInput('');
      setApprovalId('');
    }
  }

  return (
    <details className="meal-account-action">
      <summary>{t('mealRefund')}</summary>
      <form
        className="reservation-form"
        aria-label={t('mealRefund')}
        onSubmit={(event) => void submit(event)}
      >
        <p className="muted">
          {t('mealRefundHint', { balance: formatMoney(account.balance, account.currency) })}
        </p>
        <label>
          {t('mealRefundAmount')}
          <input
            inputMode="numeric"
            className="money-input"
            value={amountInput}
            disabled={off}
            aria-invalid={amount === null}
            onChange={(event) => setAmountInput(event.target.value)}
          />
        </label>
        <label>
          {t('mealRefundBeneficiary')}
          <input
            value={beneficiary}
            maxLength={120}
            placeholder={account.name}
            disabled={off}
            onChange={(event) => setBeneficiary(event.target.value)}
          />
        </label>
        <label>
          {t('mealRefundReason')}
          <input
            value={reason}
            maxLength={200}
            disabled={off}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
        {!canApprove ? (
          <ApprovalField value={approvalId} disabled={off} onChange={setApprovalId} />
        ) : null}
        <button type="submit" disabled={off || !ready}>
          {form.busy ? t('waiting') : t('mealRefundSubmit')}
        </button>
        <FormMessage text={form.message} />
      </form>
    </details>
  );
}

function AdjustForm({
  disabled,
  canApprove,
  onAdjust,
}: {
  disabled: boolean;
  canApprove: boolean;
  onAdjust: (input: { amount: string; note: string; approvalId?: string }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [amountInput, setAmountInput] = useState('');
  const [note, setNote] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const amount = parseSignedVnd(amountInput, parseVndInput);
  const off = disabled || form.busy;
  const ready = amount !== null && note.trim() !== '' && (canApprove || approvalId.trim() !== '');

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready || amount === null || off) return;
    const ok = await form.submit(() =>
      onAdjust({ amount, note: note.trim(), approvalId: approvalId.trim() || undefined }),
    );
    if (ok) {
      setAmountInput('');
      setNote('');
      setApprovalId('');
    }
  }

  return (
    <details className="meal-account-action">
      <summary>{t('mealAdjust')}</summary>
      <form
        className="reservation-form"
        aria-label={t('mealAdjust')}
        onSubmit={(event) => void submit(event)}
      >
        <label>
          {t('mealAdjustAmount')}
          <input
            value={amountInput}
            placeholder="-10.000"
            disabled={off}
            aria-invalid={amountInput.trim() !== '' && amount === null}
            onChange={(event) => setAmountInput(event.target.value)}
          />
        </label>
        <label>
          {t('mealAdjustNote')}
          <input
            value={note}
            maxLength={200}
            required
            disabled={off}
            onChange={(event) => setNote(event.target.value)}
          />
        </label>
        {!canApprove ? (
          <ApprovalField value={approvalId} disabled={off} onChange={setApprovalId} />
        ) : null}
        <button type="submit" disabled={off || !ready}>
          {form.busy ? t('waiting') : t('mealAdjustSubmit')}
        </button>
        <FormMessage text={form.message} />
      </form>
    </details>
  );
}
