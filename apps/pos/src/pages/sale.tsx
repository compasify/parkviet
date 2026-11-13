import { sellingLayoutOf } from '@parkviet/pos-shared/pos-modules';
import { useRef } from 'react';
import { usePosSelection } from '../components/pos-selection';
import { PrintQueueAlert } from '../components/print-queue-panel';
import { QuickCounterScreen } from '../components/quick-counter/quick-counter-screen';
import { TableServiceScreen } from '../components/table-service/table-service-screen';
import { WorkspaceTabs } from '../components/workspace-tabs';

export function SalePage() {
  const { context } = usePosSelection();
  // The layout is known once the context is: nothing is drawn before the
  // first one arrives, and a reload of the context (another branch) keeps
  // the layout already shown until the new one says otherwise.
  const shown = useRef<ReturnType<typeof sellingLayoutOf> | null>(null);
  if (context.data) shown.current = sellingLayoutOf(context.data);
  const layout = shown.current ?? (context.isLoading ? null : sellingLayoutOf(context.data));
  return (
    <>
      {layout === 'table_service' ? (
        <TableServiceScreen />
      ) : layout === 'quick_counter' ? (
        <QuickCounterScreen />
      ) : layout === 'counter' ? (
        <WorkspaceTabs />
      ) : null}
      <PrintQueueAlert />
    </>
  );
}
