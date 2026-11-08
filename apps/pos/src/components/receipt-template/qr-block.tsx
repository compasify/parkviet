import { useMemo } from 'react';
import { encode } from 'uqr';
import type { Align } from '../../lib/receipt-template/types';

// The dark modules of a QR code as one SVG path, a row run at a time.
export function qrPath(value: string): { size: number; path: string } | null {
  try {
    const { size, data } = encode(value, { ecc: 'M', border: 4 });
    const parts: string[] = [];
    data.forEach((row, y) => {
      let x = 0;
      while (x < size) {
        if (!row[x]) {
          x += 1;
          continue;
        }
        const start = x;
        while (x < size && row[x]) x += 1;
        parts.push(`M${start} ${y}h${x - start}v1h${start - x}z`);
      }
    });
    return { size, path: parts.join('') };
  } catch {
    // Too long to encode: the block is left off rather than break the print.
    return null;
  }
}

// A printed QR code, generated here: nothing is sent to a QR service.
export function QrCodeBlock({
  value,
  caption,
  align,
}: {
  value: string;
  caption: string | null;
  align: Align;
}) {
  const code = useMemo(() => qrPath(value), [value]);
  if (!code) return null;
  return (
    <figure className={`receipt-qr receipt-code-${align}`} data-qr-value={value}>
      <svg
        viewBox={`0 0 ${code.size} ${code.size}`}
        shapeRendering="crispEdges"
        role="img"
        aria-label={caption ?? value}
      >
        <path d={code.path} fill="#000" />
      </svg>
      {caption ? <figcaption>{caption}</figcaption> : null}
    </figure>
  );
}
