import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import { SettingsFieldGroup, SettingsRow, SettingsSection } from '@spree/dashboard-core'
import { Badge, CardContent } from '@spree/dashboard-ui'
import { LayoutGridIcon, ListChecksIcon, MonitorIcon, PrinterIcon } from '@spree/dashboard-ui/icons'
import { Link } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ModelState, modelDate } from '../components/setup/model-ui'
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
    <div className="flex flex-col gap-6" data-testid="hardware-checklist">
      <p className="text-base text-muted-foreground">{t('hardware.intro')}</p>
      <SettingsSection title={t('hardware.checksTitle')} icon={<ListChecksIcon />}>
        <CardContent>
          <SettingsFieldGroup>
            {data.checks.map((check) => (
              <div key={check.key} data-check={check.key} data-status={check.status}>
                <SettingsRow
                  label={t(`hardware.check_${check.key}`)}
                  help={<CheckDetail check={check.key} data={data} />}
                >
                  <div className="flex items-center gap-3">
                    {check.status === 'attention' ? (
                      <Link
                        to={`/${storeId}${FIX_PATHS[check.key](branch.id)}` as string}
                        className="text-sm font-medium underline underline-offset-4"
                      >
                        {t('hardware.fix')}
                      </Link>
                    ) : null}
                    <Badge variant={BADGE[check.status]}>
                      {t(`hardware.status_${check.status}`)}
                    </Badge>
                  </div>
                </SettingsRow>
              </div>
            ))}
          </SettingsFieldGroup>
        </CardContent>
      </SettingsSection>
      <SettingsSection title={t('hardware.printersTitle')} icon={<PrinterIcon />}>
        <CardContent>
          {data.printers.length ? (
            <SettingsFieldGroup>
              {data.printers.map((printer) => (
                <SettingsRow
                  key={printer.id}
                  label={printer.name}
                  help={
                    <>
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
                    </>
                  }
                >
                  <span className="text-sm text-muted-foreground">
                    {printer.roles.map((role) => t(`hardware.role_${role}`, role)).join(', ') ||
                      t('hardware.noRole')}
                  </span>
                </SettingsRow>
              ))}
            </SettingsFieldGroup>
          ) : (
            <p className="text-muted-foreground">{t('hardware.noPrinters')}</p>
          )}
        </CardContent>
      </SettingsSection>
      {data.stations.length ? (
        <SettingsSection title={t('hardware.stationsTitle')} icon={<LayoutGridIcon />}>
          <CardContent>
            <SettingsFieldGroup>
              {data.stations.map((station) => (
                <SettingsRow
                  key={station.id}
                  label={station.name}
                  help={t('hardware.stationDetail', {
                    screens: station.kds_devices,
                    printer: station.printer_id ? t('hardware.yes') : t('hardware.no'),
                  })}
                >
                  <Badge variant={station.ok ? 'default' : 'destructive'}>
                    {t(station.ok ? 'hardware.status_ok' : 'hardware.status_attention')}
                  </Badge>
                </SettingsRow>
              ))}
            </SettingsFieldGroup>
          </CardContent>
        </SettingsSection>
      ) : null}
      {data.devices.length ? (
        <SettingsSection title={t('hardware.devicesTitle')} icon={<MonitorIcon />}>
          <CardContent>
            <SettingsFieldGroup>
              {data.devices.map((device) => (
                <SettingsRow
                  key={device.id}
                  label={device.name}
                  help={
                    <>
                      {t(`hardware.mode_${device.mode}`)} ·{' '}
                      {t('hardware.lastSeen', {
                        at: modelDate(device.last_seen_at, i18n.language, branch.timezone),
                      })}
                    </>
                  }
                >
                  <Badge variant={device.online ? 'default' : 'destructive'}>
                    {t(device.online ? 'hardware.online' : 'hardware.offline')}
                  </Badge>
                </SettingsRow>
              ))}
            </SettingsFieldGroup>
          </CardContent>
        </SettingsSection>
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
