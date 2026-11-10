import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import {
  expiryState,
  formatExpiry,
  lotChoiceRequired,
  type ReturnLineTraceRow,
  type ReturnPreviewTrace,
  returnableLots,
  returnableSerials,
} from '@parkviet/pos-shared/traceability';
import { useNavigate, useSearch } from '@tanstack/react-router';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FeatureOffNote } from '../components/feature-off-note';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintButton } from '../components/receipt-print-dialog';
import { RefundActions } from '../components/refund-actions';
import { RefundEvidenceDialog } from '../components/refund-evidence-dialog';
import { lotLabel, SoldTrace } from '../components/sold-trace';
import {
  type ReturnLineInput,
  useExchange,
  useOrder,
  usePendingReturnCommands,
  useRefundCommands,
  useReturn,
  useReturnCommands,
  useReturnPreview,
} from '../hooks/use-returns';
import { writesLocked } from '../lib/pos-context';
import { definitiveRejection, posFailureKey } from '../lib/request-failure';
import {
  canCancelReturn,
  canProcessReturns,
  canReadReturns,
  compareMoney,
  defaultRefundAmount,
  describeReturnFailure,
  type PosExchange,
  type PosOrderDetail,
  type PosRefundRequest,
  type PosReturn,
  parseQuantityInput,
  type ReturnCondition,
  type ReturnPreview,
  type ReturnSelection,
  saleQuantityLabel,
  selectionError,
  selectionLines,
} from '../lib/returns';
import { todayIn } from '../lib/shifts';
import { readLayout, writeLayout } from '../lib/workspace-storage';

type Search = { orderId?: string; returnId?: string };

export function ReturnExchangePage() {
  const { context, selection } = usePosSelection();
  const search = useSearch({ strict: false }) as Search;
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}:${search.orderId ?? ''}:${search.returnId ?? ''}`;
  return <ReturnExchange key={scope} search={search} />;
}

// Lost responses are not failures: the command may have been recorded. The
// browser keeps its key and the screen says it is checking.
function failureText(error: unknown, t: (key: string) => string): string {
  return definitiveRejection(error) ? describeReturnFailure(error, t) : t('pendingCheckingLost');
}

function ReturnExchange({ search }: { search: Search }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const [numberInput, setNumberInput] = useState('');
  const [lookup, setLookup] = useState<{ orderId?: string; number?: string } | null>(
    search.orderId ? { orderId: search.orderId } : null,
  );
  const order = useOrder(lookup, branchId, Boolean(lookup) && !search.returnId);

  return (
    <PosPage title={t('returnTitle')} description={t('returnHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !canReadReturns(data?.capabilities) ? (
        <PageState title={t('forbidden')} description={t('returnForbiddenHint')} />
      ) : search.returnId ? (
        <ReturnProgress
          returnId={search.returnId}
          branchId={branchId}
          registerId={selection.registerId ?? null}
          locked={!data || writesLocked(data, selection)}
        />
      ) : !canProcessReturns(data?.capabilities) ? (
        <PageState title={t('forbidden')} description={t('returnForbiddenHint')} />
      ) : !contextFeature(data, 'returns') ? (
        <PageState title={t('featureOffTitle')}>
          <FeatureOffNote feature="returns" />
        </PageState>
      ) : (
        <section className="page-card" aria-label={t('returnFindOrder')}>
          <form
            className="row"
            onSubmit={(event) => {
              event.preventDefault();
              const number = numberInput.trim().toUpperCase();
              if (number) setLookup({ number });
            }}
          >
            <label>
              {t('returnOrderNumber')}
              <input
                value={numberInput}
                maxLength={64}
                autoComplete="off"
                onChange={(event) => setNumberInput(event.target.value)}
              />
            </label>
            <button type="submit">{t('returnFind')}</button>
          </form>
          {order.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
          {order.isError ? (
            <PageState
              kind="error"
              title={t(posFailureKey(order.error))}
              description={t('returnFindHint')}
            />
          ) : null}
          {order.data ? (
            <ReturnForm
              order={order.data}
              branchId={branchId}
              locked={!data || writesLocked(data, selection)}
              onPrepared={(operation) =>
                void navigate({ to: '/returns', search: { returnId: operation.id }, replace: true })
              }
            />
          ) : null}
        </section>
      )}
    </PosPage>
  );
}

function ReturnForm({
  order,
  branchId,
  locked,
  onPrepared,
}: {
  order: PosOrderDetail;
  branchId: string;
  locked: boolean;
  onPrepared: (operation: PosReturn) => void;
}) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const [selected, setSelected] = useState<ReturnSelection>({});
  const [raw, setRaw] = useState<Record<string, string>>({});
  const [reason, setReason] = useState('');
  const [preview, setPreview] = useState<ReturnPreview | null>(null);
  const [error, setError] = useState('');
  const previewer = useReturnPreview();
  const { prepare } = useReturnCommands(
    context.data?.staff.id ?? null,
    context.data?.store.id ?? null,
  );
  const money = (value: string | null | undefined) => formatMoney(value, order.currency);
  const invalidQuantity = Object.values(raw).some((value) => parseQuantityInput(value) === null);
  const problem = invalidQuantity ? 'returnQuantityInvalid' : selectionError(order.lines, selected);
  const lines: ReturnLineInput[] = selectionLines(order.lines, selected);
  const busy = previewer.isPending || prepare.isPending;
  // Expiry badges use the date at the branch taking the goods back.
  const branchZone =
    context.data?.branches.find((row) => row.id === branchId)?.timezone ??
    context.data?.store.timezone ??
    'Asia/Ho_Chi_Minh';
  const today = todayIn(branchZone);

  // Traced goods get no default condition: the cashier has to look and choose.
  function defaultCondition(saleLineId: string): ReturnCondition | null {
    return order.lines.find((line) => line.sale_line_id === saleLineId)?.trace
      ? null
      : 'resellable';
  }

  function change(saleLineId: string, quantityText: string, condition?: ReturnCondition | null) {
    setPreview(null);
    setRaw({ ...raw, [saleLineId]: quantityText });
    const quantity = parseQuantityInput(quantityText) ?? -1;
    const current = selected[saleLineId];
    setSelected({
      ...selected,
      [saleLineId]: {
        ...current,
        quantity,
        condition:
          condition !== undefined
            ? condition
            : (current?.condition ?? defaultCondition(saleLineId)),
      },
    });
  }

  // The serials ticked are the units coming back; their count is the quantity.
  function pickSerials(saleLineId: string, serials: string[]) {
    setPreview(null);
    setRaw({ ...raw, [saleLineId]: String(serials.length) });
    const current = selected[saleLineId];
    setSelected({
      ...selected,
      [saleLineId]: {
        quantity: serials.length,
        condition: current?.condition ?? defaultCondition(saleLineId),
        serial_codes: serials,
      },
    });
  }

  function pickLot(saleLineId: string, lotCode: string) {
    setPreview(null);
    const current = selected[saleLineId];
    setSelected({
      ...selected,
      [saleLineId]: {
        quantity: current?.quantity ?? 0,
        condition: current?.condition ?? defaultCondition(saleLineId),
        lot_code: lotCode || undefined,
      },
    });
  }

  return (
    <form
      className="return-form"
      aria-label={t('returnSelectLines')}
      onSubmit={(event) => {
        event.preventDefault();
        if (problem || busy || locked) return;
        setError('');
        if (!preview) {
          previewer.mutate(
            { branchId, orderId: order.id, lines },
            {
              onSuccess: setPreview,
              onError: (failure) => setError(describeReturnFailure(failure, t)),
            },
          );
          return;
        }
        if (!reason.trim()) {
          setError(t('returnReasonRequired'));
          return;
        }
        prepare.mutate(
          { branchId, orderId: order.id, lines, reason: reason.trim() },
          {
            onSuccess: (result) => onPrepared(result.data),
            onError: (failure) => setError(failureText(failure, t)),
          },
        );
      }}
    >
      <h2>{t('returnForOrder', { number: order.number })}</h2>
      {order.sale_branch_id !== branchId ? (
        <p className="attention-box">{t('returnCrossBranchNote')}</p>
      ) : null}
      <table className="order-lines-table">
        <thead>
          <tr>
            <th scope="col">{t('orderLineItem')}</th>
            <th scope="col">{t('orderLineSold')}</th>
            <th scope="col">{t('orderLineReturnable')}</th>
            <th scope="col">{t('returnQuantity')}</th>
            <th scope="col">{t('returnCondition')}</th>
          </tr>
        </thead>
        <tbody>
          {order.lines.map((line) => {
            const picked = selected[line.sale_line_id];
            const inputId = `return-qty-${line.sale_line_id}`;
            const serialLine = line.trace?.mode === 'serial';
            const serials = returnableSerials(line.trace);
            const lots = returnableLots(line.trace);
            const blocked = busy || locked || line.returnable_quantity === 0;
            return (
              <tr key={line.sale_line_id}>
                <th scope="row">
                  {serialLine ? line.name : <label htmlFor={inputId}>{line.name}</label>}
                  <SoldTrace trace={line.trace} today={today} />
                </th>
                <td>{saleQuantityLabel(line)}</td>
                <td>
                  {line.handed_over
                    ? `${line.returnable_quantity} ${line.base_unit}`
                    : t('orderNotHandedOver')}
                </td>
                <td>
                  {serialLine ? (
                    <fieldset
                      className="return-serials"
                      aria-label={t('returnSerialsFor', { name: line.name })}
                      disabled={blocked}
                    >
                      {serials.length === 0 ? (
                        <small className="muted">{t('returnNoSerialsLeft')}</small>
                      ) : null}
                      {serials.map((serial) => {
                        const chosen = picked?.serial_codes ?? [];
                        return (
                          <label key={serial} className="checkbox-row">
                            <input
                              type="checkbox"
                              checked={chosen.includes(serial)}
                              onChange={(event) =>
                                pickSerials(
                                  line.sale_line_id,
                                  event.target.checked
                                    ? [...chosen, serial]
                                    : chosen.filter((code) => code !== serial),
                                )
                              }
                            />
                            {serial}
                          </label>
                        );
                      })}
                    </fieldset>
                  ) : (
                    <>
                      <input
                        id={inputId}
                        inputMode="numeric"
                        value={raw[line.sale_line_id] ?? ''}
                        aria-describedby={`${inputId}-unit`}
                        disabled={busy || locked || line.returnable_quantity === 0}
                        aria-invalid={
                          picked
                            ? picked.quantity < 0 || picked.quantity > line.returnable_quantity
                            : undefined
                        }
                        onChange={(event) => change(line.sale_line_id, event.target.value)}
                      />{' '}
                      <small id={`${inputId}-unit`}>{line.base_unit}</small>
                      {lotChoiceRequired(line.trace) ? (
                        <label>
                          {t('returnLot')}
                          <select
                            aria-label={t('returnLotFor', { name: line.name })}
                            value={picked?.lot_code ?? ''}
                            disabled={blocked}
                            aria-invalid={Boolean(picked?.quantity && !picked.lot_code)}
                            onChange={(event) => pickLot(line.sale_line_id, event.target.value)}
                          >
                            <option value="">—</option>
                            {lots.map((lot) => (
                              <option key={lot.lot_code} value={lot.lot_code}>
                                {t('returnLotOption', {
                                  code: lot.lot_code,
                                  expiry: formatExpiry(lot.expiry_on),
                                  remaining: `${lot.remaining} ${line.base_unit}`,
                                })}
                                {expiryState(lot.expiry_on, today) === 'expired'
                                  ? ` · ${t('inventoryExpired')}`
                                  : expiryState(lot.expiry_on, today) === 'near'
                                    ? ` · ${t('inventoryNearExpiry')}`
                                    : ''}
                              </option>
                            ))}
                          </select>
                        </label>
                      ) : null}
                    </>
                  )}
                </td>
                <td>
                  <select
                    aria-label={t('returnConditionFor', { name: line.name })}
                    value={picked ? (picked.condition ?? '') : line.trace ? '' : 'resellable'}
                    disabled={busy || locked || line.returnable_quantity === 0}
                    aria-invalid={Boolean(picked && picked.quantity > 0 && !picked.condition)}
                    onChange={(event) =>
                      change(
                        line.sale_line_id,
                        raw[line.sale_line_id] ?? '',
                        event.target.value === 'damaged' || event.target.value === 'resellable'
                          ? event.target.value
                          : null,
                      )
                    }
                  >
                    {line.trace ? <option value="">{t('returnConditionChoose')}</option> : null}
                    <option value="resellable">{t('returnResellable')}</option>
                    <option value="damaged">{t('returnDamaged')}</option>
                  </select>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
      {preview ? <PreviewTable preview={preview} order={order} /> : null}
      {preview ? (
        <label>
          {t('returnReason')}
          <input
            value={reason}
            maxLength={200}
            required
            disabled={busy || locked}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
      ) : null}
      {problem && Object.keys(raw).length ? (
        <p className="muted" role="status">
          {t(problem)}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <div className="row">
        <button
          type="submit"
          className="checkout-submit"
          disabled={Boolean(problem) || busy || locked}
        >
          {busy ? t('waiting') : preview ? t('returnCreate') : t('returnPreview')}
        </button>
        {preview ? (
          <button type="button" disabled={busy} onClick={() => setPreview(null)}>
            {t('returnEdit')}
          </button>
        ) : null}
        <span className="muted">{money(order.totals.original_total)}</span>
      </div>
    </form>
  );
}

function PreviewTable({ preview, order }: { preview: ReturnPreview; order: PosOrderDetail }) {
  const { t } = useTranslation();
  const money = (value: string) => formatMoney(value, preview.currency);
  const names = Object.fromEntries(order.lines.map((line) => [line.sale_line_id, line.name]));
  const units = Object.fromEntries(order.lines.map((line) => [line.sale_line_id, line.base_unit]));
  return (
    <section className="return-preview" aria-label={t('returnPreviewTitle')} aria-live="polite">
      <h3>{t('returnPreviewTitle')}</h3>
      <table className="order-lines-table">
        <thead>
          <tr>
            <th scope="col">{t('orderLineItem')}</th>
            <th scope="col">{t('returnCumulative')}</th>
            <th scope="col">{t('returnLineValue')}</th>
            <th scope="col">{t('returnUsed')}</th>
            <th scope="col">{t('returnReserved')}</th>
            <th scope="col">{t('returnThisTime')}</th>
          </tr>
        </thead>
        <tbody>
          {preview.lines.map((line) => (
            <tr key={line.sale_line_id}>
              <th scope="row">
                {names[line.sale_line_id]}
                <PreviewTrace trace={line.trace} unit={units[line.sale_line_id] ?? ''} />
              </th>
              <td>
                {t('returnCumulativeValue', {
                  before: line.cumulative_before,
                  after: line.cumulative_after,
                  sold: line.sold_quantity,
                })}
              </td>
              <td>{money(line.original.total)}</td>
              <td>{money(line.used)}</td>
              <td>{money(line.reserved)}</td>
              <td>
                {money(line.this_time.total)}
                <small className="muted">
                  {' '}
                  {t('returnComponents', {
                    gross: money(line.this_time.gross),
                    discount: money(line.this_time.discount),
                    tax: money(line.this_time.tax),
                  })}
                </small>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <dl className="order-summary">
        <div>
          <dt>{t('returnEntitlement')}</dt>
          <dd>{money(preview.entitlement_total)}</dd>
        </div>
        <div>
          <dt>{t('returnCreditNote')}</dt>
          <dd>{money(preview.credit_note)}</dd>
        </div>
        <div>
          <dt>{t('returnRefund')}</dt>
          <dd>{money(preview.refund)}</dd>
        </div>
        {compareMoney(preview.unrefundable, '0') > 0 ? (
          <div>
            <dt>{t('returnUnrefundable')}</dt>
            <dd>{money(preview.unrefundable)}</dd>
          </div>
        ) : null}
      </dl>
      {preview.requires_approval ? (
        <p className="attention-box" role="note">
          {t('returnNeedsApproval', {
            reasons: [
              preview.cross_branch ? t('returnWhyCrossBranch') : null,
              preview.out_of_window ? t('returnWhyWindow') : null,
              preview.damaged ? t('returnWhyDamaged') : null,
            ]
              .filter(Boolean)
              .join(', '),
          })}
        </p>
      ) : null}
    </section>
  );
}

// Makes the replacement sale the active tab the next time the sale screen
// opens (the tabs restore the remembered view of this branch and register).
function activateWorkspace(
  scope: { staffId: string; storeId: string; branchId: string; registerId: string | null },
  workspaceId: string,
) {
  const current = readLayout(scope.staffId, scope.storeId);
  const sameContext =
    current?.branchId === scope.branchId && current.registerId === scope.registerId;
  writeLayout({
    staffId: scope.staffId,
    storeId: scope.storeId,
    savedAt: Date.now(),
    branchId: scope.branchId,
    registerId: scope.registerId,
    openWorkspaceIds: [
      workspaceId,
      ...(sameContext ? current.openWorkspaceIds.filter((id) => id !== workspaceId) : []),
    ],
    closedWorkspaceIds: sameContext
      ? (current.closedWorkspaceIds ?? []).filter((id) => id !== workspaceId)
      : [],
    activeWorkspaceId: workspaceId,
    workspacePage: 1,
    tabNumbers: sameContext ? current.tabNumbers : undefined,
  });
}

function ReturnProgress({
  returnId,
  branchId,
  registerId,
  locked,
}: {
  returnId: string;
  branchId: string;
  registerId: string | null;
  locked: boolean;
}) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { context } = usePosSelection();
  const staffId = context.data?.staff.id ?? null;
  const storeId = context.data?.store.id ?? null;
  const capabilities = context.data?.capabilities ?? [];
  const current = useReturn(returnId);
  const operation = current.data;
  const order = useOrder(
    operation ? { orderId: operation.order_id } : null,
    branchId,
    Boolean(operation),
  );
  const exchangeQuery = useExchange(operation?.exchange_id ?? null);
  const { receive, cancel, exchange } = useReturnCommands(staffId, storeId);
  const refunds = useRefundCommands(staffId, storeId);
  const pending = usePendingReturnCommands(staffId, storeId);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [cancelReason, setCancelReason] = useState('');
  const [evidenceFor, setEvidenceFor] = useState<PosRefundRequest | null>(null);
  const [evidenceError, setEvidenceError] = useState('');
  const [checking, setChecking] = useState(false);
  const pendingHere = operation
    ? [
        ...pending.pendingFor(operation.id),
        ...operation.refund_requests.flatMap((refund) => pending.pendingFor(refund.id)),
      ]
    : [];
  const recheckRef = useRef(pending.recheck);
  recheckRef.current = pending.recheck;
  const autoChecked = useRef(false);

  async function recheckAll(records = pendingHere) {
    if (!records.length) return;
    setChecking(true);
    setError('');
    try {
      for (const record of records) {
        const result = await recheckRef.current(record);
        if (result.committed) setNotice(t('pendingRecovered'));
      }
    } catch (failure) {
      setError(failureText(failure, t));
    } finally {
      setChecking(false);
    }
  }

  // Commands this browser never learned the outcome of, left from before the
  // screen opened (reload, another tab), are checked once on arrival. Later
  // ones are checked from the "Kiểm tra lại" button.
  const leftover = operation
    ? [
        ...pending.startedWith(operation.id),
        ...operation.refund_requests.flatMap((refund) => pending.startedWith(refund.id)),
      ]
    : [];
  useEffect(() => {
    if (autoChecked.current || !leftover.length) return;
    autoChecked.current = true;
    void recheckAll(leftover);
  });

  if (current.isLoading) return <PageState kind="loading" title={t('waiting')} />;
  if (current.isError || !operation)
    return <PageState kind="error" title={t(posFailureKey(current.error))} />;
  const money = (value: string) => formatMoney(value, operation.currency);
  const approvalActive = operation.approval?.status === 'active';
  const canReceive =
    canProcessReturns(capabilities) &&
    (operation.status === 'ready' || (operation.status === 'pending_approval' && approvalActive));
  const busy =
    receive.isPending ||
    cancel.isPending ||
    exchange.isPending ||
    refunds.request.isPending ||
    refunds.resolve.isPending ||
    checking;
  const recordedOrChecking = (result: { recovered: boolean }) =>
    setNotice(result.recovered ? t('pendingRecovered') : '');
  const fail = (failure: unknown) => setError(failureText(failure, t));
  const posted = operation.entitlement_status === 'posted';
  const refundsOn = contextFeature(context.data, 'refunds');

  return (
    <section className="page-card" aria-label={t('returnProgress')}>
      <h2>
        {t('returnNumber', { number: operation.return_number })} · {operation.order_number}
      </h2>
      <p
        className="status-tag"
        data-warning={operation.status === 'pending_approval'}
        role="status"
      >
        {t(`returnStatus_${operation.status}`)}
        {operation.status === 'received'
          ? ` · ${t(`entitlementStatus_${operation.entitlement_status}`)}`
          : ''}
      </p>
      {operation.status === 'received' ? (
        <ReceiptPrintButton sourceId={operation.id} label={t('receiptOpenReturn')} />
      ) : null}
      {operation.status === 'pending_approval' && !approvalActive ? (
        <p className="attention-box" role="note">
          {t('returnWaitApproval')}
        </p>
      ) : null}
      {pendingHere.length ? (
        <p className="attention-box" role="status">
          {t('pendingChecking')}{' '}
          <button type="button" disabled={checking} onClick={() => void recheckAll()}>
            {t('pendingRecheck')}
          </button>
        </p>
      ) : null}
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      <dl className="order-summary">
        <div>
          <dt>{t('returnEntitlement')}</dt>
          <dd>{money(operation.entitlement_total)}</dd>
        </div>
        <div>
          <dt>{t('returnCreditNote')}</dt>
          <dd>{money(posted ? operation.credit_note_amount : operation.expected_credit_note)}</dd>
        </div>
        <div>
          <dt>{t('returnRefund')}</dt>
          <dd>{money(posted ? operation.refund_entitlement : operation.expected_refund)}</dd>
        </div>
        <div>
          <dt>{t('returnRefunded')}</dt>
          <dd>{money(operation.refunded)}</dd>
        </div>
      </dl>
      <ul className="record-list" aria-label={t('returnLines')}>
        {operation.lines.map((line) => (
          <li key={line.id}>
            <span>
              {line.name} · {line.quantity} ·{' '}
              {t(line.condition === 'damaged' ? 'returnDamaged' : 'returnResellable')}
            </span>
            <span>{money(line.total)}</span>
            {operation.status === 'received' ? (
              <small>{t('returnRestocked', { count: line.restocked_quantity })}</small>
            ) : null}
            <ReturnTrace rows={line.trace} />
          </li>
        ))}
      </ul>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {canReceive ? (
        <div className="row">
          <button
            type="button"
            className="checkout-submit"
            disabled={busy || locked}
            onClick={() => {
              setError('');
              receive.mutate(operation, { onError: fail });
            }}
          >
            {t('returnReceive')}
          </button>
        </div>
      ) : null}
      {canCancelReturn(operation, staffId, capabilities) ? (
        <form
          className="row"
          onSubmit={(event) => {
            event.preventDefault();
            if (!cancelReason.trim()) return;
            setError('');
            cancel.mutate(
              { returnId: operation.id, reason: cancelReason.trim() },
              { onError: fail },
            );
          }}
        >
          <label>
            {t('returnCancelReason')}
            <input
              value={cancelReason}
              maxLength={200}
              onChange={(event) => setCancelReason(event.target.value)}
            />
          </label>
          <button
            type="submit"
            className="danger-button"
            disabled={busy || locked || !cancelReason.trim()}
          >
            {t('returnCancel')}
          </button>
        </form>
      ) : null}
      <section className="refund-section" aria-label={t('refundTitle')}>
        <h3>{t('refundTitle')}</h3>
        {posted && canProcessReturns(capabilities) && !refundsOn ? (
          <FeatureOffNote feature="refunds" />
        ) : null}
        {posted && canProcessReturns(capabilities) && refundsOn ? (
          <RefundForm
            key={`${operation.refundable_remaining}:${order.data?.receipts.map((row) => row.refundable).join(',')}`}
            operation={operation}
            order={order.data ?? null}
            disabled={busy || locked || pendingHere.length > 0}
            onRequest={(input) => {
              setError('');
              refunds.request.mutate(
                { returnId: operation.id, ...input },
                { onSuccess: recordedOrChecking, onError: fail },
              );
            }}
          />
        ) : null}
        <ul className="record-list" aria-label={t('refundList')}>
          {operation.refund_requests.map((refund) => (
            <RefundActions
              key={refund.id}
              refund={refund}
              staffId={staffId}
              capabilities={capabilities}
              disabled={busy || locked}
              checking={pending.pendingFor(refund.id).length > 0}
              onRecheck={() => void recheckAll(pending.pendingFor(refund.id))}
              onPayout={() => {
                setEvidenceError('');
                setEvidenceFor(refund);
              }}
              onCancel={(reason) =>
                refunds.resolve.mutate(
                  { refund, outcome: 'cancel', reason },
                  { onSuccess: recordedOrChecking, onError: fail },
                )
              }
              onFail={(reference) =>
                refunds.resolve.mutate(
                  { refund, outcome: 'failed_no_effect', reference },
                  { onSuccess: recordedOrChecking, onError: fail },
                )
              }
            />
          ))}
        </ul>
      </section>
      {operation.exchange_id ? (
        exchangeQuery.data ? (
          <ExchangeSummary
            operation={operation}
            exchange={exchangeQuery.data}
            onOpen={() => {
              if (staffId && storeId && exchangeQuery.data) {
                activateWorkspace(
                  { staffId, storeId, branchId, registerId },
                  exchangeQuery.data.replacement_workspace_id,
                );
              }
              void navigate({ to: '/' });
            }}
          />
        ) : null
      ) : operation.status !== 'canceled' &&
        canProcessReturns(capabilities) &&
        !contextFeature(context.data, 'exchanges') ? (
        <FeatureOffNote feature="exchanges" />
      ) : operation.status !== 'canceled' && canProcessReturns(capabilities) ? (
        <div className="row">
          <button
            type="button"
            disabled={busy || locked || pendingHere.length > 0}
            onClick={() => {
              setError('');
              exchange.mutate(
                { returnId: operation.id, registerId, branchId },
                { onSuccess: recordedOrChecking, onError: fail },
              );
            }}
          >
            {t('exchangeStart')}
          </button>
          <small className="muted">{t('exchangeHint')}</small>
        </div>
      ) : null}
      {evidenceFor ? (
        <RefundEvidenceDialog
          refund={evidenceFor}
          busy={refunds.confirm.isPending || refunds.resolve.isPending}
          error={evidenceError}
          onClose={() => setEvidenceFor(null)}
          onConfirm={(reference) =>
            refunds.confirm
              .mutateAsync({ refund: evidenceFor, reference })
              .then((result) => {
                recordedOrChecking(result);
                setEvidenceFor(null);
              })
              .catch((failure) => setEvidenceError(failureText(failure, t)))
          }
          onUnknown={() =>
            refunds.resolve
              .mutateAsync({ refund: evidenceFor, outcome: 'unknown' })
              .then(() => setEvidenceFor(null))
              .catch((failure) => setEvidenceError(failureText(failure, t)))
          }
        />
      ) : null}
    </section>
  );
}

// Thousands grouped with dots, the way cashiers type VND.
function groupVnd(value: string): string {
  const whole = parseVndAmount(value) ?? value.split('.')[0];
  return whole.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function RefundForm({
  operation,
  order,
  disabled,
  onRequest,
}: {
  operation: PosReturn;
  order: PosOrderDetail | null;
  disabled: boolean;
  onRequest: (input: {
    allocationId: string;
    amount: string;
    method: 'cash' | 'bank_manual';
    beneficiaryReference?: string;
  }) => void;
}) {
  const { t } = useTranslation();
  const money = (value: string) => formatMoney(value, operation.currency);
  const receipts = (order?.receipts ?? []).filter(
    (receipt) => receipt.status === 'active' && compareMoney(receipt.refundable, '0') > 0,
  );
  const [allocationId, setAllocationId] = useState(receipts[0]?.allocation_id ?? '');
  const receipt = receipts.find((row) => row.allocation_id === allocationId) ?? receipts[0];
  const suggested = receipt ? defaultRefundAmount(operation, receipt) : '0';
  const [method, setMethod] = useState<'cash' | 'bank_manual'>('cash');
  // Prefilled with the most it may be; an emptied field is an error, never
  // a silent "full amount".
  const [amountInput, setAmountInput] = useState(
    compareMoney(suggested, '0') > 0 ? groupVnd(suggested) : '',
  );
  const [beneficiary, setBeneficiary] = useState('');
  const amount = parseVndInput(amountInput);
  const tooMuch = amount !== null && compareMoney(amount, suggested) > 0;
  const amountError =
    amountInput.trim() === ''
      ? 'refundAmountRequired'
      : amount === null || amount === '0'
        ? 'invalid'
        : null;
  const canRequest =
    receipt &&
    amount !== null &&
    amount !== '0' &&
    !tooMuch &&
    (method === 'cash' || beneficiary.trim() !== '');

  if (compareMoney(operation.refundable_remaining, '0') <= 0)
    return <p className="muted">{t('refundNothingLeft')}</p>;
  if (!order) return <PageState kind="loading" title={t('waiting')} />;
  if (!receipts.length) return <p className="muted">{t('refundNoReceipt')}</p>;

  return (
    <form
      className="refund-form"
      onSubmit={(event) => {
        event.preventDefault();
        if (!canRequest || !receipt || amount === null || disabled) return;
        onRequest({
          allocationId: receipt.allocation_id,
          amount,
          method,
          beneficiaryReference: method === 'bank_manual' ? beneficiary.trim() : undefined,
        });
      }}
    >
      <label>
        {t('refundFromReceipt')}
        <select
          value={receipt?.allocation_id ?? ''}
          onChange={(event) => setAllocationId(event.target.value)}
        >
          {receipts.map((row) => (
            <option key={row.allocation_id} value={row.allocation_id}>
              {t(row.kind === 'cash' ? 'orderReceiptCash' : 'orderReceiptBank')} ·{' '}
              {money(row.amount)} · {t('refundReceiptLeft', { amount: money(row.refundable) })}
            </option>
          ))}
        </select>
      </label>
      <fieldset className="row">
        <legend>{t('refundMethod')}</legend>
        <label>
          <input
            type="radio"
            name="refund-method"
            checked={method === 'cash'}
            onChange={() => setMethod('cash')}
          />
          {t('refundCash')}
        </label>
        <label>
          <input
            type="radio"
            name="refund-method"
            checked={method === 'bank_manual'}
            onChange={() => setMethod('bank_manual')}
          />
          {t('refundBank')}
        </label>
      </fieldset>
      <label>
        {t('refundAmount')}
        <input
          inputMode="numeric"
          value={amountInput}
          placeholder={groupVnd(suggested)}
          aria-invalid={Boolean(amountError) || tooMuch}
          onChange={(event) => setAmountInput(event.target.value)}
        />
      </label>
      {method === 'bank_manual' ? (
        <label>
          {t('refundBeneficiary')}
          <input
            value={beneficiary}
            maxLength={120}
            required
            onChange={(event) => setBeneficiary(event.target.value)}
          />
        </label>
      ) : null}
      {tooMuch ? (
        <p className="error" role="alert">
          {t('refundTooMuch', { amount: money(suggested) })}
        </p>
      ) : amountError ? (
        <p className="muted" role="status">
          {t(amountError)}
        </p>
      ) : null}
      <button type="submit" disabled={!canRequest || disabled}>
        {t('refundRequest')}
      </button>
    </form>
  );
}

function ExchangeSummary({
  operation,
  exchange,
  onOpen,
}: {
  operation: PosReturn;
  exchange: PosExchange;
  onOpen: () => void;
}) {
  const { t } = useTranslation();
  const money = (value: string) => formatMoney(value, exchange.currency);
  return (
    <div className="attention-box" role="status" aria-label={t('exchangeTitle')}>
      <p>{t('exchangeCreated', { number: exchange.replacement_order_number })}</p>
      {exchange.customer_pays === null || exchange.store_refunds === null ? (
        <p>{t('exchangeNoTotalYet', { owed: money(exchange.refund_owed) })}</p>
      ) : (
        <p>
          {compareMoney(exchange.customer_pays, '0') > 0
            ? t('exchangeCustomerPays', { amount: money(exchange.customer_pays) })
            : t('exchangeStoreRefunds', { amount: money(exchange.store_refunds) })}
        </p>
      )}
      {compareMoney(exchange.refunded, '0') > 0 ? (
        <p className="muted">
          {t('exchangeRefundedAlready', { amount: money(exchange.refunded) })}
        </p>
      ) : null}
      {operation.entitlement_status !== 'posted' ? (
        <p className="muted">{t('exchangeEstimated')}</p>
      ) : null}
      <button type="button" onClick={onOpen}>
        {t('exchangeOpenSale')}
      </button>
    </div>
  );
}

function PreviewTrace({
  trace,
  unit,
}: {
  trace: ReturnPreviewTrace | null | undefined;
  unit: string;
}) {
  const { t } = useTranslation();
  if (!trace) return null;
  const parts =
    trace.mode === 'serial'
      ? trace.serials
      : trace.lots.map(
          (lot) => `${lotLabel(t, lot.lot_code, lot.expiry_on)} × ${lot.quantity} ${unit}`,
        );
  const forced = trace.mode === 'lot' ? trace.lots.filter((lot) => lot.forced_quarantine) : [];
  return parts.length ? (
    <>
      <small className="return-trace">
        {t('returnTraceBack')}: {parts.join(' · ')}
      </small>
      {forced.map((lot) => (
        <small key={lot.lot_code} className="return-trace" data-warning="true" role="status">
          {t('returnForcedQuarantine', { code: lot.lot_code, expiry: formatExpiry(lot.expiry_on) })}
        </small>
      ))}
    </>
  ) : null;
}

function ReturnTrace({ rows }: { rows: ReturnLineTraceRow[] | undefined }) {
  const { t } = useTranslation();
  if (!rows?.length) return null;
  return (
    <small className="return-trace">
      {rows
        .map((row) => {
          const label =
            row.serial ?? `${lotLabel(t, row.lot_code, row.expiry_on)} × ${row.quantity}`;
          return `${label} · ${t(row.condition === 'damaged' ? 'returnDamaged' : 'returnResellable')}`;
        })
        .join('; ')}
    </small>
  );
}
