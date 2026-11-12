import { defineConfig, devices } from '@playwright/test';

// The mocked suite on its own fixed port; the API is answered by page routes.
const port = process.env.TABLE_ORDER_TEST_PORT || '5178';

export default defineConfig({
  testDir: './e2e',
  use: { baseURL: `http://127.0.0.1:${port}` },
  webServer: {
    command: `node node_modules/vite/bin/vite.js --host 127.0.0.1 --port ${port} --strictPort`,
    url: `http://127.0.0.1:${port}/table/`,
    reuseExistingServer: false,
  },
  projects: [
    { name: 'mobile', use: { ...devices['Pixel 5'] } },
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } },
    },
  ],
});
