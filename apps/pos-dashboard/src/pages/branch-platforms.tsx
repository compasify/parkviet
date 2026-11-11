import {
  type Platform,
  type PlatformSetting,
  platformKey,
} from '@parkviet/pos-shared/platform-orders'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { usePermissions } from '@spree/dashboard-core'
import { Button, Input, Label } from '@spree/dashboard-ui'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ModelCard, ModelCheck, ModelNotice, ModelState } from '../components/setup/model-ui'
import { usePlatformSettings, usePlatformSettingWrite } from '../hooks/use-platform-orders'
import { usePosSession } from '../hooks/use-pos-session'
import { canManageBranch } from '../lib/pos-access'

const REFUSALS = ['platform_invalid', 'platform_rate_invalid', 'module_disabled'] as const
type Notice = { text: string; failed: boolean } | null
type T = (key: string, options?: Record<string, unknown>) => string

export function platformSettingFailure(error: unknown, t: T) {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`branchPlatforms.failure_${reason}`)
    : describeFailure(error, t)
}

// "Nền tảng giao hàng": which delivery platforms the counter of the branch
// takes orders from, and the percent of each order the platform keeps. A new
// rate applies to orders entered afterwards.
export function BranchPlatformsTab() {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const write = canManageBranch({ permissionKeys, context: context.data }, branch.id)
  const settings = usePlatformSettings(branch.id)
  return (
    <ModelCard title={t('branchPlatforms.title')} id="branch-platforms">
      <p className="text-sm text-muted-foreground">{t('branchPlatforms.intro')}</p>
      {settings.isError ? (
        <ModelState
          title={describeFailure(settings.error, t)}
          error
          retry={() => void settings.refetch()}
        />
      ) : !settings.data ? (
        <ModelState title={t('waiting')} />
      ) : (
        <>
          {settings.data.module_enabled ? null : (
            <p role="status" className="rounded-lg border p-3 text-sm">
              {t('branchPlatforms.moduleOff')}
            </p>
          )}
          {settings.data.platforms.map((row) => (
            <PlatformRow
              key={`${row.platform}:${row.updated_at ?? ''}`}
              setting={row}
              write={write}
              moduleEnabled={settings.data.module_enabled}
            />
          ))}
        </>
      )}
    </ModelCard>
  )
}

function PlatformRow({
  setting,
  write,
  moduleEnabled,
}: {
  setting: PlatformSetting
  write: boolean
  moduleEnabled: boolean
}) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const mutation = usePlatformSettingWrite(branch.id)
  const [active, setActive] = useState(setting.status === 'active')
  const [rate, setRate] = useState(String(Number(setting.commission_rate)))
  const [notice, setNotice] = useState<Notice>(null)
  const platform: Platform = setting.platform
  const id = `platform-rate-${platform}`
  const rateValid = /^\d{1,3}(\.\d{1,2})?$/.test(rate.trim()) && Number(rate) <= 100

  async function save(event: FormEvent) {
    event.preventDefault()
    if (!rateValid || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        platform,
        status: active ? 'active' : 'disabled',
        commission_rate: rate.trim(),
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: platformSettingFailure(failure, t), failed: true })
    }
  }

  return (
    <form
      className="space-y-3 rounded-lg border p-4"
      onSubmit={save}
      data-testid={`platform-${platform}`}
    >
      <h3 className="font-medium">{t(platformKey(platform))}</h3>
      <ModelNotice notice={notice} />
      <ModelCheck
        checked={active}
        disabled={!write || (!active && !moduleEnabled)}
        onChange={setActive}
        description={t('branchPlatforms.activeHint')}
      >
        {t('branchPlatforms.active')}
      </ModelCheck>
      <div className="max-w-xs space-y-2">
        <Label htmlFor={id}>{t('branchPlatforms.rate')}</Label>
        <Input
          id={id}
          inputMode="decimal"
          value={rate}
          disabled={!write}
          aria-invalid={!rateValid}
          onChange={(event) => setRate(event.target.value)}
        />
        <p className="text-sm text-muted-foreground">{t('branchPlatforms.rateHint')}</p>
      </div>
      {write ? (
        <Button type="submit" disabled={!rateValid || mutation.isPending}>
          {t('branchPlatforms.save')}
        </Button>
      ) : null}
    </form>
  )
}
