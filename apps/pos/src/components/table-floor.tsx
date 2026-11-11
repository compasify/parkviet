import { formatMoney } from '@parkviet/pos-shared/money';
import { type PosTableSurface, TABLE_SURFACES } from '@parkviet/pos-shared/pos-modules';
import {
  type BoardTable,
  countStates,
  filterTables,
  type ManualStatus,
  TABLE_STATES,
  type TableState,
  tableStateKey,
} from '@parkviet/pos-shared/tables';
import { type CSSProperties, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard, useTableCommands } from '../hooks/use-resource-board';
import { posFailureKey } from '../lib/request-failure';
import { describeTableFailure, saveTableSurface } from '../lib/tables';
import { TableTile } from './table-tile';

type StateFilter = TableState | 'open' | null;

const MAX_GUESTS = 999;

// The floor of the branch: tables as tiles (`table_grid`) or drawn on their
// area's plan (`floor_plan`), filtered by area and state. Picking a table
// shows what can be done with it: seat guests, open one of its orders for
// selling, add another order, or mark it being cleaned.
export function TableFloor({
  branchId,
  surface,
  onSurface,
  canServe,
  locked,
  onOpenTable,
  onSelectOrder,
}: {
  branchId: string | null;
  surface: PosTableSurface;
  onSurface: (surface: PosTableSurface) => void;
  canServe: boolean;
  locked: boolean;
  onOpenTable: (
    table: BoardTable,
    input: { guestCount: number | null; addOrder: boolean },
  ) => Promise<unknown>;
  onSelectOrder: (workspaceId: string) => void;
}) {
  const { t } = useTranslation();
  const board = useResourceBoard(branchId, true);
  const commands = useTableCommands(branchId);
  const [areaId, setAreaId] = useState<string | null>(null);
  const [stateFilter, setStateFilter] = useState<StateFilter>(null);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [guests, setGuests] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const areas = board.data?.areas ?? [];
  const tables = board.data?.resources ?? [];
  // The plan draws one area at a time: the one picked, else the first.
  const planArea =
    surface === 'floor_plan' ? (areas.find((row) => row.id === areaId) ?? areas[0] ?? null) : null;
  const shownAreaId = planArea?.id ?? areaId;
  const inArea = filterTables(tables, { areaId: shownAreaId });
  const shown = filterTables(inArea, { state: stateFilter });
  const counts = countStates(inArea);
  const openCount = inArea.filter((row) => row.orders.length > 0).length;
  const selected = tables.find((row) => row.id === selectedId) ?? null;

  const guestCount = (): number | null | 'invalid' => {
    const raw = guests.trim();
    if (!raw) return null;
    const value = Number(raw);
    return Number.isInteger(value) && value >= 0 && value <= MAX_GUESTS ? value : 'invalid';
  };

  async function act(action: () => Promise<unknown>) {
    if (busy) return;
    setBusy(true);
    setError('');
    try {
      await action();
    } catch (failure) {
      setError(describeTableFailure(failure, t));
      void commands.refreshBoard();
    } finally {
      setBusy(false);
    }
  }

  function open(table: BoardTable, addOrder: boolean) {
    const count = guestCount();
    if (count === 'invalid') {
      setError(t('tableGuestCountInvalid', { max: MAX_GUESTS }));
      return;
    }
    void act(async () => {
      await onOpenTable(table, { guestCount: count, addOrder });
      setGuests('');
    });
  }

  function mark(table: BoardTable, status: ManualStatus) {
    void act(() => commands.setManualStatus(table.id, status));
  }

  const filters: Array<{ value: StateFilter; label: string; count: number }> = [
    { value: null, label: t('tableFilterAll'), count: inArea.length },
    { value: 'open', label: t('tableFilterOpen'), count: openCount },
    ...TABLE_STATES.filter((state) => counts[state] > 0 || stateFilter === state).map((state) => ({
      value: state,
      label: t(tableStateKey(state)),
      count: counts[state],
    })),
  ];

  const tile = (table: BoardTable, style?: CSSProperties) => (
    <TableTile
      table={table}
      selected={table.id === selectedId}
      style={style}
      onSelect={(row) => {
        setSelectedId(row.id);
        setError('');
      }}
    />
  );

  return (
    <section className="table-floor" aria-label={t('tableFloorTitle')}>
      <div className="table-floor-bar">
        <fieldset className="table-floor-areas">
          <legend className="visually-hidden">{t('tableAreas')}</legend>
          {surface === 'table_grid' ? (
            <button type="button" aria-pressed={areaId === null} onClick={() => setAreaId(null)}>
              {t('tableAreasAll')}
            </button>
          ) : null}
          {areas.map((area) => (
            <button
              key={area.id}
              type="button"
              aria-pressed={shownAreaId === area.id}
              onClick={() => setAreaId(area.id)}
            >
              {area.name}
            </button>
          ))}
        </fieldset>
        <fieldset className="table-floor-surface">
          <legend className="visually-hidden">{t('tableSurface')}</legend>
          {TABLE_SURFACES.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={surface === value}
              onClick={() => {
                saveTableSurface(value);
                onSurface(value);
              }}
            >
              {t(`tableSurface_${value}`)}
            </button>
          ))}
        </fieldset>
      </div>
      <fieldset className="table-floor-states">
        <legend className="visually-hidden">{t('tableStateFilter')}</legend>
        {filters.map((filter) => (
          <button
            key={filter.value ?? 'all'}
            type="button"
            className={filter.value ? `table-filter-${filter.value}` : undefined}
            aria-pressed={stateFilter === filter.value}
            onClick={() => setStateFilter(filter.value)}
          >
            {filter.label} <span className="table-filter-count">{filter.count}</span>
          </button>
        ))}
      </fieldset>
      {board.isLoading ? <p role="status">{t('tableFloorLoading')}</p> : null}
      {board.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(board.error))}
        </p>
      ) : null}
      {board.isSuccess && tables.length === 0 ? (
        <div className="empty">
          <strong>{t('tableFloorEmpty')}</strong>
          <p>{t('tableFloorEmptyHint')}</p>
        </div>
      ) : null}
      <div className="table-floor-body">
        {surface === 'floor_plan' && planArea ? (
          <fieldset
            className="floor-plan"
            aria-label={planArea.name}
            style={{
              gridTemplateColumns: `repeat(${planArea.floor_width}, minmax(0, 1fr))`,
              gridTemplateRows: `repeat(${planArea.floor_height}, minmax(24px, 1fr))`,
              aspectRatio: `${planArea.floor_width} / ${planArea.floor_height}`,
            }}
          >
            {shown.map((table) => (
              <div
                key={table.id}
                className="floor-plan-cell"
                style={{
                  gridColumn: `${table.x + 1} / span ${table.w}`,
                  gridRow: `${table.y + 1} / span ${table.h}`,
                }}
              >
                {tile(
                  table,
                  table.rotation ? { transform: `rotate(${table.rotation}deg)` } : undefined,
                )}
              </div>
            ))}
          </fieldset>
        ) : (
          <ul className="table-grid" aria-label={t('tableFloorTitle')}>
            {shown.map((table) => (
              <li key={table.id}>{tile(table)}</li>
            ))}
          </ul>
        )}
        {selected ? (
          <aside className="table-panel" aria-label={selected.name}>
            <div className="table-panel-heading">
              <h2>{selected.name}</h2>
              <span className={`table-state-badge table-tile-${selected.state}`}>
                {t(tableStateKey(selected.state))}
              </span>
            </div>
            <p className="muted">
              {t('tableCapacity', { count: selected.capacity })}
              {selected.guest_count != null
                ? ` · ${t('tableGuests', { count: selected.guest_count })}`
                : ''}
              {selected.seated_minutes != null
                ? ` · ${t('tableSeatedMinutes', { count: selected.seated_minutes })}`
                : ''}
            </p>
            {selected.orders.length > 0 ? (
              <ul className="table-panel-orders" aria-label={t('tableOrders')}>
                {selected.orders.map((order) => (
                  <li key={order.id}>
                    <button type="button" onClick={() => onSelectOrder(order.id)}>
                      <strong>
                        {order.table_label
                          ? t('tableOrderLetter', { label: order.table_label })
                          : t('tableOrderOpen')}
                      </strong>
                      <span>{formatMoney(order.total, selected.currency ?? 'VND')}</span>
                      {order.payment_requested ? (
                        <small>{t('tableState_payment_requested')}</small>
                      ) : order.prebilled ? (
                        <small>{t('tableState_prebilled')}</small>
                      ) : null}
                      {order.edited_after_prebill ? (
                        <small>{t('tableEditedAfterPrebill')}</small>
                      ) : null}
                    </button>
                  </li>
                ))}
              </ul>
            ) : null}
            {selected.state !== 'out_of_service' && selected.state !== 'cleaning' && canServe ? (
              <div className="table-panel-open">
                <label>
                  {t('tableGuestCount')}
                  <input
                    type="number"
                    inputMode="numeric"
                    min={0}
                    max={MAX_GUESTS}
                    value={guests}
                    onChange={(event) => setGuests(event.target.value)}
                  />
                </label>
                <button
                  type="button"
                  className="primary-button"
                  disabled={busy || locked}
                  onClick={() => open(selected, selected.orders.length > 0)}
                >
                  {selected.orders.length > 0 ? t('tableAddOrder') : t('tableOpen')}
                </button>
              </div>
            ) : null}
            <div className="row table-panel-status">
              {selected.state === 'cleaning' || selected.state === 'out_of_service' ? (
                <button
                  type="button"
                  disabled={busy || locked}
                  onClick={() => mark(selected, 'available')}
                >
                  {t('tableMarkAvailable')}
                </button>
              ) : selected.orders.length === 0 ? (
                <button
                  type="button"
                  disabled={busy || locked}
                  onClick={() => mark(selected, 'cleaning')}
                >
                  {t('tableMarkCleaning')}
                </button>
              ) : null}
            </div>
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </aside>
        ) : (
          <p className="table-panel table-panel-hint muted">{t('tablePickHint')}</p>
        )}
      </div>
    </section>
  );
}
