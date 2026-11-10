import { createFileRoute } from '@tanstack/react-router'
import { BranchTabRedirect } from '../../../lib/route-access'
export const Route = createFileRoute('/_authenticated/$storeId/business-model')({
  component: () => <BranchTabRedirect tab="overview" />,
})
