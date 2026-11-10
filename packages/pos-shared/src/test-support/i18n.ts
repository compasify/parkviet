import { createInstance } from 'i18next';
import en from '../../../../apps/pos/src/locales/en.json';
import vi from '../../../../apps/pos/src/locales/vi.json';

// Test the real locale contracts without loading POS's React i18n plugin.
const i18n = createInstance();
void i18n.init({
  lng: 'vi',
  fallbackLng: 'vi',
  interpolation: { escapeValue: false },
  resources: { vi: { translation: vi }, en: { translation: en } },
});

export default i18n;
