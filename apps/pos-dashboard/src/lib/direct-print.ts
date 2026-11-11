import type { PrintableDocument } from '@parkviet/pos-shared/print-commands/commands'
import { createFetchTransport, printDirect } from '@parkviet/pos-shared/print-commands/direct'
import type { PrinterTarget, PrintOutcome } from '@parkviet/pos-shared/types/print-adapter'

// A test page straight to a LAN printer. This is the one fetch outside
// posRequest here: the target is the printer, not the Admin API.
const transport = createFetchTransport((url, init) => fetch(url, init))

export const printTestPage = (
  printer: PrinterTarget,
  document: PrintableDocument,
): Promise<PrintOutcome> =>
  printDirect(printer, document, { transport, pageProtocol: window.location.protocol })
