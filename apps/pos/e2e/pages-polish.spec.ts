import { readFileSync, writeFileSync } from 'node:fs';
import { expect, type Page, test, type TestInfo } from '@playwright/test';

// Isolated UI fixtures: no real account or financial writes.
async function capture(page: Page, testInfo: TestInfo, name: string) {
  await page.screenshot({ path: testInfo.outputPath(`${name}.png`), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  const tooSmall = await page.evaluate(() => Array.from(document.querySelectorAll('button, input, select, summary, a[href]')).filter((el) => {
    if (!el.checkVisibility() || el.closest('.visually-hidden') || el.classList.contains('skip-link')) return false;
    if (el instanceof HTMLInputElement && el.type === 'checkbox') el = el.closest('label')!;
    const rect = el.getBoundingClientRect();
    return rect.width < 43.5 || rect.height < 43.5;
  }).map((el) => `${el.tagName}: ${el.textContent?.trim()}`));
  expect(tooSmall).toEqual([]);
  if (testInfo.project.name === 'desktop') {
    const html = await page.locator('.pos-layout').evaluate((el) => el.outerHTML);
    const css = readFileSync('src/styles.css', 'utf8');
    writeFileSync(testInfo.outputPath(`${name}.html`), `<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>POS UI fixture — no real transaction</title><style>${css}</style></head><body>${html}</body></html>`);
  }
}

test('login shares register styling, reveals password and handles pending / failed authentication', async ({ page }, testInfo) => {
  let release = () => {};
  await page.route('**/api/v3/admin/auth/login', async (route) => {
    await new Promise<void>((resolve) => { release = resolve; });
    await route.fulfill({ status: 401, json: { error: { code: 'unauthorized' } } });
  });
  await page.goto('/login');
  await expect(page.locator('.header')).toHaveCSS('background-color', 'rgb(7, 86, 154)');
  await expect(page.getByText('Phiên chỉ lưu trong bộ nhớ trình duyệt.')).toHaveCount(0);
  const saleButton = page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true });
  const adminLink = page.getByRole('link', { name: 'Đăng nhập quản trị', exact: true });
  const saleBox = (await saleButton.boundingBox())!;
  const adminBox = (await adminLink.boundingBox())!;
  expect(saleBox.y).toBeCloseTo(adminBox.y, 1);
  expect(adminBox.x).toBeGreaterThan(saleBox.x);
  await capture(page, testInfo, 'login');
  const password = page.getByLabel('Mật khẩu', { exact: true });
  await password.fill('fixture-only');
  await page.getByRole('button', { name: 'Hiện mật khẩu' }).click();
  await expect(password).toHaveAttribute('type', 'text');
  await page.getByRole('button', { name: 'Ẩn mật khẩu' }).click();
  await expect(password).toHaveAttribute('type', 'password');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await saleButton.click();
  await expect(password).toBeDisabled();
  const waitingButton = page.getByRole('button', { name: 'Đang xử lý…', exact: true });
  await expect(waitingButton).toHaveCount(1);
  await expect(waitingButton).toBeDisabled();
  release();
  await expect(page.getByRole('alert')).toContainText('Không thể đăng nhập');
  await expect(password).toHaveValue('');
  await expect(page.getByLabel('Email nhân viên')).toHaveValue('staff@example.test');
  await capture(page, testInfo, 'login-error');
});
