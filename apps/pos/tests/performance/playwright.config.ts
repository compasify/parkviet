import { defineConfig, devices } from '@playwright/test';

// Separate from the e2e config so `pnpm test:e2e` never runs the timing harness.
const port = process.env.POS_TEST_PORT || '5174';

export default defineConfig({
  testDir: '.',
  testMatch: 'pos-scenarios.ts',
  workers: 1,
  use: { baseURL: `http://127.0.0.1:${port}` },
  webServer: {
    command: `node node_modules/vite/bin/vite.js --host 127.0.0.1 --port ${port} --strictPort`,
    cwd: '../..',
    url: `http://127.0.0.1:${port}/pos/login`,
    reuseExistingServer: false,
  },
  projects: [
    {
      name: 'desktop',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } },
    },
  ],
});
