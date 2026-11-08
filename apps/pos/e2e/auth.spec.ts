import { expect, test } from '@playwright/test'

test('login screen is Vietnamese and does not offer payment', async ({ page }) => {
  await page.goto('/login')
  await expect(page.getByRole('heading', { name: 'Không gian bán hàng' })).toBeVisible()
  await expect(page.getByLabel('Email nhân viên')).toBeVisible()
  const submit = page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true })
  await expect(submit).toBeVisible()
  await page.getByLabel('Email nhân viên').focus()
  await expect(page.getByLabel('Email nhân viên')).toBeFocused()
  await expect(page.getByRole('button', { name: /thu tiền|thanh toán|pay/i })).toHaveCount(0)
})
