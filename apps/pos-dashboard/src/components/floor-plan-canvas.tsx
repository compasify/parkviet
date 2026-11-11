import type { FloorArea, Placement, ResourceRecord } from '@parkviet/pos-shared/tables'
import { type KeyboardEvent, type PointerEvent, useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { nudgePlacement, shiftPlacement } from '../lib/floor-plan'

// Pixels per grid cell; the floor scrolls when it is wider than the page.
const CELL = 32

export type CanvasTable = Pick<ResourceRecord, 'name' | 'capacity' | 'shape' | 'manual_status'> &
  Placement & { key: string }

type Drag = { mode: 'move' | 'resize'; x: number; y: number; start: Placement; pointer: number }

const placementOf = ({ x, y, w, h, rotation }: Placement): Placement => ({ x, y, w, h, rotation })

// One area's grid with its tables as boxes. The selected table follows the
// pointer by whole cells (its corner handle resizes it) or the arrow keys
// (Shift resizes); any other table is selected first by click, Enter or Space.
export function FloorPlanCanvas({
  area,
  tables,
  selected,
  write,
  onSelect,
  onPlace,
}: {
  area: Pick<FloorArea, 'name' | 'floor_width' | 'floor_height'>
  tables: CanvasTable[]
  selected: string | null
  write: boolean
  onSelect: (key: string) => void
  onPlace: (placement: Placement) => void
}) {
  const { t } = useTranslation()
  const drag = useRef<Drag | null>(null)

  const begin = (event: PointerEvent<HTMLElement>, table: CanvasTable, mode: Drag['mode']) => {
    if (event.button !== 0) return
    event.stopPropagation()
    if (table.key !== selected) {
      onSelect(table.key)
      return
    }
    if (!write) return
    event.preventDefault()
    event.currentTarget.setPointerCapture(event.pointerId)
    drag.current = {
      mode,
      x: event.clientX,
      y: event.clientY,
      start: placementOf(table),
      pointer: event.pointerId,
    }
  }
  const move = (event: PointerEvent<HTMLElement>) => {
    const current = drag.current
    if (!current || current.pointer !== event.pointerId) return
    onPlace(
      shiftPlacement(
        current.start,
        { dx: (event.clientX - current.x) / CELL, dy: (event.clientY - current.y) / CELL },
        current.mode,
        area,
      ),
    )
  }
  const end = (event: PointerEvent<HTMLElement>) => {
    if (drag.current?.pointer !== event.pointerId) return
    drag.current = null
    if (event.currentTarget.hasPointerCapture(event.pointerId))
      event.currentTarget.releasePointerCapture(event.pointerId)
  }
  const key = (event: KeyboardEvent<HTMLElement>, table: CanvasTable) => {
    if (table.key !== selected) {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault()
        onSelect(table.key)
      }
      return
    }
    if (!write) return
    const next = nudgePlacement(placementOf(table), event.key, event.shiftKey, area)
    if (!next) return
    event.preventDefault()
    onPlace(next)
  }
  const handlers = (table: CanvasTable, mode: Drag['mode']) => ({
    onPointerDown: (event: PointerEvent<HTMLElement>) => begin(event, table, mode),
    onPointerMove: move,
    onPointerUp: end,
    onPointerCancel: end,
  })

  return (
    <div className="overflow-auto rounded-lg border">
      <section
        aria-label={t('floorPlan.canvas', {
          name: area.name,
          width: area.floor_width,
          height: area.floor_height,
        })}
        aria-describedby={write ? 'floor-plan-canvas-help' : undefined}
        className="relative bg-background"
        style={{
          width: area.floor_width * CELL,
          height: area.floor_height * CELL,
          backgroundImage:
            'linear-gradient(to right, var(--border) 1px, transparent 1px), linear-gradient(to bottom, var(--border) 1px, transparent 1px)',
          backgroundSize: `${CELL}px ${CELL}px`,
        }}
      >
        {tables.map((table) => {
          const active = table.key === selected
          const marked = table.manual_status !== 'available'
          return (
            // biome-ignore lint/a11y/useSemanticElements: a positioned, draggable box that holds its own resize handle cannot be a native button.
            <div
              key={table.key}
              role="button"
              tabIndex={0}
              aria-pressed={active}
              aria-label={t('floorPlan.tableOnCanvas', {
                name: table.name || t('floorPlan.newTable'),
                x: table.x,
                y: table.y,
                w: table.w,
                h: table.h,
              })}
              data-testid="floor-table"
              className={`absolute flex touch-none select-none flex-col items-center justify-center overflow-hidden border-2 bg-muted text-center text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring ${
                table.shape === 'round' ? 'rounded-full' : 'rounded-md'
              } ${active ? 'z-10 border-primary' : 'border-muted-foreground/40'} ${
                active && write ? 'cursor-move' : 'cursor-pointer'
              } ${marked ? 'border-dashed opacity-70' : ''}`}
              style={{
                left: table.x * CELL,
                top: table.y * CELL,
                width: table.w * CELL,
                height: table.h * CELL,
                transform: table.rotation ? `rotate(${table.rotation}deg)` : undefined,
              }}
              onKeyDown={(event) => key(event, table)}
              {...handlers(table, 'move')}
            >
              <strong className="max-w-full truncate px-1">
                {table.name || t('floorPlan.newTable')}
              </strong>
              <span className="text-muted-foreground">
                {marked
                  ? t(`tableState_${table.manual_status}`)
                  : t('floorPlan.seats', { count: table.capacity })}
              </span>
              {active && write ? (
                <span
                  aria-hidden="true"
                  data-testid="floor-table-resize"
                  className="absolute right-0 bottom-0 size-3 cursor-se-resize bg-primary"
                  {...handlers(table, 'resize')}
                />
              ) : null}
            </div>
          )
        })}
      </section>
      {write ? (
        <p id="floor-plan-canvas-help" className="p-2 text-xs text-muted-foreground">
          {t('floorPlan.canvasHelp')}
        </p>
      ) : null}
    </div>
  )
}
