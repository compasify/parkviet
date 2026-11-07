import { useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import {
  CALIBRATION_CHANGED,
  type CalibrationResult,
  clearCalibration,
  createCalibrationRecorder,
  readCalibration,
  type ScannerCalibration,
  saveCalibration,
} from '../lib/scanner-calibration';
import { PosIcon } from './pos-icon';

// The calibration of the register's scanner, kept in sync across components.
export function useScannerCalibration(registerId: string | null): ScannerCalibration {
  const [calibration, setCalibration] = useState(() => readCalibration(registerId));
  useEffect(() => {
    setCalibration(readCalibration(registerId));
    const update = () => setCalibration(readCalibration(registerId));
    window.addEventListener(CALIBRATION_CHANGED, update);
    window.addEventListener('storage', update);
    return () => {
      window.removeEventListener(CALIBRATION_CHANGED, update);
      window.removeEventListener('storage', update);
    };
  }, [registerId]);
  return calibration;
}

// Scan one test barcode into the field: the dialog learns which key the
// scanner sends at the end and how fast it types, then saves both for this
// register on this device.
export function ScannerCalibrationDialog({
  registerId,
  onClose,
}: {
  registerId: string;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const card = useRef<HTMLDivElement>(null);
  const titleId = useId();
  const current = useScannerCalibration(registerId);
  const [recorder] = useState(() => createCalibrationRecorder());
  const [result, setResult] = useState<CalibrationResult | null>(null);
  const [saved, setSaved] = useState('');
  useModalFocus(card, onClose);
  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('scannerCalibrationTitle')}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <p>
          {t('scannerCalibrationCurrent', {
            terminator: current.terminator,
            gap: current.maxGapMs,
          })}
        </p>
        <label>
          {t('scannerCalibrationField')}
          <input
            autoComplete="off"
            onKeyDown={(event) => {
              const outcome = recorder.push({
                key: event.key,
                timeStamp: event.timeStamp,
                isComposing: event.nativeEvent.isComposing || event.keyCode === 229,
              });
              if (event.key === 'Tab' || event.key === 'Enter') event.preventDefault();
              if (outcome) {
                setResult(outcome);
                setSaved('');
                event.currentTarget.value = '';
              }
            }}
          />
        </label>
        {result?.ok ? (
          <p role="status">
            {t('scannerCalibrationResult', {
              code: result.code,
              terminator: result.calibration.terminator,
              gap: result.calibration.maxGapMs,
            })}
          </p>
        ) : result ? (
          <p className="error" role="alert">
            {t(`scannerCalibration_${result.reason}`)}
          </p>
        ) : (
          <p className="muted">{t('scannerCalibrationHint')}</p>
        )}
        <div className="row">
          <button
            type="button"
            disabled={!result?.ok}
            onClick={() => {
              if (result?.ok && saveCalibration(registerId, result.calibration))
                setSaved(t('scannerCalibrationSaved'));
              else setSaved(t('scannerCalibrationStorage'));
            }}
          >
            {t('scannerCalibrationSave')}
          </button>
          <button
            type="button"
            onClick={() => {
              clearCalibration(registerId);
              setResult(null);
              setSaved(t('scannerCalibrationReset'));
            }}
          >
            {t('scannerCalibrationDefault')}
          </button>
        </div>
        {saved ? <p role="status">{saved}</p> : null}
      </div>
    </div>
  );
}
