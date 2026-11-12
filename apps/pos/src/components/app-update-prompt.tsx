import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { APP_UPDATE, applyUpdate, updateWaiting } from '../lib/service-worker';

// "Có bản mới, tải lại": a new build is installed and waits for the cashier.
export function AppUpdatePrompt() {
  const { t } = useTranslation();
  const [ready, setReady] = useState(updateWaiting);
  useEffect(() => {
    const onUpdate = () => setReady(true);
    window.addEventListener(APP_UPDATE, onUpdate);
    return () => window.removeEventListener(APP_UPDATE, onUpdate);
  }, []);
  if (!ready) return null;
  return (
    <p role="status">
      {t('appUpdateReady')}{' '}
      <button type="button" onClick={applyUpdate}>
        {t('appUpdateReload')}
      </button>
    </p>
  );
}
