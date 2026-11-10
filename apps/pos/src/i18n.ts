import sharedEn from '@parkviet/pos-shared/locales/en';
import sharedVi from '@parkviet/pos-shared/locales/vi';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import en from './locales/en.json';
import vi from './locales/vi.json';

void i18n.use(initReactI18next).init({
  lng: 'vi',
  fallbackLng: 'vi',
  interpolation: { escapeValue: false },
  resources: {
    vi: { translation: vi },
    en: { translation: en },
  },
});

// Texts of the shared POS logic (receipts, refusals, modules, profiles) join
// the app's own: deep merge, so sections both bundles fill keep every key.
i18n.addResourceBundle('vi', 'translation', sharedVi, true, false);
i18n.addResourceBundle('en', 'translation', sharedEn, true, false);

export default i18n;
