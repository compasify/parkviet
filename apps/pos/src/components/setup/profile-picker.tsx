import type { Dispatch } from 'react';
import { useTranslation } from 'react-i18next';
import {
  type BusinessProfile,
  profileDescriptionKey,
  profileLabelKey,
} from '../../lib/pos-modules';
import {
  isAvailable,
  isComingSoon,
  type SetupAction,
  type SetupState,
} from '../../lib/setup-wizard';

// Step 1: one radio group of industry cards, in the server's order, in two
// sections: retail (selectable) and food & entertainment ("coming soon").
// Picking a "coming soon" card asks whether the shop also sells goods; yes
// records the interest and moves the choice to a suggested retail profile.
export function ProfilePicker({
  headingId,
  profiles,
  state,
  dispatch,
}: {
  headingId: string;
  profiles: BusinessProfile[];
  state: SetupState;
  dispatch: Dispatch<SetupAction>;
}) {
  const { t } = useTranslation();
  const retail = profiles.filter((profile) => profile.group === 'retail');
  const other = profiles.filter((profile) => profile.group !== 'retail');
  const label = (key: string) => t(profileLabelKey(key), { defaultValue: key });
  const pending = profiles.find((profile) => profile.key === state.choice);
  const waiting = isComingSoon(pending) && !state.declined;
  return (
    <div className="setup-profiles">
      <div role="radiogroup" aria-labelledby={headingId} aria-required="true">
        {[
          { id: 'retail', title: t('setup.groupRetail'), rows: retail },
          { id: 'other', title: t('setup.groupFnb'), rows: other },
        ].map((section) =>
          section.rows.length ? (
            <fieldset key={section.id} className="setup-card-group">
              <legend>{section.title}</legend>
              <div className="setup-cards">
                {section.rows.map((profile) => {
                  const soon = !isAvailable(profile);
                  const id = `setup-profile-${profile.key}`;
                  return (
                    <label
                      key={profile.key}
                      className="setup-card"
                      data-selected={state.choice === profile.key}
                      data-soon={soon}
                      htmlFor={id}
                    >
                      <input
                        id={id}
                        type="radio"
                        name="setup-profile"
                        value={profile.key}
                        checked={state.choice === profile.key}
                        // The name is the industry; the badge and the line below describe it.
                        aria-labelledby={`${id}-name`}
                        aria-describedby={
                          soon ? `${id}-soon ${id}-description` : `${id}-description`
                        }
                        onChange={() => dispatch({ type: 'choose', key: profile.key, profiles })}
                      />
                      <span className="setup-card-body">
                        <strong id={`${id}-name`}>{label(profile.key)}</strong>
                        {soon ? (
                          <span className="status-tag" id={`${id}-soon`}>
                            {t('setup.comingSoon')}
                          </span>
                        ) : null}
                        <small id={`${id}-description`}>
                          {t(profileDescriptionKey(profile.key), { defaultValue: '' })}
                        </small>
                      </span>
                    </label>
                  );
                })}
              </div>
            </fieldset>
          ) : null,
        )}
      </div>
      {waiting && pending ? (
        <fieldset className="setup-interest admin-info">
          <legend>{t('setup.interestPrompt', { name: label(pending.key) })}</legend>
          <div className="setup-actions-inline">
            <button
              type="button"
              className="primary-button"
              onClick={() => dispatch({ type: 'answer-interest', sellsGoods: true, profiles })}
            >
              {t('setup.interestYes')}
            </button>
            <button
              type="button"
              onClick={() => dispatch({ type: 'answer-interest', sellsGoods: false, profiles })}
            >
              {t('setup.interestNo')}
            </button>
          </div>
        </fieldset>
      ) : null}
      {state.declined && pending ? (
        <p className="admin-info" role="status">
          {t('setup.interestDeclined', { name: label(pending.key) })}
        </p>
      ) : null}
      {state.interests.length ? (
        <div className="setup-interests" role="status">
          <p>
            {t('setup.interestsRecorded', {
              names: state.interests.map(label).join(', '),
            })}
          </p>
          <ul aria-label={t('setup.interestsList')}>
            {state.interests.map((key) => (
              <li key={key}>
                <span>{label(key)}</span>
                <button
                  type="button"
                  aria-label={t('setup.interestRemove', { name: label(key) })}
                  onClick={() => dispatch({ type: 'remove-interest', key })}
                >
                  {t('setup.interestRemoveShort')}
                </button>
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  );
}
