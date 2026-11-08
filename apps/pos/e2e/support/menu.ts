import type { Page } from '@playwright/test';

export async function openUserMenu(page: Page) {
  const menu = page.locator('.user-menu');
  if ((await menu.getAttribute('open')) === null) await menu.locator('> summary').click();
  return page.locator('.user-menu-popover');
}

// Opens a page from the header menu. From the sale screen the menu opens pages
// in a new browser tab; tests follow the link in the same page instead, which
// lands on the same route with the same session.
export async function goToMenuPage(page: Page, name: string) {
  const popover = await openUserMenu(page);
  const link = popover.getByRole('link', { name, exact: true }).first();
  if ((await link.getAttribute('target')) === '_blank') {
    const href = await link.getAttribute('href');
    if (!href) throw new Error(`menu link ${name} has no href`);
    await page.goto(new URL(href, page.url()).href);
  } else {
    await link.click();
  }
}
