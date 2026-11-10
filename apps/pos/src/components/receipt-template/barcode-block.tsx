import {
  barcodeWidthMm,
  code128Bars,
  QUIET_ZONE,
} from '@parkviet/pos-shared/receipt-template/code128';
import type { Align, PaperSize } from '@parkviet/pos-shared/receipt-template/types';
import { PRINTABLE_WIDTH_MM } from '@parkviet/pos-shared/receipt-template/validate';
import { useMemo } from 'react';

// The document number as a Code 128 barcode with the number printed under
// it. Left off when the paper is too narrow for bars a scanner can read.
export function BarcodeBlock({
  value,
  align,
  paper,
}: {
  value: string;
  align: Align;
  paper: PaperSize;
}) {
  const code = useMemo(() => code128Bars(value), [value]);
  const widthMm = barcodeWidthMm(value, PRINTABLE_WIDTH_MM[paper]);
  if (!code || widthMm === null) return null;
  const width = code.modules + QUIET_ZONE * 2;
  return (
    <figure className={`receipt-barcode receipt-code-${align}`} data-barcode-value={value}>
      <svg
        viewBox={`0 0 ${width} 30`}
        preserveAspectRatio="none"
        shapeRendering="crispEdges"
        style={{ width: `${widthMm.toFixed(1)}mm` }}
        role="img"
        aria-label={value}
      >
        {code.bars.map((bar) => (
          <rect
            key={bar.x}
            x={bar.x + QUIET_ZONE}
            y={0}
            width={bar.width}
            height={30}
            fill="#000"
          />
        ))}
      </svg>
      <figcaption>{value}</figcaption>
    </figure>
  );
}
