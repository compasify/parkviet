import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ContextSelector } from './context-selector';
import { usePosSelection } from './pos-selection';

export function ContextSetupDialog({ enabled }: { enabled: boolean }) {
  const { t } = useTranslation();
  const { needsSelection, selectionComplete } = usePosSelection();
  const dialog = useRef<HTMLDialogElement>(null);
  const [dismissed, setDismissed] = useState(false);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const element = dialog.current;
    if (!element) return;
    if (!enabled || selectionComplete) {
      element.close();
      setVisible(false);
    } else if (needsSelection && !dismissed && !element.open) {
      element.showModal();
      setVisible(true);
    }
  }, [enabled, needsSelection, selectionComplete, dismissed]);
  useEffect(() => {
    if (visible) dialog.current?.querySelector<HTMLInputElement>('[role="combobox"]')?.focus();
  }, [visible]);

  return (
    <dialog
      className="context-setup-dialog"
      ref={dialog}
      aria-labelledby="context-setup-title"
      aria-describedby="context-setup-hint"
      onCancel={() => setDismissed(true)}
    >
      <h2 id="context-setup-title">{t('selectSalesContext')}</h2>
      <p id="context-setup-hint">{t('selectSalesContextHint')}</p>
      {visible ? <ContextSelector /> : null}
      <div className="dialog-actions">
        <button
          type="button"
          onClick={() => {
            setDismissed(true);
            dialog.current?.close();
          }}
        >
          {t('chooseLater')}
        </button>
      </div>
    </dialog>
  );
}
