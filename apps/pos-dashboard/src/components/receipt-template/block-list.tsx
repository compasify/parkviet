import type { TemplateData } from '@parkviet/pos-shared/receipt-template/data'
import { MAX_BLOCKS } from '@parkviet/pos-shared/receipt-template/render'
import type {
  DocumentType,
  PaperSize,
  TemplateBlock,
  TextSize,
} from '@parkviet/pos-shared/receipt-template/types'
import {
  BLOCK_TYPES,
  type BlockType,
  WIDE_PAPERS,
} from '@parkviet/pos-shared/receipt-template/validate'
import { Button } from '@spree/dashboard-ui'
import {
  GripVerticalIcon,
  LockIcon,
  MoveDownIcon,
  MoveUpIcon,
  PlusIcon,
  Trash2Icon,
} from '@spree/dashboard-ui/icons'
import { type KeyboardEvent, type PointerEvent, useEffect, useId, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BlockEditor, type BlockProblems } from './block-editor'
import { Choice, Problem } from './controls'

export type KeyedBlock = { key: string; block: TemplateBlock }
export const keyBlocks = (blocks: TemplateBlock[]): KeyedBlock[] =>
  blocks.map((block) => ({ key: crypto.randomUUID(), block }))
const UNNUMBERED: readonly DocumentType[] = ['prebill', 'payment_ticket']
function newBlock(type: BlockType): TemplateBlock {
  switch (type) {
    case 'logo':
      return { type, width_pct: 60, align: 'center' }
    case 'business':
      return { type, fields: ['name', 'address', 'phone'], align: 'center' }
    case 'text':
      return { type, value: '', align: 'center' }
    case 'title':
      return { type }
    case 'divider':
      return { type, style: 'dashed' }
    case 'spacer':
      return { type, mm: 2 }
    case 'qr':
      return { type, source: 'url', value: '', align: 'center' }
    case 'barcode':
      return { type, align: 'center' }
    case 'signatures':
      return { type, parties: ['buyer', 'seller'] }
  }
}
export function moveBlock(list: KeyedBlock[], key: string, target: number): KeyedBlock[] | null {
  const from = list.findIndex((item) => item.key === key)
  if (from < 0 || target < 0 || target >= list.length || target === from) return null
  const next = [...list]
  const [item] = next.splice(from, 1)
  if (!item) return null
  next.splice(target, 0, item)
  return next
}
type Control = 'drag' | 'up' | 'down'
type Drag = { key: string; target: number }
type Grab = { key: string; from: KeyedBlock[] }

export function BlockList({
  place,
  blocks,
  data,
  documentType,
  paper,
  pageSize,
  readOnly,
  lockedBefore = [],
  lockedAfter = [],
  listProblem,
  problemsAt,
  onChange,
}: {
  place: 'header' | 'footer'
  blocks: KeyedBlock[]
  data: TemplateData
  documentType: DocumentType
  paper: PaperSize
  pageSize: TextSize
  readOnly: boolean
  lockedBefore?: string[]
  lockedAfter?: string[]
  listProblem: string | null
  problemsAt: (index: number) => BlockProblems
  onChange: (blocks: KeyedBlock[]) => void
}) {
  const { t } = useTranslation('pos')
  const helpId = useId()
  const hasTitle = blocks.some((item) => item.block.type === 'title')
  const choices = BLOCK_TYPES.filter(
    (type) =>
      (type !== 'title' || (place === 'header' && !hasTitle)) &&
      (type !== 'barcode' || !UNNUMBERED.includes(documentType)) &&
      (type !== 'signatures' || WIDE_PAPERS.includes(paper)),
  )
  const [adding, setAdding] = useState<BlockType>('text')
  const addType = choices.includes(adding) ? adding : 'text'
  const full = blocks.length >= MAX_BLOCKS
  const list = useRef<HTMLOListElement>(null)
  const [drag, setDrag] = useState<Drag | null>(null)
  const [grab, setGrab] = useState<Grab | null>(null)
  const [announcement, setAnnouncement] = useState('')
  const refocus = useRef<{ key: string; control: Control } | null>(null)
  useEffect(() => {
    const target = refocus.current
    if (!target) return
    refocus.current = null
    list.current
      ?.querySelector<HTMLElement>(
        `[data-block-key="${target.key}"] [data-control="${target.control}"]`,
      )
      ?.focus()
  })
  const nameOf = (item: KeyedBlock) => t(`receiptTemplates.blockType.${item.block.type}`)
  const positionOf = (item: KeyedBlock, index: number) =>
    t('receiptTemplates.blockPosition', { name: nameOf(item), position: index + 1 })
  const move = (key: string, target: number, control: Control) => {
    const next = moveBlock(blocks, key, target)
    if (!next) return false
    refocus.current = { key, control }
    onChange(next)
    return true
  }
  const dropIndex = (key: string, clientY: number) =>
    Array.from(list.current?.querySelectorAll<HTMLElement>('[data-block-key]') ?? [])
      .filter((row) => row.dataset.blockKey !== key)
      .filter((row) => {
        const box = row.getBoundingClientRect()
        return box.top + box.height / 2 < clientY
      }).length
  const pointerDown = (event: PointerEvent<HTMLButtonElement>, item: KeyedBlock) => {
    if (event.button !== 0 || grab) return
    event.currentTarget.setPointerCapture(event.pointerId)
    setDrag({ key: item.key, target: blocks.indexOf(item) })
  }
  const pointerMove = (event: PointerEvent<HTMLButtonElement>) => {
    if (!drag) return
    const target = dropIndex(drag.key, event.clientY)
    if (target !== drag.target) setDrag({ ...drag, target })
  }
  const pointerUp = () => {
    if (!drag) return
    setDrag(null)
    const item = blocks.find((other) => other.key === drag.key)
    if (item && move(drag.key, drag.target, 'drag'))
      setAnnouncement(
        t('receiptTemplates.drag.dropped', { name: nameOf(item), position: drag.target + 1 }),
      )
  }
  const toggleGrab = (item: KeyedBlock, index: number) => {
    if (grab?.key === item.key) {
      setGrab(null)
      setAnnouncement(
        t('receiptTemplates.drag.dropped', { name: nameOf(item), position: index + 1 }),
      )
    } else {
      setGrab({ key: item.key, from: blocks })
      setAnnouncement(t('receiptTemplates.drag.grabbed', { name: positionOf(item, index) }))
    }
  }
  const handleKey = (event: KeyboardEvent, item: KeyedBlock, index: number) => {
    if (grab?.key !== item.key) return
    if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
      event.preventDefault()
      const target = index + (event.key === 'ArrowUp' ? -1 : 1)
      if (move(item.key, target, 'drag'))
        setAnnouncement(
          t('receiptTemplates.drag.moved', {
            name: nameOf(item),
            position: target + 1,
            count: blocks.length,
          }),
        )
    } else if (event.key === 'Escape') {
      event.preventDefault()
      event.stopPropagation()
      refocus.current = { key: item.key, control: 'drag' }
      onChange(grab.from)
      setGrab(null)
      setAnnouncement(t('receiptTemplates.drag.cancelled', { name: nameOf(item) }))
    }
  }
  const others = drag ? blocks.filter((item) => item.key !== drag.key) : []
  const dropMark = (key: string) => {
    if (!drag || drag.target === blocks.findIndex((item) => item.key === drag.key)) return undefined
    if (others[drag.target]?.key === key) return 'before'
    if (drag.target === others.length && others[others.length - 1]?.key === key) return 'after'
    return undefined
  }
  const lockedRow = (text: string) => (
    <li
      key={text}
      className="flex items-start gap-2 rounded-lg border border-dashed bg-muted/40 p-3 text-sm text-muted-foreground"
    >
      <LockIcon className="mt-0.5 size-4 shrink-0" />
      <span>{text}</span>
      <small className="ml-auto">{t('receiptTemplates.locked')}</small>
    </li>
  )
  return (
    <div className="grid gap-4">
      <ol ref={list} className="grid gap-3" aria-label={t(`receiptTemplates.section.${place}`)}>
        {lockedBefore.map(lockedRow)}
        {blocks.map((item, index) => {
          const problems = problemsAt(index)
          const position = positionOf(item, index)
          const lockedTitle = place === 'header' && item.block.type === 'title'
          const grabbed = grab?.key === item.key
          return (
            <li
              key={item.key}
              className="grid gap-3 rounded-lg border bg-card p-3 data-[invalid=true]:border-destructive data-[drop=before]:border-t-blue-500 data-[drop=before]:border-t-4 data-[drop=after]:border-b-blue-500 data-[drop=after]:border-b-4 data-[dragging=true]:opacity-60"
              data-block-key={item.key}
              data-dragging={drag?.key === item.key || grabbed || undefined}
              data-drop={dropMark(item.key)}
              data-invalid={Object.keys(problems).length > 0 ? 'true' : undefined}
              aria-label={position}
            >
              <div className="flex flex-wrap items-center gap-2">
                {!readOnly ? (
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon-sm"
                    className="touch-none cursor-grab"
                    data-control="drag"
                    aria-label={t('receiptTemplates.drag.handle', { name: position })}
                    aria-pressed={grabbed}
                    aria-describedby={helpId}
                    onPointerDown={(event) => pointerDown(event, item)}
                    onPointerMove={pointerMove}
                    onPointerUp={pointerUp}
                    onPointerCancel={() => setDrag(null)}
                    onClick={(event) => {
                      if (event.detail === 0) toggleGrab(item, index)
                    }}
                    onKeyDown={(event) => handleKey(event, item, index)}
                    onBlur={() => {
                      if (grabbed && refocus.current?.key !== item.key) setGrab(null)
                    }}
                  >
                    <GripVerticalIcon />
                  </Button>
                ) : null}
                <strong className="mr-auto text-sm">{position}</strong>
                {!readOnly ? (
                  <div className="flex gap-1">
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon-sm"
                      data-control="up"
                      aria-disabled={index === 0 || undefined}
                      aria-label={t('receiptTemplates.moveUp', { name: position })}
                      onClick={() => move(item.key, index - 1, 'up')}
                    >
                      <MoveUpIcon />
                    </Button>
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon-sm"
                      data-control="down"
                      aria-disabled={index === blocks.length - 1 || undefined}
                      aria-label={t('receiptTemplates.moveDown', { name: position })}
                      onClick={() => move(item.key, index + 1, 'down')}
                    >
                      <MoveDownIcon />
                    </Button>
                    <Button
                      type="button"
                      variant="destructive-ghost"
                      size="icon-sm"
                      disabled={lockedTitle}
                      title={lockedTitle ? t('receiptTemplates.block.titleLocked') : undefined}
                      aria-label={t('receiptTemplates.removeBlock', { name: position })}
                      onClick={() => onChange(blocks.filter((other) => other.key !== item.key))}
                    >
                      <Trash2Icon />
                    </Button>
                  </div>
                ) : null}
              </div>
              <Problem>{problems['']}</Problem>
              <BlockEditor
                block={item.block}
                data={data}
                paper={paper}
                pageSize={pageSize}
                readOnly={readOnly}
                problems={problems}
                onChange={(block) =>
                  onChange(
                    blocks.map((other) => (other.key === item.key ? { ...other, block } : other)),
                  )
                }
              />
            </li>
          )
        })}
        {lockedAfter.map(lockedRow)}
      </ol>
      {!readOnly ? (
        <p id={helpId} className="sr-only">
          {t('receiptTemplates.drag.help')}
        </p>
      ) : null}
      <p className="sr-only" aria-live="assertive">
        {announcement}
      </p>
      {blocks.length === 0 ? (
        <p className="text-sm text-muted-foreground">{t('receiptTemplates.noBlocks')}</p>
      ) : null}
      <Problem>{listProblem}</Problem>
      {!readOnly ? (
        <div className="grid gap-3 sm:grid-cols-[1fr_auto] sm:items-end">
          <Choice
            label={t('receiptTemplates.blockTypeLabel')}
            value={addType}
            disabled={full}
            options={choices.map((value) => ({
              value,
              label: t(`receiptTemplates.blockType.${value}`),
            }))}
            onChange={setAdding}
          />
          <Button
            type="button"
            variant="outline"
            disabled={full}
            onClick={() =>
              onChange([...blocks, { key: crypto.randomUUID(), block: newBlock(addType) }])
            }
          >
            <PlusIcon />
            {t(`receiptTemplates.addBlock.${place}`)}
          </Button>
          {full ? <small>{t('receiptTemplates.blocksFull', { count: MAX_BLOCKS })}</small> : null}
        </div>
      ) : null}
    </div>
  )
}
