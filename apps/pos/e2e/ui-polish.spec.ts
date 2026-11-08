import { readFileSync, writeFileSync } from 'node:fs';
import { expect, test } from '@playwright/test';

// Presentation fixtures only. These tests do not qualify real settlement.
test('cashier layout keeps the basket reachable, formats VND and safely edits quantities', async ({ page }, testInfo) => {
  const errors: string[] = [];
  page.on('pageerror', (error) => errors.push(error.message));
  let quantity = 0;
  let revision = 0;
  let rejectUpdate = false;
  let unitRequests = 0;
  let workspaceReads = 0;
  let heartbeatRequests = 0;
  let writeGate: Promise<void> | null = null;
  let unitPrice = 125000;
  let invoicePercent = 0;
  let promotionPercent = 0;
  let itemOverride: { type: 'flat' | 'percent'; value: number } | null = null;
  const lineAmount = () => quantity * unitPrice;
  const lineReduction = () => itemOverride ? (itemOverride.type === 'percent' ? Math.round(lineAmount() * itemOverride.value / 100) : itemOverride.value) : Math.round(lineAmount() * promotionPercent / 100);
  const invoiceReduction = () => Math.round((lineAmount() - lineReduction()) * invoicePercent / 100);
  const total = () => lineAmount() - lineReduction() - invoiceReduction();
  const writes: Record<string, unknown>[] = [];
  const names = ['Gạo thơm 5kg', 'Sữa tươi tiệt trùng nguyên kem không đường nhập khẩu hộp lớn 1L mẫu mới đặc biệt', 'Trứng gà hộp 10 quả', 'Mì ăn liền gói', 'Dầu ăn 1L', 'Nước suối 500ml', 'Cà phê hòa tan hộp', 'Bánh quy bơ', 'Nước mắm 500ml', 'Đường trắng 1kg', 'Bột giặt 2kg', 'Giấy vệ sinh 10 cuộn'];
  const products = names.map((name, index) => ({ id: `v_${index}`, product_id: `p_${index}`, name, sku: `HH-${index + 1}`, barcode: `990000000000${index}`, price: String(index === 0 ? 125000 : 35000), compare_at_price: null, currency: 'VND', stock_on_hand: index === 1 ? null : 30 }));
  const workspace = () => {
    const result = ({
    id: 'ws_1', branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', order_id: 'R-001',
    revision, lease_generation: 1, operational_status: 'editing', payments: false,
    line_items: quantity ? [{ id: 'line_1', sale_line_id: 'sale_1', variant_id: 'v_0', product_id: 'p_0', name: names[0], sku: 'HH-1', quantity, price: `${unitPrice}.0`, list_price: '125000.0', unit_price: `${unitPrice}.0`, amount: String(lineAmount()), net_amount: String(total()), discounts: lineReduction() ? [{ id: 'ld_1', kind: itemOverride ? 'manual' : 'promotion', label: 'Giảm giá mặt hàng', amount: String(-lineReduction()) }] : [], item_discount: { amount: String(-lineReduction()), value_type: itemOverride?.type ?? (promotionPercent ? 'percent' : 'flat'), value: String(itemOverride?.value ?? promotionPercent), source: itemOverride ? 'manual' : promotionPercent ? 'promotion' : 'none', labels: promotionPercent ? ['Khuyến mại sản phẩm'] : [] }, line_discount: itemOverride ? { id: 'ldi_1', value_type: `item_${itemOverride.type}`, value: String(itemOverride.value), reason: 'Giảm mặt hàng', amount: String(-lineReduction()) } : null, kind: 'ordinary' }] : [],
    customer: null, discount: invoicePercent ? { id: 'di_1', value_type: 'percent', value: String(invoicePercent), reason: 'Hóa đơn', amount: String(-invoiceReduction()) } : null,
    totals: { item_total: String(lineAmount()), discount_total: String(-lineReduction() - invoiceReduction()), manual_discount_total: String(-lineReduction() - invoiceReduction()), total: String(total()), currency: 'VND' },
    financial: { received: '0', allocated: '0', unapplied: '0', remaining: String(total()), change_due: '0', attempts: [] },
  });
    return { ...result, line_items: result.line_items.map((line) => ({ ...line, item_net_amount: String(lineAmount() - lineReduction()) })) };
  };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Siêu thị Hiền', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 01', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'ui-fixture-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'cashier@example.test', full_name: 'Thu ngân' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({ json: {
        staff: { id: 'staff_1', email: 'cashier@example.test', full_name: 'Thu ngân' },
        store: { id: 'store_1', name: 'Siêu thị', currency: 'VND' },
        capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.discount.apply', 'pos.customer.write'],
        branches: [{ id: 'br_1', name: 'Siêu thị Hiền', status: 'active' }],
        registers: branch ? [{ id: 'reg_1', branch_id: branch, name: 'Quầy 01', status: 'active' }] : [],
        shift: register ? { id: 'sh_1', register_id: register, owner_id: 'staff_1', status: 'open', currency: 'VND', opening_float: '0' } : null,
        selection: { branch_id: branch, register_id: register },
      } });
    }
    if (path.endsWith('/pos/catalog')) {
      const q = (url.searchParams.get('q') ?? '').toLocaleLowerCase('vi');
      const rows = products.filter((item) => `${item.name} ${item.sku}`.toLocaleLowerCase('vi').includes(q));
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    if (path.endsWith('/pos/units/variant')) {
      unitRequests += 1;
      return route.fulfill({ json: { data: { variant_id: 'v_0', sale_unit: 'item', base_unit: 'item', tracked_mode: 'none' } } });
    }
    if (path.endsWith('/pos/traceability')) return route.fulfill({ json: { data: { reservation: 'unavailable_phase_8' } } });
    if (path.endsWith('/pos/workspaces')) {
      workspaceReads++;
      return route.fulfill({ json: { data: [workspace()], meta: { page: 1, pages: 1, count: 1 } } });
    }
    if (path.endsWith('/ws_1')) workspaceReads++;
    if (path.endsWith('/ws_1/lease') && request.method() === 'PATCH') heartbeatRequests++;
    if (path.endsWith('/ws_1') || path.endsWith('/ws_1/lease')) return route.fulfill({ json: { data: workspace() } });
    if (path.endsWith('/payment_methods')) return route.fulfill({ json: { data: [{ id: 'posmethod-cash', kind: 'cash', name: 'Cash', status: 'active' }] } });
    if (path.endsWith('/sale_1/price_override') || path.endsWith('/sale_1/line_discount') || path.endsWith('/ws_1/discount')) {
      const body = request.postDataJSON();
      expect(body.expected_revision).toBe(revision);
      expect(body.lease_generation).toBe(1);
      expect(body.editor_id).toBeTruthy();
      expect(body.idempotency_key).toBeTruthy();
      if (path.endsWith('/price_override')) {
        expect(body.reason).toBeTruthy();
        unitPrice = Number(body.price);
      } else if (path.endsWith('/line_discount')) {
        if (request.method() === 'DELETE') { itemOverride = null; }
        else {
          expect(body.reason).toBeTruthy();
          expect(['item_flat', 'item_percent']).toContain(body.value_type);
          itemOverride = { type: body.value_type === 'item_percent' ? 'percent' : 'flat', value: Number(body.value) };
        }
      } else invoicePercent = Number(body.value);
      revision++;
      return route.fulfill({ json: { data: workspace() } });
    }
    if (path.endsWith('/ws_1/items') || path.endsWith('/sale_1/update') || path.endsWith('/sale_1/remove')) {
      const body = request.postDataJSON();
      writes.push(body);
      if (writeGate) await writeGate;
      expect(body.expected_revision).toBe(revision);
      expect(body.lease_generation).toBe(1);
      expect(body.idempotency_key).toBeTruthy();
      if (rejectUpdate) return route.fulfill({ status: 422, json: { error: { code: 'invalid' } } });
      quantity = path.endsWith('/remove') ? 0 : body.quantity;
      revision += 1;
      return route.fulfill({ json: { data: workspace() } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('cashier@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('test-only');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.locator('.pos-context-details > summary')).toContainText('Quầy 01');
  await expect(page.locator('.pos-context-details')).not.toHaveAttribute('open');
  await expect(page.locator('.catalog-product')).toHaveCount(12);
  if (testInfo.project.name !== 'mobile') {
    const catalogBox = (await page.locator('.catalog-panel').boundingBox())!;
    const basketBox = (await page.locator('.basket-panel').boundingBox())!;
    const checkoutBox = (await page.locator('.checkout-panel').boundingBox())!;
    expect(basketBox.x).toBe(catalogBox.x);
    expect(basketBox.y).toBeGreaterThanOrEqual(catalogBox.y + catalogBox.height);
    expect(checkoutBox.x).toBeGreaterThanOrEqual(catalogBox.x + catalogBox.width);
    expect(checkoutBox.y).toBe(catalogBox.y);
    expect(checkoutBox.y + checkoutBox.height).toBeCloseTo(basketBox.y + basketBox.height, 0);
  }
  await expect(page.locator('.selling-search > .search-title')).toHaveCount(0);
  await expect(page.locator('#pos-product-search')).toHaveAttribute('placeholder', 'Tìm hàng hoặc quét mã (F2)');
  await expect(page.locator('#pos-product-search')).toHaveAttribute('aria-keyshortcuts', 'F2');
  for (const control of [page.locator('#pos-product-search'), page.locator('.product-search-row > button')]) {
    expect(await control.evaluate((el) => el.getBoundingClientRect().height)).toBe(32);
    expect(await control.evaluate((el) => getComputedStyle(el).fontSize)).toBe(await page.getByRole('button', { name: 'Đơn nháp mới' }).evaluate((el) => getComputedStyle(el).fontSize));
  }
  for (const name of ['Thẻ', 'Danh sách']) {
    const toggle = page.locator('.view-toggle').getByRole('button', { name, exact: true });
    expect(await toggle.evaluate((el) => el.getBoundingClientRect().height)).toBe(32);
    await toggle.click();
    await expect(toggle).toHaveAttribute('aria-pressed', 'true');
  }
  if (testInfo.project.name !== 'mobile') {
    const listRow = await page.locator('.catalog-results--list > li').first().evaluate((li) => {
      const btn = li.querySelector('.catalog-product')!;
      const thumb = li.querySelector('.catalog-image')!.getBoundingClientRect();
      const cells = ['strong', '.catalog-sku', '.catalog-meta > span:last-child', '.catalog-price'].map((sel) => li.querySelector(sel)!.getBoundingClientRect().x);
      return { border: getComputedStyle(li).borderTopWidth, height: btn.getBoundingClientRect().height, thumb: { width: thumb.width, height: thumb.height }, cells };
    });
    expect(listRow.border).toBe('0px');
    expect(listRow.height).toBeLessThanOrEqual(52);
    expect(listRow.thumb).toEqual({ width: 30, height: 30 });
    expect(listRow.cells[0]).toBeLessThan(listRow.cells[1]);
    expect(listRow.cells[1]).toBeLessThan(listRow.cells[2]);
    expect(listRow.cells[2]).toBeLessThan(listRow.cells[3]);
  }
  const catalogHeader = page.locator('.catalog-heading');
  expect(await catalogHeader.evaluate((el) => el.getBoundingClientRect().height)).toBeLessThanOrEqual(testInfo.project.name === 'desktop' ? 50 : 90);
  await expect(catalogHeader.locator('.product-search-row')).toHaveCount(1);
  if (testInfo.project.name === 'desktop') {
    const heading = (await catalogHeader.locator('h3').boundingBox())!;
    const search = (await catalogHeader.locator('form').boundingBox())!;
    const toggle = (await catalogHeader.locator('.view-toggle').boundingBox())!;
    expect(heading.x + heading.width).toBeLessThanOrEqual(search.x);
    expect(search.x + search.width).toBeLessThanOrEqual(toggle.x);
    expect(Math.abs((search.y + search.height / 2) - (heading.y + heading.height / 2))).toBeLessThan(1);
  }
  await expect(page.locator('.basket-heading .basket-actions')).toHaveCount(1);
  await expect(page.locator('.draft-detail .basket-actions')).toHaveCount(0);
  await page.locator('.view-toggle').getByRole('button', { name: 'Thẻ', exact: true }).click();
  await expect(page.locator('.product-add')).toHaveCount(0);
  expect(await page.locator('.catalog-product').first().evaluate((el) => el.getBoundingClientRect().height)).toBeLessThan(124);
  await expect(page.locator('.catalog-product-info strong').nth(1)).toHaveAttribute('title', names[1]);
  const titleMetrics = await page.locator('.catalog-product-info strong').nth(1).evaluate((el) => {
    const lineHeight = Number.parseFloat(getComputedStyle(el).lineHeight);
    return { height: el.getBoundingClientRect().height, maxTwoLines: lineHeight * 2 + 2 };
  });
  expect(titleMetrics.height).toBeLessThanOrEqual(titleMetrics.maxTwoLines);
  const firstCardFill = await page.locator('.catalog-results > li').first().evaluate((li) => {
    const btn = li.querySelector('.catalog-product')!;
    return Math.abs(li.clientHeight - btn.getBoundingClientRect().height);
  });
  expect(firstCardFill).toBeLessThanOrEqual(2);
  await expect(page.locator('.catalog-product').first()).toBeDisabled();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.locator('.catalog-product').first()).toBeEnabled();
  await expect.poll(() => heartbeatRequests).toBe(1);
  await expect(page.getByRole('button', { name: 'Thanh toán' })).toBeDisabled();
  expect(unitRequests).toBe(0); // Closed advanced forms must not fetch units for every product.
  await page.locator('.catalog-advanced > summary').first().click();
  await expect(page.locator('.add-item-form')).toBeVisible();
  await expect.poll(() => unitRequests).toBe(1);
  await page.screenshot({ path: testInfo.outputPath('advanced-item.png'), fullPage: true });
  await page.locator('.catalog-advanced > summary').first().click();
  await expect(page.locator('.add-item-form')).toHaveCount(0);
  await page.keyboard.press('F2');
  const search = page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' });
  await expect(search).toBeFocused();
  await search.fill('Gạo');
  await expect(page.locator('.catalog-product')).toHaveCount(1); // No submit needed.
  const readsBeforeAdd = workspaceReads;
  let releaseWrite: () => void = () => {};
  writeGate = new Promise<void>((resolve) => { releaseWrite = resolve; });
  await page.locator('.catalog-product').click();
  await expect.poll(() => writes.length).toBe(1);
  await expect(page.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toHaveCount(0);
  expect(await page.evaluate(() => Object.keys(JSON.parse(sessionStorage.getItem('parkviet-pos-uncertain-intents') ?? '{}')).length)).toBe(1);
  expect(await page.evaluate(() => {
    const event = new Event('beforeunload', { cancelable: true });
    window.dispatchEvent(event);
    return event.defaultPrevented;
  })).toBe(true);
  releaseWrite();
  writeGate = null;
  const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
  await expect(basket.getByRole('columnheader')).toHaveText(['STT', 'Mã hàng', 'Tên sản phẩm', 'Số lượng', 'Đơn giá', 'Giảm giá', 'Thành tiền']);
  await expect(basket.locator('td.basket-index')).toHaveText(['1']);
  await expect(basket).toContainText('125.000 ₫');
  expect(workspaceReads).toBe(readsBeforeAdd); // Canonical POST response updates basket, no follow-up GET chain.
  await page.getByRole('button', { name: 'Tăng số lượng Gạo thơm 5kg' }).click();
  await expect(basket).toContainText('250.000 ₫');
  await page.getByRole('spinbutton', { name: 'Số lượng Gạo thơm 5kg' }).fill('3');
  await page.getByRole('spinbutton', { name: 'Số lượng Gạo thơm 5kg' }).press('Enter');
  await expect(basket).toContainText('375.000 ₫');
  await expect(page.locator('.checkout-total')).toContainText('375.000 ₫');
  await expect(page.locator('.payment-panel').getByLabel('Tiền mặt')).toHaveValue('375000');
  expect(heartbeatRequests).toBe(1); // Item edits must not restart lease renewal on every response.
  await search.fill('');
  await expect(page.locator('.catalog-product')).toHaveCount(12);
  await page.screenshot({ path: testInfo.outputPath('cashier-layout.png'), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  const smallTargets = await page.evaluate(() => Array.from(document.querySelectorAll('button, input, select, summary, a[href]')).filter((el) => {
    if (!el.checkVisibility() || el.closest('.visually-hidden') || el.classList.contains('skip-link')) return false;
    const box = el.getBoundingClientRect();
    // Quantity controls, inline cell/customer icon buttons and tab close buttons deliberately use 28..32px.
    if (el.matches('.quantity-control button, .cell-edit-button, .workspace-tab-close, .customer-icon-button, .input-clear-button, .checkout-tools > .checkout-optional > summary')) return box.width < 27.5 || box.height < 27.5;
    if (el.matches('.quantity-control input, .line-price-edit > summary, .basket-table .line-options > summary')) return box.height < 29.5;
    const compact = el.matches('.view-toggle button, #pos-product-search, .product-search-row > button, .customer-search-row input, .payment-methods button, .payment-method-row input, .sale-panel-nav a, .basket-actions > button, .basket-actions summary, .item-discount-editor input, .item-discount-editor select, .item-discount-editor button, .item-discount-editor summary');
    return box.width < 43.5 || box.height < (compact ? 31.5 : 43.5);
  }).map((el) => `${el.tagName}.${el.className}: ${el.getAttribute('aria-label') ?? el.textContent?.trim()}`));
  expect(smallTargets).toEqual([]);
  if (testInfo.project.name === 'desktop') {
    const basketTop = await page.locator('.basket-heading').evaluate((el) => el.getBoundingClientRect().top);
    expect(basketTop).toBeLessThan(700);
    const html = await page.locator('.pos-layout').evaluate((el) => el.outerHTML);
    const css = readFileSync('src/styles.css', 'utf8');
    writeFileSync(testInfo.outputPath('cashier-render.html'), `<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>POS UI fixture — not a transaction</title><style>${css}</style></head><body>${html}</body></html>`);
  }
  rejectUpdate = true;
  await page.getByRole('button', { name: 'Giảm số lượng Gạo thơm 5kg' }).click();
  await expect(page.getByRole('alert')).toContainText('Dữ liệu gửi lên không hợp lệ.');
  await expect(basket).toContainText('375.000 ₫');
  expect(writes).toHaveLength(4);
  rejectUpdate = false;
  await basket.getByLabel('Sửa giá bán Gạo thơm 5kg', { exact: true }).click();
  const priceInput = basket.getByLabel('Đơn giá bán Gạo thơm 5kg', { exact: true });
  await priceInput.fill('130000');
  await basket.locator('.line-price-form').getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(basket.locator('.unit-price-original')).toHaveText('125.000 ₫');
  await expect(page.locator('.checkout-total')).toContainText('390.000 ₫');
  await expect(page.locator('.checkout-line').filter({ hasText: 'Giảm giá' })).toContainText('0 ₫');
  await expect(basket.locator('.basket-line-total')).toContainText('390.000 ₫');
  await basket.getByLabel('Sửa giá bán Gạo thơm 5kg', { exact: true }).click();
  await basket.getByLabel('Đơn giá bán Gạo thơm 5kg', { exact: true }).fill('100000');
  await basket.locator('.line-price-form').getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(basket.locator('.unit-price-original')).toHaveText('125.000 ₫');
  await expect(page.locator('.checkout-total')).toContainText('300.000 ₫');
  await expect(page.locator('.checkout-line').filter({ hasText: 'Giảm giá' })).toContainText('0 ₫');
  await expect(basket.locator('.basket-line-total')).toContainText('300.000 ₫');
  await page.getByRole('button', { name: 'Tăng số lượng Gạo thơm 5kg' }).click();
  await expect(page.locator('.checkout-total')).toContainText('400.000 ₫');
  const invoiceDiscount = page.locator('.checkout-optional').filter({ hasText: 'Giảm giá toàn đơn' });
  await invoiceDiscount.locator('summary').click();
  await invoiceDiscount.getByLabel('Lý do').fill('Hóa đơn');
  await invoiceDiscount.getByRole('button', { name: 'Áp dụng giảm giá', exact: true }).click();
  await expect(page.locator('.checkout-total')).toContainText('360.000 ₫');
  await expect(page.locator('.checkout-line').filter({ hasText: 'Giảm giá' })).toContainText('-40.000 ₫');
  await basket.getByLabel('Sửa giá bán Gạo thơm 5kg', { exact: true }).click();
  await basket.getByRole('button', { name: 'Về giá gốc' }).click();
  await expect(basket.locator('.unit-price-original')).toHaveCount(0);
  await expect(page.locator('.checkout-total')).toContainText('450.000 ₫');
  await expect(page.locator('.checkout-line').filter({ hasText: 'Giảm giá' })).toContainText('-50.000 ₫');
  promotionPercent = 10;
  await page.reload();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await basket.locator('.item-discount-edit > summary').click();
  const itemDiscount = basket.getByLabel('Giảm giá Gạo thơm 5kg', { exact: true });
  await expect(itemDiscount).toHaveValue('10');
  await expect(basket.getByLabel('Kiểu giảm giá Gạo thơm 5kg', { exact: true })).toHaveValue('percent');
  await expect(basket.locator('.item-discount-source')).toHaveText('Khuyến mại');
  await itemDiscount.fill('20');
  await itemDiscount.press('Enter');
  await expect(page.locator('.checkout-total')).toContainText('360.000 ₫');
  await basket.locator('.item-discount-edit > summary').click();
  await expect(basket.locator('.item-discount-source')).toHaveText('Đã điều chỉnh');
  await itemDiscount.fill('5');
  await itemDiscount.press('Enter');
  await expect(page.locator('.checkout-total')).toContainText('427.500 ₫');
  await basket.locator('.item-discount-edit > summary').click();
  await basket.getByLabel('Kiểu giảm giá Gạo thơm 5kg', { exact: true }).selectOption('flat');
  await itemDiscount.fill('10000');
  await itemDiscount.press('Enter');
  await expect(page.locator('.checkout-total')).toContainText('441.000 ₫');
  await basket.locator('.item-discount-edit > summary').click();
  await itemDiscount.fill('0');
  await itemDiscount.press('Enter');
  await expect(page.locator('.checkout-total')).toContainText('450.000 ₫');
  await basket.locator('.item-discount-edit > summary').click();
  await basket.getByRole('button', { name: 'Khuyến mại tự động', exact: true }).click();
  await expect(page.locator('.checkout-total')).toContainText('405.000 ₫');
  await expect(basket.locator('.basket-line-total')).toContainText('450.000 ₫');
  await basket.locator('.item-discount-edit > summary').click();
  await expect(itemDiscount).toHaveValue('10');
  await basket.locator('.item-discount-edit').getByRole('button', { name: 'Đóng', exact: true }).click();
  await page.screenshot({ path: testInfo.outputPath('item-discount-columns.png'), fullPage: true });
  // Stress only the presentation DOM, not application money/state: each panel
  // must scroll independently without pushing the document beyond its viewport.
  await page.evaluate(() => {
    for (const selector of ['.catalog-results', '.basket-lines', '.checkout-section']) {
      const list = document.querySelector(selector)!;
      const template = list.firstElementChild!;
      for (let i = 0; i < 30; i++) list.append(template.cloneNode(true));
    }
  });
  for (const selector of ['.catalog-panel', '.basket-panel', '.checkout-panel']) {
    await page.locator(selector).evaluate((el) => el.scrollIntoView({ block: 'nearest', inline: 'start' }));
    const positions = await page.evaluate((selector) => {
      const pane = document.querySelector(selector)!;
      document.querySelectorAll('.sale-layout > *').forEach((el) => { el.scrollTop = 0; });
      const header = pane.querySelector('.catalog-heading, .basket-heading');
      const headerTop = header?.getBoundingClientRect().top;
      pane.scrollTop = 100;
      return { headerTop, scrolledHeaderTop: header?.getBoundingClientRect().top, top: pane.scrollTop, other: Array.from(document.querySelectorAll('.sale-layout > *')).filter((el) => el !== pane).map((el) => el.scrollTop), doc: document.documentElement.scrollHeight, height: innerHeight, boxes: Array.from(document.querySelectorAll('body, #root, main, .shell, .draft-workspace, .sale-layout, .sale-layout > *')).map(el => ({tag: el.tagName, cls: el.className, height: el.getBoundingClientRect().height, scroll: el.scrollHeight, overflow: getComputedStyle(el).overflow, min: getComputedStyle(el).minHeight})) };
    }, selector);
    expect(positions.top).toBeGreaterThan(0);
    expect(positions.other).toEqual([0, 0]);
    expect(positions.doc, JSON.stringify(positions)).toBeLessThanOrEqual(positions.height);
    if (positions.headerTop !== undefined) expect(positions.scrolledHeaderTop).toBeCloseTo(positions.headerTop, 0);
  }
  await page.locator('.basket-panel').evaluate((el) => el.scrollIntoView({ block: 'nearest', inline: 'start' }));
  await page.locator('.basket-heading .order-more > summary').click();
  await expect(page.locator('.basket-heading .order-more-menu').getByRole('button', { name: 'Hủy nháp', exact: true })).toBeVisible();
  await page.locator('.basket-heading .order-more > summary').click();
  if (testInfo.project.name === 'desktop') {
    // No width cap even on an ultra-wide cashier screen.
    await page.setViewportSize({ width: 2560, height: 1080 });
    const bounds = await page.locator('.sale-layout').boundingBox();
    expect(bounds!.width).toBeGreaterThan(2500);
    const catalogBox = (await page.locator('.catalog-panel').boundingBox())!;
    const basketBox = (await page.locator('.basket-panel').boundingBox())!;
    const checkoutBox = (await page.locator('.checkout-panel').boundingBox())!;
    expect(basketBox.x).toBe(catalogBox.x);
    expect(basketBox.y).toBeGreaterThanOrEqual(catalogBox.y + catalogBox.height);
    expect(checkoutBox.x).toBeGreaterThanOrEqual(catalogBox.x + catalogBox.width);
    expect(checkoutBox.y).toBe(catalogBox.y);
    expect(checkoutBox.y + checkoutBox.height).toBeCloseTo(basketBox.y + basketBox.height, 0);
    await page.screenshot({ path: testInfo.outputPath('full-width-stacked-selling.png') });
  }
  expect(errors).toEqual([]);
});
