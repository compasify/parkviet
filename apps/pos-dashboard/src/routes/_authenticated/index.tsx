import { useAuth } from '@spree/dashboard-core'
import { Button } from '@spree/dashboard-ui'
import { createFileRoute, Navigate } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { preferredStore } from '../../lib/store-selection'
export const Route = createFileRoute('/_authenticated/')({ component: StoreSelection })
function StoreSelection() {
  const { t } = useTranslation()
  const { user, logout } = useAuth()
  if (!user) return null
  const first = preferredStore(user.stores)
  if (first) return <Navigate to="/$storeId" params={{ storeId: first }} replace />
  return (
    <main className="p-6">
      <p>{t('posDashboard.noStore')}</p>
      <Button onClick={() => void logout()}>{t('posDashboard.signOut')}</Button>
    </main>
  )
}
