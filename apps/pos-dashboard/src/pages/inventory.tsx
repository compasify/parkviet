import { contextFeature } from '@parkviet/pos-shared/pos-features'
import { contextModule, moduleInUse, moduleTextKey } from '@parkviet/pos-shared/pos-modules'
import {
  canManageInventory,
  type InventoryTab,
  inventoryTabs,
} from '@parkviet/pos-shared/traceability'
import type { PosContext } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, type PageTab, PageTabs } from '@spree/dashboard-core'
import { Navigate } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { AdjustPanel } from '../components/inventory/adjust-panel'
import { todayIn } from '../components/inventory/inventory-helpers'
import type { InventoryScope } from '../components/inventory/inventory-shared'
import { LotsPanel } from '../components/inventory/lots-panel'
import { RecallPanel } from '../components/inventory/recall-panel'
import { ReceivePanel } from '../components/inventory/receive-panel'
import { SerialsPanel } from '../components/inventory/serials-panel'
import { TransferPanel } from '../components/inventory/transfer-panel'
import { VariantsPanel } from '../components/inventory/variants-panel'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { branchTimeZone } from '../lib/format-time'

const MODULE = 'retail.traceability'

// The tabs the member may open at the selected branch. Receiving needs the
// traceability module on, or tracked stock still in use after it was turned
// off; the server refuses new setup itself.
export function visibleInventoryTabs(context: PosContext | undefined): InventoryTab[] {
  const tracked = contextModule(context, MODULE) || moduleInUse(context, MODULE)
  return inventoryTabs(context?.capabilities).filter((tab) => tab !== 'receive' || tracked)
}

// "/inventory" opens the first tab the member may use.
export function InventoryIndex() {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const first = visibleInventoryTabs(context.data)[0]
  if (!first) return <p className="text-muted-foreground">{t('inventoryForbidden')}</p>
  return <Navigate to="/$storeId/inventory/$tab" params={{ storeId, tab: first }} replace />
}

// "Truy xuất tồn kho": serial and lot stock of the selected branch, its
// receipts, transfers, counts with their approvals, and recall tracing.
export function InventoryPage({ tab }: { tab: string }) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const data = context.data
  const capabilities = data?.capabilities ?? []
  const branchId = data?.selection.branch_id ?? null
  const tabs = visibleInventoryTabs(data)
  const current = tabs.find((value) => value === tab)
  if (!current) return <InventoryIndex />

  // The branch feature gates enrolling stock into serial/lot tracking
  // (opening balances); stock already tracked keeps its receive, transfer
  // and count. The module gates the same setup.
  const traceOn = contextFeature(data, 'traceability')
  const moduleOn = contextModule(data, MODULE)
  const manage = canManageInventory(capabilities)
  const timeZone = branchTimeZone(data)
  const scope: InventoryScope | null = branchId
    ? {
        branchId,
        staffId: data?.staff.id ?? null,
        capabilities,
        manage,
        enroll: manage && traceOn && moduleOn,
        today: todayIn(timeZone),
        timeZone,
      }
    : null
  const moduleText = moduleTextKey(MODULE)
  const base = `/${storeId}/inventory`

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('inventoryTitle')}
        description={t('inventoryHint')}
        actions={<BranchPicker />}
      />
      <PageTabs
        className="overflow-x-auto"
        tabs={tabs.map((value) => ({
          key: value,
          label: t(`inventoryTab_${value}`),
          to: `${base}/${value}` as PageTab['to'] & string,
        }))}
      />
      {!moduleOn ? (
        <p role="note" className="text-sm text-muted-foreground" data-module={MODULE}>
          {t(moduleText ? `posModules.${moduleText}.off` : 'moduleOff')}
        </p>
      ) : manage && !traceOn ? (
        <p role="note" className="text-sm text-muted-foreground" data-feature="traceability">
          {t('featureOff_traceability')}
        </p>
      ) : null}
      {scope ? (
        <div key={`${scope.branchId}:${current}`}>
          {current === 'variants' && <VariantsPanel scope={scope} />}
          {current === 'lots' && <LotsPanel scope={scope} />}
          {current === 'serials' && <SerialsPanel scope={scope} />}
          {current === 'receive' && <ReceivePanel scope={scope} />}
          {current === 'transfer' && <TransferPanel scope={scope} />}
          {current === 'adjust' && <AdjustPanel scope={scope} />}
          {current === 'recall' && <RecallPanel scope={scope} />}
        </div>
      ) : (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      )}
    </div>
  )
}
