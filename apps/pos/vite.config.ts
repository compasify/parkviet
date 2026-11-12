import { createHash } from 'node:crypto';
import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv, type Plugin } from 'vite';

// The service worker of the built app: it keeps the files of this build so
// the POS opens with the server out of reach (pages from the network first,
// files from the cache), and lets every API and socket request through
// untouched. Each build gets its own cache; a new one waits for the cashier
// to reload (src/lib/service-worker.ts).
function serviceWorkerSource(version: string, files: string[]) {
  return `const CACHE = 'parkviet-pos-${version}';
const FILES = ${JSON.stringify(files)};
const scope = () => new URL(self.registration.scope);
self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(FILES)));
});
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key.startsWith('parkviet-pos-') && key !== CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim()),
  );
});
self.addEventListener('message', (event) => {
  if (event.data === 'skip-waiting') self.skipWaiting();
});
self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin || !url.pathname.startsWith(scope().pathname)) return;
  if (/^/(api|cable)(/|$)/.test(url.pathname)) return;
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request).catch(() =>
        caches.match(new URL('index.html', scope()).href, { cacheName: CACHE }).then((hit) => hit || Response.error()),
      ),
    );
    return;
  }
  event.respondWith(caches.match(request, { cacheName: CACHE }).then((hit) => hit || fetch(request)));
});
`;
}

function serviceWorker(): Plugin {
  return {
    name: 'parkviet-pos-service-worker',
    apply: 'build',
    enforce: 'post',
    generateBundle(_options, bundle) {
      const files = [
        ...new Set(['index.html', ...Object.keys(bundle)].filter((name) => !name.endsWith('.map'))),
      ].sort();
      const version = createHash('sha256').update(files.join('\n')).digest('hex').slice(0, 12);
      this.emitFile({
        type: 'asset',
        fileName: 'sw.js',
        source: serviceWorkerSource(version, files),
      });
    },
  };
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  return {
    // POS is its own site (pos.example.com), served from the root. Set
    // VITE_BASE_PATH (e.g. /pos/) only to mount it under a sub-path instead.
    base: process.env.VITE_BASE_PATH || '/',
    plugins: [react(), serviceWorker()],
    server: {
      // Fixed port so `spree dev` (through the dashboard dev server) and a
      // standalone `pnpm dev` land on the same URL. 5174 belongs to the
      // seller dashboard.
      port: 5175,
      strictPort: true,
      proxy: {
        '/api': {
          target: env.VITE_API_PROXY_TARGET || 'http://localhost:3000',
          changeOrigin: true,
        },
        // The mocked e2e suite turns this off so its pages never open sockets
        // on the real API.
        ...(process.env.POS_CABLE_PROXY === 'off'
          ? {}
          : {
              '/cable': {
                target: env.VITE_API_PROXY_TARGET || 'http://localhost:3000',
                changeOrigin: true,
                ws: true,
              },
            }),
      },
    },
  };
});
