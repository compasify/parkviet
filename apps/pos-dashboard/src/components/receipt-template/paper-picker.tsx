import type { PaperSize } from '@parkviet/pos-shared/receipt-template/types'
import { Label, RadioGroup, RadioGroupItem } from '@spree/dashboard-ui'
import { useId } from 'react'
import { useTranslation } from 'react-i18next'

const PAPER_SIZES: readonly PaperSize[] = ['58mm', '80mm', 'a4', 'a5', 'a6']

export function PaperPicker({
  value,
  onChange,
  sizes = PAPER_SIZES,
  disabled,
}: {
  value: PaperSize
  onChange: (paper: PaperSize) => void
  sizes?: readonly PaperSize[]
  disabled?: boolean
}) {
  const { t } = useTranslation('pos')
  const id = useId()
  return (
    <div className="grid gap-3">
      <Label id={`${id}-label`}>{t('receiptPaper')}</Label>
      <RadioGroup
        className="flex flex-wrap gap-4"
        value={value}
        disabled={disabled}
        onValueChange={(next) => onChange(next as PaperSize)}
        aria-labelledby={`${id}-label`}
      >
        {sizes.map((size) => (
          <div
            key={size}
            className="flex items-center gap-2 rounded-lg border px-3 py-2"
            title={t(`receiptPaperHint_${size}`)}
          >
            <RadioGroupItem id={`${id}-${size}`} value={size} />
            <Label htmlFor={`${id}-${size}`}>{t(`receiptPaper_${size}`)}</Label>
          </div>
        ))}
      </RadioGroup>
    </div>
  )
}
