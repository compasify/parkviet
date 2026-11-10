import {
  AppShell,
  AppShellProvider,
  adminClient,
  PermissionProvider,
  StoreProvider,
} from '@spree/dashboard-core'
import {
  Label,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@spree/dashboard-ui'
import { createFileRoute, Outlet, retainSearchParams, useRouterState } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { PosSessionContext, useCreatePosSession } from '../../hooks/use-pos-session'
import { setActiveStoreId } from '../../lib/active-store'
import { rememberStore } from '../../lib/store-selection'
import { PosNavigation } from '../../nav'

export const Route = createFileRoute('/_authenticated/$storeId')({
  validateSearch: (search: Record<string, unknown>): { branch?: string; register?: string } => ({
    branch: typeof search.branch === 'string' ? search.branch : undefined,
    register: typeof search.register === 'string' ? search.register : undefined,
  }),
  search: { middlewares: [retainSearchParams(['branch', 'register'])] },
  beforeLoad: ({ params }) => {
    adminClient.setStore(params.storeId)
    setActiveStoreId(params.storeId)
    rememberStore(params.storeId)
  },
  component: StoreLayout,
})
function StoreLayout() {
  const { storeId } = Route.useParams()
  return (
    <StoreProvider storeId={storeId}>
      <PermissionProvider>
        <PosShell key={storeId} />
      </PermissionProvider>
    </StoreProvider>
  )
}
function PosShell() {
  const { t } = useTranslation()
  const value = useCreatePosSession()
  const path = useRouterState({ select: (state) => state.location.pathname })
  const branches = value.context.data?.branches ?? []
  return (
    <PosSessionContext.Provider value={value}>
      <PosNavigation />
      <AppShellProvider>
        <AppShell
          inSettings={path.includes('/settings')}
          uiLocales={[
            { code: 'vi', name: 'Tiếng Việt' },
            { code: 'en', name: 'English' },
          ]}
        >
          {value.context.data?.sales_channel &&
            value.context.data.sales_channel.status !== 'active' && (
              <p role="status" className="px-4 pt-4 text-destructive">
                {t(
                  value.context.data.sales_channel.status === 'missing'
                    ? 'pos_channel_missing'
                    : 'pos_channel_inactive',
                )}
              </p>
            )}
          {branches.length > 0 && (
            <div className="flex max-w-sm flex-col gap-2 px-4 pt-4">
              <Label htmlFor="pos-shell-branch">{t('posDashboard.branch')}</Label>
              <Select
                value={value.selection.branchId ?? ''}
                onValueChange={(branchId) => value.setSelection({ branchId, registerId: null })}
              >
                <SelectTrigger id="pos-shell-branch">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {branches.map((branch) => (
                    <SelectItem key={branch.id} value={branch.id}>
                      {branch.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}
          <Outlet />
        </AppShell>
      </AppShellProvider>
    </PosSessionContext.Provider>
  )
}
