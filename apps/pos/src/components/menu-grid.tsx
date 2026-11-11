import { formatMoney } from '@parkviet/pos-shared/money';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useMenu, useSoldOutToggle } from '../hooks/use-menu';
import {
  addsInOneTap,
  describeMenuFailure,
  favoriteItems,
  visibleItems,
} from '../lib/menu-selection';
import type { PosMenu, PosMenuItem, PosModifierSelection } from '../lib/pos-context';
import { ModifierSheet } from './modifier-sheet';
import { PosIcon } from './pos-icon';

export type MenuAdd = (
  variantId: string,
  extra: { modifiers?: PosModifierSelection[]; note?: string; merge: boolean },
) => Promise<unknown>;

// Favourites answer the number keys 1-9 while no field has focus.
const FAVORITE_KEYS = 9;
// How long a favourite key waits for a following key that would make it part of a scan.
const SCAN_GAP_MS = 150;

function typingTarget(target: EventTarget | null) {
  return (
    target instanceof HTMLElement &&
    (target.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(target.tagName))
  );
}

// Line editors keep their popup inside a closed <details>, so only a popup
// outside a closed <details> counts as open.
function popupOpen() {
  return Array.from(document.querySelectorAll('.pos-popup-backdrop')).some(
    (node) => !node.closest('details:not([open])'),
  );
}

// The selling surface of a branch running the menu: category tabs, picture
// tiles with the current price and a sold-out mark, a favourites row and a
// quick search. A tile with sizes or options opens the modifier sheet.
export function MenuGrid({
  branchId,
  addDisabled,
  addDisabledReason,
  canSetSoldOut,
  onAdd,
}: {
  branchId: string | null;
  addDisabled: boolean;
  addDisabledReason?: string;
  canSetSoldOut: boolean;
  onAdd?: MenuAdd;
}) {
  const { t } = useTranslation();
  const menu = useMenu(branchId, true);
  const setSoldOut = useSoldOutToggle(branchId);
  const [categoryId, setCategoryId] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [sheetItem, setSheetItem] = useState<PosMenuItem | null>(null);
  const [notice, setNotice] = useState('');
  const searchRef = useRef<HTMLInputElement>(null);
  const data = menu.data;

  async function pick(item: PosMenuItem) {
    if (!data || !onAdd || addDisabled) return;
    setNotice('');
    if (item.sold_out) {
      setNotice(t('menuFailure_menu_item_sold_out'));
      return;
    }
    const variant = item.variants[0];
    if (!addsInOneTap(data, item) || !variant) {
      setSheetItem(item);
      return;
    }
    try {
      await onAdd(variant.id, { merge: true });
    } catch (failure) {
      setNotice(describeMenuFailure(failure, t));
    }
  }

  const pickRef = useRef(pick);
  pickRef.current = pick;
  const favorites = data ? favoriteItems(data) : [];
  const favoritesRef = useRef(favorites);
  favoritesRef.current = favorites;

  useEffect(() => {
    let pending: ReturnType<typeof setTimeout> | undefined;
    const cancel = () => {
      clearTimeout(pending);
      pending = undefined;
    };
    const onKey = (event: KeyboardEvent) => {
      // A scanner types digits faster than a hand: any key soon after a
      // digit means the digits were a scan, so no favourite is added.
      if (pending) {
        cancel();
        return;
      }
      if (event.key === 'F2') {
        event.preventDefault();
        searchRef.current?.focus();
        return;
      }
      if (event.ctrlKey || event.metaKey || event.altKey || typingTarget(event.target)) return;
      if (popupOpen()) return;
      const index = Number(event.key) - 1;
      if (!Number.isInteger(index) || index < 0 || index >= FAVORITE_KEYS) return;
      const item = favoritesRef.current[index];
      if (!item) return;
      pending = setTimeout(() => {
        pending = undefined;
        void pickRef.current(item);
      }, SCAN_GAP_MS);
    };
    window.addEventListener('keydown', onKey);
    return () => {
      cancel();
      window.removeEventListener('keydown', onKey);
    };
  }, []);

  async function toggleSoldOut(item: PosMenuItem) {
    setNotice('');
    try {
      await setSoldOut(item.id, !item.sold_out);
    } catch (failure) {
      setNotice(describeMenuFailure(failure, t));
    }
  }

  const items = data ? visibleItems(data, categoryId, query) : [];

  return (
    <div className="selling-search menu-grid">
      <div className="catalog-heading">
        <h3>
          {t('menuTitle')}{' '}
          {data ? <span className="catalog-count">{data.items.length}</span> : null}
        </h3>
        <div className="search-input-wrap">
          <PosIcon name="search" />
          <input
            ref={searchRef}
            type="search"
            value={query}
            aria-label={t('menuSearch')}
            placeholder={t('menuSearch')}
            onChange={(event) => setQuery(event.target.value)}
            onKeyDown={(event) => {
              if (event.key !== 'Enter') return;
              event.preventDefault();
              const only = items.length === 1 ? items[0] : undefined;
              if (only) void pick(only);
            }}
          />
        </div>
      </div>
      {menu.isPending ? <p className="muted">{t('menuLoading')}</p> : null}
      {menu.isError ? (
        <p className="error" role="alert">
          {describeMenuFailure(menu.error, t)}{' '}
          <button type="button" onClick={() => void menu.refetch()}>
            {t('menuRetry')}
          </button>
        </p>
      ) : null}
      {notice ? (
        <p className="workspace-hint" role="alert">
          {notice}
        </p>
      ) : null}
      {addDisabled && addDisabledReason ? (
        <p className="muted" role="status">
          {addDisabledReason}
        </p>
      ) : null}
      {data && favorites.length > 0 ? (
        <section className="menu-favorites" aria-label={t('menuFavorites')}>
          {favorites.map((item, index) => (
            <button
              key={item.id}
              type="button"
              className="menu-favorite"
              data-sold-out={item.sold_out}
              disabled={addDisabled || !onAdd}
              title={addDisabledReason}
              onClick={() => void pick(item)}
            >
              {index < FAVORITE_KEYS ? <kbd>{index + 1}</kbd> : null}
              <span>{item.name}</span>
            </button>
          ))}
        </section>
      ) : null}
      {data ? (
        <div className="menu-tabs" role="tablist" aria-label={t('menuCategories')}>
          <button
            type="button"
            role="tab"
            aria-selected={categoryId === null}
            onClick={() => setCategoryId(null)}
          >
            {t('menuAll')}
          </button>
          {data.categories.map((category) => (
            <button
              key={category.id}
              type="button"
              role="tab"
              aria-selected={categoryId === category.id}
              style={category.color ? { borderColor: category.color } : undefined}
              onClick={() => setCategoryId(category.id)}
            >
              {category.name}
            </button>
          ))}
        </div>
      ) : null}
      {data && items.length === 0 ? <p className="muted">{t('menuEmpty')}</p> : null}
      {data ? (
        <ul className="menu-tiles" aria-label={t('menuTitle')}>
          {items.map((item) => (
            <MenuTile
              key={item.id}
              item={item}
              menu={data}
              disabled={addDisabled || !onAdd}
              disabledReason={addDisabledReason}
              canSetSoldOut={canSetSoldOut}
              onPick={() => void pick(item)}
              onToggleSoldOut={() => void toggleSoldOut(item)}
            />
          ))}
        </ul>
      ) : null}
      {data && sheetItem && onAdd ? (
        <ModifierSheet
          menu={data}
          item={sheetItem}
          onSubmit={(result) =>
            onAdd(result.variantId, {
              modifiers: result.modifiers,
              note: result.note || undefined,
              merge: true,
            })
          }
          onClose={() => setSheetItem(null)}
        />
      ) : null}
    </div>
  );
}

function MenuTile({
  item,
  menu,
  disabled,
  disabledReason,
  canSetSoldOut,
  onPick,
  onToggleSoldOut,
}: {
  item: PosMenuItem;
  menu: PosMenu;
  disabled: boolean;
  disabledReason?: string;
  canSetSoldOut: boolean;
  onPick: () => void;
  onToggleSoldOut: () => void;
}) {
  const { t } = useTranslation();
  const prices = item.variants.map((variant) => variant.price).filter((price) => price !== null);
  const scheduled = item.variants.some(
    (variant) => variant.schedule_id && variant.price !== variant.list_price,
  );
  return (
    <li className="menu-tile" data-sold-out={item.sold_out}>
      <button
        type="button"
        className="menu-tile-pick"
        disabled={disabled || item.sold_out}
        title={item.sold_out ? t('menuSoldOut') : disabledReason}
        aria-label={item.sold_out ? `${item.name} · ${t('menuSoldOut')}` : item.name}
        onClick={onPick}
      >
        {item.image_url ? (
          <img src={item.image_url} alt="" loading="lazy" />
        ) : (
          <span className="menu-tile-placeholder" aria-hidden="true">
            {item.name.slice(0, 1)}
          </span>
        )}
        <strong>{item.name}</strong>
        <span className="menu-tile-price">
          {prices[0] ? formatMoney(prices[0], menu.currency) : '—'}
          {prices.length > 1 ? '+' : ''}
          {scheduled ? (
            <small className="menu-tile-schedule">{t('menuScheduledPrice')}</small>
          ) : null}
        </span>
        {item.sold_out ? <span className="menu-tile-sold-out">{t('menuSoldOutShort')}</span> : null}
      </button>
      {canSetSoldOut ? (
        <button type="button" className="menu-tile-sold-out-toggle" onClick={onToggleSoldOut}>
          {t(item.sold_out ? 'menuBackOnSale' : 'menuMarkSoldOut')}
        </button>
      ) : null}
    </li>
  );
}
