import type { ResourceBoard } from '@parkviet/pos-shared/tables';
import type { OpenTab } from '../hooks/use-tabs';
import { fold } from './menu-selection';
import { tableOrderName } from './tables';

// One open order in the bar's column: a named tab or an order at a table.
export type TabColumnRow = {
  id: string;
  kind: 'tab' | 'table';
  // The guest's name, or the table and the order's letter.
  name: string;
  // The table's area; null for a tab.
  place: string | null;
  orderNumber: number | null;
  openedAt: string | null;
  total: string;
  unsent: number | null;
  // The table asked for the bill; a tab has no table, so never.
  paymentRequested: boolean;
};

// What a row is found by.
export type SearchableRow = { name: string; place: string | null; orderNumber: number | null };

// The rows a bartender's typing finds: the name or the area, accents and case
// not mattering ("tuan" finds "Anh Tuấn"), or the call number.
export function searchTabs<T extends SearchableRow>(rows: readonly T[], query: string): T[] {
  const wanted = fold(query);
  if (!wanted) return [...rows];
  return rows.filter(
    (row) =>
      fold(row.name).includes(wanted) ||
      (row.place !== null && fold(row.place).includes(wanted)) ||
      (row.orderNumber !== null && String(row.orderNumber) === wanted),
  );
}

function openedTime(row: TabColumnRow): number {
  if (!row.openedAt) return Number.NEGATIVE_INFINITY;
  const at = Date.parse(row.openedAt);
  return Number.isNaN(at) ? Number.NEGATIVE_INFINITY : at;
}

// The column's rows: the open tabs and the orders open at the tables, once
// each, newest first; a row without an opening time goes last.
export function tabColumnRows(
  tabs: readonly OpenTab[],
  board: ResourceBoard | undefined,
): TabColumnRow[] {
  const rows = new Map<string, TabColumnRow>();
  for (const tab of tabs) {
    if (rows.has(tab.id)) continue;
    rows.set(tab.id, {
      id: tab.id,
      kind: 'tab',
      name: tab.tabName,
      place: tab.table,
      orderNumber: tab.orderNumber,
      openedAt: tab.openedAt,
      total: tab.total,
      unsent: tab.unsent,
      paymentRequested: false,
    });
  }
  const areas = new Map((board?.areas ?? []).map((area) => [area.id, area.name]));
  for (const table of board?.resources ?? []) {
    for (const order of table.orders) {
      if (rows.has(order.id)) continue;
      rows.set(order.id, {
        id: order.id,
        kind: 'table',
        name: tableOrderName(table.name, order.table_label),
        place: (table.area_id && areas.get(table.area_id)) || null,
        orderNumber: null,
        openedAt: order.opened_at,
        total: order.total,
        unsent: order.unsent_kitchen_items,
        paymentRequested: order.payment_requested,
      });
    }
  }
  return [...rows.values()].sort((a, b) => {
    const later = openedTime(b);
    const earlier = openedTime(a);
    return later === earlier ? 0 : later > earlier ? 1 : -1;
  });
}
