import { useId } from 'react';
import { useTranslation } from 'react-i18next';
import type { PrintChoice } from '../lib/receipt-template/selection';
import '../styles/receipt.css';

// Print template picker: one chip per template the print may use, each with
// its name and paper; the paper follows the template. Each chip is a real
// radio, so it keeps keyboard navigation and its label.
export function TemplatePicker({
  choices,
  value,
  onChange,
  disabled,
}: {
  choices: readonly PrintChoice[];
  value: string | null;
  onChange: (key: string) => void;
  disabled?: boolean;
}) {
  const { t } = useTranslation();
  const name = useId();
  const labelId = `${name}-label`;
  if (choices.length === 0) return null;
  return (
    <div className="paper-picker template-picker" role="radiogroup" aria-labelledby={labelId}>
      <span className="paper-picker-label" id={labelId}>
        {t('receiptTemplates.counter.picker')}
      </span>
      <span className="paper-picker-group">
        {choices.map((choice) => (
          <label
            key={choice.key}
            className="paper-chip"
            title={t(`receiptPaperHint_${choice.paper}`)}
          >
            <input
              type="radio"
              name={name}
              value={choice.key}
              checked={value === choice.key}
              disabled={disabled}
              onChange={() => onChange(choice.key)}
            />
            <span className="template-chip-name">
              {choice.name ?? t('receiptTemplates.counter.loadingName')}
            </span>
            <span className="template-chip-paper">{` · ${t(`receiptPaper_${choice.paper}`)}`}</span>
            {choice.original ? (
              <span className="template-chip-original">
                {` · ${t('receiptTemplates.counter.original')}`}
              </span>
            ) : null}
          </label>
        ))}
      </span>
    </div>
  );
}
