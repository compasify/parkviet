import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { InventoryPage } from '../../../../pages/inventory'
import { inventorySearchSchema } from '../../../../schemas/inventory-search'
export const Route = createFileRoute('/_authenticated/$storeId/inventory/$tab')({
  validateSearch: inventorySearchSchema,
  component: InventoryTabRoute,
})
function InventoryTabRoute() {
  const { tab } = Route.useParams()
  return (
    <PosRouteGuard page="inventory">
      <InventoryPage tab={tab} />
    </PosRouteGuard>
  )
}
