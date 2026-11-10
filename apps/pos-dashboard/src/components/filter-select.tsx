import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@spree/dashboard-ui'

// A single-choice list filter for endpoints that accept one value per field,
// where the table's multi-select filters would promise more than the server does.
export function FilterSelect({
  label,
  value,
  options,
  onChange,
}: {
  label: string
  value: string
  options: { value: string; label: string }[]
  onChange: (value: string) => void
}) {
  return (
    <Select value={value} items={options} onValueChange={(next) => onChange(String(next))}>
      <SelectTrigger aria-label={label} className="w-44">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {options.map((option) => (
          <SelectItem key={option.value} value={option.value}>
            {option.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
