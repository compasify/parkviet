import { createInstance } from 'i18next';
import en from '../locales/en.json';
import vi from '../locales/vi.json';

// Test the shared locale contracts without loading an app's React i18n plugin.
const i18n = createInstance();
void i18n.init({
  lng: 'vi',
  fallbackLng: 'vi',
  interpolation: { escapeValue: false },
  resources: { vi: { translation: vi }, en: { translation: en } },
});

export default i18n;
