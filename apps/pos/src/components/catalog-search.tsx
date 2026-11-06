import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCatalog } from '../hooks/use-catalog';
import { formatMoney } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { AddItemForm } from './add-item-form';
import { PosIcon } from './pos-icon';

export function CatalogSearch({
  storeId,
  branchId,
  workspaceId,
  onAdd,
  onAddForm,
  onScan,
  addDisabled,
}: {
  storeId: string | null;
  branchId: string | null;
  workspaceId?: string | null;
  onAdd?: (variantId: string) => void;
  onAddForm?: (
    variantId: string,
    quantity: number,
    extra: import('./add-item-form').SaleLineAddExtra,
  ) => Promise<PosWorkspace>;
  onScan?: (code: string) => void;
  addDisabled?: boolean;
}) {
  const { t } = useTranslation();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [page, setPage] = useState(1);
  const [view, setView] = useState<'cards' | 'list'>('cards');
  const [advancedIds, setAdvancedIds] = useState<Record<string, boolean>>({});
  const result = useCatalog(storeId, branchId, query, page);
  const searchRef = useRef<HTMLInputElement>(null);
  useEffect(() => {
    const timer = window.setTimeout(() => {
      setQuery(input.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [input]);
  useEffect(() => {
    const focusSearch = (event: KeyboardEvent) => {
      if (event.key === 'F2') {
        event.preventDefault();
        searchRef.current?.focus();
      }
    };
    window.addEventListener('keydown', focusSearch);
    return () => window.removeEventListener('keydown', focusSearch);
  }, []);
  void workspaceId;

  return (
    <div className="selling-search">
      <div className="catalog-heading">
        <h3>
          {t('catalogTitle')}{' '}
          {result.isSuccess ? (
            <span className="catalog-count">{result.data.meta.count}</span>
          ) : null}
        </h3>
        <form
          className="product-search-row"
          onSubmit={(event) => {
            event.preventDefault();
            setPage(1);
            setQuery(input.trim());
            onScan?.(input.trim());
          }}
        >
          <div className="search-input-wrap">
            <PosIcon name="search" />
            <input
              id="pos-product-search"
              ref={searchRef}
              type="search"
              maxLength={200}
              disabled={!branchId}
              value={input}
              onChange={(event) => setInput(event.target.value)}
              aria-label={t('searchProducts')}
              aria-keyshortcuts="F2"
              placeholder={t('searchProductsPlaceholder')}
            />
          </div>
          <button type="submit" disabled={!branchId || !input.trim()}>
            {t('catalogFind')}
          </button>
        </form>
        <fieldset className="view-toggle" aria-label={t('catalogView')}>
          <button type="button" aria-pressed={view === 'cards'} onClick={() => setView('cards')}>
            <PosIcon name="grid" /> {t('catalogCards')}
          </button>
          <button type="button" aria-pressed={view === 'list'} onClick={() => setView('list')}>
            <PosIcon name="list" /> {t('catalogList')}
          </button>
        </fieldset>
      </div>
      {!branchId ? <div className="catalog-empty">{t('catalogSearchPrompt')}</div> : null}
      {result.isFetching ? (
        <span className="catalog-loading" role="status">
          {t('waiting')}
        </span>
      ) : null}
      {result.isError ? <p role="alert">{t(posFailureKey(result.error))}</p> : null}
      {result.isSuccess && result.data.data.length === 0 ? (
        <div className="catalog-empty">
          {t('catalogEmpty')}
          <span>{t('catalogTryAgain')}</span>
        </div>
      ) : null}
      {result.isSuccess && result.data.data.length > 0 ? (
        <>
          <div className="catalog-scroll">
            <ul
              className={`catalog-results catalog-results--${view}`}
              aria-label={t('catalogResults')}
            >
              {result.data.data.map((item) => (
                <li key={item.id}>
                  <button
                    type="button"
                    className="catalog-product"
                    aria-label={t('addItem')}
                    title={item.name}
                    disabled={!onAdd || addDisabled || item.price === null}
                    onClick={() => onAdd?.(item.id)}
                  >
                    <div className="catalog-image" aria-hidden="true">
                      <PosIcon name="box" />
                    </div>
                    <span className="catalog-product-info">
                      <strong title={item.name}>{item.name}</strong>
                      <span className="catalog-meta">
                        <span className="catalog-sku">{item.sku}</span>
                        <span className="catalog-meta-sep" aria-hidden="true">
                          {' · '}
                        </span>
                        <span
                          className={
                            item.stock_on_hand === null
                              ? 'stock-unknown'
                              : item.stock_on_hand <= 3
                                ? 'stock-low'
                                : 'catalog-stock'
                          }
                        >
                          {t('catalogOnHand')}: {item.stock_on_hand ?? t('catalogStockUnknown')}
                        </span>
                      </span>
                      <span className="catalog-price">
                        {item.price !== null
                          ? formatMoney(item.price, item.currency)
                          : t('catalogNoPrice')}
                        {item.price !== null &&
                        item.compare_at_price !== null &&
                        Number(item.compare_at_price) > Number(item.price) ? (
                          <del> {formatMoney(item.compare_at_price, item.currency)}</del>
                        ) : null}
                      </span>
                    </span>
                  </button>
                  {onAddForm && !addDisabled ? (
                    <details
                      className="catalog-advanced"
                      onToggle={(event) => {
                        const open = event.currentTarget.open;
                        setAdvancedIds((current) => ({ ...current, [item.id]: open }));
                      }}
                    >
                      <summary title={t('catalogAdvanced')}>
                        <span className="visually-hidden">
                          {t('catalogAdvanced')} · {item.name}
                        </span>
                        <PosIcon name="chevron" />
                      </summary>
                      {advancedIds[item.id] ? (
                        <AddItemForm
                          storeId={storeId}
                          branchId={branchId}
                          variantId={item.id}
                          disabled={Boolean(addDisabled)}
                          onAdd={onAddForm}
                        />
                      ) : null}
                    </details>
                  ) : null}
                </li>
              ))}
            </ul>
          </div>
          {result.data.meta.pages > 1 ? (
            <div className="row catalog-pagination">
              <button type="button" disabled={page <= 1} onClick={() => setPage(page - 1)}>
                {t('previousPage')}
              </button>
              <span>
                {page} / {result.data.meta.pages}
              </span>
              <button
                type="button"
                disabled={page >= result.data.meta.pages}
                onClick={() => setPage(page + 1)}
              >
                {t('nextPage')}
              </button>
            </div>
          ) : null}
        </>
      ) : null}
    </div>
  );
}
