import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  usePaymentMethods,
  useReceivedFundDetail,
  useReceivedFunds,
  useTenders,
} from '../hooks/use-tenders';
import { workspaceEditorId } from '../hooks/use-workspaces';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosPaymentMethod, PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { TenderEvidenceDialog } from './tender-evidence-dialog';

type MethodKind = 'cash' | 'bank_manual';

export function PaymentPanel({
  workspace,
  staffId,
  storeId,
  canCollect,
  canResolve,
  disabled,
}: {
  workspace: PosWorkspace;
  staffId: string | null;
  storeId: string | null;
  canCollect: boolean;
  canResolve: boolean;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  const tenders = useTenders(staffId, storeId, workspace);
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
  const financial = workspace.financial;
  const methods = methodsQuery.data ?? [];
  const activeMethods = methods.filter((method) => activeKinds.includes(method.kind));
  const effectiveMethods = activeMethods.length > 0 ? activeMethods : methods.slice(0, 1);
  const preparedAttempts = (financial?.attempts ?? []).filter(
    (attempt) => attempt.status === 'prepared',
  );
  const completed = workspace.operational_status === 'completed';
  const remainingIsZero = financial ? Number(financial.remaining) === 0 : false;
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

  function getRowValue(kind: MethodKind): string {
    const current = customAmounts?.base === defaultAmount ? customAmounts : null;
    if (effectiveMethods.length === 1) {
      return current?.[kind] ?? defaultAmount;
    }
    if (kind === 'cash') {
      return current?.cash ?? defaultAmount;
    }
    const cashVal = Number(parseVndAmount(current?.cash ?? defaultAmount) ?? 0);
    const autoRemainder = String(Math.max(Number(defaultAmount || 0) - cashVal, 0));
    return current?.bank_manual ?? autoRemainder;
  }

  function updateRowValue(kind: MethodKind, rawValue: string) {
    const target = Number(defaultAmount || 0);
    const parsed = Number(parseVndAmount(rawValue) ?? 0);
    const remainder = String(Math.max(target - parsed, 0));
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
    (funds) => funds.available !== '0.0' && funds.available !== '0',
  );
  const activeAllocations = (allocateDetailQuery.data?.allocations ?? []).filter(
    (allocation) => allocation.workspace_id === workspace.id && allocation.status === 'active',
  );

  async function run(action: () => Promise<unknown>) {
    setBusy(true);
    setError('');
    try {
      await action();
      setCustomAmounts(null);
    } catch (failure) {
      setError(t(posFailureKey(failure)));
    } finally {
      setBusy(false);
    }
  }

  const entriesToPrepare = effectiveMethods
    .map((method) => ({
      method,
      amount: parseVndAmount(getRowValue(method.kind)),
    }))
    .filter((entry): entry is { method: PosPaymentMethod; amount: string } =>
      Boolean(entry.amount && Number(entry.amount) > 0),
    );

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
      {preparedAttempts.length > 0 ? (
        <TenderEvidenceDialog
          workspace={workspace}
          attempts={preparedAttempts}
          disabled={disabled}
          busy={busy}
          labels={{
            cancel: t('paymentCancel'),
            handed: t('paymentHanded'),
            reference: t('paymentReference'),
            account: t('paymentAccount'),
          }}
          onConfirm={(inputs) =>
            run(async () => {
              let currentRevision = workspace.revision;
              for (const input of inputs) {
                const updated = await tenders.confirm(workspaceEditorId, {
                  expectedRevision: currentRevision,
                  attemptId: input.attemptId,
                  handedAmount: input.handedAmount,
                  evidenceKind: input.evidenceKind,
                  reference: input.reference,
                  receivingAccount: input.receivingAccount,
                  terminalRef: input.terminalRef,
                });
                currentRevision = updated.revision;
              }
            })
          }
          onCancel={() =>
            run(async () => {
              let currentRevision = workspace.revision;
              for (const attempt of preparedAttempts) {
                const updated = await tenders.cancel(workspaceEditorId, {
                  expectedRevision: currentRevision,
                  attemptId: attempt.id,
                });
                currentRevision = updated.revision;
              }
            })
          }
        />
      ) : null}
      {canCollect && !completed && (!remainingIsZero || !hasItems) ? (
        <form
          onSubmit={(event) => {
            event.preventDefault();
            if (entriesToPrepare.length === 0) {
              setError(t('invalid'));
              return;
            }
            void run(async () => {
              let currentRevision = workspace.revision;
              for (const entry of entriesToPrepare) {
                const updated = await tenders.prepare(workspaceEditorId, {
                  expectedRevision: currentRevision,
                  paymentMethodId: entry.method.id,
                  amount: entry.amount,
                });
                currentRevision = updated.revision;
              }
            });
          }}
        >
          <fieldset className="payment-methods" aria-label={t('paymentMethod')}>
            {methods.map((method) => (
              <button
                type="button"
                key={method.id}
                aria-pressed={effectiveMethods.some((item) => item.id === method.id)}
                disabled={disabled || busy || preparedAttempts.length > 0}
                onClick={() => toggleMethod(method.kind)}
              >
                <PosIcon name={method.kind === 'cash' ? 'cash' : 'bank'} />
                {method.kind === 'cash'
                  ? t('cash')
                  : method.kind === 'bank_manual'
                    ? t('bankTransfer')
                    : method.name}
              </button>
            ))}
          </fieldset>
          <div className="payment-method-rows">
            {effectiveMethods.map((method) => {
              const methodLabel =
                method.kind === 'cash'
                  ? t('cash')
                  : method.kind === 'bank_manual'
                    ? t('bankTransfer')
                    : method.name;
              const rowValue = getRowValue(method.kind);
              return (
                <label className="payment-method-row" key={method.id} data-method={method.kind}>
                  <span className="payment-method-badge">
                    <PosIcon name={method.kind === 'cash' ? 'cash' : 'bank'} />
                    <strong>{methodLabel}</strong>
                  </span>
                  <input
                    inputMode="numeric"
                    className="money-input"
                    value={rowValue}
                    placeholder={defaultAmount}
                    onChange={(event) => updateRowValue(method.kind, event.target.value)}
                    disabled={disabled || busy || preparedAttempts.length > 0}
                    required={effectiveMethods.length === 1}
                  />
                </label>
              );
            })}
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
          <button
            className="checkout-submit"
            type="submit"
            disabled={
              disabled ||
              busy ||
              preparedAttempts.length > 0 ||
              !hasItems ||
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
          disabled={disabled || busy || !hasItems}
          onClick={() => void run(() => tenders.complete(workspaceEditorId))}
        >
          {t('paymentComplete')}
        </button>
      ) : null}
      {completed ? (
        <button
          className="checkout-submit"
          type="button"
          disabled={busy}
          onClick={() => void run(() => tenders.handover())}
        >
          {t('paymentHandover')}
        </button>
      ) : null}
      {canResolve && (availableFunds.length > 0 || activeAllocations.length > 0) ? (
        <details className="funds-allocate checkout-optional">
          <summary>{t('paymentAllocate')}</summary>
          <label>
            {t('paymentUnapplied')}
            <select
              value={allocateFundsId}
              onChange={(event) => setAllocateFundsId(event.target.value)}
              disabled={disabled || busy}
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
              value={allocateAmount}
              onChange={(event) => setAllocateAmount(event.target.value)}
              disabled={disabled || busy}
            />
          </label>
          <button
            type="button"
            disabled={disabled || busy || !allocateFundsId || !parseVndAmount(allocateAmount)}
            onClick={() =>
              void run(() =>
                tenders.allocate(workspaceEditorId, {
                  fundsId: allocateFundsId,
                  amount: parseVndAmount(allocateAmount) ?? undefined,
                }),
              )
            }
          >
            {t('paymentAllocate')}
          </button>
          {activeAllocations.map((allocation) => (
            <p key={allocation.id}>
              {formatMoney(allocation.amount, allocation.currency)} · {allocation.status}{' '}
              {!completed ? (
                <button
                  type="button"
                  disabled={disabled || busy}
                  onClick={() =>
                    void run(() =>
                      tenders.reverse(workspaceEditorId, { allocationId: allocation.id }),
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
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
