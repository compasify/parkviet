import type { PosLot } from '@parkviet/pos-shared/traceability'
import { defineTable, ResourceTable } from '@spree/dashboard-core'
import { Badge, ResourceNameCell, RowActions } from '@spree/dashboard-ui'
import { ShieldAlertIcon, ShieldCheckIcon } from '@spree/dashboard-ui/icons'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { fetchLots } from '../../hooks/use-inventory'
import { inventorySearchSchema, LOT_STATUSES } from '../../schemas/inventory-search'
import { hiddenTimestamps } from '../../tables/columns'
import { FilterSelect } from '../filter-select'
import { HoldDialog, type HoldTarget } from './hold-dialog'
import { quantity, variantLabel } from './inventory-helpers'
import { Expiry, type InventoryScope, type Notice, NoticeLine } from './inventory-shared'

const ALL = 'all'

// Lots at the branch with expiry, stock by state and quarantine. Stock
// keepers put a lot on hold or release it, always with a reason.
export function LotsPanel({ scope }: { scope: InventoryScope }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const search = inventorySearchSchema.parse(useSearch({ strict: false }))
  const [hold, setHold] = useState<HoldTarget | null>(null)
  const [notice, setNotice] = useState<Notice>(null)

  const tableKey = 'pos-inventory-lots'
  defineTable<PosLot>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('inventoryLotCode'),
    emptyMessage: t('inventoryEmpty'),
    columns: [
      {
        key: 'lot_code',
        label: t('inventoryLotCode'),
        default: true,
        sortable: false,
        render: (lot) => <ResourceNameCell id={lot.id} name={lot.lot_code} />,
      },
      {
        key: 'name',
        label: t('orderLineItem'),
        default: true,
        sortable: false,
        render: (lot) => variantLabel(lot),
      },
      {
        key: 'expiry_on',
        label: t('inventoryExpiry'),
        default: true,
        sortable: false,
        render: (lot) => <Expiry value={lot.expiry_on} today={scope.today} />,
      },
      {
        key: 'on_hand',
        label: t('inventoryOnHand'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (lot) => (
          <span className="flex flex-col items-end">
            <span>{quantity(lot.on_hand, lot.base_unit)}</span>
            {lot.quarantined_quantity > 0 && (
              <span className="text-xs text-muted-foreground">
                {t('inventoryQuarantinedQuantity', {
                  quantity: quantity(lot.quarantined_quantity, lot.base_unit),
                })}
              </span>
            )}
          </span>
        ),
      },
      {
        key: 'reserved',
        label: t('inventoryReserved'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (lot) => quantity(lot.reserved, lot.base_unit),
      },
      {
        key: 'committed',
        label: t('inventoryCommitted'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (lot) => quantity(lot.committed, lot.base_unit),
      },
      {
        key: 'available',
        label: t('inventoryAvailable'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (lot) => quantity(lot.available, lot.base_unit),
      },
      {
        key: 'status',
        label: t('inventoryStatus'),
        default: true,
        sortable: false,
        className: 'whitespace-normal',
        render: (lot) => (
          <span className="flex flex-col gap-1">
            <Badge
              variant={
                lot.status === 'active'
                  ? 'secondary'
                  : lot.status === 'quarantined'
                    ? 'warning'
                    : 'destructive'
              }
            >
              {t(`inventoryLotStatus_${lot.status}`)}
            </Badge>
            {lot.quarantine_reason && (
              <span className="text-xs text-muted-foreground">{lot.quarantine_reason}</span>
            )}
          </span>
        ),
      },
      ...hiddenTimestamps<PosLot>(),
    ],
  })

  return (
    <div className="space-y-4">
      <NoticeLine notice={notice} />
      <ResourceTable<PosLot>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'inventory', 'lots', scope.branchId, 'table', search.status ?? ALL]}
        queryFn={(params: Record<string, unknown>) =>
          fetchLots(scope.branchId, search.status, params)
        }
        searchParams={search}
        actions={
          <FilterSelect
            label={t('inventoryStatus')}
            value={search.status ?? ALL}
            options={[
              { value: ALL, label: t('inventoryStatusAll') },
              ...LOT_STATUSES.map((value) => ({
                value,
                label: t(`inventoryLotStatus_${value}`),
              })),
            ]}
            onChange={(value) => {
              const status = LOT_STATUSES.find((known) => known === value)
              void navigate({
                to: '.',
                search: (previous: Record<string, unknown>) => ({ ...previous, status, page: 1 }),
              })
            }}
          />
        }
        rowActions={(lot) => {
          const release = lot.status === 'quarantined'
          return (
            <RowActions
              actions={[
                {
                  key: release ? 'release' : 'quarantine',
                  label: t(release ? 'inventoryReleaseTitle' : 'inventoryQuarantineTitle', {
                    label: lot.lot_code,
                  }),
                  icon: release ? (
                    <ShieldCheckIcon className="size-4" />
                  ) : (
                    <ShieldAlertIcon className="size-4" />
                  ),
                  visible: scope.manage && lot.status !== 'expired',
                  destructive: !release,
                  onSelect: () => {
                    setNotice(null)
                    setHold({ kind: 'lots', id: lot.id, label: lot.lot_code, release })
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
