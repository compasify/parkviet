import { useCanGoBack, useNavigate, useRouter } from '@tanstack/react-router';
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
  const router = useRouter();
  const canGoBack = useCanGoBack();
  const snapshot = useSession();
  const [busy, setBusy] = useState(false);

  async function choose(storeId: string) {
    session.selectStore(storeId);
    queryClient.clear();
    await navigate({ to: '/' });
  }

  // Changing store from the counter keeps the current one until another is
  // picked, so the cashier can return to where they were without switching.
  const hasCurrentStore = snapshot.stores.some((store) => store.id === snapshot.storeId);

  function goBack() {
    if (canGoBack) router.history.back();
    else void navigate({ to: '/' });
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
            {hasCurrentStore ? (
              <button type="button" className="button-link" disabled={busy} onClick={goBack}>
                <PosIcon name="back" />
                {t('back')}
              </button>
            ) : null}
            <button type="button" className="button-link" disabled={busy} onClick={logout}>
              {t('logout')}
            </button>
          </p>
        </section>
      </div>
    </main>
  );
}
