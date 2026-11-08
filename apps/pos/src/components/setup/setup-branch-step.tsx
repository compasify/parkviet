import type { Dispatch } from 'react';
import { useTranslation } from 'react-i18next';
import type { LocationOption } from '../../hooks/use-topology';
import { posFailureKey } from '../../lib/request-failure';
import type { SetupAction, SetupProblem, SetupState } from '../../lib/setup-wizard';

// Step 3: the first branch, its stock location and an optional register, and
// whether the person setting up gets every permission there (ticked).
export function SetupBranchStep({
  state,
  dispatch,
  locations,
  problems,
}: {
  state: SetupState;
  dispatch: Dispatch<SetupAction>;
  locations: {
    rows: LocationOption[];
    isPending: boolean;
    error: unknown;
    retry: () => void;
  };
  problems: SetupProblem[];
}) {
  const { t } = useTranslation();
  const invalid = (problem: SetupProblem) => problems.includes(problem) || undefined;
  const active = locations.rows.filter((location) => location.active);
  return (
    <div className="setup-form">
      <div className="admin-form-grid">
        <label>
          {t('setup.branchName')}
          <input
            required
            maxLength={100}
            autoComplete="off"
            value={state.branch.name}
            aria-invalid={invalid('name')}
            onChange={(event) => dispatch({ type: 'branch-name', value: event.target.value })}
          />
        </label>
        <label>
          {t('setup.branchCode')}
          <input
            required
            maxLength={32}
            autoComplete="off"
            pattern={'[a-z0-9][a-z0-9_\\-]{0,31}'}
            value={state.branch.code}
            aria-invalid={invalid('code')}
            aria-describedby="setup-code-hint"
            onChange={(event) => dispatch({ type: 'branch-code', value: event.target.value })}
          />
          <small id="setup-code-hint">{t('setup.branchCodeHint')}</small>
        </label>
      </div>
      <label>
        {t('timezone')}
        <input
          required
          maxLength={64}
          list="setup-timezones"
          value={state.branch.timezone}
          aria-invalid={invalid('timezone')}
          onChange={(event) => dispatch({ type: 'timezone', value: event.target.value })}
        />
        <datalist id="setup-timezones">
          <option value="Asia/Ho_Chi_Minh" />
          <option value="Asia/Bangkok" />
          <option value="UTC" />
        </datalist>
      </label>
      {locations.isPending ? (
        <p role="status">{t('waiting')}</p>
      ) : locations.error ? (
        <div className="error" role="alert">
          <p>{t(posFailureKey(locations.error))}</p>
          <button type="button" onClick={locations.retry}>
            {t('retry')}
          </button>
        </div>
      ) : active.length === 0 ? (
        <div className="setup-blocker admin-info" role="alert">
          <strong>{t('setup.noLocationsTitle')}</strong>
          <p>{t('setup.noLocationsHint')}</p>
          <button type="button" onClick={locations.retry}>
            {t('setup.noLocationsRetry')}
          </button>
        </div>
      ) : (
        <label>
          {t('stockLocation')}
          <select
            required
            value={state.branch.stockLocationId}
            aria-invalid={invalid('location')}
            aria-describedby="setup-location-hint"
            onChange={(event) => dispatch({ type: 'stock-location', value: event.target.value })}
          >
            <option value="">{t('adminChooseWarehouse')}</option>
            {active.map((location) => (
              <option key={location.id} value={location.id}>
                {location.name}
              </option>
            ))}
          </select>
          <small id="setup-location-hint">{t('setup.locationHint')}</small>
        </label>
      )}
      <label>
        {t('setup.registerName')}
        <input
          maxLength={100}
          autoComplete="off"
          value={state.registerName}
          aria-describedby="setup-register-hint"
          onChange={(event) => dispatch({ type: 'register-name', value: event.target.value })}
        />
        <small id="setup-register-hint">{t('setup.registerHint')}</small>
      </label>
      <label className="setup-check">
        <input
          type="checkbox"
          checked={state.grantSelf}
          aria-labelledby="setup-grant-name"
          aria-describedby="setup-grant-hint"
          onChange={(event) => dispatch({ type: 'grant-self', value: event.target.checked })}
        />
        <span>
          <strong id="setup-grant-name">{t('setup.grantSelf')}</strong>
          <small id="setup-grant-hint">{t('setup.grantSelfHint')}</small>
        </span>
      </label>
    </div>
  );
}
