import { type PaymentTicketInput, paymentTicketData } from './receipt-template/data';
import { defaultTemplate } from './receipt-template/defaults';
import { renderDocument } from './receipt-template/render';
import type { PrintDocument, TemplateConfig } from './receipt-template/types';

// The payment invoice handed over when the cashier takes the money, laid out
// by the payment ticket template (the built-in one by default). Server
// figures only — nothing here computes an amount except the change already
// shown to the cashier on screen.

export { lineDiscount, lineUnitPrice } from './receipt-template/data';

type Translate = (key: string, options?: Record<string, unknown>) => string;

export function invoiceTicketPrintDocument(
  input: PaymentTicketInput,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
  config: TemplateConfig = defaultTemplate('payment_ticket'),
): PrintDocument {
  return renderDocument(config, paymentTicketData(input, t, now, timeZone));
}
