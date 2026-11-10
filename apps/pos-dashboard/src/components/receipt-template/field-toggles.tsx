import { MAX_LABEL_LENGTH } from '@parkviet/pos-shared/receipt-template/render'
import type { DocumentType, FieldSection } from '@parkviet/pos-shared/receipt-template/types'
import { FIXED_LABELS } from '@parkviet/pos-shared/receipt-template/validate'
import { Input } from '@spree/dashboard-ui'
import { useId } from 'react'
import { useTranslation } from 'react-i18next'
import { Check, Problem } from './controls'

export type FieldSectionName = 'meta' | 'totals' | 'payments'
const DEFAULT_LABEL_KEYS: Record<FieldSectionName, Record<string, string>> = {
  meta: {
    time: 'receiptTime',
    cashier: 'receiptCashier',
    order_number: 'receiptOrderNumber',
    return_number: 'receiptReturnNumber',
    customer: 'receiptCustomer',
  },
  totals: {
    item_total: 'receiptItemTotal',
    discount: 'receiptDiscount',
    tax: 'receiptTax',
    included_tax: 'receiptIncludedTax',
    total: 'receiptTotal',
  },
  payments: {
    methods: 'receiptTemplates.fields.payments.methods',
    handed: 'receiptHanded',
    change: 'receiptChange',
    reference: 'receiptReference',
    paid_total: 'receiptPaidTotal',
    debt: 'receiptDebt',
    due_on: 'receiptDueOn',
    pay_qr: 'receiptPayQrCaption',
  },
}
function defaultLabelKey(section: FieldSectionName, field: string, type: DocumentType) {
  if (section === 'meta' && field === 'order_number' && type === 'payment_ticket')
    return 'ticketOrder'
  if (section === 'totals' && field === 'total' && type === 'return') return 'receiptReturnValue'
  return DEFAULT_LABEL_KEYS[section][field] ?? field
}
export function FieldToggles<F extends string>({
  section,
  documentType,
  fields,
  locked = [],
  value,
  readOnly,
  invalid,
  onChange,
}: {
  section: FieldSectionName
  documentType: DocumentType
  fields: readonly F[]
  locked?: readonly F[]
  value: FieldSection<F>
  readOnly: boolean
  invalid: (field: F) => string | null
  onChange: (next: FieldSection<F>) => void
}) {
  const { t } = useTranslation('pos')
  const id = useId()
  const enabled = new Set<string>(value.fields)
  const labels = (value.labels ?? {}) as Partial<Record<string, string>>
  const toggle = (field: F, on: boolean) => {
    const next = on
      ? fields.filter((item) => item === field || enabled.has(item))
      : value.fields.filter((item) => item !== field)
    const kept = value.fields.filter((item) => !fields.includes(item))
    onChange({ ...value, fields: [...next, ...kept.filter((item) => !next.includes(item))] })
  }
  const relabel = (field: F, label: string) => {
    const next = { ...labels }
    if (label === '') delete next[field]
    else next[field] = label
    onChange({ ...value, labels: next as Partial<Record<F, string>> })
  }
  return (
    <ul className="grid gap-4" aria-label={t(`receiptTemplates.section.${section}`)}>
      {fields.map((field) => {
        const isLocked = locked.includes(field)
        const name = t(`receiptTemplates.fields.${section}.${field}`)
        const hint = `${id}-${field}-hint`
        const error = invalid(field)
        return (
          <li
            key={field}
            className="grid gap-2 rounded-lg border p-3 data-[invalid=true]:border-destructive"
            data-invalid={error ? 'true' : undefined}
          >
            <Check
              checked={isLocked || enabled.has(field)}
              disabled={readOnly || isLocked}
              describedBy={isLocked ? hint : undefined}
              onChange={(on) => toggle(field, on)}
            >
              {name}
            </Check>
            {section === 'payments' && FIXED_LABELS.includes(field) ? (
              <small className="text-muted-foreground">
                {t('receiptTemplates.methodLabelFixed')}
              </small>
            ) : (
              <Input
                aria-label={t('receiptTemplates.labelFor', { name })}
                value={labels[field] ?? ''}
                placeholder={t(defaultLabelKey(section, field, documentType))}
                maxLength={MAX_LABEL_LENGTH}
                disabled={readOnly}
                aria-invalid={error ? true : undefined}
                onChange={(event) => relabel(field, event.target.value)}
              />
            )}
            {isLocked ? (
              <small id={hint} className="text-muted-foreground">
                {t('receiptTemplates.locked')}
              </small>
            ) : null}
            <Problem>{error}</Problem>
          </li>
        )
      })}
    </ul>
  )
}
