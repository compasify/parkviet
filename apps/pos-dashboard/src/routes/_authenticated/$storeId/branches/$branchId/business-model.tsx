import { createFileRoute, redirect } from '@tanstack/react-router'
// Earlier URL of this branch setting; it now lives on another tab.
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/business-model')({
  beforeLoad: ({ params }) => {
    throw redirect({ to: '/$storeId/branches/$branchId', params, replace: true })
  },
})
