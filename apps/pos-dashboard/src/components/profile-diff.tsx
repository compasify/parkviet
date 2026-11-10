import { isPosFeature } from '@parkviet/pos-shared/pos-features'
import { profileLabelKey } from '@parkviet/pos-shared/pos-modules'
import { useTranslation } from 'react-i18next'
import type { ProfilePreview } from '../hooks/use-branch-modules'
import { ModelCheck, ModelStatus } from './setup/model-ui'
import { ModuleName, unitLabel } from './setup-preview-step'

type Translate = (key: string, options?: Record<string, unknown>) => string
const DEFAULT_LABELS: Record<string, string> = {
  return_window_days: 'adminReturnWindow',
  lot_selection: 'adminLotSelection',
  variance_threshold: 'adminVarianceThreshold',
  adjustment_approval_threshold: 'adminAdjustmentThreshold',
}
export function defaultLabel(t: Translate, field: string) {
  return DEFAULT_LABELS[field] ? t(DEFAULT_LABELS[field]) : field
}
export function defaultValue(t: Translate, field: string, value: unknown) {
  if (value === null || value === undefined || value === '') return t('businessModel.valueBlank')
  if (field === 'lot_selection' && (value === 'fefo' || value === 'cashier_pick'))
    return t(`adminLotSelection_${value}`)
  if (field === 'return_window_days') return t('businessModel.valueDays', { count: Number(value) })
  return String(value)
}
function usageText(t: Translate, counts: Record<string, number>) {
  const parts = Object.entries(counts)
    .filter(([, count]) => count > 0)
    .map(([name, count]) =>
      t(`businessModel.usage_${name}`, { count, defaultValue: `${name}: ${count}` }),
    )
  return parts.length
    ? t('businessModel.inUse', { list: parts.join(', ') })
    : t('businessModel.notInUse')
}

export function ProfileDiff({
  preview,
  applyModules,
  applyDefaults,
  disabled,
  onApplyModules,
  onApplyDefault,
}: {
  branchId: string
  preview: ProfilePreview
  applyModules: boolean
  applyDefaults: string[]
  disabled: boolean
  onApplyModules: (value: boolean) => void
  onApplyDefault: (field: string, value: boolean) => void
}) {
  const { t } = useTranslation()
  const moduleChanges = preview.enable.length + preview.disable.length > 0
  const features = preview.recommendedFeatures.filter(isPosFeature)
  return (
    <section
      className="space-y-6 rounded-md border p-4"
      aria-label={t('businessModel.diffLabel', { name: t(profileLabelKey(preview.to)) })}
    >
      <section aria-labelledby="profile-diff-modules" className="space-y-3">
        <h4 id="profile-diff-modules" className="font-semibold">
          {t('businessModel.diffModules')}
        </h4>
        {moduleChanges ? (
          <>
            <ul className="space-y-3">
              {preview.enable.map((key) => (
                <li key={key} data-change="enable" data-module={key}>
                  <ModelStatus on>{t('businessModel.willEnable')}</ModelStatus>{' '}
                  <strong>
                    <ModuleName moduleKey={key} />
                  </strong>
                </li>
              ))}
              {preview.disable.map((key) => (
                <li key={key} data-change="disable" data-module={key}>
                  <ModelStatus on={false}>{t('businessModel.willDisable')}</ModelStatus>{' '}
                  <strong>
                    <ModuleName moduleKey={key} />
                  </strong>
                  <p className="text-sm text-muted-foreground">
                    {usageText(t, preview.inUse[key] ?? {})}
                  </p>
                </li>
              ))}
            </ul>
            {preview.disable.length ? (
              <p className="rounded-md bg-muted p-3" role="note">
                {t('businessModel.disableWarning')}
              </p>
            ) : null}
            <ModelCheck
              checked={applyModules}
              disabled={disabled}
              onChange={onApplyModules}
              description={t('businessModel.applyModulesHint')}
            >
              {t('businessModel.applyModules')}
            </ModelCheck>
          </>
        ) : (
          <p>{t('businessModel.diffModulesSame')}</p>
        )}
      </section>
      <section aria-labelledby="profile-diff-defaults" className="space-y-3">
        <h4 id="profile-diff-defaults" className="font-semibold">
          {t('businessModel.diffDefaults')}
        </h4>
        {preview.defaults.length ? (
          <ul className="divide-y">
            {preview.defaults.map((change) => {
              const name = defaultLabel(t, change.field)
              return (
                <li
                  key={change.field}
                  data-field={change.field}
                  className="flex flex-wrap items-center justify-between gap-4 py-3"
                >
                  <div>
                    <strong>{name}</strong>
                    <p className="text-sm text-muted-foreground">
                      {t('businessModel.defaultChange', {
                        current: defaultValue(t, change.field, change.current),
                        profile: defaultValue(t, change.field, change.profile),
                      })}
                    </p>
                  </div>
                  <ModelCheck
                    checked={applyDefaults.includes(change.field)}
                    disabled={disabled}
                    name={t('businessModel.applyDefaultFor', { name })}
                    onChange={(value) => onApplyDefault(change.field, value)}
                  >
                    {t('businessModel.applyDefault')}
                  </ModelCheck>
                </li>
              )
            })}
          </ul>
        ) : (
          <p>{t('businessModel.diffDefaultsSame')}</p>
        )}
      </section>
      <section aria-labelledby="profile-diff-units" className="space-y-3">
        <h4 id="profile-diff-units" className="font-semibold">
          {t('businessModel.diffUnits')}
        </h4>
        {preview.sampleUnits.length ? (
          <ul className="flex flex-wrap gap-2" aria-labelledby="profile-diff-units">
            {preview.sampleUnits.map((code) => (
              <li key={code} className="rounded-md border px-2 py-1">
                {unitLabel(t, code)}
              </li>
            ))}
          </ul>
        ) : (
          <p>{t('businessModel.diffUnitsNone')}</p>
        )}
      </section>
      {features.length ? (
        <p className="text-sm text-muted-foreground">
          {t('businessModel.recommended', {
            list: features.map((feature) => t(`featureName_${feature}`)).join(', '),
          })}
        </p>
      ) : null}
    </section>
  )
}
