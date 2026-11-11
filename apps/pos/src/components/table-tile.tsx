import { formatMoney } from '@parkviet/pos-shared/money';
import { type BoardTable, tableStateKey } from '@parkviet/pos-shared/tables';
import type { CSSProperties } from 'react';
import { useTranslation } from 'react-i18next';

// One table on the floor, as a tile in the grid or a shape on the plan. The
// state is always written out beside its colour.
export function TableTile({
  table,
  selected,
  onSelect,
  style,
}: {
  table: BoardTable;
  selected: boolean;
  onSelect: (table: BoardTable) => void;
  style?: CSSProperties;
}) {
  const { t } = useTranslation();
  const state = t(tableStateKey(table.state));
  return (
    <button
      type="button"
      className={`table-tile table-tile-${table.state} table-shape-${table.shape}`}
      data-state={table.state}
      data-table-id={table.id}
      aria-pressed={selected}
      aria-label={`${table.name} · ${state}`}
      style={style}
      onClick={() => onSelect(table)}
    >
      <strong className="table-tile-name">{table.name}</strong>
      <span className="table-tile-state">{state}</span>
      {table.orders.length > 0 ? (
        <span className="table-tile-meta">
          {table.guest_count != null ? (
            <span>{t('tableGuests', { count: table.guest_count })}</span>
          ) : null}
          {table.seated_minutes != null ? (
            <span>{t('tableSeatedMinutes', { count: table.seated_minutes })}</span>
          ) : null}
          {table.orders.length > 1 ? (
            <span>{t('tableOrderCount', { count: table.orders.length })}</span>
          ) : null}
        </span>
      ) : (
        <span className="table-tile-meta">{t('tableCapacity', { count: table.capacity })}</span>
      )}
      {table.subtotal != null && table.orders.length > 0 ? (
        <span className="table-tile-total">
          {formatMoney(table.subtotal, table.currency ?? 'VND')}
        </span>
      ) : null}
      {table.edited_after_prebill ? (
        <span className="table-tile-flag">{t('tableEditedAfterPrebill')}</span>
      ) : null}
    </button>
  );
}
