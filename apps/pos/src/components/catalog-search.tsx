import { formatMoney } from '@parkviet/pos-shared/money';
import { catalogViewOf, type PosCatalogView } from '@parkviet/pos-shared/pos-modules';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCatalog } from '../hooks/use-catalog';
import type { PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { AddItemForm } from './add-item-form';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';

// Outcome of a scan reported back to the search box. `seq` changes for every
// outcome so the same code scanned twice is reported twice.
export type ScanNotice = {
  seq: number;
  code: string;
  message: string;
  // Added successfully: clear the box if it still holds the scanned code.
  added: boolean;
};

export function CatalogSearch({
  storeId,
  branchId,
  workspaceId,
  onAdd,
  onAddForm,
  onScan,
  scanTerminator = 'Enter',
  scanNotice,
  addDisabled,
  addDisabledReason,
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
  // The register's calibrated scanner terminator; Tab only ends a scan when
  // the field holds a code, so keyboard navigation keeps working.
  scanTerminator?: 'Enter' | 'Tab';
  scanNotice?: ScanNotice | null;
  addDisabled?: boolean;
  addDisabledReason?: string;
}) {
  const { t } = useTranslation();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [page, setPage] = useState(1);
  // The branch's industry profile picks the first view (a pharmacy reads a
  // list, a fashion shop cards). A view the cashier picks stays for the session.
  const { context } = usePosSelection();
  const [chosenView, setView] = useState<PosCatalogView | null>(null);
  const view = chosenView ?? catalogViewOf(context.data);
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
  const inputRef = useRef(input);
  inputRef.current = input;
  const [notice, setNotice] = useState('');
  useEffect(() => {
    if (!scanNotice) return;
    setNotice(scanNotice.message);
    if (scanNotice.added) {
      if (inputRef.current.trim() === scanNotice.code) setInput('');
      return;
    }
    // Leave the code in the box with its search results so the cashier chooses.
    setInput(scanNotice.code);
    setQuery(scanNotice.code);
    setPage(1);
  }, [scanNotice]);

  function search() {
    setPage(1);
    setQuery(input.trim());
    setNotice('');
  }

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
            search();
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
              onKeyDown={(event) => {
                if (event.nativeEvent.isComposing) return;
                const scannerTab =
                  scanTerminator === 'Tab' &&
                  event.key === 'Tab' &&
                  Boolean(onScan && input.trim());
                if (event.key !== 'Enter' && !scannerTab) return;
                event.preventDefault();
                search();
                // Enter in the search box is how a scanner focused here finishes a code.
                if (onScan && input.trim()) onScan(input.trim());
              }}
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
      {notice ? (
        <p className="workspace-hint" role="status">
          {notice}
        </p>
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
                    aria-label={t('addItemNamed', { name: item.name })}
                    title={addDisabled && addDisabledReason ? addDisabledReason : item.name}
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
                  {/* Stays mounted while a command runs, so a refusal stays readable. */}
                  {onAddForm ? (
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
                          disabledReason={addDisabledReason}
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
