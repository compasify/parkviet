import { sellingLayoutOf } from '@parkviet/pos-shared/pos-modules';
import { usePosSelection } from '../components/pos-selection';
import { PrintQueueAlert } from '../components/print-queue-panel';
import { TableServiceScreen } from '../components/table-service/table-service-screen';
import { WorkspaceTabs } from '../components/workspace-tabs';

export function SalePage() {
  const { context } = usePosSelection();
  return (
    <>
      {sellingLayoutOf(context.data) === 'table_service' ? (
        <TableServiceScreen />
      ) : (
        <WorkspaceTabs />
      )}
      <PrintQueueAlert />
    </>
  );
}
