import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useCreateCustomer, useCustomerSearch } from '../hooks/use-pos-customers';
import type { PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

export function CustomerPanel({
  workspace,
  branchId,
  storeId,
  canCreate,
  disabled,
  onAssign,
  onClear,
}: {
  workspace: PosWorkspace;
  branchId: string | null;
  storeId: string | null;
  canCreate: boolean;
  disabled: boolean;
  onAssign: (profileId: string) => Promise<PosWorkspace>;
  onClear: () => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [resultsOpen, setResultsOpen] = useState(false);
  const [createOpen, setCreateOpen] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const panelRef = useRef<HTMLDivElement>(null);
  const search = useCustomerSearch(storeId, branchId, query);
  const create = useCreateCustomer(storeId);
  const customer = workspace.customer;

  useEffect(() => {
    const trimmed = input.trim();
    if (!trimmed) {
      setQuery('');
      setResultsOpen(false);
      return;
    }
    const timer = window.setTimeout(() => {
      setQuery(trimmed);
      setResultsOpen(true);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [input]);

  useEffect(() => {
    const dismiss = (event: Event) => {
      if (event.target instanceof Node && !panelRef.current?.contains(event.target)) {
        setResultsOpen(false);
      }
    };
    const onEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setResultsOpen(false);
        setCreateOpen(false);
      }
    };
    document.addEventListener('pointerdown', dismiss);
    document.addEventListener('keydown', onEscape);
    return () => {
      document.removeEventListener('pointerdown', dismiss);
      document.removeEventListener('keydown', onEscape);
    };
  }, []);

  async function assign(action: () => Promise<PosWorkspace>) {
    setBusy(true);
    setMessage('');
    try {
      await action();
    } catch (error) {
      setMessage(t(posFailureKey(error)));
    } finally {
      setBusy(false);
    }
  }

  async function createCustomer(event: React.FormEvent) {
    event.preventDefault();
    if (!branchId) return;
    setMessage('');
    try {
      const profile = await create.mutateAsync({
        branchId,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
      });
      if ((profile.duplicates?.length ?? 0) > 1) setMessage(t('customerDuplicateWarning'));
      await onAssign(profile.id);
      setName('');
      setPhone('');
      setEmail('');
      setCreateOpen(false);
    } catch (error) {
      setMessage(t(posFailureKey(error)));
    }
  }

  return (
    <div className="customer-panel" ref={panelRef}>
      <div className="customer-header">
        <h3>{t('customerTitle')}</h3>
        <form
          className="customer-search-row"
          onSubmit={(event) => {
            event.preventDefault();
            const trimmed = input.trim();
            if (!trimmed) return;
            setQuery(trimmed);
            setResultsOpen(true);
          }}
        >
          <input
            type="search"
            value={input}
            disabled={!branchId}
            aria-label={t('customerSearch')}
            placeholder={t('customerSearch')}
            onFocus={() => {
              if (query.trim()) setResultsOpen(true);
            }}
            onChange={(event) => setInput(event.target.value)}
          />
          <button
            type="submit"
            className="customer-icon-button"
            aria-label={t('customerFind')}
            title={t('customerFind')}
            disabled={!branchId || !input.trim()}
          >
            <PosIcon name="search" />
          </button>
          {canCreate ? (
            <button
              type="button"
              className="customer-icon-button"
              aria-label={t('customerCreate')}
              title={t('customerCreate')}
              disabled={disabled || !branchId}
              onClick={() => setCreateOpen(true)}
            >
              <PosIcon name="plus" />
            </button>
          ) : null}
        </form>
      </div>
      {resultsOpen && query ? (
        <div className="customer-results-popover">
          {search.isLoading ? <p role="status">{t('waiting')}</p> : null}
          {search.isSuccess && search.data.data.length === 0 ? (
            <p className="muted">{t('customerEmpty')}</p>
          ) : null}
          {search.isError ? (
            <p className="error" role="alert">
              {t(posFailureKey(search.error))}
            </p>
          ) : null}
          {search.data && search.data.meta.duplicate_candidates > 1 ? (
            <p role="status">{t('customerDuplicateWarning')}</p>
          ) : null}
          {search.data?.data.length ? (
            <ul className="customer-results-list" aria-label={t('customerResults')}>
              {customer ? (
                <li>
                  <div className="customer-result-info">
                    <strong>{t('customerWalkIn')}</strong>
                  </div>
                  <button
                    type="button"
                    disabled={disabled || busy}
                    onClick={() =>
                      void assign(async () => {
                        const updated = await onClear();
                        setResultsOpen(false);
                        setInput('');
                        setQuery('');
                        return updated;
                      })
                    }
                  >
                    {t('customerAssign')}
                  </button>
                </li>
              ) : null}
              {search.data.data.map((profile) => (
                <li key={profile.id}>
                  <div className="customer-result-info">
                    <strong>{profile.name}</strong>
                    {profile.phone || profile.email ? (
                      <small>{profile.phone ?? profile.email}</small>
                    ) : null}
                  </div>
                  <button
                    type="button"
                    disabled={disabled || busy}
                    onClick={() =>
                      void assign(async () => {
                        const updated = await onAssign(profile.id);
                        setResultsOpen(false);
                        setInput('');
                        setQuery('');
                        return updated;
                      })
                    }
                  >
                    {t('customerAssign')}
                  </button>
                </li>
              ))}
            </ul>
          ) : null}
        </div>
      ) : null}
      <div className="customer-selected">
        <PosIcon name="user" />
        <div className="customer-selected-info">
          <strong>{customer?.name ?? t('customerWalkIn')}</strong>
          {customer?.phone || customer?.email ? (
            <small>{customer.phone ?? customer.email}</small>
          ) : null}
        </div>
        {customer ? (
          <button
            type="button"
            className="cell-edit-button cell-clear-button"
            aria-label={t('customerClear')}
            title={t('customerClear')}
            disabled={disabled || busy}
            onClick={() => void assign(onClear)}
          >
            <PosIcon name="close" />
          </button>
        ) : null}
      </div>
      {createOpen ? (
        <div className="pos-popup-backdrop">
          <form className="customer-create-form pos-popup-card" onSubmit={createCustomer}>
            <div className="pos-popup-header">
              <strong>{t('customerCreate')}</strong>
            </div>
            <label>
              {t('customerName')}
              <input
                value={name}
                onChange={(event) => setName(event.target.value)}
                required
                maxLength={120}
              />
            </label>
            <label>
              {t('customerPhone')}
              <input
                value={phone}
                onChange={(event) => setPhone(event.target.value)}
                maxLength={32}
              />
            </label>
            <label>
              {t('customerEmail')}
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                maxLength={254}
              />
            </label>
            <div className="row">
              <button
                type="submit"
                className="primary-button"
                disabled={
                  disabled || create.isPending || !name.trim() || (!phone.trim() && !email.trim())
                }
              >
                {t('customerCreateAndAssign')}
              </button>
              <button type="button" onClick={() => setCreateOpen(false)}>
                {t('adminClose')}
              </button>
            </div>
            {create.isError ? (
              <p className="error" role="alert">
                {t(posFailureKey(create.error))}
              </p>
            ) : null}
          </form>
        </div>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </div>
  );
}
