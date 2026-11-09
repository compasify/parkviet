import { useId } from 'react';
import { useTranslation } from 'react-i18next';
import { MAX_LABEL_LENGTH } from '../../lib/receipt-template/render';
import type { DocumentType, FieldSection } from '../../lib/receipt-template/types';
import { FIXED_LABELS } from '../../lib/receipt-template/validate';

export type FieldSectionName = 'meta' | 'totals' | 'payments';

// The label each row prints with unless the template renames it.
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
};

function defaultLabelKey(section: FieldSectionName, field: string, type: DocumentType) {
  if (section === 'meta' && field === 'order_number' && type === 'payment_ticket')
    return 'ticketOrder';
  if (section === 'totals' && field === 'total' && type === 'return') return 'receiptReturnValue';
  return DEFAULT_LABEL_KEYS[section][field] ?? field;
}

// On/off and the printed label of each field of one fixed section. Locked
// fields always print: their box stays ticked and cannot be cleared.
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
  section: FieldSectionName;
  documentType: DocumentType;
  fields: readonly F[];
  locked?: readonly F[];
  value: FieldSection<F>;
  readOnly: boolean;
  invalid: (field: F) => string | null;
  onChange: (next: FieldSection<F>) => void;
}) {
  const { t } = useTranslation();
  const id = useId();
  const enabled = new Set<string>(value.fields);
  const labels = (value.labels ?? {}) as Partial<Record<string, string>>;

  const toggle = (field: F, on: boolean) => {
    const next = on
      ? fields.filter((item) => item === field || enabled.has(item))
      : value.fields.filter((item) => item !== field);
    // Fields the editor does not offer stay as they were.
    const kept = value.fields.filter((item) => !fields.includes(item));
    onChange({ ...value, fields: [...next, ...kept.filter((item) => !next.includes(item))] });
  };
  const relabel = (field: F, label: string) => {
    const next = { ...labels };
    if (label === '') delete next[field];
    else next[field] = label;
    onChange({ ...value, labels: next as Partial<Record<F, string>> });
  };

  return (
    <ul className="rt-fields" aria-label={t(`receiptTemplates.section.${section}`)}>
      {fields.map((field) => {
        const isLocked = locked.includes(field);
        const name = t(`receiptTemplates.fields.${section}.${field}`);
        const hint = `${id}-${field}-hint`;
        const error = invalid(field);
        const fixedLabel = section === 'payments' && FIXED_LABELS.includes(field);
        return (
          <li key={field} data-invalid={error ? 'true' : undefined}>
            <label title={isLocked ? t('receiptTemplates.lockedHint') : undefined}>
              <input
                type="checkbox"
                checked={isLocked || enabled.has(field)}
                disabled={readOnly || isLocked}
                aria-describedby={isLocked ? hint : undefined}
                onChange={(event) => toggle(field, event.target.checked)}
              />
              {name}
            </label>
            {fixedLabel ? (
              <small className="rt-field-note">{t('receiptTemplates.methodLabelFixed')}</small>
            ) : (
              <input
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
              <small id={hint} className="rt-locked">
                {t('receiptTemplates.locked')}
              </small>
            ) : null}
            {error ? <small className="rt-error">{error}</small> : null}
          </li>
        );
      })}
    </ul>
  );
}
