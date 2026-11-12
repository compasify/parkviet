import { describeFailure, posFailureKey } from '@parkviet/pos-shared/request-failure'
import { Badge, Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { type FormEvent, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  KIOSK_IDLE_RANGE,
  KIOSK_QR_TIMEOUT_RANGE,
  type KioskRow,
  type KioskSettings,
  secondsWithin,
  useKioskSettings,
  useKioskWrite,
} from '../hooks/use-kiosk-settings'
import { useBranchScope } from './branch-detail'
import { ModelCard, ModelCheck, ModelNotice, ModelState, modelDate } from './setup/model-ui'

type Notice = { text: string; failed: boolean } | null

// The branch's self-ordering kiosks: how they behave, and each kiosk register
// with its paired device and its shift. A kiosk takes orders only on a shift
// a manager opens here; the shift holds no cash and closes on a zero count.
// Pair a kiosk from the devices page with mode "kiosk" and a kiosk register.
export function KioskSettingsCard() {
  const { t } = useTranslation()
  const { branch, modules } = useBranchScope()
  const enabled = modules?.['fnb.kiosk'] === true
  const settings = useKioskSettings(branch.id, enabled)
  if (!enabled) return null
  return (
    <ModelCard title={t('kiosk.title')} id="branch-kiosks">
      <p className="text-sm text-muted-foreground">{t('kiosk.intro')}</p>
      {settings.isPending ? (
        <ModelState title={t('waiting')} />
      ) : settings.isError ? (
        <ModelState
          error
          title={t(posFailureKey(settings.error))}
          retry={() => void settings.refetch()}
        />
      ) : (
        <KioskSettingsForm key={settings.dataUpdatedAt} settings={settings.data} />
      )}
    </ModelCard>
  )
}

function KioskSettingsForm({ settings }: { settings: KioskSettings }) {
  const { t, i18n } = useTranslation()
  const { branch } = useBranchScope()
  const write = useKioskWrite()
  const confirm = useConfirm()
  const idleId = useId()
  const qrId = useId()
  const [idle, setIdle] = useState(String(settings.kiosk_idle_seconds))
  const [qrTimeout, setQrTimeout] = useState(String(settings.kiosk_qr_timeout_seconds))
  const [kitchen, setKitchen] = useState(settings.kiosk_kitchen_before_payment)
  const [notice, setNotice] = useState<Notice>(null)
  const idleSeconds = secondsWithin(idle, KIOSK_IDLE_RANGE)
  const qrSeconds = secondsWithin(qrTimeout, KIOSK_QR_TIMEOUT_RANGE)
  const busy = write.isPending

  const run = async (action: () => Promise<unknown>, done: string) => {
    setNotice(null)
    try {
      await action()
      setNotice({ text: t(done), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    }
  }

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (idleSeconds === null || qrSeconds === null) return
    void run(
      () =>
        write.mutateAsync({
          method: 'PUT',
          path: '/pos/kiosk_settings',
          body: {
            branch_id: branch.id,
            kiosk_idle_seconds: idleSeconds,
            kiosk_qr_timeout_seconds: qrSeconds,
            kiosk_kitchen_before_payment: kitchen,
          },
        }),
      'saved',
    )
  }

  const toggleShift = async (kiosk: KioskRow) => {
    if (
      kiosk.shift_open &&
      !(await confirm({
        message: t('kiosk.closeConfirm', { name: kiosk.register_name }),
        variant: 'destructive',
        confirmLabel: t('kiosk.closeShift'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await run(
      () =>
        write.mutateAsync({
          method: 'POST',
          path: `/pos/kiosks/${kiosk.register_id}/shift${kiosk.shift_open ? '/close' : ''}`,
        }),
      kiosk.shift_open ? 'kiosk.shiftClosed' : 'kiosk.shiftOpened',
    )
  }

  return (
    <div className="space-y-5">
      <form className="space-y-4" onSubmit={save} aria-busy={busy}>
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-1">
            <Label htmlFor={idleId}>{t('kiosk.idle')}</Label>
            <Input
              id={idleId}
              inputMode="numeric"
              value={idle}
              aria-invalid={idleSeconds === null}
              onChange={(event) => setIdle(event.target.value)}
            />
            <p className="text-xs text-muted-foreground">{t('kiosk.idleHint', KIOSK_IDLE_RANGE)}</p>
          </div>
          <div className="space-y-1">
            <Label htmlFor={qrId}>{t('kiosk.qrTimeout')}</Label>
            <Input
              id={qrId}
              inputMode="numeric"
              value={qrTimeout}
              aria-invalid={qrSeconds === null}
              onChange={(event) => setQrTimeout(event.target.value)}
            />
            <p className="text-xs text-muted-foreground">
              {t('kiosk.qrTimeoutHint', KIOSK_QR_TIMEOUT_RANGE)}
            </p>
          </div>
        </div>
        <ModelCheck
          checked={kitchen}
          onChange={setKitchen}
          description={t('kiosk.kitchenBeforePaymentHint')}
        >
          {t('kiosk.kitchenBeforePayment')}
        </ModelCheck>
        <Button
          type="submit"
          disabled={busy || idleSeconds === null || qrSeconds === null}
          data-testid="kiosk-settings-save"
        >
          {t('save')}
        </Button>
      </form>
      {settings.kiosks.length === 0 ? (
        <p className="text-sm text-muted-foreground">{t('kiosk.none')}</p>
      ) : (
        <ul className="divide-y" data-testid="kiosk-list">
          {settings.kiosks.map((kiosk) => (
            <li
              key={kiosk.register_id}
              data-kiosk={kiosk.register_id}
              className="flex flex-wrap items-start justify-between gap-3 py-3"
            >
              <div className="space-y-1">
                <p className="font-medium">
                  {kiosk.register_name}{' '}
                  <Badge variant={kiosk.shift_open ? 'default' : 'outline'}>
                    {t(kiosk.shift_open ? 'kiosk.open' : 'kiosk.paused')}
                  </Badge>
                </p>
                <p className="text-sm text-muted-foreground">
                  {kiosk.provisioned && kiosk.device_name
                    ? t('kiosk.device', {
                        name: kiosk.device_name,
                        seen: kiosk.device_seen_at
                          ? modelDate(kiosk.device_seen_at, i18n.language, branch.timezone)
                          : t('kiosk.neverSeen'),
                      })
                    : t('kiosk.unpaired')}
                </p>
                {kiosk.shift_open && kiosk.shift_opened_at ? (
                  <p className="text-sm text-muted-foreground">
                    {t('kiosk.shiftSince', {
                      at: modelDate(kiosk.shift_opened_at, i18n.language, branch.timezone),
                    })}
                  </p>
                ) : null}
                {kiosk.waiting_orders > 0 ? (
                  <p className="text-sm">{t('kiosk.waiting', { count: kiosk.waiting_orders })}</p>
                ) : null}
              </div>
              <Button
                type="button"
                variant={kiosk.shift_open ? 'outline' : 'default'}
                disabled={busy || (!kiosk.shift_open && !kiosk.provisioned)}
                data-testid={`kiosk-shift-${kiosk.register_id}`}
                onClick={() => void toggleShift(kiosk)}
              >
                {t(kiosk.shift_open ? 'kiosk.closeShift' : 'kiosk.openShift')}
              </Button>
            </li>
          ))}
        </ul>
      )}
      <ModelNotice notice={notice} />
    </div>
  )
}
