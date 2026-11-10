import {
  type BusinessModule,
  type BusinessProfile,
  modulesEnabledWith,
  modulesRequiring,
  moduleTextKey,
  type PosModules,
  profileDescriptionKey,
  profileLabelKey,
} from '@parkviet/pos-shared/pos-modules'
import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { useStore } from '@spree/dashboard-core'
import { Button, Input, Label } from '@spree/dashboard-ui'
import { useMutation } from '@tanstack/react-query'
import { useParams } from '@tanstack/react-router'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { ProfileDiff } from '../components/profile-diff'
import {
  ModelCard,
  ModelCheck,
  ModelNotice,
  ModelPage,
  ModelSelect,
  ModelState,
  ModelStatus,
  modelDate,
} from '../components/setup/model-ui'
import { ModuleDescription } from '../components/setup-preview-step'
import {
  applyBranchProfile,
  type ProfilePreview,
  previewBranchProfile,
  setBranchModule,
  useBranchModuleDetail,
} from '../hooks/use-branch-modules'
import { useBranchSelection } from '../hooks/use-branch-selection'
import { useBusinessProfiles } from '../hooks/use-business-profiles'
import {
  refreshBusinessModel,
  type StoreProfile,
  saveStoreProfile,
  useStoreProfile,
} from '../hooks/use-onboarding'
import { usePosContext } from '../hooks/use-pos-context'

type Translate = (key: string, options?: Record<string, unknown>) => string
function moduleName(t: Translate, key: string) {
  const text = moduleTextKey(key)
  return text ? t(`posModules.${text}.label`) : key
}
function modelFailure(error: unknown, t: Translate) {
  const reason = conflictReason(error)
  if (reason === 'module_required_by') {
    const details = (error as { details?: { required_by?: unknown } }).details
    const names = Array.isArray(details?.required_by)
      ? details.required_by
          .filter((key): key is string => typeof key === 'string')
          .map((key) => moduleName(t, key))
      : []
    return t('businessModel.requiredBy', { list: names.join(', ') })
  }
  if (
    [
      'profile_conflict',
      'profile_unavailable',
      'module_unavailable',
      'reason_required',
      'onboarding_required',
    ].includes(reason ?? '')
  )
    return t(`businessModel.failure_${reason}`)
  return describeFailure(error, t)
}

export function BusinessModelPage() {
  const { t } = useTranslation()
  const storeContext = usePosContext()
  const { selection } = useBranchSelection(storeContext.data?.branches)
  const context = usePosContext(selection)
  const { branchId } = useParams({ strict: false })
  const branch = context.data?.branches.find((row) => row.id === (branchId ?? selection.branchId))
  const access = context.data?.administration
  const manager = Boolean(
    branch &&
      branch.id === selection.branchId &&
      context.data?.capabilities.includes('pos.topology.manage'),
  )
  return (
    <ModelPage
      title={branch ? `${t('businessModel.title')} · ${branch.name}` : t('businessModel.title')}
      description={t('businessModel.intro')}
      actions={<BranchPicker />}
      section="business-model"
    >
      {context.isPending ? (
        <ModelState title={t('contextWaiting')} />
      ) : context.isError ? (
        <ModelState
          error
          title={t(posFailureKey(context.error))}
          retry={() => void context.refetch()}
        />
      ) : !access?.read && !manager ? (
        <ModelState error title={t('adminAccessDenied')} />
      ) : !branch ? (
        <ModelState title={t('branchesEmpty')} />
      ) : (
        <BusinessModel
          key={branch.id}
          branch={{ ...branch, profile_key: branch.profile_key ?? context.data?.profile?.key }}
          storeId={context.data?.store.id ?? null}
          storeWrite={access?.write === true}
          branchWrite={access?.write === true || manager}
        />
      )}
    </ModelPage>
  )
}

function BusinessModel({
  branch,
  storeId,
  storeWrite,
  branchWrite,
}: {
  branch: PosBranch
  storeId: string | null
  storeWrite: boolean
  branchWrite: boolean
}) {
  const { t } = useTranslation()
  const catalogue = useBusinessProfiles(storeId)
  const detail = useBranchModuleDetail(branch.id)
  const profiles = catalogue.data?.profiles ?? []
  return (
    <>
      <ModelCard title={t('businessModel.currentTitle')} id="business-model-current">
        {catalogue.isPending ? (
          <ModelState title={t('waiting')} />
        ) : catalogue.isError ? (
          <ModelState
            error
            title={t(posFailureKey(catalogue.error))}
            retry={() => void catalogue.refetch()}
          />
        ) : null}
        {branch.profile_key ? (
          <div data-profile={branch.profile_key}>
            <strong>
              {t(profileLabelKey(branch.profile_key), { defaultValue: branch.profile_key })}
            </strong>
            <p className="text-sm text-muted-foreground">
              {t(profileDescriptionKey(branch.profile_key), { defaultValue: '' })}
            </p>
          </div>
        ) : (
          <p>{t('businessModel.profileUnknown')}</p>
        )}
        {storeWrite && catalogue.data ? (
          <ChangeProfile branch={branch} profiles={profiles} />
        ) : null}
      </ModelCard>
      <ModuleSwitches
        branch={branch}
        catalogue={catalogue.data?.modules ?? []}
        detail={detail}
        write={branchWrite}
      />
      {storeWrite && catalogue.data ? (
        <StoreProfileSection storeId={storeId} profiles={profiles} />
      ) : null}
    </>
  )
}

function ChangeProfile({ branch, profiles }: { branch: PosBranch; profiles: BusinessProfile[] }) {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const mutation = useMutation({
    mutationFn: (input: Parameters<typeof applyBranchProfile>[1]) =>
      applyBranchProfile(branch.id, input),
  })
  const choices = profiles.filter(
    (profile) => profile.status === 'available' && profile.key !== branch.profile_key,
  )
  const [target, setTarget] = useState('')
  const [preview, setPreview] = useState<ProfilePreview | null>(null)
  const [applyModules, setApplyModules] = useState(true)
  const [applyDefaults, setApplyDefaults] = useState<string[]>([])
  const [reason, setReason] = useState('')
  const [busy, setBusy] = useState(false)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  async function loadPreview(key: string) {
    setBusy(true)
    try {
      setPreview(await previewBranchProfile(branch.id, key))
      setApplyModules(true)
      setApplyDefaults([])
    } catch (error) {
      setPreview(null)
      setNotice({ text: modelFailure(error, t), failed: true })
    } finally {
      setBusy(false)
    }
  }
  async function apply(event: FormEvent) {
    event.preventDefault()
    const note = reason.trim()
    if (!preview || !note || busy) return
    setBusy(true)
    setNotice(null)
    try {
      await mutation.mutateAsync({
        profile_key: preview.to,
        expected_profile_key: preview.from,
        apply_modules: applyModules,
        apply_defaults: applyDefaults,
        reason: note,
      })
      setPreview(null)
      setTarget('')
      setReason('')
      setNotice({
        text: t('businessModel.profileSaved', { name: t(profileLabelKey(preview.to)) }),
        failed: false,
      })
      await refreshBusinessModel(storeId)
    } catch (error) {
      if (conflictReason(error) === 'profile_conflict') {
        setNotice({ text: t('businessModel.failure_profile_conflict'), failed: true })
        // Never leave the stale diff executable if refresh/re-preview fails.
        const next = preview.to
        setPreview(null)
        await refreshBusinessModel(storeId)
        await loadPreview(next)
      } else setNotice({ text: modelFailure(error, t), failed: true })
    } finally {
      setBusy(false)
    }
  }
  return (
    <div className="space-y-4 border-t pt-4">
      <h3 id="business-model-change" className="text-base font-semibold">
        {t('businessModel.changeTitle')}
      </h3>
      <p className="text-sm text-muted-foreground">{t('businessModel.changeIntro')}</p>
      <ModelNotice notice={notice} />
      <form
        className="space-y-3"
        aria-labelledby="business-model-change"
        onSubmit={(event) => {
          event.preventDefault()
          if (target && !busy) void loadPreview(target)
        }}
      >
        <ModelSelect
          label={t('businessModel.newProfile')}
          value={target}
          disabled={busy}
          options={[
            { value: '', label: t('businessModel.chooseProfile') },
            ...choices.map((profile) => ({
              value: profile.key,
              label: t(profileLabelKey(profile.key), { defaultValue: profile.key }),
            })),
          ]}
          onChange={(value) => {
            setTarget(value)
            setPreview(null)
            setNotice(null)
          }}
        />
        <Button type="submit" variant="outline" disabled={busy || !target}>
          {t('businessModel.previewButton')}
        </Button>
      </form>
      {preview ? (
        <form
          className="space-y-4"
          aria-label={t('businessModel.applyFormLabel', { name: t(profileLabelKey(preview.to)) })}
          onSubmit={(event) => void apply(event)}
        >
          <p>
            {t('businessModel.diffIntro', {
              from: t(profileLabelKey(preview.from), { defaultValue: preview.from || '—' }),
              to: t(profileLabelKey(preview.to)),
            })}
          </p>
          <ProfileDiff
            branchId={branch.id}
            preview={preview}
            applyModules={applyModules}
            applyDefaults={applyDefaults}
            disabled={busy}
            onApplyModules={setApplyModules}
            onApplyDefault={(field, value) =>
              setApplyDefaults((fields) =>
                value
                  ? [...fields.filter((item) => item !== field), field]
                  : fields.filter((item) => item !== field),
              )
            }
          />
          <Label htmlFor="business-model-reason">{t('featureReason')}</Label>
          <Input
            id="business-model-reason"
            value={reason}
            maxLength={200}
            required
            autoComplete="off"
            disabled={busy}
            onChange={(event) => setReason(event.target.value)}
          />
          <div className="flex flex-wrap gap-2">
            <Button type="submit" disabled={busy || !reason.trim()}>
              {busy
                ? t('waiting')
                : t('businessModel.applyButton', { name: t(profileLabelKey(preview.to)) })}
            </Button>
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => {
                setPreview(null)
                setNotice(null)
              }}
            >
              {t('adminCancel')}
            </Button>
          </div>
        </form>
      ) : null}
    </div>
  )
}

type ModuleChange = { key: string; enabled: boolean; alsoEnabled: string[] }
function ModuleSwitches({
  branch,
  catalogue,
  detail,
  write,
}: {
  branch: PosBranch
  catalogue: BusinessModule[]
  detail: ReturnType<typeof useBranchModuleDetail>
  write: boolean
}) {
  const { t, i18n } = useTranslation()
  const { storeId } = useStore()
  const mutation = useMutation({
    mutationFn: (input: { key: string; enabled: boolean; reason: string }) =>
      setBranchModule(branch.id, input.key, input.enabled, input.reason),
  })
  const [change, setChange] = useState<ModuleChange | null>(null)
  const [reason, setReason] = useState('')
  const [busy, setBusy] = useState(false)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const modules: PosModules = detail.data?.modules ?? {}
  // Unknown server modules remain visible. Catalogue availability does not erase them.
  const keys = [
    ...catalogue.filter((item) => item.status === 'available').map((item) => item.key),
    ...Object.keys(modules).filter((key) => !catalogue.some((item) => item.key === key)),
  ]
  async function save(event: FormEvent) {
    event.preventDefault()
    const note = reason.trim()
    if (!change || !note || busy || !write) return
    setBusy(true)
    setNotice(null)
    const name = moduleName(t, change.key)
    try {
      const result = await mutation.mutateAsync({
        key: change.key,
        enabled: change.enabled,
        reason: note,
      })
      setNotice({
        text: change.enabled
          ? result.alsoEnabled.length
            ? t('businessModel.moduleOnWith', {
                name,
                list: result.alsoEnabled.map((key) => moduleName(t, key)).join(', '),
              })
            : t('businessModel.moduleOnSaved', { name })
          : t('businessModel.moduleOffSaved', { name }),
        failed: false,
      })
      setChange(null)
      setReason('')
    } catch (error) {
      setNotice({ text: modelFailure(error, t), failed: true })
    } finally {
      try {
        await refreshBusinessModel(storeId)
      } finally {
        setBusy(false)
      }
    }
  }
  return (
    <ModelCard title={t('businessModel.modulesTitle')} id="business-model-modules">
      <p className="text-sm text-muted-foreground">{t('businessModel.modulesIntro')}</p>
      {!write ? <p>{t('featureReadOnly')}</p> : null}
      <ModelNotice notice={notice} />
      {detail.isPending ? (
        <ModelState title={t('waiting')} />
      ) : detail.isError ? (
        <ModelState
          error
          title={t(posFailureKey(detail.error))}
          retry={() => void detail.refetch()}
        />
      ) : null}
      {detail.data && !detail.isError ? (
        <ul className="divide-y" aria-label={t('businessModel.modulesList')}>
          {keys.map((key) => {
            const on = modules[key] === true
            const name = moduleName(t, key)
            const latest = detail.data.settings.find((row) => row.module === key)
            const requiredBy = on ? modulesRequiring(key, catalogue, modules) : []
            const enabledWith = on ? [] : modulesEnabledWith(key, catalogue, modules)
            const editing = change?.key === key
            const reasonId = `module-reason-${key.replaceAll('.', '-')}`
            const blockedId = `module-blocked-${key.replaceAll('.', '-')}`
            return (
              <li key={key} data-module={key} className="flex flex-wrap items-start gap-4 py-5">
                <div className="min-w-0 flex-1">
                  <h3 className="text-base font-medium">{name}</h3>
                  <p className="text-sm text-muted-foreground">
                    <ModuleDescription moduleKey={key} />
                  </p>
                  {latest?.changed_at ? (
                    <p className="text-sm text-muted-foreground">
                      {t('featureLastChange', {
                        name: latest.changed_by_name ?? '—',
                        at: modelDate(latest.changed_at, i18n.language, branch.timezone),
                        reason: latest.reason,
                      })}
                    </p>
                  ) : null}
                  {requiredBy.length ? (
                    <p id={blockedId} className="text-sm text-muted-foreground">
                      {t('businessModel.requiredBy', {
                        list: requiredBy.map((item) => moduleName(t, item)).join(', '),
                      })}
                    </p>
                  ) : null}
                </div>
                <ModelStatus on={on}>{t(on ? 'featureStatusOn' : 'featureStatusOff')}</ModelStatus>
                {write && !editing ? (
                  <Button
                    type="button"
                    variant={on ? 'destructive' : 'outline'}
                    disabled={busy || requiredBy.length > 0}
                    aria-describedby={requiredBy.length ? blockedId : undefined}
                    onClick={() => {
                      setNotice(null)
                      setReason('')
                      setChange({ key, enabled: !on, alsoEnabled: enabledWith })
                    }}
                  >
                    {t(on ? 'businessModel.moduleTurnOff' : 'businessModel.moduleTurnOn', { name })}
                  </Button>
                ) : null}
                {write && editing && change ? (
                  <form
                    className="flex w-full flex-col gap-3 rounded-md bg-muted p-4"
                    aria-label={t('featureChangeFor', { name })}
                    onSubmit={(event) => void save(event)}
                  >
                    <p id={`${reasonId}-hint`}>
                      {change.enabled
                        ? change.alsoEnabled.length
                          ? t('businessModel.moduleConfirmOnWith', {
                              name,
                              list: change.alsoEnabled
                                .map((item) => moduleName(t, item))
                                .join(', '),
                            })
                          : t('businessModel.moduleConfirmOn', { name })
                        : t('businessModel.moduleConfirmOff', { name })}
                    </p>
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
                      onChange={(event) => setReason(event.target.value)}
                    />
                    <div className="flex gap-2">
                      <Button
                        type="submit"
                        variant={change.enabled ? 'default' : 'destructive'}
                        disabled={busy || !reason.trim()}
                      >
                        {busy ? t('waiting') : t('featureSave')}
                      </Button>
                      <Button
                        type="button"
                        variant="outline"
                        disabled={busy}
                        onClick={() => setChange(null)}
                      >
                        {t('adminCancel')}
                      </Button>
                    </div>
                  </form>
                ) : null}
              </li>
            )
          })}
        </ul>
      ) : null}
    </ModelCard>
  )
}

function StoreProfileSection({
  storeId,
  profiles,
}: {
  storeId: string | null
  profiles: BusinessProfile[]
}) {
  const { t } = useTranslation()
  const query = useStoreProfile(storeId, true)
  if (query.isPending) return <ModelState title={t('waiting')} />
  if (query.isError)
    return (
      <ModelState error title={t(posFailureKey(query.error))} retry={() => void query.refetch()} />
    )
  return <StoreProfileForm stored={query.data ?? null} profiles={profiles} />
}
function StoreProfileForm({
  stored,
  profiles,
}: {
  stored: StoreProfile | null
  profiles: BusinessProfile[]
}) {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const mutation = useMutation({ mutationFn: saveStoreProfile })
  const [profileKey, setProfileKey] = useState(stored?.profile_key ?? 'khac')
  const [wholesale, setWholesale] = useState(stored?.wholesale ?? false)
  const [interests, setInterests] = useState<string[]>(stored?.interests ?? [])
  const [reason, setReason] = useState('')
  const [busy, setBusy] = useState(false)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const changed =
    !stored ||
    profileKey !== stored.profile_key ||
    wholesale !== stored.wholesale ||
    [...interests].sort().join() !== [...stored.interests].sort().join()
  async function save(event: FormEvent) {
    event.preventDefault()
    const note = reason.trim()
    if (!note || busy || !changed) return
    setBusy(true)
    setNotice(null)
    try {
      await mutation.mutateAsync({ profile_key: profileKey, wholesale, interests, reason: note })
      setReason('')
      setNotice({ text: t('businessModel.storeSaved'), failed: false })
      await refreshBusinessModel(storeId)
    } catch (error) {
      setNotice({ text: modelFailure(error, t), failed: true })
    } finally {
      setBusy(false)
    }
  }
  return (
    <ModelCard title={t('businessModel.storeTitle')} id="business-model-store">
      <p className="text-sm text-muted-foreground">{t('businessModel.storeIntro')}</p>
      <ModelNotice notice={notice} />
      <form className="space-y-5" onSubmit={(event) => void save(event)}>
        <ModelSelect
          label={t('businessModel.storeProfile')}
          value={profileKey}
          disabled={busy}
          onChange={setProfileKey}
          options={profiles
            .filter((profile) => profile.status === 'available')
            .map((profile) => ({
              value: profile.key,
              label: t(profileLabelKey(profile.key), { defaultValue: profile.key }),
            }))}
        />
        <ModelCheck
          checked={wholesale}
          disabled={busy}
          onChange={setWholesale}
          description={t('setup.wholesaleNote')}
        >
          {t('businessModel.storeWholesale')}
        </ModelCheck>
        {profiles.some((profile) => profile.status === 'coming_soon') ? (
          <fieldset className="space-y-3 rounded-md border p-4">
            <legend>{t('businessModel.storeInterests')}</legend>
            {profiles
              .filter((profile) => profile.status === 'coming_soon')
              .map((profile) => (
                <ModelCheck
                  key={profile.key}
                  checked={interests.includes(profile.key)}
                  disabled={busy}
                  onChange={(value) =>
                    setInterests((keys) =>
                      value
                        ? [...keys.filter((key) => key !== profile.key), profile.key]
                        : keys.filter((key) => key !== profile.key),
                    )
                  }
                >
                  {t(profileLabelKey(profile.key), { defaultValue: profile.key })}
                </ModelCheck>
              ))}
          </fieldset>
        ) : null}
        <div className="space-y-2">
          <Label htmlFor="store-profile-reason">{t('featureReason')}</Label>
          <Input
            id="store-profile-reason"
            value={reason}
            maxLength={200}
            required
            autoComplete="off"
            disabled={busy}
            onChange={(event) => setReason(event.target.value)}
          />
        </div>
        <Button type="submit" disabled={busy || !changed || !reason.trim()}>
          {busy ? t('waiting') : t('businessModel.storeSave')}
        </Button>
      </form>
    </ModelCard>
  )
}
