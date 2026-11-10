import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { ShiftClosuresPage } from '../../../../pages/shift-closures'
import { closureSearchSchema } from '../../../../schemas/list-search'
export const Route = createFileRoute('/_authenticated/$storeId/shifts/closures')({
  validateSearch: closureSearchSchema,
  component: () => (
    <PosRouteGuard page="shifts">
      <ShiftClosuresPage />
    </PosRouteGuard>
  ),
})
