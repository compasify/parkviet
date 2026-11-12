import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  // The Vite dev server transforms modules on demand, so on a two-core CI
  // runner four workers push full page loads past the default timeout.
  workers: process.env.CI ? 2 : 4,
  timeout: process.env.CI ? 60_000 : 30_000,
  retries: process.env.CI ? 1 : 0,
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'tablet', use: { ...devices['iPad (gen 7)'], browserName: 'chromium' } },
    { name: 'mobile', use: { ...devices['iPhone 13'], browserName: 'chromium' } },
  ],
  use: { baseURL: 'http://localhost:5176', trace: 'retain-on-failure' },
  webServer: { command: 'pnpm dev', url: 'http://localhost:5176', reuseExistingServer: false },
})
