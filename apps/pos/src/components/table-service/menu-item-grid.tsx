import { formatMoney } from '@parkviet/pos-shared/money';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  MENU_DENSITIES,
  type MenuDensity,
  savedMenuDensity,
  saveMenuDensity,
} from '../../lib/menu-density';
import { addsInOneTap, visibleItems } from '../../lib/menu-selection';
import type { PosMenu, PosMenuItem } from '../../lib/pos-context';
import { popupOpen, typingTarget } from '../menu-grid';
import { PosIcon } from '../pos-icon';

const DENSITY_LABELS: Record<MenuDensity, string> = {
  airy: 'menuDensityAiry',
  regular: 'menuDensityRegular',
  dense: 'menuDensityDense',
};

// The dishes of the order screen as text tiles: the search box (`/` jumps
// to it), the density of this device, and per dish its category stripe, its
// price, how many the open order already has, and a dimmed "sold out".
export function MenuItemGrid({
  menu,
  categoryId,
  quantities,
  disabled,
  disabledReason,
  canSetSoldOut,
  onPick,
  onToggleSoldOut,
}: {
  menu: PosMenu;
  // Search looks through every category.
  categoryId: string | null;
  // Units of each dish (by item id) on the open order.
  quantities: ReadonlyMap<string, number>;
  disabled: boolean;
  disabledReason?: string;
  canSetSoldOut: boolean;
  onPick: (item: PosMenuItem) => void;
  onToggleSoldOut: (item: PosMenuItem) => void;
}) {
  const { t } = useTranslation();
  const [query, setQuery] = useState('');
  const [density, setDensity] = useState<MenuDensity>(savedMenuDensity);
  const searchRef = useRef<HTMLInputElement>(null);
  const items = visibleItems(menu, query.trim() ? null : categoryId, query);
  const colors = new Map(menu.categories.map((category) => [category.id, category.color]));

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key !== '/' || event.ctrlKey || event.metaKey || event.altKey) return;
      if (typingTarget(event.target) || popupOpen()) return;
      event.preventDefault();
      searchRef.current?.focus();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  return (
    <div className="menu-item-area">
      <div className="menu-item-top">
        <div className="search-input-wrap menu-item-search">
          <PosIcon name="search" />
          <input
            ref={searchRef}
            type="search"
            value={query}
            aria-label={t('menuSearchDish')}
            placeholder={t('menuSearchDish')}
            aria-keyshortcuts="/"
            onChange={(event) => setQuery(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Escape' && query) {
                event.preventDefault();
                setQuery('');
                return;
              }
              if (event.key !== 'Enter') return;
              event.preventDefault();
              const only = items.length === 1 ? items[0] : undefined;
              if (only && !disabled) onPick(only);
            }}
          />
          <kbd>/</kbd>
        </div>
        <fieldset className="menu-density">
          <legend className="visually-hidden">{t('menuDensity')}</legend>
          {MENU_DENSITIES.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={density === value}
              onClick={() => {
                setDensity(value);
                saveMenuDensity(value);
              }}
            >
              {t(DENSITY_LABELS[value])}
            </button>
          ))}
        </fieldset>
      </div>
      {disabled && disabledReason ? (
        <p className="muted" role="status">
          {disabledReason}
        </p>
      ) : null}
      {items.length === 0 ? <p className="muted menu-item-empty">{t('menuEmpty')}</p> : null}
      <ul className="menu-items" data-density={density} aria-label={t('menuTitle')}>
        {items.map((item) => {
          const price = item.variants.map((variant) => variant.price).find((row) => row !== null);
          const quantity = quantities.get(item.id) ?? 0;
          const color = item.menu_category_id ? colors.get(item.menu_category_id) : null;
          return (
            <li
              key={item.id}
              className="menu-item"
              data-sold-out={item.sold_out}
              style={color ? { borderTopColor: color } : undefined}
            >
              <button
                type="button"
                className="menu-item-pick"
                disabled={disabled || item.sold_out}
                title={item.sold_out ? t('menuSoldOut') : disabledReason}
                aria-label={item.sold_out ? `${item.name} · ${t('menuSoldOutTile')}` : item.name}
                aria-description={quantity > 0 ? t('menuInOrder', { count: quantity }) : undefined}
                onClick={() => onPick(item)}
              >
                <strong className="menu-item-name">{item.name}</strong>
                <span className="menu-item-price">
                  {item.sold_out
                    ? t('menuSoldOutTile')
                    : `${price ? formatMoney(price, menu.currency) : '—'}${item.variants.length > 1 ? '+' : ''}`}
                </span>
                {!item.sold_out && !addsInOneTap(menu, item) ? (
                  <small className="menu-item-options">{t('menuHasOptions')}</small>
                ) : null}
              </button>
              {quantity > 0 ? (
                <span className="menu-item-quantity" aria-hidden="true">
                  {quantity}
                </span>
              ) : null}
              {canSetSoldOut ? (
                <button
                  type="button"
                  className="menu-item-sold-out-toggle"
                  aria-label={`${t(item.sold_out ? 'menuBackOnSale' : 'menuMarkSoldOut')}: ${item.name}`}
                  onClick={() => onToggleSoldOut(item)}
                >
                  {t(item.sold_out ? 'menuBackOnSale' : 'menuMarkSoldOut')}
                </button>
              ) : null}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
