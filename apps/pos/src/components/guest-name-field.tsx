import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';

const GUEST_NAME_MAX = 60;

// The name the guest gives at the counter, saved on Enter or when the field
// is left. The call board and the cup labels show it next to the call number.
export function GuestNameField({
  workspace,
  disabled,
  disabledReason,
  onSave,
}: {
  workspace: PosWorkspace;
  disabled: boolean;
  disabledReason?: string;
  onSave: (guestName: string) => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const saved = workspace.guest_name ?? '';
  const [value, setValue] = useState(saved);
  const [message, setMessage] = useState('');
  const [saving, setSaving] = useState(false);

  async function save(event?: FormEvent) {
    event?.preventDefault();
    const next = value.replace(/\s+/g, ' ').trim();
    if (next === saved || saving) return;
    setSaving(true);
    setMessage('');
    try {
      await onSave(next);
      setValue(next);
    } catch (error) {
      setMessage(describeFailure(error, t));
    } finally {
      setSaving(false);
    }
  }

  return (
    <form className="guest-name" onSubmit={(event) => void save(event)}>
      <label>
        {t('guestName')}
        <input
          value={value}
          maxLength={GUEST_NAME_MAX}
          autoComplete="off"
          placeholder={t('guestNamePlaceholder')}
          disabled={disabled || saving}
          title={disabled ? disabledReason : undefined}
          data-testid="guest-name"
          onChange={(event) => setValue(event.target.value)}
          onBlur={() => void save()}
        />
      </label>
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </form>
  );
}
