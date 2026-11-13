import { useNavigate } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import posAppIcon from '../assets/brand/parkviet-pos-app-icon.svg';
import { PosIcon } from '../components/pos-icon';
import { useSession } from '../hooks/use-session';
import { session } from '../lib/app-session';
import { queryClient } from '../lib/query-client';
import '../styles/login.css';

export function StorePickerPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const snapshot = useSession();
  const [busy, setBusy] = useState(false);

  async function choose(storeId: string) {
    session.selectStore(storeId);
    queryClient.clear();
    await navigate({ to: '/' });
  }

  async function logout() {
    setBusy(true);
    try {
      await session.logout();
    } finally {
      setBusy(false);
      await navigate({ to: '/login' });
    }
  }

  return (
    <main className="layout pos-layout login-split store-picker">
      <div className="login-side">
        <section className="auth-panel" aria-labelledby="title">
          <div className="login-side-brand">
            <img className="login-side-logo" src={posAppIcon} alt="" />
            <strong>
              ParkViet <span>POS</span>
            </strong>
          </div>
          <div className="auth-eyebrow">{snapshot.name}</div>
          <h1 id="title">{t('storePickerTitle')}</h1>
          <p className="auth-intro">{t('storePickerIntro')}</p>
          <ul className="store-choices">
            {snapshot.stores.map((store) => (
              <li key={store.id}>
                <button
                  type="button"
                  className="store-choice"
                  disabled={busy}
                  aria-current={store.id === snapshot.storeId ? 'true' : undefined}
                  onClick={() => void choose(store.id)}
                >
                  <span>{store.name || store.code}</span>
                  {store.id === snapshot.storeId ? (
                    <small>{t('storeCurrent')}</small>
                  ) : (
                    <PosIcon name="chevron" />
                  )}
                </button>
              </li>
            ))}
          </ul>
          <p className="auth-help">
            <button type="button" className="button-link" disabled={busy} onClick={logout}>
              {t('logout')}
            </button>
          </p>
        </section>
      </div>
    </main>
  );
}
