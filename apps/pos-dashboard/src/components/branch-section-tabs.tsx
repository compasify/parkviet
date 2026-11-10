import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import { type PageTab, PageTabs, useStore } from '@spree/dashboard-core'
import { useParams } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { useBranchModules } from '../hooks/use-branch-modules'
import { usePosSession } from '../hooks/use-pos-session'

// Sections of one branch's configuration, shown on pages reached through
// /branches/$branchId. Store-level pages are reached from the sidebar instead.
// The current section always shows, even when its module has since been turned off.
export function BranchSectionTabs({ current }: { current: string }) {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const { context } = usePosSession()
  const { branchId } = useParams({ strict: false }) as { branchId?: string }
  const modules = useBranchModules(branchId ?? null)
  if (!branchId) return null
  const base = `/${storeId}/branches/${branchId}`
  const tabs = [
    { key: 'products', label: t('branchProductsTitle') },
    ...(current === 'label-formats' ||
    branchSettingVisible({ ...context.data, modules }, 'label-formats')
      ? [{ key: 'label-formats', label: t('labelFormatsTitle') }]
      : []),
    { key: 'features', label: t('branchFeaturesTitle') },
    { key: 'business-model', label: t('businessModel.title') },
  ]
  return (
    <PageTabs
      className="overflow-x-auto"
      // PageTabs marks the active tab by comparing a concrete pathname, which the
      // router's typed route templates cannot express.
      tabs={tabs.map((tab) => ({ ...tab, to: `${base}/${tab.key}` as PageTab['to'] & string }))}
    />
  )
}
