import { formatMoney } from '@parkviet/pos-shared/money'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { usePermissions } from '@spree/dashboard-core'
import { Badge, Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { type FormEvent, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ProductSearch } from '../components/product-search'
import {
  ModelCard,
  ModelCheck,
  ModelNotice,
  ModelSelect,
  ModelState,
} from '../components/setup/model-ui'
import { usePosSession } from '../hooks/use-pos-session'
import {
  type RatePlanInput,
  useRatePlans,
  useRatePlanWrite,
  useRatePreview,
  useSpecialDays,
} from '../hooks/use-rate-plans'
import { canManageRatePlans } from '../lib/pos-access'
import {
  clockToMinutes,
  coverageProblems,
  DAY_TYPES,
  type DayType,
  minutesToClock,
  type RatePlan,
  ratePlanFailure,
} from '../lib/rate-plans'

type Notice = { text: string; failed: boolean } | null
type RuleDraft = {
  key: string
  day_type: DayType
  start: string
  end: string
  price: string
  label: string
}
type PlanDraft = {
  name: string
  resourceType: string
  variantId: string
  variantName: string
  block: string
  grace: string
  minimum: string
  rules: RuleDraft[]
}

// Monday to Sunday; the server numbers Sunday 0.
const WEEK_DAYS = [1, 2, 3, 4, 5, 6, 0] as const
let ruleSequence = 0
const ruleKey = () => {
  ruleSequence += 1
  return `rule-${ruleSequence}`
}

function draftOf(plan: RatePlan | null): PlanDraft {
  if (!plan)
    return {
      name: '',
      resourceType: '',
      variantId: '',
      variantName: '',
      block: '15',
      grace: '5',
      minimum: '60',
      rules: [
        { key: ruleKey(), day_type: 'weekday', start: '00:00', end: '24:00', price: '', label: '' },
        { key: ruleKey(), day_type: 'weekend', start: '00:00', end: '24:00', price: '', label: '' },
      ],
    }
  return {
    name: plan.name,
    resourceType: plan.resource_type_code,
    variantId: plan.variant_id,
    variantName: plan.variant_name ?? plan.variant_id,
    block: String(plan.block_minutes),
    grace: String(plan.grace_minutes),
    minimum: String(plan.minimum_minutes),
    rules: plan.rules.map((rule) => ({
      key: ruleKey(),
      day_type: rule.day_type,
      start: minutesToClock(rule.start_minute),
      end: minutesToClock(rule.end_minute),
      price: String(Number(rule.price_per_hour)),
      label: rule.label ?? '',
    })),
  }
}

const wholeMinutes = (value: string) => (/^\d{1,4}$/.test(value.trim()) ? Number(value) : null)
const price = (value: string) => (/^\d{1,12}(\.\d{1,2})?$/.test(value.trim()) ? value.trim() : null)

// The draft as the server takes it, or null while a field is unreadable.
function inputOf(draft: PlanDraft): RatePlanInput | null {
  const block = wholeMinutes(draft.block)
  const grace = wholeMinutes(draft.grace)
  const minimum = wholeMinutes(draft.minimum)
  if (!draft.name.trim() || !draft.resourceType.trim() || !draft.variantId) return null
  if (block === null || block < 1 || grace === null || minimum === null) return null
  const rules = draft.rules.map((rule) => ({
    day_type: rule.day_type,
    start_minute: clockToMinutes(rule.start),
    end_minute: clockToMinutes(rule.end),
    price_per_hour: price(rule.price),
    label: rule.label.trim() || null,
  }))
  if (
    rules.some(
      (rule) => rule.start_minute === null || rule.end_minute === null || !rule.price_per_hour,
    )
  )
    return null
  return {
    name: draft.name.trim(),
    resource_type_code: draft.resourceType.trim(),
    variant_id: draft.variantId,
    block_minutes: block,
    grace_minutes: grace,
    minimum_minutes: minimum,
    rules: rules.map((rule) => ({
      ...rule,
      start_minute: (rule.start_minute ?? 0) % 1440,
      end_minute: rule.end_minute ?? 1440,
      price_per_hour: rule.price_per_hour ?? '0',
    })),
  }
}

// "Giá giờ": the prices of play time at a branch (karaoke rooms, billiard
// tables): plans per kind of room with their time bands, the weekend days,
// holidays and a priced preview of a stay.
export function BranchRatePlansTab() {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const write = canManageRatePlans({ permissionKeys, context: context.data })
  const plans = useRatePlans(branch.id)
  const [editing, setEditing] = useState<RatePlan | 'new' | null>(null)
  const list = plans.data?.data ?? []
  const active = list.filter((plan) => plan.status === 'active')
  return (
    <div className="space-y-6">
      <ModelCard title={t('ratePlans.title')} id="branch-rate-plans">
        <p className="text-sm text-muted-foreground">{t('ratePlans.intro')}</p>
        {plans.isError ? (
          <ModelState
            title={describeFailure(plans.error, t)}
            error
            retry={() => void plans.refetch()}
          />
        ) : !plans.data ? (
          <ModelState title={t('waiting')} />
        ) : (
          <>
            {list.length === 0 ? <p className="text-sm">{t('ratePlans.empty')}</p> : null}
            <ul className="divide-y rounded-lg border" aria-label={t('ratePlans.title')}>
              {list.map((plan) => (
                <li
                  key={plan.id}
                  className="flex flex-wrap items-center gap-3 p-3"
                  data-testid={`rate-plan-${plan.id}`}
                >
                  <div className="min-w-0 flex-1">
                    <p className="font-medium">
                      {plan.name}{' '}
                      <span className="text-sm text-muted-foreground">
                        · {plan.resource_type_code} · {plan.variant_name ?? plan.variant_id}
                      </span>
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {t('ratePlans.rounding', {
                        block: plan.block_minutes,
                        grace: plan.grace_minutes,
                        minimum: plan.minimum_minutes,
                      })}
                    </p>
                  </div>
                  <Badge variant="outline">
                    {t('ratePlans.version', { version: plan.version })}
                  </Badge>
                  <Badge variant={plan.status === 'active' ? 'default' : 'secondary'}>
                    {t(`ratePlans.status_${plan.status}`)}
                  </Badge>
                  {write && plan.status === 'active' ? (
                    <Button variant="outline" onClick={() => setEditing(plan)}>
                      {t('ratePlans.edit')}
                    </Button>
                  ) : null}
                </li>
              ))}
            </ul>
            {write && editing === null ? (
              <Button onClick={() => setEditing('new')}>{t('ratePlans.add')}</Button>
            ) : null}
            {editing ? (
              <PlanEditor
                key={editing === 'new' ? 'new' : editing.id}
                plan={editing === 'new' ? null : editing}
                onDone={() => setEditing(null)}
              />
            ) : null}
          </>
        )}
      </ModelCard>
      {plans.data ? (
        <WeekendCard
          key={(plans.data.meta.weekend_days ?? []).join()}
          days={plans.data.meta.weekend_days ?? [6, 0]}
          write={write}
        />
      ) : null}
      <HolidaysCard write={write} />
      {active.length > 0 ? <PreviewCard plans={active} /> : null}
    </div>
  )
}

function PlanEditor({ plan, onDone }: { plan: RatePlan | null; onDone: () => void }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const mutation = useRatePlanWrite(branch.id)
  const [draft, setDraft] = useState<PlanDraft>(() => draftOf(plan))
  const [notice, setNotice] = useState<Notice>(null)
  const input = inputOf(draft)
  const problems = input?.rules ? coverageProblems(input.rules) : []
  const set = (patch: Partial<PlanDraft>) => setDraft((current) => ({ ...current, ...patch }))
  const setRule = (key: string, patch: Partial<RuleDraft>) =>
    set({ rules: draft.rules.map((rule) => (rule.key === key ? { ...rule, ...patch } : rule)) })

  async function save(event: FormEvent) {
    event.preventDefault()
    if (!input || problems.length > 0 || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({ kind: 'plan', id: plan?.id, input })
      onDone()
    } catch (failure) {
      setNotice({ text: ratePlanFailure(failure, t), failed: true })
    }
  }

  async function archive() {
    if (!plan || mutation.isPending) return
    try {
      await mutation.mutateAsync({ kind: 'plan', id: plan.id, input: { status: 'archived' } })
      onDone()
    } catch (failure) {
      setNotice({ text: ratePlanFailure(failure, t), failed: true })
    }
  }

  return (
    <form
      className="space-y-4 rounded-lg border p-4"
      onSubmit={(event) => void save(event)}
      aria-label={t('ratePlans.editor')}
    >
      <ModelNotice notice={notice} />
      {plan ? <p className="text-sm text-muted-foreground">{t('ratePlans.versionHint')}</p> : null}
      <div className="grid gap-3 sm:grid-cols-2">
        <Field label={t('ratePlans.name')} value={draft.name} onChange={(name) => set({ name })} />
        <Field
          label={t('ratePlans.resourceType')}
          hint={t('ratePlans.resourceTypeHint')}
          value={draft.resourceType}
          onChange={(resourceType) => set({ resourceType })}
        />
        <Field
          label={t('ratePlans.block')}
          value={draft.block}
          numeric
          onChange={(block) => set({ block })}
        />
        <Field
          label={t('ratePlans.grace')}
          value={draft.grace}
          numeric
          onChange={(grace) => set({ grace })}
        />
        <Field
          label={t('ratePlans.minimum')}
          value={draft.minimum}
          numeric
          onChange={(minimum) => set({ minimum })}
        />
      </div>
      <div className="space-y-1">
        <ProductSearch
          branchId={branch.id}
          label={t('ratePlans.service')}
          onPick={(hit) => set({ variantId: hit.variantId, variantName: hit.name })}
        />
        <p className="text-sm">{draft.variantName || t('ratePlans.serviceMissing')}</p>
        <p className="text-sm text-muted-foreground">{t('ratePlans.serviceHint')}</p>
      </div>
      <fieldset className="space-y-3">
        <legend className="font-medium">{t('ratePlans.bands')}</legend>
        {draft.rules.map((rule, index) => (
          <div
            key={rule.key}
            className="grid items-end gap-2 sm:grid-cols-6"
            data-testid="rate-rule"
          >
            <ModelSelect
              label={t('ratePlans.dayType')}
              value={rule.day_type}
              options={DAY_TYPES.map((value) => ({ value, label: t(`ratePlans.day_${value}`) }))}
              onChange={(value) => setRule(rule.key, { day_type: value as DayType })}
            />
            <Field
              label={t('ratePlans.from')}
              value={rule.start}
              onChange={(start) => setRule(rule.key, { start })}
            />
            <Field
              label={t('ratePlans.to')}
              value={rule.end}
              onChange={(end) => setRule(rule.key, { end })}
            />
            <Field
              label={t('ratePlans.pricePerHour')}
              value={rule.price}
              numeric
              onChange={(value) => setRule(rule.key, { price: value })}
            />
            <Field
              label={t('ratePlans.bandLabel')}
              value={rule.label}
              onChange={(label) => setRule(rule.key, { label })}
            />
            <Button
              type="button"
              variant="outline"
              aria-label={t('ratePlans.removeBand', { index: index + 1 })}
              onClick={() => set({ rules: draft.rules.filter((row) => row.key !== rule.key) })}
            >
              {t('ratePlans.remove')}
            </Button>
          </div>
        ))}
        <Button
          type="button"
          variant="outline"
          onClick={() =>
            set({
              rules: [
                ...draft.rules,
                {
                  key: ruleKey(),
                  day_type: 'weekday',
                  start: '18:00',
                  end: '24:00',
                  price: '',
                  label: '',
                },
              ],
            })
          }
        >
          {t('ratePlans.addBand')}
        </Button>
        <p className="text-sm text-muted-foreground">{t('ratePlans.bandsHint')}</p>
        {problems.length > 0 ? (
          <p role="alert" className="text-sm text-destructive">
            {t('ratePlans.coverage', {
              days: problems.map((day) => t(`ratePlans.day_${day}`)).join(', '),
            })}
          </p>
        ) : null}
      </fieldset>
      <div className="flex flex-wrap gap-2">
        <Button type="submit" disabled={!input || problems.length > 0 || mutation.isPending}>
          {t('ratePlans.save')}
        </Button>
        <Button type="button" variant="outline" onClick={onDone}>
          {t('ratePlans.cancel')}
        </Button>
        {plan ? (
          <Button
            type="button"
            variant="outline"
            disabled={mutation.isPending}
            onClick={() => void archive()}
          >
            {t('ratePlans.archive')}
          </Button>
        ) : null}
      </div>
    </form>
  )
}

function Field({
  label,
  value,
  onChange,
  numeric,
  hint,
  type,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  numeric?: boolean
  hint?: string
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
        inputMode={numeric ? 'numeric' : undefined}
        onChange={(event) => onChange(event.target.value)}
      />
      {hint ? <p className="text-sm text-muted-foreground">{hint}</p> : null}
    </div>
  )
}

function WeekendCard({ days, write }: { days: number[]; write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const mutation = useRatePlanWrite(branch.id)
  const [chosen, setChosen] = useState<number[]>(days)
  const [notice, setNotice] = useState<Notice>(null)
  const changed = [...chosen].sort().join() !== [...days].sort().join()
  async function save(event: FormEvent) {
    event.preventDefault()
    if (mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({ kind: 'weekend_days', days: chosen })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: ratePlanFailure(failure, t), failed: true })
    }
  }
  return (
    <ModelCard title={t('ratePlans.weekend')} id="branch-weekend-days">
      <p className="text-sm text-muted-foreground">{t('ratePlans.weekendIntro')}</p>
      <ModelNotice notice={notice} />
      <form className="space-y-3" onSubmit={(event) => void save(event)}>
        <fieldset className="flex flex-wrap gap-4">
          <legend className="sr-only">{t('ratePlans.weekend')}</legend>
          {WEEK_DAYS.map((day) => (
            <ModelCheck
              key={day}
              checked={chosen.includes(day)}
              disabled={!write}
              onChange={(on) =>
                setChosen((current) =>
                  on ? [...current, day] : current.filter((row) => row !== day),
                )
              }
            >
              {t(`ratePlans.weekDay_${day}`)}
            </ModelCheck>
          ))}
        </fieldset>
        {write ? (
          <Button type="submit" disabled={!changed || mutation.isPending}>
            {t('ratePlans.save')}
          </Button>
        ) : null}
      </form>
    </ModelCard>
  )
}

function HolidaysCard({ write }: { write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const days = useSpecialDays(branch.id)
  const mutation = useRatePlanWrite(branch.id)
  const confirm = useConfirm()
  const [date, setDate] = useState('')
  const [name, setName] = useState('')
  const [surcharge, setSurcharge] = useState('')
  const [notice, setNotice] = useState<Notice>(null)
  const ready =
    /^\d{4}-\d{2}-\d{2}$/.test(date) &&
    name.trim().length > 0 &&
    (!surcharge || price(surcharge) !== null)

  async function add(event: FormEvent) {
    event.preventDefault()
    if (!ready || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        kind: 'special_day',
        date,
        name: name.trim(),
        holiday_surcharge_percent: surcharge.trim(),
      })
      setDate('')
      setName('')
      setSurcharge('')
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: ratePlanFailure(failure, t), failed: true })
    }
  }

  async function remove(id: string, label: string) {
    const ok = await confirm({
      message: t('ratePlans.removeHoliday', { name: label }),
      variant: 'destructive',
      confirmLabel: t('ratePlans.remove'),
      cancelLabel: t('adminCancel'),
    })
    if (!ok) return
    try {
      await mutation.mutateAsync({ kind: 'remove_special_day', id })
    } catch (failure) {
      setNotice({ text: ratePlanFailure(failure, t), failed: true })
    }
  }

  return (
    <ModelCard title={t('ratePlans.holidays')} id="branch-holidays">
      <p className="text-sm text-muted-foreground">{t('ratePlans.holidaysIntro')}</p>
      <ModelNotice notice={notice} />
      {days.isError ? (
        <ModelState
          title={describeFailure(days.error, t)}
          error
          retry={() => void days.refetch()}
        />
      ) : !days.data ? (
        <ModelState title={t('waiting')} />
      ) : (
        <ul className="divide-y rounded-lg border" aria-label={t('ratePlans.holidays')}>
          {days.data.length === 0 ? (
            <li className="p-3 text-sm">{t('ratePlans.holidaysEmpty')}</li>
          ) : null}
          {days.data.map((day) => (
            <li key={day.id} className="flex items-center gap-3 p-3">
              <span className="flex-1">
                {day.date} · {day.name}
                {day.holiday_surcharge_percent
                  ? ` · ${t('ratePlans.surchargeShown', { percent: Number(day.holiday_surcharge_percent) })}`
                  : ''}
              </span>
              {write ? (
                <Button variant="outline" onClick={() => void remove(day.id, day.name)}>
                  {t('ratePlans.remove')}
                </Button>
              ) : null}
            </li>
          ))}
        </ul>
      )}
      {write ? (
        <form className="grid items-end gap-3 sm:grid-cols-4" onSubmit={(event) => void add(event)}>
          <Field label={t('ratePlans.date')} type="date" value={date} onChange={setDate} />
          <Field label={t('ratePlans.holidayName')} value={name} onChange={setName} />
          <Field
            label={t('ratePlans.surcharge')}
            value={surcharge}
            numeric
            onChange={setSurcharge}
          />
          <Button type="submit" disabled={!ready || mutation.isPending}>
            {t('ratePlans.addHoliday')}
          </Button>
        </form>
      ) : null}
    </ModelCard>
  )
}

// "datetime-local" gives the browser's local time; the server reads it with its offset.
const isoOf = (value: string) => {
  const time = Date.parse(value)
  return Number.isFinite(time) ? new Date(time).toISOString() : null
}

function PreviewCard({ plans }: { plans: RatePlan[] }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const [planId, setPlanId] = useState(plans[0]?.id ?? '')
  const [from, setFrom] = useState('')
  const [to, setTo] = useState('')
  const [asked, setAsked] = useState<{ startedAt: string; endedAt: string } | null>(null)
  const preview = useRatePreview(branch.id, planId || null, asked)
  const startedAt = isoOf(from)
  const endedAt = isoOf(to)
  return (
    <ModelCard title={t('ratePlans.preview')} id="branch-rate-preview">
      <p className="text-sm text-muted-foreground">{t('ratePlans.previewIntro')}</p>
      <form
        className="grid items-end gap-3 sm:grid-cols-4"
        onSubmit={(event) => {
          event.preventDefault()
          if (startedAt && endedAt) setAsked({ startedAt, endedAt })
        }}
      >
        <ModelSelect
          label={t('ratePlans.plan')}
          value={planId}
          options={plans.map((plan) => ({
            value: plan.id,
            label: `${plan.name} · ${plan.resource_type_code}`,
          }))}
          onChange={(value) => {
            setPlanId(value)
            setAsked(null)
          }}
        />
        <Field label={t('ratePlans.from')} type="datetime-local" value={from} onChange={setFrom} />
        <Field label={t('ratePlans.to')} type="datetime-local" value={to} onChange={setTo} />
        <Button type="submit" disabled={!startedAt || !endedAt}>
          {t('ratePlans.previewRun')}
        </Button>
      </form>
      {preview.isError ? (
        <p role="alert" className="text-sm text-destructive">
          {ratePlanFailure(preview.error, t)}
        </p>
      ) : preview.data ? (
        <div className="space-y-1 text-sm" data-testid="rate-preview">
          <p>
            {t('ratePlans.previewResult', {
              played: preview.data.played_minutes,
              billed: preview.data.billed_minutes,
            })}{' '}
            <strong>{formatMoney(preview.data.amount, preview.data.currency ?? 'VND')}</strong>
          </p>
          <ul>
            {preview.data.lines.map((line) => (
              <li key={line.starts_at}>
                {line.label ?? '—'} · {t('ratePlans.minutes', { count: line.minutes })} ·{' '}
                {formatMoney(line.price_per_hour, preview.data?.currency ?? 'VND')}/h ·{' '}
                {formatMoney(line.amount, preview.data?.currency ?? 'VND')}
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </ModelCard>
  )
}
