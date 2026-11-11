import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { MenuPage } from '../../../pages/menu'
export const Route = createFileRoute('/_authenticated/$storeId/menu')({
  component: () => (
    <PosRouteGuard page="menu">
      <MenuPage />
    </PosRouteGuard>
  ),
})
