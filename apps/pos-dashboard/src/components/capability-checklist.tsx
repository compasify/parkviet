import { Checkbox, Field, FieldDescription, FieldLabel } from '@spree/dashboard-ui'
import { useId } from 'react'
import { useTranslation } from 'react-i18next'
import { capabilityGroups } from '../lib/capability-groups'

// Capability checkboxes grouped by the work they open. Read-only lists show
// the same rows disabled, so a role's grants read like the editable form.
export function CapabilityChecklist({
  value,
  onChange,
  disabled = false,
}: {
  value: readonly string[]
  onChange?: (next: string[]) => void
  disabled?: boolean
}) {
  const { t } = useTranslation()
  const id = useId()
  return (
    <div className="space-y-5">
      {capabilityGroups.map((group) => (
        <fieldset key={group.key} className="space-y-3">
          <legend className="mb-2 text-sm font-semibold">
            {t(`capabilityGroups.${group.key}`)}
          </legend>
          {group.capabilities.map(({ value: capability, label }) => (
            <Field key={capability} orientation="horizontal">
              <Checkbox
                id={`${id}-${capability}`}
                checked={value.includes(capability)}
                disabled={disabled || !onChange}
                onCheckedChange={(checked) =>
                  onChange?.(
                    checked === true
                      ? [...value.filter((item) => item !== capability), capability]
                      : value.filter((item) => item !== capability),
                  )
                }
              />
              <div>
                <FieldLabel htmlFor={`${id}-${capability}`}>{t(label)}</FieldLabel>
                <FieldDescription>{t(`${label}Hint`)}</FieldDescription>
              </div>
            </Field>
          ))}
        </fieldset>
      ))}
    </div>
  )
}
