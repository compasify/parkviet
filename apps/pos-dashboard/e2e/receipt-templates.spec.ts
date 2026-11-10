import { expect, type Locator, type Page, test } from '@playwright/test';
import { DEFAULT_TEMPLATES } from '@parkviet/pos-shared/receipt-template/defaults';
import type { DocumentType, TemplateConfig } from '@parkviet/pos-shared/receipt-template/types';
import { installDashboardShell } from './support/dashboard';

// Presentation fixtures retain immutable versions, stale writes and 422 JSON
// pointers from the POS suite. They never modify the real API or grant access.
type Template = { id: string; document_type: DocumentType; name: string; paper: string; status: 'active' | 'disabled'; is_default: boolean; current_version: number; updated_at: string };
type Version = { version: number; config: TemplateConfig; created_at: string };
type Write = { method: string; path: string; body: Record<string, unknown> | null };
const staff = { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' };
const branch = { id: 'branch_main', name: 'Chi nhánh Quận 1', code: 'q1', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null, return_window_days: 7 };
const register = { id: 'register_2', branch_id: branch.id, name: 'Quầy 2', code: 'Q2', status: 'active' };
const profile = { address: '12 Lê Lợi, Quận 1', contact_phone: '0901 234 567', customer_support_email: null, url: null, facebook: null, instagram: null, logo_url: null };
const NAMES: Record<DocumentType, string> = { sale: 'Phiếu bán hàng', prebill: 'Phiếu tạm tính', payment_ticket: 'Phiếu thanh toán', return: 'Phiếu trả hàng', refund: 'Phiếu hoàn tiền', shift_closure: 'Phiếu chốt ca' };

async function install(page: Page, access = { read: true, write: true }) {
  const clone = <T,>(value: T): T => JSON.parse(JSON.stringify(value)) as T;
  const templates: Template[] = (Object.keys(NAMES) as DocumentType[]).map((type, index) => ({ id: `postpl_${index + 1}`, document_type: type, name: NAMES[type], paper: '80mm', status: 'active', is_default: true, current_version: 1, updated_at: '2026-11-08T02:00:00Z' }));
  const versions = new Map<string, Version[]>(templates.map((template) => [template.id, [{ version: 1, config: clone(DEFAULT_TEMPLATES[template.document_type]), created_at: '2026-11-08T02:00:00Z' }]]));
  const state = { writes: [] as Write[], nextPatch: '' as '' | 'conflict' | 'invalid', editBeforeRestore: false, versionsRequests: 0, latestRequests: 0 };
  const toPos = (template: Template) => ({ ...template, version: template.current_version, created_at: '2026-11-08T02:00:00Z', config: versions.get(template.id)?.find((version) => version.version === template.current_version)?.config, updated_by: { id: staff.id, name: staff.full_name } });
  const revise = (template: Template, config: TemplateConfig) => { template.current_version += 1; template.updated_at = '2026-11-08T03:00:00Z'; versions.get(template.id)?.push({ version: template.current_version, config: clone(config), created_at: template.updated_at }); };
  const create = (source: Template, name: string, paper: string, config: TemplateConfig) => { const created: Template = { ...source, id: `postpl_${templates.length + 1}`, name, paper, status: 'active', is_default: false, current_version: 1 }; templates.push(created); versions.set(created.id, [{ version: 1, config: clone(config), created_at: '2026-11-08T03:00:00Z' }]); return created; };
  await page.addInitScript(() => {
    window.print = () => {
      const root = window.top as unknown as { printedSheets?: string[] };
      root.printedSheets ??= [];
      root.printedSheets.push(document.querySelector('[data-testid="receipt-template-test-print"]')?.textContent ?? '');
    };
  });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', ''); const method = request.method();
    const body = method === 'GET' ? null : ((request.postDataJSON() ?? {}) as Record<string, unknown>);
    if (method !== 'GET' && !/\/auth\//.test(path)) state.writes.push({ method, path, body });
    const notFound = () => route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'Not found' } } });
    const stale = (template: Template) => route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Stale.', details: { reason: 'template_version_conflict', current_version: template.current_version } } } });
    if (path === '/pos/context') return route.fulfill({ json: { staff, store: { id: 'store_1', name: 'Park Việt', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh', profile }, administration: access, capabilities: [], branches: [branch], registers: [register], shift: null, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null } } });
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/registers') return route.fulfill({ json: { data: [register], meta: { next: null } } });
    if (path === '/pos/memberships') return route.fulfill({ json: { data: [{ id: 'membership_1', staff_id: staff.id, branch_id: branch.id, status: 'active' }], meta: { next: null } } });
    if (path === '/pos/receipts') { state.latestRequests += 1; return route.fulfill({ json: { data: [], meta: { next: null } } }); }
    const match = /^\/pos\/receipt_templates(?:\/([^/]+))?(?:\/(versions|duplicate|default|restore|disable))?$/.exec(path);
    if (!match) return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
    const [, id, action] = match;
    if (!id && method === 'GET') return route.fulfill({ json: { data: templates.filter((template) => url.searchParams.get('include_disabled') === '1' || template.status === 'active').map(toPos) } });
    if (!id && method === 'POST') { const type = body?.from_default as DocumentType; const source = templates.find((template) => template.document_type === type && template.is_default); if (!source) return notFound(); return route.fulfill({ status: 201, json: { data: toPos(create(source, String(body?.name), String(body?.paper), DEFAULT_TEMPLATES[type])) } }); }
    const template = templates.find((item) => item.id === id); if (!template) return notFound();
    if (!action && method === 'GET') return route.fulfill({ json: { data: toPos(template) } });
    if (action === 'versions') { state.versionsRequests += 1; if (!access.write) return route.fulfill({ status: 403, json: { error: { code: 'forbidden' } } }); const rows = [...(versions.get(template.id) ?? [])].reverse().map((version) => ({ ...version, created_by: { id: staff.id, name: staff.full_name } })); return route.fulfill({ json: { data: rows, meta: { next: null } } }); }
    if (!action && method === 'PATCH') {
      if (state.nextPatch === 'conflict') { state.nextPatch = ''; revise(template, versions.get(template.id)?.at(-1)?.config as TemplateConfig); return stale(template); }
      if (state.nextPatch === 'invalid') { state.nextPatch = ''; return route.fulfill({ status: 422, json: { error: { code: 'validation_error', message: 'value must be at most 500 characters.', details: { errors: [{ pointer: '/config/footer/0/value', code: 'too_long', message: 'value must be at most 500 characters.' }] } } } }); }
      if (body?.expected_version !== template.current_version) return stale(template);
      template.name = String(body?.name); template.paper = String(body?.paper); revise(template, body?.config as TemplateConfig); return route.fulfill({ json: { data: toPos(template) } });
    }
    if (action === 'duplicate') return route.fulfill({ status: 201, json: { data: toPos(create(template, `${template.name} (bản sao)`, template.paper, versions.get(template.id)?.at(-1)?.config as TemplateConfig)) } });
    if (action === 'default') { for (const other of templates) if (other.document_type === template.document_type) other.is_default = other.id === template.id; return route.fulfill({ json: { data: toPos(template) } }); }
    if (action === 'disable') { template.status = 'disabled'; template.is_default = false; return route.fulfill({ json: { data: toPos(template) } }); }
    if (action === 'restore') { if (state.editBeforeRestore) { state.editBeforeRestore = false; revise(template, versions.get(template.id)?.at(-1)?.config as TemplateConfig); } if (body?.expected_version !== template.current_version) return stale(template); const source = versions.get(template.id)?.find((version) => version.version === body?.version); if (!source) return notFound(); revise(template, source.config); return route.fulfill({ json: { data: toPos(template) } }); }
    return notFound();
  });
  // Shell is last so only shell requests are consumed before POS fixtures.
  await installDashboardShell(page, { ...access, authenticated: true });
  return { state, templates };
}

async function openTemplates(page: Page) { await page.goto('/store_1/settings/receipt-templates'); await expect(page.getByRole('heading', { level: 1 })).toHaveText('Mẫu in'); }
async function show(page: Page, pane: 'Chỉnh sửa' | 'Xem trước') {
  // The toggle only exists once the editor loads; wait for it before
  // deciding, or tablet/mobile miss the click while the skeleton shows.
  // On desktop the toggle is permanently hidden (both panes show) and the
  // wait attaches without blocking.
  await page.getByLabel('Tên mẫu').waitFor({ state: 'attached' });
  const toggle = page.getByRole('button', { name: pane, exact: true });
  if (await toggle.isVisible()) await toggle.click();
  await expect(pane === 'Xem trước' ? preview(page) : page.getByLabel('Tên mẫu')).toBeVisible();
}
async function openSection(page: Page, title: string) { const trigger = page.getByRole('button', { name: new RegExp(`^${title}`) }); if ((await trigger.getAttribute('aria-expanded')) !== 'true') { await trigger.focus(); await page.keyboard.press('Enter'); } await expect(trigger).toHaveAttribute('aria-expanded', 'true'); return trigger.locator('xpath=../..'); }
async function choose(page: Page, owner: Page | Locator, label: string, option: string) { await owner.getByRole('combobox', { name: label, exact: true }).click(); await page.getByRole('option', { name: option, exact: true }).click(); }
const preview = (page: Page) => page.frameLocator('[data-testid="receipt-template-preview-frame"]').getByTestId('receipt-template-preview');
const versionPreview = (page: Page) => page.frameLocator('[data-testid="receipt-template-version-preview-frame"]').getByTestId('receipt-template-version-preview');
const printed = (page: Page) => page.evaluate(() => (window as unknown as { printedSheets?: string[] }).printedSheets ?? []);

test('create, edit variables, save, test print, default, duplicate, disable and restore', async ({ page }) => {
  const { state } = await install(page); page.on('dialog', (dialog) => dialog.accept()); await openTemplates(page);
  const saleList = page.getByRole('list', { name: 'Mẫu Phiếu bán hàng' });
  await expect(saleList.getByRole('listitem')).toHaveCount(1); await expect(saleList).toContainText('Mặc định'); await expect(saleList).toContainText('80mm · phiên bản 1');
  await page.getByRole('button', { name: 'Tạo mẫu', exact: true }).click(); const create = page.getByRole('dialog', { name: 'Tạo mẫu in' });
  await choose(page, create, 'Loại chứng từ', 'Phiếu bán hàng'); await create.getByRole('radio', { name: '58mm', exact: true }).check(); await create.getByLabel('Tên mẫu').fill('Bán hàng K58'); await create.getByRole('button', { name: 'Tạo và chỉnh sửa', exact: true }).click();
  await expect(page).toHaveURL(/\/settings\/receipt-templates\/postpl_7$/); expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/receipt_templates', body: { from_default: 'sale', name: 'Bán hàng K58', paper: '58mm' } });
  const totals = await openSection(page, 'Tổng & thanh toán'); await expect(totals.getByRole('checkbox', { name: 'Tổng cộng', exact: true })).toBeChecked(); await expect(totals.getByRole('checkbox', { name: 'Tổng cộng', exact: true })).toBeDisabled();
  const header = await openSection(page, 'Đầu phiếu'); await expect(header.getByRole('button', { name: 'Xóa Khối 3: Tiêu đề chứng từ' })).toBeDisabled(); await expect(header).toContainText('Nhãn “BẢN SAO” khi in lại');
  const footer = await openSection(page, 'Chân phiếu'); await expect(footer).toContainText('không phải hóa đơn điện tử'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click();
  const text = footer.getByRole('listitem', { name: 'Khối 1: Văn bản' }).getByRole('textbox', { name: 'Nội dung' }); await text.pressSequentially('Cảm ơn {store.na'); await expect(footer.getByRole('listbox', { name: 'Thông tin có thể chèn' })).toBeVisible(); await page.keyboard.press('Enter'); await expect(text).toHaveValue('Cảm ơn {store.name}');
  await text.pressSequentially(' - '); await footer.getByRole('button', { name: 'Chèn thông tin' }).click(); const options = footer.getByRole('listbox', { name: 'Thông tin có thể chèn' }); await expect(options.getByRole('option', { name: /\{branch\.name\}/ })).toContainText('Chi nhánh Quận 1'); await options.getByRole('option', { name: /\{branch\.name\}/ }).click(); await expect(text).toHaveValue('Cảm ơn {store.name} - {branch.name}');
  await show(page, 'Xem trước'); await expect(preview(page)).toContainText('Cảm ơn Park Việt - Chi nhánh Quận 1'); await expect(preview(page)).toHaveAttribute('data-paper', '58mm'); await show(page, 'Chỉnh sửa');
  await choose(page, footer, 'Loại khối', 'Đường kẻ'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); await footer.getByRole('button', { name: 'Đưa lên: Khối 2: Đường kẻ' }).focus(); await page.keyboard.press('Enter'); await expect(footer.getByRole('button', { name: 'Đưa lên: Khối 1: Đường kẻ' })).toBeFocused();
  await page.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã lưu phiên bản 2.' })).toBeVisible(); expect(state.writes.at(-1)).toMatchObject({ method: 'PATCH', body: { expected_version: 1, name: 'Bán hàng K58', paper: '58mm' } }); expect((state.writes.at(-1)?.body?.config as TemplateConfig).footer).toEqual([{ type: 'divider', style: 'dashed' }, { type: 'text', value: 'Cảm ơn {store.name} - {branch.name}', align: 'center' }]);
  await page.getByRole('button', { name: 'In thử', exact: true }).click(); await expect.poll(async () => (await printed(page)).length).toBe(1); expect((await printed(page))[0]).toContain('IN THỬ — KHÔNG CÓ GIÁ TRỊ'); expect((await printed(page))[0]).toContain('Cảm ơn Park Việt'); expect(state.writes.filter((write) => write.path.includes('/prints') || write.path.includes('/receipts'))).toEqual([]);
  await page.reload(); const reloaded = await openSection(page, 'Chân phiếu'); await expect(reloaded.getByRole('listitem', { name: 'Khối 2: Văn bản' }).getByRole('textbox', { name: 'Nội dung' })).toHaveValue('Cảm ơn {store.name} - {branch.name}');
  await page.getByRole('link', { name: 'Về danh sách mẫu in' }).click(); await expect(saleList.getByRole('listitem')).toHaveCount(2); await saleList.getByRole('button', { name: 'Đặt mẫu Bán hàng K58 làm mặc định' }).click(); await expect(page.getByRole('status').filter({ hasText: '“Bán hàng K58” là mẫu mặc định.' })).toBeVisible(); await expect(saleList.getByRole('listitem').filter({ hasText: 'Phiếu bán hàng' })).not.toContainText('Mặc định');
  await saleList.getByRole('button', { name: 'Nhân bản mẫu Bán hàng K58', exact: true }).click(); await expect(saleList.getByRole('listitem').filter({ hasText: 'Bán hàng K58 (bản sao)' })).toBeVisible(); await saleList.getByRole('button', { name: 'Ngừng dùng mẫu Bán hàng K58 (bản sao)' }).click(); await page.getByRole('dialog').getByRole('button', { name: 'Ngừng dùng', exact: true }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã ngừng dùng “Bán hàng K58 (bản sao)”.' })).toBeVisible();
  expect(state.writes.map((write) => write.path).slice(-3)).toEqual(['/pos/receipt_templates/postpl_7/default', '/pos/receipt_templates/postpl_7/duplicate', '/pos/receipt_templates/postpl_8/disable']);
  await saleList.getByRole('link', { name: 'Sửa mẫu Bán hàng K58', exact: true }).click(); await page.getByRole('button', { name: 'Lịch sử', exact: true }).click(); const drawer = page.getByRole('dialog', { name: 'Lịch sử phiên bản · Bán hàng K58' }); const list = drawer.getByRole('list', { name: 'Các phiên bản' }); await expect(list.getByRole('listitem')).toHaveCount(2); await expect(versionPreview(page)).toContainText('Cảm ơn Park Việt'); await list.getByRole('button', { name: /^Phiên bản 1/ }).click(); await expect(versionPreview(page)).not.toContainText('Cảm ơn'); await drawer.getByRole('button', { name: 'Khôi phục phiên bản 1' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã khôi phục phiên bản 1 thành phiên bản 3.' })).toBeVisible(); expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/receipt_templates/postpl_7/restore', body: { version: 1, expected_version: 2 } }); await show(page, 'Xem trước'); await expect(preview(page)).not.toContainText('Cảm ơn');
});

test('read-only administrators see previews without write controls or history requests', async ({ page }) => {
  const { state } = await install(page, { read: true, write: false }); await openTemplates(page);
  for (const name of ['Tạo mẫu', 'Nhân bản', 'Đặt mặc định', 'Ngừng dùng']) await expect(page.getByRole('button', { name, exact: true })).toHaveCount(0);
  await page.getByRole('link', { name: 'Xem mẫu Phiếu bán hàng' }).click(); await expect(page.getByRole('heading', { level: 1 })).toHaveText('Chỉnh mẫu in · Phiếu bán hàng');
  for (const name of ['Lưu', 'Lịch sử', 'Khôi phục mặc định']) await expect(page.getByRole('button', { name, exact: true })).toHaveCount(0);
  await expect(page.getByLabel('Tên mẫu')).toBeDisabled(); const footer = await openSection(page, 'Chân phiếu'); await expect(footer.getByRole('button', { name: 'Thêm khối chân phiếu' })).toHaveCount(0); await show(page, 'Xem trước'); await expect(preview(page)).toContainText('Park Việt'); await expect(preview(page)).toContainText('PHIẾU BÁN HÀNG'); expect(state.writes).toEqual([]); expect(state.versionsRequests).toBe(0);
});

test('stale edits preserve the draft, validation marks blocks, leaving requires consent', async ({ page }) => {
  const { state } = await install(page); page.on('dialog', (dialog) => dialog.accept()); await openTemplates(page); await page.getByRole('link', { name: 'Sửa mẫu Phiếu bán hàng', exact: true }).click(); await page.getByLabel('Tên mẫu').fill('Phiếu bán hàng K80');
  state.nextPatch = 'conflict'; await page.getByRole('button', { name: 'Lưu', exact: true }).click(); const conflict = page.getByRole('alert').filter({ hasText: 'Mẫu vừa được người khác sửa' }); await expect(conflict).toBeVisible(); await expect(page.getByLabel('Tên mẫu')).toHaveValue('Phiếu bán hàng K80'); await conflict.getByRole('button', { name: 'Ghi đè bằng thay đổi của tôi' }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã lưu phiên bản 3.' })).toBeVisible(); expect(state.writes.at(-1)).toMatchObject({ method: 'PATCH', body: { expected_version: 2 } });
  const footer = await openSection(page, 'Chân phiếu'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); const block = footer.getByRole('listitem', { name: 'Khối 1: Văn bản' }); await block.getByRole('textbox', { name: 'Nội dung' }).fill('Hotline {store.hotline}'); await expect(block).toHaveAttribute('data-invalid', 'true'); await expect(block).toContainText('Có thông tin chèn không hợp lệ'); const writes = state.writes.length; await page.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(page.getByRole('alert').filter({ hasText: 'Hãy sửa các lỗi được đánh dấu trước khi lưu.' })).toBeVisible(); expect(state.writes).toHaveLength(writes);
  await block.getByRole('textbox', { name: 'Nội dung' }).fill('Hotline {store.phone}'); await expect(block).not.toHaveAttribute('data-invalid', 'true'); state.nextPatch = 'invalid'; await page.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(page.getByRole('alert').filter({ hasText: 'Máy chủ chưa nhận mẫu' })).toBeVisible(); await expect(block).toHaveAttribute('data-invalid', 'true'); await expect(block).toContainText('Quá dài.'); await expect(page.getByRole('button', { name: /^Chân phiếu/ })).toContainText('1 lỗi');
  page.removeAllListeners('dialog'); page.once('dialog', (dialog) => { expect(dialog.message()).toContain('thay đổi chưa lưu'); void dialog.dismiss(); }); await page.getByRole('link', { name: 'Về danh sách mẫu in' }).click(); await expect(page).toHaveURL(/\/settings\/receipt-templates\/postpl_1$/); await expect(block.getByRole('textbox', { name: 'Nội dung' })).toHaveValue('Hotline {store.phone}');
});

test('stale restore retries the original version, never overwriting with the draft', async ({ page }) => {
  const { state } = await install(page); page.on('dialog', (dialog) => dialog.accept()); await openTemplates(page); await page.getByRole('link', { name: 'Sửa mẫu Phiếu tạm tính', exact: true }).click(); await page.getByLabel('Tên mẫu').fill('Tạm tính K80'); await page.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã lưu phiên bản 2.' })).toBeVisible();
  state.editBeforeRestore = true; await page.getByRole('button', { name: 'Lịch sử', exact: true }).click(); await page.getByRole('dialog').getByRole('button', { name: 'Khôi phục phiên bản 1' }).click(); const conflict = page.getByRole('alert').filter({ hasText: 'Mẫu vừa được người khác sửa' }); await expect(conflict).toBeVisible(); expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/receipt_templates/postpl_2/restore', body: { version: 1, expected_version: 2 } }); await expect(conflict.getByRole('button', { name: 'Ghi đè bằng thay đổi của tôi' })).toHaveCount(0); const patches = state.writes.filter((write) => write.method === 'PATCH').length;
  await conflict.getByRole('button', { name: 'Vẫn khôi phục phiên bản 1' }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã khôi phục phiên bản 1 thành phiên bản 4.' })).toBeVisible(); expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/receipt_templates/postpl_2/restore', body: { version: 1, expected_version: 3 } }); expect(state.writes.filter((write) => write.method === 'PATCH')).toHaveLength(patches); await expect(conflict).toHaveCount(0);
});

test('keyboard/pointer ordering, QR, barcodes, signatures, copies, overflow and scoped CSS', async ({ page }) => {
  const { state } = await install(page); await openTemplates(page); await page.getByRole('link', { name: 'Sửa mẫu Phiếu bán hàng', exact: true }).click(); const header = await openSection(page, 'Đầu phiếu'); const handle = (name: string) => header.getByRole('button', { name: `Kéo để sắp xếp ${name}` });
  await handle('Khối 1: Thông tin cửa hàng').focus(); await page.keyboard.press('Enter'); await expect(handle('Khối 1: Thông tin cửa hàng')).toHaveAttribute('aria-pressed', 'true'); await page.keyboard.press('ArrowDown'); await expect(handle('Khối 2: Thông tin cửa hàng')).toBeFocused(); await page.keyboard.press('Escape'); await expect(handle('Khối 1: Thông tin cửa hàng')).toBeFocused(); await page.keyboard.press('Enter'); await page.keyboard.press('ArrowDown'); await page.keyboard.press('Enter'); await expect(handle('Khối 2: Thông tin cửa hàng')).toHaveAttribute('aria-pressed', 'false');
  await handle('Khối 3: Tiêu đề chứng từ').scrollIntoViewIfNeeded(); const grip = await handle('Khối 3: Tiêu đề chứng từ').boundingBox(); const first = await header.getByRole('listitem', { name: 'Khối 1: Văn bản' }).boundingBox(); if (!grip || !first) throw new Error('Blocks are not laid out'); await page.mouse.move(grip.x + grip.width / 2, grip.y + grip.height / 2); await page.mouse.down(); await page.mouse.move(first.x + 40, first.y + 4, { steps: 6 }); await expect(header.getByRole('listitem', { name: 'Khối 1: Văn bản' })).toHaveAttribute('data-drop', 'before'); await page.mouse.up(); await expect(header.getByRole('listitem', { name: 'Khối 1: Tiêu đề chứng từ' })).toBeVisible();
  const footer = await openSection(page, 'Chân phiếu'); await choose(page, footer, 'Loại khối', 'Mã QR'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); const qr = footer.getByRole('listitem', { name: 'Khối 1: Mã QR' }); await qr.getByLabel('Đường link (http:// hoặc https://)').fill('javascript:alert(1)'); await expect(qr).toContainText('Đường link phải bắt đầu bằng http:// hoặc https://.'); await qr.getByLabel('Đường link (http:// hoặc https://)').fill('https://zalo.me/parkviet'); await qr.getByLabel('Chú thích dưới mã (không bắt buộc)').fill('Zalo OA'); await expect(qr.locator('[data-template-error]')).toHaveCount(0); await choose(page, footer, 'Loại khối', 'Mã vạch số chứng từ'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click();
  await show(page, 'Xem trước'); await expect(preview(page).locator('[data-qr-value="https://zalo.me/parkviet"]')).toContainText('Zalo OA'); await expect(preview(page).locator('[data-qr-value] svg path').first()).toHaveAttribute('d', /^M\d/); await expect(preview(page).locator('[data-barcode-value="R100245"] rect').first()).toBeAttached();
  // receipt.css lives only in the preview frame, never in the settings page.
  await expect(page.locator('.receipt-sheet')).toHaveCount(0); await expect(preview(page)).toHaveCSS('color', 'rgb(0, 0, 0)');
  await show(page, 'Chỉnh sửa'); const pageSection = await openSection(page, 'Trang & giấy'); await pageSection.getByRole('radio', { name: 'A4', exact: true }).check(); await choose(page, pageSection, 'Số liên mỗi lần in', '2 liên'); const lines = await openSection(page, 'Dòng hàng'); await choose(page, lines, 'Kiểu trình bày', 'Bảng'); await choose(page, footer, 'Loại khối', 'Ô chữ ký'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); await footer.getByRole('listitem', { name: 'Khối 3: Ô chữ ký' }).getByLabel('Nhãn ô Người bán').fill('Nhân viên');
  await show(page, 'Xem trước'); await expect(preview(page).locator('table.receipt-grid th').first()).toHaveText('Tên hàng'); await expect(preview(page).locator('.receipt-signatures')).toContainText('Người mua'); await expect(preview(page).locator('.receipt-signatures')).toContainText('Nhân viên');
  await show(page, 'Chỉnh sửa'); await pageSection.getByRole('radio', { name: '58mm', exact: true }).check(); await choose(page, footer, 'Loại khối', 'Văn bản'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); const long = 'Đổi trả trong bảy ngày khi còn hóa đơn và tem nhãn'; await footer.getByRole('listitem', { name: 'Khối 4: Văn bản' }).getByRole('textbox', { name: 'Nội dung' }).fill(long); await expect(footer.getByRole('listitem', { name: 'Khối 4: Văn bản' })).toContainText('khoảng 32 ký tự'); await show(page, 'Xem trước'); await expect(preview(page).getByTestId('receipt-overflow')).toHaveText(long.slice(32)); await expect(preview(page).locator('.receipt-signatures')).toHaveCount(0);
  await show(page, 'Chỉnh sửa'); await page.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(page.getByRole('status').filter({ hasText: 'Đã lưu phiên bản 2.' })).toBeVisible(); const config = state.writes.at(-1)?.body?.config as TemplateConfig; expect(config.page.copies).toBe(2); expect(config.header.map((block) => block.type)).toEqual(['title', 'text', 'business']); expect(config.footer).toEqual([{ type: 'qr', source: 'url', value: 'https://zalo.me/parkviet', align: 'center', caption: 'Zalo OA' }, { type: 'barcode', align: 'center' }, { type: 'signatures', parties: ['buyer', 'seller'], labels: { seller: 'Nhân viên' } }, { type: 'text', value: long, align: 'center' }]);
});

test('latest receipt fallback and restoring defaults remain local until saved', async ({ page }) => {
  const { state } = await install(page); await openTemplates(page); await page.getByRole('link', { name: 'Sửa mẫu Phiếu bán hàng', exact: true }).click(); await show(page, 'Xem trước'); await choose(page, page, 'Dữ liệu xem trước', 'Phiếu gần nhất'); await expect.poll(() => state.latestRequests).toBe(1); await expect(preview(page)).toContainText('Park Việt');
  await show(page, 'Chỉnh sửa'); const footer = await openSection(page, 'Chân phiếu'); await footer.getByRole('button', { name: 'Thêm khối chân phiếu' }).click(); await footer.getByRole('textbox', { name: 'Nội dung' }).fill('Bản nháp'); await page.getByRole('button', { name: 'Khôi phục mặc định', exact: true }).click(); await expect(footer.getByRole('textbox', { name: 'Nội dung' })).toHaveCount(0); expect(state.writes).toEqual([]);
});
