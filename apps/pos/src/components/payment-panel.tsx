import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  usePaymentMethods,
  useReceivedFundDetail,
  useReceivedFunds,
  useTenders,
} from '../hooks/use-tenders';
import { formatMoney, parseVndAmount, parseVndInput } from '../lib/money';
import type { PosPaymentMethod, PosWorkspace } from '../lib/pos-context';
import { describeFailure, posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { TenderEvidenceDialog, type TenderEvidenceItemInput } from './tender-evidence-dialog';

type MethodKind = 'cash' | 'bank_manual';
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
  disabled,
  command,
}: {
  workspace: PosWorkspace;
  staffId: string | null;
  storeId: string | null;
  canCollect: boolean;
  canResolve: boolean;
  disabled: boolean;
  // Runs through the workspace's serializer and hands over its newest revision.
  command: WorkspaceCommand;
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
    cash?: string;
    bank_manual?: string;
  } | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [evidenceOpen, setEvidenceOpen] = useState(false);
  const [handedOver, setHandedOver] = useState(false);
  const financial = workspace.financial;
  const methods = methodsQuery.data ?? [];
  const activeMethods = methods.filter((method) => activeKinds.includes(method.kind));
  const effectiveMethods = activeMethods.length > 0 ? activeMethods : methods.slice(0, 1);
  const preparedAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status === 'prepared',
  );
  const completed = workspace.operational_status === 'completed';
  const remainingIsZero = financial ? parseVndAmount(financial.remaining) === '0' : false;
  const totalIsZero = parseVndAmount(workspace.totals?.total ?? '') === '0';
  const currency = workspace.totals?.currency ?? 'VND';
  const hasItems = (workspace.line_items?.length ?? 0) > 0;
  const nonCanceledAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status !== 'canceled',
  );
  const hasPaymentActivity = Boolean(
    financial &&
      (nonCanceledAttempts.length > 0 ||
        Number(financial.received) > 0 ||
        Number(financial.allocated) > 0 ||
        Number(financial.unapplied) > 0 ||
        Number(financial.change_due) > 0),
  );
  const defaultAmount =
    parseVndAmount(
      hasPaymentActivity
        ? (financial?.remaining ?? workspace.totals?.total ?? '')
        : (workspace.totals?.total ?? financial?.remaining ?? ''),
    ) ?? '';
  const locked = disabled || busy;

  function methodLabel(method: { kind: string; name?: string }) {
    return method.kind === 'cash'
      ? t('cash')
      : method.kind === 'bank_manual'
        ? t('bankTransfer')
        : (method.name ?? method.kind);
  }

  function getRowValue(kind: MethodKind): string {
    const current = customAmounts?.base === defaultAmount ? customAmounts : null;
    if (effectiveMethods.length === 1) {
      return current?.[kind] ?? defaultAmount;
    }
    if (kind === 'cash') {
      return current?.cash ?? defaultAmount;
    }
    const cashVal = BigInt(parseVndInput(current?.cash ?? defaultAmount) ?? 0);
    const target = BigInt(defaultAmount || 0);
    return current?.bank_manual ?? String(target > cashVal ? target - cashVal : 0n);
  }

  function updateRowValue(kind: MethodKind, rawValue: string) {
    const target = BigInt(defaultAmount || 0);
    const parsed = BigInt(parseVndInput(rawValue) ?? 0);
    const remainder = String(target > parsed ? target - parsed : 0n);
    setCustomAmounts((prev) => {
      const current = prev?.base === defaultAmount ? prev : { base: defaultAmount };
      if (effectiveMethods.length > 1) {
        return kind === 'cash'
          ? { base: defaultAmount, cash: rawValue, bank_manual: remainder }
          : { base: defaultAmount, bank_manual: rawValue, cash: remainder };
      }
      return { ...current, base: defaultAmount, [kind]: rawValue };
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
    return describeFailure(failure, t, fallbackKey);
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
    const raw = getRowValue(method.kind);
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
    return run(() =>
      eachRow(
        inputs,
        (input) => methodLabel({ kind: kindOf(input.attemptId) }),
        (input) =>
          command((current) =>
            tenders.confirm(current, {
              attemptId: input.attemptId,
              handedAmount: input.handedAmount,
              receivedAmount: input.receivedAmount,
              evidenceKind: input.evidenceKind,
              reference: input.reference,
              receivingAccount: input.receivingAccount,
              terminalRef: input.terminalRef,
            }),
          ),
      ),
    );
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
          <div className="remaining-row">
            <dt>{t('paymentRemaining')}</dt>
            <dd>{formatMoney(financial.remaining, currency)}</dd>
          </div>
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
                  {attempt.kind === 'cash' ? t('cash') : t('bankTransfer')}
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
          attempts={preparedAttempts}
          disabled={disabled}
          busy={busy}
          error={error}
          onConfirm={confirmEvidence}
          onCancel={cancelPrepared}
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
              >
                <PosIcon name={method.kind === 'cash' ? 'cash' : 'bank'} />
                {methodLabel(method)}
              </button>
            ))}
          </fieldset>
          <div className="payment-method-rows">
            {rows.map(({ method, raw, amount }) => (
              <label className="payment-method-row" key={method.id} data-method={method.kind}>
                <span className="payment-method-badge">
                  <PosIcon name={method.kind === 'cash' ? 'cash' : 'bank'} />
                  <strong>{methodLabel(method)}</strong>
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
            disabled={
              locked ||
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
      {canCollect && !completed && financial && remainingIsZero && hasItems ? (
        <button
          type="button"
          className="checkout-submit"
          disabled={locked || preparedAttempts.length > 0}
          onClick={() =>
            void run(
              () => command((current) => tenders.complete(current)),
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
      {error && !(preparedAttempts.length > 0 && evidenceOpen) ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
