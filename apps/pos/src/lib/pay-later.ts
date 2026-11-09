import { encode } from 'uqr';
import { formatMoney } from './money';

// The pay-later VietQR of a credit sale, as the server reports it: on the
// receipt snapshot (`credit.pay_qr`, for the debt at issue time) and on each
// open receivable (`pay_later`, for what is still owed). It is a plain bank
// QR with `TN<order number>` as the transfer note; when the bank reports a
// transfer with that note, the server books it against the debt. It never
// expires. `payload` is the VietQR string banking apps scan; `image_url` is
// the img.vietqr.io picture of the same QR the counter QR already uses.

export type PayLaterQr = {
  amount: string;
  currency: string;
  order_number: string;
  transfer_content: string;
  bank_bin: string;
  bank_name: string | null;
  account_number: string;
  account_name: string;
  payload: string;
  image_url: string | null;
};

type Translate = (key: string, options?: Record<string, unknown>) => string;

const text = (value: unknown): string | null =>
  typeof value === 'string' && value.trim() !== '' ? value : null;

// A pay-later QR from server data, or null when anything it needs is missing.
export function payLaterQr(value: unknown): PayLaterQr | null {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return null;
  const row = value as Record<string, unknown>;
  const amount = text(row.amount);
  const transferContent = text(row.transfer_content);
  const accountNumber = text(row.account_number);
  const payload = text(row.payload);
  if (!amount || !transferContent || !accountNumber || !payload) return null;
  return {
    amount,
    currency: text(row.currency) ?? 'VND',
    order_number: text(row.order_number) ?? '',
    transfer_content: transferContent,
    bank_bin: text(row.bank_bin) ?? '',
    bank_name: text(row.bank_name),
    account_number: accountNumber,
    account_name: text(row.account_name) ?? '',
    payload,
    image_url: text(row.image_url),
  };
}

type SnapshotLike = { source_type: string; document: Record<string, unknown> };
const record = (value: unknown): Record<string, unknown> | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;

// The pay-later QR a sale receipt snapshot carries, or null.
export function receiptPayLaterQr(receipt: SnapshotLike): PayLaterQr | null {
  if (receipt.source_type !== 'sale') return null;
  return payLaterQr(record(receipt.document.credit)?.pay_qr);
}

export function receiptStoreName(receipt: SnapshotLike): string | null {
  return text(record(receipt.document.store)?.name);
}

// The lines printed under the QR, for paying by typing the details in.
export function payLaterDetails(qr: PayLaterQr, t: Translate): string[] {
  return [
    t('payLaterAmount', { amount: formatMoney(qr.amount, qr.currency) }),
    [qr.bank_name, qr.account_number, qr.account_name].filter(Boolean).join(' · '),
    t('payLaterNote', { note: qr.transfer_content }),
  ];
}

// The message sent to the customer (Zalo or any other app).
export function payLaterMessage(qr: PayLaterQr, t: Translate, storeName?: string | null): string {
  const lines = [
    storeName ? t('payLaterShareFrom', { store: storeName }) : null,
    t('payLaterShareOwed', {
      order: qr.order_number,
      amount: formatMoney(qr.amount, qr.currency),
    }),
    t('payLaterShareBank', {
      bank: qr.bank_name ?? qr.bank_bin,
      account: qr.account_number,
      name: qr.account_name,
    }),
    t('payLaterShareNote', { note: qr.transfer_content }),
    qr.image_url ? t('payLaterShareLink', { link: qr.image_url }) : null,
  ];
  return lines.filter((line): line is string => Boolean(line)).join('\n');
}

// The QR as a PNG file drawn here from the payload (no QR service is
// called); null where the browser cannot draw one.
export async function payLaterQrFile(qr: PayLaterQr): Promise<File | null> {
  try {
    const { size, data } = encode(qr.payload, { ecc: 'M', border: 4 });
    const scale = 8;
    const canvas = document.createElement('canvas');
    canvas.width = size * scale;
    canvas.height = size * scale;
    const context = canvas.getContext('2d');
    if (!context) return null;
    context.fillStyle = '#fff';
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.fillStyle = '#000';
    data.forEach((row, y) => {
      row.forEach((dark, x) => {
        if (dark) context.fillRect(x * scale, y * scale, scale, scale);
      });
    });
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/png'));
    return blob ? new File([blob], `QR-${qr.transfer_content}.png`, { type: 'image/png' }) : null;
  } catch {
    return null;
  }
}

export type ShareOutcome = 'shared' | 'copied' | 'cancelled' | 'failed';

type ShareNavigator = Pick<Navigator, 'share' | 'canShare' | 'clipboard'>;

// Shares the message (and the QR picture where the device can) through the
// system share sheet, where Zalo is offered; without one, copies the message
// to paste into Zalo.
export async function sharePayLater(
  qr: PayLaterQr,
  t: Translate,
  storeName?: string | null,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  return shareMessage(payLaterMessage(qr, t, storeName), qr, t('payLaterShareTitle'), nav);
}

// Any message with an optional QR picture: the share sheet where there is
// one, else the clipboard.
export async function shareMessage(
  message: string,
  qr: PayLaterQr | null,
  title: string,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  if (typeof nav.share === 'function') {
    const file = qr ? await payLaterQrFile(qr) : null;
    const withFile = file && nav.canShare?.({ files: [file] }) ? { files: [file] } : {};
    try {
      await nav.share({ title, text: message, ...withFile });
      return 'shared';
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') return 'cancelled';
      // Some share targets refuse the file or the call; copying still works.
    }
  }
  return copyMessage(message, nav);
}

export async function copyMessage(
  message: string,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  try {
    await nav.clipboard?.writeText(message);
    return nav.clipboard ? 'copied' : 'failed';
  } catch {
    return 'failed';
  }
}
