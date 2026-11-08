import { Link } from '@tanstack/react-router';
import { useTranslation } from 'react-i18next';
import type { ProfileDefaultChange, ProfilePreview } from '../hooks/use-branch-modules';
import { isPosFeature } from '../lib/pos-features';
import { profileLabelKey } from '../lib/pos-modules';
import { ModuleName, unitLabel } from './setup/setup-preview-step';

type Translate = (key: string, options?: Record<string, unknown>) => string;

const DEFAULT_LABELS: Record<string, string> = {
  return_window_days: 'adminReturnWindow',
  lot_selection: 'adminLotSelection',
  variance_threshold: 'adminVarianceThreshold',
  adjustment_approval_threshold: 'adminAdjustmentThreshold',
};

export function defaultLabel(t: Translate, field: string) {
  return DEFAULT_LABELS[field] ? t(DEFAULT_LABELS[field]) : field;
}

export function defaultValue(t: Translate, field: string, value: unknown) {
  if (value === null || value === undefined || value === '') return t('businessModel.valueBlank');
  if (field === 'lot_selection' && (value === 'fefo' || value === 'cashier_pick'))
    return t(`adminLotSelection_${value}`);
  if (field === 'return_window_days') return t('businessModel.valueDays', { count: Number(value) });
  return String(value);
}

// How much of an outgoing module's setup the branch holds, in words.
function usageText(t: Translate, counts: Record<string, number>) {
  const parts = Object.entries(counts)
    .filter(([, count]) => count > 0)
    .map(([name, count]) =>
      t(`businessModel.usage_${name}`, { count, defaultValue: `${name}: ${count}` }),
    );
  return parts.length
    ? t('businessModel.inUse', { list: parts.join(', ') })
    : t('businessModel.notInUse');
}

// The diff of moving a branch to another profile (D7): modules switched on and
// off (with the D5 warning: selling what is configured never changes), every
// differing default with its own box (unticked), and the sample units added.
export function ProfileDiff({
  branchId,
  preview,
  applyModules,
  applyDefaults,
  disabled,
  onApplyModules,
  onApplyDefault,
}: {
  branchId: string;
  preview: ProfilePreview;
  applyModules: boolean;
  applyDefaults: string[];
  disabled: boolean;
  onApplyModules: (value: boolean) => void;
  onApplyDefault: (field: string, value: boolean) => void;
}) {
  const { t } = useTranslation();
  const moduleChanges = preview.enable.length + preview.disable.length > 0;
  const features = preview.recommendedFeatures.filter(isPosFeature);
  return (
    <section
      className="profile-diff"
      aria-label={t('businessModel.diffLabel', { name: t(profileLabelKey(preview.to)) })}
    >
      <section aria-labelledby="profile-diff-modules">
        <h4 id="profile-diff-modules">{t('businessModel.diffModules')}</h4>
        {moduleChanges ? (
          <>
            <ul className="profile-diff-list">
              {preview.enable.map((key) => (
                <li key={key} data-change="enable" data-module={key}>
                  <span className="status-tag">{t('businessModel.willEnable')}</span>{' '}
                  <strong>
                    <ModuleName moduleKey={key} />
                  </strong>
                </li>
              ))}
              {preview.disable.map((key) => (
                <li key={key} data-change="disable" data-module={key}>
                  <span className="status-tag" data-warning="true">
                    {t('businessModel.willDisable')}
                  </span>{' '}
                  <strong>
                    <ModuleName moduleKey={key} />
                  </strong>
                  <small>{usageText(t, preview.inUse[key] ?? {})}</small>
                </li>
              ))}
            </ul>
            {preview.disable.length ? (
              <p className="admin-info" role="note">
                {t('businessModel.disableWarning')}
              </p>
            ) : null}
            <label className="setup-check">
              <input
                type="checkbox"
                checked={applyModules}
                disabled={disabled}
                onChange={(event) => onApplyModules(event.target.checked)}
              />
              <span>
                <strong>{t('businessModel.applyModules')}</strong>
                <small>{t('businessModel.applyModulesHint')}</small>
              </span>
            </label>
          </>
        ) : (
          <p className="muted">{t('businessModel.diffModulesSame')}</p>
        )}
      </section>
      <section aria-labelledby="profile-diff-defaults">
        <h4 id="profile-diff-defaults">{t('businessModel.diffDefaults')}</h4>
        {preview.defaults.length ? (
          <ul className="profile-diff-list">
            {preview.defaults.map((change: ProfileDefaultChange) => {
              const name = defaultLabel(t, change.field);
              return (
                <li key={change.field} data-field={change.field}>
                  <span>
                    <strong>{name}</strong>
                    <small>
                      {t('businessModel.defaultChange', {
                        current: defaultValue(t, change.field, change.current),
                        profile: defaultValue(t, change.field, change.profile),
                      })}
                    </small>
                  </span>
                  <label className="setup-check">
                    <input
                      type="checkbox"
                      checked={applyDefaults.includes(change.field)}
                      disabled={disabled}
                      aria-label={t('businessModel.applyDefaultFor', { name })}
                      onChange={(event) => onApplyDefault(change.field, event.target.checked)}
                    />
                    <span aria-hidden="true">{t('businessModel.applyDefault')}</span>
                  </label>
                </li>
              );
            })}
          </ul>
        ) : (
          <p className="muted">{t('businessModel.diffDefaultsSame')}</p>
        )}
      </section>
      <section aria-labelledby="profile-diff-units">
        <h4 id="profile-diff-units">{t('businessModel.diffUnits')}</h4>
        {preview.sampleUnits.length ? (
          <ul className="setup-chips" aria-labelledby="profile-diff-units">
            {preview.sampleUnits.map((code) => (
              <li key={code}>{unitLabel(t, code)}</li>
            ))}
          </ul>
        ) : (
          <p className="muted">{t('businessModel.diffUnitsNone')}</p>
        )}
      </section>
      {features.length ? (
        <p className="muted">
          {t('businessModel.recommended', {
            list: features.map((feature) => t(`featureName_${feature}`)).join(', '),
          })}{' '}
          <Link to="/settings/branches/$branchId/features" params={{ branchId }}>
            {t('branchFeaturesTitle')}
          </Link>
        </p>
      ) : null}
    </section>
  );
}
