import {
  type BranchFeatures,
  branchOverride,
  offReason,
  type PosFeature,
} from '@parkviet/pos-shared/pos-features'
import { Button, Input, Label } from '@spree/dashboard-ui'
import { useTranslation } from 'react-i18next'
import { modelDate as formatInZone, ModelStatus } from './setup/model-ui'

export type FeatureChange = {
  feature: PosFeature
  scope: 'store' | 'branch'
  enabled: boolean | null
}
export function featureChangeText(change: FeatureChange, kind: 'confirm' | 'saved') {
  const action =
    change.scope === 'store'
      ? change.enabled
        ? 'StoreOn'
        : 'StoreOff'
      : change.enabled === null
        ? 'BranchRestore'
        : 'BranchOff'
  return `feature${kind === 'confirm' ? 'Confirm' : 'Saved'}${action}`
}

export function FeatureSwitchRow({
  feature,
  flags,
  timeZone,
  storeWrite,
  branchWrite,
  busy,
  change,
  reason,
  onStart,
  onReason,
  onCancel,
  onSave,
}: {
  feature: PosFeature
  flags: BranchFeatures
  timeZone: string
  storeWrite: boolean
  branchWrite: boolean
  busy: boolean
  change: FeatureChange | null
  reason: string
  onStart: (change: FeatureChange) => void
  onReason: (value: string) => void
  onCancel: () => void
  onSave: () => void
}) {
  const { t, i18n } = useTranslation()
  const on = flags.features[feature] === true
  const storeOn = flags.store_defaults[feature] === true
  const branchOff = branchOverride(flags, feature) === false
  const why = offReason(flags, feature)
  const name = t(`featureName_${feature}`)
  const latest = [...flags.settings]
    .filter((row) => row.feature === feature)
    .sort((a, b) => (b.changed_at ?? '').localeCompare(a.changed_at ?? ''))[0]
  const reasonId = `feature-reason-${feature}`
  return (
    <li data-feature={feature} className="flex flex-wrap items-start gap-4 py-5">
      <div className="min-w-0 flex-1 space-y-1">
        <h3 className="font-medium">{name}</h3>
        <p className="text-sm text-muted-foreground">{t(`featureHint_${feature}`)}</p>
        <p className="text-sm text-muted-foreground">
          {t('featureStoreState', { state: t(storeOn ? 'featureStatusOn' : 'featureStatusOff') })}
          {' · '}
          {t(branchOff ? 'featureBranchOffState' : 'featureBranchFollows')}
        </p>
        {latest ? (
          <p className="text-sm text-muted-foreground">
            {t('featureLastChange', {
              name: latest.changed_by_name ?? '—',
              at: formatInZone(latest.changed_at, i18n.language, timeZone),
              reason: latest.reason,
            })}
          </p>
        ) : null}
      </div>
      <ModelStatus on={on}>
        {on
          ? t('featureStatusOn')
          : t(why === 'branch' ? 'featureOffByBranch' : 'featureOffByStore')}
      </ModelStatus>
      {!change && (storeWrite || branchWrite) ? (
        <div className="flex w-full flex-wrap gap-2">
          {storeWrite ? (
            <Button
              type="button"
              variant={storeOn ? 'destructive' : 'outline'}
              disabled={busy}
              onClick={() => onStart({ feature, scope: 'store', enabled: !storeOn })}
            >
              {t(storeOn ? 'featureStoreTurnOff' : 'featureStoreTurnOn', { name })}
            </Button>
          ) : null}
          {branchWrite && (!branchOff || storeWrite) ? (
            <Button
              type="button"
              variant={branchOff ? 'outline' : 'destructive'}
              disabled={busy}
              onClick={() =>
                onStart({ feature, scope: 'branch', enabled: branchOff ? null : false })
              }
            >
              {t(branchOff ? 'featureBranchRestore' : 'featureBranchTurnOff', { name })}
            </Button>
          ) : null}
        </div>
      ) : null}
      {change ? (
        <form
          className="flex w-full flex-col gap-3 rounded-md bg-muted p-4"
          aria-label={t('featureChangeFor', { name })}
          onSubmit={(event) => {
            event.preventDefault()
            onSave()
          }}
        >
          <p id={`${reasonId}-hint`}>{t(featureChangeText(change, 'confirm'), { name })}</p>
          <Label htmlFor={reasonId}>{t('featureReason')}</Label>
          <Input
            id={reasonId}
            value={reason}
            maxLength={200}
            required
            autoComplete="off"
            aria-describedby={`${reasonId}-hint`}
            disabled={busy}
            autoFocus
            onChange={(event) => onReason(event.target.value)}
          />
          <div className="flex flex-wrap gap-2">
            <Button
              type="submit"
              variant={change.enabled === false ? 'destructive' : 'default'}
              disabled={busy || !reason.trim()}
            >
              {busy ? t('waiting') : t('featureSave')}
            </Button>
            <Button type="button" variant="outline" disabled={busy} onClick={onCancel}>
              {t('adminCancel')}
            </Button>
          </div>
        </form>
      ) : null}
    </li>
  )
}
