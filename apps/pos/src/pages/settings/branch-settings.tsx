import { Link, useParams } from '@tanstack/react-router';
import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../../components/pos-icon';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import { useBranchModules } from '../../hooks/use-branch-modules';
import { useBranches } from '../../hooks/use-topology';
import { administrationAccess } from '../../lib/pos-administration';
import type { PosBranch } from '../../lib/pos-context';
import type { PosModules } from '../../lib/pos-modules';
import { posFailureKey } from '../../lib/request-failure';
import { branchSettingVisible } from '../../modules/registry';

export type BranchSettingsScope = {
  branch: PosBranch;
  access: { read: boolean; write: boolean };
  storeId: string | null;
  // Modules on at this branch; null when unknown, which hides nothing.
  modules: PosModules | null;
};

const SECTION_TEXT = {
  products: { title: 'branchProductsTitle', intro: 'branchProductsIntro' },
  labels: { title: 'labelFormatsTitle', intro: 'labelFormatsIntro' },
  features: { title: 'branchFeaturesTitle', intro: 'branchFeaturesIntro' },
  model: { title: 'businessModel.title', intro: 'businessModel.intro' },
} as const;

// Frame of the per-branch administration pages. Reading needs the topology read
// permission; every write control below it also checks `access.write`.
export function BranchSettingsFrame({
  section,
  children,
}: {
  section: 'products' | 'labels' | 'features' | 'model';
  children: (scope: BranchSettingsScope) => ReactNode;
}) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const access = administrationAccess(context.data);
  const branchId = useParams({ strict: false }).branchId ?? '';
  const branches = useBranches(access.read);
  const branch = branches.data?.data.find((item) => item.id === branchId);
  const modules = useBranchModules(access.read ? branchId : null);
  // Scale label formats are a `retail.measured` page: not offered at a branch
  // without it, but still shown while it is the page being looked at.
  const labelsLink =
    section === 'labels' || branchSettingVisible({ ...context.data, modules }, 'label-formats');
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
            {labelsLink ? (
              <Link
                className="button-link"
                to="/settings/branches/$branchId/label-formats"
                params={{ branchId }}
                activeProps={linkProps}
              >
                <PosIcon name="list" />
                {t('labelFormatsTitle')}
              </Link>
            ) : null}
            <Link
              className="button-link"
              to="/settings/branches/$branchId/features"
              params={{ branchId }}
              activeProps={linkProps}
            >
              <PosIcon name="cog" />
              {t('branchFeaturesTitle')}
            </Link>
            <Link
              className="button-link"
              to="/settings/branches/$branchId/business-model"
              params={{ branchId }}
              activeProps={linkProps}
            >
              <PosIcon name="grid" />
              {t('businessModel.title')}
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
          {branch
            ? children({ branch, access, storeId: context.data?.store.id ?? null, modules })
            : null}
        </div>
      )}
    </PosPage>
  );
}
