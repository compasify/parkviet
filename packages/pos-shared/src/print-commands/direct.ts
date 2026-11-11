import type { PrinterTarget, PrintOutcome } from '../types/print-adapter';
import { documentCommands, type PrintableDocument } from './commands';
import { eposRequest, eposSucceeded } from './epson-epos';
import { starRequest, starSucceeded } from './star-webprnt';

// A printer the browser talks to over the LAN. The network is injected, so
// this stays free of browser APIs. A browser hides why a request failed, so
// `reachable` tells a CORS refusal (the printer answered) from no printer.
// Either way the request may have arrived, so neither proves there is no paper.

export type DirectRequest = {
  url: string;
  headers: Record<string, string>;
  body: string;
  timeoutMs: number;
};
export type DirectResponse = { status: number; body: string };

export class DirectTimeout extends Error {}

export type DirectTransport = {
  send(request: DirectRequest): Promise<DirectResponse>;
  reachable(url: string): Promise<boolean>;
};

export const DIRECT_TIMEOUT_MS = 15_000;
export const REACHABLE_TIMEOUT_MS = 3_000;

// The part of `fetch` a transport uses; the app passes its own.
export type FetchLike = (
  url: string,
  init: {
    method?: string;
    headers?: Record<string, string>;
    body?: string;
    mode?: 'no-cors';
    signal: AbortSignal;
  },
) => Promise<{ status: number; text(): Promise<string> }>;

export function createFetchTransport(fetchFn: FetchLike): DirectTransport {
  return {
    async send({ url, headers, body, timeoutMs }) {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeoutMs);
      try {
        const response = await fetchFn(url, {
          method: 'POST',
          headers,
          body,
          signal: controller.signal,
        });
        return { status: response.status, body: await response.text() };
      } catch (failure) {
        if (controller.signal.aborted) throw new DirectTimeout();
        throw failure;
      } finally {
        clearTimeout(timer);
      }
    },
    // An opaque answer still proves something is listening at that address.
    // A silent address must not hold up the failure it is explaining.
    async reachable(url) {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), REACHABLE_TIMEOUT_MS);
      try {
        await fetchFn(url, { mode: 'no-cors', signal: controller.signal });
        return true;
      } finally {
        clearTimeout(timer);
      }
    },
  };
}

export const isDirectConnection = (connection: PrinterTarget['connection']) =>
  connection === 'epson_epos' || connection === 'star_webprnt';

const secure = (printer: PrinterTarget) => printer.settings.https === true;

// The outcomes known to mean no paper: stopped before sending, or refused by
// the printer. A timeout or a dropped connection is not among them, since the
// printer may have printed and only the answer got lost. These are also the
// reasons the server accepts for taking a print back.
const CERTAINLY_UNPRINTED = ['mixed_content', 'no_address', 'printer_error'] as const;
export type UnprintedReason = (typeof CERTAINLY_UNPRINTED)[number];
// `not_sent`: a later print of the same press, never attempted after a failure.
export type VoidReason = UnprintedReason | 'not_sent';

export function certainlyUnprinted(
  outcome: PrintOutcome,
): outcome is { ok: false; reason: UnprintedReason } {
  return !outcome.ok && (CERTAINLY_UNPRINTED as readonly string[]).includes(outcome.reason);
}

export async function printDirect(
  printer: PrinterTarget,
  document: PrintableDocument,
  options: { transport: DirectTransport; pageProtocol: string; timeoutMs?: number },
): Promise<PrintOutcome> {
  if (!isDirectConnection(printer.connection)) return { ok: false, reason: 'failed' };
  if (!printer.address) return { ok: false, reason: 'no_address' };
  // A browser blocks this outright, so do not attempt it.
  if (options.pageProtocol === 'https:' && !secure(printer))
    return { ok: false, reason: 'mixed_content' };

  const origin = `${secure(printer) ? 'https' : 'http'}://${printer.address}`;
  const commands = documentCommands(document, printer);
  const epson = printer.connection === 'epson_epos';
  const request = epson ? eposRequest(origin, commands) : starRequest(origin, commands);
  try {
    const response = await options.transport.send({
      ...request,
      timeoutMs: options.timeoutMs ?? DIRECT_TIMEOUT_MS,
    });
    const succeeded = epson ? eposSucceeded(response.body) : starSucceeded(response.body);
    return response.status >= 200 && response.status < 300 && succeeded
      ? { ok: true }
      : { ok: false, reason: 'printer_error' };
  } catch (failure) {
    if (failure instanceof DirectTimeout) return { ok: false, reason: 'timeout' };
    const answered = await options.transport.reachable(origin).catch(() => false);
    return { ok: false, reason: answered ? 'cors' : 'unreachable' };
  }
}
