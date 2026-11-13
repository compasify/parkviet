import { formatMoney } from '@parkviet/pos-shared/money';
import {
  type TicketGroup,
  type TicketGroupMode,
  type TicketLineTag,
  ticketLineAmount,
  ticketLineTag,
} from '@parkviet/pos-shared/ticket-groups';
import { describeTraceFailure } from '@parkviet/pos-shared/traceability';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { kitchenSent } from '../../lib/kitchen';
import { linePicks } from '../../lib/menu-selection';
import type { PosLineItem, PosMenuItem, PosWorkspace } from '../../lib/pos-context';
import { MAX_COUNT_QUANTITY } from '../../lib/quantity';
import { snapshotLocked } from '../../lib/request-failure';
import { courseName, seatsOf } from '../../lib/table-courses';
import { lineChanged, lineSent } from '../../lib/table-kitchen';
import { ItemDiscountEditor } from '../item-discount-editor';
import { ModifierSheet } from '../modifier-sheet';
import { PosIcon } from '../pos-icon';
import type { SellingWorkspace } from '../workspace-tabs';

// Seats offered when moving a dish, at least this many.
const MIN_SEATS = 4;
const SEAT_MAX = 99;

type Clock = {
  // Milliseconds now, ticking while the ticket is open.
  now: number;
  // "14:22" in the branch's time zone.
  time: (value: string) => string;
};

// The lines of the table ticket in their groups; tapping a line opens its
// tools under it. Unsent dishes change freely (by the line's own version,
// without the lease); a dish the kitchen has comes back only as a void.
export function TicketLines({
  selling,
  active,
  groups,
  mode,
  plain,
  clock,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  groups: TicketGroup[];
  mode: TicketGroupMode;
  // Without a kitchen the lines show without group headings.
  plain: boolean;
  clock: Clock;
}) {
  const { t } = useTranslation();
  const { workspaces, command, run, placement, setPlacement, canAppend, busy } = selling;
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [editing, setEditing] = useState<{ line: PosLineItem; item: PosMenuItem } | null>(null);
  const menu = selling.menu.data ?? null;
  const currency = active.totals?.currency ?? 'VND';
  const table = selling.activeTable.table !== null;

  // A line change, with what the counter's basket does on a refusal: a line
  // someone else changed reloads, a line the kitchen has goes to the void.
  async function change(
    line: PosLineItem,
    action: (current: PosWorkspace) => Promise<PosWorkspace>,
  ) {
    setError('');
    try {
      await command(active, action);
    } catch (failure) {
      if (lineChanged(failure)) {
        setError(t('lineChangedByOther'));
        void workspaces.refresh();
      } else if (lineSent(failure) && selling.kitchenOn && !active.payments)
        selling.setVoiding(line);
      else if (snapshotLocked(failure) && canAppend) setError(t('tableSnapshotLocked'));
      else setError(describeTraceFailure(failure, t));
    }
  }

  function fire(course: number) {
    void run(() => command(active, (current) => workspaces.fireCourse(current, course)));
  }

  function heading(group: TicketGroup) {
    const items = t('ticketGroupItems', { count: group.quantity });
    switch (group.kind) {
      case 'new':
        return {
          label: t('ticketGroupNew', { count: group.quantity }),
          aside: <span className="ticket-group-aside">{t('ticketGroupNewHint')}</span>,
        };
      case 'held': {
        const courses = [...new Set(group.lines.map((line) => line.course ?? 0))].filter(Boolean);
        return {
          label: t('ticketGroupHeld'),
          aside: (
            <span className="ticket-group-aside">
              {courses.map((course) => (
                <FireButton
                  key={course}
                  label={courses.length > 1 ? courseName(course) : undefined}
                  disabled={!canAppend || busy}
                  onFire={() => fire(course)}
                />
              ))}
            </span>
          ),
        };
      }
      case 'round': {
        const send = group.send;
        const label = send
          ? t(send.staff_name ? 'ticketGroupRoundBy' : 'ticketGroupRound', {
              number: send.sequence,
              time: clock.time(send.sent_at),
              name: send.staff_name,
            })
          : t('ticketGroupSent');
        return { label, aside: <span className="ticket-group-aside">{items}</span> };
      }
      case 'course': {
        if (group.course === null || group.course === undefined)
          return {
            label: t('ticketCourseNone'),
            aside: <span className="ticket-group-aside">{items}</span>,
          };
        const status = group.courseStatus ?? 'fired';
        const name = courseName(group.course);
        const course = group.course;
        return {
          icon: status === 'held' ? 'pause' : status === 'done' ? 'check' : 'play',
          label:
            status === 'fired' && group.send
              ? t('ticketCourse_firedAt', { course: name, time: clock.time(group.send.sent_at) })
              : t(`ticketCourse_${status}`, { course: name }),
          aside:
            status === 'held' ? (
              <span className="ticket-group-aside">
                <FireButton disabled={!canAppend || busy} onFire={() => fire(course)} />
              </span>
            ) : (
              <span className="ticket-group-aside">{items}</span>
            ),
        } as const;
      }
      case 'seat':
      case 'shared':
        return {
          label: group.seat ? t('ticketSeat', { seat: group.seat }) : t('ticketSeatShared'),
          aside: (
            <span className="ticket-group-aside">
              {formatMoney(String(group.amount ?? 0), currency)}
            </span>
          ),
        };
      default:
        return {
          label: t('ticketGroupOther'),
          aside: <span className="ticket-group-aside">{items}</span>,
        };
    }
  }

  if (groups.length === 0)
    return (
      <div className="ticket-lines">
        <p className="ticket-empty">{t('ticketEmpty')}</p>
      </div>
    );

  return (
    <div className="ticket-lines">
      {groups.map((group) => {
        const head = heading(group);
        const seatHead = group.kind === 'seat' || group.kind === 'shared';
        const current = seatHead && table && (placement.seat ?? null) === (group.seat ?? null);
        return (
          <section
            key={group.key}
            className={`ticket-group ticket-group-${group.kind}`}
            aria-label={head.label}
          >
            {plain ? null : seatHead && table ? (
              // Tapping a seat orders the next dishes for it.
              <button
                type="button"
                className="ticket-group-head ticket-group-seat-pick"
                aria-pressed={current}
                aria-label={t('ticketSeatPick', {
                  seat: group.seat ?? t('ticketSeatShared'),
                })}
                disabled={!canAppend || busy}
                onClick={() => setPlacement({ ...placement, seat: group.seat ?? null })}
              >
                <span>
                  {head.label}
                  {current ? ` · ${t('ticketSeatCurrent')}` : ''}
                </span>
                {head.aside}
              </button>
            ) : (
              <div className="ticket-group-head">
                {'icon' in head && head.icon ? <PosIcon name={head.icon} /> : null}
                <span>{head.label}</span>
                {head.aside}
              </div>
            )}
            <ul>
              {group.lines.map((line) => (
                <TicketLine
                  key={line.id}
                  selling={selling}
                  active={active}
                  line={line}
                  mode={mode}
                  clock={clock}
                  selected={selectedId === line.id}
                  onSelect={() => setSelectedId((id) => (id === line.id ? null : line.id))}
                  onChange={(action) => void change(line, action)}
                  onEditNote={(item) => setEditing({ line, item })}
                />
              ))}
            </ul>
          </section>
        );
      })}
      {error ? (
        <p className="error ticket-error" role="alert">
          {error}
        </p>
      ) : null}
      {editing && menu && editing.line.sale_line_id ? (
        <ModifierSheet
          menu={menu}
          item={editing.item}
          editing
          initial={{
            variantId: editing.line.variant_id,
            picks: linePicks(editing.line),
            note: editing.line.note ?? '',
          }}
          onSubmit={(result) =>
            command(active, (current) =>
              workspaces.updateModifiers(current, editing.line.sale_line_id as string, {
                modifiers: result.modifiers,
                note: result.note || null,
              }),
            )
          }
          onClose={() => setEditing(null)}
        />
      ) : null}
    </div>
  );
}

function FireButton({
  label,
  disabled,
  onFire,
}: {
  label?: string;
  disabled: boolean;
  onFire: () => void;
}) {
  const { t } = useTranslation();
  return (
    <button type="button" className="ticket-fire" disabled={disabled} onClick={onFire}>
      {t('ticketCourseFire')}
      {label ? ` · ${label}` : ''}
    </button>
  );
}

const TAG_CLASS: Record<TicketLineTag, string> = {
  new: 'ticket-tag-new',
  held: 'ticket-tag-held',
  cooking: 'ticket-tag-cooking',
  done: 'ticket-tag-done',
  sent: 'ticket-tag-sent',
  none: '',
};

function TicketLine({
  selling,
  active,
  line,
  mode,
  clock,
  selected,
  onSelect,
  onChange,
  onEditNote,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  line: PosLineItem;
  mode: TicketGroupMode;
  clock: Clock;
  selected: boolean;
  onSelect: () => void;
  onChange: (action: (current: PosWorkspace) => Promise<PosWorkspace>) => void;
  onEditNote: (item: PosMenuItem) => void;
}) {
  const { t } = useTranslation();
  const currency = active.totals?.currency ?? 'VND';
  const tag = ticketLineTag(line);
  const sent = kitchenSent(line) > 0;
  const send =
    typeof line.kitchen_send_sequence === 'number'
      ? (active.kitchen_sends ?? []).find((row) => row.sequence === line.kitchen_send_sequence)
      : undefined;
  const minutes = send
    ? Math.max(0, Math.floor((clock.now - Date.parse(send.sent_at)) / 60_000))
    : null;
  const tagText =
    (tag === 'cooking' || tag === 'sent') && minutes !== null && Number.isFinite(minutes)
      ? t(`ticketTag_${tag}For`, { minutes })
      : tag === 'none'
        ? ''
        : t(`ticketTag_${tag}`);
  const details = [
    (line.modifiers ?? []).map((row) => row.name).join(', '),
    mode !== 'seat' && line.seat ? t('ticketSeat', { seat: line.seat }) : '',
    mode !== 'course' && line.course
      ? `${courseName(line.course)}${line.course_status === 'held' ? ` · ${t('ticketPlacementHeld')}` : ''}`
      : '',
  ].filter(Boolean);
  return (
    <li
      className={`ticket-line ticket-line-${tag}${selected ? ' ticket-line-selected' : ''}`}
      data-line-id={line.id}
    >
      <button
        type="button"
        className="ticket-line-main"
        aria-expanded={selected}
        aria-label={`${line.quantity} × ${line.name}${tagText ? ` · ${tagText}` : ''}`}
        onClick={onSelect}
      >
        <span className="ticket-line-qty">{line.quantity}</span>
        <span className="ticket-line-body">
          <span className="ticket-line-name">
            {line.name}
            {tagText ? <span className={`ticket-tag ${TAG_CLASS[tag]}`}>{tagText}</span> : null}
          </span>
          {details.length > 0 ? (
            <span className="ticket-line-detail">{details.join(' · ')}</span>
          ) : null}
          {line.note ? <span className="ticket-line-note">* {line.note}</span> : null}
        </span>
        <span className="ticket-line-price">
          {formatMoney(String(ticketLineAmount(line)), currency)}
          {sent ? (
            <span className="ticket-line-lock" title={t('ticketLocked')}>
              <PosIcon name="lock" />
              <span className="visually-hidden">{t('ticketLocked')}</span>
            </span>
          ) : null}
        </span>
      </button>
      {selected ? (
        <LineActions
          selling={selling}
          active={active}
          line={line}
          onChange={onChange}
          onEditNote={onEditNote}
        />
      ) : null}
    </li>
  );
}

function menuItemOf(selling: SellingWorkspace, line: PosLineItem): PosMenuItem | null {
  return (
    selling.menu.data?.items.find((item) =>
      item.variants.some((variant) => variant.id === line.variant_id),
    ) ?? null
  );
}

// The tools of the line the cashier tapped: the count, its note and
// options, its seat, its discount, and taking it off (a void once sent).
function LineActions({
  selling,
  active,
  line,
  onChange,
  onEditNote,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  line: PosLineItem;
  onChange: (action: (current: PosWorkspace) => Promise<PosWorkspace>) => void;
  onEditNote: (item: PosMenuItem) => void;
}) {
  const { t } = useTranslation();
  const {
    data,
    workspaces,
    editDisabled,
    canAppend,
    busy,
    lockReason,
    kitchenOn,
    activeTable,
    setVoiding,
    command,
  } = selling;
  const [seating, setSeating] = useState(false);
  const sent = kitchenSent(line) > 0;
  const lineId = line.sale_line_id ?? line.id;
  // A table order changes unsent lines without the lease, like the basket.
  const countDisabled = editDisabled && !(canAppend && !busy);
  // Play time and scale labels change only where they come from.
  const fixed = line.kind === 'timed' || line.kind === 'measured' || Boolean(line.label_barcode);
  const voidable = sent && kitchenOn && !active.payments && !countDisabled;
  const item = line.kind === 'menu' && !sent ? menuItemOf(selling, line) : null;
  const seats = Math.min(
    SEAT_MAX,
    Math.max(MIN_SEATS, activeTable.guestCount ?? 0, ...seatsOf(active), line.seat ?? 0),
  );
  const canSeat = activeTable.table !== null && kitchenOn && Boolean(line.sale_line_id);
  return (
    <fieldset className="ticket-line-actions">
      <legend className="visually-hidden">{t('ticketLineActions', { name: line.name })}</legend>
      {!sent && !fixed ? (
        <span className="ticket-stepper">
          <button
            type="button"
            aria-label={t('decreaseQuantity', { name: line.name })}
            disabled={countDisabled || line.quantity <= 1}
            title={lockReason}
            onClick={() =>
              onChange((current) =>
                workspaces.updateItem(current, lineId, { quantity: line.quantity - 1 }),
              )
            }
          >
            <PosIcon name="minus" />
          </button>
          <span>{line.quantity}</span>
          <button
            type="button"
            aria-label={t('increaseQuantity', { name: line.name })}
            disabled={countDisabled || line.quantity >= MAX_COUNT_QUANTITY}
            title={lockReason}
            onClick={() =>
              onChange((current) =>
                workspaces.updateItem(current, lineId, { quantity: line.quantity + 1 }),
              )
            }
          >
            <PosIcon name="plus" />
          </button>
        </span>
      ) : null}
      {item && line.sale_line_id ? (
        <button
          type="button"
          disabled={editDisabled}
          title={lockReason}
          onClick={() => onEditNote(item)}
        >
          {t('ticketLineNote')}
        </button>
      ) : null}
      {canSeat ? (
        <button
          type="button"
          aria-expanded={seating}
          disabled={!canAppend || busy}
          onClick={() => setSeating((value) => !value)}
        >
          {t('ticketLineSeat')}
        </button>
      ) : null}
      {line.sale_line_id &&
      line.kind !== 'timed' &&
      data?.capabilities.includes('pos.discount.apply') ? (
        <span className="ticket-line-discount" title={t('ticketLineDiscount')}>
          <ItemDiscountEditor
            key={`${line.id}:${line.item_discount?.value_type}:${line.item_discount?.value}:${line.line_discount?.id}`}
            workspace={active}
            line={line}
            currency={active.totals?.currency ?? 'VND'}
            disabled={editDisabled}
            disabledReason={lockReason}
            canApplyDiscount
            // The editor reports its own refusals (approval, reason).
            onApply={(input) =>
              command(active, (current) => workspaces.lineDiscount(current, lineId, input))
            }
            onClear={(approvalId) =>
              command(active, (current) =>
                workspaces.clearLineDiscount(current, lineId, approvalId),
              )
            }
          />
        </span>
      ) : null}
      {sent ? (
        voidable ? (
          <button type="button" className="ticket-danger" onClick={() => setVoiding(line)}>
            {t('ticketLineVoid')}
          </button>
        ) : null
      ) : (
        <button
          type="button"
          className="ticket-danger"
          disabled={countDisabled || line.kind === 'timed'}
          title={lockReason}
          onClick={() => onChange((current) => workspaces.removeItem(current, lineId))}
        >
          {t('ticketLineRemove')}
        </button>
      )}
      {seating && canSeat ? (
        <fieldset className="ticket-seat-picker">
          <legend className="visually-hidden">{t('ticketLineSeatFor', { name: line.name })}</legend>
          {[null, ...Array.from({ length: seats }, (_, index) => index + 1)].map((seat) => (
            <button
              key={seat ?? 'shared'}
              type="button"
              aria-pressed={(line.seat ?? null) === seat}
              disabled={!canAppend || busy}
              onClick={() => {
                setSeating(false);
                if ((line.seat ?? null) !== seat)
                  onChange((current) =>
                    workspaces.placeLine(current, line.sale_line_id as string, { seat }),
                  );
              }}
            >
              {seat === null ? t('seatShared') : seat}
            </button>
          ))}
        </fieldset>
      ) : null}
    </fieldset>
  );
}
