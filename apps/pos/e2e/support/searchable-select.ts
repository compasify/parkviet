import type { Locator, Page } from '@playwright/test';

/** The branch/register pickers are searchable comboboxes; `data-value` holds the selected id. */
export function picker(scope: Page | Locator, name: string) {
  return scope.getByRole('combobox', { name, exact: true });
}

export async function pickerValue(scope: Page | Locator, name: string) {
  return (await picker(scope, name).getAttribute('data-value')) ?? '';
}

export async function pickOption(scope: Page | Locator, name: string, value: string) {
  const box = picker(scope, name);
  await box.click();
  const listbox = scope.locator(`[id="${await box.getAttribute('aria-controls')}"]`);
  await listbox.locator(`[role="option"][data-value="${value}"]`).click();
}
