import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './app';
import i18n from './i18n';
import './styles.css';

const root = document.getElementById('root');
if (root) {
  document.documentElement.lang = i18n.language;
  createRoot(root).render(
    <StrictMode>
      <App />
    </StrictMode>,
  );
}
