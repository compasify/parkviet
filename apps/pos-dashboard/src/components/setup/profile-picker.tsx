import {
  type BusinessProfile,
  profileDescriptionKey,
  profileLabelKey,
} from '@parkviet/pos-shared/pos-modules'
import {
  isAvailable,
  isComingSoon,
  type SetupAction,
  type SetupState,
} from '@parkviet/pos-shared/setup-wizard'
import { Badge, Button, RadioGroup, RadioGroupItem } from '@spree/dashboard-ui'
import type { Dispatch } from 'react'
import { useTranslation } from 'react-i18next'

export function ProfilePicker({
  headingId,
  profiles,
  state,
  dispatch,
}: {
  headingId: string
  profiles: BusinessProfile[]
  state: SetupState
  dispatch: Dispatch<SetupAction>
}) {
  const { t } = useTranslation()
  const pending = profiles.find((profile) => profile.key === state.choice)
  const waiting = isComingSoon(pending) && !state.declined
  const label = (key: string) => t(profileLabelKey(key), { defaultValue: key })
  return (
    <div className="space-y-6">
      <RadioGroup
        value={state.choice ?? ''}
        onValueChange={(key) => {
          if (typeof key === 'string') dispatch({ type: 'choose', key, profiles })
        }}
        aria-labelledby={headingId}
        aria-required="true"
      >
        {[
          {
            id: 'retail',
            title: t('setup.groupRetail'),
            rows: profiles.filter((profile) => profile.group === 'retail'),
          },
          {
            id: 'other',
            title: t('setup.groupFnb'),
            rows: profiles.filter((profile) => profile.group !== 'retail'),
          },
        ].map((section) =>
          section.rows.length ? (
            <fieldset key={section.id} className="min-w-0 space-y-3">
              <legend className="mb-3 font-semibold">{section.title}</legend>
              <div className="grid grid-cols-[repeat(auto-fill,minmax(min(100%,18rem),1fr))] gap-3">
                {section.rows.map((profile) => {
                  const soon = !isAvailable(profile)
                  const id = `setup-profile-${profile.key}`
                  return (
                    <label
                      key={profile.key}
                      htmlFor={id}
                      className={`flex cursor-pointer items-start gap-3 rounded-lg border p-4 ${state.choice === profile.key ? 'border-primary bg-muted' : 'hover:bg-muted/50'}`}
                      data-selected={state.choice === profile.key}
                      data-soon={soon}
                    >
                      <RadioGroupItem
                        id={id}
                        value={profile.key}
                        aria-labelledby={`${id}-name`}
                        aria-describedby={`${id}-description${soon ? ` ${id}-soon` : ''}`}
                      />
                      <div className="min-w-0 space-y-2">
                        <span id={`${id}-name`} className="text-base font-medium">
                          {label(profile.key)}
                        </span>
                        {soon ? (
                          <Badge variant="outline" id={`${id}-soon`}>
                            {t('setup.comingSoon')}
                          </Badge>
                        ) : null}
                        <p id={`${id}-description`} className="text-sm text-muted-foreground">
                          {t(profileDescriptionKey(profile.key), { defaultValue: '' })}
                        </p>
                      </div>
                    </label>
                  )
                })}
              </div>
            </fieldset>
          ) : null,
        )}
      </RadioGroup>
      {waiting && pending ? (
        <fieldset className="space-y-3 rounded-md border bg-muted p-4">
          <legend>{t('setup.interestPrompt', { name: label(pending.key) })}</legend>
          <div className="flex flex-wrap gap-2">
            <Button
              type="button"
              onClick={() => dispatch({ type: 'answer-interest', sellsGoods: true, profiles })}
            >
              {t('setup.interestYes')}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => dispatch({ type: 'answer-interest', sellsGoods: false, profiles })}
            >
              {t('setup.interestNo')}
            </Button>
          </div>
        </fieldset>
      ) : null}
      {state.declined && pending ? (
        <p role="status">{t('setup.interestDeclined', { name: label(pending.key) })}</p>
      ) : null}
      {state.interests.length ? (
        <div role="status" className="space-y-3">
          <p>{t('setup.interestsRecorded', { names: state.interests.map(label).join(', ') })}</p>
          <ul aria-label={t('setup.interestsList')} className="space-y-2">
            {state.interests.map((key) => (
              <li key={key} className="flex flex-wrap items-center gap-3">
                <span>{label(key)}</span>
                <Button
                  type="button"
                  size="sm"
                  variant="outline"
                  aria-label={t('setup.interestRemove', { name: label(key) })}
                  onClick={() => dispatch({ type: 'remove-interest', key })}
                >
                  {t('setup.interestRemoveShort')}
                </Button>
              </li>
            ))}
          </ul>
        </div>
      ) : null}
    </div>
  )
}
