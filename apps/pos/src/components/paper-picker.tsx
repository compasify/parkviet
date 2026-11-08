import { useId } from 'react';
import { useTranslation } from 'react-i18next';
import { PAPER_SIZES, type PaperSize } from '../lib/print-adapter';
import '../styles/receipt.css';

const ROLLS: readonly PaperSize[] = ['58mm', '80mm'];

// Compact paper size picker: thermal rolls and sheets as two chip groups.
// Each chip is a real radio, so it keeps keyboard navigation and its label.
export function PaperPicker({
  value,
  onChange,
  sizes = PAPER_SIZES,
  disabled,
}: {
  value: PaperSize;
  onChange: (paper: PaperSize) => void;
  sizes?: readonly PaperSize[];
  disabled?: boolean;
}) {
  const { t } = useTranslation();
  const name = useId();
  const labelId = `${name}-label`;
  const groups = [
    sizes.filter((size) => ROLLS.includes(size)),
    sizes.filter((size) => !ROLLS.includes(size)),
  ].filter((group) => group.length > 0);
  return (
    <div className="paper-picker" role="radiogroup" aria-labelledby={labelId}>
      <span className="paper-picker-label" id={labelId}>
        {t('receiptPaper')}
      </span>
      {groups.map((group) => (
        <span key={group.join()} className="paper-picker-group">
          {group.map((size) => (
            <label key={size} className="paper-chip" title={t(`receiptPaperHint_${size}`)}>
              <input
                type="radio"
                name={name}
                value={size}
                checked={value === size}
                disabled={disabled}
                onChange={() => onChange(size)}
              />
              {t(`receiptPaper_${size}`)}
            </label>
          ))}
        </span>
      ))}
    </div>
  );
}
