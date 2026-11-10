import { SERVICE_MODES, type ServiceMode } from '@parkviet/pos-shared/types/pos-context';
import { useTranslation } from 'react-i18next';

export function serviceModeOf(value: unknown): ServiceMode {
  return SERVICE_MODES.includes(value as ServiceMode) ? (value as ServiceMode) : 'counter';
}

// A label when the sale is not a counter sale, and a picker only where the
// menu module is on. Retail branches keep counter and never see the picker.
export function ServiceModeControl({
  value,
  enabled,
  disabled,
  onPick,
}: {
  value: unknown;
  enabled: boolean;
  disabled: boolean;
  onPick: (mode: ServiceMode) => void;
}) {
  const { t } = useTranslation();
  const current = serviceModeOf(value);
  if (!enabled) {
    if (current === 'counter') return null;
    return <p className="order-source-tag">{t(`serviceMode.${current}`)}</p>;
  }
  return (
    <fieldset className="order-source-picker" disabled={disabled}>
      <legend>{t('serviceMode.label')}</legend>
      {SERVICE_MODES.map((mode) => (
        <button
          key={mode}
          type="button"
          aria-pressed={current === mode}
          onClick={() => {
            if (mode !== current) onPick(mode);
          }}
        >
          {t(`serviceMode.${mode}`)}
        </button>
      ))}
    </fieldset>
  );
}
