import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../../components/pos-icon';
import { PageState } from '../../components/pos-page';
import { VariantUnitEditor } from '../../components/variant-unit-editor';
import {
  type AssignmentFilter,
  assignBranchProduct,
  type BranchProduct,
  removeBranchProduct,
  useBranchProducts,
} from '../../hooks/use-branch-catalog';
import { queryClient } from '../../lib/query-client';
import { describeFailure, posFailureKey } from '../../lib/request-failure';
import { BranchSettingsFrame, type BranchSettingsScope } from './branch-settings';

export function BranchProductsPage() {
  return (
    <BranchSettingsFrame section="products">
      {(scope) => <BranchProducts key={scope.branch.id} {...scope} />}
    </BranchSettingsFrame>
  );
}

function BranchProducts({ branch, access, storeId }: BranchSettingsScope) {
  const { t } = useTranslation();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [assigned, setAssigned] = useState<AssignmentFilter>('all');
  const [page, setPage] = useState(1);
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const [unitProduct, setUnitProduct] = useState<BranchProduct | null>(null);
  const products = useBranchProducts(branch.id, { q: query, assigned, page }, access.read);
  useEffect(() => {
    const timer = window.setTimeout(() => {
      setQuery(input.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [input]);
  const rows = products.data?.data ?? [];
  const pages = Math.max(1, products.data?.meta.pages ?? 1);
  const lastPage = products.isSuccess ? pages : null;
  // Removing the last rows of the last page under a filter shrinks the list.
  useEffect(() => {
    if (lastPage !== null) setPage((current) => Math.min(current, lastPage));
  }, [lastPage]);

  async function toggle(product: BranchProduct) {
    if (!access.write || pendingId) return;
    setPendingId(product.id);
    setNotice(null);
    try {
      if (product.assigned) await removeBranchProduct(branch.id, product.id);
      else await assignBranchProduct(branch.id, product.id);
      setNotice({
        text: t(product.assigned ? 'branchProductRemoved' : 'branchProductAdded', {
          name: product.name,
        }),
        failed: false,
      });
    } catch (error) {
      setNotice({
        text: t('branchProductFailed', { name: product.name, reason: describeFailure(error, t) }),
        failed: true,
      });
    } finally {
      setPendingId(null);
      // The server is the authority on the assortment either way; the sale
      // screen's catalog depends on it too.
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['pos', 'branch-products'] }),
        queryClient.invalidateQueries({ queryKey: ['pos', 'catalog'] }),
      ]);
    }
  }

  return (
    <section className="page-card admin-content" aria-labelledby="branch-products-heading">
      <div className="section-heading">
        <div>
          <h2 id="branch-products-heading">{t('branchProductsTitle')}</h2>
          <p>{t(access.write ? 'branchProductsHint' : 'branchProductsReadOnly')}</p>
        </div>
      </div>
      <form
        className="admin-filters"
        onSubmit={(event) => {
          event.preventDefault();
          setQuery(input.trim());
          setPage(1);
        }}
      >
        <label className="admin-search">
          {t('branchProductsSearch')}
          <input
            aria-label={t('branchProductsSearch')}
            type="search"
            maxLength={100}
            value={input}
            placeholder={t('branchProductsSearchPlaceholder')}
            onChange={(event) => setInput(event.target.value)}
          />
        </label>
        <label>
          {t('branchProductsFilter')}
          <select
            aria-label={t('branchProductsFilter')}
            value={assigned}
            onChange={(event) => {
              setAssigned(event.target.value as AssignmentFilter);
              setPage(1);
            }}
          >
            <option value="all">{t('branchProductsFilterAll')}</option>
            <option value="assigned">{t('branchProductsFilterAssigned')}</option>
            <option value="unassigned">{t('branchProductsFilterUnassigned')}</option>
          </select>
        </label>
      </form>
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      {products.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
      {products.isError ? (
        <PageState kind="error" title={t(posFailureKey(products.error))}>
          <p>{describeFailure(products.error, t)}</p>
          <button type="button" onClick={() => void products.refetch()}>
            {t('retry')}
          </button>
        </PageState>
      ) : null}
      {products.isSuccess && rows.length === 0 ? (
        <PageState title={t('adminNoResults')}>
          <p>{t('branchProductsEmpty')}</p>
        </PageState>
      ) : null}
      <ul
        className="admin-records"
        aria-label={t('branchProductList')}
        aria-busy={products.isFetching}
      >
        {rows.map((product) => {
          const busy = pendingId === product.id;
          return (
            <li key={product.id}>
              <div className="admin-record-copy">
                <strong>{product.name}</strong>
                <small>
                  {product.skus.length
                    ? `${t('itemSkuColumn')}: ${product.skus.join(', ')}`
                    : t('branchProductNoSku')}
                </small>
                {product.status !== 'active' ? (
                  <small>{t('branchProductStatus', { status: product.status })}</small>
                ) : null}
              </div>
              <span className="status-tag" data-warning={!product.assigned}>
                {t(product.assigned ? 'branchProductAssigned' : 'branchProductUnassigned')}
              </span>
              <div className="admin-record-actions">
                {product.assigned ? (
                  <button
                    type="button"
                    aria-label={t('branchProductUnitsFor', { name: product.name })}
                    onClick={() => setUnitProduct(product)}
                  >
                    <PosIcon name="settings" />
                    {t('branchProductUnits')}
                  </button>
                ) : null}
                {access.write ? (
                  <button
                    type="button"
                    className={product.assigned ? 'danger-button' : 'primary-button'}
                    aria-label={t(
                      product.assigned ? 'branchProductRemoveFor' : 'branchProductAddFor',
                      { name: product.name },
                    )}
                    aria-busy={busy}
                    disabled={Boolean(pendingId)}
                    onClick={() => void toggle(product)}
                  >
                    <PosIcon name={product.assigned ? 'minus' : 'plus'} />
                    {busy
                      ? t('waiting')
                      : t(product.assigned ? 'branchProductRemove' : 'branchProductAdd')}
                  </button>
                ) : null}
              </div>
            </li>
          );
        })}
      </ul>
      <nav className="admin-pagination" aria-label={t('branchProductsPages')}>
        <button
          type="button"
          disabled={page <= 1 || products.isFetching}
          onClick={() => setPage((current) => Math.max(1, current - 1))}
        >
          {t('previousPage')}
        </button>
        <span aria-live="polite">
          {t('branchProductsPageStatus', {
            page,
            pages,
            count: products.data?.meta.count ?? 0,
          })}
        </span>
        <button
          type="button"
          disabled={page >= pages || products.isFetching}
          onClick={() => setPage((current) => current + 1)}
        >
          {t('nextPage')}
        </button>
      </nav>
      {unitProduct ? (
        <VariantUnitEditor
          branchId={branch.id}
          storeId={storeId}
          product={unitProduct}
          canWrite={access.write}
          onClose={() => setUnitProduct(null)}
        />
      ) : null}
    </section>
  );
}
