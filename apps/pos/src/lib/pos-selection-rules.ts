export type ContextOptions<T> = {
  data: T[];
  meta: { page: number; pages: number; count?: number };
};

// Only an unfiltered, complete result can prove a singleton or an empty branch.
export function onlyActiveOption<T extends { status: string }>(
  page: ContextOptions<T> | undefined,
) {
  return page &&
    page.meta.pages <= 1 &&
    (page.meta.count ?? page.data.length) === 1 &&
    page.data.length === 1 &&
    page.data[0].status === 'active'
    ? page.data[0]
    : null;
}

export function emptyOptions<T>(page: ContextOptions<T> | undefined) {
  return Boolean(
    page &&
      page.meta.pages <= 1 &&
      (page.meta.count ?? page.data.length) === 0 &&
      page.data.length === 0,
  );
}

export function assignInvoiceNumbers(
  previous: Record<string, number>,
  ids: string[],
  closedIds: string[],
) {
  const numbers = Object.fromEntries(
    Object.entries(previous).filter(([id]) => !closedIds.includes(id)),
  );
  let next = Math.max(0, ...Object.values(numbers));
  for (const id of ids) if (!numbers[id]) numbers[id] = ++next;
  return numbers;
}
