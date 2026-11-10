import {
  LABEL_BODY_LENGTH,
  LABEL_NAME_MAX,
  LABEL_WEIGHT_UNITS,
  type LabelFormat,
  labelDigitsUsed,
  labelFormatBody,
  labelFormatDraft,
  labelFormatProblems,
} from '@parkviet/pos-shared/label-format'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { mapSpreeErrorsToForm, useResourceMutation } from '@spree/dashboard-core'
import { Button, DialogFooter, FieldDescription } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { saveLabelFormat } from '../hooks/use-branch-catalog'
import { type LabelFormatFormValues, labelFormatSchema } from '../schemas/label-format'
import { TopologyDialog } from './topology-dialog'
import { Input, TopologyField, TopologySelect } from './topology-fields'

export function LabelFormatEditor({
  format,
  onSaved,
  onClose,
}: {
  format?: LabelFormat
  onSaved: (saved: LabelFormat) => Promise<void> | void
  onClose: () => void
}) {
  const { t } = useTranslation()
  const form = useForm<LabelFormatFormValues>({ defaultValues: labelFormatDraft(format) })
  const draft = form.watch()
  const [error, setError] = useState('')
  const dirty = form.formState.isDirty
  const mutation = useResourceMutation({
    mutationFn: (body: Record<string, unknown>) => saveLabelFormat(format?.id, body),
    successMessage: false,
    errorMessage: false,
  })
  const busy = form.formState.isSubmitting
  const problems = labelFormatProblems(draft)
  const used = labelDigitsUsed(draft)
  const layoutProblem = problems.includes('layout')
  function set<K extends keyof LabelFormatFormValues>(key: K, value: LabelFormatFormValues[K]) {
    form.setValue(key, value as never, { shouldDirty: true })
  }
  async function submit(value: LabelFormatFormValues) {
    form.clearErrors()
    const parsed = labelFormatSchema.safeParse(value)
    if (!parsed.success) {
      for (const issue of parsed.error.issues)
        form.setError(issue.path[0] as keyof LabelFormatFormValues, {
          message: t(issue.message, { total: LABEL_BODY_LENGTH }),
        })
      return
    }
    const body = labelFormatBody(parsed.data)
    if (!body) return
    setError('')
    try {
      const result = await mutation.mutateAsync(body)
      await onSaved(result.data)
      onClose()
    } catch (failure) {
      mapSpreeErrorsToForm(failure, form.setError)
      setError(describeFailure(failure, t))
    }
  }
  function text(
    key: keyof LabelFormatFormValues,
    label: string,
    problem?: (typeof problems)[number],
    maxLength?: number,
    hint?: string,
  ) {
    const message = form.formState.errors[key]?.message
    return (
      <TopologyField label={t(label)} error={message} hint={hint && t(hint)}>
        {(id, describedBy) => (
          <Input
            id={id}
            aria-describedby={describedBy}
            maxLength={maxLength}
            aria-invalid={
              Boolean(message) || Boolean(dirty && problem && problems.includes(problem))
            }
            value={draft[key]}
            onChange={(e) => set(key, e.target.value as never)}
            inputMode={key === 'name' ? 'text' : key === 'price_tolerance' ? 'decimal' : 'numeric'}
          />
        )}
      </TopologyField>
    )
  }
  return (
    <TopologyDialog
      title={t(format ? 'labelFormatEditTitle' : 'labelFormatCreateTitle')}
      subtitle={format ? t('labelFormatVersion', { version: format.version }) : undefined}
      dirty={dirty}
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          noValidate
          onSubmit={form.handleSubmit(submit)}
          aria-busy={busy}
          className="space-y-5"
        >
          <fieldset disabled={busy} className="space-y-4">
            {text('name', 'labelFormatName', 'name', LABEL_NAME_MAX)}
            <TopologyField label={t('labelFormatKind')}>
              {(id) => (
                <TopologySelect
                  id={id}
                  value={draft.kind}
                  options={['weight', 'price'].map((value) => ({
                    value,
                    label: t(`labelFormatKind_${value}`),
                  }))}
                  onChange={(value) => {
                    const kind = value === 'price' ? 'price' : 'weight'
                    set('kind', kind)
                    set('value_unit_code', kind === 'price' ? '' : draft.value_unit_code || 'g')
                  }}
                />
              )}
            </TopologyField>
            <fieldset aria-label={t('labelFormatLayout')} className="grid gap-4 sm:grid-cols-2">
              {text('prefix', 'labelFormatPrefix', 'prefix', 4)}
              {text('item_code_length', 'labelFormatItemCodeLength', 'itemCodeLength', 2)}
              {text('value_length', 'labelFormatValueLength', 'valueLength', 2)}
              {text('value_decimals', 'labelFormatDecimals', 'decimals', 1)}
            </fieldset>
            <p
              aria-live="polite"
              className={layoutProblem ? 'text-destructive' : 'text-muted-foreground'}
            >
              {used === null
                ? t('labelFormatLayoutUnknown', { total: LABEL_BODY_LENGTH })
                : t(layoutProblem ? 'labelFormatLayoutInvalid' : 'labelFormatLayoutValid', {
                    used,
                    total: LABEL_BODY_LENGTH,
                  })}
            </p>
            {draft.kind === 'weight' ? (
              <TopologyField
                label={t('labelFormatUnit')}
                error={form.formState.errors.value_unit_code?.message}
              >
                {(id) => (
                  <TopologySelect
                    id={id}
                    value={draft.value_unit_code}
                    onChange={(value) => set('value_unit_code', value)}
                    options={[
                      { value: '', label: t('labelFormatChooseUnit') },
                      ...LABEL_WEIGHT_UNITS.map((value) => ({ value, label: value })),
                    ]}
                  />
                )}
              </TopologyField>
            ) : (
              text(
                'price_tolerance',
                'labelFormatTolerance',
                'tolerance',
                undefined,
                'labelFormatToleranceHint',
              )
            )}
            {format && <FieldDescription>{t('labelFormatVersionNote')}</FieldDescription>}
          </fieldset>
          {dirty && problems.length > 0 && (
            <div aria-live="polite" className="text-sm text-destructive">
              {problems.map((problem) => (
                <p key={problem}>
                  {t(`labelFormatProblem_${problem}`, { total: LABEL_BODY_LENGTH })}
                </p>
              ))}
            </div>
          )}
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={close}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !dirty || problems.length > 0}>
              {t(busy ? 'waiting' : 'save')}
            </Button>
          </DialogFooter>
        </form>
      )}
    </TopologyDialog>
  )
}
