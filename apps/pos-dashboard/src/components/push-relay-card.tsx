import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import {
  Button,
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  Input,
  Label,
  useConfirm,
} from '@spree/dashboard-ui'
import { type FormEvent, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  type PushRelay,
  RELAY_KEY_RANGE,
  relayInputProblem,
  usePushRelay,
  usePushRelayWrite,
} from '../hooks/use-push-relay'
import { ModelNotice, ModelState } from './setup/model-ui'

type Notice = { text: string; failed: boolean } | null

// Background notifications for owners' phones go through a relay the store
// names here: an HTTPS address and the key requests to it are signed with.
// Notifications carry only the kind of event and an id. Without a relay the
// owner app hears events only while it is open; nothing else changes.
export function PushRelayCard() {
  const { t } = useTranslation()
  const relay = usePushRelay()
  return (
    <Card data-testid="push-relay-card">
      <CardHeader>
        <CardTitle>{t('pushRelay.title')}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <p className="text-sm text-muted-foreground">{t('pushRelay.intro')}</p>
        {relay.isPending ? (
          <ModelState title={t('waiting')} />
        ) : relay.isError ? (
          <ModelState
            error
            title={t(posFailureKey(relay.error))}
            retry={() => void relay.refetch()}
          />
        ) : (
          <PushRelayForm key={relay.dataUpdatedAt} relay={relay.data} />
        )}
      </CardContent>
    </Card>
  )
}

function PushRelayForm({ relay }: { relay: PushRelay | null }) {
  const { t, i18n } = useTranslation()
  const write = usePushRelayWrite()
  const confirm = useConfirm()
  const urlId = useId()
  const keyId = useId()
  const [url, setUrl] = useState(relay?.url ?? '')
  const [key, setKey] = useState('')
  const [notice, setNotice] = useState<Notice>(null)
  const problem = relayInputProblem(url, key, relay?.key_set ?? false)
  const busy = write.isPending
  const when = (at: string) => new Date(at).toLocaleString(i18n.language)

  const run = async (action: () => Promise<unknown>, done: string) => {
    setNotice(null)
    try {
      await action()
      setNotice({ text: t(done), failed: false })
    } catch (failure) {
      setNotice({
        text:
          conflictReason(failure) === 'push_relay_unreachable'
            ? t('pushRelay.unreachable')
            : describeFailure(failure, t),
        failed: true,
      })
    }
  }

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (problem) return
    void run(async () => {
      await write.mutateAsync({
        method: 'PUT',
        path: '/pos/push_relay_settings',
        body: { url: url.trim(), ...(key.trim() ? { key: key.trim() } : {}) },
      })
      setKey('')
    }, 'saved')
  }

  const remove = async () => {
    if (
      !(await confirm({
        message: t('pushRelay.removeConfirm'),
        variant: 'destructive',
        confirmLabel: t('pushRelay.remove'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await run(
      () => write.mutateAsync({ method: 'DELETE', path: '/pos/push_relay_settings' }),
      'pushRelay.removed',
    )
  }

  return (
    <div className="space-y-4">
      <p className="text-sm" data-testid="push-relay-status">
        {!relay
          ? t('pushRelay.off')
          : relay.last_error && relay.last_error_at
            ? t('pushRelay.lastError', { error: relay.last_error, at: when(relay.last_error_at) })
            : relay.last_delivered_at
              ? t('pushRelay.lastDelivered', { at: when(relay.last_delivered_at) })
              : t('pushRelay.notChecked')}
      </p>
      <form className="space-y-4" onSubmit={save} aria-busy={busy}>
        <div className="space-y-1">
          <Label htmlFor={urlId}>{t('pushRelay.url')}</Label>
          <Input
            id={urlId}
            value={url}
            placeholder="https://"
            autoComplete="off"
            aria-invalid={url.trim() !== '' && problem === 'url'}
            onChange={(event) => setUrl(event.target.value)}
          />
        </div>
        <div className="space-y-1">
          <Label htmlFor={keyId}>{t('pushRelay.key')}</Label>
          <Input
            id={keyId}
            type="password"
            value={key}
            autoComplete="new-password"
            aria-invalid={key.trim() !== '' && problem === 'key'}
            onChange={(event) => setKey(event.target.value)}
          />
          <p className="text-xs text-muted-foreground">
            {relay?.key_set ? t('pushRelay.keyKept') : t('pushRelay.keyHint', RELAY_KEY_RANGE)}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button type="submit" disabled={busy || problem !== null} data-testid="push-relay-save">
            {t('save')}
          </Button>
          {relay ? (
            <>
              <Button
                type="button"
                variant="outline"
                disabled={busy}
                data-testid="push-relay-check"
                onClick={() =>
                  void run(
                    () =>
                      write.mutateAsync({ method: 'POST', path: '/pos/push_relay_settings/check' }),
                    'pushRelay.checked',
                  )
                }
              >
                {t('pushRelay.check')}
              </Button>
              <Button type="button" variant="outline" disabled={busy} onClick={() => void remove()}>
                {t('pushRelay.remove')}
              </Button>
            </>
          ) : null}
        </div>
      </form>
      <ModelNotice notice={notice} />
    </div>
  )
}
