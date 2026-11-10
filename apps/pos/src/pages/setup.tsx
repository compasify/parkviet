import { profileLabelKey } from '@parkviet/pos-shared/pos-modules';
import {
  initialSetup,
  onboardingPayload,
  onboardingSelection,
  SETUP_STEPS,
  type SetupProblem,
  type SetupState,
  type SetupStep,
  setupReducer,
  stepProblems,
} from '@parkviet/pos-shared/setup-wizard';
import { Link, useNavigate } from '@tanstack/react-router';
import { type ReactNode, useEffect, useReducer, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../components/pos-icon';
import { PageState } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ProfilePicker } from '../components/setup/profile-picker';
import { SetupBranchStep } from '../components/setup/setup-branch-step';
import { ModuleName, SetupPreviewStep, unitLabel } from '../components/setup/setup-preview-step';
import { useBusinessProfiles } from '../hooks/use-business-profiles';
import { refreshBusinessModel, useOnboarding } from '../hooks/use-onboarding';
import { useLocationOptions } from '../hooks/use-topology';
import { conflictReason, describeFailure, posFailureKey } from '../lib/request-failure';
import '../styles/setup.css';

const STEP_TITLE: Record<SetupStep, string> = {
  1: 'setup.step1',
  2: 'setup.step2',
  3: 'setup.step3',
  4: 'setup.step4',
  5: 'setup.step5',
};

// First-run setup. Shown instead of the branch picker while the store has no
// profile and no active branch, to staff who may set it up
// (`onboarding.can_setup`). Nothing is stored in the browser and nothing is
// sent before the last step.
export function SetupPage() {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const onboarding = context.data?.onboarding;
  const [done, setDone] = useState(false);
  let body: ReactNode;
  if (done) body = <PageState kind="success" title={t('setup.doneOpening')} />;
  else if (context.isPending) body = <PageState kind="loading" title={t('contextWaiting')} />;
  else if (context.isError)
    body = (
      <PageState kind="error" title={t(posFailureKey(context.error))}>
        <button type="button" onClick={() => void context.refetch()}>
          {t('retry')}
        </button>
      </PageState>
    );
  else if (!onboarding?.required)
    body = (
      <PageState kind="success" title={t('setup.alreadyDone')}>
        <p>{t('setup.alreadyDoneHint')}</p>
        <Link className="button-link" to="/">
          <PosIcon name="grid" />
          {t('sellingArea')}
        </Link>
      </PageState>
    );
  else if (!onboarding.can_setup)
    body = (
      <PageState title={t('branchesEmpty')}>
        <p>{t('setup.askAdmin')}</p>
      </PageState>
    );
  else body = <SetupWizard onDone={() => setDone(true)} />;
  return (
    <div className="pos-page setup-page">
      <div className="page-heading">
        <div>
          <h1 id="pos-page-title" tabIndex={-1}>
            {t('setup.title')}
          </h1>
          <p>{t('setup.intro')}</p>
        </div>
      </div>
      {body}
    </div>
  );
}

function SetupWizard({ onDone }: { onDone: () => void }) {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { context, setSelection } = usePosSelection();
  const storeId = context.data?.store.id ?? null;
  const catalogue = useBusinessProfiles(storeId);
  const locations = useLocationOptions(true);
  const onboarding = useOnboarding();
  const [state, dispatch] = useReducer(setupReducer, context.data?.store.timezone, initialSetup);
  const [shownProblems, setShownProblems] = useState<SetupProblem[]>([]);
  const [failure, setFailure] = useState('');
  const heading = useRef<HTMLHeadingElement>(null);
  const firstStep = useRef(true);
  const profiles = catalogue.data?.profiles ?? [];
  const profile = profiles.find((item) => item.key === state.profileKey);
  const activeLocations = (locations.data?.data ?? []).filter((location) => location.active);
  const locationIds = activeLocations.map((location) => location.id);
  const problems = stepProblems(state, state.step, { profiles, locationIds });
  // Reported problems disappear as each one is fixed.
  const visibleProblems = shownProblems.filter((problem) => problems.includes(problem));
  const locked = onboarding.pending || onboarding.uncertain;

  // A store with a single stock location starts with it chosen.
  const soleLocation = locationIds.length === 1 ? locationIds[0] : null;
  useEffect(() => {
    if (!state.branch.stockLocationId && soleLocation)
      dispatch({ type: 'stock-location', value: soleLocation });
  }, [state.branch.stockLocationId, soleLocation]);

  // Each step announces itself: focus moves to its heading.
  // biome-ignore lint/correctness/useExhaustiveDependencies: the step change is the trigger
  useEffect(() => {
    if (firstStep.current) {
      firstStep.current = false;
      return;
    }
    heading.current?.focus();
  }, [state.step]);

  function go(step: SetupStep) {
    setShownProblems([]);
    setFailure('');
    dispatch({ type: 'go', step });
  }

  function next() {
    if (problems.length) {
      setShownProblems(problems);
      return;
    }
    if (state.step < 5) go((state.step + 1) as SetupStep);
  }

  async function finish(run: () => Promise<unknown>) {
    setFailure('');
    try {
      const data = await run();
      const selection = onboardingSelection(data);
      onDone();
      // The new branch (and register) becomes the selling context; the sale
      // screen then offers to open a shift as usual.
      if (selection) setSelection(selection);
      await refreshBusinessModel();
      await navigate({ to: '/' });
    } catch (error) {
      if (conflictReason(error) === 'already_onboarded') {
        // Set up meanwhile (another device, or a lost answer with other content).
        setFailure(t('setup.alreadyOnboarded'));
        await refreshBusinessModel();
        return;
      }
      setFailure(describeFailure(error, t, 'setup.createFailed'));
    }
  }

  function create() {
    if (!profile || problems.length) {
      setShownProblems(problems);
      return;
    }
    void finish(() => onboarding.submit(onboardingPayload(state, profile)));
  }

  if (catalogue.isPending) return <PageState kind="loading" title={t('waiting')} />;
  if (catalogue.isError)
    return (
      <PageState kind="error" title={t(posFailureKey(catalogue.error))}>
        <button type="button" onClick={() => void catalogue.refetch()}>
          {t('retry')}
        </button>
      </PageState>
    );

  const headingId = `setup-step-${state.step}-title`;
  return (
    <section className="page-card setup-wizard" aria-labelledby={headingId}>
      <ol className="setup-progress" aria-label={t('setup.progress')}>
        {SETUP_STEPS.map((step) => (
          <li
            key={step}
            aria-current={step === state.step ? 'step' : undefined}
            data-done={step < state.step}
          >
            <span className="setup-progress-number">{step}</span>
            <span className="setup-progress-label">{t(STEP_TITLE[step])}</span>
          </li>
        ))}
      </ol>
      <h2 id={headingId} ref={heading} tabIndex={-1}>
        <span className="visually-hidden">
          {t('setup.stepOf', { step: state.step, total: 5 })}{' '}
        </span>
        {t(STEP_TITLE[state.step])}
      </h2>
      <form
        className="setup-step"
        // The step lists what is missing in one announced message instead
        // of the browser's per-field bubbles.
        noValidate
        onSubmit={(event) => {
          event.preventDefault();
          if (state.step === 5) create();
          else next();
        }}
      >
        {state.step === 1 ? (
          <ProfilePicker
            headingId={headingId}
            profiles={profiles}
            state={state}
            dispatch={dispatch}
          />
        ) : null}
        {state.step === 2 ? (
          <fieldset className="setup-wholesale">
            <legend>{t('setup.wholesaleQuestion')}</legend>
            {([true, false] as const).map((value) => (
              <label key={String(value)} className="setup-check">
                <input
                  type="radio"
                  name="setup-wholesale"
                  checked={state.wholesale === value}
                  onChange={() => dispatch({ type: 'wholesale', value })}
                />
                <span>{t(value ? 'setup.wholesaleYes' : 'setup.wholesaleNo')}</span>
              </label>
            ))}
            <p className="muted">{t('setup.wholesaleNote')}</p>
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
            state={state}
            dispatch={dispatch}
            problems={visibleProblems}
          />
        ) : null}
        {state.step === 5 && profile ? (
          <SetupSummary
            state={state}
            profileName={t(profileLabelKey(profile.key))}
            modules={profile.modules}
            units={profile.sample_units.map((code) => unitLabel(t, code))}
            location={
              activeLocations.find((row) => row.id === state.branch.stockLocationId)?.name ?? ''
            }
          />
        ) : null}
        {visibleProblems.length ? (
          <div className="error" role="alert">
            <p>{t('setup.fixFirst')}</p>
            <ul>
              {visibleProblems.map((problem) => (
                <li key={problem}>{t(`setup.problem_${problem}`)}</li>
              ))}
            </ul>
          </div>
        ) : null}
        {onboarding.uncertain ? (
          <div className="status-tag setup-checking" data-warning="true" role="status">
            {t('setup.checking')}{' '}
            <button
              type="button"
              disabled={onboarding.pending}
              onClick={() => void finish(onboarding.recheck)}
            >
              {t('setup.recheck')}
            </button>
          </div>
        ) : null}
        {failure ? (
          <p className="error" role="alert">
            {failure}
          </p>
        ) : null}
        <div className="setup-nav">
          <button
            type="button"
            disabled={state.step === 1 || locked}
            onClick={() => go((state.step - 1) as SetupStep)}
          >
            <PosIcon name="back" />
            {t('setup.back')}
          </button>
          <button type="submit" className="primary-button" disabled={locked}>
            {state.step === 5
              ? onboarding.pending
                ? t('waiting')
                : t('setup.create')
              : t('setup.next')}
          </button>
        </div>
      </form>
    </section>
  );
}

function SetupSummary({
  state,
  profileName,
  modules,
  units,
  location,
}: {
  state: SetupState;
  profileName: string;
  modules: string[];
  units: string[];
  location: string;
}) {
  const { t } = useTranslation();
  const none = t('setup.none');
  return (
    <div className="setup-summary">
      <p>{t('setup.summaryIntro')}</p>
      <dl>
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
        <dt>{t('setup.summaryGrant')}</dt>
        <dd>{t(state.grantSelf ? 'setup.summaryGrantYes' : 'setup.summaryGrantNo')}</dd>
      </dl>
    </div>
  );
}
