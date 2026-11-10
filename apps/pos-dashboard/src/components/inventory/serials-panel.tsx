import type { PosSerialUnit } from '@parkviet/pos-shared/traceability'
import { defineTable, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import { Badge, ResourceNameCell, RowActions } from '@spree/dashboard-ui'
import { ShieldAlertIcon, ShieldCheckIcon } from '@spree/dashboard-ui/icons'
import { useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { fetchSerialUnits } from '../../hooks/use-inventory'
import { formatInstant } from '../../lib/format-time'
import { hiddenTimestamps } from '../../tables/columns'
import { HoldDialog, type HoldTarget } from './hold-dialog'
import { variantLabel } from './inventory-helpers'
import { type InventoryScope, type Notice, NoticeLine } from './inventory-shared'

// Serial units of the branch's variants: where each one is and whether it is
// held. In-stock and held units can be quarantined or released.
export function SerialsPanel({ scope }: { scope: InventoryScope }) {
  const { t, i18n } = useTranslation()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))
  const [hold, setHold] = useState<HoldTarget | null>(null)
  const [notice, setNotice] = useState<Notice>(null)

  const tableKey = 'pos-inventory-serials'
  defineTable<PosSerialUnit>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('inventorySerial'),
    emptyMessage: t('inventoryEmpty'),
    columns: [
      {
        key: 'serial',
        label: t('inventorySerial'),
        default: true,
        sortable: false,
        render: (unit) => <ResourceNameCell id={unit.id} name={unit.serial} />,
      },
      {
        key: 'name',
        label: t('orderLineItem'),
        default: true,
        sortable: false,
        render: (unit) => variantLabel(unit),
      },
      {
        key: 'status',
        label: t('inventoryStatus'),
        default: true,
        sortable: false,
        className: 'whitespace-normal',
        render: (unit) => (
          <span className="flex flex-col gap-1">
            <Badge variant={unit.status === 'quarantined' ? 'warning' : 'secondary'}>
              {t(`inventorySerialStatus_${unit.status}`)}
            </Badge>
            {unit.quarantine_reason && (
              <span className="text-xs text-muted-foreground">{unit.quarantine_reason}</span>
            )}
          </span>
        ),
      },
      {
        key: 'branch_id',
        label: t('inventoryLocation'),
        default: true,
        sortable: false,
        render: (unit) =>
          unit.branch_id === scope.branchId
            ? t('inventoryThisBranch')
            : unit.branch_id
              ? t('inventoryOtherBranch')
              : t('inventoryNoBranch'),
      },
      {
        key: 'changed_at',
        label: t('inventoryUpdatedAt'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (unit) => formatInstant(unit.updated_at, i18n.language, scope.timeZone),
      },
      ...hiddenTimestamps<PosSerialUnit>(),
    ],
  })

  return (
    <div className="space-y-4">
      <NoticeLine notice={notice} />
      <ResourceTable<PosSerialUnit>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'inventory', 'serials', scope.branchId, 'table']}
        queryFn={(params: Record<string, unknown>) => fetchSerialUnits(scope.branchId, params)}
        searchParams={search}
        rowActions={(unit) => {
          const release = unit.status === 'quarantined'
          return (
            <RowActions
              actions={[
                {
                  key: release ? 'release' : 'quarantine',
                  label: t(release ? 'inventoryReleaseTitle' : 'inventoryQuarantineTitle', {
                    label: unit.serial,
                  }),
                  icon: release ? (
                    <ShieldCheckIcon className="size-4" />
                  ) : (
                    <ShieldAlertIcon className="size-4" />
                  ),
                  visible: scope.manage && (unit.status === 'in_stock' || release),
                  destructive: !release,
                  onSelect: () => {
                    setNotice(null)
                    setHold({ kind: 'serial_units', id: unit.id, label: unit.serial, release })
                  },
                },
              ]}
            />
          )
        }}
      />
      {hold && (
        <HoldDialog
          branchId={scope.branchId}
          target={hold}
          onClose={() => setHold(null)}
          onDone={(message) => {
            setHold(null)
            setNotice({ text: message, failed: false })
          }}
        />
      )}
    </div>
  )
}
