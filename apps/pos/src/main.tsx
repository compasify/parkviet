import { QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider } from '@tanstack/react-router';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './i18n';
import { queryClient } from './lib/query-client';
import { registerServiceWorker } from './lib/service-worker';
import { router } from './router';
import './styles.css';

const root = document.getElementById('root');
if (!root) throw new Error('Missing #root');

// Only the built app installs it: the dev server and its tests stay uncached.
if (import.meta.env.PROD) registerServiceWorker();

createRoot(root).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  </StrictMode>,
);
