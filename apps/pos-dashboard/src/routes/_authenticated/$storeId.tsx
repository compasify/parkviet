import {
  AppShell,
  AppShellProvider,
  adminClient,
  PermissionProvider,
  StoreProvider,
} from '@spree/dashboard-core'
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
  // Receipt templates keep their settings URL but belong to the main sidebar.
  const inSettings = path.includes('/settings') && !path.includes('/settings/receipt-templates')
  return (
    <PosSessionContext.Provider value={value}>
      <PosNavigation />
      <AppShellProvider>
        <AppShell
          inSettings={inSettings}
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
          <Outlet />
        </AppShell>
      </AppShellProvider>
    </PosSessionContext.Provider>
  )
}
