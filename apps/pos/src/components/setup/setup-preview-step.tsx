import { type BusinessProfile, moduleTextKey } from '@parkviet/pos-shared/pos-modules';
import {
  editableDefaults,
  recommendedFeatures,
  type SetupAction,
  type SetupProblem,
  type SetupState,
} from '@parkviet/pos-shared/setup-wizard';
import type { Dispatch } from 'react';
import { useTranslation } from 'react-i18next';

// A module this client has no label for shows its key (D3: never dropped).
export function ModuleName({ moduleKey }: { moduleKey: string }) {
  const { t } = useTranslation();
  const text = moduleTextKey(moduleKey);
  return text ? t(`posModules.${text}.label`) : moduleKey;
}

export function ModuleDescription({ moduleKey }: { moduleKey: string }) {
  const { t } = useTranslation();
  const text = moduleTextKey(moduleKey);
  return text ? t(`posModules.${text}.description`) : null;
}

export function unitLabel(
  t: (key: string, options?: Record<string, unknown>) => string,
  code: string,
) {
  return t(`setup.unit.${code}`, { defaultValue: code });
}

// Step 4: what the industry turns on and suggests, before anything is sent.
// Branch defaults are edited in place; the risky features the industry
// usually uses are listed with their risk, each box left unticked (D6).
export function SetupPreviewStep({
  profile,
  state,
  dispatch,
  problems,
}: {
  profile: BusinessProfile;
  state: SetupState;
  dispatch: Dispatch<SetupAction>;
  problems: SetupProblem[];
}) {
  const { t } = useTranslation();
  const fields = editableDefaults(profile);
  const features = recommendedFeatures(profile);
  const invalid = (problem: SetupProblem) => problems.includes(problem) || undefined;
  return (
    <div className="setup-preview">
      <section aria-labelledby="setup-modules-heading">
        <h3 id="setup-modules-heading">{t('setup.modulesTitle')}</h3>
        {profile.modules.length ? (
          <ul className="setup-module-list">
            {profile.modules.map((key) => (
              <li key={key} data-module={key}>
                <strong>
                  <ModuleName moduleKey={key} />
                </strong>
                <small>
                  <ModuleDescription moduleKey={key} />
                </small>
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted">{t('setup.modulesNone')}</p>
        )}
        <p className="muted">{t('setup.modulesLater')}</p>
      </section>
      <section aria-labelledby="setup-defaults-heading">
        <h3 id="setup-defaults-heading">{t('setup.defaultsTitle')}</h3>
        <div className="admin-form-grid">
          {fields.includes('return_window_days') ? (
            <label>
              {t('adminReturnWindow')}
              <input
                type="text"
                inputMode="numeric"
                maxLength={4}
                value={state.defaults.return_window_days}
                aria-invalid={invalid('return-window')}
                aria-describedby="setup-return-hint"
                onChange={(event) =>
                  dispatch({
                    type: 'default',
                    field: 'return_window_days',
                    value: event.target.value,
                  })
                }
              />
              <small id="setup-return-hint">{t('adminReturnWindowHint')}</small>
            </label>
          ) : null}
          {fields.includes('lot_selection') ? (
            <label>
              {t('adminLotSelection')}
              <select
                value={state.defaults.lot_selection}
                aria-describedby="setup-lot-hint"
                onChange={(event) =>
                  dispatch({ type: 'default', field: 'lot_selection', value: event.target.value })
                }
              >
                <option value="fefo">{t('adminLotSelection_fefo')}</option>
                <option value="cashier_pick">{t('adminLotSelection_cashier_pick')}</option>
              </select>
              <small id="setup-lot-hint">{t('adminLotSelectionHint')}</small>
            </label>
          ) : null}
          {fields.includes('variance_threshold') ? (
            <label>
              {t('adminVarianceThreshold')}
              <input
                type="text"
                inputMode="numeric"
                maxLength={20}
                value={state.defaults.variance_threshold}
                aria-invalid={invalid('variance')}
                onChange={(event) =>
                  dispatch({
                    type: 'default',
                    field: 'variance_threshold',
                    value: event.target.value,
                  })
                }
              />
            </label>
          ) : null}
          {fields.includes('adjustment_approval_threshold') ? (
            <label>
              {t('adminAdjustmentThreshold')}
              <input
                type="text"
                inputMode="numeric"
                maxLength={9}
                value={state.defaults.adjustment_approval_threshold}
                aria-invalid={invalid('adjustment')}
                onChange={(event) =>
                  dispatch({
                    type: 'default',
                    field: 'adjustment_approval_threshold',
                    value: event.target.value,
                  })
                }
              />
            </label>
          ) : null}
        </div>
        <p className="muted">
          {t(profile.display.catalog_view === 'list' ? 'setup.viewList' : 'setup.viewCards')}
        </p>
      </section>
      <section aria-labelledby="setup-units-heading">
        <h3 id="setup-units-heading">{t('setup.unitsTitle')}</h3>
        {profile.sample_units.length ? (
          <>
            <ul className="setup-chips" aria-labelledby="setup-units-heading">
              {profile.sample_units.map((code) => (
                <li key={code}>{unitLabel(t, code)}</li>
              ))}
            </ul>
            <p className="muted">{t('setup.unitsHint')}</p>
          </>
        ) : (
          <p className="muted">{t('setup.unitsNone')}</p>
        )}
      </section>
      {features.length ? (
        <fieldset className="setup-features">
          <legend>{t('setup.featuresTitle')}</legend>
          <p className="muted" id="setup-features-hint">
            {t('setup.featuresHint')}
          </p>
          {features.map((feature) => (
            <label key={feature} className="setup-check" data-feature={feature}>
              <input
                type="checkbox"
                checked={state.features.includes(feature)}
                aria-labelledby={`setup-feature-${feature}-name`}
                aria-describedby={`setup-feature-${feature}-risk setup-features-hint`}
                onChange={(event) =>
                  dispatch({ type: 'feature', feature, value: event.target.checked })
                }
              />
              <span>
                <strong id={`setup-feature-${feature}-name`}>{t(`featureName_${feature}`)}</strong>
                <small id={`setup-feature-${feature}-risk`}>{t(`featureHint_${feature}`)}</small>
              </span>
            </label>
          ))}
        </fieldset>
      ) : null}
    </div>
  );
}
