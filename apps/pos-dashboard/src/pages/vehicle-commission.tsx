import { formatMoney } from '@parkviet/pos-shared/money'
import { writesLocked } from '@parkviet/pos-shared/pos-context'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { Badge, Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { type FormEvent, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import {
  ModelCard,
  ModelNotice,
  ModelPage,
  ModelSelect,
  ModelState,
} from '../components/setup/model-ui'
import { usePosSession } from '../hooks/use-pos-session'
import {
  useBusOperators,
  useCommissionRules,
  useSaveBusOperator,
  useSaveCommissionRule,
  useSaveVisitSettings,
  useVisitSettings,
} from '../hooks/use-vehicle-commission'
import {
  type BusOperator,
  type CommissionRule,
  describeVehicleFailure,
  type RuleDraft,
  ruleBody,
  ruleDraft,
  VEHICLE_COMMISSION_MODULE,
  VEHICLE_TYPES,
} from '../lib/vehicle-commission'

type Notice = { text: string; failed: boolean } | null

// "Hoa hồng xe": the set-up of a rest stop's coach commission. How long a
// coach visit stays open, the bus operators, and the branch's rules: an
// amount per coach type and per guest, with minimums, dates and optionally one
// operator (whose own rule wins over the general one). A visit keeps the rule
// it closed with, so editing a rule never changes a closed visit. Paying the
// driver is counter work.
export function VehicleCommissionPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const branchId = context.data?.selection.branch_id ?? null
  const on = context.data?.modules?.[VEHICLE_COMMISSION_MODULE] === true
  return (
    <ModelPage
      title={t('vehicleCommission.title')}
      description={t('vehicleCommission.intro')}
      actions={<BranchPicker />}
    >
      {!branchId ? (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      ) : !on ? (
        <ModelState title={t('vehicleCommission.off')} />
      ) : (
        <div key={branchId} className="space-y-6">
          <VisitWindow branchId={branchId} />
          <Operators branchId={branchId} />
          <Rules branchId={branchId} />
        </div>
      )}
    </ModelPage>
  )
}

function useLocked() {
  const { context, selection } = usePosSession()
  return writesLocked(context.data, selection)
}

function VisitWindow({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const id = useId()
  const settings = useVisitSettings(branchId)
  const save = useSaveVisitSettings(branchId)
  const locked = useLocked()
  const [text, setText] = useState<string | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const current = settings.data?.data.visit_window_minutes
  const value = text ?? (current === undefined ? '' : String(current))
  const minutes = Number(value)
  const valid = /^\d+$/.test(value) && minutes >= 5 && minutes <= 1440

  async function submit(event: FormEvent) {
    event.preventDefault()
    if (!valid) return
    setNotice(null)
    try {
      await save.mutateAsync(minutes)
      setText(null)
      setNotice({ text: t('vehicleCommission.windowSaved', { minutes }), failed: false })
    } catch (failure) {
      setNotice({ text: describeVehicleFailure(failure, t), failed: true })
    }
  }

  return (
    <ModelCard title={t('vehicleCommission.windowTitle')} id={`${id}-window`}>
      {settings.isError ? (
        <ModelState title={describeFailure(settings.error, t)} error />
      ) : (
        <form className="flex flex-wrap items-end gap-3" onSubmit={submit}>
          <div className="space-y-2">
            <Label htmlFor={`${id}-minutes`}>{t('vehicleCommission.windowMinutes')}</Label>
            <Input
              id={`${id}-minutes`}
              inputMode="numeric"
              className="w-32"
              value={value}
              aria-invalid={value !== '' && !valid}
              disabled={locked || settings.isPending}
              onChange={(event) => setText(event.target.value.replace(/\D/g, ''))}
            />
          </div>
          <Button type="submit" disabled={locked || !valid || save.isPending || text === null}>
            {t('vehicleCommission.save')}
          </Button>
          <p className="w-full text-sm text-muted-foreground">
            {t('vehicleCommission.windowHint')}
          </p>
        </form>
      )}
      <ModelNotice notice={notice} />
    </ModelCard>
  )
}

function Operators({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const id = useId()
  const operators = useBusOperators(branchId)
  const save = useSaveBusOperator(branchId)
  const confirm = useConfirm()
  const locked = useLocked() || save.isPending
  const [editing, setEditing] = useState<BusOperator | null>(null)
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [notice, setNotice] = useState<Notice>(null)
  const rows = operators.data?.data ?? []

  function edit(operator: BusOperator | null) {
    setEditing(operator)
    setName(operator?.name ?? '')
    setPhone(operator?.phone ?? '')
  }

  async function run(action: () => Promise<BusOperator>) {
    setNotice(null)
    try {
      const saved = await action()
      setNotice({ text: t('vehicleCommission.operatorSaved', { name: saved.name }), failed: false })
      return true
    } catch (failure) {
      setNotice({ text: describeVehicleFailure(failure, t), failed: true })
      return false
    }
  }

  async function submit(event: FormEvent) {
    event.preventDefault()
    const ok = await run(() =>
      save.mutateAsync({
        id: editing?.id,
        values: { name: name.trim(), phone: phone.trim() },
      }),
    )
    if (ok) edit(null)
  }

  async function toggle(operator: BusOperator) {
    const archiving = operator.status === 'active'
    if (
      archiving &&
      !(await confirm({
        message: t('vehicleCommission.archiveOperatorConfirm', { name: operator.name }),
        variant: 'destructive',
        confirmLabel: t('vehicleCommission.archive'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await run(() =>
      save.mutateAsync({
        id: operator.id,
        values: { status: archiving ? 'archived' : 'active' },
      }),
    )
  }

  return (
    <ModelCard title={t('vehicleCommission.operatorsTitle')} id={`${id}-operators`}>
      <form className="flex flex-wrap items-end gap-3" onSubmit={submit}>
        <div className="space-y-2">
          <Label htmlFor={`${id}-name`}>{t('vehicleCommission.operatorName')}</Label>
          <Input
            id={`${id}-name`}
            value={name}
            maxLength={120}
            disabled={locked}
            onChange={(event) => setName(event.target.value)}
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor={`${id}-phone`}>{t('vehicleCommission.operatorPhone')}</Label>
          <Input
            id={`${id}-phone`}
            value={phone}
            maxLength={20}
            disabled={locked}
            onChange={(event) => setPhone(event.target.value)}
          />
        </div>
        <Button type="submit" disabled={locked || name.trim() === ''}>
          {editing ? t('vehicleCommission.save') : t('vehicleCommission.addOperator')}
        </Button>
        {editing && (
          <Button type="button" variant="outline" onClick={() => edit(null)}>
            {t('adminCancel')}
          </Button>
        )}
      </form>
      <ModelNotice notice={notice} />
      {operators.isError ? (
        <ModelState title={describeFailure(operators.error, t)} error />
      ) : rows.length === 0 ? (
        <ModelState title={t('vehicleCommission.operatorsEmpty')} />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full text-sm" aria-labelledby={`${id}-operators`}>
            <thead>
              <tr className="border-b text-left">
                <th className="p-2">{t('vehicleCommission.operatorName')}</th>
                <th className="p-2">{t('vehicleCommission.operatorPhone')}</th>
                <th className="p-2">{t('vehicleCommission.status')}</th>
                <th className="p-2">
                  <span className="sr-only">{t('vehicleCommission.actions')}</span>
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((operator) => (
                <tr key={operator.id} className="border-b last:border-0">
                  <td className="p-2">{operator.name}</td>
                  <td className="p-2">{operator.phone ?? '—'}</td>
                  <td className="p-2">
                    <Badge variant={operator.status === 'active' ? 'secondary' : 'warning'}>
                      {t(`vehicleCommission.status_${operator.status}`)}
                    </Badge>
                  </td>
                  <td className="space-x-2 p-2 text-right">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={locked}
                      onClick={() => edit(operator)}
                    >
                      {t('vehicleCommission.edit')}
                    </Button>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={locked}
                      onClick={() => void toggle(operator)}
                    >
                      {operator.status === 'active'
                        ? t('vehicleCommission.archive')
                        : t('vehicleCommission.restore')}
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </ModelCard>
  )
}

function Rules({ branchId }: { branchId: string }) {
  const { t } = useTranslation()
  const id = useId()
  const rules = useCommissionRules(branchId)
  const operators = useBusOperators(branchId)
  const save = useSaveCommissionRule(branchId)
  const confirm = useConfirm()
  const locked = useLocked() || save.isPending
  const [editing, setEditing] = useState<CommissionRule | null>(null)
  const [draft, setDraft] = useState<RuleDraft>(() => ruleDraft())
  const [notice, setNotice] = useState<Notice>(null)
  const rows = rules.data?.data ?? []
  const activeOperators = (operators.data?.data ?? []).filter(
    (operator) => operator.status === 'active' || operator.id === draft.busOperatorId,
  )
  const patch = (values: Partial<RuleDraft>) => setDraft((current) => ({ ...current, ...values }))

  function edit(rule: CommissionRule | null) {
    setEditing(rule)
    setDraft(ruleDraft(rule ?? undefined))
  }

  async function run(action: () => Promise<CommissionRule>) {
    setNotice(null)
    try {
      const saved = await action()
      setNotice({ text: t('vehicleCommission.ruleSaved', { name: saved.name }), failed: false })
      return true
    } catch (failure) {
      setNotice({ text: describeVehicleFailure(failure, t), failed: true })
      return false
    }
  }

  async function submit(event: FormEvent) {
    event.preventDefault()
    const result = ruleBody(draft)
    if ('invalid' in result) {
      setNotice({ text: t(`vehicleCommission.ruleInvalid_${result.invalid}`), failed: true })
      return
    }
    const ok = await run(() => save.mutateAsync({ id: editing?.id, values: result.body }))
    if (ok) edit(null)
  }

  async function toggle(rule: CommissionRule) {
    const archiving = rule.status === 'active'
    if (
      archiving &&
      !(await confirm({
        message: t('vehicleCommission.archiveRuleConfirm', { name: rule.name }),
        variant: 'destructive',
        confirmLabel: t('vehicleCommission.archive'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await run(() =>
      save.mutateAsync({ id: rule.id, values: { status: archiving ? 'archived' : 'active' } }),
    )
  }

  const money = (value: string) => (Number(value) > 0 ? formatMoney(value) : '—')
  const field = (key: string, label: string, value: string, onChange: (value: string) => void) => (
    <div className="space-y-2">
      <Label htmlFor={`${id}-${key}`}>{label}</Label>
      <Input
        id={`${id}-${key}`}
        inputMode="numeric"
        className="w-36"
        value={value}
        disabled={locked}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )

  return (
    <ModelCard title={t('vehicleCommission.rulesTitle')} id={`${id}-rules`}>
      <p className="text-sm text-muted-foreground">{t('vehicleCommission.rulesHint')}</p>
      <form className="space-y-3" onSubmit={submit}>
        <div className="flex flex-wrap items-end gap-3">
          <div className="space-y-2">
            <Label htmlFor={`${id}-rule-name`}>{t('vehicleCommission.ruleName')}</Label>
            <Input
              id={`${id}-rule-name`}
              value={draft.name}
              maxLength={120}
              disabled={locked}
              onChange={(event) => patch({ name: event.target.value })}
            />
          </div>
          <ModelSelect
            label={t('vehicleCommission.ruleOperator')}
            value={draft.busOperatorId}
            disabled={locked}
            options={[
              { value: '', label: t('vehicleCommission.ruleAllOperators') },
              ...activeOperators.map((operator) => ({ value: operator.id, label: operator.name })),
            ]}
            onChange={(value) => patch({ busOperatorId: value })}
          />
        </div>
        <div className="flex flex-wrap items-end gap-3">
          {VEHICLE_TYPES.map((type) =>
            field(type, t(`vehicleCommission.type_${type}`), draft.amounts[type], (value) =>
              patch({ amounts: { ...draft.amounts, [type]: value } }),
            ),
          )}
          {field('per-guest', t('vehicleCommission.perGuest'), draft.perGuest, (value) =>
            patch({ perGuest: value }),
          )}
        </div>
        <div className="flex flex-wrap items-end gap-3">
          {field('min-guests', t('vehicleCommission.minGuests'), draft.minGuests, (value) =>
            patch({ minGuests: value.replace(/\D/g, '') }),
          )}
          {field('min-revenue', t('vehicleCommission.minRevenue'), draft.minRevenue, (value) =>
            patch({ minRevenue: value }),
          )}
          <div className="space-y-2">
            <Label htmlFor={`${id}-starts`}>{t('vehicleCommission.startsOn')}</Label>
            <Input
              id={`${id}-starts`}
              type="date"
              value={draft.startsOn}
              disabled={locked}
              onChange={(event) => patch({ startsOn: event.target.value })}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor={`${id}-ends`}>{t('vehicleCommission.endsOn')}</Label>
            <Input
              id={`${id}-ends`}
              type="date"
              value={draft.endsOn}
              disabled={locked}
              onChange={(event) => patch({ endsOn: event.target.value })}
            />
          </div>
        </div>
        <div className="flex gap-2">
          <Button type="submit" disabled={locked}>
            {editing ? t('vehicleCommission.save') : t('vehicleCommission.addRule')}
          </Button>
          {editing && (
            <Button type="button" variant="outline" onClick={() => edit(null)}>
              {t('adminCancel')}
            </Button>
          )}
        </div>
      </form>
      <ModelNotice notice={notice} />
      {rules.isError ? (
        <ModelState title={describeFailure(rules.error, t)} error />
      ) : rows.length === 0 ? (
        <ModelState title={t('vehicleCommission.rulesEmpty')} />
      ) : (
        <div className="overflow-x-auto rounded-lg border">
          <table className="w-full text-sm" aria-labelledby={`${id}-rules`}>
            <thead>
              <tr className="border-b text-left">
                <th className="p-2">{t('vehicleCommission.ruleName')}</th>
                <th className="p-2">{t('vehicleCommission.ruleOperator')}</th>
                {VEHICLE_TYPES.map((type) => (
                  <th key={type} className="p-2 text-right">
                    {t(`vehicleCommission.type_${type}`)}
                  </th>
                ))}
                <th className="p-2 text-right">{t('vehicleCommission.perGuest')}</th>
                <th className="p-2">{t('vehicleCommission.period')}</th>
                <th className="p-2">{t('vehicleCommission.status')}</th>
                <th className="p-2">
                  <span className="sr-only">{t('vehicleCommission.actions')}</span>
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((rule) => (
                <tr key={rule.id} className="border-b last:border-0">
                  <td className="p-2">{rule.name}</td>
                  <td className="p-2">
                    {rule.bus_operator?.name ?? t('vehicleCommission.ruleAllOperators')}
                  </td>
                  {VEHICLE_TYPES.map((type) => (
                    <td key={type} className="p-2 text-right tabular-nums">
                      {money(rule.per_vehicle_amounts[type] ?? '0')}
                    </td>
                  ))}
                  <td className="p-2 text-right tabular-nums">{money(rule.per_guest_amount)}</td>
                  <td className="p-2">
                    {rule.starts_on || rule.ends_on
                      ? `${rule.starts_on ?? '…'} – ${rule.ends_on ?? '…'}`
                      : t('vehicleCommission.always')}
                  </td>
                  <td className="p-2">
                    <Badge variant={rule.status === 'active' ? 'secondary' : 'warning'}>
                      {t(`vehicleCommission.status_${rule.status}`)}
                    </Badge>
                  </td>
                  <td className="space-x-2 p-2 text-right">
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={locked}
                      onClick={() => edit(rule)}
                    >
                      {t('vehicleCommission.edit')}
                    </Button>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      disabled={locked}
                      onClick={() => void toggle(rule)}
                    >
                      {rule.status === 'active'
                        ? t('vehicleCommission.archive')
                        : t('vehicleCommission.restore')}
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </ModelCard>
  )
}
