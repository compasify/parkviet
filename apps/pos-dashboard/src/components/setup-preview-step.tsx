import {
  type BusinessModule,
  type BusinessProfile,
  modulesRequiring,
  moduleTextKey,
} from '@parkviet/pos-shared/pos-modules'
import {
  editableDefaults,
  recommendedFeatures,
  type SetupAction,
  type SetupProblem,
  type SetupState,
} from '@parkviet/pos-shared/setup-wizard'
import { Input, Label } from '@spree/dashboard-ui'
import type { Dispatch } from 'react'
import { useTranslation } from 'react-i18next'
import { ModelCheck, ModelSelect } from './setup/model-ui'

export function ModuleName({ moduleKey }: { moduleKey: string }) {
  const { t } = useTranslation()
  const text = moduleTextKey(moduleKey)
  return text ? t(`posModules.${text}.label`) : moduleKey
}
export function ModuleDescription({ moduleKey }: { moduleKey: string }) {
  const { t } = useTranslation()
  const text = moduleTextKey(moduleKey)
  return text ? t(`posModules.${text}.description`) : null
}
export function unitLabel(
  t: (key: string, options?: Record<string, unknown>) => string,
  code: string,
) {
  return t(`setup.unit.${code}`, { defaultValue: code })
}

export function SetupPreviewStep({
  profile,
  catalogue,
  state,
  dispatch,
  problems,
}: {
  profile: BusinessProfile
  catalogue: BusinessModule[]
  state: SetupState
  dispatch: Dispatch<SetupAction>
  problems: SetupProblem[]
}) {
  const { t } = useTranslation()
  const enabled = profile.modules.filter((key) => !state.disabledModules.includes(key))
  const active = { ...profile, modules: enabled }
  const enabledMap = Object.fromEntries(enabled.map((key) => [key, true]))
  const fields = editableDefaults(active)
  const features = recommendedFeatures(profile)
  const numberFields = [
    { field: 'return_window_days', label: 'adminReturnWindow', problem: 'return-window', max: 4 },
    { field: 'variance_threshold', label: 'adminVarianceThreshold', problem: 'variance', max: 20 },
    {
      field: 'adjustment_approval_threshold',
      label: 'adminAdjustmentThreshold',
      problem: 'adjustment',
      max: 9,
    },
  ] as const
  return (
    <div className="flex flex-col gap-6">
      <section aria-labelledby="setup-modules-heading">
        <h3 id="setup-modules-heading" className="font-semibold">
          {t('setup.modulesTitle')}
        </h3>
        <p className="mt-1 text-sm text-muted-foreground">{t('setup.modulesLater')}</p>
        {profile.modules.length ? (
          <ul className="mt-3 divide-y">
            {profile.modules.map((key) => {
              const on = !state.disabledModules.includes(key)
              const requiredBy = on ? modulesRequiring(key, catalogue, enabledMap) : []
              const text = moduleTextKey(key)
              return (
                <li key={key} data-module={key} className="py-3">
                  <ModelCheck
                    checked={on}
                    disabled={requiredBy.length > 0}
                    description={text ? t(`posModules.${text}.description`) : undefined}
                    onChange={(value) => dispatch({ type: 'module', key, value })}
                  >
                    <ModuleName moduleKey={key} />
                  </ModelCheck>
                  {requiredBy.length ? (
                    <p className="mt-1 text-sm text-muted-foreground">
                      {t('businessModel.requiredBy', {
                        list: requiredBy
                          .map((item) => {
                            const name = moduleTextKey(item)
                            return name ? t(`posModules.${name}.label`) : item
                          })
                          .join(', '),
                      })}
                    </p>
                  ) : null}
                </li>
              )
            })}
          </ul>
        ) : (
          <p className="mt-3">{t('setup.modulesNone')}</p>
        )}
      </section>
      <section aria-labelledby="setup-defaults-heading" className="space-y-4">
        <h3 id="setup-defaults-heading" className="font-semibold">
          {t('setup.defaultsTitle')}
        </h3>
        <div className="grid gap-4 sm:grid-cols-2">
          {numberFields
            .filter(({ field }) => fields.includes(field))
            .map(({ field, label, problem, max }) => (
              <div key={field} className="space-y-2">
                <Label htmlFor={`setup-${field}`}>{t(label)}</Label>
                <Input
                  id={`setup-${field}`}
                  inputMode="numeric"
                  maxLength={max}
                  value={state.defaults[field]}
                  aria-invalid={problems.includes(problem)}
                  aria-describedby={
                    field === 'return_window_days' ? 'setup-return-hint' : undefined
                  }
                  onChange={(event) =>
                    dispatch({ type: 'default', field, value: event.target.value })
                  }
                />
                {field === 'return_window_days' ? (
                  <p id="setup-return-hint" className="text-sm text-muted-foreground">
                    {t('adminReturnWindowHint')}
                  </p>
                ) : null}
              </div>
            ))}
          {fields.includes('lot_selection') ? (
            <ModelSelect
              label={t('adminLotSelection')}
              value={state.defaults.lot_selection}
              hint={t('adminLotSelectionHint')}
              options={['fefo', 'cashier_pick'].map((value) => ({
                value,
                label: t(`adminLotSelection_${value}`),
              }))}
              onChange={(value) => dispatch({ type: 'default', field: 'lot_selection', value })}
            />
          ) : null}
        </div>
        <p className="text-sm text-muted-foreground">
          {t(
            profile.display.surface === 'menu_grid' && active.modules.includes('fnb.menu')
              ? 'setup.viewMenuGrid'
              : profile.display.catalog_view === 'list'
                ? 'setup.viewList'
                : 'setup.viewCards',
          )}
        </p>
        {active.modules.includes('fnb.kitchen') ? (
          <p className="text-sm text-muted-foreground">
            {t('setup.previewKitchen', {
              trigger: t(
                `setup.shopTrigger_${profile.branch_defaults.kitchen_send_trigger === 'manual' ? 'manual' : 'on_complete'}`,
              ),
              stations: profile.kitchen_stations
                .map((kind) => t(`setup.shopStation_${kind}`))
                .join(', '),
            })}
          </p>
        ) : null}
      </section>
      <section aria-labelledby="setup-units-heading">
        <h3 id="setup-units-heading" className="font-semibold">
          {t('setup.unitsTitle')}
        </h3>
        {profile.sample_units.length ? (
          <>
            <ul className="my-3 flex flex-wrap gap-2" aria-labelledby="setup-units-heading">
              {profile.sample_units.map((code) => (
                <li key={code} className="rounded-md border px-2 py-1 text-sm">
                  {unitLabel(t, code)}
                </li>
              ))}
            </ul>
            <p className="text-sm text-muted-foreground">{t('setup.unitsHint')}</p>
          </>
        ) : (
          <p>{t('setup.unitsNone')}</p>
        )}
      </section>
      {features.length ? (
        <fieldset className="space-y-4 rounded-md border p-4">
          <legend className="font-semibold">{t('setup.featuresTitle')}</legend>
          <p className="text-sm text-muted-foreground">{t('setup.featuresHint')}</p>
          {features.map((feature) => (
            <div key={feature} data-feature={feature}>
              <ModelCheck
                checked={state.features.includes(feature)}
                onChange={(value) => dispatch({ type: 'feature', feature, value })}
                description={t(`featureHint_${feature}`)}
              >
                {t(`featureName_${feature}`)}
              </ModelCheck>
            </div>
          ))}
        </fieldset>
      ) : null}
    </div>
  )
}
