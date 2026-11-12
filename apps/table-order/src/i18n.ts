import i18next from 'i18next';
import { initReactI18next } from 'react-i18next';
import en from './locales/en.json';
import vi from './locales/vi.json';

const LANGUAGE_KEY = 'parkviet.table.language';

function savedLanguage(): 'vi' | 'en' {
  try {
    return globalThis.localStorage?.getItem(LANGUAGE_KEY) === 'en' ? 'en' : 'vi';
  } catch {
    return 'vi';
  }
}

// Vietnamese unless the guest switched to English on this phone.
void i18next.use(initReactI18next).init({
  resources: { vi: { translation: vi }, en: { translation: en } },
  lng: savedLanguage(),
  fallbackLng: 'vi',
  interpolation: { escapeValue: false },
});

export function toggleLanguage() {
  const next = i18next.language === 'en' ? 'vi' : 'en';
  try {
    globalThis.localStorage?.setItem(LANGUAGE_KEY, next);
  } catch {
    // Private mode: the choice lasts for this page only.
  }
  document.documentElement.lang = next;
  void i18next.changeLanguage(next);
}

export default i18next;
