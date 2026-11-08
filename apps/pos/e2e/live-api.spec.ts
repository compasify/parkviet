import { readFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import { expect, type Page, test } from '@playwright/test';
import { picker, pickerValue, pickOption } from './support/searchable-select';

async function selectReviewContext(page: Page, credentials: { branch_id: string; register_id: string }) {
  const chooser = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  const summary = page.locator('.pos-context-details > summary');
  await expect.poll(async () => await chooser.isVisible() ||
    ((await summary.textContent()) ?? '').includes('Quầy:')).toBe(true);
  if (await chooser.isVisible()) await chooser.getByRole('button', { name: 'Để sau' }).click();
  await summary.click();
  if (await pickerValue(page, 'Chi nhánh') !== credentials.branch_id) await pickOption(page, 'Chi nhánh', credentials.branch_id);
  await expect(picker(page, 'Quầy')).toBeEnabled();
  if (await pickerValue(page, 'Quầy') !== credentials.register_id) await pickOption(page, 'Quầy', credentials.register_id);
  await page.locator('.pos-context-details').evaluate((element) => { (element as HTMLDetailsElement).open = false; });
}

async function findDraft(page: Page, draft: { id: string; order_id: string }) {
  const more = page.locator('.draft-filter');
  if (await more.count()) await more.evaluate((element) => { (element as HTMLDetailsElement).open = true; });
  await page.getByLabel('Tìm trong danh sách đã tải').fill(draft.order_id);
  return page.locator(`[role="tab"][data-workspace-id="${draft.id}"]`);
}

test('real API preserves one editor and rejects a stale browser after takeover', async ({ browser }) => {
  test.setTimeout(90_000);
  test.skip(process.env.POS_LIVE_REVIEW !== '1', 'Requires explicitly provisioned synthetic development data');
  const credentials = JSON.parse(readFileSync('../../server/pos-live-review-credentials.json', 'utf8')) as {
    email: string; password: string; branch_id: string; register_id: string;
  };
  const firstContext = await browser.newContext();
  const secondContext = await browser.newContext();
  try {
    const first = await firstContext.newPage();
    const second = await secondContext.newPage();
    for (const page of [first, second]) {
      await page.goto('http://127.0.0.1:5174/login');
      await page.getByLabel('Email nhân viên').fill(credentials.email);
      await page.getByLabel('Mật khẩu', { exact: true }).fill(credentials.password);
      await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
      await expect(page.locator('.header-user')).toHaveText('POS Review', { timeout: 25_000 });
      await selectReviewContext(page, credentials);
      await expect(page.getByText('Ca đang mở:', { exact: false })).toBeVisible();
    }
    const createResponse = first.waitForResponse((response) => response.url().includes('/pos/workspaces') && response.request().method() === 'POST');
    await first.getByRole('button', { name: 'Đơn nháp mới' }).click();
    const created = await createResponse;
    expect(created.status(), await created.text()).toBe(201);
    const draft = (await created.json()).data as { id: string; order_id: string };
    await (await findDraft(first, draft)).click();
    await expect(first.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
    const listResponses: string[] = [];
    second.on('response', async (response) => {
      if (response.url().includes('/pos/workspaces') && response.request().method() === 'GET') {
        listResponses.push(`${response.status()} ${new URL(response.url()).search} ${await response.text()}`);
      }
    });
    await second.reload();
    await second.locator('.pos-context-details > summary').click();
    await expect(second.getByRole('combobox', { name: 'Quầy' })).toHaveAttribute('data-value', credentials.register_id);
    const secondDraft = await findDraft(second, draft);
    try {
      await expect(secondDraft).toBeVisible();
    } catch (error) {
      console.log('Workspace list responses:', listResponses.join('\n'));
      throw error;
    }
    await secondDraft.click();
    await second.reload();
    try {
      await expect(secondDraft).toHaveAttribute('aria-selected', 'true', { timeout: 20_000 });
    } catch (error) {
      console.log('Workspace list responses:', listResponses.join('\n'));
      throw error;
    }
    await expect(second.getByRole('button', { name: 'Nhận quyền sửa', exact: true })).toBeVisible();
    const claimResponse = second.waitForResponse((response) => response.url().includes(`/pos/workspaces/${draft.id}/lease`) && response.request().method() === 'POST');
    await second.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
    const claim = await claimResponse;
    expect(claim.status(), await claim.text()).toBe(409);
    await expect(second.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
    const takeoverResponse = second.waitForResponse((response) => response.url().includes('/lease') && response.request().method() === 'POST');
    await second.getByRole('button', { name: 'Tiếp quản quyền sửa' }).click();
    const takeover = await takeoverResponse;
    expect(takeover.status(), await takeover.text()).toBe(200);
    const takeoverData = (await takeover.json()).data as { lease_generation: number; revision: number };
    const editorId = (takeover.request().postDataJSON() as { editor_id: string }).editor_id;
    const authorization = (await takeover.request().allHeaders()).authorization;
    expect(authorization).toBeTruthy();
    try {
      await expect(second.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
    } catch (error) {
      console.log('Takeover result:', await takeover.text(), 'Workspace list responses:', listResponses.join('\n'));
      throw error;
    }
    const staleResponse = first.waitForResponse((response) => response.url().includes(`/pos/workspaces/${draft.id}/park`) && response.request().method() === 'POST');
    await first.getByRole('button', { name: 'Tạm giữ' }).click();
    const stale = await staleResponse;
    expect(stale.status(), await stale.text()).toBe(409);
    await expect(first.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
    const url = `http://127.0.0.1:5174/api/v3/admin/pos/workspaces/${draft.id}/park`;
    const mutation = { editor_id: editorId, expected_revision: takeoverData.revision, lease_generation: takeoverData.lease_generation };
    const [raceA, raceB] = await Promise.all([firstContext.request, secondContext.request].map((client) =>
      client.post(url, { headers: { authorization, 'Idempotency-Key': randomUUID() }, data: mutation }),
    ));
    expect([raceA.status(), raceB.status()].sort()).toEqual([200, 409]);
    const successful = raceA.status() === 200 ? raceA : raceB;
    const parked = (await successful.json()).data as { id: string; revision: number; operational_status: string };
    expect(parked).toMatchObject({ id: draft.id, revision: takeoverData.revision + 1, operational_status: 'parked' });
  } finally {
    await firstContext.close();
    await secondContext.close();
  }
});

test('real API recovers a committed draft after its response is lost and the page reloads', async ({ browser }) => {
  test.setTimeout(90_000);
  test.skip(process.env.POS_LIVE_REVIEW !== '1', 'Requires explicitly provisioned synthetic development data');
  const credentials = JSON.parse(readFileSync('../../server/pos-live-review-credentials.json', 'utf8')) as {
    email: string; password: string; branch_id: string; register_id: string;
  };
  const context = await browser.newContext();
  try {
    const page = await context.newPage();
    await page.goto('http://127.0.0.1:5174/login');
    await page.getByLabel('Email nhân viên').fill(credentials.email);
    await page.getByLabel('Mật khẩu', { exact: true }).fill(credentials.password);
    await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
    await expect(page.locator('.header-user')).toHaveText('POS Review', { timeout: 25_000 });
    await selectReviewContext(page, credentials);
    await expect(page.getByText('Ca đang mở:', { exact: false })).toBeVisible();

    let committed: { id: string; order_id: string } | undefined;
    let firstKey = '';
    let firstHeader = '';
    await page.route('**/api/v3/admin/pos/workspaces', async (route) => {
      if (route.request().method() !== 'POST') return route.continue();
      if (committed) return route.abort('connectionfailed');
      const body = route.request().postDataJSON() as { idempotency_key: string };
      firstKey = body.idempotency_key;
      firstHeader = route.request().headers()['idempotency-key'] ?? '';
      const response = await route.fetch();
      expect(response.status()).toBe(201);
      committed = (await response.json()).data;
      await route.abort('connectionfailed');
    });
    await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
    await expect.poll(() => committed?.id).toBeTruthy();
    await expect(page.getByRole('alert')).toBeVisible();
    await expect(page.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toBeVisible();
    const draft = committed!;
    await page.unrouteAll({ behavior: 'wait' });
    await page.reload();
    await page.locator('.pos-context-details > summary').click();
    await expect(page.getByRole('combobox', { name: 'Quầy' })).toHaveAttribute('data-value', credentials.register_id);
    await expect(page.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toBeVisible();
    const retryResponse = page.waitForResponse((response) => response.url().endsWith('/pos/workspaces') && response.request().method() === 'POST');
    await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
    const retry = await retryResponse;
    expect((retry.request().postDataJSON() as { idempotency_key: string }).idempotency_key).toBe(firstKey);
    expect(retry.request().headers()['idempotency-key'] ?? '').toBe(firstHeader);
    expect(retry.status()).toBe(409);
    await expect(page.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toHaveCount(0);
    const recoveredDraft = await findDraft(page, draft);
    await expect(recoveredDraft).toHaveCount(1);
    await recoveredDraft.click();
    await expect(page.getByRole('button', { name: 'Nhận quyền sửa', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
  } finally {
    await context.close();
  }
});
