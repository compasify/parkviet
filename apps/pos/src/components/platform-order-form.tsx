import { formatMoney } from '@parkviet/pos-shared/money';
import {
  type Platform,
  platformKey,
  validPlatformOrderRef,
} from '@parkviet/pos-shared/platform-orders';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useMenu } from '../hooks/use-menu';
import type { PlatformEntry } from '../hooks/use-platform-orders';
import {
  draftLine,
  draftTotal,
  entryLines,
  lineValid,
  PLATFORM_MAX_LINES,
  PLATFORM_MAX_QUANTITY,
  type PlatformDraftLine,
  platformPriceValue,
} from '../lib/platform-order-draft';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { MenuGrid } from './menu-grid';
import { PosIcon } from './pos-icon';

// Typing in an order read off a platform's tablet: the platform, its order
// code and the driver's pickup code, then the dishes picked from the menu
// with their options, each with the platform's price beside the shop's. The
// order goes to the kitchen as soon as it is entered.
export function PlatformOrderForm({
  branchId,
  platforms,
  onSubmit,
  onClose,
}: {
  branchId: string | null;
  platforms: Platform[];
  onSubmit: (entry: PlatformEntry) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const menu = useMenu(branchId, true);
  const [platform, setPlatform] = useState<Platform | null>(platforms[0] ?? null);
  const [ref, setRef] = useState('');
  const [pickup, setPickup] = useState('');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<PlatformDraftLine[]>([]);
  const [message, setMessage] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const counter = useRef(0);
  const currency = menu.data?.currency ?? 'VND';
  const total = draftTotal(lines);
  const refValid = validPlatformOrderRef(ref);
  const ready =
    platform !== null &&
    refValid &&
    lines.length > 0 &&
    lines.length <= PLATFORM_MAX_LINES &&
    lines.every(lineValid);

  const update = (key: string, change: Partial<PlatformDraftLine>) =>
    setLines((current) =>
      current.map((line) => (line.key === key ? { ...line, ...change } : line)),
    );

  async function add(
    variantId: string,
    extra: { modifiers?: PlatformDraftLine['modifiers']; note?: string },
  ) {
    if (!menu.data) return;
    counter.current += 1;
    const line = draftLine(menu.data, variantId, extra, `line-${counter.current}`);
    if (line) setLines((current) => [...current, line]);
  }

  async function submit() {
    if (!platform || !ready) return;
    setSubmitting(true);
    setMessage('');
    try {
      await onSubmit({
        platform,
        platformOrderRef: ref,
        pickupCode: pickup,
        note,
        lines: entryLines(lines),
      });
      onClose();
    } catch (failure) {
      setMessage(platformFailure(failure, t));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="pos-popup-card platform-order-form"
        data-testid="platform-order-form"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('platformEnterTitle')}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <form
          className="platform-order-fields"
          onSubmit={(event) => {
            event.preventDefault();
            void submit();
          }}
        >
          <fieldset className="order-source-picker">
            <legend>{t('platformChoose')}</legend>
            {platforms.map((value) => (
              <button
                key={value}
                type="button"
                aria-pressed={platform === value}
                data-platform={value}
                onClick={() => setPlatform(value)}
              >
                {t(platformKey(value))}
              </button>
            ))}
          </fieldset>
          <label>
            {t('platformOrderRef')}
            <input
              value={ref}
              maxLength={64}
              required
              autoComplete="off"
              aria-invalid={ref !== '' && !refValid}
              data-testid="platform-order-ref"
              onChange={(event) => setRef(event.target.value)}
            />
          </label>
          <label>
            {t('platformPickupCode')}
            <input
              value={pickup}
              maxLength={32}
              autoComplete="off"
              data-testid="platform-pickup-code"
              onChange={(event) => setPickup(event.target.value)}
            />
          </label>
          <label>
            {t('platformNote')}
            <input
              value={note}
              maxLength={1000}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
          {lines.length === 0 ? (
            <p className="muted">{t('platformNoLines')}</p>
          ) : (
            <table className="platform-order-lines">
              <thead>
                <tr>
                  <th>{t('platformLineItem')}</th>
                  <th>{t('platformLineQuantity')}</th>
                  <th>{t('platformLineShopPrice')}</th>
                  <th>{t('platformLinePlatformPrice')}</th>
                  <th>
                    <span className="visually-hidden">{t('platformLineRemove')}</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {lines.map((line) => (
                  <tr key={line.key} data-testid="platform-line">
                    <td>
                      <strong>{line.name}</strong>
                      {line.modifierNames.length > 0 ? (
                        <small> · {line.modifierNames.join(', ')}</small>
                      ) : null}
                      {line.note ? <small> · {line.note}</small> : null}
                    </td>
                    <td>
                      <input
                        type="number"
                        min={1}
                        max={PLATFORM_MAX_QUANTITY}
                        step={1}
                        value={line.quantity}
                        aria-label={t('platformLineQuantityOf', { name: line.name })}
                        onChange={(event) =>
                          update(line.key, { quantity: Number(event.target.value) })
                        }
                      />
                    </td>
                    <td>{line.shopPrice ? formatMoney(line.shopPrice, currency) : '—'}</td>
                    <td>
                      <input
                        inputMode="numeric"
                        value={line.platformPrice}
                        placeholder={line.shopPrice ? String(Number(line.shopPrice)) : ''}
                        aria-label={t('platformLinePriceOf', { name: line.name })}
                        aria-invalid={platformPriceValue(line.platformPrice) === null}
                        data-testid="platform-line-price"
                        onChange={(event) =>
                          update(line.key, { platformPrice: event.target.value })
                        }
                      />
                    </td>
                    <td>
                      <button
                        type="button"
                        className="cell-edit-button"
                        aria-label={t('platformLineRemoveOf', { name: line.name })}
                        onClick={() =>
                          setLines((current) => current.filter((row) => row.key !== line.key))
                        }
                      >
                        <PosIcon name="close" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
          <p className="platform-order-total" data-testid="platform-order-total">
            {t('platformTotal')}: {total === null ? '—' : formatMoney(total, currency)}
          </p>
          {message ? (
            <p className="error" role="alert">
              {message}
            </p>
          ) : null}
          <div className="platform-order-form-actions">
            <button type="button" onClick={onClose}>
              {t('platformCancelEntry')}
            </button>
            <button
              type="submit"
              className="primary"
              disabled={!ready || submitting}
              data-testid="platform-order-submit"
            >
              {t('platformSubmit')}
            </button>
          </div>
        </form>
        <MenuGrid
          branchId={branchId}
          addDisabled={submitting || lines.length >= PLATFORM_MAX_LINES}
          canSetSoldOut={false}
          onAdd={add}
        />
      </div>
    </div>
  );
}

const PLATFORM_REASONS = [
  'platform_disabled',
  'platform_order_duplicate',
  'platform_item_not_menu',
  'platform_price_invalid',
  'platform_order_ref_invalid',
  'platform_order_empty',
  'platform_order_completed',
  'platform_order_canceled',
  'approval_required',
] as const;

// Why the server refused a platform order command, in the counter's words.
export function platformFailure(failure: unknown, t: (key: string) => string): string {
  const reason = conflictReason(failure);
  if (reason && (PLATFORM_REASONS as readonly string[]).includes(reason))
    return t(`platformFailure_${reason}`);
  return describeFailure(failure, t);
}
