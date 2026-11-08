import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  return {
    // POS is its own site (pos.example.com), served from the root. Set
    // VITE_BASE_PATH (e.g. /pos/) only to mount it under a sub-path instead.
    base: process.env.VITE_BASE_PATH || '/',
    plugins: [react()],
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
      },
    },
  };
});
