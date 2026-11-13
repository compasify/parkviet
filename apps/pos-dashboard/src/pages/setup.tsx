import { profileLabelKey, profileModules, tablesOptional } from '@parkviet/pos-shared/pos-modules'
import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import {
  hasShopStep,
  initialSetup,
  nextStep,
  onboardingPayload,
  onboardingSelection,
  previousStep,
  type SetupProblem,
  type SetupState,
  type SetupStep,
  SHOP_STEP,
  type ShopSetup,
  SUMMARY_STEP,
  setupReducer,
  setupSteps,
  shopDefaults,
  stepProblems,
  tablesOn,
} from '@parkviet/pos-shared/setup-wizard'
import { Button, Label, RadioGroup, RadioGroupItem, Wizard } from '@spree/dashboard-ui'
import { useMutation } from '@tanstack/react-query'
import { useNavigate, useParams } from '@tanstack/react-router'
import { useEffect, useReducer, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { ModelPage, ModelState } from '../components/setup/model-ui'
import { ProfilePicker } from '../components/setup/profile-picker'
import { SetupBranchStep } from '../components/setup/setup-branch-step'
import { SetupFnbStep, stationName, taxLabel } from '../components/setup/setup-fnb-step'
import { ModuleName, SetupPreviewStep, unitLabel } from '../components/setup-preview-step'
import { useBranchSelection } from '../hooks/use-branch-selection'
import { useBusinessProfiles } from '../hooks/use-business-profiles'
import { refreshBusinessModel, useOnboarding } from '../hooks/use-onboarding'
import { usePosContext } from '../hooks/use-pos-context'
import { useLocationOptions } from '../hooks/use-topology'

export function SetupPage() {
  const { t } = useTranslation()
  const context = usePosContext()
  const [done, setDone] = useState(false)
  const onboarding = context.data?.onboarding
  return (
    <ModelPage title={t('setup.title')} description={t('setup.intro')}>
      {done ? (
        <ModelState title={t('setup.doneOpening')} />
      ) : context.isPending ? (
        <ModelState title={t('contextWaiting')} />
      ) : context.isError ? (
        <ModelState
          error
          title={t(posFailureKey(context.error))}
          retry={() => void context.refetch()}
        />
      ) : !onboarding?.required ? (
        <ModelState title={t('setup.alreadyDone')} />
      ) : !onboarding.can_setup ? (
        <ModelState title={t('setup.askAdmin')} />
      ) : (
        <SetupWizard onDone={() => setDone(true)} />
      )}
    </ModelPage>
  )
}

function SetupWizard({ onDone }: { onDone: () => void }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const { storeId } = useParams({ strict: false })
  const context = usePosContext()
  const { setSelection } = useBranchSelection(context.data?.branches)
  const catalogue = useBusinessProfiles(context.data?.store.id ?? null)
  const locations = useLocationOptions(true)
  const onboarding = useOnboarding()
  const mutation = useMutation({ mutationFn: (run: () => Promise<unknown>) => run() })
  const [state, dispatch] = useReducer(setupReducer, context.data?.store.timezone, initialSetup)
  const [shownProblems, setShownProblems] = useState<SetupProblem[]>([])
  const [failure, setFailure] = useState('')
  const [open, setOpen] = useState(true)
  const sending = useRef(false)
  const heading = useRef<HTMLHeadingElement>(null)
  const profiles = catalogue.data?.profiles ?? []
  const profile = profiles.find((item) => item.key === state.profileKey)
  const taxes = catalogue.data?.tax_categories ?? []
  const routingProfile = profile
    ? {
        ...profile,
        modules: profile.modules.filter((key) => !state.disabledModules.includes(key)),
      }
    : undefined
  const steps = setupSteps(routingProfile)
  const activeLocations = (locations.data?.data ?? []).filter((location) => location.active)
  const locationIds = activeLocations.map((location) => location.id)
  const problems = stepProblems(state, state.step, { profiles, locationIds })
  const visibleProblems = shownProblems.filter((problem) => problems.includes(problem))
  const locked = onboarding.pending || onboarding.uncertain
  const soleLocation = locationIds.length === 1 ? locationIds[0] : null
  useEffect(() => {
    if (!state.branch.stockLocationId && soleLocation)
      dispatch({ type: 'stock-location', value: soleLocation })
  }, [state.branch.stockLocationId, soleLocation])
  useEffect(() => {
    if (state.step && open) heading.current?.focus()
  }, [state.step, open])
  function go(step: SetupStep) {
    if (locked || sending.current) return
    setShownProblems([])
    setFailure('')
    // The shop step starts from the profile's proposal; edits stay while the profile does.
    if (routingProfile && catalogue.data && hasShopStep(routingProfile) && step >= SHOP_STEP)
      dispatch({
        type: 'shop-init',
        value: shopDefaults(routingProfile, catalogue.data, stationName(t)),
      })
    dispatch({ type: 'go', step })
  }
  async function finish(run: () => Promise<unknown>) {
    if (sending.current) return
    sending.current = true
    setFailure('')
    try {
      const data = await mutation.mutateAsync(run)
      const selection = onboardingSelection(data)
      onDone()
      if (selection) setSelection(selection)
      await refreshBusinessModel(storeId)
      // A new F&B branch opens on its hardware checklist: printers, kitchen
      // screens and the print station come next.
      if (selection && hasShopStep(profile)) {
        await navigate({
          to: '/$storeId/branches/$branchId/hardware',
          params: {
            storeId: storeId ?? context.data?.store.id ?? '',
            branchId: selection.branchId,
          },
        })
        return
      }
      await navigate({
        to: '/$storeId',
        params: { storeId: storeId ?? context.data?.store.id ?? '' },
        search: {
          branch: selection?.branchId ?? undefined,
          register: selection?.registerId ?? undefined,
        },
      })
    } catch (error) {
      if (conflictReason(error) === 'already_onboarded') {
        setFailure(t('setup.alreadyOnboarded'))
        await refreshBusinessModel(storeId)
      } else setFailure(describeFailure(error, t, 'setup.createFailed'))
    } finally {
      sending.current = false
    }
  }
  function submit() {
    if (locked || sending.current) return
    if (problems.length) {
      setShownProblems(problems)
      return
    }
    if (state.step !== SUMMARY_STEP) {
      go(nextStep(state.step, profile))
      return
    }
    if (profile) void finish(() => onboarding.submit(onboardingPayload(state, profile)))
  }
  if (catalogue.isPending) return <ModelState title={t('waiting')} />
  if (catalogue.isError)
    return (
      <ModelState
        error
        title={t(posFailureKey(catalogue.error))}
        retry={() => void catalogue.refetch()}
      />
    )
  const headingId = `setup-step-${state.step}-title`
  return (
    <>
      {!open ? (
        <Button type="button" onClick={() => setOpen(true)}>
          {t('setup.resume')}
        </Button>
      ) : null}
      <Wizard
        open={open}
        onOpenChange={(next) => {
          if (!locked && !sending.current) setOpen(next)
        }}
        title={t('setup.title')}
        subtitle={t('setup.intro')}
        steps={steps.map((step) => ({ key: String(step), label: t(`setup.step${step}`) }))}
        current={String(state.step)}
        onStepSelect={locked ? undefined : (key) => go(Number(key) as SetupStep)}
        onSubmit={(event) => {
          event.preventDefault()
          submit()
        }}
        contentClassName={state.step === 1 ? undefined : 'max-w-4xl'}
        back={
          <Button
            type="button"
            variant="outline"
            disabled={state.step === 1 || locked}
            onClick={() => go(previousStep(state.step, profile))}
          >
            {t('setup.back')}
          </Button>
        }
        forward={
          <Button type="submit" disabled={locked}>
            {state.step === SUMMARY_STEP
              ? onboarding.pending
                ? t('waiting')
                : t('setup.create')
              : t('setup.next')}
          </Button>
        }
      >
        {/* RadioGroup items are buttons: Enter would only re-select them.
            Keyboard users expect Enter to advance, like the POS wizard. */}
        <fieldset
          className="min-w-0 space-y-5"
          onKeyDown={(event) => {
            const target = event.target as HTMLElement
            if (event.key === 'Enter' && !locked && target.getAttribute('role') === 'radio') {
              event.preventDefault()
              submit()
            }
          }}
        >
          <h2 id={headingId} ref={heading} tabIndex={-1} className="text-xl font-semibold">
            <span className="sr-only">
              {t('setup.stepOf', { step: steps.indexOf(state.step) + 1, total: steps.length })}{' '}
            </span>
            {t(`setup.step${state.step}`)}
          </h2>
          <fieldset disabled={locked} className="min-w-0 space-y-5">
            {state.step === 1 ? (
              <ProfilePicker
                headingId={headingId}
                profiles={profiles}
                state={state}
                dispatch={dispatch}
              />
            ) : null}
            {state.step === 2 ? (
              <fieldset className="space-y-4">
                <legend className="mb-4">{t('setup.wholesaleQuestion')}</legend>
                <RadioGroup
                  value={String(state.wholesale)}
                  onValueChange={(value) =>
                    dispatch({ type: 'wholesale', value: value === 'true' })
                  }
                >
                  {([true, false] as const).map((value) => (
                    <div key={String(value)} className="flex items-center gap-3">
                      <RadioGroupItem id={`wholesale-${value}`} value={String(value)} />
                      <Label htmlFor={`wholesale-${value}`}>
                        {t(value ? 'setup.wholesaleYes' : 'setup.wholesaleNo')}
                      </Label>
                    </div>
                  ))}
                </RadioGroup>
                <p className="text-sm text-muted-foreground">{t('setup.wholesaleNote')}</p>
              </fieldset>
            ) : null}
            {state.step === 3 ? (
              <SetupBranchStep
                state={state}
                dispatch={dispatch}
                problems={visibleProblems}
                locations={{
                  rows: locations.data?.data ?? [],
                  isPending: locations.isPending,
                  error: locations.isError ? locations.error : null,
                  retry: () => void locations.refetch(),
                }}
              />
            ) : null}
            {state.step === 4 && profile ? (
              <SetupPreviewStep
                profile={profile}
                catalogue={catalogue.data?.modules ?? []}
                state={state}
                dispatch={dispatch}
                problems={visibleProblems}
              />
            ) : null}
            {state.step === SHOP_STEP && profile && state.shop ? (
              <SetupFnbStep
                profile={profile}
                shop={state.shop}
                hasTables={state.hasTables}
                registerName={state.registerName}
                taxes={taxes}
                dispatch={dispatch}
                problems={visibleProblems}
              />
            ) : null}
            {state.step === SUMMARY_STEP && profile ? (
              <SetupSummary
                state={state}
                shop={hasShopStep(routingProfile) ? state.shop : null}
                taxLabel={(code) => taxLabel(t, taxes, code)}
                profileName={t(profileLabelKey(profile.key))}
                modules={profileModules(profile, tablesOptional(profile) && state.hasTables).filter(
                  (key) => !state.disabledModules.includes(key),
                )}
                tables={tablesOn(state, profile)}
                units={profile.sample_units.map((code) => unitLabel(t, code))}
                location={
                  activeLocations.find((row) => row.id === state.branch.stockLocationId)?.name ?? ''
                }
              />
            ) : null}
          </fieldset>
          {visibleProblems.length ? (
            <div role="alert" className="rounded-md border border-destructive p-4 text-destructive">
              <p>{t('setup.fixFirst')}</p>
              <ul className="list-inside list-disc">
                {visibleProblems.map((problem) => (
                  <li key={problem}>{t(`setup.problem_${problem}`)}</li>
                ))}
              </ul>
            </div>
          ) : null}
          {onboarding.uncertain ? (
            <div role="status" className="flex flex-wrap items-center gap-3 rounded-md border p-4">
              {t('setup.checking')}
              <Button
                type="button"
                variant="outline"
                disabled={onboarding.pending}
                onClick={() => void finish(onboarding.recheck)}
              >
                {t('setup.recheck')}
              </Button>
            </div>
          ) : null}
          {failure ? (
            <p role="alert" className="text-destructive">
              {failure}
            </p>
          ) : null}
        </fieldset>
      </Wizard>
    </>
  )
}

function SetupSummary({
  state,
  shop,
  taxLabel,
  profileName,
  modules,
  tables,
  units,
  location,
}: {
  state: SetupState
  shop: ShopSetup | null
  taxLabel: (code: string) => string
  profileName: string
  modules: string[]
  tables: boolean
  units: string[]
  location: string
}) {
  const { t } = useTranslation()
  const none = t('setup.none')
  return (
    <section data-testid="setup-summary" className="space-y-4">
      <p>{t('setup.summaryIntro')}</p>
      <dl className="grid grid-cols-1 gap-3 sm:grid-cols-[minmax(10rem,1fr)_2fr] [&>dt]:font-medium [&>dd]:break-words">
        <dt>{t('setup.summaryProfile')}</dt>
        <dd>{profileName}</dd>
        <dt>{t('setup.summaryWholesale')}</dt>
        <dd>{t(state.wholesale ? 'setup.wholesaleYes' : 'setup.wholesaleNo')}</dd>
        {state.interests.length ? (
          <>
            <dt>{t('setup.summaryInterests')}</dt>
            <dd>{state.interests.map((key) => t(profileLabelKey(key))).join(', ')}</dd>
          </>
        ) : null}
        <dt>{t('setup.summaryBranch')}</dt>
        <dd>
          {state.branch.name.trim()} · {state.branch.code} · {state.branch.timezone}
        </dd>
        <dt>{t('stockLocation')}</dt>
        <dd>{location || none}</dd>
        <dt>{t('setup.summaryRegister')}</dt>
        <dd>{state.registerName.trim() || t('setup.summaryNoRegister')}</dd>
        <dt>{t('setup.summaryTables')}</dt>
        <dd>
          {tables
            ? t('setup.summaryTablesYes', { register: state.registerName.trim() })
            : t('setup.summaryTablesNo')}
        </dd>
        <dt>{t('setup.summaryModules')}</dt>
        <dd>
          {modules.length
            ? modules.map((key, index) => (
                <span key={key}>
                  {index ? ', ' : ''}
                  <ModuleName moduleKey={key} />
                </span>
              ))
            : none}
        </dd>
        <dt>{t('setup.summaryUnits')}</dt>
        <dd>{units.length ? units.join(', ') : none}</dd>
        <dt>{t('setup.summaryFeatures')}</dt>
        <dd>
          {state.features.length
            ? state.features.map((feature) => t(`featureName_${feature}`)).join(', ')
            : t('setup.summaryNoFeatures')}
        </dd>
        {shop ? (
          <>
            <dt>{t('setup.summaryStations')}</dt>
            <dd>{shop.stations.map((row) => row.name.trim()).join(', ') || none}</dd>
            <dt>{t('setup.summaryTax')}</dt>
            <dd>
              {t('setup.summaryTaxValue', {
                food: taxLabel(shop.foodTax),
                alcohol: taxLabel(shop.alcoholTax),
              })}
            </dd>
            {modules.includes('fnb.kitchen') ? (
              <>
                <dt>{t('setup.shopTrigger')}</dt>
                <dd>{t(`setup.shopTrigger_${shop.trigger}`)}</dd>
              </>
            ) : null}
          </>
        ) : null}
        <dt>{t('setup.summaryGrant')}</dt>
        <dd>{t(state.grantSelf ? 'setup.summaryGrantYes' : 'setup.summaryGrantNo')}</dd>
      </dl>
    </section>
  )
}
