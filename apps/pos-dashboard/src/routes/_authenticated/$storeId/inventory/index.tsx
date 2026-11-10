import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { InventoryIndex } from '../../../../pages/inventory'
export const Route = createFileRoute('/_authenticated/$storeId/inventory/')({
  component: () => (
    <PosRouteGuard page="inventory">
      <InventoryIndex />
    </PosRouteGuard>
  ),
})
