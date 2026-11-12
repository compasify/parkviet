import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money';
import {
  describeTraceFailure,
  paymentBlock,
  traceReasonKey,
} from '@parkviet/pos-shared/traceability';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { quickApproveCredit } from '../hooks/use-receivables';
import {
  usePaymentMethods,
  useReceivedFundDetail,
  useReceivedFunds,
  useTenders,
} from '../hooks/use-tenders';
import { type RowAmounts, rebalanceRows, splitRowValues } from '../lib/payment-split';
import type { PosPaymentMethod, PosWorkspace } from '../lib/pos-context';
import { autoPrintEnabled } from '../lib/receipt-preferences';
import { creditConflictKey } from '../lib/receivables';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import { vietqrConflictKey } from '../lib/vietqr';
import { CreditApprovalDialog } from './credit-approval-dialog';
import { FeatureOffNote } from './feature-off-note';
import { PosIcon } from './pos-icon';
import { QuickCreditDialog } from './quick-credit-dialog';
import { ReceiptPrintButton } from './receipt-print-dialog';
import {
  TenderEvidenceDialog,
  type TenderEvidenceItemInput,
  type TicketNames,
} from './tender-evidence-dialog';

type MethodKind = PosPaymentMethod['kind'];

function methodIcon(kind: MethodKind) {
  return kind === 'cash' ? 'cash' : kind === 'vietqr' ? 'qr' : 'bank';
}
type WorkspaceCommand = (
  action: (current: PosWorkspace) => Promise<PosWorkspace>,
) => Promise<PosWorkspace>;

// One row of a split payment failed; earlier rows already reached the server.
class RowFailure extends Error {
  constructor(
    readonly row: string,
    readonly done: number,
    readonly total: number,
    readonly failure: unknown,
  ) {
    super('payment-row-failed');
  }
}

// The order can be completed right away: confirmed money covers it and no
// other tender is still waiting or in doubt (same rule as "Complete order").
// A canteen sponsor's part (`sponsorDue`) is charged as the order completes,
// so the order is ready once only that part is left.
function paidInFull(workspace: PosWorkspace, sponsorDue = 0n) {
  const financial = workspace.financial;
  const remaining = parseVndAmount(financial?.remaining ?? '');
  return Boolean(
    financial &&
      workspace.operational_status !== 'completed' &&
      (workspace.line_items?.length ?? 0) > 0 &&
      remaining !== null &&
      BigInt(remaining) === sponsorDue &&
      !financial.attempts?.some(
        (attempt) => attempt.status === 'prepared' || attempt.status === 'unknown',
      ),
  );
}

const EINVOICE_BUYER_FIELDS = [
  'tax_code',
  'name',
  'address',
  'email',
  'phone',
  'personal_id',
  'passport_no',
  'nationality',
  'buyer_note',
] as const;
type EinvoiceBuyerField = (typeof EINVOICE_BUYER_FIELDS)[number];
const emptyBuyer = Object.fromEntries(EINVOICE_BUYER_FIELDS.map((key) => [key, ''])) as Record<
  EinvoiceBuyerField,
  string
>;

// Only the fields typed in; nothing when the buyer gave no details.
function filledBuyer(buyer: Record<EinvoiceBuyerField, string>) {
  const filled = Object.fromEntries(
    Object.entries(buyer)
      .map(([key, value]) => [key, value.trim()])
      .filter(([, value]) => value !== ''),
  );
  return Object.keys(filled).length > 0 ? filled : undefined;
}

function einvoiceBuyerField(failure: unknown) {
  if (typeof failure !== 'object' || failure === null || !('details' in failure)) return '';
  const details = failure.details;
  return typeof details === 'object' &&
    details !== null &&
    'field' in details &&
    typeof details.field === 'string'
    ? details.field
    : '';
}

async function eachRow<T>(
  rows: T[],
  label: (row: T) => string,
  step: (row: T) => Promise<unknown>,
) {
  for (const [index, row] of rows.entries()) {
    try {
      await step(row);
    } catch (failure) {
      throw new RowFailure(label(row), index, rows.length, failure);
    }
  }
}

export function PaymentPanel({
  workspace,
  staffId,
  storeId,
  canCollect,
  canResolve,
  canSellCredit = false,
  creditEnabled = true,
  quickCredit = false,
  drawerOpen = true,
  disabled,
  command,
  reserveTrace,
  ticketNames,
  timeZone,
  einvoiceType = 'none',
  mealSponsorAmount,
}: {
  // A canteen order's sponsor part (decimal string): the cashier takes only
  // the eater's part, and completing charges the rest to the sponsor.
  mealSponsorAmount?: string | null;
  // The store's e-invoice; anything but `none` offers the buyer's details.
  einvoiceType?: 'none' | 'cash_register' | 'coded';
  // Store, branch, register and cashier printed on the payment invoice.
  ticketNames?: TicketNames;
  timeZone?: string;
  workspace: PosWorkspace;
  staffId: string | null;
  storeId: string | null;
  canCollect: boolean;
  canResolve: boolean;
  canSellCredit?: boolean;
  // Branch feature flag: off keeps the debt summary but offers no new credit sale.
  creditEnabled?: boolean;
  // `quick_credit` on: the cashier approves their own credit sale, no manager.
  quickCredit?: boolean;
  // The order's shift is open and this cashier owns it.
  drawerOpen?: boolean;
  disabled: boolean;
  // Runs through the workspace's serializer and hands over its newest revision.
  command: WorkspaceCommand;
  // Reserves traced stock (serials, FEFO lots) for the newest revision.
  reserveTrace?: (current: PosWorkspace) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const tenders = useTenders(staffId, storeId);
  const methodsQuery = usePaymentMethods(workspace, canCollect && !disabled);
  const fundsQuery = useReceivedFunds(storeId, workspace.branch_id, null, canResolve);
  const [allocateFundsId, setAllocateFundsId] = useState('');
  const [allocateAmount, setAllocateAmount] = useState('');
  const allocateDetailQuery = useReceivedFundDetail(
    allocateFundsId || null,
    Boolean(allocateFundsId),
  );
  const [activeKinds, setActiveKinds] = useState<MethodKind[]>(['cash']);
  const [customAmounts, setCustomAmounts] = useState<{
    base: string;
    amounts: RowAmounts;
  } | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [evidenceOpen, setEvidenceOpen] = useState(false);
  // The dialog's opener ("Thanh toán") is disabled once a tender is prepared,
  // so a dialog put on hold hands keyboard focus to the resume button instead
  // of leaving it on the page body.
  const resumeButton = useRef<HTMLButtonElement>(null);
  const evidenceWasOpen = useRef(false);
  useEffect(() => {
    if (evidenceWasOpen.current && !evidenceOpen) resumeButton.current?.focus();
    evidenceWasOpen.current = evidenceOpen;
  }, [evidenceOpen]);
  const [creditOpen, setCreditOpen] = useState(false);
  const [handedOver, setHandedOver] = useState(false);
  // "Khách lấy hóa đơn": who the e-invoice is made out to. Left empty, the
  // invoice is for a consumer and the receipt carries a QR to add details.
  const [buyer, setBuyer] = useState<Record<EinvoiceBuyerField, string>>(emptyBuyer);
  const [buyerFor, setBuyerFor] = useState(workspace.id);
  if (buyerFor !== workspace.id) {
    setBuyerFor(workspace.id);
    setBuyer(emptyBuyer);
  }
  const buyerDetails = einvoiceType === 'none' ? undefined : filledBuyer(buyer);
  const financial = workspace.financial;
  const credit = financial?.credit ?? null;
  const offeredMethods = methodsQuery.data ?? [];
  // When the branch offers VietQR it is the bank transfer: the QR fills in the
  // account, amount and note, the bank notification confirms it, and a
  // transfer the bank never reported is still attested by hand on the same
  // tender. A second, QR-less transfer button would only invite mistakes.
  const methods = offeredMethods.some((method) => method.kind === 'vietqr')
    ? offeredMethods.filter((method) => method.kind !== 'bank_manual')
    : offeredMethods;
  const activeMethods = methods.filter((method) => activeKinds.includes(method.kind));
  const effectiveMethods = activeMethods.length > 0 ? activeMethods : methods.slice(0, 1);
  const preparedAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status === 'prepared',
  );
  const completed = workspace.operational_status === 'completed';
  // A sale completed while this panel is open prints by itself on a device
  // set to do so; reopening a completed order never does.
  const [autoPrint, setAutoPrint] = useState(false);
  const wasCompleted = useRef(completed);
  useEffect(() => {
    if (completed && !wasCompleted.current && autoPrintEnabled()) setAutoPrint(true);
    wasCompleted.current = completed;
  }, [completed]);
  const sponsorDue = BigInt(parseVndAmount(mealSponsorAmount ?? '') ?? '0');
  const mealSponsor = sponsorDue > 0n;
  const remainingValue = financial ? parseVndAmount(financial.remaining) : null;
  // Nothing left for the cashier to take: with a meal sponsor, only its part is left.
  const remainingIsZero =
    remainingValue !== null &&
    (mealSponsor ? BigInt(remainingValue) <= sponsorDue : remainingValue === '0');
  const completeOptions = mealSponsor ? { mealSponsor: true } : undefined;
  const totalIsZero = parseVndAmount(workspace.totals?.total ?? '') === '0';
  const currency = workspace.totals?.currency ?? 'VND';
  const hasItems = (workspace.line_items?.length ?? 0) > 0;
  // Money may be moving on these, so the remainder is not final yet.
  const unresolvedAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status === 'prepared' || attempt.status === 'unknown',
  );
  const nonCanceledAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status !== 'canceled',
  );
  const hasPaymentActivity = Boolean(
    financial &&
      (nonCanceledAttempts.length > 0 ||
        Number(financial.received) > 0 ||
        Number(financial.allocated) > 0 ||
        Number(financial.unapplied) > 0 ||
        Number(financial.change_due) > 0 ||
        Boolean(credit?.approved || credit?.debt)),
  );
  const fullAmount =
    parseVndAmount(
      hasPaymentActivity
        ? (financial?.remaining ?? workspace.totals?.total ?? '')
        : (workspace.totals?.total ?? financial?.remaining ?? ''),
    ) ?? '';
  // The eater pays only their part of a sponsored meal.
  const defaultAmount =
    mealSponsor && fullAmount
      ? String(BigInt(fullAmount) > sponsorDue ? BigInt(fullAmount) - sponsorDue : 0n)
      : fullAmount;
  const locked = disabled || busy;
  const trace = paymentBlock(workspace);
  // Payment cannot start while the server says traced stock is not ready.
  const traceBlocked = !trace.ready && !completed;
  // Money is recorded on the order's own shift; the server refuses with
  // `shift_closed` once that drawer is not open, so no new payment starts.
  const drawerBlocked = !drawerOpen && !completed;
  const blockedBy = traceBlocked
    ? 'pos-trace-blocked'
    : drawerBlocked
      ? 'pos-drawer-closed'
      : undefined;

  function methodLabel(method: { kind: string; name?: string }) {
    return method.kind === 'cash'
      ? t('cash')
      : method.kind === 'bank_manual'
        ? t('bankTransfer')
        : method.kind === 'vietqr'
          ? t('vietqr')
          : (method.name ?? method.kind);
  }

  // Choosing a method: VietQR is offered as "Bank transfer" (see `methods`).
  function choiceLabel(method: PosPaymentMethod) {
    return method.kind === 'vietqr' ? t('bankTransfer') : methodLabel(method);
  }

  const rowKinds = effectiveMethods.map((method) => method.kind);
  // Typed amounts belong to the target they were typed against.
  const typedAmounts = customAmounts?.base === defaultAmount ? customAmounts.amounts : null;
  const rowValues = splitRowValues(rowKinds, defaultAmount, typedAmounts);

  function updateRowValue(kind: MethodKind, rawValue: string) {
    setCustomAmounts({
      base: defaultAmount,
      amounts: rebalanceRows(rowKinds, defaultAmount, typedAmounts, kind, rawValue),
    });
  }

  function toggleMethod(kind: MethodKind) {
    setActiveKinds((current) => {
      if (current.includes(kind)) {
        if (current.length > 1) return current.filter((item) => item !== kind);
        const other = methods.find((method) => method.kind !== kind)?.kind;
        return other ? [other] : current;
      }
      return [...current, kind];
    });
  }

  const availableFunds = (fundsQuery.data?.data ?? []).filter(
    (funds) => parseVndAmount(funds.available) !== '0',
  );
  const activeAllocations = (allocateDetailQuery.data?.allocations ?? []).filter(
    (allocation) => allocation.workspace_id === workspace.id && allocation.status === 'active',
  );
  const parsedAllocate = parseVndInput(allocateAmount);

  function explain(failure: unknown, fallbackKey?: string) {
    const reason = conflictReason(failure);
    if (reason === 'einvoice_buyer_invalid') {
      const field = einvoiceBuyerField(failure);
      return t('einvoiceBuyerInvalid', {
        field: field ? t(`einvoiceBuyer_${field}`, { defaultValue: field }) : '',
      });
    }
    const key = creditConflictKey(reason) ?? vietqrConflictKey(reason);
    return key ? t(key) : describeTraceFailure(failure, t, fallbackKey);
  }

  async function run(
    action: () => Promise<unknown>,
    fallbackKey?: (failure: unknown) => string | undefined,
  ): Promise<boolean> {
    setBusy(true);
    setError('');
    try {
      await action();
      setCustomAmounts(null);
      return true;
    } catch (failure) {
      if (failure instanceof RowFailure) {
        setError(
          t('paymentRowFailed', {
            row: failure.row,
            done: failure.done,
            total: failure.total,
            reason: explain(failure.failure, fallbackKey?.(failure.failure)),
          }),
        );
      } else {
        setError(explain(failure, fallbackKey?.(failure)));
      }
      // Whatever part went through is on the server now: show it.
      void tenders.refresh();
      return false;
    } finally {
      setBusy(false);
    }
  }

  const rows = effectiveMethods.map((method) => {
    const raw = rowValues[method.kind] ?? defaultAmount;
    return { method, raw, amount: parseVndInput(raw) };
  });
  const invalidRows = rows.filter((row) => row.raw.trim() !== '' && row.amount === null);
  const entriesToPrepare = rows.filter(
    (row): row is { method: PosPaymentMethod; raw: string; amount: string } =>
      row.amount !== null && BigInt(row.amount) > 0n,
  );

  function confirmEvidence(inputs: TenderEvidenceItemInput[]) {
    const kindOf = (attemptId: string) =>
      preparedAttempts.find((attempt) => attempt.id === attemptId)?.kind ?? 'cash';
    return run(async () => {
      let latest: PosWorkspace | undefined;
      await eachRow(
        inputs,
        (input) => methodLabel({ kind: kindOf(input.attemptId) }),
        async (input) => {
          latest = await command((current) =>
            tenders.confirm(current, {
              attemptId: input.attemptId,
              handedAmount: input.handedAmount,
              receivedAmount: input.receivedAmount,
              evidenceKind: input.evidenceKind,
              reference: input.reference,
              receivingAccount: input.receivingAccount,
              terminalRef: input.terminalRef,
              tipAmount: input.tipAmount,
            }),
          );
        },
      );
      // "Finish" in the dialog finishes the sale: once the confirmed money
      // covers the order, complete it here instead of a second click. A
      // refusal (e.g. lost lease) leaves the "Complete order" button as before.
      if (latest && paidInFull(latest, sponsorDue))
        await command((current) =>
          tenders.complete(current, undefined, buyerDetails, completeOptions),
        );
    });
  }

  // A manual bank tender prepared before VietQR was offered (or switched on)
  // shows no QR. Swap it for a VietQR tender of the same amount: cancel the
  // manual one, then prepare the QR, so only one transfer is ever waiting.
  const vietqrMethod = offeredMethods.find((method) => method.kind === 'vietqr');
  const manualBankAttempt = preparedAttempts.find((attempt) => attempt.kind === 'bank_manual');
  const canShowVietqr = Boolean(
    vietqrMethod &&
      manualBankAttempt &&
      !preparedAttempts.some((attempt) => attempt.kind === 'vietqr'),
  );

  function showVietqr() {
    const attempt = manualBankAttempt;
    const method = vietqrMethod;
    const amount = attempt ? parseVndAmount(attempt.amount) : null;
    if (!attempt || !method || !amount) return Promise.resolve(false);
    return run(async () => {
      await command((current) => tenders.cancel(current, { attemptId: attempt.id }));
      await command((current) => tenders.prepare(current, { paymentMethodId: method.id, amount }));
    });
  }

  function cancelPrepared() {
    return run(() =>
      eachRow(
        preparedAttempts,
        (attempt) => methodLabel(attempt),
        (attempt) => command((current) => tenders.cancel(current, { attemptId: attempt.id })),
      ),
    );
  }

  if (!canCollect && !financial) return null;

  return (
    <section className="payment-panel" aria-label={t('paymentTitle')}>
      <h3 id="pos-payment-title">{t('paymentMethods')}</h3>
      {drawerBlocked ? (
        <p className="attention-box" role="note" id="pos-drawer-closed">
          {t('paymentNeedsOpenShift')}
        </p>
      ) : null}
      {traceBlocked ? (
        <div className="attention-box" role="alert" id="pos-trace-blocked">
          <p>{t('paymentTraceBlocked')}</p>
          {trace.issues.length ? (
            <ul>
              {trace.issues.map((issue) => (
                <li key={`${issue.saleLineId}:${issue.reason}`}>
                  {issue.name}: {t(traceReasonKey(issue.reason) ?? 'paymentTraceIssueUnknown')}
                </li>
              ))}
            </ul>
          ) : null}
          {reserveTrace && trace.fixable ? (
            <button
              type="button"
              disabled={locked}
              onClick={() => void run(() => command((current) => reserveTrace(current)))}
            >
              {busy ? t('waiting') : t('paymentTraceReserve')}
            </button>
          ) : null}
        </div>
      ) : null}
      {financial && hasPaymentActivity ? (
        <dl className="payment-summary">
          <div>
            <dt>{t('paymentReceived')}</dt>
            <dd>{formatMoney(financial.received, currency)}</dd>
          </div>
          {Number(financial.allocated) !== Number(financial.received) ? (
            <div>
              <dt>{t('paymentAllocated')}</dt>
              <dd>{formatMoney(financial.allocated, currency)}</dd>
            </div>
          ) : null}
          {Number(financial.unapplied) > 0 ? (
            <div>
              <dt>{t('paymentUnapplied')}</dt>
              <dd>{formatMoney(financial.unapplied, currency)}</dd>
            </div>
          ) : null}
          {credit?.approved && !completed ? (
            <div>
              <dt>{t('paymentCreditApproved')}</dt>
              <dd>{formatMoney(credit.approved, currency)}</dd>
            </div>
          ) : null}
          {credit?.debt ? (
            <>
              <div>
                <dt>{t('paymentDebt')}</dt>
                <dd>{formatMoney(credit.debt, currency)}</dd>
              </div>
              <div className="remaining-row">
                <dt>{t('paymentDebtBalance')}</dt>
                <dd>{formatMoney(credit.balance, currency)}</dd>
              </div>
            </>
          ) : (
            <div className="remaining-row">
              <dt>{t('paymentRemaining')}</dt>
              <dd>{formatMoney(financial.remaining, currency)}</dd>
            </div>
          )}
          {Number(financial.change_due) > 0 ? (
            <div>
              <dt>{t('paymentChange')}</dt>
              <dd>{formatMoney(financial.change_due, currency)}</dd>
            </div>
          ) : null}
        </dl>
      ) : null}
      {nonCanceledAttempts.length ? (
        <details className="payment-history">
          <summary>
            {t('paymentAttempts')} ({nonCanceledAttempts.length})
          </summary>
          <ul className="attempt-list">
            {nonCanceledAttempts.map((attempt) => (
              <li key={attempt.id}>
                <span>
                  {methodLabel(attempt)}
                  <small>
                    {t(`tenderStatus_${attempt.status}`, { defaultValue: attempt.status })}
                  </small>
                </span>
                <strong>{formatMoney(attempt.amount, attempt.currency)}</strong>
              </li>
            ))}
          </ul>
        </details>
      ) : null}
      {preparedAttempts.length > 0 && !evidenceOpen ? (
        <div className="payment-held" role="status">
          <p>{t('paymentHeldHint')}</p>
          <button
            ref={resumeButton}
            type="button"
            className="checkout-submit"
            disabled={busy}
            onClick={() => setEvidenceOpen(true)}
          >
            {t('paymentResume')}
          </button>
        </div>
      ) : null}
      {preparedAttempts.length > 0 && evidenceOpen ? (
        <TenderEvidenceDialog
          workspace={workspace}
          names={ticketNames}
          timeZone={timeZone}
          attempts={preparedAttempts}
          disabled={disabled}
          busy={busy}
          error={error}
          onConfirm={confirmEvidence}
          onCancel={cancelPrepared}
          onShowVietqr={canShowVietqr ? showVietqr : undefined}
          onHold={() => {
            setEvidenceOpen(false);
            setError('');
          }}
        />
      ) : null}
      {canCollect && !completed && (!remainingIsZero || !hasItems) ? (
        <form
          onSubmit={(event) => {
            event.preventDefault();
            if (invalidRows.length > 0 || entriesToPrepare.length === 0) {
              setError(t('paymentAmountInvalid'));
              return;
            }
            void run(() =>
              eachRow(
                entriesToPrepare,
                (entry) => methodLabel(entry.method),
                (entry) =>
                  command((current) =>
                    tenders.prepare(current, {
                      paymentMethodId: entry.method.id,
                      amount: entry.amount,
                    }),
                  ),
              ),
            ).then((prepared) => {
              if (prepared) setEvidenceOpen(true);
            });
          }}
        >
          <fieldset className="payment-methods" aria-label={t('paymentMethod')}>
            {methods.map((method) => (
              <button
                type="button"
                key={method.id}
                aria-pressed={effectiveMethods.some((item) => item.id === method.id)}
                disabled={locked || preparedAttempts.length > 0}
                onClick={() => toggleMethod(method.kind)}
                title={method.kind === 'vietqr' ? t('paymentVietqrTitle') : undefined}
              >
                <PosIcon name={methodIcon(method.kind)} />
                {choiceLabel(method)}
              </button>
            ))}
          </fieldset>
          <div className="payment-method-rows">
            {rows.map(({ method, raw, amount }) => (
              <label className="payment-method-row" key={method.id} data-method={method.kind}>
                <span className="payment-method-badge">
                  <PosIcon name={methodIcon(method.kind)} />
                  <strong>{choiceLabel(method)}</strong>
                </span>
                <input
                  inputMode="numeric"
                  className="money-input"
                  value={raw}
                  placeholder={defaultAmount}
                  aria-invalid={raw.trim() !== '' && amount === null}
                  onChange={(event) => updateRowValue(method.kind, event.target.value)}
                  disabled={locked || preparedAttempts.length > 0}
                  required={effectiveMethods.length === 1}
                />
              </label>
            ))}
          </div>
          {invalidRows.length > 0 ? (
            <p className="error" role="alert">
              {t('paymentAmountInvalid')}
            </p>
          ) : null}
          {methodsQuery.isLoading ? <p role="status">{t('waiting')}</p> : null}
          {methodsQuery.isError ? (
            <p className="error" role="alert">
              {t(posFailureKey(methodsQuery.error))}
            </p>
          ) : null}
          {!disabled && methodsQuery.isSuccess && methods.length === 0 ? (
            <p className="muted">{t('paymentNoMethods')}</p>
          ) : null}
          <button
            className="checkout-submit"
            type="submit"
            aria-describedby={blockedBy}
            disabled={
              locked ||
              traceBlocked ||
              drawerBlocked ||
              preparedAttempts.length > 0 ||
              !hasItems ||
              invalidRows.length > 0 ||
              entriesToPrepare.length === 0
            }
          >
            {busy ? t('waiting') : t('paymentPrepare')}
          </button>
        </form>
      ) : null}
      {canCollect &&
      canSellCredit &&
      !mealSponsor &&
      !completed &&
      financial &&
      !remainingIsZero &&
      hasItems ? (
        <>
          <button
            type="button"
            className="credit-action"
            disabled={
              !creditEnabled ||
              locked ||
              traceBlocked ||
              drawerBlocked ||
              unresolvedAttempts.length > 0
            }
            aria-describedby={
              !creditEnabled
                ? 'pos-credit-off'
                : blockedBy
                  ? blockedBy
                  : unresolvedAttempts.length > 0
                    ? 'pos-credit-blocked'
                    : undefined
            }
            title={workspace.customer ? undefined : t('creditCustomerRequired')}
            onClick={() => {
              setError('');
              setCreditOpen(true);
            }}
          >
            <PosIcon name="user" />
            {t('creditAction')}
          </button>
          {!creditEnabled ? <FeatureOffNote feature="credit" id="pos-credit-off" /> : null}
          {creditEnabled && unresolvedAttempts.length > 0 ? (
            <small className="muted" id="pos-credit-blocked">
              {t('creditBlockedByTender')}
            </small>
          ) : null}
        </>
      ) : null}
      {creditOpen && creditEnabled && quickCredit && !completed ? (
        <QuickCreditDialog
          workspace={workspace}
          busy={busy || disabled}
          error={error}
          onClose={() => {
            setCreditOpen(false);
            setError('');
          }}
          onConfirm={() =>
            void run(() =>
              command(async (current) => {
                const held = await quickApproveCredit(current);
                return tenders.complete(current, held.approval_id, buyerDetails);
              }),
            ).then((done) => {
              if (done) setCreditOpen(false);
            })
          }
        />
      ) : null}
      {creditOpen && creditEnabled && !quickCredit && !completed ? (
        <CreditApprovalDialog
          workspace={workspace}
          busy={busy || disabled}
          error={error}
          onClose={() => {
            setCreditOpen(false);
            setError('');
          }}
          onComplete={(approvalId) =>
            run(() =>
              command((current) => tenders.complete(current, approvalId, buyerDetails)),
            ).then((done) => {
              if (done) setCreditOpen(false);
              return done;
            })
          }
        />
      ) : null}
      {canCollect && einvoiceType !== 'none' && !completed && financial && hasItems ? (
        <details className="einvoice-buyer checkout-optional">
          <summary>
            {t('einvoiceBuyerTitle')}
            {buyerDetails ? ` · ${buyer.name || buyer.tax_code || t('einvoiceBuyerFilled')}` : ''}
          </summary>
          <small className="muted">{t('einvoiceBuyerHint')}</small>
          {EINVOICE_BUYER_FIELDS.map((field) => (
            <label key={field}>
              {t(`einvoiceBuyer_${field}`)}
              <input
                value={buyer[field]}
                disabled={locked}
                inputMode={field === 'tax_code' || field === 'phone' ? 'numeric' : undefined}
                type={field === 'email' ? 'email' : 'text'}
                autoComplete="off"
                onChange={(event) => setBuyer({ ...buyer, [field]: event.target.value })}
              />
            </label>
          ))}
        </details>
      ) : null}
      {canCollect && !completed && financial && remainingIsZero && hasItems ? (
        <button
          type="button"
          className="checkout-submit"
          disabled={locked || traceBlocked || drawerBlocked || preparedAttempts.length > 0}
          aria-describedby={blockedBy}
          onClick={() =>
            void run(
              () =>
                command((current) =>
                  tenders.complete(current, undefined, buyerDetails, completeOptions),
                ),
              (failure) =>
                totalIsZero && posFailureKey(failure) === 'forbidden'
                  ? 'paymentZeroTotalApproval'
                  : undefined,
            )
          }
        >
          {t('paymentComplete')}
        </button>
      ) : null}
      {completed ? (
        <ReceiptPrintButton
          sourceId={workspace.id}
          label={t('receiptPrint')}
          autoPrint={autoPrint}
        />
      ) : null}
      {completed && !handedOver ? (
        <button
          className="checkout-submit"
          type="button"
          disabled={locked}
          onClick={() =>
            void run(() => command((current) => tenders.handover(current))).then((done) => {
              if (done) setHandedOver(true);
            })
          }
        >
          {t('paymentHandover')}
        </button>
      ) : null}
      {completed && handedOver ? (
        <p className="muted" role="status">
          {t('paymentHandedOver')}
        </p>
      ) : null}
      {canResolve && (availableFunds.length > 0 || activeAllocations.length > 0) ? (
        <details className="funds-allocate checkout-optional">
          <summary>{t('paymentAllocate')}</summary>
          <label>
            {t('paymentUnapplied')}
            <select
              value={allocateFundsId}
              onChange={(event) => setAllocateFundsId(event.target.value)}
              disabled={locked}
            >
              <option value="">—</option>
              {availableFunds.map((funds) => (
                <option key={funds.id} value={funds.id}>
                  {funds.kind} · {formatMoney(funds.available, funds.currency)} ·{' '}
                  {funds.reference ?? funds.id}
                </option>
              ))}
            </select>
          </label>
          <label>
            {t('fundsAllocateAmount')}
            <input
              inputMode="numeric"
              aria-label={t('fundsAllocateAmount')}
              aria-invalid={allocateAmount.trim() !== '' && parsedAllocate === null}
              value={allocateAmount}
              onChange={(event) => setAllocateAmount(event.target.value)}
              disabled={locked}
            />
          </label>
          <button
            type="button"
            disabled={locked || !allocateFundsId || !parsedAllocate || parsedAllocate === '0'}
            onClick={() => {
              if (!parsedAllocate) return;
              void run(() =>
                command((current) =>
                  tenders.allocate(current, { fundsId: allocateFundsId, amount: parsedAllocate }),
                ),
              ).then((done) => {
                if (done) setAllocateAmount('');
              });
            }}
          >
            {t('paymentAllocate')}
          </button>
          {activeAllocations.map((allocation) => (
            <p key={allocation.id}>
              {formatMoney(allocation.amount, allocation.currency)} · {allocation.status}{' '}
              {!completed ? (
                <button
                  type="button"
                  disabled={locked}
                  onClick={() =>
                    void run(() =>
                      command((current) =>
                        tenders.reverse(current, { allocationId: allocation.id }),
                      ),
                    )
                  }
                >
                  {t('paymentReverseAllocation')}
                </button>
              ) : null}
            </p>
          ))}
        </details>
      ) : null}
      {error && !(preparedAttempts.length > 0 && evidenceOpen) && !creditOpen ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
