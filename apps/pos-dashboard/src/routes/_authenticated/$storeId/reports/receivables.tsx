import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { ReportsPage } from '../../../../pages/reports'
import { reportSearchSchema } from '../../../../schemas/report-search'
export const Route = createFileRoute('/_authenticated/$storeId/reports/receivables')({
  validateSearch: reportSearchSchema,
  component: () => (
    <PosRouteGuard page="reports">
      <ReportsPage type="receivables" />
    </PosRouteGuard>
  ),
})
