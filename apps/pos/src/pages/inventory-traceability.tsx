import { type KeyboardEvent, type ReactNode, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import {
  FORM_LIST_LIMIT,
  type InventoryCommandInput,
  type RecallQuery,
  useAdjustments,
  useInventoryCommand,
  useInventoryVariants,
  useLots,
  useRecall,
  useSerialUnits,
} from '../hooks/use-inventory';
import { useModalFocus } from '../lib/dialog-focus';
import { posFailureKey } from '../lib/request-failure';
import { formatInZone, todayIn } from '../lib/shifts';
import {
  adjustmentActions,
  canManageInventory,
  canOpenInventory,
  canTraceInventory,
  describeInventoryFailure,
  expiryState,
  formatExpiry,
  type InventoryTab,
  inventoryTabs,
  type LotRowDraft,
  type PosAdjustment,
  type PosLot,
  type PosSerialUnit,
  type PosTraceStatus,
  type PosTransferResult,
  parseSerials,
  parseWholeQuantity,
  serialListAfterTab,
  stockEntryPayload,
  type TrackedMode,
} from '../lib/traceability';

const EMPTY_LOT_ROW: LotRowDraft = { lot_code: '', expiry_on: '', quantity: '' };

export function InventoryTraceabilityPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Inventory key={scope} />;
}

type Scope = {
  branchId: string;
  staffId: string | null;
  storeId: string | null;
  capabilities: string[];
  manage: boolean;
  // Manage or trace: may read variants, lots and serials.
  reader: boolean;
  today: string;
  timeZone: string;
};

function Inventory() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const capabilities = data?.capabilities ?? [];
  const manage = canManageInventory(capabilities);
  const branch = data?.branches.find((row) => row.id === selection.branchId);
  const timeZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const tabs = inventoryTabs(capabilities);
  const [chosen, setChosen] = useState<InventoryTab | null>(null);
  const tab = chosen && tabs.includes(chosen) ? chosen : (tabs[0] ?? 'adjust');

  function onTabKey(event: KeyboardEvent<HTMLButtonElement>, index: number) {
    const last = tabs.length - 1;
    const target =
      event.key === 'ArrowRight'
        ? (index + 1) % tabs.length
        : event.key === 'ArrowLeft'
          ? (index + last) % tabs.length
          : event.key === 'Home'
            ? 0
            : event.key === 'End'
              ? last
              : null;
    if (target === null) return;
    event.preventDefault();
    setChosen(tabs[target]);
    document.getElementById(`inventory-tab-${tabs[target]}`)?.focus();
  }

  const scope: Scope | null = selection.branchId
    ? {
        branchId: selection.branchId,
        staffId: data?.staff.id ?? null,
        storeId: data?.store.id ?? null,
        capabilities,
        manage,
        reader: manage || canTraceInventory(capabilities),
        today: todayIn(timeZone),
        timeZone,
      }
    : null;

  return (
    <PosPage title={t('inventoryTitle')} description={t('inventoryHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !scope ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !canOpenInventory(capabilities) ? (
        <PageState title={t('forbidden')}>
          <p>{t('inventoryForbidden')}</p>
        </PageState>
      ) : (
        <>
          <div className="report-tabs" role="tablist" aria-label={t('inventoryTitle')}>
            {tabs.map((value, index) => (
              <button
                key={value}
                id={`inventory-tab-${value}`}
                type="button"
                role="tab"
                aria-selected={tab === value}
                aria-controls="inventory-panel"
                tabIndex={tab === value ? 0 : -1}
                onClick={() => setChosen(value)}
                onKeyDown={(event) => onTabKey(event, index)}
              >
                {t(`inventoryTab_${value}`)}
              </button>
            ))}
          </div>
          <section
            id="inventory-panel"
            className="page-card inventory-panel"
            role="tabpanel"
            aria-labelledby={`inventory-tab-${tab}`}
          >
            {tab === 'variants' ? <VariantsPanel scope={scope} /> : null}
            {tab === 'lots' ? <LotsPanel scope={scope} /> : null}
            {tab === 'serials' ? <SerialsPanel scope={scope} /> : null}
            {tab === 'receive' ? <ReceivePanel scope={scope} /> : null}
            {tab === 'transfer' ? <TransferPanel scope={scope} /> : null}
            {tab === 'adjust' ? <AdjustPanel scope={scope} /> : null}
            {tab === 'recall' ? <RecallPanel scope={scope} /> : null}
          </section>
        </>
      )}
    </PosPage>
  );
}

function QueryState({
  query,
  empty,
}: {
  query: { isPending: boolean; isError: boolean; error: unknown; refetch: () => unknown };
  empty: boolean;
}) {
  const { t } = useTranslation();
  if (query.isPending) return <PageState kind="loading" title={t('waiting')} />;
  if (query.isError)
    return (
      <PageState kind="error" title={t(posFailureKey(query.error))}>
        <button type="button" onClick={() => void query.refetch()}>
          {t('retry')}
        </button>
      </PageState>
    );
  return empty ? <PageState title={t('inventoryEmpty')} /> : null;
}

function Pager({
  page,
  pages,
  onPage,
}: {
  page: number;
  pages: number;
  onPage: (page: number) => void;
}) {
  const { t } = useTranslation();
  if (pages <= 1) return null;
  return (
    <div className="row">
      <button type="button" disabled={page <= 1} onClick={() => onPage(page - 1)}>
        {t('previousPage')}
      </button>
      <span>
        {page} / {pages}
      </span>
      <button type="button" disabled={page >= pages} onClick={() => onPage(page + 1)}>
        {t('nextPage')}
      </button>
    </div>
  );
}

// A stock command whose response never arrived: the form stays on the same
// content until the receipt check settles whether it committed.
function CommandCheck({
  command,
}: {
  command: { uncertain: boolean; isPending: boolean; recheck: () => void };
}) {
  const { t } = useTranslation();
  if (!command.uncertain) return null;
  return (
    <div className="status-tag" data-warning="true" role="status">
      {t('inventoryCommandChecking')}{' '}
      <button type="button" disabled={command.isPending} onClick={command.recheck}>
        {t('inventoryCommandRecheck')}
      </button>
    </div>
  );
}

function quantity(value: number | null | undefined, unit: string | undefined) {
  if (value === null || value === undefined) return '—';
  return unit ? `${value} ${unit}` : String(value);
}

function variantLabel(variant: Pick<PosTraceStatus, 'name' | 'sku'>) {
  return variant.sku ? `${variant.name} · ${variant.sku}` : variant.name;
}

function Expiry({ value, today }: { value: string | null; today: string }) {
  const { t } = useTranslation();
  const state = expiryState(value, today);
  return (
    <span>
      {formatExpiry(value)}
      {state === 'expired' ? (
        <>
          {' '}
          <span className="status-tag" data-danger="true">
            {t('inventoryExpired')}
          </span>
        </>
      ) : state === 'near' ? (
        <>
          {' '}
          <span className="status-tag" data-warning="true">
            {t('inventoryNearExpiry')}
          </span>
        </>
      ) : null}
    </span>
  );
}

// Serial codes one per line; a Tab-terminated scan becomes a line break.
function SerialTextarea({
  label,
  value,
  onChange,
  disabled,
  rows = 4,
  hint,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  disabled: boolean;
  rows?: number;
  hint?: ReactNode;
}) {
  const hintId = useId();
  return (
    <label>
      {label}
      <textarea
        rows={rows}
        value={value}
        disabled={disabled}
        aria-describedby={hint ? hintId : undefined}
        onKeyDown={(event) => {
          if (event.key !== 'Tab') return;
          const next = serialListAfterTab(event.currentTarget.value, event.shiftKey);
          if (next === null) return;
          event.preventDefault();
          onChange(next);
        }}
        onChange={(event) => onChange(event.target.value)}
      />
      {hint ? <small id={hintId}>{hint}</small> : null}
    </label>
  );
}

function VariantsPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const variants = useInventoryVariants(scope.branchId, true);
  const rows = variants.data?.data ?? [];
  const [opening, setOpening] = useState<PosTraceStatus | null>(null);
  const [notice, setNotice] = useState('');
  return (
    <>
      <h2>{t('inventoryTab_variants')}</h2>
      <p className="muted">{t('inventoryVariantsHint')}</p>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      <QueryState query={variants} empty={variants.isSuccess && rows.length === 0} />
      {rows.length ? (
        <table className="order-lines-table" aria-label={t('inventoryTab_variants')}>
          <thead>
            <tr>
              <th scope="col">{t('orderLineItem')}</th>
              <th scope="col">{t('inventoryTrackedMode')}</th>
              <th scope="col">{t('inventoryEnrollment')}</th>
              <th scope="col">{t('inventoryCoreOnHand')}</th>
              <th scope="col">{t('inventoryTypedOnHand')}</th>
              <th scope="col">{t('inventoryBlocked')}</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.variant_id}>
                <th scope="row">{variantLabel(row)}</th>
                <td>{t(`variantUnitTracked_${row.tracked_mode}`)}</td>
                <td>
                  {row.enrolled ? t('inventoryEnrolled') : t('inventoryNotEnrolled')}
                  {' · '}
                  {row.reconciled ? t('inventoryReconciled') : t('inventoryUnreconciled')}
                </td>
                <td>{quantity(row.core_on_hand, row.base_unit)}</td>
                <td>{quantity(row.typed_on_hand, row.base_unit)}</td>
                <td>
                  {row.blocked_reason ? (
                    <span className="status-tag" data-warning="true">
                      {t(`inventoryBlocked_${row.blocked_reason}`)}
                    </span>
                  ) : (
                    t('inventorySellable')
                  )}
                  {scope.manage && !row.enrolled && row.tracked_mode !== 'none' ? (
                    <>
                      {' '}
                      <button
                        type="button"
                        aria-label={t('inventoryOpeningFor', { name: row.name })}
                        onClick={() => {
                          setNotice('');
                          setOpening(row);
                        }}
                      >
                        {t('inventoryOpening')}
                      </button>
                    </>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : null}
      {opening ? (
        <OpeningForm
          key={opening.variant_id}
          scope={scope}
          variant={opening}
          onClose={() => setOpening(null)}
          onDone={(name) => {
            setOpening(null);
            setNotice(t('inventoryOpeningDone', { name }));
          }}
        />
      ) : null}
    </>
  );
}

function StockEntryFields({
  mode,
  baseUnit,
  serialText,
  onSerialText,
  lotRows,
  onLotRows,
  disabled,
}: {
  mode: TrackedMode;
  baseUnit: string;
  serialText: string;
  onSerialText: (value: string) => void;
  lotRows: LotRowDraft[];
  onLotRows: (rows: LotRowDraft[]) => void;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  if (mode === 'serial') {
    const count = parseSerials(serialText).codes.length;
    return (
      <SerialTextarea
        label={t('inventorySerialList')}
        value={serialText}
        onChange={onSerialText}
        disabled={disabled}
        rows={5}
        hint={t('inventorySerialListHint', { count })}
      />
    );
  }
  const set = (index: number, key: keyof LotRowDraft, value: string) =>
    onLotRows(lotRows.map((row, at) => (at === index ? { ...row, [key]: value } : row)));
  return (
    <fieldset className="inventory-lot-rows">
      <legend>{t('inventoryLotRows', { unit: baseUnit })}</legend>
      {lotRows.map((row, index) => (
        // Rows have no identity beyond their position while being typed.
        // biome-ignore lint/suspicious/noArrayIndexKey: positional draft rows
        <div className="row" key={index}>
          <label>
            {t('inventoryLotCode')}
            <input
              value={row.lot_code}
              maxLength={64}
              disabled={disabled}
              aria-label={t('inventoryLotCodeRow', { row: index + 1 })}
              onChange={(event) => set(index, 'lot_code', event.target.value)}
            />
          </label>
          <label>
            {t('inventoryExpiry')}
            <input
              type="date"
              value={row.expiry_on}
              disabled={disabled}
              aria-label={t('inventoryExpiryRow', { row: index + 1 })}
              onChange={(event) => set(index, 'expiry_on', event.target.value)}
            />
          </label>
          <label>
            {t('inventoryQuantity', { unit: baseUnit })}
            <input
              inputMode="numeric"
              value={row.quantity}
              disabled={disabled}
              aria-label={t('inventoryQuantityRow', { row: index + 1 })}
              onChange={(event) => set(index, 'quantity', event.target.value)}
            />
          </label>
          {lotRows.length > 1 ? (
            <button
              type="button"
              disabled={disabled}
              aria-label={t('inventoryLotRemove', { row: index + 1 })}
              onClick={() => onLotRows(lotRows.filter((_, at) => at !== index))}
            >
              {t('removeItem')}
            </button>
          ) : null}
        </div>
      ))}
      <button
        type="button"
        disabled={disabled || lotRows.length >= 50}
        onClick={() => onLotRows([...lotRows, EMPTY_LOT_ROW])}
      >
        {t('inventoryLotAdd')}
      </button>
    </fieldset>
  );
}

function useStockEntry() {
  const [serialText, setSerialText] = useState('');
  const [lotRows, setLotRows] = useState<LotRowDraft[]>([EMPTY_LOT_ROW]);
  return {
    serialText,
    setSerialText,
    lotRows,
    setLotRows,
    reset() {
      setSerialText('');
      setLotRows([EMPTY_LOT_ROW]);
    },
  };
}

function entryError(
  entry: { error: string | null; codes: string[] },
  t: (key: string, options?: Record<string, unknown>) => string,
) {
  return entry.error ? t(entry.error, { codes: entry.codes.join(', ') }) : '';
}

function actorOf(scope: Scope) {
  return { staffId: scope.staffId, storeId: scope.storeId };
}

function OpeningForm({
  scope,
  variant,
  onClose,
  onDone,
}: {
  scope: Scope;
  variant: PosTraceStatus;
  onClose: () => void;
  onDone: (name: string) => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const entry = useStockEntry();
  const command = useInventoryCommand<PosTraceStatus>(actorOf(scope));
  const [error, setError] = useState('');
  const busy = command.isPending;
  const locked = busy || command.uncertain;
  useModalFocus(card, () => {
    if (!busy) onClose();
  });
  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card inventory-dialog"
        onSubmit={(event) => {
          event.preventDefault();
          if (locked) return;
          const payload = stockEntryPayload(variant.tracked_mode, entry.serialText, entry.lotRows);
          if (!payload.body) {
            setError(entryError(payload, t));
            return;
          }
          setError('');
          command.run(
            {
              branchId: scope.branchId,
              action: 'opening',
              path: '/pos/inventory/opening_balances',
              body: { branch_id: scope.branchId, variant_id: variant.variant_id, ...payload.body },
            },
            {
              onSuccess: () => onDone(variant.name),
              onError: (failure) => setError(describeInventoryFailure(failure, t)),
            },
          );
        }}
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('inventoryOpeningTitle', { name: variant.name })}</h4>
        </div>
        <p className="muted">
          {t('inventoryOpeningHint', {
            core: quantity(variant.core_on_hand, variant.base_unit),
          })}
        </p>
        <StockEntryFields
          mode={variant.tracked_mode}
          baseUnit={variant.base_unit}
          serialText={entry.serialText}
          onSerialText={entry.setSerialText}
          lotRows={entry.lotRows}
          onLotRows={entry.setLotRows}
          disabled={locked}
        />
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <CommandCheck command={command} />
        <div className="row">
          <button type="button" disabled={busy} onClick={onClose}>
            {t('paymentCancelNo')}
          </button>
          <button type="submit" className="checkout-submit" disabled={locked}>
            {busy ? t('waiting') : t('inventoryOpeningSubmit')}
          </button>
        </div>
      </form>
    </div>
  );
}

// Asks for the reason of a quarantine, release or cancellation.
function ReasonDialog({
  title,
  submitLabel,
  command,
  error,
  onSubmit,
  onClose,
}: {
  title: string;
  submitLabel: string;
  command: { uncertain: boolean; isPending: boolean; recheck: () => void };
  error: string;
  onSubmit: (reason: string) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLFormElement>(null);
  const [reason, setReason] = useState('');
  const [missing, setMissing] = useState(false);
  const busy = command.isPending;
  const locked = busy || command.uncertain;
  useModalFocus(card, () => {
    if (!busy) onClose();
  });
  return (
    <div className="pos-popup-backdrop">
      <form
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-busy={busy}
        tabIndex={-1}
        className="pos-popup-card"
        onSubmit={(event) => {
          event.preventDefault();
          if (locked) return;
          if (!reason.trim()) {
            setMissing(true);
            return;
          }
          setMissing(false);
          onSubmit(reason.trim());
        }}
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{title}</h4>
        </div>
        <label>
          {t('inventoryReason')}
          <input
            value={reason}
            maxLength={200}
            required
            disabled={locked}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
        {missing ? (
          <p className="error" role="alert">
            {t('inventoryReasonRequired')}
          </p>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <CommandCheck command={command} />
        <div className="row">
          <button type="button" disabled={busy} onClick={onClose}>
            {t('paymentCancelNo')}
          </button>
          <button type="submit" className="checkout-submit" disabled={locked}>
            {busy ? t('waiting') : submitLabel}
          </button>
        </div>
      </form>
    </div>
  );
}

type HoldTarget = {
  kind: 'lots' | 'serial_units';
  id: string;
  label: string;
  release: boolean;
};

// Quarantine or release of one lot or serial unit, with its reason.
function HoldDialog({
  scope,
  target,
  onClose,
  onDone,
}: {
  scope: Scope;
  target: HoldTarget;
  onClose: () => void;
  onDone: (message: string) => void;
}) {
  const { t } = useTranslation();
  const command = useInventoryCommand<PosLot | PosSerialUnit>(actorOf(scope));
  const [error, setError] = useState('');
  const action = target.release ? 'release' : 'quarantine';
  return (
    <ReasonDialog
      title={t(target.release ? 'inventoryReleaseTitle' : 'inventoryQuarantineTitle', {
        label: target.label,
      })}
      submitLabel={t(target.release ? 'inventoryRelease' : 'inventoryQuarantine')}
      command={command}
      error={error}
      onClose={onClose}
      onSubmit={(reason) => {
        setError('');
        command.run(
          {
            branchId: scope.branchId,
            action,
            path: `/pos/${target.kind}/${target.id}/${action}`,
            body: { reason },
          },
          {
            onSuccess: () =>
              onDone(
                t(target.release ? 'inventoryReleased' : 'inventoryQuarantined', {
                  label: target.label,
                }),
              ),
            onError: (failure) => setError(describeInventoryFailure(failure, t)),
          },
        );
      }}
    />
  );
}

function LotsPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [filters, setFilters] = useState({ q: '', status: '', page: 1 });
  const lots = useLots(scope.branchId, filters, true);
  const rows = lots.data?.data ?? [];
  const [hold, setHold] = useState<HoldTarget | null>(null);
  const [notice, setNotice] = useState('');
  return (
    <>
      <h2>{t('inventoryTab_lots')}</h2>
      <form
        className="row"
        onSubmit={(event) => {
          event.preventDefault();
          setFilters({ q, status, page: 1 });
        }}
      >
        <label>
          {t('inventoryLotCode')}
          <input value={q} maxLength={64} onChange={(event) => setQ(event.target.value)} />
        </label>
        <label>
          {t('inventoryStatus')}
          <select value={status} onChange={(event) => setStatus(event.target.value)}>
            <option value="">{t('inventoryStatusAll')}</option>
            <option value="active">{t('inventoryLotStatus_active')}</option>
            <option value="quarantined">{t('inventoryLotStatus_quarantined')}</option>
            <option value="expired">{t('inventoryLotStatus_expired')}</option>
          </select>
        </label>
        <button type="submit">{t('inventorySearch')}</button>
      </form>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      <QueryState query={lots} empty={lots.isSuccess && rows.length === 0} />
      {rows.length ? (
        <table className="order-lines-table" aria-label={t('inventoryLotList')}>
          <thead>
            <tr>
              <th scope="col">{t('inventoryLotCode')}</th>
              <th scope="col">{t('orderLineItem')}</th>
              <th scope="col">{t('inventoryExpiry')}</th>
              <th scope="col">{t('inventoryOnHand')}</th>
              <th scope="col">{t('inventoryReserved')}</th>
              <th scope="col">{t('inventoryCommitted')}</th>
              <th scope="col">{t('inventoryAvailable')}</th>
              <th scope="col">{t('inventoryStatus')}</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((lot) => (
              <tr key={lot.id}>
                <th scope="row">{lot.lot_code}</th>
                <td>{variantLabel(lot)}</td>
                <td>
                  <Expiry value={lot.expiry_on} today={scope.today} />
                </td>
                <td>
                  {quantity(lot.on_hand, lot.base_unit)}
                  {lot.quarantined_quantity > 0 ? (
                    <small className="muted">
                      {' '}
                      ·{' '}
                      {t('inventoryQuarantinedQuantity', {
                        quantity: quantity(lot.quarantined_quantity, lot.base_unit),
                      })}
                    </small>
                  ) : null}
                </td>
                <td>{quantity(lot.reserved, lot.base_unit)}</td>
                <td>{quantity(lot.committed, lot.base_unit)}</td>
                <td>{quantity(lot.available, lot.base_unit)}</td>
                <td>
                  {t(`inventoryLotStatus_${lot.status}`)}
                  {lot.quarantine_reason ? (
                    <small className="muted"> · {lot.quarantine_reason}</small>
                  ) : null}
                  {scope.manage && lot.status !== 'expired' ? (
                    <>
                      {' '}
                      <button
                        type="button"
                        aria-label={t(
                          lot.status === 'quarantined'
                            ? 'inventoryReleaseTitle'
                            : 'inventoryQuarantineTitle',
                          { label: lot.lot_code },
                        )}
                        onClick={() => {
                          setNotice('');
                          setHold({
                            kind: 'lots',
                            id: lot.id,
                            label: lot.lot_code,
                            release: lot.status === 'quarantined',
                          });
                        }}
                      >
                        {t(
                          lot.status === 'quarantined' ? 'inventoryRelease' : 'inventoryQuarantine',
                        )}
                      </button>
                    </>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : null}
      <Pager
        page={filters.page}
        pages={lots.data?.meta.pages ?? 1}
        onPage={(page) => setFilters({ ...filters, page })}
      />
      {hold ? (
        <HoldDialog
          scope={scope}
          target={hold}
          onClose={() => setHold(null)}
          onDone={(message) => {
            setHold(null);
            setNotice(message);
          }}
        />
      ) : null}
    </>
  );
}

function SerialsPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const [q, setQ] = useState('');
  const [filters, setFilters] = useState({ q: '', page: 1 });
  const serials = useSerialUnits(scope.branchId, filters, true);
  const rows = serials.data?.data ?? [];
  const [hold, setHold] = useState<HoldTarget | null>(null);
  const [notice, setNotice] = useState('');
  return (
    <>
      <h2>{t('inventoryTab_serials')}</h2>
      <form
        className="row"
        onSubmit={(event) => {
          event.preventDefault();
          setFilters({ q: q.trim(), page: 1 });
        }}
      >
        <label>
          {t('inventorySerial')}
          <input value={q} maxLength={100} onChange={(event) => setQ(event.target.value)} />
        </label>
        <button type="submit">{t('inventorySearch')}</button>
      </form>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      <QueryState query={serials} empty={serials.isSuccess && rows.length === 0} />
      {rows.length ? (
        <table className="order-lines-table" aria-label={t('inventorySerialTable')}>
          <thead>
            <tr>
              <th scope="col">{t('inventorySerial')}</th>
              <th scope="col">{t('orderLineItem')}</th>
              <th scope="col">{t('inventoryStatus')}</th>
              <th scope="col">{t('inventoryLocation')}</th>
              <th scope="col">{t('inventoryUpdatedAt')}</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((unit) => (
              <tr key={unit.id}>
                <th scope="row">{unit.serial}</th>
                <td>{variantLabel(unit)}</td>
                <td>
                  {t(`inventorySerialStatus_${unit.status}`)}
                  {unit.quarantine_reason ? (
                    <small className="muted"> · {unit.quarantine_reason}</small>
                  ) : null}
                  {scope.manage && (unit.status === 'in_stock' || unit.status === 'quarantined') ? (
                    <>
                      {' '}
                      <button
                        type="button"
                        aria-label={t(
                          unit.status === 'quarantined'
                            ? 'inventoryReleaseTitle'
                            : 'inventoryQuarantineTitle',
                          { label: unit.serial },
                        )}
                        onClick={() => {
                          setNotice('');
                          setHold({
                            kind: 'serial_units',
                            id: unit.id,
                            label: unit.serial,
                            release: unit.status === 'quarantined',
                          });
                        }}
                      >
                        {t(
                          unit.status === 'quarantined'
                            ? 'inventoryRelease'
                            : 'inventoryQuarantine',
                        )}
                      </button>
                    </>
                  ) : null}
                </td>
                <td>
                  {unit.branch_id === scope.branchId
                    ? t('inventoryThisBranch')
                    : unit.branch_id
                      ? t('inventoryOtherBranch')
                      : t('inventoryNoBranch')}
                </td>
                <td>{formatInZone(unit.updated_at, 'vi-VN', scope.timeZone)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : null}
      <Pager
        page={filters.page}
        pages={serials.data?.meta.pages ?? 1}
        onPage={(page) => setFilters({ ...filters, page })}
      />
      {hold ? (
        <HoldDialog
          scope={scope}
          target={hold}
          onClose={() => setHold(null)}
          onDone={(message) => {
            setHold(null);
            setNotice(message);
          }}
        />
      ) : null}
    </>
  );
}

function VariantSelect({
  variants,
  value,
  onChange,
  disabled,
}: {
  variants: PosTraceStatus[];
  value: string;
  onChange: (value: string) => void;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  return (
    <label>
      {t('inventoryVariant')}
      <select
        value={value}
        required
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      >
        <option value="">—</option>
        {variants.map((variant) => (
          <option key={variant.variant_id} value={variant.variant_id}>
            {variantLabel(variant)} · {t(`variantUnitTracked_${variant.tracked_mode}`)}
          </option>
        ))}
      </select>
    </label>
  );
}

// Lots of one variant for the transfer and count forms: up to the server cap,
// narrowed by a lot code prefix when a variant has more.
function useFormLots(scope: Scope, variant: PosTraceStatus | null, status?: string) {
  const [q, setQ] = useState('');
  const lots = useLots(
    scope.branchId,
    { variantId: variant?.variant_id, status, q, limit: FORM_LIST_LIMIT },
    variant?.tracked_mode === 'lot',
  );
  return { lots, q, setQ };
}

function LotFilter({
  value,
  onChange,
  truncated,
  disabled,
}: {
  value: string;
  onChange: (value: string) => void;
  truncated: boolean;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  return (
    <>
      <label>
        {t('inventoryLotFilter')}
        <input
          value={value}
          maxLength={64}
          disabled={disabled}
          onChange={(event) => onChange(event.target.value)}
        />
      </label>
      {truncated ? <p className="muted">{t('inventoryLotListCapped')}</p> : null}
    </>
  );
}

function TraceSummary({ status }: { status: PosTraceStatus }) {
  const { t } = useTranslation();
  return (
    <p className="muted" role="status">
      {t('inventoryResultStatus', {
        name: status.name,
        core: quantity(status.core_on_hand, status.base_unit),
        typed: quantity(status.typed_on_hand, status.base_unit),
      })}{' '}
      {status.blocked_reason
        ? t(`inventoryBlocked_${status.blocked_reason}`)
        : t('inventorySellable')}
    </p>
  );
}

function ReceivePanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const variants = useInventoryVariants(scope.branchId, true);
  const tracked = (variants.data?.data ?? []).filter((row) => row.tracked_mode !== 'none');
  const [variantId, setVariantId] = useState('');
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null;
  const entry = useStockEntry();
  const command = useInventoryCommand<PosTraceStatus>(actorOf(scope));
  const [error, setError] = useState('');
  const [result, setResult] = useState<PosTraceStatus | null>(null);
  const busy = command.isPending;
  const locked = busy || command.uncertain;
  return (
    <form
      className="inventory-form"
      aria-label={t('inventoryTab_receive')}
      onSubmit={(event) => {
        event.preventDefault();
        if (locked || !variant) return;
        const payload = stockEntryPayload(variant.tracked_mode, entry.serialText, entry.lotRows);
        if (!payload.body) {
          setError(entryError(payload, t));
          return;
        }
        setError('');
        setResult(null);
        command.run(
          {
            branchId: scope.branchId,
            action: 'receive',
            path: '/pos/inventory/receipts',
            body: { branch_id: scope.branchId, variant_id: variant.variant_id, ...payload.body },
          },
          {
            onSuccess: (status) => {
              setResult(status);
              entry.reset();
            },
            onError: (failure) => setError(describeInventoryFailure(failure, t)),
          },
        );
      }}
    >
      <h2>{t('inventoryTab_receive')}</h2>
      <p className="muted">{t('inventoryReceiveHint')}</p>
      <QueryState query={variants} empty={variants.isSuccess && tracked.length === 0} />
      <VariantSelect
        variants={tracked}
        value={variantId}
        disabled={locked}
        onChange={(value) => {
          setVariantId(value);
          setError('');
          entry.reset();
        }}
      />
      {variant ? (
        <StockEntryFields
          mode={variant.tracked_mode}
          baseUnit={variant.base_unit}
          serialText={entry.serialText}
          onSerialText={entry.setSerialText}
          lotRows={entry.lotRows}
          onLotRows={entry.setLotRows}
          disabled={locked}
        />
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <CommandCheck command={command} />
      {result ? <TraceSummary status={result} /> : null}
      <button type="submit" className="checkout-submit" disabled={locked || !variant}>
        {busy ? t('waiting') : t('inventoryReceiveSubmit')}
      </button>
    </form>
  );
}

function TransferPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const variants = useInventoryVariants(scope.branchId, true);
  const tracked = (variants.data?.data ?? []).filter((row) => row.tracked_mode !== 'none');
  const [variantId, setVariantId] = useState('');
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null;
  const { lots, q, setQ } = useFormLots(scope, variant, 'active');
  // The server checks stock management at both branches.
  const destinations = (context.data?.branches ?? []).filter(
    (branch) => branch.id !== scope.branchId && branch.status === 'active',
  );
  const [toBranchId, setToBranchId] = useState('');
  const [serialText, setSerialText] = useState('');
  const [amounts, setAmounts] = useState<Record<string, string>>({});
  const command = useInventoryCommand<PosTransferResult>(actorOf(scope));
  const [error, setError] = useState('');
  const [result, setResult] = useState<PosTransferResult | null>(null);
  const busy = command.isPending;
  const locked = busy || command.uncertain;
  const lotRows = lots.data?.data ?? [];

  function payload(): { body: Record<string, unknown> } | { error: string } {
    if (!variant) return { error: t('inventoryVariantRequired') };
    if (variant.tracked_mode === 'serial') {
      const parsed = parseSerials(serialText);
      if (parsed.duplicates.length || parsed.tooLong.length)
        return {
          error: t(parsed.tooLong.length ? 'inventorySerialTooLong' : 'inventorySerialDuplicate', {
            codes: [...parsed.tooLong, ...parsed.duplicates].join(', '),
          }),
        };
      if (!parsed.codes.length) return { error: t('inventoryNothingEntered') };
      return { body: { serials: parsed.codes } };
    }
    // Amounts typed for lots hidden by the filter are still sent.
    const picked: { lot_id: string; quantity: number }[] = [];
    for (const [lotId, text] of Object.entries(amounts)) {
      if (!text.trim()) continue;
      const amount = parseWholeQuantity(text);
      if (amount === null) return { error: t('inventoryQuantityInvalid') };
      const lot = lotRows.find((row) => row.id === lotId);
      if (lot && amount > lot.available) return { error: t('inventoryQuantityTooMany') };
      picked.push({ lot_id: lotId, quantity: amount });
    }
    return picked.length ? { body: { lots: picked } } : { error: t('inventoryNothingEntered') };
  }

  return (
    <form
      className="inventory-form"
      aria-label={t('inventoryTab_transfer')}
      onSubmit={(event) => {
        event.preventDefault();
        if (locked || !variant) return;
        if (!toBranchId) {
          setError(t('inventoryDestinationRequired'));
          return;
        }
        const built = payload();
        if ('error' in built) {
          setError(built.error);
          return;
        }
        setError('');
        setResult(null);
        command.run(
          {
            branchId: scope.branchId,
            action: 'transfer',
            path: '/pos/inventory/transfers',
            body: {
              from_branch_id: scope.branchId,
              to_branch_id: toBranchId,
              variant_id: variant.variant_id,
              ...built.body,
            },
          },
          {
            onSuccess: (data) => {
              setResult(data);
              setSerialText('');
              setAmounts({});
            },
            onError: (failure) => setError(describeInventoryFailure(failure, t)),
          },
        );
      }}
    >
      <h2>{t('inventoryTab_transfer')}</h2>
      <p className="muted">{t('inventoryTransferHint')}</p>
      <QueryState query={variants} empty={variants.isSuccess && tracked.length === 0} />
      <VariantSelect
        variants={tracked}
        value={variantId}
        disabled={locked}
        onChange={(value) => {
          setVariantId(value);
          setError('');
          setSerialText('');
          setAmounts({});
          setQ('');
        }}
      />
      <label>
        {t('inventoryDestination')}
        <select
          value={toBranchId}
          required
          disabled={locked}
          onChange={(event) => setToBranchId(event.target.value)}
        >
          <option value="">—</option>
          {destinations.map((branch) => (
            <option key={branch.id} value={branch.id}>
              {branch.name}
            </option>
          ))}
        </select>
      </label>
      {destinations.length === 0 ? <p className="muted">{t('inventoryNoDestination')}</p> : null}
      {variant?.tracked_mode === 'serial' ? (
        <SerialTextarea
          label={t('inventorySerialList')}
          value={serialText}
          onChange={setSerialText}
          disabled={locked}
        />
      ) : null}
      {variant?.tracked_mode === 'lot' ? (
        <>
          <LotFilter
            value={q}
            onChange={setQ}
            disabled={locked}
            truncated={(lots.data?.meta.count ?? 0) > lotRows.length}
          />
          <QueryState query={lots} empty={lots.isSuccess && lotRows.length === 0} />
          {lotRows.map((lot) => (
            <label key={lot.id}>
              {t('inventoryTransferLot', {
                code: lot.lot_code,
                expiry: formatExpiry(lot.expiry_on),
                available: quantity(lot.available, lot.base_unit),
              })}
              <input
                inputMode="numeric"
                value={amounts[lot.id] ?? ''}
                disabled={locked}
                onChange={(event) => setAmounts({ ...amounts, [lot.id]: event.target.value })}
              />
            </label>
          ))}
        </>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <CommandCheck command={command} />
      {result ? (
        <>
          <TraceSummary status={result.from} />
          <TraceSummary status={result.to} />
        </>
      ) : null}
      <button type="submit" className="checkout-submit" disabled={locked || !variant}>
        {busy ? t('waiting') : t('inventoryTransferSubmit')}
      </button>
    </form>
  );
}

type CountDraft = { counted: string; quarantined: string };

function AdjustPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const variants = useInventoryVariants(scope.branchId, scope.manage);
  const tracked = (variants.data?.data ?? []).filter((row) => row.tracked_mode !== 'none');
  const [variantId, setVariantId] = useState('');
  const variant = tracked.find((row) => row.variant_id === variantId) ?? null;
  const { lots, q, setQ } = useFormLots(scope, variant);
  const lotRows = lots.data?.data ?? [];
  const [counted, setCounted] = useState<Record<string, CountDraft>>({});
  const [missing, setMissing] = useState('');
  const [found, setFound] = useState('');
  const [reason, setReason] = useState('');
  const command = useInventoryCommand<PosAdjustment>(actorOf(scope));
  const [error, setError] = useState('');
  const [result, setResult] = useState<PosAdjustment | null>(null);
  const busy = command.isPending;
  const locked = busy || command.uncertain;

  function setCount(lotId: string, field: keyof CountDraft, value: string) {
    setCounted((current) => ({
      ...current,
      [lotId]: { ...(current[lotId] ?? { counted: '', quarantined: '' }), [field]: value },
    }));
  }

  function payload(): { body: Record<string, unknown> } | { error: string } {
    if (!variant) return { error: t('inventoryVariantRequired') };
    if (!reason.trim()) return { error: t('inventoryReasonRequired') };
    if (variant.tracked_mode === 'serial') {
      const gone = parseSerials(missing);
      const extra = parseSerials(found);
      const repeated = [...gone.duplicates, ...extra.duplicates];
      if (repeated.length)
        return { error: t('inventorySerialDuplicate', { codes: repeated.join(', ') }) };
      const tooLong = [...gone.tooLong, ...extra.tooLong];
      if (tooLong.length)
        return { error: t('inventorySerialTooLong', { codes: tooLong.join(', ') }) };
      const both = gone.codes.filter((code) => extra.codes.includes(code));
      if (both.length) return { error: t('traceReason_duplicate_serial') };
      if (!gone.codes.length && !extra.codes.length) return { error: t('inventoryNothingEntered') };
      return {
        body: {
          ...(gone.codes.length ? { missing_serials: gone.codes } : {}),
          ...(extra.codes.length ? { found_serials: extra.codes } : {}),
        },
      };
    }
    const rows: { lot_id: string; counted: number; counted_quarantined?: number }[] = [];
    for (const [lotId, draft] of Object.entries(counted)) {
      if (!draft.counted.trim() && !draft.quarantined.trim()) continue;
      // Every counted lot states its whole count, quarantined units aside.
      if (!draft.counted.trim()) return { error: t('inventoryCountRequired') };
      const value = parseWholeQuantity(draft.counted, true);
      if (value === null) return { error: t('inventoryQuantityInvalid') };
      const held = draft.quarantined.trim() ? parseWholeQuantity(draft.quarantined, true) : null;
      if (draft.quarantined.trim() && held === null)
        return { error: t('inventoryQuantityInvalid') };
      rows.push({
        lot_id: lotId,
        counted: value,
        ...(held !== null ? { counted_quarantined: held } : {}),
      });
    }
    return rows.length ? { body: { lots: rows } } : { error: t('inventoryNothingEntered') };
  }

  return (
    <>
      {scope.manage ? (
        <form
          className="inventory-form"
          aria-label={t('inventoryTab_adjust')}
          onSubmit={(event) => {
            event.preventDefault();
            if (locked || !variant) return;
            const built = payload();
            if ('error' in built) {
              setError(built.error);
              return;
            }
            setError('');
            setResult(null);
            command.run(
              {
                branchId: scope.branchId,
                action: 'adjust',
                path: '/pos/inventory/adjustments',
                body: {
                  branch_id: scope.branchId,
                  variant_id: variant.variant_id,
                  reason: reason.trim(),
                  ...built.body,
                },
              },
              {
                onSuccess: (adjustment) => {
                  setResult(adjustment);
                  setCounted({});
                  setMissing('');
                  setFound('');
                  setReason('');
                },
                onError: (failure) => setError(describeInventoryFailure(failure, t)),
              },
            );
          }}
        >
          <h2>{t('inventoryTab_adjust')}</h2>
          <p className="muted">{t('inventoryAdjustHint')}</p>
          <QueryState query={variants} empty={variants.isSuccess && tracked.length === 0} />
          <VariantSelect
            variants={tracked}
            value={variantId}
            disabled={locked}
            onChange={(value) => {
              setVariantId(value);
              setError('');
              setCounted({});
              setQ('');
            }}
          />
          {variant?.tracked_mode === 'lot' ? (
            <>
              <LotFilter
                value={q}
                onChange={setQ}
                disabled={locked}
                truncated={(lots.data?.meta.count ?? 0) > lotRows.length}
              />
              <QueryState query={lots} empty={lots.isSuccess && lotRows.length === 0} />
              {lotRows.map((lot) => (
                <div className="row" key={lot.id}>
                  <label>
                    {t('inventoryCountLot', {
                      code: lot.lot_code,
                      onHand: quantity(lot.on_hand, lot.base_unit),
                    })}
                    <input
                      inputMode="numeric"
                      value={counted[lot.id]?.counted ?? ''}
                      disabled={locked}
                      onChange={(event) => setCount(lot.id, 'counted', event.target.value)}
                    />
                  </label>
                  {lot.quarantined_quantity > 0 ? (
                    <label>
                      {t('inventoryCountQuarantined', {
                        code: lot.lot_code,
                        held: quantity(lot.quarantined_quantity, lot.base_unit),
                      })}
                      <input
                        inputMode="numeric"
                        value={counted[lot.id]?.quarantined ?? ''}
                        disabled={locked}
                        onChange={(event) => setCount(lot.id, 'quarantined', event.target.value)}
                      />
                    </label>
                  ) : null}
                </div>
              ))}
            </>
          ) : null}
          {variant?.tracked_mode === 'serial' ? (
            <>
              <SerialTextarea
                label={t('inventoryMissingSerials')}
                value={missing}
                onChange={setMissing}
                disabled={locked}
                rows={3}
              />
              <SerialTextarea
                label={t('inventoryFoundSerials')}
                value={found}
                onChange={setFound}
                disabled={locked}
                rows={3}
              />
            </>
          ) : null}
          <label>
            {t('inventoryReason')}
            <input
              value={reason}
              maxLength={200}
              disabled={locked}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <CommandCheck command={command} />
          {result ? (
            <p className="muted" role="status">
              {t(`inventoryAdjustmentResult_${result.status}`, {
                name: result.name,
                delta: quantity(result.delta, variant?.base_unit),
              })}
            </p>
          ) : null}
          <button type="submit" className="checkout-submit" disabled={locked || !variant}>
            {busy ? t('waiting') : t('inventoryAdjustSubmit')}
          </button>
        </form>
      ) : null}
      <PendingAdjustments
        scope={scope}
        units={new Map(tracked.map((row) => [row.variant_id, row.base_unit]))}
      />
    </>
  );
}

function adjustmentLine(
  line: PosAdjustment['lines'][number],
  unit: string | undefined,
  t: (key: string, options?: Record<string, unknown>) => string,
) {
  const label = line.lot_code ?? line.serial ?? '';
  const main = `${label}: ${quantity(line.before, unit)} → ${quantity(line.after, unit)}`;
  return line.quarantined_delta
    ? `${main} (${t('inventoryAdjustmentQuarantined', {
        before: quantity(line.quarantined_before, unit),
        after: quantity(line.quarantined_after, unit),
      })})`
    : main;
}

function PendingAdjustments({ scope, units }: { scope: Scope; units: Map<string, string> }) {
  const { t } = useTranslation();
  const [page, setPage] = useState(1);
  const pending = useAdjustments(scope.branchId, 'pending_approval', page, true);
  const rows = pending.data?.data ?? [];
  const command = useInventoryCommand<PosAdjustment>(actorOf(scope));
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [canceling, setCanceling] = useState<PosAdjustment | null>(null);
  const locked = command.isPending || command.uncertain;

  function send(input: InventoryCommandInput, done: (updated: PosAdjustment) => void) {
    setError('');
    setNotice('');
    command.run(input, {
      onSuccess: done,
      onError: (failure) => setError(describeInventoryFailure(failure, t)),
    });
  }

  function act(adjustment: PosAdjustment, action: 'approve' | 'apply') {
    send(
      {
        branchId: scope.branchId,
        action: `adjustment.${action}`,
        path: `/pos/inventory/adjustments/${adjustment.id}/${action}`,
        body:
          action === 'apply' && adjustment.approval?.status === 'active'
            ? { approval_id: adjustment.approval.id }
            : {},
      },
      (updated) => setNotice(t(`inventoryAdjustmentDone_${action}`, { name: updated.name })),
    );
  }

  return (
    <section aria-labelledby="inventory-pending-title">
      <div className="row">
        <h3 id="inventory-pending-title">{t('inventoryPendingAdjustments')}</h3>
        <button type="button" disabled={pending.isFetching} onClick={() => void pending.refetch()}>
          {t('inventoryRefresh')}
        </button>
      </div>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {error && !canceling ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {!canceling ? <CommandCheck command={command} /> : null}
      <QueryState query={pending} empty={pending.isSuccess && rows.length === 0} />
      {rows.length ? (
        <ul className="record-list" aria-label={t('inventoryPendingAdjustments')}>
          {rows.map((adjustment) => {
            const actions = adjustmentActions(adjustment, scope.staffId, scope.capabilities);
            const unit = units.get(adjustment.variant_id);
            return (
              <li key={adjustment.id}>
                <span>
                  <strong>{variantLabel(adjustment)}</strong> ·{' '}
                  {t('inventoryAdjustmentDelta', { delta: quantity(adjustment.delta, unit) })} ·{' '}
                  {adjustment.reason}
                </span>
                <small className="muted">
                  {t('inventoryAdjustmentRequester', {
                    name: adjustment.requester_name,
                    at: formatInZone(adjustment.created_at, 'vi-VN', scope.timeZone),
                  })}
                  {adjustment.approval?.status === 'active' ? ` · ${t('inventoryApproved')}` : ''}
                </small>
                <small>
                  {adjustment.lines.map((line) => adjustmentLine(line, unit, t)).join('; ')}
                </small>
                <span className="row">
                  {actions.approve ? (
                    <button
                      type="button"
                      disabled={locked}
                      onClick={() => act(adjustment, 'approve')}
                    >
                      {t('inventoryApprove')}
                    </button>
                  ) : null}
                  {actions.apply ? (
                    <button
                      type="button"
                      disabled={locked}
                      onClick={() => act(adjustment, 'apply')}
                    >
                      {t('inventoryApply')}
                    </button>
                  ) : null}
                  {actions.cancel ? (
                    <button
                      type="button"
                      disabled={locked}
                      onClick={() => {
                        setError('');
                        setNotice('');
                        setCanceling(adjustment);
                      }}
                    >
                      {t('inventoryCancelAdjustment')}
                    </button>
                  ) : null}
                </span>
              </li>
            );
          })}
        </ul>
      ) : null}
      <Pager page={page} pages={pending.data?.meta.pages ?? 1} onPage={setPage} />
      {canceling ? (
        <ReasonDialog
          title={t('inventoryCancelTitle', { name: canceling.name })}
          submitLabel={t('inventoryCancelAdjustment')}
          command={command}
          error={error}
          onClose={() => {
            setCanceling(null);
            setError('');
          }}
          onSubmit={(reason) =>
            send(
              {
                branchId: scope.branchId,
                action: 'adjustment.cancel',
                path: `/pos/inventory/adjustments/${canceling.id}/cancel`,
                body: { reason },
              },
              (updated) => {
                setCanceling(null);
                setNotice(t('inventoryAdjustmentDone_cancel', { name: updated.name }));
              },
            )
          }
        />
      ) : null}
    </section>
  );
}

function RecallPanel({ scope }: { scope: Scope }) {
  const { t } = useTranslation();
  const [kind, setKind] = useState<RecallQuery['kind']>('lot_code');
  const [value, setValue] = useState('');
  const [query, setQuery] = useState<RecallQuery | null>(null);
  const recall = useRecall(query, true);
  const result = recall.data?.data;
  const meta = recall.data?.meta;
  return (
    <>
      <h2>{t('inventoryTab_recall')}</h2>
      <p className="muted">{t('inventoryRecallHint')}</p>
      <form
        className="row"
        onSubmit={(event) => {
          event.preventDefault();
          const text = value.trim();
          setQuery(text ? { kind, value: text, page: 1 } : null);
        }}
      >
        <label>
          {t('inventoryRecallBy')}
          <select
            value={kind}
            onChange={(event) => setKind(event.target.value as RecallQuery['kind'])}
          >
            <option value="lot_code">{t('inventoryLotCode')}</option>
            <option value="serial">{t('inventorySerial')}</option>
          </select>
        </label>
        <label>
          {t('inventoryRecallValue')}
          <input value={value} maxLength={100} onChange={(event) => setValue(event.target.value)} />
        </label>
        <button type="submit">{t('inventorySearch')}</button>
      </form>
      {query && recall.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
      {recall.isError ? (
        <p className="error" role="alert">
          {describeInventoryFailure(recall.error, t)}
        </p>
      ) : null}
      {result ? (
        <div className="inventory-recall" aria-live="polite">
          {meta?.truncated ? (
            <p className="status-tag" data-warning="true">
              {t('inventoryRecallTruncated')}
            </p>
          ) : null}
          <h3>{t('inventoryRecallStock')}</h3>
          {result.lots.length === 0 && result.serial_units.length === 0 ? (
            <p className="muted">{t('inventoryEmpty')}</p>
          ) : null}
          {result.lots.length ? (
            <ul className="record-list" aria-label={t('inventoryRecallLots')}>
              {result.lots.map((lot) => (
                <li key={lot.id}>
                  <strong>{lot.lot_code}</strong>
                  <span>{variantLabel(lot)}</span>
                  <Expiry value={lot.expiry_on} today={scope.today} />
                  <span>
                    {t('inventoryOnHand')}: {quantity(lot.on_hand, lot.base_unit)}
                  </span>
                  <span>{t(`inventoryLotStatus_${lot.status}`)}</span>
                </li>
              ))}
            </ul>
          ) : null}
          {result.serial_units.length ? (
            <ul className="record-list" aria-label={t('inventoryRecallSerials')}>
              {result.serial_units.map((unit) => (
                <li key={unit.id}>
                  <strong>{unit.serial}</strong>
                  <span>{variantLabel(unit)}</span>
                  <span>{t(`inventorySerialStatus_${unit.status}`)}</span>
                </li>
              ))}
            </ul>
          ) : null}
          <h3>{t('inventoryRecallSales')}</h3>
          {result.sales.length === 0 ? (
            <p className="muted">{t('inventoryRecallNoSales')}</p>
          ) : null}
          {result.sales.length ? (
            <table className="order-lines-table" aria-label={t('inventoryRecallSales')}>
              <thead>
                <tr>
                  <th scope="col">{t('inventoryRecallOrder')}</th>
                  <th scope="col">{t('inventoryRecallBranch')}</th>
                  <th scope="col">{t('inventoryRecallSoldAt')}</th>
                  <th scope="col">{t('orderLineItem')}</th>
                  <th scope="col">{t('inventoryRecallTrace')}</th>
                  <th scope="col">{t('inventoryRecallQuantity')}</th>
                  <th scope="col">{t('inventoryRecallCustomer')}</th>
                </tr>
              </thead>
              <tbody>
                {result.sales.map((sale) => (
                  <tr key={`${sale.sale_line_id}:${sale.lot_code ?? ''}:${sale.serial ?? ''}`}>
                    <th scope="row">{sale.order_number}</th>
                    <td>{sale.branch_name}</td>
                    <td>{formatInZone(sale.sold_at, 'vi-VN', scope.timeZone)}</td>
                    <td>{sale.sku ? `${sale.name} · ${sale.sku}` : sale.name}</td>
                    <td>
                      {sale.serial ??
                        (sale.lot_code
                          ? `${sale.lot_code} · ${t('inventoryExpiryShort')} ${formatExpiry(sale.expiry_on)}`
                          : '—')}
                    </td>
                    <td>
                      {t('inventoryRecallReturned', {
                        quantity: quantity(sale.quantity, sale.base_unit),
                        returned: quantity(sale.returned_quantity, sale.base_unit),
                      })}
                    </td>
                    <td>
                      {sale.customer
                        ? `${sale.customer.name}${sale.customer.phone ? ` · ${sale.customer.phone}` : ''}`
                        : t('inventoryRecallWalkIn')}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : null}
          {query ? (
            <Pager
              page={query.page}
              pages={meta?.pages ?? 1}
              onPage={(page) => setQuery({ ...query, page })}
            />
          ) : null}
        </div>
      ) : null}
    </>
  );
}
