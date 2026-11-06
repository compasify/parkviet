import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useOpenShift } from '../hooks/use-shift';
import { writesLocked } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { usePosSelection } from './pos-selection';

export function OpenShiftDialog() {
  const { t } = useTranslation();
  const { selection, context, selectionComplete } = usePosSelection();
  const openShift = useOpenShift();
  const [amount, setAmount] = useState('0');
  const [error, setError] = useState('');
  const data = context.data;
  const canOpen = Boolean(
    selectionComplete &&
      data?.capabilities.includes('pos.shift.open') &&
      !data.shift &&
      !writesLocked(data, selection),
  );
  if (!canOpen || !selection.branchId) return null;

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!selection.branchId) return;
    setError('');
    try {
      await openShift.mutateAsync({
        ...(selection.registerId
          ? { register_id: selection.registerId }
          : { branch_id: selection.branchId }),
        opening_float: amount.trim(),
      });
      setAmount('0');
    } catch (caught) {
      setError(t(posFailureKey(caught)));
    }
  }

  return (
    <form className="dialog" onSubmit={submit}>
      <label>
        {t('openingFloat')}
        <input
          inputMode="decimal"
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
        />
      </label>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      <button type="submit" disabled={openShift.isPending}>
        {openShift.isPending ? t('waiting') : t('openShift')}
      </button>
    </form>
  );
}
