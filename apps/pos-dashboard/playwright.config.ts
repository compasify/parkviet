import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  workers: 4,
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'tablet', use: { ...devices['iPad (gen 7)'], browserName: 'chromium' } },
    { name: 'mobile', use: { ...devices['iPhone 13'], browserName: 'chromium' } },
  ],
  use: { baseURL: 'http://localhost:5176', trace: 'retain-on-failure' },
  webServer: { command: 'pnpm dev', url: 'http://localhost:5176', reuseExistingServer: false },
})
