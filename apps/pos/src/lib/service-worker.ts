// The installed app shell: the service worker built with the app (see
// vite.config.ts) keeps its files so the POS opens without the server, and
// never touches the API. A new build waits until the cashier reloads for it.

export const APP_UPDATE = 'pos:app-update';

let waiting: ServiceWorker | null = null;

function offer(worker: ServiceWorker) {
  waiting = worker;
  window.dispatchEvent(new Event(APP_UPDATE));
}

export function registerServiceWorker() {
  if (!('serviceWorker' in navigator)) return;
  const base = import.meta.env.BASE_URL;
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register(`${base}sw.js`, { scope: base })
      .then((registration) => {
        if (registration.waiting && navigator.serviceWorker.controller) offer(registration.waiting);
        registration.addEventListener('updatefound', () => {
          const installing = registration.installing;
          installing?.addEventListener('statechange', () => {
            if (installing.state === 'installed' && navigator.serviceWorker.controller)
              offer(installing);
          });
        });
      })
      .catch(() => undefined);
  });
}

export function updateWaiting() {
  return waiting !== null;
}

// Hands over to the new build and reloads once it controls the page.
export function applyUpdate() {
  if (!waiting) return;
  navigator.serviceWorker.addEventListener('controllerchange', () => window.location.reload(), {
    once: true,
  });
  waiting.postMessage('skip-waiting');
}
