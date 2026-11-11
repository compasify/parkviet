import { PrintQueueAlert } from '../components/print-queue-panel';
import { WorkspaceTabs } from '../components/workspace-tabs';

export function SalePage() {
  return (
    <>
      <WorkspaceTabs />
      <PrintQueueAlert />
    </>
  );
}
