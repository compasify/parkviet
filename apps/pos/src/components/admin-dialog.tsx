import { type ReactNode, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from './pos-icon';

// Modal shell shared by administration editors: focus moves into the dialog on
// open and back to the opener on close; Escape asks before dropping changes.
export function AdminDialog({
  id,
  title,
  subtitle,
  busy,
  dirty,
  onClose,
  children,
}: {
  id: string;
  title: string;
  subtitle?: string;
  busy: boolean;
  dirty: boolean;
  onClose: () => void;
  // Receives the guarded close so the form's own Cancel button asks the same way.
  children: (close: () => void) => ReactNode;
}) {
  const { t } = useTranslation();
  const dialog = useRef<HTMLDialogElement>(null);
  useEffect(() => {
    const element = dialog.current;
    const previous = document.activeElement;
    element?.showModal();
    element?.querySelector<HTMLElement>('input:not(:disabled), select:not(:disabled)')?.focus();
    return () => {
      element?.close();
      if (previous instanceof HTMLElement && previous.isConnected) previous.focus();
    };
  }, []);
  function close() {
    if (!busy && (!dirty || window.confirm(t('adminDiscard')))) onClose();
  }
  return (
    <dialog
      ref={dialog}
      className="topology-dialog"
      aria-labelledby={`${id}-title`}
      onCancel={(event) => {
        event.preventDefault();
        close();
      }}
    >
      <div className="topology-dialog-heading">
        <div>
          <p className="admin-eyebrow">{t('adminWorkspace')}</p>
          <h2 id={`${id}-title`}>{title}</h2>
          {subtitle ? <p className="admin-editor-context">{subtitle}</p> : null}
        </div>
        <button type="button" aria-label={t('adminClose')} disabled={busy} onClick={close}>
          <PosIcon name="close" />
        </button>
      </div>
      {children(close)}
    </dialog>
  );
}
