import { PageHeader } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  Checkbox,
  Label,
  SectionTitle,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@spree/dashboard-ui'
import { type ReactNode, useId } from 'react'
import { useTranslation } from 'react-i18next'

export function modelDate(value: string | null | undefined, locale: string, timeZone: string) {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '—'
  try {
    return new Intl.DateTimeFormat(locale, {
      dateStyle: 'short',
      timeStyle: 'short',
      timeZone,
    }).format(date)
  } catch {
    return new Intl.DateTimeFormat(locale, {
      dateStyle: 'short',
      timeStyle: 'short',
      timeZone: 'UTC',
    }).format(date)
  }
}

export function ModelPage({
  title,
  description,
  actions,
  children,
}: {
  title: string
  description?: string
  actions?: ReactNode
  children: ReactNode
}) {
  return (
    <div className="space-y-6">
      <PageHeader title={title} description={description} actions={actions} />
      {children}
    </div>
  )
}

export function ModelCard({
  title,
  children,
  id,
  icon,
}: {
  title: string
  children: ReactNode
  id: string
  icon?: ReactNode
}) {
  return (
    <section className="flex flex-col gap-3" aria-labelledby={id}>
      <SectionTitle id={id}>
        {icon}
        {title}
      </SectionTitle>
      <Card>
        <CardContent>
          <div className="flex flex-col gap-4">{children}</div>
        </CardContent>
      </Card>
    </section>
  )
}

export function ModelState({
  title,
  error,
  retry,
}: {
  title: string
  error?: boolean
  retry?: () => void
}) {
  const { t } = useTranslation()
  return (
    <div role={error ? 'alert' : 'status'} className="rounded-lg border p-4">
      <p>{title}</p>
      {retry ? (
        <Button type="button" variant="outline" className="mt-3" onClick={retry}>
          {t('retry')}
        </Button>
      ) : null}
    </div>
  )
}

export function ModelNotice({ notice }: { notice: { text: string; failed: boolean } | null }) {
  return notice ? (
    <p
      role={notice.failed ? 'alert' : 'status'}
      className={notice.failed ? 'text-destructive' : 'text-success'}
    >
      {notice.text}
    </p>
  ) : null
}

export function ModelSelect({
  label,
  value,
  options,
  onChange,
  disabled,
  invalid,
  hint,
  id: explicitId,
}: {
  label: string
  value: string
  options: { value: string; label: string }[]
  onChange: (value: string) => void
  disabled?: boolean
  invalid?: boolean
  hint?: string
  id?: string
}) {
  const generated = useId()
  const id = explicitId ?? generated
  const selected = options.find((item) => item.value === value)
  return (
    <div className="flex min-w-0 flex-col gap-2">
      <Label id={`${id}-label`} htmlFor={id}>
        {label}
      </Label>
      <Select value={value} onValueChange={onChange} disabled={disabled}>
        <SelectTrigger
          id={id}
          aria-labelledby={`${id}-label`}
          aria-invalid={invalid}
          aria-describedby={hint ? `${id}-hint` : undefined}
        >
          <SelectValue>{selected?.label ?? '—'}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {options.map((item) => (
            <SelectItem key={item.value} value={item.value}>
              {item.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      {hint ? (
        <small id={`${id}-hint`} className="text-muted-foreground">
          {hint}
        </small>
      ) : null}
    </div>
  )
}

export function ModelCheck({
  checked,
  onChange,
  children,
  disabled,
  name,
  description,
  id: explicitId,
}: {
  checked: boolean
  onChange: (value: boolean) => void
  children: ReactNode
  disabled?: boolean
  name?: string
  description?: string
  id?: string
}) {
  const generated = useId()
  const id = explicitId ?? generated
  // Base UI Field auto-labels the checkbox from the visible Label, which
  // beats aria-label. Point aria-labelledby at the full name instead so
  // callers passing `name` get it as the accessible name (POS parity).
  return (
    <div className="flex items-start gap-3">
      <Checkbox
        id={id}
        checked={checked}
        disabled={disabled}
        onCheckedChange={(value) => onChange(value === true)}
        aria-label={name}
        aria-labelledby={name ? `${id}-name` : undefined}
        aria-describedby={description ? `${id}-hint` : undefined}
      />
      <div className="min-w-0">
        <Label htmlFor={id}>{children}</Label>
        {name ? (
          <span id={`${id}-name`} className="sr-only">
            {name}
          </span>
        ) : null}
        {description ? (
          <p id={`${id}-hint`} className="mt-1 text-sm text-muted-foreground">
            {description}
          </p>
        ) : null}
      </div>
    </div>
  )
}

export function ModelStatus({ on, children }: { on: boolean; children: ReactNode }) {
  return (
    <Badge className="shrink-0" variant={on ? 'default' : 'outline'}>
      {children}
    </Badge>
  )
}
