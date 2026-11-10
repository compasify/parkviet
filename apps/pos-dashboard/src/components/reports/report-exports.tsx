import { failureStatus } from '@parkviet/pos-shared/request-failure'
import { describeShiftFailure } from '@parkviet/pos-shared/shifts'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@spree/dashboard-ui'
import { DownloadIcon } from '@spree/dashboard-ui/icons'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { exportDownloadLink, useExports } from '../../hooks/use-reports'
import { formatInstant } from '../../lib/format-time'
import { startDownload } from '../../lib/report-download'

// The reader's own CSV exports of the branch. Files already made stay
// downloadable until they expire, even when new exports are switched off.
export function ReportExports({ branchId, timeZone }: { branchId: string; timeZone: string }) {
  const { t, i18n } = useTranslation()
  const exports = useExports(branchId, true)
  const [error, setError] = useState('')

  async function download(id: string) {
    setError('')
    try {
      const link = await exportDownloadLink(id)
      startDownload(link.url, link.filename)
    } catch (failure) {
      if (failureStatus(failure) === 410) {
        setError(t('reportExportExpired'))
        void exports.refetch()
        return
      }
      setError(describeShiftFailure(failure, t))
    }
  }

  const rows = exports.data?.data ?? []
  return (
    <section aria-label={t('reportExports')}>
      <Card>
        <CardHeader>
          <CardTitle>{t('reportExports')}</CardTitle>
          <CardDescription>{t('reportExportsHint')}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {exports.isError && (
            <p role="alert" className="text-sm text-destructive">
              {describeShiftFailure(exports.error, t)}
            </p>
          )}
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          <ul className="divide-y" aria-label={t('reportExports')}>
            {rows.map((row) => {
              const expired = row.status === 'expired' || Date.parse(row.expires_at) <= Date.now()
              const status = expired ? 'expired' : row.status
              return (
                <li key={row.id} className="flex flex-wrap items-center gap-3 py-2">
                  <div className="min-w-0 flex-1">
                    <p className="font-medium">{t(`reportTab_${row.report_type}`)}</p>
                    <p className="text-sm text-muted-foreground">
                      {[row.filters.from, row.filters.to].filter(Boolean).join(' – ')} ·{' '}
                      {t('reportExpires', {
                        time: formatInstant(row.expires_at, i18n.language, timeZone),
                      })}
                    </p>
                  </div>
                  <Badge
                    variant={
                      status === 'failed' || status === 'expired'
                        ? 'warning'
                        : status === 'ready'
                          ? 'success'
                          : 'secondary'
                    }
                  >
                    {t(`reportExportStatus_${status}`)}
                    {row.row_count != null ? ` · ${t('reportRows', { count: row.row_count })}` : ''}
                  </Badge>
                  {status === 'ready' && (
                    <Button variant="outline" size="sm" onClick={() => void download(row.id)}>
                      <DownloadIcon className="size-4" />
                      {t('reportDownload')}
                    </Button>
                  )}
                </li>
              )
            })}
          </ul>
        </CardContent>
      </Card>
    </section>
  )
}
