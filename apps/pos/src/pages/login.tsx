import { Link, useNavigate } from '@tanstack/react-router';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { LoginShowcase } from '../components/login-showcase';
import { PosIcon } from '../components/pos-icon';
import { useStoredSnapshot } from '../hooks/use-offline';
import { session } from '../lib/app-session';
import { snapshotState } from '../lib/offline-sales';
import { posDashboardHomeUrl } from '../lib/pos-dashboard-url';
import '../styles/login.css';

export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  // Administration is a separate app with its own sign-in.
  const administrationUrl = posDashboardHomeUrl();
  // Opened offline (no session to restore): the register may still sell
  // cash sales from its stored snapshot.
  const stored = useStoredSnapshot();
  const offlineReady = stored.loaded && snapshotState(stored.snapshot) === 'ready';

  async function login(event: FormEvent) {
    event.preventDefault();
    if (busy) return;
    setBusy(true);
    setError('');
    try {
      await session.login(email, password);
      setPassword('');
      await navigate({ to: '/' });
    } catch {
      setPassword('');
      setError(t('failure'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="layout pos-layout login-split">
      <div className="login-side">
        <section className="auth-panel" aria-labelledby="title">
          <div className="login-side-brand">
            <span className="auth-symbol">
              <PosIcon name="cash" />
            </span>
            <strong>
              ParkViet <span>POS</span>
            </strong>
            <span className="login-side-area">{t('sellingArea')}</span>
          </div>
          <div className="auth-eyebrow">{t('staffAccess')}</div>
          <h1 id="title">{t('title')}</h1>
          <p className="auth-intro">{t('intro')}</p>
          {error && (
            <p className="error" id="login-error" role="alert">
              {error}
            </p>
          )}
          <form className="auth-form" onSubmit={login} aria-busy={busy}>
            <div className="auth-field">
              <label htmlFor="email">{t('email')}</label>
              <input
                id="email"
                type="email"
                autoComplete="username"
                autoCapitalize="none"
                spellCheck={false}
                disabled={busy}
                aria-describedby={error ? 'login-error' : undefined}
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
              />
            </div>
            <div className="auth-field">
              <label htmlFor="password">{t('password')}</label>
              <div className="password-field">
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  disabled={busy}
                  aria-describedby={error ? 'login-error' : undefined}
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  required
                />
                <button
                  className="password-toggle"
                  type="button"
                  disabled={busy}
                  aria-label={t(showPassword ? 'hidePassword' : 'showPassword')}
                  aria-pressed={showPassword}
                  onClick={() => setShowPassword((current) => !current)}
                >
                  <PosIcon name={showPassword ? 'eyeOff' : 'eye'} />
                </button>
              </div>
            </div>
            <div className="auth-actions">
              <button className="checkout-submit" type="submit" disabled={busy}>
                <PosIcon name="cash" /> {busy ? t('waiting') : t('loginSale')}
              </button>
              {administrationUrl ? (
                <a
                  className="button-link auth-admin-submit"
                  href={administrationUrl}
                  target="_blank"
                  rel="noopener"
                >
                  <PosIcon name="cog" /> {t('loginAdministration')}
                </a>
              ) : null}
            </div>
          </form>
          {offlineReady ? (
            <p className="auth-help">
              <Link to="/offline">{t('offlineSellLink')}</Link>
            </p>
          ) : null}
          <p className="auth-help">{t('loginHelp')}</p>
        </section>
      </div>
      <LoginShowcase />
    </main>
  );
}
