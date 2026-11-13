import type { FloorArea, Placement, ResourceRecord } from '@parkviet/pos-shared/tables'
import { Button } from '@spree/dashboard-ui'
import { LocateFixed, Minus, Plus } from 'lucide-react'
import {
  type KeyboardEvent,
  type PointerEvent,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from 'react'
import { useTranslation } from 'react-i18next'
import { FLOOR_MAX, nudgePlacement, rectanglePlacement, shiftPlacement } from '../lib/floor-plan'

// Cells are always square. The grid lines cover the whole frame at any zoom,
// so the floor reads as endless; the tables sit centred in it. Zoom changes the
// cell size; the frame never scrolls. A drag past the edge adds cells.
const MIN_ZOOM = 0.5
const MAX_ZOOM = 3
const OPEN = { floor_width: FLOOR_MAX, floor_height: FLOOR_MAX }

export type CanvasTable = Pick<ResourceRecord, 'name' | 'capacity' | 'shape' | 'manual_status'> &
  Placement & { key: string }

type Drag = { mode: 'move' | 'resize'; x: number; y: number; start: Placement; pointer: number }
type Sketch = {
  pointer: number
  x: number
  y: number
  origin: { x: number; y: number }
  placement: Placement
}

const placementOf = ({ x, y, w, h, rotation }: Placement): Placement => ({ x, y, w, h, rotation })

const clampZoom = (value: number) => Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, value))

// One area's plan. Its cells fit the tables into the frame at zoom 1; the
// wheel and the buttons zoom around the centre. Dragging empty space pans the
// view, except while adding, when it draws the new table instead.
export function FloorPlanCanvas({
  area,
  tables,
  selected,
  write,
  zoom = 1,
  onZoom,
  onSelect,
  onPlace,
  onDraw,
  onExtend,
  adding = false,
  onAdding,
  onAddTable,
}: {
  area: Pick<FloorArea, 'name' | 'floor_width' | 'floor_height'>
  tables: CanvasTable[]
  selected: string | null
  write: boolean
  zoom?: number
  onZoom?: (zoom: number) => void
  onSelect: (key: string) => void
  onPlace: (placement: Placement) => void
  onDraw?: (placement: Placement) => void
  onExtend?: (floor: { floor_width: number; floor_height: number }) => void
  adding?: boolean
  onAdding?: (adding: boolean) => void
  onAddTable?: () => void
}) {
  const { t } = useTranslation()
  const drag = useRef<Drag | null>(null)
  const sketch = useRef<Sketch | null>(null)
  const placed = useRef<Placement | null>(null)
  const frame = useRef<HTMLElement>(null)
  const zoomRef = useRef(zoom)
  const [box, setBox] = useState({ width: 0, height: 0 })
  const [drawing, setDrawing] = useState<Placement | null>(null)
  const [pan, setPan] = useState({ x: 0, y: 0 })
  const panning = useRef<{ pointer: number; x: number; y: number; start: typeof pan } | null>(null)
  // Zooming keeps the point at the frame's centre where it was.
  const [shownZoom, setShownZoom] = useState(zoom)
  if (shownZoom !== zoom) {
    const ratio = zoom / shownZoom
    setShownZoom(zoom)
    setPan((current) => ({ x: current.x * ratio, y: current.y * ratio }))
  }
  zoomRef.current = zoom
  const drawMode = adding && write && Boolean(onDraw)

  useLayoutEffect(() => {
    const node = frame.current
    if (!node) return
    const measure = () => setBox({ width: node.clientWidth, height: node.clientHeight })
    measure()
    const observer = new ResizeObserver(measure)
    observer.observe(node)
    return () => observer.disconnect()
  }, [])

  useEffect(() => {
    const node = frame.current
    if (!node || !onZoom) return
    const wheel = (event: WheelEvent) => {
      event.preventDefault()
      const factor = event.deltaY < 0 ? 1.15 : 1 / 1.15
      onZoom(clampZoom(zoomRef.current * factor))
    }
    node.addEventListener('wheel', wheel, { passive: false })
    return () => node.removeEventListener('wheel', wheel)
  }, [onZoom])

  let reachX = 0
  let reachY = 0
  for (const table of tables) {
    reachX = Math.max(reachX, table.x + table.w)
    reachY = Math.max(reachY, table.y + table.h)
  }
  if (drawing) {
    reachX = Math.max(reachX, drawing.x + drawing.w)
    reachY = Math.max(reachY, drawing.y + drawing.h)
  }
  // The editor shows room around the tables, so its cells start smaller.
  const cols = Math.min(FLOOR_MAX, write ? Math.max(reachX + 4, 24) : Math.max(reachX, 12))
  const rows = Math.min(FLOOR_MAX, write ? Math.max(reachY + 4, 16) : Math.max(reachY, 8))

  // Square cells sized so the tables' span fits the frame, then zoomed; the
  // span is centred, and the grid lines run on past it to the frame's edges.
  const cell = Math.max(1, Math.min((box.width || 1) / cols, (box.height || 1) / rows) * zoom)
  const offsetX = ((box.width || 0) - cols * cell) / 2 + pan.x
  const offsetY = ((box.height || 0) - rows * cell) / 2 + pan.y

  const cellDelta = (pixelsX: number, pixelsY: number) => ({
    dx: pixelsX / cell,
    dy: pixelsY / cell,
  })
  const cellAt = (clientX: number, clientY: number) => {
    const rect = frame.current?.getBoundingClientRect()
    const along = (pixels: number) =>
      Math.min(FLOOR_MAX - 1, Math.max(0, Math.floor(pixels / cell)))
    return {
      x: along(clientX - (rect?.left ?? 0) - (frame.current?.clientLeft ?? 0) - offsetX),
      y: along(clientY - (rect?.top ?? 0) - (frame.current?.clientTop ?? 0) - offsetY),
    }
  }
  const extend = (placement: Placement) => {
    const floor_width = Math.min(FLOOR_MAX, Math.max(area.floor_width, placement.x + placement.w))
    const floor_height = Math.min(FLOOR_MAX, Math.max(area.floor_height, placement.y + placement.h))
    if (floor_width !== area.floor_width || floor_height !== area.floor_height)
      onExtend?.({ floor_width, floor_height })
  }

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
    const next = shiftPlacement(
      current.start,
      cellDelta(event.clientX - current.x, event.clientY - current.y),
      current.mode,
      OPEN,
    )
    placed.current = next
    onPlace(next)
  }
  const end = (event: PointerEvent<HTMLElement>) => {
    if (drag.current?.pointer !== event.pointerId) return
    drag.current = null
    if (placed.current) extend(placed.current)
    placed.current = null
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
    const next = nudgePlacement(placementOf(table), event.key, event.shiftKey, OPEN)
    if (!next) return
    event.preventDefault()
    onPlace(next)
    extend(next)
  }
  const handlers = (table: CanvasTable, mode: Drag['mode']) => ({
    onPointerDown: (event: PointerEvent<HTMLElement>) => begin(event, table, mode),
    onPointerMove: move,
    onPointerUp: end,
    onPointerCancel: end,
  })

  const beginDraw = (event: PointerEvent<HTMLElement>) => {
    if (event.button !== 0) return
    if ((event.target as Element).closest('[data-testid="floor-table"]')) return
    if (!drawMode) {
      if (!onZoom) return
      event.currentTarget.setPointerCapture(event.pointerId)
      panning.current = { pointer: event.pointerId, x: event.clientX, y: event.clientY, start: pan }
      return
    }
    const origin = cellAt(event.clientX, event.clientY)
    event.currentTarget.setPointerCapture(event.pointerId)
    sketch.current = {
      pointer: event.pointerId,
      x: event.clientX,
      y: event.clientY,
      origin,
      placement: rectanglePlacement(origin, origin),
    }
    setDrawing(sketch.current.placement)
  }
  const moveDraw = (event: PointerEvent<HTMLElement>) => {
    const grab = panning.current
    if (grab?.pointer === event.pointerId) {
      setPan({
        x: grab.start.x + event.clientX - grab.x,
        y: grab.start.y + event.clientY - grab.y,
      })
      return
    }
    const current = sketch.current
    if (!current || current.pointer !== event.pointerId) return
    current.placement = rectanglePlacement(current.origin, cellAt(event.clientX, event.clientY))
    setDrawing(current.placement)
  }
  const endDraw = (event: PointerEvent<HTMLElement>) => {
    if (event.currentTarget.hasPointerCapture(event.pointerId))
      event.currentTarget.releasePointerCapture(event.pointerId)
    if (panning.current?.pointer === event.pointerId) panning.current = null
    const current = sketch.current
    if (!current || current.pointer !== event.pointerId) return
    sketch.current = null
    setDrawing(null)
    // A click without a drag places a 2 × 2 table at that cell.
    const moved = Math.hypot(event.clientX - current.x, event.clientY - current.y)
    const placement =
      moved >= 6
        ? current.placement
        : rectanglePlacement(current.origin, {
            x: Math.min(FLOOR_MAX - 1, current.origin.x + 1),
            y: Math.min(FLOOR_MAX - 1, current.origin.y + 1),
          })
    onDraw?.(placement)
    extend(placement)
    onAdding?.(false)
  }

  const boxOf = (placement: Placement) => ({
    left: offsetX + placement.x * cell,
    top: offsetY + placement.y * cell,
    width: placement.w * cell,
    height: placement.h * cell,
  })
  const fit = () => {
    setPan({ x: 0, y: 0 })
    onZoom?.(1)
  }

  return (
    <div className="relative h-full min-h-0">
      <section
        ref={frame}
        aria-label={t('floorPlan.canvas', { name: area.name })}
        className={`relative h-full overflow-hidden rounded-lg border bg-background ${drawMode ? 'touch-none cursor-crosshair' : onZoom ? 'touch-none cursor-grab active:cursor-grabbing' : ''}`}
        style={{
          backgroundImage:
            'linear-gradient(to right, var(--border) 1px, transparent 1px), linear-gradient(to bottom, var(--border) 1px, transparent 1px)',
          backgroundSize: `${cell}px ${cell}px`,
          backgroundPosition: `${offsetX}px ${offsetY}px`,
        }}
        onPointerDown={beginDraw}
        onPointerMove={moveDraw}
        onPointerUp={endDraw}
        onPointerCancel={endDraw}
      >
        {drawing ? (
          <div
            aria-hidden="true"
            className="pointer-events-none absolute border-2 border-dashed border-primary bg-primary/10"
            style={boxOf(drawing)}
          />
        ) : null}
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
                ...boxOf(table),
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
      {onZoom ? (
        <div className="absolute top-3 right-3 z-20 flex items-start gap-2">
          <span className="rounded-md border bg-card px-2 py-1 text-xs tabular-nums text-muted-foreground shadow-md">
            {t('floorPlan.zoomLevel', { percent: Math.round(zoom * 100) })}
          </span>
          <div className="flex flex-col overflow-hidden rounded-lg border bg-card shadow-md">
            <Button
              type="button"
              size="icon-sm"
              variant="ghost"
              aria-label={t('floorPlan.zoomIn')}
              onClick={() => onZoom(clampZoom(zoom * 1.25))}
            >
              <Plus />
            </Button>
            <Button
              type="button"
              size="icon-sm"
              variant="ghost"
              aria-label={t('floorPlan.zoomOut')}
              onClick={() => onZoom(clampZoom(zoom / 1.25))}
            >
              <Minus />
            </Button>
            <Button
              type="button"
              size="icon-sm"
              variant="ghost"
              aria-label={t('floorPlan.zoomFit')}
              onClick={fit}
            >
              <LocateFixed />
            </Button>
          </div>
        </div>
      ) : null}
      {onAdding ? (
        <div className="absolute bottom-3 left-3 z-20 flex items-center gap-2">
          {drawMode ? (
            <>
              <Button
                type="button"
                variant="outline"
                className="shadow-md"
                onClick={() => onAdding(false)}
              >
                {t('adminCancel')}
              </Button>
              <span className="rounded-md border bg-card px-2 py-1 text-xs text-muted-foreground shadow-md">
                {t('floorPlan.drawHint')}
              </span>
            </>
          ) : (
            <Button
              type="button"
              className="shadow-md"
              // From the keyboard there is nothing to drag: add the table at
              // the first free spot instead.
              onClick={(event) => (event.detail === 0 ? onAddTable?.() : onAdding(true))}
            >
              {t('floorPlan.addTable')}
            </Button>
          )}
        </div>
      ) : null}
    </div>
  )
}
