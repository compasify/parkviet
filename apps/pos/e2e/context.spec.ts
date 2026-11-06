import { expect, test } from '@playwright/test';

test('anonymous settings returns to the Vietnamese login screen', async ({ page }) => {
  await page.route('**/api/v3/admin/auth/refresh', (route) =>
    route.fulfill({ status: 401, json: { error: { code: 'unauthorized' } } }),
  );
  await page.goto('/pos/settings');
  await expect(page).toHaveURL(/\/pos\/login$/);
  await expect(page.getByRole('heading', { name: 'Không gian bán hàng' })).toBeVisible();
  await page.getByLabel('Email nhân viên').focus();
  await expect(page.getByLabel('Email nhân viên')).toBeFocused();
  await expect(page.getByRole('button', { name: /thu tiền|thanh toán|pay/i })).toHaveCount(0);
});
