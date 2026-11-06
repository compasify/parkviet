import { useEffect, useState } from 'react';
import { assignInvoiceNumbers } from '../lib/pos-selection-rules';
import { readLayout, writeLayout } from '../lib/workspace-storage';

export function useInvoiceNumbers(
  staffId: string | null,
  storeId: string | null,
  branchId: string | null,
  registerId: string | null,
  ids: string[],
  closedIds: string[],
) {
  const scope = JSON.stringify([staffId, storeId, branchId, registerId]);
  const [state, setState] = useState<{ scope: string; numbers: Record<string, number> }>({
    scope: '',
    numbers: {},
  });
  const layout = staffId && storeId ? readLayout(staffId, storeId) : null;
  const previous =
    state.scope === scope
      ? state.numbers
      : layout?.branchId === branchId && layout?.registerId === registerId
        ? (layout.tabNumbers ?? {})
        : {};
  const numbers = assignInvoiceNumbers(previous, ids, closedIds);
  const serialized = JSON.stringify(numbers);
  useEffect(() => {
    const next = JSON.parse(serialized) as Record<string, number>;
    setState((current) =>
      current.scope === scope && JSON.stringify(current.numbers) === serialized
        ? current
        : { scope, numbers: next },
    );
    if (!staffId || !storeId || !branchId) return;
    const current = readLayout(staffId, storeId);
    if (current?.branchId !== branchId || current.registerId !== registerId) return;
    writeLayout({ ...current, savedAt: Date.now(), tabNumbers: next });
  }, [scope, serialized, staffId, storeId, branchId, registerId]);
  return numbers;
}
