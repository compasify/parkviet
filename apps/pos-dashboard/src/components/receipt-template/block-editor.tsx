import { barcodeWidthMm } from '@parkviet/pos-shared/receipt-template/code128'
import type { TemplateData } from '@parkviet/pos-shared/receipt-template/data'
import {
  businessLines,
  MAX_CAPTION_LENGTH,
  MAX_LABEL_LENGTH,
  MAX_TEXT_LENGTH,
  MAX_TITLE_LENGTH,
  MAX_URL_LENGTH,
} from '@parkviet/pos-shared/receipt-template/render'
import type {
  Align,
  BusinessField,
  PaperSize,
  QrBlock,
  SignatureParty,
  SocialField,
  TemplateBlock,
  TextSize,
} from '@parkviet/pos-shared/receipt-template/types'
import {
  BUSINESS_FIELDS,
  charsPerLine,
  overlongLines,
  PRINTABLE_WIDTH_MM,
  SIGNATURE_PARTIES,
  SOCIAL_FIELDS,
  WIDE_PAPERS,
} from '@parkviet/pos-shared/receipt-template/validate'
import { resolveText, variableValues } from '@parkviet/pos-shared/receipt-template/variables'
import { Input, Label } from '@spree/dashboard-ui'
import { type ReactNode, useId } from 'react'
import { useTranslation } from 'react-i18next'
import { Check, Choice, Problem } from './controls'
import { TemplateTextField } from './variable-picker'

export type BlockProblems = Partial<Record<string, string>>
const numberOr = (text: string, fallback: number) =>
  text.trim() !== '' && Number.isFinite(Number(text)) ? Number(text) : fallback

function AlignPicker({
  value,
  readOnly,
  onChange,
}: {
  value: Align | undefined
  readOnly: boolean
  onChange: (align: Align) => void
}) {
  const { t } = useTranslation('pos')
  return (
    <Choice
      label={t('receiptTemplates.block.align')}
      value={value ?? 'center'}
      disabled={readOnly}
      options={(['left', 'center', 'right'] as const).map((value) => ({
        value,
        label: t(`receiptTemplates.align.${value}`),
      }))}
      onChange={onChange}
    />
  )
}

export function BlockEditor({
  block,
  data,
  paper,
  pageSize,
  readOnly,
  problems,
  onChange,
}: {
  block: TemplateBlock
  data: TemplateData
  paper: PaperSize
  pageSize: TextSize
  readOnly: boolean
  problems: BlockProblems
  onChange: (block: TemplateBlock) => void
}) {
  const { t } = useTranslation('pos')
  const id = useId()
  const error = (key: string) => <Problem id={`${id}-${key}-error`}>{problems[key]}</Problem>
  const describedBy = (key: string) => (problems[key] ? `${id}-${key}-error` : undefined)
  const align = 'align' in block ? block.align : undefined
  const alignPicker = (
    <AlignPicker
      value={align}
      readOnly={readOnly}
      onChange={(align) => onChange({ ...block, align } as TemplateBlock)}
    />
  )
  const warning = (text: string) => (
    <small className="text-amber-700 dark:text-amber-400">{text}</small>
  )
  switch (block.type) {
    case 'logo':
      return (
        <div className="grid gap-3">
          <Label htmlFor={`${id}-width`}>{t('receiptTemplates.block.logoWidth')}</Label>
          <Input
            id={`${id}-width`}
            type="number"
            min={20}
            max={100}
            step={5}
            value={block.width_pct ?? 60}
            disabled={readOnly}
            aria-invalid={Boolean(problems.width_pct)}
            aria-describedby={describedBy('width_pct')}
            onChange={(event) => onChange({ ...block, width_pct: numberOr(event.target.value, 0) })}
          />
          {error('width_pct')}
          {alignPicker}
          <Check
            checked={block.monochrome === true}
            disabled={readOnly}
            onChange={(monochrome) => onChange({ ...block, monochrome })}
          >
            {t('receiptTemplates.block.monochrome')}
          </Check>
          {!data.store.logoUrl ? (
            <small className="text-muted-foreground">
              {t('receiptTemplates.block.logoMissing')}
            </small>
          ) : null}
        </div>
      )
    case 'business': {
      const enabled = new Set<string>(block.fields)
      const limit = charsPerLine(paper, pageSize)
      const long = overlongLines(businessLines(block.fields, data), limit)
      const toggle = (field: BusinessField, on: boolean) =>
        onChange({
          ...block,
          fields: on
            ? BUSINESS_FIELDS.filter((item) => item === field || enabled.has(item))
            : block.fields.filter((item) => item !== field),
        })
      return (
        <div className="grid gap-3">
          <fieldset className="grid gap-2" aria-describedby={describedBy('fields')}>
            <legend className="mb-2 font-medium">
              {t('receiptTemplates.block.businessFields')}
            </legend>
            {BUSINESS_FIELDS.map((field) => (
              <Check
                key={field}
                checked={enabled.has(field)}
                disabled={readOnly}
                onChange={(on) => toggle(field, on)}
              >
                {t(`receiptTemplates.business.${field}`)}
              </Check>
            ))}
          </fieldset>
          {error('fields')}
          {long.length > 0
            ? warning(t('receiptTemplates.block.tooWide', { count: limit ?? 0, paper }))
            : null}
          {alignPicker}
        </div>
      )
    }
    case 'text': {
      const limit = charsPerLine(paper, pageSize, block.size ?? 'm')
      const long = overlongLines(
        block.value
          .split(/\r?\n/)
          .map((line) => resolveText(line, data))
          .filter((line) => !line.blank)
          .map((line) => line.text),
        limit,
      )
      return (
        <div className="grid gap-3">
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
          {long.length > 0
            ? warning(t('receiptTemplates.block.tooWide', { count: limit ?? 0, paper }))
            : null}
          <div className="grid gap-3 sm:grid-cols-2">
            {alignPicker}
            <Choice
              label={t('receiptTemplates.block.size')}
              value={block.size ?? 'm'}
              disabled={readOnly}
              options={(['s', 'm', 'l'] as const).map((value) => ({
                value,
                label: t(`receiptTemplates.size.${value}`),
              }))}
              onChange={(size) => onChange({ ...block, size })}
            />
          </div>
          <Check
            checked={block.bold === true}
            disabled={readOnly}
            onChange={(bold) => onChange({ ...block, bold })}
          >
            {t('receiptTemplates.block.bold')}
          </Check>
        </div>
      )
    }
    case 'title':
      return (
        <div className="grid gap-3">
          <Label htmlFor={`${id}-title`}>{t('receiptTemplates.block.titleLabel')}</Label>
          <Input
            id={`${id}-title`}
            value={block.label ?? ''}
            placeholder={data.title}
            maxLength={MAX_TITLE_LENGTH}
            disabled={readOnly}
            aria-invalid={Boolean(problems.label)}
            aria-describedby={describedBy('label')}
            onChange={(event) => {
              const { label: _previous, ...rest } = block
              onChange(event.target.value === '' ? rest : { ...rest, label: event.target.value })
            }}
          />
          {error('label')}
          <small className="text-muted-foreground">{t('receiptTemplates.block.titleLocked')}</small>
        </div>
      )
    case 'divider':
      return (
        <Choice
          label={t('receiptTemplates.block.dividerStyle')}
          value={block.style ?? 'dashed'}
          disabled={readOnly}
          options={(['dashed', 'solid'] as const).map((value) => ({
            value,
            label: t(`receiptTemplates.block.${value}`),
          }))}
          onChange={(style) => onChange({ ...block, style })}
        />
      )
    case 'qr':
      return (
        <QrFields
          block={block}
          data={data}
          readOnly={readOnly}
          problems={problems}
          error={error}
          describedBy={describedBy}
          onChange={onChange}
        />
      )
    case 'barcode':
      return (
        <div className="grid gap-3">
          {alignPicker}
          <small className="text-muted-foreground">
            {data.number
              ? t('receiptTemplates.block.barcodeNote', { number: data.number })
              : t('receiptTemplates.block.barcodeNone')}
          </small>
          {data.number && barcodeWidthMm(data.number, PRINTABLE_WIDTH_MM[paper]) === null
            ? warning(t('receiptTemplates.block.barcodeTooWide', { number: data.number, paper }))
            : null}
        </div>
      )
    case 'signatures': {
      const chosen = new Set<string>(block.parties)
      const update = (
        parties: SignatureParty[],
        labels: Partial<Record<SignatureParty, string>>,
      ) => {
        const kept = Object.fromEntries(
          Object.entries(labels).filter(
            ([party, label]) => label && parties.includes(party as SignatureParty),
          ),
        )
        const { labels: _previous, ...rest } = block
        onChange(
          Object.keys(kept).length > 0 ? { ...rest, parties, labels: kept } : { ...rest, parties },
        )
      }
      const toggle = (party: SignatureParty, on: boolean) =>
        update(
          on
            ? SIGNATURE_PARTIES.filter((item) => item === party || chosen.has(item))
            : block.parties.filter((item) => item !== party),
          block.labels ?? {},
        )
      return (
        <div className="grid gap-3">
          <fieldset className="grid gap-2" aria-describedby={describedBy('parties')}>
            <legend className="mb-2 font-medium">
              {t('receiptTemplates.block.signatureParties')}
            </legend>
            {SIGNATURE_PARTIES.map((party) => (
              <Check
                key={party}
                checked={chosen.has(party)}
                disabled={readOnly}
                onChange={(on) => toggle(party, on)}
              >
                {data.signatureLabels[party]}
              </Check>
            ))}
          </fieldset>
          {error('parties')}
          {block.parties.map((party) => (
            <div key={party} className="grid gap-2">
              <Label htmlFor={`${id}-${party}`}>
                {t('receiptTemplates.block.signatureLabel', { name: data.signatureLabels[party] })}
              </Label>
              <Input
                id={`${id}-${party}`}
                value={block.labels?.[party] ?? ''}
                placeholder={data.signatureLabels[party]}
                maxLength={MAX_LABEL_LENGTH}
                disabled={readOnly}
                onChange={(event) =>
                  update(block.parties, { ...(block.labels ?? {}), [party]: event.target.value })
                }
              />
            </div>
          ))}
          {error('labels')}
          {!WIDE_PAPERS.includes(paper)
            ? warning(t('receiptTemplates.block.signaturesSheetOnly'))
            : null}
        </div>
      )
    }
    case 'spacer':
      return (
        <div className="grid gap-2">
          <Label htmlFor={`${id}-spacer`}>{t('receiptTemplates.block.spacerMm')}</Label>
          <Input
            id={`${id}-spacer`}
            type="number"
            min={1}
            max={10}
            value={block.mm ?? 2}
            disabled={readOnly}
            aria-invalid={Boolean(problems.mm)}
            aria-describedby={describedBy('mm')}
            onChange={(event) => onChange({ ...block, mm: numberOr(event.target.value, 0) })}
          />
          {error('mm')}
        </div>
      )
  }
}

function QrFields({
  block,
  data,
  readOnly,
  problems,
  error,
  describedBy,
  onChange,
}: {
  block: QrBlock
  data: TemplateData
  readOnly: boolean
  problems: BlockProblems
  error: (key: string) => ReactNode
  describedBy: (key: string) => string | undefined
  onChange: (block: TemplateBlock) => void
}) {
  const { t } = useTranslation('pos')
  const id = useId()
  const shared = {
    type: 'qr' as const,
    ...(block.caption !== undefined ? { caption: block.caption } : {}),
    ...(block.align !== undefined ? { align: block.align } : {}),
  }
  return (
    <div className="grid gap-3">
      <Choice
        label={t('receiptTemplates.block.qrSource')}
        value={block.source}
        disabled={readOnly}
        options={[
          { value: 'url', label: t('receiptTemplates.block.qrSourceUrl') },
          { value: 'store_social', label: t('receiptTemplates.block.qrSourceStore') },
        ]}
        onChange={(value) =>
          onChange(
            value === 'store_social'
              ? { ...shared, source: 'store_social', field: 'facebook' }
              : { ...shared, source: 'url', value: '' },
          )
        }
      />
      {block.source === 'url' ? (
        <>
          <Label htmlFor={`${id}-url`}>{t('receiptTemplates.block.qrUrl')}</Label>
          <Input
            id={`${id}-url`}
            type="url"
            inputMode="url"
            value={block.value}
            placeholder="https://"
            maxLength={MAX_URL_LENGTH}
            disabled={readOnly}
            aria-invalid={Boolean(problems.value)}
            aria-describedby={describedBy('value')}
            onChange={(event) => onChange({ ...block, value: event.target.value })}
          />
          {error('value')}
        </>
      ) : (
        <>
          <Choice
            label={t('receiptTemplates.block.qrField')}
            value={block.field}
            disabled={readOnly}
            invalid={Boolean(problems.field)}
            describedBy={describedBy('field')}
            options={SOCIAL_FIELDS.map((value) => ({
              value,
              label: t(`receiptTemplates.business.${value}`),
            }))}
            onChange={(field: SocialField) => onChange({ ...block, field })}
          />
          {error('field')}
          {!data.store[block.field] ? (
            <small className="text-muted-foreground">
              {t('receiptTemplates.block.qrStoreMissing')}
            </small>
          ) : null}
        </>
      )}
      <Label htmlFor={`${id}-caption`}>{t('receiptTemplates.block.qrCaption')}</Label>
      <Input
        id={`${id}-caption`}
        value={block.caption ?? ''}
        maxLength={MAX_CAPTION_LENGTH}
        disabled={readOnly}
        aria-invalid={Boolean(problems.caption)}
        aria-describedby={describedBy('caption')}
        onChange={(event) => {
          const { caption: _previous, ...rest } = block
          onChange(event.target.value === '' ? rest : { ...rest, caption: event.target.value })
        }}
      />
      {error('caption')}
      <AlignPicker
        value={block.align}
        readOnly={readOnly}
        onChange={(align) => onChange({ ...block, align })}
      />
    </div>
  )
}
