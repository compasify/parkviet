import { Card, CardContent, CardHeader, CardTitle } from '@spree/dashboard-ui'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { usePosSession } from '../hooks/use-pos-session'
import { useLocationOptions } from '../hooks/use-topology'
import { BranchBusinessModel } from './business-model'

// What a branch is set up with, and its business model.
export function BranchOverviewTab() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const { branch, access, branchWrite } = useBranchScope()
  const locations = useLocationOptions(access.read)
  const location = (id: string | null | undefined) =>
    id ? (locations.data?.data.find((row) => row.id === id)?.name ?? '—') : null
  const rows: [string, ReactNode][] = [
    ['code', branch.code],
    ['timezone', branch.timezone],
    ['businessDayCutoff', (branch.business_day_cutoff ?? '04:00').slice(0, 5)],
    ...(access.read
      ? ([
          ['stockLocation', location(branch.stock_location_id) ?? '—'],
          [
            'adminReceivingWarehouse',
            location(branch.receiving_stock_location_id) ?? t('adminDefaultWarehouse'),
          ],
        ] as [string, ReactNode][])
      : []),
    ['adminReturnWindow', branch.return_window_days ?? '—'],
    ['adminVarianceThreshold', branch.variance_threshold ?? '—'],
    ['adminAdjustmentThreshold', branch.adjustment_approval_threshold ?? '—'],
    ['adminReceivingNote', branch.receiving_note || '—'],
  ]
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>{t('branchOverviewInfo')}</CardTitle>
        </CardHeader>
        <CardContent>
          <dl className="grid gap-x-6 gap-y-3 sm:grid-cols-2">
            {rows.map(([label, value]) => (
              <div key={label} className="min-w-0">
                <dt className="text-sm text-muted-foreground">{t(label)}</dt>
                <dd className="break-words">{value}</dd>
              </div>
            ))}
          </dl>
        </CardContent>
      </Card>
      <BranchBusinessModel
        key={branch.id}
        branch={{ ...branch, profile_key: branch.profile_key ?? context.data?.profile?.key }}
        storeId={context.data?.store.id ?? null}
        storeWrite={access.write}
        branchWrite={branchWrite}
      />
    </div>
  )
}
