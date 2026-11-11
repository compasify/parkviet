import type { PrintableDocument } from '@parkviet/pos-shared/print-commands/commands';
import {
  createFetchTransport,
  type DirectTransport,
  type FetchLike,
  isDirectConnection,
  printDirect,
} from '@parkviet/pos-shared/print-commands/direct';
import type {
  Printer,
  PrinterRole,
  PrintJob,
  PrintOutcome,
} from '@parkviet/pos-shared/types/print-adapter';

// Where a document goes: the browser's print dialog, a LAN printer the browser
// talks to, or a print station's queue. The printer languages themselves are in
// pos-shared; this adds the network and the choice of printer.

export type PrintRoute =
  | { kind: 'browser' }
  | { kind: 'direct'; printer: Printer }
  | { kind: 'queue'; printer: Printer };

export const BROWSER_ROUTE: PrintRoute = { kind: 'browser' };

// The register's own printer for the role, else one serving the whole branch.
// With neither, printing is the browser's, as it always was.
export function choosePrintRoute(
  printers: readonly Printer[],
  role: PrinterRole,
  registerId: string | null,
): PrintRoute {
  const able = printers.filter((row) => row.status === 'active' && row.roles.includes(role));
  const printer =
    able.find((row) => registerId !== null && row.register_id === registerId) ??
    able.find((row) => row.register_id === null);
  if (!printer || printer.connection === 'browser') return BROWSER_ROUTE;
  return isDirectConnection(printer.connection)
    ? { kind: 'direct', printer }
    : { kind: 'queue', printer };
}

const windowFetch: FetchLike = (url, init) => fetch(url, init);
export const fetchTransport: DirectTransport = createFetchTransport(windowFetch);

// A failed job someone already reprinted is dealt with; its copy speaks for it.
export const openPrintJobs = (jobs: readonly PrintJob[]) =>
  jobs.filter((job) => !(job.status === 'failed' && job.reprinted));

// Waiting for a printer that is disabled or whose station was revoked.
export const stuckPrintJob = (job: PrintJob) =>
  (job.status === 'queued' || job.status === 'claimed') && !job.printer_available;

export function deliverDirect(
  printer: Printer,
  document: PrintableDocument,
  transport: DirectTransport = fetchTransport,
): Promise<PrintOutcome> {
  return printDirect(printer, document, { transport, pageProtocol: window.location.protocol });
}
