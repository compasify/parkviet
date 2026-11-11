import { expect, test } from '@playwright/test';
import { addLine, addSheet, installRetailApi, login, newWorld, openTab, payCash } from './support/retail-api';

const completes = (world: ReturnType<typeof newWorld>) =>
  world.writes.filter((write) => write.family === 'complete').map((write) => write.body.einvoice_buyer);

test('the cashier takes the buyer details for the e-invoice with the sale', async ({ page }) => {
  const world = newWorld();
  world.einvoiceType = 'cash_register';
  addLine(world, addSheet(world, 'ws_inv'), 'v_rice', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_inv');

  const panel = page.locator('.payment-panel');
  await panel.getByText('Khách lấy hóa đơn').click();
  await panel.getByLabel('Mã số thuế').fill('0312345678');
  // A tax code without a name and address is refused; the sale stays open.
  await payCash(page, '100.000');
  await expect(panel.getByText('Thông tin xuất hóa đơn chưa hợp lệ: Tên người mua / đơn vị.')).toBeVisible();
  expect(world.sheets.get('ws_inv')?.status).toBe('editing');

  await panel.getByLabel('Tên người mua / đơn vị').fill('Công ty TNHH ABC');
  await panel.getByLabel('Địa chỉ').fill('2 Hai Bà Trưng');
  await panel.getByLabel('Email nhận hóa đơn').fill('ketoan@abc.vn');
  await panel.getByRole('button', { name: 'Hoàn tất đơn', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  expect(world.sheets.get('ws_inv')?.status).toBe('completed');
  expect(completes(world).at(-1)).toEqual({
    tax_code: '0312345678',
    name: 'Công ty TNHH ABC',
    address: '2 Hai Bà Trưng',
    email: 'ketoan@abc.vn',
  });
});

test('a store without e-invoices asks nothing and sends no buyer', async ({ page }) => {
  const world = newWorld();
  addLine(world, addSheet(world, 'ws_plain'), 'v_water', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_plain');

  await expect(page.locator('.payment-panel').getByText('Khách lấy hóa đơn')).toHaveCount(0);
  await payCash(page, '5.000');
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  expect(completes(world)).toEqual([undefined]);
});
