import {
  Alert,
  AlertDescription,
  Button,
  Checkbox,
  Label,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@spree/dashboard-ui'
import { type ReactNode, useId } from 'react'

export function Choice<T extends string>({
  label,
  value,
  options,
  disabled,
  invalid,
  describedBy,
  onChange,
}: {
  label: string
  value: T
  options: readonly { value: T; label: string; disabled?: boolean }[]
  disabled?: boolean
  invalid?: boolean
  describedBy?: string
  onChange: (value: T) => void
}) {
  const id = useId()
  return (
    <div className="grid gap-2">
      <Label htmlFor={id}>{label}</Label>
      <Select
        value={value}
        items={options}
        disabled={disabled}
        onValueChange={(next) => onChange(next as T)}
      >
        <SelectTrigger id={id} aria-invalid={invalid || undefined} aria-describedby={describedBy}>
          <SelectValue />
        </SelectTrigger>
        <SelectContent>
          {options.map((option) => (
            <SelectItem key={option.value} value={option.value} disabled={option.disabled}>
              {option.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}

export function Check({
  children,
  checked,
  disabled,
  onChange,
  describedBy,
}: {
  children: ReactNode
  checked: boolean
  disabled?: boolean
  onChange: (checked: boolean) => void
  describedBy?: string
}) {
  const id = useId()
  return (
    <div className="flex items-center gap-3 py-1">
      <Checkbox
        id={id}
        checked={checked}
        disabled={disabled}
        onCheckedChange={onChange}
        aria-describedby={describedBy}
      />
      <Label htmlFor={id}>{children}</Label>
    </div>
  )
}

export function Problem({ children, id }: { children: ReactNode; id?: string }) {
  return children ? (
    <small id={id} data-template-error className="text-destructive">
      {children}
    </small>
  ) : null
}

export function Notice({ text, failed = false }: { text: string; failed?: boolean }) {
  return (
    <Alert variant={failed ? 'destructive' : 'default'} role={failed ? 'alert' : 'status'}>
      <AlertDescription>{text}</AlertDescription>
    </Alert>
  )
}

export function PageState({
  title,
  error,
  retry,
  retryLabel,
}: {
  title: string
  error?: string
  retry?: () => void
  retryLabel?: string
}) {
  return (
    <div className="grid gap-3 rounded-xl border bg-card p-6" role={error ? 'alert' : 'status'}>
      <p>{title}</p>
      {error ? <p className="text-muted-foreground">{error}</p> : null}
      {retry ? (
        <Button variant="outline" onClick={retry}>
          {retryLabel}
        </Button>
      ) : null}
    </div>
  )
}
