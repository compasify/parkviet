import { formatMoney } from '@parkviet/pos-shared/money';
import { type PosTableSurface, TABLE_SURFACES } from '@parkviet/pos-shared/pos-modules';
import {
  attentionReasons,
  BOARD_CHIPS,
  BOARD_TONES,
  type BoardChip,
  type BoardOptions,
  type BoardTable,
  boardCounts,
  filterTables,
  inBoardChip,
  ROOM_TONES,
  roomTone,
  tileAlert,
  tileTone,
} from '@parkviet/pos-shared/tables';
import type { ServiceMode } from '@parkviet/pos-shared/types/pos-context';
import { type CSSProperties, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard, useTableCommands } from '../../hooks/use-resource-board';
import { useTimedCommands } from '../../hooks/use-timed';
import { useTicker } from '../../lib/board-ticker';
import { useModalFocus } from '../../lib/dialog-focus';
import type { PosWorkspace } from '../../lib/pos-context';
import { conflictReason, posFailureKey } from '../../lib/request-failure';
import { canServeTables, describeTableFailure, saveTableSurface } from '../../lib/tables';
import {
  canRunClock,
  clockOffset,
  isRunning,
  TIMED_MODULE,
  timedFailureKey,
} from '../../lib/timed-clock';
import { DeliveryForm } from '../delivery-form';
import { PosIcon } from '../pos-icon';
import { type ClockStartOptions, TimedPanel } from '../timed-panel';
import { OrderTrays, type SellingWorkspace } from '../workspace-tabs';
import { BoardTile } from './board-tile';
import { BoardPopover, GuestCountPicker } from './guest-count-popover';
import { type RoomClockAction, RoomClockBadge, RoomTile } from './room-tile';
import type { StopAndPay } from './stop-and-pay-dialog';

const OPEN_STATUSES = ['editing', 'parked'];
// How often the board's chip counts look at the clocks again; each tile's
// own clock moves every second.
const COUNTS_STEP_MS = 15_000;

// The order's list (`addOrder` false), seating guests (true), or a room's
// clock with its status (`clock`).
type Popover = { tableId: string; anchor: HTMLElement; addOrder: boolean; clock?: boolean };

// The first screen of a branch serving tables: every table of the picked
// area as a tile (or on the area's plan), filter chips with their counts,
// the colour legend, and two fixed tiles to start a takeaway or a delivery
// order. A table with guests opens its order; a free one asks for the
// number of guests right under its tile and opens the order once seated.
// A branch billing play time may show its rooms instead: each with its
// clock and the actions start/pause/resume, order and pay on the tile.
// A bar reaches it from its open tabs and goes back to them in one tap.
export function TableBoard({
  selling,
  onOpenOrder,
  onPay,
  onStopAndPay,
  onTabs,
}: {
  selling: SellingWorkspace;
  // Selects an order and shows it for ordering.
  onOpenOrder: (workspaceId: string) => void;
  // Selects an order and opens its payment.
  onPay: (workspaceId: string) => void;
  // A room's clock still counts: confirm stopping it before the payment.
  onStopAndPay: (request: StopAndPay) => void;
  // A bar: back to its open tabs beside the menu.
  onTabs?: () => void;
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
  const timedCommands = useTimedCommands();
  const [areaId, setAreaId] = useState<string | null>(null);
  const [chip, setChip] = useState<BoardChip>('all');
  const [popover, setPopover] = useState<Popover | null>(null);
  const [busy, setBusy] = useState(false);
  // A pause or resume in flight: a second tap before the first re-renders
  // must not send it twice.
  const clocking = useRef(false);
  const [error, setError] = useState('');
  // A clock command refused from a tile, said above the rooms.
  const [roomError, setRoomError] = useState('');
  const [delivering, setDelivering] = useState<PosWorkspace | null>(null);
  const branch = data?.branches.find((row) => row.id === selection.branchId);
  const timeZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  // The branch bills play time: clocks show on the tiles and the room board
  // is one of the surfaces.
  const timedOn = data?.modules?.[TIMED_MODULE] === true;
  const canTime = canRunClock(data);
  const offsetMs = clockOffset(board.data?.server_now, board.dataUpdatedAt);
  const readAt = board.data?.server_now ?? null;
  const countsNow = useTicker(timedOn, COUNTS_STEP_MS) + offsetMs;
  const options: BoardOptions = {
    alertMinutes: branch?.seated_alert_minutes ?? null,
    kitchen: kitchenOn,
    now: timedOn ? countsNow : undefined,
  };
  const surface: PosTableSurface =
    tableSurface === 'floor_plan'
      ? 'floor_plan'
      : tableSurface === 'resource_board' && timedOn
        ? 'resource_board'
        : 'table_grid';
  const surfaces = TABLE_SURFACES.filter((value) => value !== 'resource_board' || timedOn);
  const rooms = surface === 'resource_board';
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

  // The order a room's tile works on: the one its clock bills, else its
  // only one; null when there is none or the cashier has to pick.
  function roomOrder(table: BoardTable): string | null {
    const billed = table.timed?.workspace_id;
    if (billed && table.orders.some((order) => order.id === billed)) return billed;
    return table.orders.length === 1 ? table.orders[0].id : null;
  }

  // "Gọi món": the room's order, else seat it (or pick among its orders).
  function orderRoom(table: BoardTable, anchor: HTMLElement) {
    setRoomError('');
    const workspaceId = roomOrder(table);
    if (workspaceId) onOpenOrder(workspaceId);
    else pick(table, anchor);
  }

  // "Thanh toán": a clock still counting on the order is stopped first, after
  // the cashier says yes; the payment never opens with the clock counting.
  function payRoom(table: BoardTable, anchor: HTMLElement) {
    setRoomError('');
    const workspaceId = roomOrder(table);
    if (!workspaceId) {
      setPopover({ tableId: table.id, anchor, addOrder: false });
      return;
    }
    const timed = table.timed;
    if (timed && isRunning(timed) && (timed.workspace_id ?? workspaceId) === workspaceId) {
      onStopAndPay({
        sessionId: timed.id,
        workspaceId,
        room: table.name,
        amount: timed.quote_amount,
        currency: table.currency ?? 'VND',
      });
      return;
    }
    onPay(workspaceId);
  }

  async function clockAct(table: BoardTable, action: () => Promise<unknown>, anchor: HTMLElement) {
    if (busy || clocking.current) return;
    clocking.current = true;
    setBusy(true);
    setRoomError('');
    try {
      await action();
    } catch (failure) {
      const reason = conflictReason(failure);
      // A long pause resumes with a manager's approval, asked in the room's panel.
      if (reason === 'approval_required') {
        setPopover({ tableId: table.id, anchor, addOrder: false, clock: true });
        return;
      }
      const key = timedFailureKey(reason);
      setRoomError(`${table.name}: ${key ? t(key) : describeTableFailure(failure, t)}`);
    } finally {
      clocking.current = false;
      setBusy(false);
    }
  }

  // Start opens the room's panel (a package, a minutes card, outside the
  // branch's hours); pause and resume take one tap.
  function clockRoom(table: BoardTable, action: RoomClockAction, anchor: HTMLElement) {
    setError('');
    const timed = table.timed;
    if (action === 'start' || !timed || (action === 'resume' && timed.pause_too_long)) {
      setPopover({ tableId: table.id, anchor, addOrder: false, clock: true });
      return;
    }
    void clockAct(
      table,
      () => (action === 'pause' ? timedCommands.pause(timed.id) : timedCommands.resume(timed.id)),
      anchor,
    );
  }

  async function startClock(table: BoardTable, start: ClockStartOptions) {
    await workspaces.startClock(table.id, table.orders.length === 0, start);
    setPopover(null);
    void commands.refreshBoard();
  }

  const tile = (table: BoardTable, style?: CSSProperties) => (
    <BoardTile
      table={table}
      tone={tileTone(table, options)}
      alert={tileAlert(table, options)}
      expanded={popover?.tableId === table.id}
      timeZone={timeZone}
      style={style}
      clock={
        table.timed && isRunning(table.timed) ? (
          <RoomClockBadge table={table} offsetMs={offsetMs} readAt={readAt} />
        ) : null
      }
      clockLabel={
        table.timed && isRunning(table.timed)
          ? `${t('timedClock')}: ${t(`roomTone_${roomTone(table, options.now)}`)}`
          : null
      }
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
    <section
      className={rooms ? 'table-board room-board' : 'table-board'}
      aria-label={t(rooms ? 'roomBoardTitle' : 'boardTitle')}
    >
      <div className="table-board-top">
        {onTabs ? (
          <button type="button" className="table-board-tabs" onClick={onTabs}>
            <PosIcon name="back" /> {t('tabListTitle')}
          </button>
        ) : null}
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
        {rooms ? (
          <ul aria-label={t('boardLegend')}>
            {ROOM_TONES.map((tone) => (
              <li key={tone}>
                <i className={`board-swatch room-tile-${tone}`} aria-hidden="true" />
                {t(`roomLegend_${tone}`)}
              </li>
            ))}
          </ul>
        ) : (
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
        )}
        <fieldset className="table-board-surface">
          <legend className="visually-hidden">{t('tableSurface')}</legend>
          {surfaces.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={surface === value}
              onClick={() => {
                saveTableSurface(value);
                setSavedSurface(value);
              }}
            >
              <PosIcon
                name={
                  value === 'floor_plan'
                    ? 'location'
                    : value === 'resource_board'
                      ? 'clock'
                      : 'grid'
                }
              />
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
      {roomError ? (
        <p className="error" role="alert">
          {roomError}
        </p>
      ) : null}
      {rooms && !canTime ? <p className="muted">{t('roomCannotTime')}</p> : null}
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
        {rooms ? (
          <ul className="table-board-grid room-board-grid" aria-label={t('roomBoardTitle')}>
            {quickTiles}
            {shown.map((table) => (
              <li key={table.id}>
                <RoomTile
                  table={table}
                  offsetMs={offsetMs}
                  readAt={readAt}
                  timeZone={timeZone}
                  expanded={popover?.tableId === table.id}
                  attention={attentionReasons(table, options)}
                  canTime={canTime}
                  canServe={canServe}
                  locked={writeLocked || busy}
                  onDetails={(row, anchor) => {
                    setError('');
                    setPopover({ tableId: row.id, anchor, addOrder: false, clock: true });
                  }}
                  onClock={clockRoom}
                  onOrder={orderRoom}
                  onPay={payRoom}
                />
              </li>
            ))}
          </ul>
        ) : surface === 'floor_plan' && planArea ? (
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
          {popover.clock ? (
            <div className="guest-count-picker room-popover">
              <h3>{selected.name}</h3>
              {canTime ? (
                <TimedPanel
                  branchId={selection.branchId}
                  table={selected}
                  tables={tables}
                  offsetMs={offsetMs}
                  readAt={readAt}
                  outsideHours={board.data?.outside_operating_hours === true}
                  currency={selected.currency ?? 'VND'}
                  locked={writeLocked}
                  onStart={startClock}
                  onFailure={(failure, key) => {
                    setError(key ? t(key) : describeTableFailure(failure, t));
                    void commands.refreshBoard();
                  }}
                />
              ) : (
                <p>{t('roomCannotTime')}</p>
              )}
              {selected.state === 'cleaning' || selected.state === 'out_of_service' ? (
                <button
                  type="button"
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
              ) : selected.orders.length === 0 ? (
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
              {error ? (
                <p className="error" role="alert">
                  {error}
                </p>
              ) : null}
            </div>
          ) : selected.orders.length > 0 && !popover.addOrder ? (
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
