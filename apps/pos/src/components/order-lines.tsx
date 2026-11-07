import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { MAX_COUNT_QUANTITY, parseCountQuantity, parseMeasuredQuantity } from '../lib/quantity';
import { describeFailure } from '../lib/request-failure';
import { ItemDiscountEditor } from './item-discount-editor';
import { LinePriceEditor } from './line-price-editor';
import { PosIcon } from './pos-icon';

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
}) {
  const { t } = useTranslation();
  const [quantities, setQuantities] = useState<Record<string, string>>({});
  const [error, setError] = useState('');
  const lines = workspace.line_items ?? [];
  const currency = workspace.totals?.currency ?? 'VND';

  async function run(lineId: string, action: () => Promise<PosWorkspace>) {
    if (disabled) return;
    setError('');
    try {
      await action();
      setQuantities((current) => {
        const next = { ...current };
        delete next[lineId];
        return next;
      });
    } catch (failure) {
      setError(describeFailure(failure, t));
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
              const quantityLocked = disabled || labelled;
              const quantityTitle = labelled ? t('saleLineLabelLocked') : disabledReason;
              const targetId = line.sale_line_id ?? line.id;
              const inputValue =
                quantities[line.id] ??
                (measured ? (line.sale_quantity ?? '') : String(line.quantity));
              const measuredQuantity = measured ? parseMeasuredQuantity(inputValue) : null;
              const countQuantity = measured ? null : parseCountQuantity(inputValue);
              const validQuantity = measured ? measuredQuantity !== null : countQuantity !== null;
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
                      {line.lot_code ? (
                        <span>{` · ${t('saleLineLot')}: ${line.lot_code}`}</span>
                      ) : null}
                      {line.serial_codes?.length ? (
                        <span>{` · ${t('saleLineSerials')}: ${line.serial_codes.join(', ')}`}</span>
                      ) : null}
                      {line.tracked_mode && line.tracked_mode !== 'none' ? (
                        <span>{` · ${t('saleLineReservationUnavailable')}`}</span>
                      ) : null}
                    </div>
                  </td>
                  <td>
                    <div className="quantity-control">
                      {!measured ? (
                        <button
                          type="button"
                          aria-label={t('decreaseQuantity', { name: line.name })}
                          disabled={disabled || line.quantity <= 1}
                          title={disabledReason}
                          onClick={() =>
                            void run(line.id, () =>
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
                          disabled={disabled || line.quantity >= MAX_COUNT_QUANTITY}
                          title={disabledReason}
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
                      {line.sale_line_id && (canApplyDiscount || canOverridePrice) ? (
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
                          disabled={disabled || !validQuantity}
                          title={disabledReason}
                          onClick={saveQuantity}
                        >
                          {t('save')}
                        </button>
                      ) : null}
                      <button
                        className="remove-line"
                        type="button"
                        title={disabledReason ?? t('removeItem')}
                        aria-label={`${t('removeItem')} ${line.name}`}
                        disabled={disabled}
                        onClick={() => void run(line.id, () => onRemove(targetId))}
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
    </>
  );
}
