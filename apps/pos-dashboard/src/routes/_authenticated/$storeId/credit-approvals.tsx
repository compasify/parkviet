import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { CreditApprovalsPage } from '../../../pages/credit-approvals'
export const Route = createFileRoute('/_authenticated/$storeId/credit-approvals')({
  component: () => (
    <PosRouteGuard page="credit-approvals">
      <CreditApprovalsPage />
    </PosRouteGuard>
  ),
})
