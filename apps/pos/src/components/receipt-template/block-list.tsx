import { type KeyboardEvent, type PointerEvent, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { TemplateData } from '../../lib/receipt-template/data';
import { MAX_BLOCKS } from '../../lib/receipt-template/render';
import type {
  DocumentType,
  PaperSize,
  TemplateBlock,
  TextSize,
} from '../../lib/receipt-template/types';
import { BLOCK_TYPES, type BlockType, WIDE_PAPERS } from '../../lib/receipt-template/validate';
import { PosIcon } from '../pos-icon';
import { BlockEditor, type BlockProblems } from './block-editor';

// The header or footer blocks in print order. Each block keeps a stable key
// so focus follows it when it moves.
export type KeyedBlock = { key: string; block: TemplateBlock };

export const keyBlocks = (blocks: TemplateBlock[]): KeyedBlock[] =>
  blocks.map((block) => ({ key: crypto.randomUUID(), block }));

// Documents without a number (pre-bill, payment ticket) have no barcode.
const UNNUMBERED: readonly DocumentType[] = ['prebill', 'payment_ticket'];

function newBlock(type: BlockType): TemplateBlock {
  switch (type) {
    case 'logo':
      return { type, width_pct: 60, align: 'center' };
    case 'business':
      return { type, fields: ['name', 'address', 'phone'], align: 'center' };
    case 'text':
      return { type, value: '', align: 'center' };
    case 'title':
      return { type };
    case 'divider':
      return { type, style: 'dashed' };
    case 'spacer':
      return { type, mm: 2 };
    case 'qr':
      return { type, source: 'url', value: '', align: 'center' };
    case 'barcode':
      return { type, align: 'center' };
    case 'signatures':
      return { type, parties: ['buyer', 'seller'] };
  }
}

// `list` with the block `key` moved to `target`; null when it stays put.
export function moveBlock(list: KeyedBlock[], key: string, target: number): KeyedBlock[] | null {
  const from = list.findIndex((item) => item.key === key);
  if (from < 0 || target < 0 || target >= list.length || target === from) return null;
  const next = [...list];
  const [item] = next.splice(from, 1);
  if (!item) return null;
  next.splice(target, 0, item);
  return next;
}

type Control = 'drag' | 'up' | 'down';
// A pointer drag in progress: the block and where it would land.
type Drag = { key: string; target: number };
// A keyboard grab: the block and the order to go back to on Escape.
type Grab = { key: string; from: KeyedBlock[] };

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
  place: 'header' | 'footer';
  blocks: KeyedBlock[];
  data: TemplateData;
  documentType: DocumentType;
  paper: PaperSize;
  pageSize: TextSize;
  readOnly: boolean;
  // Parts every print carries around these blocks, shown as locked rows.
  lockedBefore?: string[];
  lockedAfter?: string[];
  listProblem: string | null;
  problemsAt: (index: number) => BlockProblems;
  onChange: (blocks: KeyedBlock[]) => void;
}) {
  const { t } = useTranslation();
  const helpId = useId();
  const hasTitle = blocks.some((item) => item.block.type === 'title');
  const choices = BLOCK_TYPES.filter(
    (type) =>
      (type !== 'title' || (place === 'header' && !hasTitle)) &&
      (type !== 'barcode' || !UNNUMBERED.includes(documentType)) &&
      (type !== 'signatures' || WIDE_PAPERS.includes(paper)),
  );
  const [adding, setAdding] = useState<BlockType>('text');
  const addType = choices.includes(adding) ? adding : 'text';
  const full = blocks.length >= MAX_BLOCKS;
  const list = useRef<HTMLOListElement>(null);
  const [drag, setDrag] = useState<Drag | null>(null);
  const [grab, setGrab] = useState<Grab | null>(null);
  const [announcement, setAnnouncement] = useState('');
  // The control to focus again once a move re-rendered the list: moving a
  // block can take its focused button out of the page for a moment.
  const refocus = useRef<{ key: string; control: Control } | null>(null);

  useEffect(() => {
    const target = refocus.current;
    if (!target) return;
    refocus.current = null;
    list.current
      ?.querySelector<HTMLElement>(
        `[data-block-key="${target.key}"] [data-control="${target.control}"]`,
      )
      ?.focus();
  });

  const nameOf = (item: KeyedBlock) => t(`receiptTemplates.blockType.${item.block.type}`);
  const positionOf = (item: KeyedBlock, index: number) =>
    t('receiptTemplates.blockPosition', { name: nameOf(item), position: index + 1 });

  const move = (key: string, target: number, control: Control) => {
    const next = moveBlock(blocks, key, target);
    if (!next) return false;
    refocus.current = { key, control };
    onChange(next);
    return true;
  };

  // Where a block dragged to `clientY` lands: after every other block whose
  // middle is above the pointer.
  const dropIndex = (key: string, clientY: number) => {
    const rows = Array.from(
      list.current?.querySelectorAll<HTMLElement>('[data-block-key]') ?? [],
    ).filter((row) => row.dataset.blockKey !== key);
    return rows.filter((row) => {
      const box = row.getBoundingClientRect();
      return box.top + box.height / 2 < clientY;
    }).length;
  };

  const pointerDown = (event: PointerEvent<HTMLButtonElement>, item: KeyedBlock) => {
    if (event.button !== 0 || grab) return;
    event.currentTarget.setPointerCapture(event.pointerId);
    setDrag({ key: item.key, target: blocks.indexOf(item) });
  };
  const pointerMove = (event: PointerEvent<HTMLButtonElement>) => {
    if (!drag) return;
    const target = dropIndex(drag.key, event.clientY);
    if (target !== drag.target) setDrag({ ...drag, target });
  };
  const pointerUp = () => {
    if (!drag) return;
    setDrag(null);
    const item = blocks.find((other) => other.key === drag.key);
    if (item && move(drag.key, drag.target, 'drag'))
      setAnnouncement(
        t('receiptTemplates.drag.dropped', { name: nameOf(item), position: drag.target + 1 }),
      );
  };

  // Keyboard: Enter or Space picks the block up and puts it down, the arrow
  // keys move it, Escape puts it back where it was.
  const toggleGrab = (item: KeyedBlock, index: number) => {
    if (grab?.key === item.key) {
      setGrab(null);
      setAnnouncement(
        t('receiptTemplates.drag.dropped', { name: nameOf(item), position: index + 1 }),
      );
    } else {
      setGrab({ key: item.key, from: blocks });
      setAnnouncement(t('receiptTemplates.drag.grabbed', { name: positionOf(item, index) }));
    }
  };
  const handleKey = (event: KeyboardEvent, item: KeyedBlock, index: number) => {
    if (grab?.key !== item.key) return;
    if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
      event.preventDefault();
      const target = index + (event.key === 'ArrowUp' ? -1 : 1);
      if (move(item.key, target, 'drag'))
        setAnnouncement(
          t('receiptTemplates.drag.moved', {
            name: nameOf(item),
            position: target + 1,
            count: blocks.length,
          }),
        );
    } else if (event.key === 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      refocus.current = { key: item.key, control: 'drag' };
      onChange(grab.from);
      setGrab(null);
      setAnnouncement(t('receiptTemplates.drag.cancelled', { name: nameOf(item) }));
    }
  };

  // The block a pointer drag would land before or after, for the marker.
  const others = drag ? blocks.filter((item) => item.key !== drag.key) : [];
  const dropMark = (key: string): 'before' | 'after' | undefined => {
    if (!drag || drag.target === blocks.findIndex((item) => item.key === drag.key))
      return undefined;
    if (others[drag.target]?.key === key) return 'before';
    if (drag.target === others.length && others[others.length - 1]?.key === key) return 'after';
    return undefined;
  };

  return (
    <div className="rt-blocks">
      <ol ref={list} className="rt-block-list" aria-label={t(`receiptTemplates.section.${place}`)}>
        {lockedBefore.map((text) => (
          <li key={text} className="rt-block rt-block-locked">
            <PosIcon name="lock" />
            <span>{text}</span>
            <small className="rt-locked">{t('receiptTemplates.locked')}</small>
          </li>
        ))}
        {blocks.map((item, index) => {
          const problems = problemsAt(index);
          const position = positionOf(item, index);
          const lockedTitle = place === 'header' && item.block.type === 'title';
          const grabbed = grab?.key === item.key;
          return (
            <li
              key={item.key}
              className="rt-block"
              data-block-key={item.key}
              data-dragging={drag?.key === item.key || grabbed || undefined}
              data-drop={dropMark(item.key)}
              data-invalid={Object.keys(problems).length > 0 ? 'true' : undefined}
              aria-label={position}
            >
              <div className="rt-block-head">
                {readOnly ? null : (
                  <button
                    type="button"
                    className="rt-drag-handle"
                    data-control="drag"
                    aria-label={t('receiptTemplates.drag.handle', { name: position })}
                    aria-pressed={grabbed}
                    aria-describedby={helpId}
                    onPointerDown={(event) => pointerDown(event, item)}
                    onPointerMove={pointerMove}
                    onPointerUp={pointerUp}
                    onPointerCancel={() => setDrag(null)}
                    // Keyboard presses only: a mouse press is a drag.
                    onClick={(event) => {
                      if (event.detail === 0) toggleGrab(item, index);
                    }}
                    onKeyDown={(event) => handleKey(event, item, index)}
                    onBlur={() => {
                      // A move re-renders the list and may blur the handle for a moment.
                      if (grabbed && refocus.current?.key !== item.key) setGrab(null);
                    }}
                  >
                    <PosIcon name="list" />
                  </button>
                )}
                <strong>{position}</strong>
                {readOnly ? null : (
                  <div className="rt-block-actions">
                    <button
                      type="button"
                      // Stays focusable at the edge so focus follows the moved block.
                      data-control="up"
                      aria-disabled={index === 0 || undefined}
                      aria-label={t('receiptTemplates.moveUp', { name: position })}
                      onClick={() => move(item.key, index - 1, 'up')}
                    >
                      <PosIcon name="chevron" style={{ transform: 'rotate(180deg)' }} />
                    </button>
                    <button
                      type="button"
                      data-control="down"
                      aria-disabled={index === blocks.length - 1 || undefined}
                      aria-label={t('receiptTemplates.moveDown', { name: position })}
                      onClick={() => move(item.key, index + 1, 'down')}
                    >
                      <PosIcon name="chevron" />
                    </button>
                    <button
                      type="button"
                      className="danger-button"
                      disabled={lockedTitle}
                      title={lockedTitle ? t('receiptTemplates.block.titleLocked') : undefined}
                      aria-label={t('receiptTemplates.removeBlock', { name: position })}
                      onClick={() => onChange(blocks.filter((other) => other.key !== item.key))}
                    >
                      <PosIcon name="trash" />
                    </button>
                  </div>
                )}
              </div>
              {problems[''] ? <small className="rt-error">{problems['']}</small> : null}
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
          );
        })}
        {lockedAfter.map((text) => (
          <li key={text} className="rt-block rt-block-locked">
            <PosIcon name="lock" />
            <span>{text}</span>
            <small className="rt-locked">{t('receiptTemplates.locked')}</small>
          </li>
        ))}
      </ol>
      {readOnly ? null : (
        <p id={helpId} className="visually-hidden">
          {t('receiptTemplates.drag.help')}
        </p>
      )}
      <p className="visually-hidden" aria-live="assertive">
        {announcement}
      </p>
      {blocks.length === 0 ? <p className="muted">{t('receiptTemplates.noBlocks')}</p> : null}
      {listProblem ? <small className="rt-error">{listProblem}</small> : null}
      {readOnly ? null : (
        <div className="rt-add-block">
          <label>
            {t('receiptTemplates.blockTypeLabel')}
            <select
              value={addType}
              disabled={full}
              onChange={(event) => setAdding(event.target.value as BlockType)}
            >
              {choices.map((type) => (
                <option key={type} value={type}>
                  {t(`receiptTemplates.blockType.${type}`)}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            disabled={full}
            onClick={() =>
              onChange([...blocks, { key: crypto.randomUUID(), block: newBlock(addType) }])
            }
          >
            <PosIcon name="plus" />
            {t(`receiptTemplates.addBlock.${place}`)}
          </button>
          {full ? <small>{t('receiptTemplates.blocksFull', { count: MAX_BLOCKS })}</small> : null}
        </div>
      )}
    </div>
  );
}
