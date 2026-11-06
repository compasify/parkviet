import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { ItemDiscountEditor } from './item-discount-editor';
import { LinePriceEditor } from './line-price-editor';
import { PosIcon } from './pos-icon';

export function OrderLines({
  workspace,
  disabled,
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
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const lines = workspace.line_items ?? [];
  const currency = workspace.totals?.currency ?? 'VND';

  async function run(lineId: string, action: () => Promise<PosWorkspace>) {
    setBusy(true);
    setError('');
    try {
      await action();
      setQuantities((current) => {
        const next = { ...current };
        delete next[lineId];
        return next;
      });
    } catch (failure) {
      setError(t(posFailureKey(failure)));
    } finally {
      setBusy(false);
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
              const targetId = line.sale_line_id ?? line.id;
              const inputValue =
                quantities[line.id] ??
                (measured ? (line.sale_quantity ?? '') : String(line.quantity));
              const validQuantity = measured
                ? /^\d+(\.\d+)?$/.test(inputValue) && Number(inputValue) > 0
                : /^\d+$/.test(inputValue) &&
                  Number(inputValue) >= 1 &&
                  Number(inputValue) <= 10000;
              const saveQuantity = () => {
                if (!validQuantity || disabled || busy) return;
                void run(line.id, () =>
                  onUpdate(
                    targetId,
                    measured ? { sale_quantity: inputValue } : { quantity: Number(inputValue) },
                  ),
                );
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
                          disabled={disabled || busy || line.quantity <= 1}
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
                        max={measured ? undefined : 10000}
                        value={inputValue}
                        disabled={disabled || busy}
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
                          disabled={disabled || busy || line.quantity >= 10000}
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
                          disabled={disabled || busy}
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
                      disabled={disabled || busy}
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
                          disabled={disabled || busy || !validQuantity}
                          onClick={saveQuantity}
                        >
                          {t('save')}
                        </button>
                      ) : null}
                      <button
                        className="remove-line"
                        type="button"
                        title={t('removeItem')}
                        aria-label={`${t('removeItem')} ${line.name}`}
                        disabled={disabled || busy}
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
