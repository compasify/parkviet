import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney } from '../lib/money';
import type { GuestMenu, MenuItem } from '../lib/types';

// The menu by category; a sold-out dish stays listed but cannot be opened.
export function MenuScreen({
  menu,
  onPick,
}: {
  menu: GuestMenu;
  onPick: (item: MenuItem) => void;
}) {
  const { t, i18n } = useTranslation();
  const [categoryId, setCategoryId] = useState<string | null>(null);
  const categories = [...menu.categories].sort((a, b) => a.position - b.position);
  const items = menu.items
    .filter((item) => !categoryId || item.menu_category_id === categoryId)
    .sort((a, b) => a.position - b.position);

  if (menu.items.length === 0) return <p className="muted">{t('menuEmpty')}</p>;

  return (
    <section aria-label={t('tabMenu')}>
      {categories.length > 1 ? (
        <nav className="chips" aria-label={t('tabMenu')}>
          <button
            type="button"
            aria-pressed={categoryId === null}
            onClick={() => setCategoryId(null)}
          >
            {t('allCategories')}
          </button>
          {categories.map((category) => (
            <button
              key={category.id}
              type="button"
              aria-pressed={categoryId === category.id}
              onClick={() => setCategoryId(category.id)}
            >
              {category.name}
            </button>
          ))}
        </nav>
      ) : null}
      <ul className="menu-items">
        {items.map((item) => {
          const prices = item.variants.map((variant) => Number(variant.price));
          const from = item.variants.find(
            (variant) => Number(variant.price) === Math.min(...prices),
          );
          return (
            <li key={item.id}>
              <button
                type="button"
                className="menu-item"
                disabled={item.sold_out}
                data-testid={`menu-item-${item.id}`}
                onClick={() => onPick(item)}
              >
                {item.image_url ? (
                  <img src={item.image_url} alt="" loading="lazy" referrerPolicy="no-referrer" />
                ) : null}
                <span className="menu-item-text">
                  <strong>{item.name}</strong>
                  {item.components.length > 0 ? (
                    <small>
                      {t('combo', {
                        items: item.components
                          .map((part) => `${part.quantity} ${part.name}`)
                          .join(', '),
                      })}
                    </small>
                  ) : null}
                  <span className="price">
                    {item.sold_out
                      ? t('soldOut')
                      : formatMoney(from?.price, menu.currency, i18n.language)}
                  </span>
                </span>
              </button>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
