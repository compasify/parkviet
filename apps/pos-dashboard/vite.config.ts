import tailwindcss from '@tailwindcss/vite'
import { tanstackRouter } from '@tanstack/router-plugin/vite'
import react from '@vitejs/plugin-react'
import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_')
  const target = env.VITE_API_PROXY_TARGET || 'http://localhost:3000'
  return {
    base: env.VITE_BASE_PATH || '/',
    plugins: [tanstackRouter({ target: 'react', autoCodeSplitting: true }), tailwindcss(), react()],
    resolve: {
      dedupe: [
        'react',
        'react-dom',
        'i18next',
        'react-i18next',
        '@tanstack/react-query',
        '@tanstack/react-router',
      ],
    },
    server: {
      port: 5176,
      strictPort: true,
      proxy: { '/api': { target, changeOrigin: true }, '/rails': { target, changeOrigin: true } },
    },
  }
})
