import { useTranslation } from 'react-i18next';
import type { PosMenu } from '../../lib/pos-context';

// The menu's categories down the left edge: each with its colour stripe and
// how many dishes it holds, "all" first.
export function CategoryRail({
  menu,
  value,
  onChange,
}: {
  menu: PosMenu;
  value: string | null;
  onChange: (categoryId: string | null) => void;
}) {
  const { t } = useTranslation();
  const counts = new Map<string, number>();
  for (const item of menu.items)
    if (item.menu_category_id)
      counts.set(item.menu_category_id, (counts.get(item.menu_category_id) ?? 0) + 1);
  const rows = [
    { id: null, name: t('menuAll'), color: null, count: menu.items.length },
    ...menu.categories.map((category) => ({
      id: category.id,
      name: category.name,
      color: category.color,
      count: counts.get(category.id) ?? 0,
    })),
  ];
  return (
    <nav className="category-rail" aria-label={t('menuCategories')}>
      {rows.map((row) => (
        <button
          key={row.id ?? 'all'}
          type="button"
          aria-pressed={value === row.id}
          style={row.color ? { borderLeftColor: row.color } : undefined}
          onClick={() => onChange(row.id)}
        >
          <span className="category-rail-name">{row.name}</span>
          <small>{t('menuDishCount', { count: row.count })}</small>
        </button>
      ))}
    </nav>
  );
}
