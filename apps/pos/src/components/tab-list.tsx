import { formatMoney } from '@parkviet/pos-shared/money';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useOpenTabs } from '../hooks/use-tabs';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

const TAB_NAME_MAX = 60;

function openedTime(iso: string | null, language: string) {
  if (!iso) return '';
  return new Date(iso).toLocaleTimeString(language, { hour: '2-digit', minute: '2-digit' });
}

// A bar's open tabs: the search keeps the focus, so a bartender types a name
// and picks the tab; "Mở tab" opens one with only the guest's name.
export function TabList({
  branchId,
  storeId,
  currency,
  canOpen,
  onOpenTab,
  onSelectOrder,
}: {
  branchId: string | null;
  storeId: string | null;
  currency: string;
  canOpen: boolean;
  onOpenTab: (name: string) => Promise<void>;
  onSelectOrder: (id: string) => void;
}) {
  const { t, i18n } = useTranslation();
  const [query, setQuery] = useState('');
  const [name, setName] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const search = useRef<HTMLInputElement>(null);
  const tabs = useOpenTabs(branchId, storeId, query, Boolean(branchId));
  const rows = tabs.data ?? [];

  useEffect(() => {
    search.current?.focus();
  }, []);

  async function open(event: FormEvent) {
    event.preventDefault();
    const value = (name || query).trim();
    if (!value) return;
    setBusy(true);
    setMessage(null);
    try {
      await onOpenTab(value);
      setName('');
      setQuery('');
    } catch (error) {
      const reason = conflictReason(error);
      setMessage(
        reason === 'tab_name_taken'
          ? t('tabNameTaken')
          : reason === 'tab_name_invalid'
            ? t('tabNameInvalid')
            : t(posFailureKey(error)),
      );
    } finally {
      setBusy(false);
      search.current?.focus();
    }
  }

  return (
    <section className="tab-list" aria-label={t('tabListTitle')}>
      <div className="tab-list-toolbar">
        <label className="tab-list-search">
          <PosIcon name="search" />
          <span className="visually-hidden">{t('tabSearch')}</span>
          <input
            ref={search}
            type="search"
            value={query}
            placeholder={t('tabSearchPlaceholder')}
            maxLength={TAB_NAME_MAX}
            onChange={(event) => setQuery(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' && rows.length === 1) onSelectOrder(rows[0].id);
            }}
          />
        </label>
        {canOpen ? (
          <form className="tab-list-open" onSubmit={(event) => void open(event)}>
            <label>
              <span className="visually-hidden">{t('tabName')}</span>
              <input
                value={name}
                placeholder={t('tabNamePlaceholder')}
                maxLength={TAB_NAME_MAX}
                onChange={(event) => setName(event.target.value)}
              />
            </label>
            <button type="submit" disabled={busy || !(name || query).trim()}>
              <PosIcon name="plus" /> {t('tabOpen')}
            </button>
          </form>
        ) : null}
      </div>
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {tabs.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(tabs.error))}
        </p>
      ) : null}
      {tabs.isSuccess && rows.length === 0 ? (
        <p className="workspace-hint" role="status">
          {query.trim() ? t('tabNoMatch') : t('tabNone')}
        </p>
      ) : null}
      {rows.length > 0 ? (
        <table className="tab-list-table">
          <thead>
            <tr>
              <th scope="col">{t('tabName')}</th>
              <th scope="col">{t('tabTable')}</th>
              <th scope="col">{t('tabOpenedAt')}</th>
              <th scope="col" className="numeric">
                {t('tabTotal')}
              </th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id}>
                <td>
                  <button
                    type="button"
                    className="link-button"
                    onClick={() => onSelectOrder(row.id)}
                  >
                    {row.tabName}
                  </button>
                </td>
                <td>{row.table ?? '—'}</td>
                <td>{openedTime(row.openedAt, i18n.language)}</td>
                <td className="numeric">{formatMoney(row.total, currency)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : null}
    </section>
  );
}
