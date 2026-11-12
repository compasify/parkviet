import { formatMoney, parseVndAmount } from '@parkviet/pos-shared/money';
import {
  describeTraceFailure,
  formatExpiry,
  traceReasonKey,
} from '@parkviet/pos-shared/traceability';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCupLabelReprint } from '../hooks/use-kitchen';
import { kitchenSent, kitchenStates } from '../lib/kitchen';
import { linePicks, toSelections } from '../lib/menu-selection';
import type {
  PosLineItem,
  PosMenu,
  PosMenuItem,
  PosModifierSelection,
  PosWorkspace,
} from '../lib/pos-context';
import { MAX_COUNT_QUANTITY, parseCountQuantity, parseMeasuredQuantity } from '../lib/quantity';
import { snapshotLocked } from '../lib/request-failure';
import { lineChanged, lineSent } from '../lib/table-kitchen';
import { ItemDiscountEditor } from './item-discount-editor';
import { LinePriceEditor } from './line-price-editor';
import { ModifierSheet } from './modifier-sheet';
import { PosIcon } from './pos-icon';
import { lotLabel } from './sold-trace';

export function OrderLines({
  workspace,
  disabled,
  disabledReason,
  canApplyDiscount,
  canOverridePrice,
  onUpdate,
  onRemove,
  onLineDiscount,
  onClearLineDiscount,
  onPriceOverride,
  menu = null,
  onUpdateModifiers,
  onAddSame,
  cupLabels = false,
  appendOnly = false,
  onVoid,
  onStale,
}: {
  workspace: PosWorkspace;
  disabled: boolean;
  disabledReason?: string;
  canApplyDiscount: boolean;
  canOverridePrice: boolean;
  onUpdate: (
    lineItemId: string,
    input: { quantity?: number; sale_quantity?: string },
  ) => Promise<PosWorkspace>;
  onRemove: (lineItemId: string) => Promise<PosWorkspace>;
  onLineDiscount: (
    saleLineId: string,
    input: {
      valueType: 'flat' | 'percent' | 'unit_price' | 'item_flat' | 'item_percent';
      value: string;
      reason: string;
      approvalId?: string;
    },
  ) => Promise<PosWorkspace>;
  onClearLineDiscount: (saleLineId: string, approvalId?: string) => Promise<PosWorkspace>;
  onPriceOverride: (
    saleLineId: string,
    input: { price: string; reason: string; approvalId?: string },
  ) => Promise<PosWorkspace>;
  // The branch's menu while it runs one: menu lines can change their options.
  menu?: PosMenu | null;
  onUpdateModifiers?: (
    saleLineId: string,
    input: { modifiers: PosModifierSelection[]; note: string | null },
  ) => Promise<PosWorkspace>;
  onAddSame?: (
    variantId: string,
    input: { modifiers: PosModifierSelection[]; note?: string },
  ) => Promise<PosWorkspace>;
  // The branch prints cup labels: a line already sent or sold can print its
  // labels again.
  cupLabels?: boolean;
  // A table order: without the lease, lines the kitchen has not heard about
  // still change by their own version; prices, discounts and options do not.
  appendOnly?: boolean;
  // Takes back what the kitchen has of a line: the void dialog.
  onVoid?: (line: PosLineItem) => void;
  // Someone else changed a line first: reload the order.
  onStale?: () => void;
}) {
  const { t } = useTranslation();
  const [quantities, setQuantities] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<{ line: PosLineItem; item: PosMenuItem } | null>(null);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const reprint = useCupLabelReprint();
  const lines = workspace.line_items ?? [];
  const currency = workspace.totals?.currency ?? 'VND';

  // Changing counts and taking lines off, which a table order allows without the lease.
  const countDisabled = disabled && !appendOnly;

  async function run(lineId: string, action: () => Promise<PosWorkspace>) {
    if (countDisabled) return;
    setError('');
    try {
      await action();
      setQuantities((current) => {
        const next = { ...current };
        delete next[lineId];
        return next;
      });
    } catch (failure) {
      const line = lines.find((row) => row.id === lineId);
      if (lineChanged(failure)) {
        setError(t('lineChangedByOther'));
        onStale?.();
      } else if (lineSent(failure) && line && onVoid) onVoid(line);
      else if (snapshotLocked(failure) && appendOnly) setError(t('tableSnapshotLocked'));
      else setError(describeTraceFailure(failure, t));
    }
  }

  return (
    <>
      <div className="basket-table-scroll">
        <table className="basket-table" aria-label={t('basketTitle')}>
          <thead>
            <tr>
              {[
                'itemIndexColumn',
                'itemSkuColumn',
                'itemNameColumn',
                'itemQuantityColumn',
                'itemPriceColumn',
                'itemDiscountColumn',
                'itemTotalColumn',
              ].map((label) => (
                <th key={label} scope="col">
                  {t(label)}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="basket-lines">
            {lines.length === 0 ? (
              <tr>
                <td colSpan={7}>
                  <div className="basket-empty">
                    <PosIcon name="box" />
                    <strong>{t('basketEmpty')}</strong>
                    <span>{t('basketReady')}</span>
                  </div>
                </td>
              </tr>
            ) : null}
            {lines.map((line, index) => {
              const measured = line.kind === 'measured';
              // A scale label fixes the package's quantity; the server refuses edits.
              const labelled = Boolean(line.label_barcode);
              // Each unit of a serial line is one scanned serial: re-add to change it.
              const serialLine = line.trace?.mode === 'serial';
              // Play time changes only through the room's clock.
              const timedLine = line.kind === 'timed';
              // The kitchen has made this much already: the line may grow, not shrink.
              const sent = kitchenSent(line);
              // Without the lease only a line the kitchen has not heard about changes.
              const quantityLocked =
                countDisabled || labelled || serialLine || timedLine || (disabled && sent > 0);
              // What the kitchen has comes back only through a void.
              const voidable = sent > 0 && Boolean(onVoid) && !countDisabled;
              const sentTitle =
                sent > 0
                  ? t(voidable ? 'kitchenSentVoid' : 'kitchenSentLocked', { count: sent })
                  : undefined;
              const quantityTitle = timedLine
                ? t('timedFailure_timed_line')
                : labelled
                  ? t('saleLineLabelLocked')
                  : serialLine
                    ? t('saleLineSerialLocked')
                    : disabledReason;
              const targetId = line.sale_line_id ?? line.id;
              const inputValue =
                quantities[line.id] ??
                (measured ? (line.sale_quantity ?? '') : String(line.quantity));
              const measuredQuantity = measured ? parseMeasuredQuantity(inputValue) : null;
              const countQuantity = measured ? null : parseCountQuantity(inputValue);
              const validQuantity = measured
                ? measuredQuantity !== null
                : countQuantity !== null && countQuantity >= sent;
              const saveQuantity = () => {
                if (quantityLocked) return;
                if (measuredQuantity !== null)
                  void run(line.id, () => onUpdate(targetId, { sale_quantity: measuredQuantity }));
                else if (countQuantity !== null)
                  void run(line.id, () => onUpdate(targetId, { quantity: countQuantity }));
              };
              return (
                <tr key={line.id}>
                  <td className="basket-index">{index + 1}</td>
                  <td className="basket-sku">{line.sku || '—'}</td>
                  <td>
                    <div className="basket-line-name">
                      <strong>{line.name}</strong>
                      {line.price_label ? (
                        <span className="basket-line-price-label">{line.price_label}</span>
                      ) : null}
                      {measured ? (
                        <span>
                          {' · '}
                          {line.sale_quantity} {line.sale_unit} ({line.base_quantity}{' '}
                          {line.base_unit})
                        </span>
                      ) : null}
                      {line.label_barcode ? (
                        <span className="basket-line-label">
                          {t('saleLineLabel', { barcode: line.label_barcode })}
                          {line.label_format_version
                            ? ` · ${t('saleLineLabelVersion', { version: line.label_format_version })}`
                            : ''}
                        </span>
                      ) : null}
                      <LineTrace line={line} />
                      <MenuLineDetail line={line} />
                      <TimedLineDetail line={line} />
                      {sent > 0 ? (
                        <span className="basket-line-kitchen" title={sentTitle}>
                          <PosIcon name="check" /> {t('kitchenSentBadge', { count: sent })}
                        </span>
                      ) : null}
                      {kitchenStates(line).length > 0 ? (
                        <span
                          className="basket-line-kitchen-states"
                          data-testid="line-kitchen-states"
                        >
                          {kitchenStates(line)
                            .map((row) => t(`kitchenLineState_${row.state}`, { count: row.count }))
                            .join(' · ')}
                        </span>
                      ) : null}
                      {line.kind === 'menu' && line.sale_line_id
                        ? (() => {
                            const item = menuItemOf(menu, line);
                            const same = sameSelections(line);
                            const printsLabels =
                              cupLabels &&
                              item?.cup_label === true &&
                              (sent > 0 || workspace.operational_status === 'completed');
                            return (
                              <span className="basket-line-actions">
                                {item && onUpdateModifiers ? (
                                  <button
                                    type="button"
                                    disabled={disabled || sent > 0}
                                    title={sentTitle ?? disabledReason}
                                    onClick={() => setEditing({ line, item })}
                                  >
                                    {t('menuEditOptions')}
                                  </button>
                                ) : null}
                                {onAddSame && same ? (
                                  <button
                                    type="button"
                                    disabled={countDisabled || line.quantity >= MAX_COUNT_QUANTITY}
                                    title={disabledReason}
                                    onClick={() =>
                                      void run(line.id, () =>
                                        onAddSame(line.variant_id, {
                                          modifiers: same,
                                          note: line.note ?? undefined,
                                        }),
                                      )
                                    }
                                  >
                                    {t('menuAddSame')}
                                  </button>
                                ) : null}
                                {printsLabels ? (
                                  <button
                                    type="button"
                                    disabled={reprint.isPending}
                                    data-testid="cup-label-reprint"
                                    onClick={() => {
                                      setError('');
                                      setNotice('');
                                      reprint
                                        .mutateAsync({
                                          workspaceId: workspace.id,
                                          saleLineId: line.sale_line_id ?? undefined,
                                        })
                                        .then((result) =>
                                          setNotice(
                                            t('cupLabelReprinted', { count: result.jobs.length }),
                                          ),
                                        )
                                        .catch((failure: unknown) =>
                                          setError(describeTraceFailure(failure, t)),
                                        );
                                    }}
                                  >
                                    {t('cupLabelReprint')}
                                  </button>
                                ) : null}
                              </span>
                            );
                          })()
                        : null}
                    </div>
                  </td>
                  <td>
                    <div className="quantity-control">
                      {!measured ? (
                        <button
                          type="button"
                          aria-label={t('decreaseQuantity', { name: line.name })}
                          disabled={
                            voidable && line.quantity <= sent
                              ? false
                              : quantityLocked || line.quantity <= Math.max(1, sent)
                          }
                          title={line.quantity <= sent ? sentTitle : quantityTitle}
                          onClick={() =>
                            voidable && line.quantity <= sent
                              ? onVoid?.(line)
                              : void run(line.id, () =>
                                  onUpdate(targetId, { quantity: line.quantity - 1 }),
                                )
                          }
                        >
                          <PosIcon name="minus" />
                        </button>
                      ) : null}
                      <label className="visually-hidden" htmlFor={`quantity-${line.id}`}>
                        {measured ? t('saleLineSaleQuantity') : t('quantity')} {line.name}
                      </label>
                      <input
                        id={`quantity-${line.id}`}
                        type={measured ? 'text' : 'number'}
                        inputMode={measured ? 'decimal' : 'numeric'}
                        min={measured ? undefined : 1}
                        max={measured ? undefined : MAX_COUNT_QUANTITY}
                        value={inputValue}
                        aria-invalid={!validQuantity}
                        disabled={quantityLocked}
                        title={quantityTitle}
                        onKeyDown={(event) => {
                          if (event.key === 'Enter') {
                            event.preventDefault();
                            saveQuantity();
                          }
                        }}
                        onChange={(event) =>
                          setQuantities((current) => ({
                            ...current,
                            [line.id]: event.target.value,
                          }))
                        }
                      />
                      {!measured ? (
                        <button
                          type="button"
                          aria-label={t('increaseQuantity', { name: line.name })}
                          disabled={quantityLocked || line.quantity >= MAX_COUNT_QUANTITY}
                          title={quantityTitle}
                          onClick={() =>
                            void run(line.id, () =>
                              onUpdate(targetId, { quantity: line.quantity + 1 }),
                            )
                          }
                        >
                          <PosIcon name="plus" />
                        </button>
                      ) : null}
                    </div>
                  </td>
                  <td className="basket-unit-price">
                    <div className="basket-cell-inline">
                      {(() => {
                        const effectivePrice =
                          line.line_discount?.value_type === 'unit_price'
                            ? line.line_discount.value
                            : (line.unit_price ?? line.price);
                        const baseListPrice = line.list_price;
                        const hasPriceChange =
                          baseListPrice !== undefined &&
                          parseVndAmount(effectivePrice) !== parseVndAmount(baseListPrice);
                        return (
                          <span className="unit-price-stack">
                            <span>
                              {formatMoney(effectivePrice, currency)}
                              {measured ? ` / ${line.sale_unit}` : ''}
                            </span>
                            {hasPriceChange ? (
                              <del className="unit-price-original">
                                {formatMoney(baseListPrice, currency)}
                              </del>
                            ) : null}
                          </span>
                        );
                      })()}
                      {line.sale_line_id && !timedLine && (canApplyDiscount || canOverridePrice) ? (
                        <LinePriceEditor
                          key={`${line.id}:${line.unit_price ?? line.price}:${line.list_price ?? ''}`}
                          line={line}
                          currency={currency}
                          disabled={disabled}
                          disabledReason={disabledReason}
                          canApplyDiscount={canApplyDiscount || canOverridePrice}
                          onApply={(input) =>
                            onPriceOverride(targetId, {
                              price: input.value,
                              reason: input.reason,
                              approvalId: input.approvalId,
                            })
                          }
                        />
                      ) : null}
                    </div>
                  </td>
                  <td className="basket-item-discount">
                    <ItemDiscountEditor
                      key={`${line.id}:${line.item_discount?.value_type}:${line.item_discount?.value}:${line.item_discount?.source}:${line.line_discount?.id}`}
                      line={line}
                      currency={currency}
                      disabled={disabled}
                      disabledReason={disabledReason}
                      canApplyDiscount={canApplyDiscount}
                      onApply={(input) => onLineDiscount(targetId, input)}
                      onClear={(approvalId) => onClearLineDiscount(targetId, approvalId)}
                    />
                  </td>
                  <td>
                    <div className="basket-line-total">
                      <strong>
                        {formatMoney(
                          line.item_net_amount ?? line.net_amount ?? line.amount,
                          currency,
                        )}
                      </strong>
                      {quantities[line.id] !== undefined ? (
                        <button
                          type="button"
                          disabled={quantityLocked || !validQuantity}
                          title={disabledReason}
                          onClick={saveQuantity}
                        >
                          {t('save')}
                        </button>
                      ) : null}
                      <button
                        className="remove-line"
                        type="button"
                        title={sentTitle ?? disabledReason ?? t('removeItem')}
                        aria-label={`${t('removeItem')} ${line.name}`}
                        disabled={voidable ? false : countDisabled || timedLine || sent > 0}
                        onClick={() =>
                          voidable ? onVoid?.(line) : void run(line.id, () => onRemove(targetId))
                        }
                      >
                        <PosIcon name="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {editing && menu && onUpdateModifiers && editing.line.sale_line_id ? (
        <ModifierSheet
          menu={menu}
          item={editing.item}
          editing
          initial={{
            variantId: editing.line.variant_id,
            picks: linePicks(editing.line),
            note: editing.line.note ?? '',
          }}
          onSubmit={(result) =>
            onUpdateModifiers(editing.line.sale_line_id as string, {
              modifiers: result.modifiers,
              note: result.note || null,
            })
          }
          onClose={() => setEditing(null)}
        />
      ) : null}
    </>
  );
}

function menuItemOf(menu: PosMenu | null, line: PosLineItem): PosMenuItem | null {
  return (
    menu?.items.find((item) => item.variants.some((variant) => variant.id === line.variant_id)) ??
    null
  );
}

// The options of a line to send again for one more of the same. A line whose
// option was deleted since cannot be repeated exactly, so it offers nothing.
function sameSelections(line: PosLineItem): PosModifierSelection[] | null {
  const rows = line.modifiers ?? [];
  if (rows.some((row) => row.option_id === null)) return null;
  return toSelections(linePicks(line));
}

// A play-time line's clock: how long the room was played and, once stopped,
// the bands it was billed at. Every time is the server's.
function TimedLineDetail({ line }: { line: PosLineItem }) {
  const { t, i18n } = useTranslation();
  const timed = line.timed_session;
  if (line.kind !== 'timed' || !timed) return null;
  const clock = (value: string) =>
    new Date(value).toLocaleTimeString(i18n.language, { hour: '2-digit', minute: '2-digit' });
  const played = timed.quote?.played_minutes ?? timed.played_minutes ?? 0;
  const bands = timed.quote?.lines ?? [];
  return (
    <span className="basket-line-menu basket-line-timed">
      <span className="basket-line-label">
        {timed.resource_name ? `${timed.resource_name} · ` : ''}
        {t('timedPlayed', { time: t('timedMinutes', { count: played }) })}
        {timed.status === 'stopped' && timed.stopped_at
          ? ` · ${t('timedStopped', { time: clock(timed.stopped_at) })}`
          : ''}
      </span>
      {timed.status === 'stopped'
        ? bands.map((band) => (
            <span key={`${band.starts_at}:${band.ends_at}`} className="basket-line-label">
              {band.label ? `${band.label} · ` : ''}
              {t('timedLine', {
                minutes: band.minutes,
                from: clock(band.starts_at),
                to: clock(band.ends_at),
              })}
            </span>
          ))
        : null}
    </span>
  );
}

// What the line was sold with: options, combo contents and the note.
function MenuLineDetail({ line }: { line: PosLineItem }) {
  const modifiers = line.modifiers ?? [];
  const components = line.components ?? [];
  if (modifiers.length === 0 && components.length === 0 && !line.note) return null;
  return (
    <span className="basket-line-menu">
      {modifiers.length > 0 ? (
        <span className="basket-line-label">
          {modifiers
            .map((row) => (row.quantity > 1 ? `+ ${row.name} ×${row.quantity}` : `+ ${row.name}`))
            .join(', ')}
        </span>
      ) : null}
      {components.length > 0 ? (
        <span className="basket-line-label">
          {components.map((row) => `${row.name} ×${row.quantity}`).join(', ')}
        </span>
      ) : null}
      {line.note ? <span className="basket-line-label basket-line-note">* {line.note}</span> : null}
    </span>
  );
}

// Serials and lots held for a traced line, or the FEFO plan the server will
// reserve at payment. Payloads without trace show the recorded lot/serials.
function LineTrace({ line }: { line: PosLineItem }) {
  const { t } = useTranslation();
  const trace = line.trace;
  if (!trace)
    return line.lot_code || line.serial_codes?.length ? (
      <span className="basket-line-label">
        {line.lot_code ? `${t('saleLineLot')}: ${line.lot_code}` : ''}
        {line.lot_code && line.serial_codes?.length ? ' · ' : ''}
        {line.serial_codes?.length
          ? `${t('saleLineSerials')}: ${line.serial_codes.join(', ')}`
          : ''}
      </span>
    ) : null;
  const lotText = (code: string | null, expiry: string | null) => lotLabel(t, code, expiry);
  // Allocations count base units.
  const unit = line.base_unit ? ` ${line.base_unit}` : '';
  return (
    <span className="basket-line-trace">
      {trace.allocations.map((allocation) => (
        <span key={allocation.id} className="basket-line-label">
          {allocation.kind === 'serial'
            ? `${t('saleLineSerials')}: ${allocation.serial ?? ''}`
            : `${lotText(allocation.lot_code, allocation.expiry_on)} × ${allocation.quantity}${unit}`}
          {` · ${t(`saleLineTraceStatus_${allocation.status}`)}`}
        </span>
      ))}
      {trace.allocations.length === 0
        ? trace.preview.map((plan) => (
            <span key={plan.lot_code} className="basket-line-label">
              {t('saleLineLotPreview', {
                code: plan.lot_code,
                expiry: formatExpiry(plan.expiry_on),
                quantity: `${plan.quantity}${unit}`,
              })}
            </span>
          ))
        : null}
      {trace.issue ? (
        <span className="basket-line-label" role="status" data-warning="true">
          {t(traceReasonKey(trace.issue) ?? 'paymentTraceIssueUnknown')}
        </span>
      ) : null}
    </span>
  );
}
