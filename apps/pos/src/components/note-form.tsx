import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';

export function NoteForm({
  workspace,
  disabled,
  onSave,
  onClose,
}: {
  workspace: PosWorkspace;
  disabled: boolean;
  onSave: (note: string) => Promise<PosWorkspace>;
  onClose?: () => void;
}) {
  const { t } = useTranslation();
  const [note, setNote] = useState(workspace.note ?? '');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError('');
    try {
      const saved = await onSave(note.trim());
      setNote(saved.note ?? '');
      onClose?.();
    } catch {
      setError(t('noteFailed'));
    } finally {
      setBusy(false);
    }
  }

  return (
    <form className="note-form pos-popup-card" onSubmit={submit}>
      <div className="pos-popup-header">
        <strong>{t('noteTitle')}</strong>
        <span className="muted">{note.trim().length} / 1000</span>
      </div>
      <label>
        {t('noteLabel')}
        <textarea
          maxLength={1000}
          rows={3}
          value={note}
          onChange={(event) => setNote(event.target.value)}
          disabled={disabled || busy}
          placeholder={t('notePlaceholder')}
        />
      </label>
      <div className="row">
        <button type="submit" className="primary-button" disabled={disabled || busy}>
          {t('noteSave')}
        </button>
        {onClose ? (
          <button type="button" onClick={onClose}>
            {t('adminClose')}
          </button>
        ) : null}
      </div>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </form>
  );
}
