import { defineConfig, devices } from '@playwright/test';

const port = process.env.POS_TEST_PORT || '5174';
// Real-API runs reload pages, which restores the session through the refresh
// cookie. The API refuses refresh from an origin that is not allowed (the
// development store allows `http://localhost`), so those runs open the POS
// under that origin; the mocked suite keeps the IPv4 loopback.
const host = process.env.POS_LIVE_REVIEW === '1' ? 'localhost' : '127.0.0.1';

export default defineConfig({
  testDir: './e2e',
  timeout: process.env.CI ? 60_000 : 30_000,
  retries: process.env.CI ? 1 : 0,
  use: { baseURL: `http://${host}:${port}` },
  webServer: {
    command: `node node_modules/vite/bin/vite.js --host 127.0.0.1 --port ${port} --strictPort`,
    url: `http://127.0.0.1:${port}/login`,
    reuseExistingServer: false,
    env: { POS_CABLE_PROXY: process.env.POS_LIVE_REVIEW === '1' ? 'on' : 'off' },
  },
  projects: [
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } },
    },
    {
      name: 'tablet',
      use: { ...devices['Desktop Chrome'], viewport: { width: 768, height: 1024 } },
    },
    { name: 'mobile', use: { ...devices['Pixel 5'] } },
  ],
});
