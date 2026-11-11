import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import { Badge } from '@spree/dashboard-ui'
import { Link } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ModelCard, ModelState, modelDate } from '../components/setup/model-ui'
import {
  type HardwareCheckKey,
  type HardwareCheckStatus,
  type HardwareStatus,
  useHardwareStatus,
} from '../hooks/use-hardware-status'

// Where each check is fixed, relative to the store.
const FIX_PATHS: Record<HardwareCheckKey, (branchId: string) => string> = {
  receipt_printer: (branchId) => `/branches/${branchId}/printing`,
  kitchen_printer: (branchId) => `/branches/${branchId}/printing`,
  cup_label_printer: (branchId) => `/branches/${branchId}/kitchen`,
  kitchen_stations: (branchId) => `/branches/${branchId}/kitchen`,
  print_station: () => '/devices',
  customer_display: () => '/devices',
  server: () => '/settings/system',
  einvoice: () => '/settings/einvoice',
}

const BADGE: Record<HardwareCheckStatus, 'default' | 'destructive' | 'outline'> = {
  ok: 'default',
  attention: 'destructive',
  not_needed: 'outline',
}

// The hardware checklist of one branch. Every line is read from the server
// (printers that printed, stations with a screen or printer, devices seen,
// paired displays, the way out to the internet, e-invoice settings) and
// re-read every 30 seconds.
export function BranchHardwareTab() {
  const { t, i18n } = useTranslation()
  const { branch, storeId } = useBranchScope()
  const status = useHardwareStatus(branch.id)
  if (status.isPending) return <ModelState title={t('waiting')} />
  if (status.isError)
    return (
      <ModelState
        error
        title={t(posFailureKey(status.error))}
        retry={() => void status.refetch()}
      />
    )
  const data = status.data
  return (
    <div className="space-y-6" data-testid="hardware-checklist">
      <p className="text-sm text-muted-foreground">{t('hardware.intro')}</p>
      <ModelCard id="hardware-checks" title={t('hardware.checksTitle')}>
        <ul className="divide-y">
          {data.checks.map((check) => (
            <li
              key={check.key}
              data-check={check.key}
              data-status={check.status}
              className="flex flex-wrap items-start justify-between gap-3 py-3"
            >
              <div className="min-w-0 flex-1">
                <p className="font-medium">{t(`hardware.check_${check.key}`)}</p>
                <p className="text-sm text-muted-foreground">
                  <CheckDetail check={check.key} data={data} />
                </p>
                {check.status === 'attention' ? (
                  <Link
                    to={`/${storeId}${FIX_PATHS[check.key](branch.id)}` as string}
                    className="text-sm underline"
                  >
                    {t('hardware.fix')}
                  </Link>
                ) : null}
              </div>
              <Badge variant={BADGE[check.status]}>{t(`hardware.status_${check.status}`)}</Badge>
            </li>
          ))}
        </ul>
      </ModelCard>
      <ModelCard id="hardware-printers" title={t('hardware.printersTitle')}>
        {data.printers.length ? (
          <ul className="divide-y">
            {data.printers.map((printer) => (
              <li key={printer.id} className="py-2">
                <strong>{printer.name}</strong>{' '}
                <span className="text-sm text-muted-foreground">
                  {printer.roles.map((role) => t(`hardware.role_${role}`, role)).join(', ') ||
                    t('hardware.noRole')}
                </span>
                <p className="text-sm">
                  {printer.last_job_status
                    ? t('hardware.lastJob', {
                        status: t(
                          `hardware.job_${printer.last_job_status}`,
                          printer.last_job_status,
                        ),
                        at: modelDate(printer.last_job_at, i18n.language, branch.timezone),
                      })
                    : t('hardware.neverPrinted')}
                  {printer.last_error ? ` · ${printer.last_error}` : ''}
                </p>
              </li>
            ))}
          </ul>
        ) : (
          <p>{t('hardware.noPrinters')}</p>
        )}
      </ModelCard>
      {data.stations.length ? (
        <ModelCard id="hardware-stations" title={t('hardware.stationsTitle')}>
          <ul className="divide-y">
            {data.stations.map((station) => (
              <li key={station.id} className="flex justify-between gap-3 py-2">
                <span>
                  <strong>{station.name}</strong>{' '}
                  <span className="text-sm text-muted-foreground">
                    {t('hardware.stationDetail', {
                      screens: station.kds_devices,
                      printer: station.printer_id ? t('hardware.yes') : t('hardware.no'),
                    })}
                  </span>
                </span>
                <Badge variant={station.ok ? 'default' : 'destructive'}>
                  {t(station.ok ? 'hardware.status_ok' : 'hardware.status_attention')}
                </Badge>
              </li>
            ))}
          </ul>
        </ModelCard>
      ) : null}
      {data.devices.length ? (
        <ModelCard id="hardware-devices" title={t('hardware.devicesTitle')}>
          <ul className="divide-y">
            {data.devices.map((device) => (
              <li key={device.id} className="flex justify-between gap-3 py-2">
                <span>
                  <strong>{device.name}</strong>{' '}
                  <span className="text-sm text-muted-foreground">
                    {t(`hardware.mode_${device.mode}`)} ·{' '}
                    {t('hardware.lastSeen', {
                      at: modelDate(device.last_seen_at, i18n.language, branch.timezone),
                    })}
                  </span>
                </span>
                <Badge variant={device.online ? 'default' : 'destructive'}>
                  {t(device.online ? 'hardware.online' : 'hardware.offline')}
                </Badge>
              </li>
            ))}
          </ul>
        </ModelCard>
      ) : null}
      <p className="text-sm text-muted-foreground">
        {t('hardware.generatedAt', {
          at: modelDate(data.generated_at, i18n.language, branch.timezone),
        })}
      </p>
    </div>
  )
}

function CheckDetail({ check, data }: { check: HardwareCheckKey; data: HardwareStatus }) {
  const { t } = useTranslation()
  if (check === 'customer_display')
    return <>{t('hardware.detail_customer_display', { count: data.customer_displays.live })}</>
  if (check === 'server')
    return (
      <>
        {t('hardware.detail_server', {
          url: data.server.public_base_url ?? t('hardware.unset'),
          pending: data.server.outbound_pending,
          failed: data.server.outbound_failed,
        })}
      </>
    )
  if (check === 'einvoice')
    return (
      <>
        {t('hardware.detail_einvoice', {
          provider: data.einvoice.provider ?? t('hardware.unset'),
          missing: data.einvoice.missing_fields.join(', ') || '—',
        })}
      </>
    )
  return <>{t(`hardware.detail_${check}`)}</>
}
