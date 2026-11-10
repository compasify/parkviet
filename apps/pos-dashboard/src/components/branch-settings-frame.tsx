import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import type { PosModules } from '@parkviet/pos-shared/pos-modules'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, useStore } from '@spree/dashboard-core'
import { Button, Card, CardContent } from '@spree/dashboard-ui'
import { Link, useParams } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchModules } from '../hooks/use-branch-modules'
import { usePosSession } from '../hooks/use-pos-session'
import { useBranches } from '../hooks/use-topology'
import { BranchPicker } from './branch-picker'

export type BranchSettingsScope = {
  branch: PosBranch
  access: { read: boolean; write: boolean }
  storeId: string | null
  modules: PosModules | null
}
export function BranchSettingsFrame({
  section,
  children,
}: {
  section: 'products' | 'labels'
  children: (scope: BranchSettingsScope) => ReactNode
}) {
  const { t } = useTranslation()
  const { context, selection } = usePosSession()
  const { storeId } = useStore()
  const params = useParams({ strict: false }) as { branchId?: string }
  const branchId = params.branchId ?? selection.branchId
  const access = context.data?.administration ?? { read: false, write: false }
  const branches = useBranches(access.read)
  const branch = branches.data?.data.find((row) => row.id === branchId)
  const modules = useBranchModules(access.read ? branchId : null)
  const title = t(section === 'products' ? 'branchProductsTitle' : 'labelFormatsTitle')
  return (
    <div className="space-y-6">
      <PageHeader
        title={branch ? `${title} · ${branch.name}` : title}
        description={t(section === 'products' ? 'branchProductsIntro' : 'labelFormatsIntro')}
        actions={<BranchPicker />}
      />
      {context.isPending ? (
        <p role="status">{t('contextWaiting')}</p>
      ) : context.isError ? (
        <div role="alert">
          {describeFailure(context.error, t)}
          <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
        </div>
      ) : !access.read ? (
        <Card>
          <CardContent className="pt-6">
            <p>{t('forbidden')}</p>
            <p>{t('adminAccessDenied')}</p>
          </CardContent>
        </Card>
      ) : (
        <>
          <nav className="flex flex-wrap gap-2" aria-label={t('branchSettingsSections')}>
            <Button asChild variant="outline">
              <Link to={`/${storeId}/branches` as string}>{t('branchSettingsBack')}</Link>
            </Button>
            {branch && (
              <>
                <Button asChild variant="outline">
                  <Link to={`/${storeId}/branches/${branch.id}/products` as string}>
                    {t('branchProductsTitle')}
                  </Link>
                </Button>
                {(section === 'labels' ||
                  branchSettingVisible({ ...context.data, modules }, 'label-formats')) && (
                  <Button asChild variant="outline">
                    <Link to={`/${storeId}/branches/${branch.id}/label-formats` as string}>
                      {t('labelFormatsTitle')}
                    </Link>
                  </Button>
                )}
              </>
            )}
          </nav>
          {branches.isPending && <p role="status">{t('waiting')}</p>}
          {branches.isError && (
            <div role="alert">
              {describeFailure(branches.error, t)}
              <Button onClick={() => void branches.refetch()}>{t('retry')}</Button>
            </div>
          )}
          {branches.isSuccess && !branch && <p role="alert">{t('branchSettingsMissing')}</p>}
          {branch && children({ branch, access, storeId, modules })}
        </>
      )}
    </div>
  )
}
