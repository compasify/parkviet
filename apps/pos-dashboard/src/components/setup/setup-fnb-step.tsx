import type { BusinessProfile, BusinessTaxCategory } from '@parkviet/pos-shared/pos-modules'
import {
  hasKitchen,
  MAX_STATIONS,
  type SetupAction,
  type SetupProblem,
  type ShopSetup,
  type ShopStationKind,
  STATION_NAME_MAX,
} from '@parkviet/pos-shared/setup-wizard'
import { Button, Input, Label } from '@spree/dashboard-ui'
import type { Dispatch } from 'react'
import { useTranslation } from 'react-i18next'
import { ModelSelect } from './model-ui'

type T = (key: string, options?: Record<string, unknown>) => string

// "0.08" → "8%".
export function taxRateLabel(rate: string) {
  const value = Number(rate)
  return Number.isFinite(value) ? `${Math.round(value * 10000) / 100}%` : rate
}

export function taxLabel(t: T, taxes: BusinessTaxCategory[], code: string) {
  const row = taxes.find((item) => item.code === code)
  return t(`setup.tax_${code}`, {
    defaultValue: code,
    rate: row ? taxRateLabel(row.rate) : '',
  })
}

export const stationName = (t: T) => (kind: ShopStationKind) => t(`setup.shopStation_${kind}`)

// The F&B "set up the shop" step: kitchen stations (named, removable, up to
// four), the tax rates new menu items start with, and when orders reach the
// kitchen. The menu itself is entered later under Menu.
export function SetupFnbStep({
  profile,
  shop,
  taxes,
  dispatch,
  problems,
}: {
  profile: BusinessProfile
  shop: ShopSetup
  taxes: BusinessTaxCategory[]
  dispatch: Dispatch<SetupAction>
  problems: SetupProblem[]
}) {
  const { t } = useTranslation()
  const kitchen = hasKitchen(profile)
  const taxOptions = taxes.map((row) => ({ value: row.code, label: taxLabel(t, taxes, row.code) }))
  return (
    <div className="flex flex-col gap-6" data-testid="setup-shop">
      <p className="text-sm text-muted-foreground">{t('setup.shopIntro')}</p>
      {kitchen ? (
        <section aria-labelledby="setup-stations-heading" className="space-y-3">
          <h3 id="setup-stations-heading" className="font-semibold">
            {t('setup.shopStationsTitle')}
          </h3>
          <p className="text-sm text-muted-foreground">{t('setup.shopStationsHint')}</p>
          {shop.stations.length === 0 ? <p>{t('setup.shopNoStations')}</p> : null}
          <ul className="space-y-3">
            {shop.stations.map((station, index) => (
              // Stations have no id until created; the position is their identity here.
              // biome-ignore lint/suspicious/noArrayIndexKey: rows are only added or removed by index
              <li key={index} className="flex flex-wrap items-end gap-3">
                <div className="min-w-48 flex-1 space-y-2">
                  <Label htmlFor={`setup-station-${index}`}>
                    {t('setup.shopStationName', { number: index + 1 })}
                  </Label>
                  <Input
                    id={`setup-station-${index}`}
                    value={station.name}
                    maxLength={STATION_NAME_MAX}
                    aria-invalid={
                      problems.includes('station-name') || problems.includes('station-duplicate')
                    }
                    onChange={(event) =>
                      dispatch({ type: 'station-name', index, value: event.target.value })
                    }
                  />
                </div>
                <div className="w-40">
                  <ModelSelect
                    label={t('setup.shopStationKind')}
                    value={station.kind}
                    options={(['prep', 'bar'] as const).map((kind) => ({
                      value: kind,
                      label: t(`setup.shopKind_${kind}`),
                    }))}
                    onChange={(value) =>
                      dispatch({
                        type: 'station-kind',
                        index,
                        value: value === 'bar' ? 'bar' : 'prep',
                      })
                    }
                  />
                </div>
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => dispatch({ type: 'station-remove', index })}
                >
                  {t('setup.shopStationRemove')}
                </Button>
              </li>
            ))}
          </ul>
          {shop.stations.length < MAX_STATIONS ? (
            <Button
              type="button"
              variant="outline"
              onClick={() =>
                dispatch({
                  type: 'station-add',
                  name: t('setup.shopStationNew', { number: shop.stations.length + 1 }),
                })
              }
            >
              {t('setup.shopStationAdd')}
            </Button>
          ) : null}
        </section>
      ) : null}
      <section aria-labelledby="setup-tax-heading" className="space-y-3">
        <h3 id="setup-tax-heading" className="font-semibold">
          {t('setup.shopTaxTitle')}
        </h3>
        <div className="grid gap-4 sm:grid-cols-2">
          <ModelSelect
            id="setup-tax-food"
            label={t('setup.shopTaxFood')}
            value={shop.foodTax}
            invalid={problems.includes('tax')}
            options={taxOptions}
            onChange={(value) => dispatch({ type: 'shop-tax', role: 'food', value })}
          />
          <ModelSelect
            id="setup-tax-alcohol"
            label={t('setup.shopTaxAlcohol')}
            value={shop.alcoholTax}
            invalid={problems.includes('tax')}
            options={taxOptions}
            onChange={(value) => dispatch({ type: 'shop-tax', role: 'alcohol', value })}
          />
        </div>
        <p className="text-sm text-muted-foreground">{t('setup.shopTaxHint')}</p>
      </section>
      {kitchen ? (
        <ModelSelect
          id="setup-trigger"
          label={t('setup.shopTrigger')}
          value={shop.trigger}
          hint={t(`setup.shopTriggerHint_${shop.trigger}`)}
          options={(['on_complete', 'manual'] as const).map((value) => ({
            value,
            label: t(`setup.shopTrigger_${value}`),
          }))}
          onChange={(value) =>
            dispatch({ type: 'shop-trigger', value: value === 'manual' ? 'manual' : 'on_complete' })
          }
        />
      ) : null}
      <p className="text-sm text-muted-foreground">{t('setup.shopMenuLater')}</p>
    </div>
  )
}
