import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money';
import {
  describeTraceFailure,
  paymentBlock,
  traceReasonKey,
} from '@parkviet/pos-shared/traceability';
import { type ReactNode, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { quickApproveCredit } from '../hooks/use-receivables';
import { lookupStoredValueCard } from '../hooks/use-stored-value';
import {
  usePaymentMethods,
  useReceivedFundDetail,
  useReceivedFunds,
  useTenders,
  useVietqrTender,
} from '../hooks/use-tenders';
import { cashSuggestions, evenShare, groupVndDigits } from '../lib/cash-suggestions';
import { type RowAmounts, rebalanceRows, splitRowValues } from '../lib/payment-split';
import type { PosFinancialAttempt, PosPaymentMethod, PosWorkspace } from '../lib/pos-context';
import { autoPrintEnabled } from '../lib/receipt-preferences';
import { creditConflictKey } from '../lib/receivables';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import { normalizeStoredValueCard, storedValueReasonKey } from '../lib/stored-value';
import {
  type VietqrTenderSummary,
  vietqrConflictKey,
  vietqrReceived,
  vietqrTimeLeft,
} from '../lib/vietqr';
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

export type PaymentLayout = 'panel' | 'fullscreen';

// What the full payment screen's own tools need from the payment: a QR
// waiting for a transfer was prepared for the order as it is, so anything
// that changes the order lets that QR go first and holds the next one back
// until it is done. A QR whose money already arrived is never let go.
export type PaymentControls = {
  // A payment command of this screen is running.
  busy: boolean;
  // Keeps the next QR back (a dialog that may change the order is open).
  hold: (held: boolean) => void;
  // Cancels a QR still waiting; false (with the reason shown) when it could not.
  release: () => Promise<boolean>;
  // Runs `action` with the QR let go first; its failure reaches the caller.
  whileReleased: <T>(action: () => Promise<T>) => Promise<T>;
};

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

// The smaller of two whole amounts.
function smaller(a: bigint, b: bigint): bigint {
  return a < b ? a : b;
}

// A card reading that matches no card.
class StoredValueMissing extends Error {}

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
  storedValueCards = false,
  layout = 'panel',
  defaultTender = 'cash',
  cashTip = false,
  bill,
  tools,
  onCompleted,
}: {
  // `panel`: the column of the counter's checkout. `fullscreen`: the table
  // payment screen, with what is due in three big boxes, the QR and the
  // cash keypad side by side, the rarer methods below and one finish button.
  // Both run the same tender commands.
  layout?: PaymentLayout;
  // The method picked first; on the full screen, VietQR shows its QR at once.
  defaultTender?: MethodKind;
  // Full screen: the cash takes a guest's tip (table service settled later).
  cashTip?: boolean;
  // Full screen: the bill on the left and the screen's own tools in the foot,
  // given the controls that let the order change under a waiting QR.
  bill?: (controls: PaymentControls) => ReactNode;
  tools?: (controls: PaymentControls) => ReactNode;
  // Full screen: the order was completed here; `print` when the cashier asked
  // for the invoice with it.
  onCompleted?: (workspace: PosWorkspace, options: { print: boolean }) => void;
  // The branch bills play time, so prepaid money cards may pay the order.
  storedValueCards?: boolean;
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
  const [activeKinds, setActiveKinds] = useState<MethodKind[]>([defaultTender]);
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
  const [cardReading, setCardReading] = useState('');
  const [cardNotice, setCardNotice] = useState('');
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
  const fullscreen = layout === 'fullscreen';
  // Full screen: the finish button asked for the invoice with the completion.
  const printOnComplete = useRef(false);
  const completedHandler = useRef(onCompleted);
  completedHandler.current = onCompleted;
  const completedWorkspace = useRef(workspace);
  completedWorkspace.current = workspace;
  useEffect(() => {
    if (completed && !wasCompleted.current) {
      // The full screen hands the completed order back; the screen it returns
      // to prints, so nothing prints from here.
      if (fullscreen)
        completedHandler.current?.(completedWorkspace.current, { print: printOnComplete.current });
      else if (autoPrintEnabled()) setAutoPrint(true);
    }
    wasCompleted.current = completed;
  }, [completed, fullscreen]);
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
    if (failure instanceof StoredValueMissing) return t('storedValueNotFound');
    const reason = conflictReason(failure);
    if (reason === 'einvoice_buyer_invalid') {
      const field = einvoiceBuyerField(failure);
      return t('einvoiceBuyerInvalid', {
        field: field ? t(`einvoiceBuyer_${field}`, { defaultValue: field }) : '',
      });
    }
    const key =
      creditConflictKey(reason) ?? vietqrConflictKey(reason) ?? storedValueReasonKey(reason);
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

  // Full screen. VietQR shows its QR for what is due as soon as the screen
  // opens: a VietQR tender is prepared for it, the same tender "Bank
  // transfer" prepares in the panel. Cash is counted on the keypad and taken
  // with one press: the waiting QR is let go, the cash tender is prepared for
  // what the money covers and confirmed with what was handed, and the next
  // QR comes for whatever is left. Every step is the panel's own command.
  const cashMethod = methods.find((method) => method.kind === 'cash');
  const otherMethods = methods.filter(
    (method) => method.kind !== 'cash' && method.kind !== 'vietqr',
  );
  const [cashRaw, setCashRaw] = useState('');
  const [tipRaw, setTipRaw] = useState('');
  // "Chia đều": each guest pays an even part of what was due when it was picked.
  const [share, setShare] = useState<{ workspaceId: string; parts: number; amount: string } | null>(
    null,
  );
  const shareDetails = useRef<HTMLDetailsElement>(null);
  const [qrHold, setQrHold] = useState(false);
  // The order and amount a QR was last prepared for by itself, so a refused
  // QR is not asked for again and again.
  const triedQr = useRef<string | null>(null);
  const qrAttempt = fullscreen
    ? preparedAttempts.find((attempt) => attempt.kind === 'vietqr')
    : undefined;
  const qrQuery = useVietqrTender(workspace.id, qrAttempt?.id ?? null);
  const qrSummary = qrAttempt ? (qrQuery.data ?? null) : null;
  const qrIn = vietqrReceived(qrSummary);
  // A QR still waiting for its transfer; one whose money arrived is kept.
  const waitingQr = qrAttempt && !qrIn ? qrAttempt : undefined;
  // Tenders that stop another payment from starting; a waiting QR on the
  // full screen is let go first instead.
  const blockingAttempts = unresolvedAttempts.filter((attempt) => attempt.id !== waitingQr?.id);
  // Prepared tenders other than the screen's own QR finish in the evidence dialog.
  const heldAttempts = fullscreen
    ? preparedAttempts.filter((attempt) => attempt.id !== qrAttempt?.id)
    : preparedAttempts;
  const dueValue = BigInt(defaultAmount || '0');
  const shareValue = share?.workspaceId === workspace.id ? BigInt(share.amount) : null;
  const target = shareValue !== null && shareValue < dueValue ? shareValue : dueValue;
  const handed = parseVndInput(cashRaw);
  const cashInvalid = cashRaw.trim() !== '' && handed === null;
  const handedValue = BigInt(handed ?? '0');
  const tip = cashTip ? parseVndInput(tipRaw) : null;
  const tipInvalid = cashTip && tipRaw.trim() !== '' && tip === null;
  const tipValue = BigInt(tip ?? '0');
  // What the cash pays of the order; the rest of what was handed is tip and change.
  const cashOver = handedValue - tipValue;
  const cashPays = smaller(cashOver, target);
  const qrAmount = qrAttempt ? BigInt(parseVndAmount(qrAttempt.amount) ?? '0') : 0n;
  const finishKind: 'cash' | 'qr' | 'complete' | null =
    handedValue > 0n
      ? 'cash'
      : qrIn
        ? 'qr'
        : financial && remainingIsZero && hasItems
          ? 'complete'
          : null;
  const paysNow =
    finishKind === 'cash'
      ? (cashPays > 0n ? cashPays : 0n) + (qrIn ? qrAmount : 0n)
      : finishKind === 'qr'
        ? qrAmount
        : 0n;
  // This press pays everything still due, so the order completes with it.
  const finishes = finishKind === 'complete' || (finishKind !== null && paysNow >= dueValue);
  const leftPreview = dueValue > paysNow ? dueValue - paysNow : 0n;
  const changeDue = BigInt(parseVndAmount(financial?.change_due ?? '') ?? '0');
  const changePreview = finishKind === 'cash' && cashOver > target ? cashOver - target : changeDue;
  const cashLocked = locked || !cashMethod || heldAttempts.length > 0;
  const finishDisabled =
    locked ||
    !canCollect ||
    traceBlocked ||
    drawerBlocked ||
    finishKind === null ||
    cashInvalid ||
    tipInvalid ||
    heldAttempts.length > 0 ||
    (finishKind === 'cash' && (!cashMethod || cashPays <= 0n));
  const autoQr =
    fullscreen &&
    defaultTender === 'vietqr' &&
    vietqrMethod &&
    canCollect &&
    !locked &&
    !qrHold &&
    !creditOpen &&
    !evidenceOpen &&
    !completed &&
    hasItems &&
    !traceBlocked &&
    !drawerBlocked &&
    unresolvedAttempts.length === 0 &&
    target > 0n
      ? `${workspace.id}:${target}`
      : null;

  const completeFallback = (failure: unknown) =>
    totalIsZero && posFailureKey(failure) === 'forbidden' ? 'paymentZeroTotalApproval' : undefined;

  // What is still due on a workspace the server just returned.
  function dueOf(current: PosWorkspace) {
    const remaining = BigInt(
      parseVndAmount(current.financial?.remaining ?? current.totals?.total ?? '') ?? '0',
    );
    return remaining > sponsorDue ? remaining - sponsorDue : 0n;
  }

  function prepareQr() {
    const method = vietqrMethod;
    if (!method || target <= 0n) return Promise.resolve(false);
    const amount = String(target);
    return run(() =>
      command((current) => tenders.prepare(current, { paymentMethodId: method.id, amount })),
    );
  }

  // Cancels the QR still waiting for its transfer; the server refuses when
  // the money already arrived, and that refusal is the caller's to show.
  async function releaseQr() {
    if (waitingQr)
      await command(async (current) => {
        let latest = current;
        for (const attempt of current.financial?.attempts ?? [])
          if (attempt.kind === 'vietqr' && attempt.status === 'prepared')
            latest = await tenders.cancel(latest, { attemptId: attempt.id });
        return latest;
      });
    triedQr.current = null;
  }

  const controls: PaymentControls = {
    busy,
    hold: setQrHold,
    // Someone who may not take payments here leaves the QR as it is.
    release: () => (disabled ? Promise.resolve(true) : run(releaseQr)),
    async whileReleased(action) {
      setQrHold(true);
      try {
        await releaseQr();
        return await action();
      } finally {
        setQrHold(false);
      }
    },
  };

  // Another method (a QR-less transfer) is prepared for what is due and
  // confirmed in the evidence dialog, as in the panel.
  function prepareOther(method: PosPaymentMethod) {
    const amount = String(target);
    void run(async () => {
      if (waitingQr) await releaseQr();
      await command((current) => tenders.prepare(current, { paymentMethodId: method.id, amount }));
    }).then((prepared) => {
      if (prepared) setEvidenceOpen(true);
    });
  }

  function chooseShare(parts: number | null) {
    if (shareDetails.current) shareDetails.current.open = false;
    const next =
      parts && parts > 1
        ? { workspaceId: workspace.id, parts, amount: String(evenShare(dueValue, parts)) }
        : null;
    setShare(next);
    const nextTarget = next && BigInt(next.amount) < dueValue ? BigInt(next.amount) : dueValue;
    // The waiting QR asks for the old amount: the next one asks for the part.
    if (waitingQr && qrAmount !== nextTarget) void run(releaseQr);
  }

  function pressKey(key: string) {
    const digits = (parseVndInput(cashRaw) ?? cashRaw.replace(/\D/g, '')).replace(/^0+/, '');
    const next = key === 'back' ? digits.slice(0, -1) : `${digits}${key}`.replace(/^0+/, '');
    setCashRaw(next ? groupVndDigits(next.slice(0, 12)) : '');
  }

  function finish() {
    const kind = finishKind;
    const attempt = qrAttempt;
    const received = qrIn;
    const cash = cashMethod;
    const handedAmount = handed ?? '0';
    printOnComplete.current = finishes;
    void run(async () => {
      let latest: PosWorkspace | undefined;
      // Money the bank reported is confirmed first; a QR still waiting goes.
      if (attempt && received)
        latest = await command((current) =>
          tenders.confirm(current, { attemptId: attempt.id, evidenceKind: 'vietqr_webhook' }),
        );
      else if (attempt && kind === 'cash')
        latest = await command((current) => tenders.cancel(current, { attemptId: attempt.id }));
      if (kind === 'cash' && cash)
        latest = await command(async (current) => {
          const due = dueOf(current);
          const part = shareValue !== null && shareValue < due ? shareValue : due;
          const pays = smaller(cashOver, part);
          if (pays <= 0n) return current;
          const prepared = await tenders.prepare(current, {
            paymentMethodId: cash.id,
            amount: String(pays),
          });
          const cashAttempt = (prepared.financial?.attempts ?? []).find(
            (item) => item.kind === 'cash' && item.status === 'prepared',
          );
          if (!cashAttempt) return prepared;
          return tenders.confirm(prepared, {
            attemptId: cashAttempt.id,
            evidenceKind: 'cash_count',
            handedAmount,
            tipAmount: tipValue > 0n ? String(tipValue) : undefined,
          });
        });
      if (latest ? paidInFull(latest, sponsorDue) : kind === 'complete')
        await command((current) =>
          tenders.complete(current, undefined, buyerDetails, completeOptions),
        );
    }, completeFallback).then((done) => {
      // The QR may have gone: the next one asks for what is left.
      triedQr.current = null;
      if (!done) printOnComplete.current = false;
      if (done) {
        setCashRaw('');
        setTipRaw('');
      }
    });
  }

  // biome-ignore lint/correctness/useExhaustiveDependencies: prepares once per order and amount, while no other tender waits
  useEffect(() => {
    if (!autoQr || triedQr.current === autoQr) return;
    triedQr.current = autoQr;
    void prepareQr();
  }, [autoQr]);

  if (!fullscreen && !canCollect && !financial) return null;

  // In a popover on the full screen; the panel lays the same fields out inline.
  const popover = (children: ReactNode) =>
    fullscreen ? <div className="pay-popover">{children}</div> : children;
  const plain = (value: bigint) => groupVndDigits(String(value));

  const drawerNote = drawerBlocked ? (
    <p className="attention-box" role="note" id="pos-drawer-closed">
      {t('paymentNeedsOpenShift')}
    </p>
  ) : null;
  const traceBox = traceBlocked ? (
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
  ) : null;
  // The full screen shows its waiting QR in its own card, not in the list.
  const listedAttempts = nonCanceledAttempts.filter((attempt) => attempt.id !== qrAttempt?.id);
  const attemptHistory = listedAttempts.length ? (
    <details className="payment-history">
      <summary>
        {t('paymentAttempts')} ({listedAttempts.length})
      </summary>
      <ul className="attempt-list">
        {listedAttempts.map((attempt) => (
          <li key={attempt.id}>
            <span>
              {methodLabel(attempt)}
              <small>{t(`tenderStatus_${attempt.status}`, { defaultValue: attempt.status })}</small>
            </span>
            <strong>{formatMoney(attempt.amount, attempt.currency)}</strong>
          </li>
        ))}
      </ul>
    </details>
  ) : null;
  const held =
    heldAttempts.length > 0 && !evidenceOpen ? (
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
    ) : null;
  const evidence =
    preparedAttempts.length > 0 && evidenceOpen ? (
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
    ) : null;
  const creditAction =
    canCollect &&
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
            !creditEnabled || locked || traceBlocked || drawerBlocked || blockingAttempts.length > 0
          }
          aria-describedby={
            !creditEnabled
              ? 'pos-credit-off'
              : blockedBy
                ? blockedBy
                : blockingAttempts.length > 0
                  ? 'pos-credit-blocked'
                  : undefined
          }
          title={workspace.customer ? undefined : t('creditCustomerRequired')}
          onClick={() => {
            setError('');
            if (!waitingQr) {
              setCreditOpen(true);
              return;
            }
            // Credit completes the order: the waiting QR goes first.
            setQrHold(true);
            void run(releaseQr).then((released) => {
              if (released) setCreditOpen(true);
              else setQrHold(false);
            });
          }}
        >
          <PosIcon name="user" />
          {t('creditAction')}
        </button>
        {!creditEnabled ? <FeatureOffNote feature="credit" id="pos-credit-off" /> : null}
        {creditEnabled && blockingAttempts.length > 0 ? (
          <small className="muted" id="pos-credit-blocked">
            {t('creditBlockedByTender')}
          </small>
        ) : null}
      </>
    ) : null;
  const closeCredit = () => {
    setCreditOpen(false);
    setError('');
    setQrHold(false);
  };
  const creditDialogs = (
    <>
      {creditOpen && creditEnabled && quickCredit && !completed ? (
        <QuickCreditDialog
          workspace={workspace}
          busy={busy || disabled}
          error={error}
          onClose={closeCredit}
          onConfirm={() =>
            void run(() =>
              command(async (current) => {
                const approval = await quickApproveCredit(current);
                return tenders.complete(current, approval.approval_id, buyerDetails);
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
          onClose={closeCredit}
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
    </>
  );
  const einvoice =
    canCollect && einvoiceType !== 'none' && !completed && financial && hasItems ? (
      <details
        className={
          fullscreen
            ? 'einvoice-buyer checkout-optional pay-foot-menu'
            : 'einvoice-buyer checkout-optional'
        }
      >
        <summary>
          {fullscreen ? t('payEinvoice') : t('einvoiceBuyerTitle')}
          {buyerDetails ? ` · ${buyer.name || buyer.tax_code || t('einvoiceBuyerFilled')}` : ''}
        </summary>
        {popover(
          <>
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
          </>,
        )}
      </details>
    ) : null;
  const storedValue =
    canCollect && storedValueCards && !mealSponsor && !completed && financial && hasItems ? (
      <details className="stored-value-pay checkout-optional">
        <summary>{t('storedValuePay')}</summary>
        {popover(
          <>
            <small className="muted">{t('storedValuePayHint')}</small>
            <label>
              {t('storedValueReading')}
              <input
                value={cardReading}
                autoComplete="off"
                maxLength={120}
                disabled={locked}
                placeholder={t('storedValueReadingHint')}
                onChange={(event) => setCardReading(event.target.value)}
              />
            </label>
            <button
              type="button"
              disabled={
                locked ||
                traceBlocked ||
                drawerBlocked ||
                blockingAttempts.length > 0 ||
                remainingIsZero ||
                !cardReading.trim()
              }
              aria-describedby={blockedBy}
              onClick={() => {
                const reading = cardReading.trim();
                setCardNotice('');
                void run(async () => {
                  const card = await lookupStoredValueCard(workspace.branch_id, reading);
                  if (!card) throw new StoredValueMissing();
                  if (waitingQr) await releaseQr();
                  let paid: unknown = null;
                  await command(async (current) => {
                    const result = await tenders.payStoredValue(current, card.id);
                    paid = result.card;
                    return result.workspace;
                  });
                  const after = normalizeStoredValueCard(paid);
                  setCardReading('');
                  setCardNotice(
                    t('storedValuePaid', {
                      hint: card.cardHint,
                      balance: formatMoney(after?.balance ?? '0', card.currency),
                    }),
                  );
                });
              }}
            >
              {t('storedValuePaySubmit')}
            </button>
            {cardNotice ? <p role="status">{cardNotice}</p> : null}
          </>,
        )}
      </details>
    ) : null;
  const receiptPrint = completed ? (
    <ReceiptPrintButton sourceId={workspace.id} label={t('receiptPrint')} autoPrint={autoPrint} />
  ) : null;
  const handover = (
    <>
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
    </>
  );
  const fundsAllocate =
    canResolve && (availableFunds.length > 0 || activeAllocations.length > 0) ? (
      <details className="funds-allocate checkout-optional">
        <summary>{t('paymentAllocate')}</summary>
        {popover(
          <>
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
                void run(async () => {
                  if (waitingQr) await releaseQr();
                  await command((current) =>
                    tenders.allocate(current, { fundsId: allocateFundsId, amount: parsedAllocate }),
                  );
                }).then((done) => {
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
          </>,
        )}
      </details>
    ) : null;
  const errorLine =
    error && !(preparedAttempts.length > 0 && evidenceOpen) && !creditOpen ? (
      <p className="error" role="alert">
        {error}
      </p>
    ) : null;

  if (fullscreen) {
    const finishLabel = busy
      ? t('waiting')
      : finishes || finishKind === null
        ? t('payFinish')
        : finishKind === 'cash'
          ? t('payCollectCash', { amount: formatMoney(String(cashPays), currency) })
          : t('payCollectQr', { amount: formatMoney(String(qrAmount), currency) });
    return (
      <section className="pay-screen" aria-label={t('paymentTitle')}>
        {bill?.(controls)}
        <div className="pay-main">
          {drawerNote}
          {traceBox}
          <dl className="pay-due">
            <div>
              <dt>{t('payDue')}</dt>
              <dd>{formatMoney(workspace.totals?.total ?? '0', currency)}</dd>
              {shareValue !== null && share ? (
                <small>
                  {t('paySplitEvenOn', {
                    parts: share.parts,
                    amount: formatMoney(String(shareValue), currency),
                  })}
                </small>
              ) : null}
            </div>
            <div className="pay-due-left">
              <dt>{t('payLeft')}</dt>
              <dd>{formatMoney(String(leftPreview), currency)}</dd>
            </div>
            <div className="pay-due-change">
              <dt>{t('payChange')}</dt>
              <dd>{formatMoney(String(changePreview), currency)}</dd>
            </div>
          </dl>
          {completed ? (
            <div className="pay-done">
              <p role="status">{t('payCompleted')}</p>
              {receiptPrint}
              {handover}
            </div>
          ) : !canCollect ? (
            <p className="muted">{t('payNoRight')}</p>
          ) : (
            <>
              {held}
              <div className={vietqrMethod ? 'pay-cards' : 'pay-cards pay-cards-single'}>
                {vietqrMethod ? (
                  <VietqrCard
                    attempt={qrAttempt}
                    summary={qrSummary}
                    loading={qrQuery.isLoading}
                    failed={qrQuery.isError}
                    amount={String(target)}
                    currency={currency}
                    disabled={locked || traceBlocked || drawerBlocked}
                    canShow={unresolvedAttempts.length === 0 && target > 0n && hasItems}
                    onShow={() => {
                      triedQr.current = autoQr;
                      void prepareQr();
                    }}
                    onManual={() => setEvidenceOpen(true)}
                  />
                ) : null}
                {cashMethod ? (
                  <section className="pay-card pay-cash" aria-label={t('cash')}>
                    <h3>
                      <PosIcon name="cash" /> {t('cash')}
                    </h3>
                    <div className="pay-cash-body">
                      <div className="pay-cash-quick">
                        <button
                          type="button"
                          className="pay-cash-exact"
                          disabled={cashLocked || target <= 0n}
                          onClick={() => setCashRaw(plain(target + tipValue))}
                        >
                          {t('payCashExact', { amount: plain(target + tipValue) })}
                        </button>
                        {cashSuggestions(target + tipValue).map((value) => (
                          <button
                            key={String(value)}
                            type="button"
                            disabled={cashLocked}
                            onClick={() => setCashRaw(plain(value))}
                          >
                            {plain(value)}
                          </button>
                        ))}
                      </div>
                      <div className="pay-keypad">
                        <input
                          className="money-input pay-keypad-display"
                          inputMode="numeric"
                          autoComplete="off"
                          aria-label={t('paymentHanded')}
                          placeholder="0"
                          value={cashRaw}
                          aria-invalid={cashInvalid}
                          disabled={cashLocked}
                          onChange={(event) => setCashRaw(event.target.value)}
                        />
                        {KEYPAD.map((key) => (
                          <button
                            key={key}
                            type="button"
                            disabled={cashLocked}
                            aria-label={key === 'back' ? t('payKeypadBack') : undefined}
                            onClick={() => pressKey(key)}
                          >
                            {key === 'back' ? '⌫' : key}
                          </button>
                        ))}
                      </div>
                    </div>
                    {cashTip ? (
                      <label className="pay-cash-tip">
                        {t('paymentTip')}
                        <input
                          className="money-input"
                          inputMode="numeric"
                          autoComplete="off"
                          placeholder="0"
                          value={tipRaw}
                          aria-invalid={tipInvalid}
                          disabled={cashLocked}
                          onChange={(event) => setTipRaw(event.target.value)}
                        />
                      </label>
                    ) : null}
                    {cashInvalid ? (
                      <p className="error" role="alert">
                        {t('paymentAmountInvalid')}
                      </p>
                    ) : null}
                  </section>
                ) : null}
              </div>
              <div className="pay-others">
                {otherMethods.map((method) => (
                  <button
                    key={method.id}
                    type="button"
                    disabled={
                      locked ||
                      traceBlocked ||
                      drawerBlocked ||
                      blockingAttempts.length > 0 ||
                      target <= 0n ||
                      !hasItems
                    }
                    aria-describedby={blockedBy}
                    onClick={() => prepareOther(method)}
                  >
                    <PosIcon name={methodIcon(method.kind)} />
                    {choiceLabel(method)}
                  </button>
                ))}
                {storedValue}
                {creditAction}
                {fundsAllocate}
              </div>
              {methodsQuery.isLoading ? <p role="status">{t('waiting')}</p> : null}
              {methodsQuery.isError ? (
                <p className="error" role="alert">
                  {t(posFailureKey(methodsQuery.error))}
                </p>
              ) : null}
              {!disabled && methodsQuery.isSuccess && methods.length === 0 ? (
                <p className="muted">{t('paymentNoMethods')}</p>
              ) : null}
            </>
          )}
          {attemptHistory}
          {errorLine}
          <div className="pay-foot">
            {canCollect && !completed && financial && hasItems ? (
              <details className="pay-foot-menu pay-split-even" ref={shareDetails}>
                <summary>
                  {shareValue !== null && share
                    ? t('paySplitEvenParts', { count: share.parts })
                    : t('paySplitEven')}
                </summary>
                <div className="pay-popover pay-split-options">
                  {[2, 3, 4, 5, 6].map((parts) => (
                    <button
                      key={parts}
                      type="button"
                      aria-pressed={share?.parts === parts && shareValue !== null}
                      disabled={locked}
                      onClick={() => chooseShare(parts)}
                    >
                      {t('paySplitEvenParts', { count: parts })}
                    </button>
                  ))}
                  {shareValue !== null ? (
                    <button type="button" disabled={locked} onClick={() => chooseShare(null)}>
                      {t('paySplitEvenOff')}
                    </button>
                  ) : null}
                </div>
              </details>
            ) : null}
            {tools?.(controls)}
            {einvoice}
            {!completed ? (
              <button
                type="button"
                className="pay-finish"
                aria-describedby={blockedBy}
                disabled={finishDisabled}
                onClick={finish}
              >
                {finishLabel}
              </button>
            ) : null}
          </div>
        </div>
        {evidence}
        {creditDialogs}
      </section>
    );
  }

  return (
    <section className="payment-panel" aria-label={t('paymentTitle')}>
      <h3 id="pos-payment-title">{t('paymentMethods')}</h3>
      {drawerNote}
      {traceBox}
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
      {attemptHistory}
      {held}
      {evidence}
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
      {creditAction}
      {creditDialogs}
      {einvoice}
      {storedValue}
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
              completeFallback,
            )
          }
        >
          {t('paymentComplete')}
        </button>
      ) : null}
      {receiptPrint}
      {handover}
      {fundsAllocate}
      {errorLine}
    </section>
  );
}

const KEYPAD = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '000', '0', 'back'];

// The QR of the full payment screen, shown as soon as it is prepared, with
// the amount, where it goes and whether the bank has reported the transfer.
function VietqrCard({
  attempt,
  summary,
  loading,
  failed,
  amount,
  currency,
  disabled,
  canShow,
  onShow,
  onManual,
}: {
  attempt: PosFinancialAttempt | undefined;
  summary: VietqrTenderSummary | null;
  loading: boolean;
  failed: boolean;
  // What the next QR asks for, shown before it is prepared.
  amount: string;
  currency: string;
  disabled: boolean;
  canShow: boolean;
  onShow: () => void;
  // The bank never reported it: the cashier attests it in the evidence dialog.
  onManual: () => void;
}) {
  const { t } = useTranslation();
  const received = vietqrReceived(summary);
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!attempt || received) return;
    const timer = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, [attempt, received]);
  const timeLeft = vietqrTimeLeft(summary?.expires_at, now);
  return (
    <section className="pay-card pay-card-active pay-vietqr" aria-label={t('vietqr')}>
      <h3>
        <PosIcon name="qr" /> {t('payVietqrTitle')}
      </h3>
      {attempt ? (
        <>
          {summary?.qr_url && !received ? (
            <img
              className="pay-qr"
              src={summary.qr_url}
              alt={t('vietqrImageAlt')}
              width={176}
              height={176}
            />
          ) : null}
          <strong className="pay-qr-amount">{formatMoney(attempt.amount, attempt.currency)}</strong>
          {summary ? (
            <small className="pay-qr-note">
              {[summary.bank_name, summary.account_name, summary.account_number]
                .filter(Boolean)
                .join(' · ')}
              {summary.transfer_content
                ? ` · ${t('paymentTransferContent')}: ${summary.transfer_content}`
                : ''}
            </small>
          ) : null}
          <p className={received ? 'pay-qr-status received' : 'pay-qr-status'} role="status">
            {loading
              ? t('waiting')
              : failed
                ? t('vietqrStatusUnknown')
                : received
                  ? t('vietqrReceived')
                  : timeLeft
                    ? t('payVietqrWaiting', { time: timeLeft })
                    : t('vietqrExpired')}
          </p>
          {!received ? (
            <button type="button" className="pay-qr-manual" disabled={disabled} onClick={onManual}>
              {t('vietqrManualConfirm')}
            </button>
          ) : null}
        </>
      ) : (
        <>
          <strong className="pay-qr-amount">{formatMoney(amount, currency)}</strong>
          <button type="button" disabled={disabled || !canShow} onClick={onShow}>
            <PosIcon name="qr" />
            {t('paymentShowVietqr')}
          </button>
        </>
      )}
    </section>
  );
}
