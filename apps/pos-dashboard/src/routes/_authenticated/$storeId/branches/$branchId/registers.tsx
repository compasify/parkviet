import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { KioskSettingsCard } from '../../../../../components/kiosk-settings-card'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { TopologyPage } from '../../../../../pages/topology'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/registers')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="registers">
      <div className="space-y-6">
        <TopologyPage kind="registers" branchId={Route.useParams().branchId} />
        <KioskSettingsCard />
      </div>
    </PosRouteGuard>
  ),
})
