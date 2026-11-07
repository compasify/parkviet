import { Link, useParams } from '@tanstack/react-router';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../../components/pos-icon';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import { useBranches } from '../../hooks/use-topology';
import { administrationAccess } from '../../lib/pos-administration';
import type { PosBranch } from '../../lib/pos-context';
import { posFailureKey } from '../../lib/request-failure';

export type BranchSettingsScope = {
  branch: PosBranch;
  access: { read: boolean; write: boolean };
  storeId: string | null;
};

const SECTION_TEXT = {
  products: { title: 'branchProductsTitle', intro: 'branchProductsIntro' },
  labels: { title: 'labelFormatsTitle', intro: 'labelFormatsIntro' },
  features: { title: 'branchFeaturesTitle', intro: 'branchFeaturesIntro' },
} as const;

// Frame of the per-branch administration pages. Reading needs the topology read
// permission; every write control below it also checks `access.write`.
export function BranchSettingsFrame({
  section,
  children,
}: {
  section: 'products' | 'labels' | 'features';
  children: (scope: BranchSettingsScope) => ReactNode;
}) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const access = administrationAccess(context.data);
  const branchId = useParams({ strict: false }).branchId ?? '';
  const branches = useBranches(access.read);
  const branch = branches.data?.data.find((item) => item.id === branchId);
  const title = t(SECTION_TEXT[section].title);
  const linkProps = { className: 'is-active', 'aria-current': 'page' } as const;
  return (
    <PosPage
      title={branch ? `${title} · ${branch.name}` : title}
      description={t(SECTION_TEXT[section].intro)}
    >
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !access.read ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <div className="pos-administration">
          <nav className="admin-branch-nav" aria-label={t('branchSettingsSections')}>
            <Link className="button-link" to="/settings">
              <PosIcon name="back" />
              {t('branchSettingsBack')}
            </Link>
            <Link
              className="button-link"
              to="/settings/branches/$branchId/products"
              params={{ branchId }}
              activeProps={linkProps}
            >
              <PosIcon name="box" />
              {t('branchProductsTitle')}
            </Link>
            <Link
              className="button-link"
              to="/settings/branches/$branchId/label-formats"
              params={{ branchId }}
              activeProps={linkProps}
            >
              <PosIcon name="list" />
              {t('labelFormatsTitle')}
            </Link>
            <Link
              className="button-link"
              to="/settings/branches/$branchId/features"
              params={{ branchId }}
              activeProps={linkProps}
            >
              <PosIcon name="cog" />
              {t('branchFeaturesTitle')}
            </Link>
          </nav>
          {branches.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
          {branches.isError ? (
            <PageState kind="error" title={t(posFailureKey(branches.error))}>
              <button type="button" onClick={() => void branches.refetch()}>
                {t('retry')}
              </button>
            </PageState>
          ) : null}
          {branches.isSuccess && !branch ? (
            <PageState kind="error" title={t('branchSettingsMissing')} />
          ) : null}
          {branch ? children({ branch, access, storeId: context.data?.store.id ?? null }) : null}
        </div>
      )}
    </PosPage>
  );
}
