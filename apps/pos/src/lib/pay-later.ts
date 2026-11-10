import { type PayLaterQr, payLaterMessage } from '@parkviet/pos-shared/pay-later';
import { encode } from 'uqr';

export * from '@parkviet/pos-shared/pay-later';

type Translate = (key: string, options?: Record<string, unknown>) => string;

// Draw the payload locally; no remote QR service is called.
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

export async function sharePayLater(
  qr: PayLaterQr,
  t: Translate,
  storeName?: string | null,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  return shareMessage(payLaterMessage(qr, t, storeName), qr, t('payLaterShareTitle'), nav);
}

// Share a message and optional QR through the system sheet, else the clipboard.
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
