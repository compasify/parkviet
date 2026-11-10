import {
  matchingPreset,
  ORDER_SOURCES,
  orderSourceKey,
  RANGE_PRESETS,
  rangePreset,
} from '@parkviet/pos-shared/order-source'
import type { ReportType } from '@parkviet/pos-shared/reports'
import { Button, Card, CardContent, Checkbox, Input, Label } from '@spree/dashboard-ui'
import { type ReactNode, useId } from 'react'
import { useTranslation } from 'react-i18next'
import type { ReportSearch } from '../../schemas/report-search'
import { FilterSelect } from '../filter-select'

// The "all" choice of a single-choice filter; no filter value uses it.
const ALL = '*'

export type ReportFilterPatch = Partial<
  Pick<
    ReportSearch,
    | 'from'
    | 'to'
    | 'registerId'
    | 'shiftId'
    | 'mine'
    | 'section'
    | 'orderSource'
    | 'kind'
    | 'source'
    | 'status'
  >
>

const pick = <T extends string>(value: string) => (value === ALL ? undefined : (value as T))

export function ReportFilters({
  type,
  search,
  today,
  from,
  to,
  dated,
  registers,
  shifts,
  onChange,
  children,
}: {
  type: ReportType
  search: ReportSearch
  today: string
  from: string
  to: string
  dated: boolean
  registers: { id: string; name: string }[]
  shifts: { id: string; label: string }[]
  onChange: (patch: ReportFilterPatch) => void
  children?: ReactNode
}) {
  const { t } = useTranslation()
  const ids = useId()
  const selected = matchingPreset({ from, to }, today)
  return (
    <Card>
      <CardContent className="space-y-4">
        {dated && (
          <fieldset className="flex flex-wrap gap-2">
            <legend className="sr-only">{t('reportRangeQuick')}</legend>
            {RANGE_PRESETS.map((preset) => (
              <Button
                key={preset}
                type="button"
                size="sm"
                variant={selected === preset ? 'default' : 'outline'}
                aria-pressed={selected === preset}
                onClick={() =>
                  onChange(
                    preset === 'today'
                      ? { from: undefined, to: undefined }
                      : rangePreset(preset, today),
                  )
                }
              >
                {t(`reportRange_${preset}`)}
              </Button>
            ))}
          </fieldset>
        )}
        <form
          className="flex flex-wrap items-end gap-3"
          onSubmit={(event) => event.preventDefault()}
        >
          {dated && (
            <>
              <div className="grid gap-1.5">
                <Label htmlFor={`${ids}-from`}>{t('reportFrom')}</Label>
                <Input
                  id={`${ids}-from`}
                  type="date"
                  className="w-40"
                  value={from}
                  max={to}
                  onChange={(event) => onChange({ from: event.target.value || undefined, to })}
                />
              </div>
              <div className="grid gap-1.5">
                <Label htmlFor={`${ids}-to`}>{t('reportTo')}</Label>
                <Input
                  id={`${ids}-to`}
                  type="date"
                  className="w-40"
                  value={to}
                  min={from}
                  onChange={(event) => onChange({ from, to: event.target.value || undefined })}
                />
              </div>
            </>
          )}
          <FilterSelect
            label={t('register')}
            value={search.registerId ?? ALL}
            options={[
              { value: ALL, label: t('reportAllRegisters') },
              ...registers.map((row) => ({ value: row.id, label: row.name })),
            ]}
            onChange={(value) => onChange({ registerId: pick(value) })}
          />
          <FilterSelect
            label={t('reportShift')}
            value={search.shiftId ?? ALL}
            options={[
              { value: ALL, label: t('reportAllShifts') },
              ...shifts.map((row) => ({ value: row.id, label: row.label })),
              ...(search.shiftId && !shifts.some((row) => row.id === search.shiftId)
                ? [{ value: search.shiftId, label: search.shiftId }]
                : []),
            ]}
            onChange={(value) => onChange({ shiftId: pick(value) })}
          />
          {type === 'sales' && (
            <>
              <FilterSelect
                label={t('reportSection')}
                value={search.section ?? ALL}
                options={[
                  { value: ALL, label: t('reportSection_sales') },
                  { value: 'returns', label: t('reportSection_returns') },
                ]}
                onChange={(value) => onChange({ section: pick(value) })}
              />
              <FilterSelect
                label={t('reportCol_order_source')}
                value={search.orderSource ?? ALL}
                options={[
                  { value: ALL, label: t('reportAll') },
                  ...ORDER_SOURCES.map((value) => ({ value, label: t(orderSourceKey(value)) })),
                ]}
                onChange={(value) => onChange({ orderSource: pick(value) })}
              />
            </>
          )}
          {type === 'receipts' && (
            <>
              <FilterSelect
                label={t('reportKind')}
                value={search.kind ?? ALL}
                options={[
                  { value: ALL, label: t('reportAll') },
                  { value: 'cash', label: t('reportKind_cash') },
                  { value: 'bank_manual', label: t('reportKind_bank_manual') },
                ]}
                onChange={(value) => onChange({ kind: pick(value) })}
              />
              <FilterSelect
                label={t('reportSource')}
                value={search.source ?? ALL}
                options={[
                  { value: ALL, label: t('reportAll') },
                  { value: 'sale', label: t('reportSource_sale') },
                  { value: 'collection', label: t('reportSource_collection') },
                  { value: 'unsolicited', label: t('reportSource_unsolicited') },
                ]}
                onChange={(value) => onChange({ source: pick(value) })}
              />
            </>
          )}
          {type === 'receivables' && (
            <FilterSelect
              label={t('reportStatus')}
              value={search.status ?? ALL}
              options={[
                { value: ALL, label: t('reportStatus_open') },
                { value: 'overdue', label: t('reportStatus_overdue') },
                { value: 'settled', label: t('reportStatus_settled') },
                { value: 'all', label: t('reportAll') },
              ]}
              onChange={(value) => onChange({ status: pick(value) })}
            />
          )}
          <div className="flex h-9 items-center gap-2">
            <Checkbox
              id={`${ids}-mine`}
              checked={Boolean(search.mine)}
              onCheckedChange={(checked) => onChange({ mine: checked || undefined })}
            />
            <Label htmlFor={`${ids}-mine`} className="font-normal">
              {t('reportMineOnly')}
            </Label>
          </div>
          {children}
        </form>
      </CardContent>
    </Card>
  )
}
