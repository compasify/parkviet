import { createFileRoute, redirect } from '@tanstack/react-router'
// Earlier URL of this branch setting; it now lives on another tab.
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/label-formats')({
  beforeLoad: ({ params }) => {
    throw redirect({ to: '/$storeId/branches/$branchId/features', params, replace: true })
  },
})
