import { expect, type Page, test } from '@playwright/test';
import { BUSINESS_PROFILES, PROFILE_MODULES, profileOf } from './support/business-profiles';

// First-run store setup (plan 261108-1830, phase 4): a store with neither a
// profile nor an active branch sends whoever may set it up to /setup. Five
// steps, one POST /pos/onboarding at the end, one idempotency key for the
// same answers. Presentation fixtures only: no real account privileges.

const staff = { id: 'staff_owner', full_name: 'Chủ cửa hàng', email: 'owner@example.test' };
const FULL = ['pos.shift.open', 'pos.payment.collect', 'pos.discount.apply', 'pos.customer.write', 'pos.topology.manage'];

type Branch = { id: string; name: string; code: string; status: string; timezone: string; stock_location_id: string; profile_key: string };
type Register = { id: string; branch_id: string; name: string; code: string; status: string };

type SetupWorld = {
  canSetup: boolean;
  locations: Array<{ id: string; name: string; active: boolean }>;
  branches: Branch[];
  registers: Register[];
  granted: boolean;
  // POST /pos/onboarding as received: Idempotency-Key header and body.
  posts: Array<{ key: string | null; body: Record<string, unknown> }>;
  // Committed results by key, with the body they answered.
  results: Map<string, { body: string; json: unknown }>;
  // Answers to lose after the command committed (the SDK itself retries twice).
  lose: number;
};

function newSetupWorld(extra: Partial<SetupWorld> = {}): SetupWorld {
  return {
    canSetup: true,
    locations: [
      { id: 'sloc_main', name: 'Kho chính', active: true },
      { id: 'sloc_old', name: 'Kho cũ', active: false },
      { id: 'sloc_2', name: 'Kho phụ', active: true },
    ],
    branches: [],
    registers: [],
    granted: false,
    posts: [],
    results: new Map(),
    lose: 0,
    ...extra,
  };
}

const page1 = (data: unknown[]) => ({ data, meta: { page: 1, pages: 1, count: data.length, next: null } });

async function installSetupApi(page: Page, world: SetupWorld) {
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/auth/logout') return route.fulfill({ json: {} });
    if (path === '/me') return route.fulfill({ json: { user: staff } });
    const onboarded = world.branches.length > 0;
    if (path === '/pos/context') {
      const branchId = url.searchParams.get('branch_id');
      const registerId = url.searchParams.get('register_id');
      const branch = world.branches.find((row) => row.id === branchId);
      return route.fulfill({
        json: {
          staff,
          store: { id: 'store_new', name: 'Cửa hàng mới', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          administration: { read: world.canSetup, write: world.canSetup },
          capabilities: branch && world.granted ? FULL : [],
          features: {},
          modules: branch ? Object.fromEntries(PROFILE_MODULES[branch.profile_key].map((key) => [key, true])) : {},
          module_usage: { 'retail.traceability': false },
          profile: branch ? { key: branch.profile_key, version: 1, display: profileOf(branch.profile_key)?.display ?? {} } : null,
          onboarding: { required: !onboarded, can_setup: world.canSetup },
          branches: world.branches,
          registers: world.registers.filter((row) => row.branch_id === branchId),
          shift: null,
          selection: { branch_id: branchId, register_id: registerId },
        },
      });
    }
    if (path === '/pos/context/branches') return route.fulfill({ json: page1(world.branches) });
    if (path === '/pos/context/registers')
      return route.fulfill({ json: page1(world.registers.filter((row) => row.branch_id === url.searchParams.get('branch_id'))) });
    if (path === '/pos/business_profiles') return route.fulfill({ json: { data: BUSINESS_PROFILES } });
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: world.locations, meta: { next: null } } });
    if (path === '/pos/onboarding' && method === 'POST') {
      const key = request.headers()['idempotency-key'] ?? null;
      const body = (request.postDataJSON() ?? {}) as Record<string, unknown>;
      world.posts.push({ key, body });
      if (!key) return route.fulfill({ status: 422, json: { error: { code: 'parameter_invalid', message: 'Idempotency-Key is required.' } } });
      const stored = world.results.get(key);
      if (stored && stored.body !== JSON.stringify(body))
        return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Idempotency key was reused with a different payload.' } } });
      if (!stored) {
        if (onboarded)
          return route.fulfill({
            status: 409,
            json: { error: { code: 'conflict', message: 'This store is already set up.', details: { reason: 'already_onboarded' } } },
          });
        const profile = profileOf(String(body.profile_key));
        if (!profile || profile.status !== 'available')
          return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Unavailable.', details: { reason: 'profile_unavailable' } } } });
        const input = body.branch as Record<string, unknown>;
        const branch: Branch = {
          id: `posbranch_${world.branches.length + 1}`, name: String(input.name), code: String(input.code), status: 'active',
          timezone: String(input.timezone), stock_location_id: String(input.stock_location_id), profile_key: profile.key,
        };
        world.branches.push(branch);
        const registerInput = body.register as { name?: string } | undefined;
        const register: Register | null = registerInput
          ? { id: 'posreg_1', branch_id: branch.id, name: String(registerInput.name), code: `${branch.code.slice(0, 29)}-1`, status: 'active' }
          : null;
        if (register) world.registers.push(register);
        world.granted = body.grant_self === true;
        world.results.set(key, {
          body: JSON.stringify(body),
          json: {
            data: {
              store_profile: { id: 'posstoreprof_1', profile_key: profile.key, wholesale: body.wholesale, interests: body.interests },
              branch, register, membership: world.granted ? { id: 'posmember_1' } : null,
              features: {}, modules: Object.fromEntries(profile.modules.map((item) => [item, true])),
            },
          },
        });
      }
      if (world.lose > 0) {
        world.lose -= 1;
        return route.abort('timedout');
      }
      return route.fulfill({ status: 201, json: world.results.get(key)?.json });
    }
    if (method !== 'GET') return route.fulfill({ status: 404, json: { error: { code: 'not_found', message: `Not mocked: ${method} ${path}` } } });
    return route.fulfill({ json: page1([]) });
  });
}

async function signIn(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('owner@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
}

// Visible controls a screen reader would announce without a name (the same
// targeted check as accessibility.spec.ts; no audit library is installed).
async function unnamedControls(page: Page) {
  return page.evaluate(() => {
    const visible = (element: Element) => {
      const box = (element as HTMLElement).getBoundingClientRect();
      return box.width > 0 && box.height > 0 && getComputedStyle(element).visibility !== 'hidden';
    };
    const name = (element: Element) => {
      const labelled = element.getAttribute('aria-labelledby');
      if (labelled) return labelled.split(' ').map((id) => document.getElementById(id)?.textContent ?? '').join(' ').trim();
      if (element.getAttribute('aria-label')) return element.getAttribute('aria-label')?.trim();
      const id = element.getAttribute('id');
      const forLabel = id ? document.querySelector(`label[for="${CSS.escape(id)}"]`) : null;
      return (
        forLabel?.textContent?.trim() ||
        element.closest('label')?.textContent?.trim() ||
        (element instanceof HTMLButtonElement || element.tagName === 'A' || element.tagName === 'SUMMARY' ? element.textContent?.trim() : '') ||
        element.getAttribute('title')?.trim() ||
        (element as HTMLInputElement).placeholder?.trim() ||
        ''
      );
    };
    return [...document.querySelectorAll('button, a[href], input:not([type="hidden"]), select, textarea, summary, [role="tab"]')]
      .filter(visible)
      .filter((element) => !name(element))
      .map((element) => element.outerHTML.slice(0, 160));
  });
}

async function fitsWidth(page: Page) {
  return page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1);
}

async function checkScreen(page: Page) {
  expect(await unnamedControls(page)).toEqual([]);
  expect(await fitsWidth(page)).toBe(true);
}

// Step headings start with a visually hidden "Bước n/5:".
const step = (page: Page, name: string) =>
  page.getByRole('heading', { level: 2, name: new RegExp(`${name.replace(/[?.*+()[\]\\]/g, '\\$&')}$`) });
const next = (page: Page) => page.getByRole('button', { name: 'Tiếp tục', exact: true }).click();
const radio = (page: Page, name: string) => page.getByRole('radio', { name, exact: true });

async function fillBranch(page: Page, name: string) {
  await expect(step(page, 'Chi nhánh đầu tiên')).toBeVisible();
  await page.getByLabel('Tên chi nhánh').fill(name);
  await page.getByLabel('Kho bán hàng').selectOption({ label: 'Kho chính' });
}

test('a new store set up as a pharmacy gets its branch and register, and the sale screen offers to open a shift', async ({ page }) => {
  const world = newSetupWorld();
  await installSetupApi(page, world);
  await signIn(page);
  await expect(page).toHaveURL(/\/setup$/);
  await expect(page.getByRole('heading', { level: 1, name: 'Thiết lập cửa hàng' })).toBeVisible();

  // Step 1: 13 retail cards and 6 "coming soon", in the server's order, one radio group.
  await expect(step(page, 'Bạn kinh doanh gì?')).toBeVisible();
  const group = page.getByRole('radiogroup', { name: /Bạn kinh doanh gì\?/ });
  await expect(group.getByRole('radio')).toHaveCount(19);
  await expect(page.getByRole('group', { name: 'Bán buôn, bán lẻ' }).getByRole('radio')).toHaveCount(13);
  await expect(page.getByRole('group', { name: 'Ăn uống, giải trí' }).getByRole('radio')).toHaveCount(6);
  await expect(page.getByRole('group', { name: 'Ăn uống, giải trí' }).getByText('Sắp hỗ trợ')).toHaveCount(6);
  await expect(group.getByRole('radio').first()).toHaveAccessibleName('Tạp hóa & Siêu thị');
  await checkScreen(page);
  await radio(page, 'Nhà thuốc').check();
  await next(page);

  // Step 2: wholesale, with the price list note.
  await expect(step(page, 'Có bán sỉ không?')).toBeFocused();
  await expect(radio(page, 'Không bán sỉ')).toBeChecked();
  await expect(page.getByText('Bảng giá sỉ sẽ có trong bản cập nhật sau.')).toBeVisible();
  await checkScreen(page);
  await next(page);

  // Step 3: the code follows the name; only active stock locations; "Quầy 1"; self grant ticked.
  await fillBranch(page, 'Nhà thuốc Minh Châu');
  await expect(page.getByLabel('Mã chi nhánh')).toHaveValue('nha-thuoc-minh-chau');
  await expect(page.getByLabel('Múi giờ')).toHaveValue('Asia/Ho_Chi_Minh');
  await expect(page.getByLabel('Kho bán hàng').locator('option')).toHaveText(['Chọn kho hàng', 'Kho chính', 'Kho phụ']);
  await expect(page.getByLabel('Tên quầy đầu tiên (không bắt buộc)')).toHaveValue('Quầy 1');
  await expect(page.getByRole('checkbox', { name: /Cấp cho tôi toàn quyền tại chi nhánh này/ })).toBeChecked();
  await checkScreen(page);
  await next(page);

  // Step 4: modules with a line each, defaults editable, sample units, risky features unticked.
  await expect(step(page, 'Xem trước')).toBeVisible();
  const modules = page.locator('.setup-module-list');
  await expect(modules.locator('li strong')).toHaveText(['Quy đổi đơn vị', 'Serial, lô, hạn dùng']);
  await expect(modules).toContainText('Theo dõi từng serial hoặc từng lô');
  await expect(page.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toHaveValue('7');
  await expect(page.getByLabel('Chọn lô khi bán', { exact: false })).toHaveValue('fefo');
  await expect(page.getByRole('list', { name: 'Đơn vị mẫu sẽ thêm' }).getByRole('listitem')).toHaveText(['Viên', 'Vỉ', 'Hộp', 'Chai']);
  const usual = page.getByRole('group', { name: 'Ngành này thường dùng' });
  await expect(usual.getByRole('checkbox')).toHaveCount(3);
  for (const name of ['Kho truy xuất (serial/lô)', 'Trả hàng', 'Hoàn tiền'])
    await expect(usual.getByRole('checkbox', { name, exact: true })).not.toBeChecked();
  await expect(usual.getByText('Lập phiếu trả mới. Phiếu đã lập vẫn nhận hàng, hủy được.')).toBeVisible();
  await checkScreen(page);
  await next(page);

  // Step 5: summary, then one command.
  await expect(step(page, 'Tạo cửa hàng')).toBeVisible();
  await expect(page.locator('.setup-summary')).toContainText('Nhà thuốc Minh Châu · nha-thuoc-minh-chau · Asia/Ho_Chi_Minh');
  await expect(page.locator('.setup-summary')).toContainText('Không bật chức năng nào');
  await checkScreen(page);
  expect(world.posts).toHaveLength(0);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).click();

  await expect(page).toHaveURL(/\/$/);
  expect(world.posts).toHaveLength(1);
  expect(world.posts[0].key).toMatch(/^[0-9a-f-]{36}$/);
  expect(world.posts[0].body).toEqual({
    profile_key: 'nha_thuoc',
    wholesale: false,
    interests: [],
    branch: {
      name: 'Nhà thuốc Minh Châu', code: 'nha-thuoc-minh-chau', timezone: 'Asia/Ho_Chi_Minh',
      stock_location_id: 'sloc_main', return_window_days: 7, lot_selection: 'fefo',
    },
    register: { name: 'Quầy 1' },
    grant_self: true,
    // D6: nothing risky is turned on unless ticked.
    features: [],
  });
  // The new branch and register are the selling context; the shift dialog is there.
  const context = page.locator('.pos-context-details summary');
  await expect(context).toContainText('Nhà thuốc Minh Châu');
  await expect(context).toContainText('Quầy 1');
  await expect(page.getByLabel('Tiền đầu ca')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Mở ca', exact: true })).toBeVisible();
  await expect(page.getByRole('dialog', { name: 'Chọn nơi bán hàng' })).toHaveCount(0);
});

test('a lost answer at the last step is checked again with the same key and creates one branch', async ({ page }) => {
  // The command commits, then every answer of the first click is lost (the
  // SDK tries three times with the same key).
  const world = newSetupWorld({ lose: 3 });
  await installSetupApi(page, world);
  await signIn(page);
  await radio(page, 'Thời trang').check();
  await next(page);
  await next(page);
  await fillBranch(page, 'Shop Thời Trang Hoa');
  await next(page);
  await next(page);
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).click();

  const checking = page.getByRole('status').filter({ hasText: 'Đang kiểm tra kết quả…' });
  await expect(checking).toBeVisible({ timeout: 15_000 });
  await expect(page).toHaveURL(/\/setup$/);
  // The answers are kept and cannot change while the result is unknown.
  await expect(page.getByRole('button', { name: 'Quay lại' })).toBeDisabled();
  await expect(page.getByRole('button', { name: 'Tạo cửa hàng', exact: true })).toBeDisabled();
  expect(world.posts).toHaveLength(3);
  expect(world.branches).toHaveLength(1);

  await checking.getByRole('button', { name: 'Kiểm tra lại', exact: true }).click();
  await expect(page).toHaveURL(/\/$/);
  await expect(page.locator('.pos-context-details summary')).toContainText('Shop Thời Trang Hoa');
  expect(world.posts).toHaveLength(4);
  expect(new Set(world.posts.map((post) => post.key)).size).toBe(1);
  expect(world.posts.every((post) => JSON.stringify(post.body) === JSON.stringify(world.posts[0].body))).toBe(true);
  expect(world.branches).toHaveLength(1);
  expect(world.registers).toHaveLength(1);
});

test('a coming-soon business creates no food branch and is sent as an interest of a retail store', async ({ page }) => {
  const world = newSetupWorld();
  await installSetupApi(page, world);
  await signIn(page);

  // "No, we do not sell goods": noted, but setup cannot continue without a retail card.
  await radio(page, 'Cafe, Trà sữa').check();
  const ask = page.getByRole('group', { name: /POS chưa hỗ trợ Cafe, Trà sữa.*Bạn có bán thêm hàng hóa không\?/ });
  await expect(ask).toBeVisible();
  await next(page);
  await expect(page.getByRole('alert')).toContainText('Chọn một ngành bán lẻ.');
  await ask.getByRole('button', { name: 'Không', exact: true }).click();
  await expect(page.getByText('POS hiện chỉ tạo được chi nhánh bán lẻ')).toBeVisible();
  await next(page);
  await expect(step(page, 'Bạn kinh doanh gì?')).toBeVisible();

  // A canteen also sells packaged goods: yes suggests the grocery profile.
  await radio(page, 'Căng tin & Trạm dừng nghỉ').check();
  await page.getByRole('button', { name: 'Có, chọn ngành bán lẻ' }).click();
  await expect(radio(page, 'Tạp hóa & Siêu thị')).toBeChecked();
  await expect(page.getByRole('list', { name: 'Ngành đang quan tâm' }).getByRole('listitem')).toHaveCount(2);
  await next(page);
  await radio(page, 'Có bán sỉ').check();
  await next(page);
  await fillBranch(page, 'Tạp hóa Bến Xe');
  await page.getByLabel('Mã chi nhánh').fill('ben-xe');
  await page.getByLabel('Tên quầy đầu tiên (không bắt buộc)').fill('');
  await page.getByRole('checkbox', { name: /Cấp cho tôi toàn quyền/ }).uncheck();
  await next(page);
  // Ticked by the owner: only then is a risky feature sent.
  await page.getByRole('group', { name: 'Ngành này thường dùng' }).getByRole('checkbox', { name: 'Bán ghi nợ', exact: true }).check();
  await next(page);
  await expect(page.locator('.setup-summary')).toContainText('Cafe, Trà sữa, Căng tin & Trạm dừng nghỉ');
  await page.getByRole('button', { name: 'Tạo cửa hàng', exact: true }).click();

  await expect(page).toHaveURL(/\/$/);
  expect(world.posts).toHaveLength(1);
  expect(world.posts[0].body).toMatchObject({
    profile_key: 'tap_hoa_sieu_thi',
    wholesale: true,
    interests: ['cafe_tra_sua', 'cang_tin_tram_dung'],
    branch: { code: 'ben-xe', return_window_days: 7, lot_selection: 'fefo' },
    grant_self: false,
    features: ['credit'],
  });
  expect(world.posts[0].body).not.toHaveProperty('register');
  expect(world.branches.map((branch) => branch.profile_key)).toEqual(['tap_hoa_sieu_thi']);
});

test('without stock locations the branch step explains where to create one and does not go on', async ({ page }) => {
  const world = newSetupWorld({ locations: [{ id: 'sloc_old', name: 'Kho cũ', active: false }] });
  await installSetupApi(page, world);
  await signIn(page);
  await radio(page, 'Mỹ phẩm').check();
  await next(page);
  await next(page);
  await page.getByLabel('Tên chi nhánh').fill('Mỹ phẩm Lan');
  const blocker = page.getByRole('alert').filter({ hasText: 'Cửa hàng chưa có kho hàng' });
  await expect(blocker).toContainText('Admin Dashboard');
  await expect(page.getByLabel('Kho bán hàng')).toHaveCount(0);
  await next(page);
  await expect(step(page, 'Chi nhánh đầu tiên')).toBeVisible();
  await expect(page.getByRole('alert').filter({ hasText: 'Chưa đi tiếp được' })).toContainText('chưa có kho hàng');

  // A location created meanwhile: reloading the list unblocks the step.
  world.locations.push({ id: 'sloc_new', name: 'Kho mới', active: true });
  await blocker.getByRole('button', { name: 'Tải lại danh sách kho' }).click();
  await expect(page.getByLabel('Kho bán hàng')).toHaveValue('sloc_new');
  await next(page);
  await expect(step(page, 'Xem trước')).toBeVisible();
  expect(world.posts).toHaveLength(0);
});

test('without the setup permission the branch picker asks for a store administrator, and /setup shows no wizard', async ({ page }) => {
  const world = newSetupWorld({ canSetup: false });
  await installSetupApi(page, world);
  await signIn(page);
  await expect(page.locator('.header-user')).toHaveText('Chủ cửa hàng');
  const picker = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  await expect(picker.getByRole('status').filter({ hasText: 'Chưa có chi nhánh.' })).toContainText(
    'Nhờ quản trị cửa hàng thiết lập POS.',
  );
  await expect(page).not.toHaveURL(/\/setup$/);

  await page.goto('/setup');
  await expect(page.getByRole('heading', { level: 1, name: 'Thiết lập cửa hàng' })).toBeVisible();
  await expect(page.locator('.setup-page').getByText('Nhờ quản trị cửa hàng thiết lập POS.', { exact: true })).toBeVisible();
  await expect(page.getByRole('radiogroup')).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Tạo cửa hàng' })).toHaveCount(0);
  expect(world.posts).toHaveLength(0);
});

test('keyboard only: arrows pick an industry, each step moves focus to its heading', async ({ page }) => {
  const world = newSetupWorld();
  await installSetupApi(page, world);
  await signIn(page);
  const first = radio(page, 'Tạp hóa & Siêu thị');
  await first.focus();
  await page.keyboard.press('Space');
  await expect(first).toBeChecked();
  for (let index = 0; index < 5; index += 1) await page.keyboard.press('ArrowDown');
  await expect(radio(page, 'Nhà thuốc')).toBeChecked();
  await expect(radio(page, 'Nhà thuốc')).toBeFocused();
  // Enter submits the step from any field of its form.
  await page.keyboard.press('Enter');
  await expect(step(page, 'Có bán sỉ không?')).toBeFocused();
  await page.keyboard.press('Tab');
  await expect(radio(page, 'Không bán sỉ')).toBeFocused();
  await page.keyboard.press('Enter');
  await expect(step(page, 'Chi nhánh đầu tiên')).toBeFocused();
  await page.keyboard.press('Tab');
  await expect(page.getByLabel('Tên chi nhánh')).toBeFocused();
  await page.keyboard.type('Nhà thuốc Phím');
  await page.keyboard.press('Enter');
  // The stock location is still missing: the step says so and stays.
  await expect(page.getByRole('alert')).toContainText('Chọn kho bán hàng.');
  await page.getByLabel('Kho bán hàng').focus();
  await page.keyboard.press('ArrowDown');
  await page.getByLabel('Tên chi nhánh').press('Enter');
  await expect(step(page, 'Xem trước')).toBeFocused();
});
