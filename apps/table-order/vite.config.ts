import react from '@vitejs/plugin-react';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  return {
    // The server serves the build at /table/ (server/Dockerfile sets
    // VITE_BASE_PATH); development and the e2e suite serve it there too, so
    // the sticker's /table/t/<code> link works the same everywhere.
    base: process.env.VITE_BASE_PATH || '/table/',
    plugins: [react()],
    build: { sourcemap: false },
    server: {
      // Fixed port beside the counter (5175) and POS administration (5176).
      port: 5177,
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
