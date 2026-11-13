import { formatMoney } from '@parkviet/pos-shared/money';
import { type ReactNode, useEffect, useId, useMemo, useRef, useState } from 'react';
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
import type {
  PosMenu,
  PosMenuItem,
  PosMenuModifierGroup,
  PosModifierSelection,
} from '../lib/pos-context';
import { PosIcon } from './pos-icon';

export const MENU_NOTE_LIMIT = 200;

export type ModifierSheetResult = {
  variantId: string;
  modifiers: PosModifierSelection[];
  note: string;
};

// The panel beside the ticket: required groups lead and show whether they
// are met, the add button names the group still missing, quick notes add to
// the note, and the placement (seat, course) sits at the bottom.
export type ModifierPanelOptions = { quickNotes: string[]; placement?: ReactNode };

// A required group the default picks leave empty comes first, then the other
// required groups, then the optional ones. The order stays put while picking.
function panelOrder(groups: PosMenuModifierGroup[], picks: MenuPicks) {
  const rank = (group: PosMenuModifierGroup) =>
    group.min_select === 0 ? 2 : groupProblem(group, picks) === 'min' ? 0 : 1;
  return [...groups].sort((left, right) => rank(left) - rank(right));
}

function priceDelta(amount: string, currency: string) {
  const value = Number(amount);
  if (!value) return '';
  return value > 0 ? `+${formatMoney(amount, currency)}` : formatMoney(amount, currency);
}

function splitNote(note: string) {
  return note
    .split(',')
    .map((part) => part.trim())
    .filter(Boolean);
}

// Size, option groups and a note. Required groups are marked and the add
// button waits until every group has enough picks. The price is an estimate;
// the line takes the price the server works out.
export function ModifierForm({
  menu,
  item,
  initial,
  editing = false,
  onSubmit,
  onDone,
  onBusyChange,
  panel,
}: {
  menu: PosMenu;
  item: PosMenuItem;
  // Picks of a line being edited; its size stays as sold.
  initial?: { variantId: string; picks: MenuPicks; note: string };
  editing?: boolean;
  onSubmit: (result: ModifierSheetResult) => Promise<unknown>;
  // Called once the submit went through.
  onDone: () => void;
  onBusyChange?: (busy: boolean) => void;
  panel?: ModifierPanelOptions;
}) {
  const { t } = useTranslation();
  const formId = useId();
  const listed = useMemo(() => itemGroups(menu, item), [menu, item]);
  const [startPicks] = useState<MenuPicks>(() => initial?.picks ?? defaultPicks(listed));
  const [picks, setPicks] = useState<MenuPicks>(startPicks);
  const groups = useMemo(
    () => (panel ? panelOrder(listed, startPicks) : listed),
    [panel, listed, startPicks],
  );
  const [variantId, setVariantId] = useState(initial?.variantId ?? item.variants[0]?.id ?? '');
  const [note, setNote] = useState(initial?.note ?? '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const variant = item.variants.find((row) => row.id === variantId) ?? item.variants[0];
  const ready = Boolean(variant) && picksReady(groups, picks) && note.length <= MENU_NOTE_LIMIT;
  const estimate = estimatePrice(variant?.price ?? null, groups, picks);
  const missing = groups.find((group) => groupProblem(group, picks) === 'min');
  const noted = splitNote(note);
  const busyChange = useRef(onBusyChange);
  busyChange.current = onBusyChange;
  useEffect(() => {
    busyChange.current?.(busy);
  }, [busy]);

  async function submit() {
    if (!ready || !variant || busy) return;
    setBusy(true);
    setError('');
    try {
      await onSubmit({ variantId: variant.id, modifiers: toSelections(picks), note: note.trim() });
      onDone();
    } catch (failure) {
      setError(describeMenuFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  // A quick note joins the note, or leaves it when tapped again.
  function toggleQuickNote(text: string) {
    setNote((current) => {
      const parts = splitNote(current);
      const next = parts.includes(text) ? parts.filter((part) => part !== text) : [...parts, text];
      return next.join(', ').slice(0, MENU_NOTE_LIMIT);
    });
  }

  const fields = (
    <>
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
              <label key={row.id} className="modifier-option" data-picked={row.id === variant?.id}>
                <input
                  type="radio"
                  name={`${formId}-size`}
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
        const required = group.min_select > 0;
        return (
          <fieldset
            key={group.id}
            className="modifier-group"
            disabled={busy}
            data-invalid={problem !== null}
          >
            <legend>
              {group.name}{' '}
              {required && panel ? (
                <span className="modifier-required" data-met={problem !== 'min'}>
                  <span aria-hidden="true">{problem === 'min' ? '✕' : '✓'}</span>{' '}
                  {t(problem === 'min' ? 'menuRequiredMissing' : 'menuRequired')}
                </span>
              ) : required ? (
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
                const delta = priceDelta(option.price_delta, menu.currency);
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
                      name={single ? `${formId}-${group.id}` : undefined}
                      checked={quantity > 0}
                      onChange={() => setPicks((current) => togglePick(group, current, option.id))}
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
      {panel && panel.quickNotes.length > 0 ? (
        <fieldset className="modifier-group modifier-quick-notes" disabled={busy}>
          <legend>
            {t('menuQuickNotes')} <small className="muted">{t('menuQuickNotesHint')}</small>
          </legend>
          <div className="modifier-options">
            {panel.quickNotes.map((text) => (
              <button
                key={text}
                type="button"
                className="modifier-option"
                aria-pressed={noted.includes(text)}
                data-picked={noted.includes(text)}
                onClick={() => toggleQuickNote(text)}
              >
                {text}
              </button>
            ))}
          </div>
        </fieldset>
      ) : null}
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
    </>
  );

  return (
    <form
      className={panel ? 'modifier-form-panel' : 'modifier-sheet-body'}
      onSubmit={(event) => {
        event.preventDefault();
        void submit();
      }}
    >
      {panel ? <div className="modifier-form-fields">{fields}</div> : fields}
      <div className="modifier-sheet-footer">
        {panel?.placement ? <div className="modifier-placement">{panel.placement}</div> : null}
        <span className="modifier-estimate" title={t('menuEstimateHint')}>
          {formatMoney(estimate, menu.currency)}
        </span>
        <button type="submit" className="primary" disabled={!ready || busy}>
          {panel && !editing && missing
            ? t('menuChooseToAdd', { group: missing.name })
            : t(editing ? 'menuSaveOptions' : 'menuAdd')}
        </button>
      </div>
    </form>
  );
}

// The modifier form as a popup over the selling screen.
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
  const [busy, setBusy] = useState(false);

  useModalFocus(card, () => {
    if (!busy) onClose();
  });

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
        <ModifierForm
          menu={menu}
          item={item}
          initial={initial}
          editing={editing}
          onSubmit={onSubmit}
          onDone={onClose}
          onBusyChange={setBusy}
        />
      </div>
    </div>
  );
}
