import {
  TEMPLATE_VARIABLES,
  type TemplateVariable,
} from '@parkviet/pos-shared/receipt-template/variables'
import { Button, Label, Textarea } from '@spree/dashboard-ui'
import { type KeyboardEvent, useId, useLayoutEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

type Opened = { mode: 'button'; at: number } | { mode: 'typed'; start: number }
const QUERY = /^[a-z_.]*$/

export function TemplateTextField({
  label,
  value,
  samples,
  maxLength,
  readOnly,
  invalid,
  describedBy,
  onChange,
}: {
  label: string
  value: string
  samples: Record<TemplateVariable, string>
  maxLength: number
  readOnly: boolean
  invalid: boolean
  describedBy?: string
  onChange: (value: string) => void
}) {
  const { t } = useTranslation('pos')
  const id = useId()
  const field = useRef<HTMLTextAreaElement>(null)
  const list = useRef<HTMLDivElement>(null)
  const [opened, setOpened] = useState<Opened | null>(null)
  const [active, setActive] = useState(0)
  const [caret, setCaret] = useState(0)
  const placeCaret = useRef<number | null>(null)
  useLayoutEffect(() => {
    const position = placeCaret.current
    if (position === null || !field.current) return
    placeCaret.current = null
    field.current.focus()
    field.current.setSelectionRange(position, position)
  })
  const query =
    opened?.mode === 'typed' ? value.slice(opened.start + 1, Math.max(caret, opened.start + 1)) : ''
  const options = TEMPLATE_VARIABLES.filter((name) => name.includes(query))
  const current = Math.min(active, Math.max(options.length - 1, 0))
  const close = (refocus: boolean) => {
    setOpened(null)
    setActive(0)
    if (refocus) field.current?.focus()
  }
  const insert = (name: TemplateVariable) => {
    if (!opened) return
    const token = `{${name}}`
    const [from, to] = opened.mode === 'typed' ? [opened.start, caret] : [opened.at, opened.at]
    const next = `${value.slice(0, from)}${token}${value.slice(to)}`.slice(0, maxLength)
    onChange(next)
    setOpened(null)
    setActive(0)
    const end = Math.min(from + token.length, next.length)
    placeCaret.current = end
    setCaret(end)
  }
  const navigate = (event: KeyboardEvent) => {
    if (!opened) return
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      setActive(
        (current + (event.key === 'ArrowDown' ? 1 : -1) + options.length) %
          Math.max(options.length, 1),
      )
    } else if ((event.key === 'Enter' || event.key === 'Tab') && options[current]) {
      event.preventDefault()
      insert(options[current])
    } else if (event.key === 'Escape') {
      event.preventDefault()
      event.stopPropagation()
      close(true)
    }
  }
  const typed = (text: string, position: number) => {
    setCaret(position)
    if (text[position - 1] === '{' && text.length > value.length) {
      setOpened({ mode: 'typed', start: position - 1 })
      setActive(0)
      return
    }
    if (opened?.mode === 'typed') {
      const pending = text.slice(opened.start + 1, position)
      if (position <= opened.start || text[opened.start] !== '{' || !QUERY.test(pending))
        close(false)
    }
  }
  const listId = `${id}-variables`
  return (
    <fieldset
      aria-label={label}
      className="relative grid gap-2"
      onBlur={(event) => {
        if (opened && !event.currentTarget.contains(event.relatedTarget as Node | null))
          setOpened(null)
      }}
    >
      <Label htmlFor={id}>{label}</Label>
      <Textarea
        id={id}
        ref={field}
        value={value}
        rows={2}
        maxLength={maxLength}
        disabled={readOnly}
        aria-invalid={invalid || undefined}
        aria-describedby={
          [describedBy, readOnly ? null : `${id}-hint`].filter(Boolean).join(' ') || undefined
        }
        onChange={(event) => {
          onChange(event.target.value)
          typed(event.target.value, event.target.selectionStart)
        }}
        onSelect={(event) => setCaret(event.currentTarget.selectionStart)}
        onKeyDown={(event) => {
          if (opened?.mode === 'typed') navigate(event)
        }}
      />
      {!readOnly ? (
        <div className="flex flex-wrap items-center justify-between gap-2">
          <small id={`${id}-hint`} className="text-muted-foreground">
            {t('receiptTemplates.variableHint')}
          </small>
          <Button
            type="button"
            variant="outline"
            size="sm"
            aria-haspopup="listbox"
            aria-expanded={opened !== null}
            aria-controls={opened ? listId : undefined}
            onClick={() => {
              if (opened) return close(true)
              setOpened({ mode: 'button', at: field.current?.selectionStart ?? value.length })
              setActive(0)
              requestAnimationFrame(() => list.current?.focus())
            }}
          >
            {t('receiptTemplates.insertVariable')}
          </Button>
        </div>
      ) : null}
      {opened && options.length > 0 ? (
        <div
          ref={list}
          id={listId}
          role="listbox"
          tabIndex={-1}
          className="z-10 max-h-64 overflow-auto rounded-lg border bg-popover p-1 shadow-md"
          aria-label={t('receiptTemplates.variables.title')}
          aria-activedescendant={`${listId}-${current}`}
          onKeyDown={navigate}
        >
          {options.map((name, index) => (
            <div
              key={name}
              id={`${listId}-${index}`}
              role="option"
              tabIndex={-1}
              aria-selected={index === current}
              className="grid cursor-pointer gap-1 rounded-md p-2 text-sm aria-selected:bg-accent"
              onMouseDown={(event) => event.preventDefault()}
              onClick={() => insert(name)}
              onKeyDown={(event) => {
                if (event.key === 'Enter') insert(name)
              }}
            >
              <code>{`{${name}}`}</code>
              <span>{t(`receiptTemplates.variables.${name}`)}</span>
              <small className="text-muted-foreground">
                {samples[name] || t('receiptTemplates.variables.emptySample')}
              </small>
            </div>
          ))}
        </div>
      ) : null}
    </fieldset>
  )
}
