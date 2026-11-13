import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { PageHeader } from '@spree/dashboard-core'
import { Badge, Button } from '@spree/dashboard-ui'
import { GlobeIcon, ShieldCheckIcon } from '@spree/dashboard-ui/icons'
import type { TFunction } from 'i18next'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { PushRelayCard } from '../components/push-relay-card'
import { ModelCard } from '../components/setup/model-ui'
import { type SystemStatus, useSystemStatus } from '../hooks/use-system-status'

// A nightly backup older than this needs a look (one missed night plus slack).
const BACKUP_STALE_HOURS = 36
// Above this the realtime adapter is slower than the KDS target allows.
const REALTIME_SLOW_MS = 2000

type Row = { key: string; ok: boolean; value: ReactNode }

// The server this store runs on: the address devices pair with, its TLS
// mode, and whether the database, jobs, realtime, printing, outbound work
// and backups are healthy, and the relay for owners' background notifications.
// Store administrators only.
export function SystemStatusPage() {
  const { t } = useTranslation()
  const status = useSystemStatus(true)
  const data = status.data?.data
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('systemStatus.title')}
        description={t('systemStatus.intro')}
        actions={
          <Button
            variant="outline"
            onClick={() => status.refetch()}
            disabled={status.isFetching}
            data-testid="system-status-refresh"
          >
            {t('systemStatus.refresh')}
          </Button>
        }
      />
      {status.isPending ? <p>{t('systemStatus.loading')}</p> : null}
      {status.error ? (
        <p role="alert" className="text-destructive">
          {describeFailure(status.error, t)}
        </p>
      ) : null}
      {data ? (
        <>
          <ServerCard data={data} />
          <HealthCard data={data} />
        </>
      ) : null}
      <PushRelayCard />
    </div>
  )
}

function ServerCard({ data }: { data: SystemStatus }) {
  const { t } = useTranslation()
  const url = data.server.public_base_url
  return (
    <ModelCard title={t('systemStatus.server')} id="system-server" icon={<GlobeIcon />}>
      <dl className="grid gap-x-6 gap-y-3 sm:grid-cols-2">
        <Field label={t('systemStatus.publicUrl')}>
          {url ? (
            <code data-testid="system-public-url">{url}</code>
          ) : (
            <span data-testid="system-public-url">{t('systemStatus.publicUrlUnset')}</span>
          )}
        </Field>
        <Field label={t('systemStatus.tlsMode')}>
          {t(`systemStatus.tls.${data.server.tls_mode}`)}
        </Field>
        <Field label={t('systemStatus.version')}>
          {data.version.app} · Spree {data.version.spree} · Rails {data.version.rails}
        </Field>
        <Field label={t('systemStatus.generatedAt')}>{formatTime(data.generated_at)}</Field>
      </dl>
      <p className="text-sm text-muted-foreground">{t('systemStatus.repairNote')}</p>
    </ModelCard>
  )
}

function HealthCard({ data }: { data: SystemStatus }) {
  const { t } = useTranslation()
  const age = (seconds: number | null) =>
    seconds === null ? '' : ` ${t('systemStatus.oldest', { age: formatAge(seconds, t) })}`
  const backupAgeHours = data.backup.last_at
    ? (Date.parse(data.generated_at) - Date.parse(data.backup.last_at)) / 3_600_000
    : null
  const rows: Row[] = [
    {
      key: 'database',
      ok: data.database.ok,
      value: data.database.ok
        ? t('systemStatus.databaseOk', { ms: data.database.latency_ms })
        : t('systemStatus.unreachable'),
    },
    {
      key: 'jobs',
      ok: data.jobs.ok && !data.jobs.failed,
      value: data.jobs.ok
        ? t('systemStatus.jobsOk', {
            processes: data.jobs.processes,
            ready: data.jobs.ready,
            failed: data.jobs.failed,
          }) + age(data.jobs.oldest_ready_age_seconds)
        : t('systemStatus.jobsDown'),
    },
    {
      key: 'realtime',
      ok: data.realtime.ok && (data.realtime.probe_ms ?? 0) <= REALTIME_SLOW_MS,
      value: data.realtime.ok
        ? t('systemStatus.realtimeOk', {
            ms: data.realtime.probe_ms,
            adapter: data.realtime.adapter,
          })
        : t('systemStatus.unreachable'),
    },
    {
      key: 'printing',
      ok: data.printing.failed_last_24h === 0,
      value:
        t('systemStatus.printingValue', {
          pending: data.printing.pending,
          failed: data.printing.failed_last_24h,
          hours: data.printing.failed_window_hours,
        }) + age(data.printing.oldest_pending_age_seconds),
    },
    {
      key: 'outbound',
      ok: data.outbound.failed === 0,
      value:
        t('systemStatus.outboundValue', {
          pending: data.outbound.pending,
          failed: data.outbound.failed,
        }) + age(data.outbound.oldest_pending_age_seconds),
    },
    {
      key: 'vietqr',
      ok: data.vietqr.unmatched === 0,
      value: data.vietqr.last_received_at
        ? t('systemStatus.vietqrValue', {
            at: formatTime(data.vietqr.last_received_at),
            unmatched: data.vietqr.unmatched,
          })
        : t('systemStatus.vietqrNever'),
    },
    {
      key: 'backup',
      ok: backupAgeHours !== null && backupAgeHours <= BACKUP_STALE_HOURS,
      value: !data.backup.configured
        ? t('systemStatus.backupUnconfigured')
        : data.backup.last_at
          ? t('systemStatus.backupValue', {
              at: formatTime(data.backup.last_at),
              files: data.backup.count,
            })
          : t('systemStatus.backupNone'),
    },
  ]
  return (
    <ModelCard title={t('systemStatus.health')} id="system-health" icon={<ShieldCheckIcon />}>
      <ul className="divide-y">
        {rows.map((row) => (
          <li
            key={row.key}
            data-testid={`system-${row.key}`}
            className="flex flex-wrap items-center justify-between gap-2 py-3"
          >
            <div className="min-w-0">
              <div className="font-medium">{t(`systemStatus.rows.${row.key}`)}</div>
              <div className="text-sm text-muted-foreground break-words">{row.value}</div>
            </div>
            <Badge variant={row.ok ? 'secondary' : 'warning'}>
              {row.ok ? t('systemStatus.ok') : t('systemStatus.attention')}
            </Badge>
          </li>
        ))}
      </ul>
    </ModelCard>
  )
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="min-w-0">
      <dt className="text-sm text-muted-foreground">{label}</dt>
      <dd className="break-words">{children}</dd>
    </div>
  )
}

const formatTime = (iso: string) => new Date(iso).toLocaleString()

function formatAge(seconds: number, t: TFunction) {
  if (seconds < 120) return t('systemStatus.ageSeconds', { count: seconds })
  if (seconds < 7200) return t('systemStatus.ageMinutes', { count: Math.round(seconds / 60) })
  return t('systemStatus.ageHours', { count: Math.round(seconds / 3600) })
}
