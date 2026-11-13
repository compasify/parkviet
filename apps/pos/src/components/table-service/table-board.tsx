import { formatMoney } from '@parkviet/pos-shared/money';
import { type PosTableSurface, TABLE_SURFACES } from '@parkviet/pos-shared/pos-modules';
import {
  BOARD_CHIPS,
  BOARD_TONES,
  type BoardChip,
  type BoardOptions,
  type BoardTable,
  boardCounts,
  filterTables,
  inBoardChip,
  tileAlert,
  tileTone,
} from '@parkviet/pos-shared/tables';
import type { ServiceMode } from '@parkviet/pos-shared/types/pos-context';
import { type CSSProperties, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard, useTableCommands } from '../../hooks/use-resource-board';
import { useModalFocus } from '../../lib/dialog-focus';
import type { PosWorkspace } from '../../lib/pos-context';
import { posFailureKey } from '../../lib/request-failure';
import { canServeTables, describeTableFailure, saveTableSurface } from '../../lib/tables';
import { DeliveryForm } from '../delivery-form';
import { PosIcon } from '../pos-icon';
import { OrderTrays, type SellingWorkspace } from '../workspace-tabs';
import { BoardTile } from './board-tile';
import { BoardPopover, GuestCountPicker } from './guest-count-popover';

const OPEN_STATUSES = ['editing', 'parked'];
// The board draws tiles or the plan; the room board belongs to timed rooms.
const BOARD_SURFACES = TABLE_SURFACES.filter((value) => value !== 'resource_board');

type Popover = { tableId: string; anchor: HTMLElement; addOrder: boolean };

// The first screen of a branch serving tables: every table of the picked
// area as a tile (or on the area's plan), filter chips with their counts,
// the colour legend, and two fixed tiles to start a takeaway or a delivery
// order. A table with guests opens its order; a free one asks for the
// number of guests right under its tile and opens the order once seated.
export function TableBoard({
  selling,
  onOpenOrder,
}: {
  selling: SellingWorkspace;
  // Selects an order and shows it for ordering.
  onOpenOrder: (workspaceId: string) => void;
}) {
  const { t } = useTranslation();
  const {
    data,
    selection,
    selectionComplete,
    locked,
    workspaces,
    rows,
    run,
    command,
    canCreate,
    message,
    kitchenOn,
    tableSurface,
    setSavedSurface,
    platformOrders,
    guestOrders,
    kioskOrders,
  } = selling;
  const board = useResourceBoard(selection.branchId, true);
  const commands = useTableCommands(selection.branchId);
  const [areaId, setAreaId] = useState<string | null>(null);
  const [chip, setChip] = useState<BoardChip>('all');
  const [popover, setPopover] = useState<Popover | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [delivering, setDelivering] = useState<PosWorkspace | null>(null);
  const branch = data?.branches.find((row) => row.id === selection.branchId);
  const timeZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const options: BoardOptions = {
    alertMinutes: branch?.seated_alert_minutes ?? null,
    kitchen: kitchenOn,
  };
  const surface: PosTableSurface = tableSurface === 'floor_plan' ? 'floor_plan' : 'table_grid';
  const areas = board.data?.areas ?? [];
  const tables = board.data?.resources ?? [];
  // The plan draws one area at a time: the one picked, else the first.
  const planArea =
    surface === 'floor_plan' ? (areas.find((row) => row.id === areaId) ?? areas[0] ?? null) : null;
  const shownAreaId = planArea?.id ?? areaId;
  const inArea = filterTables(tables, { areaId: shownAreaId });
  const counts = boardCounts(inArea, options);
  const shown = inArea.filter((row) => inBoardChip(row, chip, options));
  const selected = popover ? (tables.find((row) => row.id === popover.tableId) ?? null) : null;
  const canServe = canServeTables(data);
  const writeLocked = locked || !selectionComplete;
  const openCount = (mode: ServiceMode) =>
    rows.filter(
      (row) => row.service_mode === mode && OPEN_STATUSES.includes(row.operational_status),
    ).length;
  const takeaway = data?.modules?.['fnb.menu'] === true;
  const delivery = data?.features?.delivery === true;

  function close() {
    setPopover(null);
    setError('');
  }

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

  function pick(table: BoardTable, tile: HTMLElement) {
    setError('');
    // One order: straight in. Several: the cashier picks which.
    if (table.orders.length === 1) {
      onOpenOrder(table.orders[0].id);
      return;
    }
    setPopover({ tableId: table.id, anchor: tile, addOrder: false });
  }

  function seat(table: BoardTable, guestCount: number | null, addOrder: boolean) {
    void act(async () => {
      const created = await workspaces.openTable(table.id, { guestCount, addOrder });
      setPopover(null);
      onOpenOrder(created.id);
    });
  }

  // A takeaway or delivery order: a new draft at this register, served that way.
  async function startOrder(mode: 'takeaway' | 'delivery') {
    if (!canCreate || busy) return;
    setBusy(true);
    try {
      const created = await run(() => workspaces.create(selection.registerId));
      if (!created) return;
      const served = await run(() =>
        command(created, (current) => workspaces.setServiceMode(current, mode)),
      );
      // A refused mode leaves the draft as it was; the board shows why.
      if (!served) return;
      if (mode === 'delivery') setDelivering(served);
      else onOpenOrder(created.id);
    } finally {
      setBusy(false);
    }
  }

  const tile = (table: BoardTable, style?: CSSProperties) => (
    <BoardTile
      table={table}
      tone={tileTone(table, options)}
      alert={tileAlert(table, options)}
      expanded={popover?.tableId === table.id}
      timeZone={timeZone}
      style={style}
      onSelect={pick}
    />
  );

  const quickTiles = (
    <>
      {takeaway ? (
        <li>
          <button
            type="button"
            className="board-tile board-tile-quick"
            disabled={!canCreate || busy}
            title={canCreate ? undefined : t('workspaceNeedShift')}
            onClick={() => void startOrder('takeaway')}
          >
            <strong className="board-tile-name">+ {t('boardTakeaway')}</strong>
            <small>{t('boardOpenOrders', { count: openCount('takeaway') })}</small>
          </button>
        </li>
      ) : null}
      {delivery ? (
        <li>
          <button
            type="button"
            className="board-tile board-tile-quick"
            disabled={!canCreate || busy}
            title={canCreate ? undefined : t('workspaceNeedShift')}
            onClick={() => void startOrder('delivery')}
          >
            <strong className="board-tile-name">+ {t('boardDelivery')}</strong>
            <small>{t('boardOpenOrders', { count: openCount('delivery') })}</small>
          </button>
        </li>
      ) : null}
    </>
  );

  return (
    <section className="table-board" aria-label={t('boardTitle')}>
      <div className="table-board-top">
        <fieldset className="table-board-areas">
          <legend className="visually-hidden">{t('tableAreas')}</legend>
          {surface === 'table_grid' ? (
            <button type="button" aria-pressed={areaId === null} onClick={() => setAreaId(null)}>
              {t('tableAreasAll')}{' '}
              <small>
                {boardCounts(tables, options).in_use}/{tables.length}
              </small>
            </button>
          ) : null}
          {areas.map((area) => {
            const own = boardCounts(filterTables(tables, { areaId: area.id }), options);
            return (
              <button
                key={area.id}
                type="button"
                aria-pressed={shownAreaId === area.id}
                onClick={() => setAreaId(area.id)}
              >
                {area.name}{' '}
                <small>
                  {own.in_use}/{own.all}
                </small>
              </button>
            );
          })}
        </fieldset>
        <fieldset className="table-board-chips">
          <legend className="visually-hidden">{t('tableStateFilter')}</legend>
          {BOARD_CHIPS.map((value) => (
            <button
              key={value}
              type="button"
              className={`board-chip board-chip-${value}`}
              aria-pressed={chip === value}
              onClick={() => setChip(value)}
            >
              {t(`boardChip_${value}`)} <b>{counts[value]}</b>
            </button>
          ))}
        </fieldset>
      </div>
      <div className="table-board-legend">
        <ul aria-label={t('boardLegend')}>
          {BOARD_TONES.map((tone) => (
            <li key={tone}>
              <i className={`board-swatch board-tile-${tone}`} aria-hidden="true" />
              {t(`boardLegend_${tone}`)}
            </li>
          ))}
          <li className="table-board-legend-alert">
            <i className="board-swatch-strip" aria-hidden="true" />
            {options.alertMinutes
              ? t('boardLegendSeatedLong', { count: options.alertMinutes })
              : t('tableState_waiting_long')}
          </li>
          <li>{t('boardLegendIcons')}</li>
        </ul>
        <fieldset className="table-board-surface">
          <legend className="visually-hidden">{t('tableSurface')}</legend>
          {BOARD_SURFACES.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={surface === value}
              onClick={() => {
                saveTableSurface(value);
                setSavedSurface(value);
              }}
            >
              <PosIcon name={value === 'floor_plan' ? 'location' : 'grid'} />
              {t(`tableSurface_${value}`)}
            </button>
          ))}
        </fieldset>
      </div>
      {platformOrders || guestOrders || kioskOrders ? (
        <div className="table-board-trays">
          <OrderTrays selling={selling} onTaken={onOpenOrder} />
        </div>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {board.isLoading ? <p role="status">{t('tableFloorLoading')}</p> : null}
      {board.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(board.error))}
        </p>
      ) : null}
      <div className="table-board-body">
        {board.isSuccess && tables.length === 0 ? (
          <div className="empty">
            <strong>{t('tableFloorEmpty')}</strong>
            <p>{t('tableFloorEmptyHint')}</p>
          </div>
        ) : null}
        {surface === 'floor_plan' && planArea ? (
          <>
            {takeaway || delivery ? <ul className="table-board-grid">{quickTiles}</ul> : null}
            <fieldset
              className="floor-plan table-board-plan"
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
          </>
        ) : (
          <ul className="table-board-grid" aria-label={t('boardTitle')}>
            {quickTiles}
            {shown.map((table) => (
              <li key={table.id}>{tile(table)}</li>
            ))}
          </ul>
        )}
      </div>
      {popover && selected ? (
        <BoardPopover anchor={popover.anchor} label={selected.name} onClose={close}>
          {selected.orders.length > 0 && !popover.addOrder ? (
            <div className="guest-count-picker">
              <h3>{selected.name}</h3>
              <ul className="board-popover-orders" aria-label={t('tableOrders')}>
                {selected.orders.map((order) => (
                  <li key={order.id}>
                    <button type="button" onClick={() => onOpenOrder(order.id)}>
                      <strong>
                        {order.table_label
                          ? t('tableOrderLetter', { label: order.table_label })
                          : t('tableOrderOpen')}
                      </strong>
                      <span>{formatMoney(order.total, selected.currency ?? 'VND')}</span>
                    </button>
                  </li>
                ))}
              </ul>
              {canServe ? (
                <button
                  type="button"
                  disabled={busy || writeLocked}
                  onClick={() => setPopover({ ...popover, addOrder: true })}
                >
                  <PosIcon name="plus" /> {t('tableAddOrder')}
                </button>
              ) : null}
            </div>
          ) : selected.state === 'cleaning' || selected.state === 'out_of_service' ? (
            <div className="guest-count-picker">
              <h3>{selected.name}</h3>
              <p>{t(`tableState_${selected.state}`)}</p>
              <button
                type="button"
                className="primary-button board-popover-primary"
                disabled={busy || writeLocked}
                onClick={() =>
                  void act(async () => {
                    await commands.setManualStatus(selected.id, 'available');
                    setPopover(null);
                  })
                }
              >
                {t('tableMarkAvailable')}
              </button>
              {error ? (
                <p className="error" role="alert">
                  {error}
                </p>
              ) : null}
            </div>
          ) : (
            <GuestCountPicker
              title={t(popover.addOrder ? 'boardAddOrderTitle' : 'boardOpenTitle', {
                name: selected.name,
              })}
              hint={t('boardOpenHint')}
              busy={busy}
              disabled={writeLocked || !canServe}
              disabledReason={canServe ? undefined : t('boardCannotServe')}
              error={error}
              onOpen={(guestCount) => seat(selected, guestCount, popover.addOrder)}
            >
              {selected.orders.length === 0 ? (
                <button
                  type="button"
                  disabled={busy || writeLocked}
                  onClick={() =>
                    void act(async () => {
                      await commands.setManualStatus(selected.id, 'cleaning');
                      setPopover(null);
                    })
                  }
                >
                  {t('tableMarkCleaning')}
                </button>
              ) : null}
            </GuestCountPicker>
          )}
        </BoardPopover>
      ) : null}
      {delivering ? (
        <DeliveryDialog
          workspace={delivering}
          selling={selling}
          onDone={() => {
            setDelivering(null);
            onOpenOrder(delivering.id);
          }}
        />
      ) : null}
    </section>
  );
}

// Who takes a new delivery order and its fee, asked before the menu opens.
function DeliveryDialog({
  workspace,
  selling,
  onDone,
}: {
  workspace: PosWorkspace;
  selling: SellingWorkspace;
  onDone: () => void;
}) {
  const { t } = useTranslation();
  const ref = useRef<HTMLDivElement>(null);
  const { command, workspaces, locked, channelUnavailable, pendingCounts } = selling;
  useModalFocus(ref, onDone);
  return (
    <div className="pos-popup-backdrop">
      <div ref={ref} role="dialog" aria-modal="true" aria-label={t('deliveryTitle')} tabIndex={-1}>
        <DeliveryForm
          workspace={workspace}
          disabled={locked || channelUnavailable || Boolean(pendingCounts[workspace.id])}
          onSave={(input) =>
            command(workspace, (current) => workspaces.setDelivery(current, input))
          }
          onClear={() => command(workspace, (current) => workspaces.clearDelivery(current))}
          onClose={onDone}
        />
      </div>
    </div>
  );
}
