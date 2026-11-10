import type { PayLaterQr } from '@parkviet/pos-shared/pay-later'
import { encode } from 'uqr'

export type ShareOutcome = 'shared' | 'copied' | 'cancelled' | 'failed'
type ShareNavigator = Pick<Navigator, 'share' | 'canShare' | 'clipboard'>

// The pay-later QR drawn locally as a PNG; no remote QR service is called.
async function qrFile(qr: PayLaterQr): Promise<File | null> {
  try {
    const { size, data } = encode(qr.payload, { ecc: 'M', border: 4 })
    const scale = 8
    const canvas = document.createElement('canvas')
    canvas.width = size * scale
    canvas.height = size * scale
    const context = canvas.getContext('2d')
    if (!context) return null
    context.fillStyle = '#fff'
    context.fillRect(0, 0, canvas.width, canvas.height)
    context.fillStyle = '#000'
    data.forEach((row, y) => {
      row.forEach((dark, x) => {
        if (dark) context.fillRect(x * scale, y * scale, scale, scale)
      })
    })
    const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/png'))
    return blob ? new File([blob], `QR-${qr.transfer_content}.png`, { type: 'image/png' }) : null
  } catch {
    return null
  }
}

export async function copyMessage(
  message: string,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  try {
    await nav.clipboard?.writeText(message)
    return nav.clipboard ? 'copied' : 'failed'
  } catch {
    return 'failed'
  }
}

// Shares a message (and the QR when the target takes files) through the
// system sheet, else copies it, as the selling app does.
export async function shareMessage(
  message: string,
  qr: PayLaterQr | null,
  title: string,
  nav: Partial<ShareNavigator> = navigator,
): Promise<ShareOutcome> {
  if (typeof nav.share === 'function') {
    const file = qr ? await qrFile(qr) : null
    const withFile = file && nav.canShare?.({ files: [file] }) ? { files: [file] } : {}
    try {
      await nav.share({ title, text: message, ...withFile })
      return 'shared'
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') return 'cancelled'
      // Some share targets refuse the file or the call; copying still works.
    }
  }
  return copyMessage(message, nav)
}
