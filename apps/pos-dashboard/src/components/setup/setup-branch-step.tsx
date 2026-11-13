import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import type { SetupAction, SetupProblem, SetupState } from '@parkviet/pos-shared/setup-wizard'
import { TimezoneCombobox } from '@spree/dashboard-core'
import { Button, Input, Label } from '@spree/dashboard-ui'
import type { Dispatch } from 'react'
import { useTranslation } from 'react-i18next'
import type { LocationOption } from '../../hooks/use-topology'
import { ModelCheck, ModelSelect } from './model-ui'

export function SetupBranchStep({
  state,
  dispatch,
  locations,
  problems,
}: {
  state: SetupState
  dispatch: Dispatch<SetupAction>
  locations: { rows: LocationOption[]; isPending: boolean; error: unknown; retry: () => void }
  problems: SetupProblem[]
}) {
  const { t } = useTranslation()
  const active = locations.rows.filter((location) => location.active)
  return (
    <div className="space-y-5">
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="setup-branch-name">{t('setup.branchName')}</Label>
          <Input
            id="setup-branch-name"
            maxLength={100}
            autoComplete="off"
            value={state.branch.name}
            aria-invalid={problems.includes('name')}
            onChange={(event) => dispatch({ type: 'branch-name', value: event.target.value })}
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="setup-branch-code">{t('setup.branchCode')}</Label>
          <Input
            id="setup-branch-code"
            maxLength={32}
            autoComplete="off"
            value={state.branch.code}
            aria-invalid={problems.includes('code')}
            aria-describedby="setup-code-hint"
            onChange={(event) => dispatch({ type: 'branch-code', value: event.target.value })}
          />
          <p id="setup-code-hint" className="text-sm text-muted-foreground">
            {t('setup.branchCodeHint')}
          </p>
        </div>
      </div>
      <div className="space-y-2">
        <Label htmlFor="setup-timezone">{t('timezone')}</Label>
        <TimezoneCombobox
          id="setup-timezone"
          value={state.branch.timezone}
          invalid={problems.includes('timezone')}
          onValueChange={(value) => dispatch({ type: 'timezone', value })}
        />
        <p id="setup-timezone-hint" className="text-sm text-muted-foreground">
          {t('timezoneHint')}
        </p>
      </div>
      {locations.isPending ? (
        <p role="status">{t('waiting')}</p>
      ) : locations.error ? (
        <div role="alert">
          <p>{t(posFailureKey(locations.error))}</p>
          <Button type="button" variant="outline" onClick={locations.retry}>
            {t('retry')}
          </Button>
        </div>
      ) : !active.length ? (
        <div className="space-y-3 rounded-md border bg-muted p-4" role="alert">
          <strong>{t('setup.noLocationsTitle')}</strong>
          <p>{t('setup.noLocationsHint')}</p>
          <Button type="button" variant="outline" onClick={locations.retry}>
            {t('setup.noLocationsRetry')}
          </Button>
        </div>
      ) : (
        <ModelSelect
          label={t('stockLocation')}
          value={state.branch.stockLocationId}
          invalid={problems.includes('location')}
          hint={t('setup.locationHint')}
          options={[
            { value: '', label: t('adminChooseWarehouse') },
            ...active.map((location) => ({ value: location.id, label: location.name })),
          ]}
          onChange={(value) => dispatch({ type: 'stock-location', value })}
        />
      )}
      <div className="space-y-2">
        <Label htmlFor="setup-register-name">{t('setup.registerName')}</Label>
        <Input
          id="setup-register-name"
          maxLength={100}
          autoComplete="off"
          value={state.registerName}
          aria-describedby="setup-register-hint"
          onChange={(event) => dispatch({ type: 'register-name', value: event.target.value })}
        />
        <p id="setup-register-hint" className="text-sm text-muted-foreground">
          {t('setup.registerHint')}
        </p>
      </div>
      <ModelCheck
        checked={state.grantSelf}
        onChange={(value) => dispatch({ type: 'grant-self', value })}
        description={t('setup.grantSelfHint')}
      >
        {t('setup.grantSelf')}
      </ModelCheck>
    </div>
  )
}
