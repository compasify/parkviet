import { useId } from 'react';
import { useTranslation } from 'react-i18next';
import type { TemplateData } from '../../lib/receipt-template/data';
import { MAX_TEXT_LENGTH, MAX_TITLE_LENGTH } from '../../lib/receipt-template/render';
import type {
  Align,
  BusinessField,
  PaperSize,
  TemplateBlock,
  TextSize,
} from '../../lib/receipt-template/types';
import { BUSINESS_FIELDS, charsPerLine, overlongLines } from '../../lib/receipt-template/validate';
import { resolveText, variableValues } from '../../lib/receipt-template/variables';
import { TemplateTextField } from './variable-picker';

export type BlockProblems = Partial<Record<string, string>>;

const ALIGNS: readonly Align[] = ['left', 'center', 'right'];
const SIZES: readonly TextSize[] = ['s', 'm', 'l'];

const numberOr = (text: string, fallback: number) => {
  const value = Number(text);
  return text.trim() !== '' && Number.isFinite(value) ? value : fallback;
};

function AlignPicker({
  value,
  readOnly,
  onChange,
}: {
  value: Align | undefined;
  readOnly: boolean;
  onChange: (align: Align) => void;
}) {
  const { t } = useTranslation();
  return (
    <label>
      {t('receiptTemplates.block.align')}
      <select
        value={value ?? 'center'}
        disabled={readOnly}
        onChange={(event) => onChange(event.target.value as Align)}
      >
        {ALIGNS.map((align) => (
          <option key={align} value={align}>
            {t(`receiptTemplates.align.${align}`)}
          </option>
        ))}
      </select>
    </label>
  );
}

// The settings of one header or footer block. `problems` holds the error of
// each setting (by key) or of the whole block (`''`).
export function BlockEditor({
  block,
  data,
  paper,
  pageSize,
  readOnly,
  problems,
  onChange,
}: {
  block: TemplateBlock;
  data: TemplateData;
  paper: PaperSize;
  pageSize: TextSize;
  readOnly: boolean;
  problems: BlockProblems;
  onChange: (block: TemplateBlock) => void;
}) {
  const { t } = useTranslation();
  const id = useId();
  const error = (key: string) =>
    problems[key] ? (
      <small id={`${id}-${key}-error`} className="rt-error">
        {problems[key]}
      </small>
    ) : null;
  const describedBy = (key: string) => (problems[key] ? `${id}-${key}-error` : undefined);

  switch (block.type) {
    case 'logo':
      return (
        <div className="rt-block-fields">
          <label>
            {t('receiptTemplates.block.logoWidth')}
            <input
              type="number"
              min={20}
              max={100}
              step={5}
              value={block.width_pct ?? 60}
              disabled={readOnly}
              aria-invalid={problems.width_pct ? true : undefined}
              aria-describedby={describedBy('width_pct')}
              onChange={(event) =>
                onChange({ ...block, width_pct: numberOr(event.target.value, 0) })
              }
            />
          </label>
          {error('width_pct')}
          <AlignPicker
            value={block.align}
            readOnly={readOnly}
            onChange={(align) => onChange({ ...block, align })}
          />
          {data.store.logoUrl ? null : (
            <small className="rt-field-note">{t('receiptTemplates.block.logoMissing')}</small>
          )}
        </div>
      );
    case 'business': {
      const enabled = new Set<string>(block.fields);
      const toggle = (field: BusinessField, on: boolean) =>
        onChange({
          ...block,
          fields: on
            ? BUSINESS_FIELDS.filter((item) => item === field || enabled.has(item))
            : block.fields.filter((item) => item !== field),
        });
      return (
        <div className="rt-block-fields">
          <fieldset className="rt-checks" aria-describedby={describedBy('fields')}>
            <legend>{t('receiptTemplates.block.businessFields')}</legend>
            {BUSINESS_FIELDS.map((field) => (
              <label key={field}>
                <input
                  type="checkbox"
                  checked={enabled.has(field)}
                  disabled={readOnly}
                  onChange={(event) => toggle(field, event.target.checked)}
                />
                {t(`receiptTemplates.business.${field}`)}
              </label>
            ))}
          </fieldset>
          {error('fields')}
          <AlignPicker
            value={block.align}
            readOnly={readOnly}
            onChange={(align) => onChange({ ...block, align })}
          />
        </div>
      );
    }
    case 'text': {
      const limit = charsPerLine(paper, pageSize, block.size ?? 'm');
      const long = overlongLines(
        block.value
          .split(/\r?\n/)
          .map((line) => resolveText(line, data))
          .filter((line) => !line.blank)
          .map((line) => line.text),
        limit,
      );
      return (
        <div className="rt-block-fields">
          <TemplateTextField
            label={t('receiptTemplates.block.text')}
            value={block.value}
            samples={variableValues(data)}
            maxLength={MAX_TEXT_LENGTH}
            readOnly={readOnly}
            invalid={Boolean(problems.value)}
            describedBy={describedBy('value')}
            onChange={(value) => onChange({ ...block, value })}
          />
          {error('value')}
          {long.length > 0 ? (
            <small className="rt-warning">
              {t('receiptTemplates.block.tooWide', { count: limit ?? 0, paper })}
            </small>
          ) : null}
          <div className="rt-inline-fields">
            <AlignPicker
              value={block.align}
              readOnly={readOnly}
              onChange={(align) => onChange({ ...block, align })}
            />
            <label>
              {t('receiptTemplates.block.size')}
              <select
                value={block.size ?? 'm'}
                disabled={readOnly}
                onChange={(event) => onChange({ ...block, size: event.target.value as TextSize })}
              >
                {SIZES.map((size) => (
                  <option key={size} value={size}>
                    {t(`receiptTemplates.size.${size}`)}
                  </option>
                ))}
              </select>
            </label>
            <label>
              <input
                type="checkbox"
                checked={block.bold === true}
                disabled={readOnly}
                onChange={(event) => onChange({ ...block, bold: event.target.checked })}
              />
              {t('receiptTemplates.block.bold')}
            </label>
          </div>
        </div>
      );
    }
    case 'title':
      return (
        <div className="rt-block-fields">
          <label>
            {t('receiptTemplates.block.titleLabel')}
            <input
              value={block.label ?? ''}
              placeholder={data.title}
              maxLength={MAX_TITLE_LENGTH}
              disabled={readOnly}
              aria-invalid={problems.label ? true : undefined}
              aria-describedby={describedBy('label')}
              onChange={(event) => {
                const { label: _previous, ...rest } = block;
                onChange(event.target.value === '' ? rest : { ...rest, label: event.target.value });
              }}
            />
          </label>
          {error('label')}
          <small className="rt-locked">{t('receiptTemplates.block.titleLocked')}</small>
        </div>
      );
    case 'divider':
      return (
        <div className="rt-block-fields">
          <label>
            {t('receiptTemplates.block.dividerStyle')}
            <select
              value={block.style ?? 'dashed'}
              disabled={readOnly}
              onChange={(event) =>
                onChange({ ...block, style: event.target.value as 'solid' | 'dashed' })
              }
            >
              <option value="dashed">{t('receiptTemplates.block.dashed')}</option>
              <option value="solid">{t('receiptTemplates.block.solid')}</option>
            </select>
          </label>
        </div>
      );
    case 'spacer':
      return (
        <div className="rt-block-fields">
          <label>
            {t('receiptTemplates.block.spacerMm')}
            <input
              type="number"
              min={1}
              max={10}
              value={block.mm ?? 2}
              disabled={readOnly}
              aria-invalid={problems.mm ? true : undefined}
              aria-describedby={describedBy('mm')}
              onChange={(event) => onChange({ ...block, mm: numberOr(event.target.value, 0) })}
            />
          </label>
          {error('mm')}
        </div>
      );
  }
}
