import {
  describeInventoryFailure,
  expiryState,
  formatExpiry,
  type LotRowDraft,
  type PosTraceStatus,
  parseSerials,
  serialListAfterTab,
  type TrackedMode,
} from '@parkviet/pos-shared/traceability'
import {
  Badge,
  Button,
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Input,
  Label,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Textarea,
} from '@spree/dashboard-ui'
import { type ReactNode, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { quantity, variantLabel } from './inventory-helpers'

// What the stock screens share: the branch they act on and what the member
// may do there.
export type InventoryScope = {
  branchId: string
  staffId: string | null
  capabilities: string[]
  manage: boolean
  // Manage, and the branch allows enrolling stock into tracking.
  enroll: boolean
  today: string
  timeZone: string
}

export type Notice = { text: string; failed: boolean } | null

export type CommandState = { uncertain: boolean; isPending: boolean; recheck: () => void }

export const EMPTY_LOT_ROW: LotRowDraft = { lot_code: '', expiry_on: '', quantity: '' }

export function NoticeLine({ notice }: { notice: Notice }) {
  if (!notice) return null
  return (
    <p
      role={notice.failed ? 'alert' : 'status'}
      className={notice.failed ? 'text-sm text-destructive' : 'text-sm text-muted-foreground'}
    >
      {notice.text}
    </p>
  )
}

export function FormError({ text }: { text: string }) {
  if (!text) return null
  return (
    <p role="alert" className="text-sm text-destructive">
      {text}
    </p>
  )
}

// Loading, failure and empty states of a list a form picks from.
export function VariantsState({
  query,
  empty,
}: {
  query: { isPending: boolean; isError: boolean; error: unknown; refetch: () => unknown }
  empty: boolean
}) {
  const { t } = useTranslation()
  if (query.isPending)
    return (
      <p role="status" className="text-sm text-muted-foreground">
        {t('waiting')}
      </p>
    )
  if (query.isError)
    return (
      <div role="alert" className="flex flex-wrap items-center gap-2 text-sm text-destructive">
        <span>{describeInventoryFailure(query.error, t)}</span>
        <Button type="button" size="sm" variant="outline" onClick={() => void query.refetch()}>
          {t('retry')}
        </Button>
      </div>
    )
  return empty ? <p className="text-sm text-muted-foreground">{t('inventoryEmpty')}</p> : null
}

// A stock command whose response never arrived: the form stays on the same
// content until the receipt check settles whether it committed.
export function CommandCheck({ command }: { command: CommandState }) {
  const { t } = useTranslation()
  if (!command.uncertain) return null
  return (
    <div
      role="status"
      className="flex flex-wrap items-center gap-2 rounded-md border border-warning-border bg-warning-bg p-2 text-sm"
    >
      <span>{t('inventoryCommandChecking')}</span>
      <Button
        type="button"
        size="sm"
        variant="outline"
        disabled={command.isPending}
        onClick={command.recheck}
      >
        {t('inventoryCommandRecheck')}
      </Button>
    </div>
  )
}

export function Expiry({ value, today }: { value: string | null; today: string }) {
  const { t } = useTranslation()
  const state = expiryState(value, today)
  return (
    <span className="inline-flex items-center gap-2 whitespace-nowrap">
      {formatExpiry(value)}
      {state === 'expired' && <Badge variant="destructive">{t('inventoryExpired')}</Badge>}
      {state === 'near' && <Badge variant="warning">{t('inventoryNearExpiry')}</Badge>}
    </span>
  )
}

// A single choice with an empty "—" option, for the stock forms.
export function ChoiceField({
  label,
  value,
  options,
  onChange,
  disabled,
}: {
  label: string
  value: string
  options: { value: string; label: string }[]
  onChange: (value: string) => void
  disabled?: boolean
}) {
  const id = useId()
  const BLANK = '__blank__'
  const items = [{ value: BLANK, label: '—' }, ...options]
  const selected = options.find((option) => option.value === value)
  return (
    <div className="grid gap-1">
      <Label htmlFor={id}>{label}</Label>
      <Select
        value={value || BLANK}
        items={items}
        disabled={disabled}
        onValueChange={(next) => onChange(next === BLANK ? '' : next)}
      >
        <SelectTrigger id={id} aria-label={label} className="w-full">
          <SelectValue>{selected?.label ?? '—'}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {items.map((item) => (
            <SelectItem key={item.value} value={item.value}>
              {item.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  )
}

export function VariantField({
  variants,
  value,
  onChange,
  disabled,
}: {
  variants: PosTraceStatus[]
  value: string
  onChange: (value: string) => void
  disabled: boolean
}) {
  const { t } = useTranslation()
  return (
    <ChoiceField
      label={t('inventoryVariant')}
      value={value}
      disabled={disabled}
      onChange={onChange}
      options={variants.map((variant) => ({
        value: variant.variant_id,
        label: `${variantLabel(variant)} · ${t(`variantUnitTracked_${variant.tracked_mode}`)}`,
      }))}
    />
  )
}

export function TextField({
  label,
  value,
  onChange,
  disabled,
  maxLength,
  numeric,
  type,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  disabled?: boolean
  maxLength?: number
  numeric?: boolean
  type?: string
}) {
  const id = useId()
  return (
    <div className="grid gap-1">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        type={type}
        value={value}
        maxLength={maxLength}
        inputMode={numeric ? 'numeric' : undefined}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )
}

// Serial codes one per line; a Tab-terminated scan becomes a line break.
export function SerialTextarea({
  label,
  value,
  onChange,
  disabled,
  rows = 4,
  hint,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  disabled: boolean
  rows?: number
  hint?: ReactNode
}) {
  const id = useId()
  return (
    <div className="grid gap-1">
      <Label htmlFor={id}>{label}</Label>
      <Textarea
        id={id}
        rows={rows}
        value={value}
        disabled={disabled}
        aria-describedby={hint ? `${id}-hint` : undefined}
        onKeyDown={(event) => {
          if (event.key !== 'Tab') return
          const next = serialListAfterTab(event.currentTarget.value, event.shiftKey)
          if (next === null) return
          event.preventDefault()
          onChange(next)
        }}
        onChange={(event) => onChange(event.target.value)}
      />
      {hint ? (
        <p id={`${id}-hint`} className="text-xs text-muted-foreground">
          {hint}
        </p>
      ) : null}
    </div>
  )
}

export function LotFilter({
  value,
  onChange,
  truncated,
  disabled,
}: {
  value: string
  onChange: (value: string) => void
  truncated: boolean
  disabled: boolean
}) {
  const { t } = useTranslation()
  return (
    <div className="space-y-1">
      <TextField
        label={t('inventoryLotFilter')}
        value={value}
        maxLength={64}
        disabled={disabled}
        onChange={onChange}
      />
      {truncated && <p className="text-xs text-muted-foreground">{t('inventoryLotListCapped')}</p>}
    </div>
  )
}

export function useStockEntry() {
  const [serialText, setSerialText] = useState('')
  const [lotRows, setLotRows] = useState<LotRowDraft[]>([EMPTY_LOT_ROW])
  return {
    serialText,
    setSerialText,
    lotRows,
    setLotRows,
    reset() {
      setSerialText('')
      setLotRows([EMPTY_LOT_ROW])
    },
  }
}
export type StockEntry = ReturnType<typeof useStockEntry>

export function entryError(
  entry: { error: string | null; codes: string[] },
  t: (key: string, options?: Record<string, unknown>) => string,
) {
  return entry.error ? t(entry.error, { codes: entry.codes.join(', ') }) : ''
}

// New stock by serial codes, or by lots with an expiry and a whole quantity.
export function StockEntryFields({
  mode,
  baseUnit,
  entry,
  disabled,
}: {
  mode: TrackedMode
  baseUnit: string
  entry: StockEntry
  disabled: boolean
}) {
  const { t } = useTranslation()
  if (mode === 'serial') {
    const count = parseSerials(entry.serialText).codes.length
    return (
      <SerialTextarea
        label={t('inventorySerialList')}
        value={entry.serialText}
        onChange={entry.setSerialText}
        disabled={disabled}
        rows={5}
        hint={t('inventorySerialListHint', { count })}
      />
    )
  }
  const rows = entry.lotRows
  const set = (index: number, key: keyof LotRowDraft, value: string) =>
    entry.setLotRows(rows.map((row, at) => (at === index ? { ...row, [key]: value } : row)))
  return (
    <fieldset className="space-y-3 rounded-md border p-3">
      <legend className="px-1 text-sm font-medium">
        {t('inventoryLotRows', { unit: baseUnit })}
      </legend>
      {rows.map((row, index) => (
        // Rows have no identity beyond their position while being typed.
        // biome-ignore lint/suspicious/noArrayIndexKey: positional draft rows
        <div className="grid items-end gap-2 sm:grid-cols-[1fr_10rem_8rem_auto]" key={index}>
          <div className="grid gap-1">
            <Label>{t('inventoryLotCode')}</Label>
            <Input
              value={row.lot_code}
              maxLength={64}
              disabled={disabled}
              aria-label={t('inventoryLotCodeRow', { row: index + 1 })}
              onChange={(event) => set(index, 'lot_code', event.target.value)}
            />
          </div>
          <div className="grid gap-1">
            <Label>{t('inventoryExpiry')}</Label>
            <Input
              type="date"
              value={row.expiry_on}
              disabled={disabled}
              aria-label={t('inventoryExpiryRow', { row: index + 1 })}
              onChange={(event) => set(index, 'expiry_on', event.target.value)}
            />
          </div>
          <div className="grid gap-1">
            <Label>{t('inventoryQuantity', { unit: baseUnit })}</Label>
            <Input
              inputMode="numeric"
              value={row.quantity}
              disabled={disabled}
              aria-label={t('inventoryQuantityRow', { row: index + 1 })}
              onChange={(event) => set(index, 'quantity', event.target.value)}
            />
          </div>
          {rows.length > 1 ? (
            <Button
              type="button"
              variant="outline"
              disabled={disabled}
              aria-label={t('inventoryLotRemove', { row: index + 1 })}
              onClick={() => entry.setLotRows(rows.filter((_, at) => at !== index))}
            >
              {t('removeItem')}
            </Button>
          ) : (
            <span />
          )}
        </div>
      ))}
      <Button
        type="button"
        variant="outline"
        disabled={disabled || rows.length >= 50}
        onClick={() => entry.setLotRows([...rows, EMPTY_LOT_ROW])}
      >
        {t('inventoryLotAdd')}
      </Button>
    </fieldset>
  )
}

export function TraceSummary({ status }: { status: PosTraceStatus }) {
  const { t } = useTranslation()
  return (
    <p role="status" className="text-sm text-muted-foreground">
      {t('inventoryResultStatus', {
        name: status.name,
        core: quantity(status.core_on_hand, status.base_unit),
        typed: quantity(status.typed_on_hand, status.base_unit),
      })}{' '}
      {status.blocked_reason
        ? t(`inventoryBlocked_${status.blocked_reason}`)
        : t('inventorySellable')}
    </p>
  )
}

// Asks for the reason of a quarantine, release or cancellation.
export function ReasonDialog({
  title,
  description,
  submitLabel,
  destructive,
  command,
  error,
  onSubmit,
  onClose,
}: {
  title: string
  description?: string
  submitLabel: string
  destructive?: boolean
  command: CommandState
  error: string
  onSubmit: (reason: string) => void
  onClose: () => void
}) {
  const { t } = useTranslation()
  const id = useId()
  const [reason, setReason] = useState('')
  const [missing, setMissing] = useState(false)
  const busy = command.isPending
  const locked = busy || command.uncertain
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {description && <DialogDescription>{description}</DialogDescription>}
        </DialogHeader>
        <form
          className="space-y-4"
          aria-busy={busy}
          onSubmit={(event) => {
            event.preventDefault()
            if (locked) return
            if (!reason.trim()) {
              setMissing(true)
              return
            }
            setMissing(false)
            onSubmit(reason.trim())
          }}
        >
          <div className="grid gap-1">
            <Label htmlFor={id}>{t('inventoryReason')}</Label>
            <Input
              id={id}
              value={reason}
              maxLength={200}
              required
              disabled={locked}
              onChange={(event) => setReason(event.target.value)}
            />
          </div>
          {missing && <FormError text={t('inventoryReasonRequired')} />}
          <FormError text={error} />
          <CommandCheck command={command} />
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={onClose}>
              {t('adminCancel')}
            </Button>
            <Button
              type="submit"
              variant={destructive ? 'destructive' : 'default'}
              disabled={locked}
            >
              {busy ? t('waiting') : submitLabel}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
