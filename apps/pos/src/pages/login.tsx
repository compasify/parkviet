import { useNavigate } from '@tanstack/react-router';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../components/pos-icon';
import { session } from '../lib/app-session';

export function LoginPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busyTarget, setBusyTarget] = useState<'sale' | 'administration' | null>(null);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const busy = busyTarget !== null;

  async function login(event: FormEvent) {
    event.preventDefault();
    if (busy) return;
    const submitter = (event.nativeEvent as SubmitEvent).submitter as HTMLButtonElement | null;
    const administration = submitter?.value === 'administration';
    setBusyTarget(administration ? 'administration' : 'sale');
    setError('');
    try {
      await session.login(email, password);
      setPassword('');
      await navigate({ to: administration ? '/settings' : '/' });
    } catch {
      setPassword('');
      setError(t('failure'));
    } finally {
      setBusyTarget(null);
    }
  }

  return (
    <main className="layout pos-layout pos-auth-layout">
      <header className="header">
        <strong>
          ParkViet <span>POS</span>
        </strong>
        <span className="header-title">{t('sellingArea')}</span>
      </header>
      <div className="auth-main">
        <section className="auth-panel" aria-labelledby="title">
          <span className="auth-symbol">
            <PosIcon name="cash" />
          </span>
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
              <button className="checkout-submit" type="submit" value="sale" disabled={busy}>
                <PosIcon name="cash" /> {busyTarget === 'sale' ? t('waiting') : t('loginSale')}
              </button>
              <button
                className="auth-admin-submit"
                type="submit"
                value="administration"
                disabled={busy}
              >
                <PosIcon name="cog" />{' '}
                {busyTarget === 'administration' ? t('waiting') : t('loginAdministration')}
              </button>
            </div>
          </form>
        </section>
        <p className="auth-help">{t('loginHelp')}</p>
      </div>
    </main>
  );
}
