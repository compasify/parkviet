import {
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@spree/dashboard-ui'
import { type ReactNode, useId } from 'react'

export function TopologyField({
  label,
  error,
  hint,
  children,
}: {
  label: string
  error?: string
  hint?: string
  children: (id: string, describedBy?: string) => ReactNode
}) {
  const id = useId()
  return (
    <Field data-invalid={Boolean(error)}>
      <FieldLabel htmlFor={id}>{label}</FieldLabel>
      {children(id, hint ? `${id}-hint` : undefined)}
      {hint && <FieldDescription id={`${id}-hint`}>{hint}</FieldDescription>}
      {error && <FieldError>{error}</FieldError>}
    </Field>
  )
}
export function TopologySelect({
  id,
  value,
  onChange,
  options,
  disabled,
  describedBy,
  invalid,
}: {
  id: string
  value: string
  onChange: (value: string) => void
  options: { value: string; label: string; disabled?: boolean }[]
  disabled?: boolean
  describedBy?: string
  invalid?: boolean
}) {
  // Radix reserves the empty value for clearing; keep the public form contract blank.
  // Base UI resolves the closed trigger from mounted items only, so render the
  // selected label explicitly instead of showing the raw value.
  const keyOf = (itemValue: string) => itemValue || '__blank__'
  const selected = options.find((option) => keyOf(option.value) === keyOf(value))
  return (
    <Select
      value={value || '__blank__'}
      onValueChange={(v) => onChange(v === '__blank__' ? '' : v)}
      disabled={disabled}
    >
      <SelectTrigger id={id} aria-describedby={describedBy} aria-invalid={invalid}>
        <SelectValue>{selected?.label ?? '—'}</SelectValue>
      </SelectTrigger>
      <SelectContent>
        {options.map((option) => (
          <SelectItem
            key={option.value || '__blank__'}
            value={option.value || '__blank__'}
            disabled={option.disabled}
          >
            {option.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
export { Input }
