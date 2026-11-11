import { formatMoney } from '@parkviet/pos-shared/money';
import { useId, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import {
  defaultPicks,
  describeMenuFailure,
  estimatePrice,
  groupCount,
  groupProblem,
  itemGroups,
  MAX_OPTION_QUANTITY,
  type MenuPicks,
  picksReady,
  stepPick,
  togglePick,
  toSelections,
} from '../lib/menu-selection';
import type { PosMenu, PosMenuItem, PosModifierSelection } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

export const MENU_NOTE_LIMIT = 200;

export type ModifierSheetResult = {
  variantId: string;
  modifiers: PosModifierSelection[];
  note: string;
};

// Size, option groups and a note on one screen. Required groups are marked
// and the add button waits until every group has enough picks. The price is
// an estimate; the line takes the price the server works out.
export function ModifierSheet({
  menu,
  item,
  initial,
  editing = false,
  onSubmit,
  onClose,
}: {
  menu: PosMenu;
  item: PosMenuItem;
  // Picks of a line being edited; its size stays as sold.
  initial?: { variantId: string; picks: MenuPicks; note: string };
  editing?: boolean;
  onSubmit: (result: ModifierSheetResult) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const groups = useMemo(() => itemGroups(menu, item), [menu, item]);
  const [variantId, setVariantId] = useState(initial?.variantId ?? item.variants[0]?.id ?? '');
  const [picks, setPicks] = useState<MenuPicks>(() => initial?.picks ?? defaultPicks(groups));
  const [note, setNote] = useState(initial?.note ?? '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const variant = item.variants.find((row) => row.id === variantId) ?? item.variants[0];
  const ready = Boolean(variant) && picksReady(groups, picks) && note.length <= MENU_NOTE_LIMIT;
  const estimate = estimatePrice(variant?.price ?? null, groups, picks);

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

  async function submit() {
    if (!ready || !variant || busy) return;
    setBusy(true);
    setError('');
    try {
      await onSubmit({ variantId: variant.id, modifiers: toSelections(picks), note: note.trim() });
      onClose();
    } catch (failure) {
      setError(describeMenuFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card modifier-sheet"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{item.name}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            disabled={busy}
            aria-label={t('menuSheetClose')}
            title={t('menuSheetClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <form
          className="modifier-sheet-body"
          onSubmit={(event) => {
            event.preventDefault();
            void submit();
          }}
        >
          {item.components.length > 0 ? (
            <p className="muted modifier-components">
              {item.components.map((row) => `${row.name} ×${row.quantity}`).join(' · ')}
            </p>
          ) : null}
          {item.variants.length > 1 ? (
            <fieldset className="modifier-group" disabled={editing || busy}>
              <legend>{t('menuSize')}</legend>
              <div className="modifier-options">
                {item.variants.map((row) => (
                  <label
                    key={row.id}
                    className="modifier-option"
                    data-picked={row.id === variant?.id}
                  >
                    <input
                      type="radio"
                      name={`${titleId}-size`}
                      checked={row.id === variant?.id}
                      onChange={() => setVariantId(row.id)}
                    />
                    <span>{row.name ?? item.name}</span>
                    <small>{formatMoney(row.price, menu.currency)}</small>
                  </label>
                ))}
              </div>
              {editing ? <p className="muted">{t('menuSizeLocked')}</p> : null}
            </fieldset>
          ) : null}
          {groups.map((group) => {
            const problem = groupProblem(group, picks);
            const single = group.max_select === 1 && !group.allow_quantity;
            return (
              <fieldset
                key={group.id}
                className="modifier-group"
                disabled={busy}
                data-invalid={problem !== null}
              >
                <legend>
                  {group.name}{' '}
                  {group.min_select > 0 ? (
                    <span className="modifier-required">{t('menuRequired')}</span>
                  ) : null}
                  <small className="muted">
                    {t('menuGroupRange', {
                      min: group.min_select,
                      max: group.max_select,
                      picked: groupCount(group, picks),
                    })}
                  </small>
                </legend>
                <div className="modifier-options">
                  {group.options.map((option) => {
                    const quantity = picks[option.id] ?? 0;
                    const delta =
                      option.price_delta !== '0' && option.price_delta !== '0.0'
                        ? `+${formatMoney(option.price_delta, menu.currency)}`
                        : '';
                    if (group.allow_quantity)
                      return (
                        <div key={option.id} className="modifier-option" data-picked={quantity > 0}>
                          <span>{option.name}</span>
                          {delta ? <small>{delta}</small> : null}
                          <span className="quantity-control">
                            <button
                              type="button"
                              aria-label={t('decreaseQuantity', { name: option.name })}
                              disabled={quantity === 0}
                              onClick={() =>
                                setPicks((current) => stepPick(group, current, option.id, -1))
                              }
                            >
                              <PosIcon name="minus" />
                            </button>
                            <output aria-live="polite">{quantity}</output>
                            <button
                              type="button"
                              aria-label={t('increaseQuantity', { name: option.name })}
                              disabled={quantity >= MAX_OPTION_QUANTITY}
                              onClick={() =>
                                setPicks((current) => stepPick(group, current, option.id, 1))
                              }
                            >
                              <PosIcon name="plus" />
                            </button>
                          </span>
                        </div>
                      );
                    return (
                      <label key={option.id} className="modifier-option" data-picked={quantity > 0}>
                        <input
                          type={single ? 'radio' : 'checkbox'}
                          name={single ? `${titleId}-${group.id}` : undefined}
                          checked={quantity > 0}
                          onChange={() =>
                            setPicks((current) => togglePick(group, current, option.id))
                          }
                          onClick={(event) => {
                            // A radio cannot be unticked by itself; an optional
                            // single choice may be cleared by tapping it again.
                            if (single && quantity > 0 && group.min_select === 0) {
                              event.preventDefault();
                              setPicks((current) => togglePick(group, current, option.id));
                            }
                          }}
                        />
                        <span>{option.name}</span>
                        {delta ? <small>{delta}</small> : null}
                      </label>
                    );
                  })}
                </div>
                {problem === 'min' ? (
                  <p className="muted" role="status">
                    {t('menuGroupMin', { min: group.min_select })}
                  </p>
                ) : null}
              </fieldset>
            );
          })}
          <label className="modifier-note">
            <span>{t('menuNote')}</span>
            <textarea
              value={note}
              maxLength={MENU_NOTE_LIMIT}
              rows={2}
              disabled={busy}
              placeholder={t('menuNotePlaceholder')}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <div className="modifier-sheet-footer">
            <span className="modifier-estimate" title={t('menuEstimateHint')}>
              {formatMoney(estimate, menu.currency)}
            </span>
            <button type="submit" className="primary" disabled={!ready || busy}>
              {t(editing ? 'menuSaveOptions' : 'menuAdd')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
