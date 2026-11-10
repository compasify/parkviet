import { PageHeader, useSettingsNav, useStore } from '@spree/dashboard-core'
import { Button } from '@spree/dashboard-ui'
import { createFileRoute, Link } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
export const Route = createFileRoute('/_authenticated/$storeId/settings/')({ component: Settings })
function Settings() {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const { all } = useSettingsNav()
  return (
    <div className="p-6">
      <PageHeader title={t('storeSettings')} />
      <div className="flex flex-col items-start gap-3">
        {all.map((entry) => (
          <Button key={entry.key} variant="outline" asChild>
            <Link
              to={
                entry.key === 'setup'
                  ? '/$storeId/settings/setup'
                  : entry.key === 'store-model'
                    ? '/$storeId/settings/business-model'
                    : '/$storeId/settings/receipt-templates'
              }
              params={{ storeId }}
            >
              {t(entry.labelKey ?? entry.label ?? entry.key)}
            </Link>
          </Button>
        ))}
      </div>
    </div>
  )
}
