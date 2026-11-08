import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { TemplateData } from '../../lib/receipt-template/data';
import { MAX_BLOCKS } from '../../lib/receipt-template/render';
import type { PaperSize, TemplateBlock, TextSize } from '../../lib/receipt-template/types';
import { BLOCK_TYPES, type BlockType } from '../../lib/receipt-template/validate';
import { PosIcon } from '../pos-icon';
import { BlockEditor, type BlockProblems } from './block-editor';

// The header or footer blocks in print order. Each block keeps a stable key
// so focus follows it when it moves.
export type KeyedBlock = { key: string; block: TemplateBlock };

export const keyBlocks = (blocks: TemplateBlock[]): KeyedBlock[] =>
  blocks.map((block) => ({ key: crypto.randomUUID(), block }));

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
  }
}

export function BlockList({
  place,
  blocks,
  data,
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
  const hasTitle = blocks.some((item) => item.block.type === 'title');
  const choices = BLOCK_TYPES.filter(
    (type) => type !== 'title' || (place === 'header' && !hasTitle),
  );
  const [adding, setAdding] = useState<BlockType>('text');
  const addType = choices.includes(adding) ? adding : 'text';
  const full = blocks.length >= MAX_BLOCKS;

  const move = (index: number, step: -1 | 1) => {
    if (index + step < 0 || index + step >= blocks.length) return;
    const next = [...blocks];
    const [item] = next.splice(index, 1);
    if (!item) return;
    next.splice(index + step, 0, item);
    onChange(next);
  };

  return (
    <div className="rt-blocks">
      <ol className="rt-block-list" aria-label={t(`receiptTemplates.section.${place}`)}>
        {lockedBefore.map((text) => (
          <li key={text} className="rt-block rt-block-locked">
            <PosIcon name="lock" />
            <span>{text}</span>
            <small className="rt-locked">{t('receiptTemplates.locked')}</small>
          </li>
        ))}
        {blocks.map((item, index) => {
          const problems = problemsAt(index);
          const name = t(`receiptTemplates.blockType.${item.block.type}`);
          const position = t('receiptTemplates.blockPosition', { name, position: index + 1 });
          const lockedTitle = place === 'header' && item.block.type === 'title';
          return (
            <li
              key={item.key}
              className="rt-block"
              data-invalid={Object.keys(problems).length > 0 ? 'true' : undefined}
              aria-label={position}
            >
              <div className="rt-block-head">
                <strong>{position}</strong>
                {readOnly ? null : (
                  <div className="rt-block-actions">
                    <button
                      type="button"
                      // Stays focusable at the edge so focus follows the moved block.
                      aria-disabled={index === 0 || undefined}
                      aria-label={t('receiptTemplates.moveUp', { name: position })}
                      onClick={() => move(index, -1)}
                    >
                      <PosIcon name="chevron" style={{ transform: 'rotate(180deg)' }} />
                    </button>
                    <button
                      type="button"
                      aria-disabled={index === blocks.length - 1 || undefined}
                      aria-label={t('receiptTemplates.moveDown', { name: position })}
                      onClick={() => move(index, 1)}
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
