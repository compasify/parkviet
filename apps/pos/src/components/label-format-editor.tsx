import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { saveLabelFormat } from '../hooks/use-branch-catalog';
import {
  LABEL_BODY_LENGTH,
  LABEL_NAME_MAX,
  LABEL_WEIGHT_UNITS,
  type LabelFormat,
  type LabelFormatDraft,
  labelDigitsUsed,
  labelFormatBody,
  labelFormatDraft,
  labelFormatProblems,
} from '../lib/label-format';
import { describeFailure } from '../lib/request-failure';
import { AdminDialog } from './admin-dialog';

export function LabelFormatEditor({
  branchId,
  format,
  onSaved,
  onClose,
}: {
  branchId: string;
  format?: LabelFormat;
  onSaved: (saved: LabelFormat) => Promise<void> | void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const [draft, setDraft] = useState<LabelFormatDraft>(() => labelFormatDraft(format));
  const [dirty, setDirty] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const problems = labelFormatProblems(draft);
  const used = labelDigitsUsed(draft);
  const layoutProblem = problems.includes('layout');

  function set<K extends keyof LabelFormatDraft>(key: K, value: LabelFormatDraft[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
    setDirty(true);
  }

  async function submit(event: FormEvent) {
    event.preventDefault();
    const body = labelFormatBody(draft);
    if (busy || !body) return;
    setBusy(true);
    setError('');
    try {
      const result = await saveLabelFormat(branchId, format?.id, body);
      await onSaved(result.data);
      onClose();
    } catch (failure) {
      setError(describeFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  const invalid = (problem: (typeof problems)[number]) => dirty && problems.includes(problem);
  return (
    <AdminDialog
      id="label-format-editor"
      title={t(format ? 'labelFormatEditTitle' : 'labelFormatCreateTitle')}
      subtitle={format ? t('labelFormatVersion', { version: format.version }) : undefined}
      busy={busy}
      dirty={dirty}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={submit} aria-busy={busy} noValidate>
          <fieldset className="admin-form-fields" disabled={busy}>
            <div className="admin-form-grid">
              <label>
                {t('labelFormatName')}
                <input
                  aria-label={t('labelFormatName')}
                  required
                  maxLength={LABEL_NAME_MAX}
                  value={draft.name}
                  aria-invalid={invalid('name')}
                  onChange={(event) => set('name', event.target.value)}
                />
              </label>
              <label>
                {t('labelFormatKind')}
                <select
                  aria-label={t('labelFormatKind')}
                  value={draft.kind}
                  onChange={(event) => {
                    const kind = event.target.value === 'price' ? 'price' : 'weight';
                    setDraft((current) => ({
                      ...current,
                      kind,
                      value_unit_code: kind === 'price' ? '' : current.value_unit_code || 'g',
                    }));
                    setDirty(true);
                  }}
                >
                  <option value="weight">{t('labelFormatKind_weight')}</option>
                  <option value="price">{t('labelFormatKind_price')}</option>
                </select>
              </label>
            </div>
            <fieldset className="label-layout-fields" aria-describedby="label-layout-status">
              <legend>{t('labelFormatLayout')}</legend>
              <div className="admin-form-grid label-layout-grid">
                <label>
                  {t('labelFormatPrefix')}
                  <input
                    aria-label={t('labelFormatPrefix')}
                    inputMode="numeric"
                    maxLength={4}
                    value={draft.prefix}
                    aria-invalid={invalid('prefix') || layoutProblem}
                    onChange={(event) => set('prefix', event.target.value)}
                  />
                </label>
                <label>
                  {t('labelFormatItemCodeLength')}
                  <input
                    aria-label={t('labelFormatItemCodeLength')}
                    inputMode="numeric"
                    maxLength={2}
                    value={draft.item_code_length}
                    aria-invalid={invalid('itemCodeLength') || layoutProblem}
                    onChange={(event) => set('item_code_length', event.target.value)}
                  />
                </label>
                <label>
                  {t('labelFormatValueLength')}
                  <input
                    aria-label={t('labelFormatValueLength')}
                    inputMode="numeric"
                    maxLength={2}
                    value={draft.value_length}
                    aria-invalid={invalid('valueLength') || layoutProblem}
                    onChange={(event) => set('value_length', event.target.value)}
                  />
                </label>
                <label>
                  {t('labelFormatDecimals')}
                  <input
                    aria-label={t('labelFormatDecimals')}
                    inputMode="numeric"
                    maxLength={1}
                    value={draft.value_decimals}
                    aria-invalid={invalid('decimals')}
                    onChange={(event) => set('value_decimals', event.target.value)}
                  />
                </label>
              </div>
              <p
                id="label-layout-status"
                className={layoutProblem ? 'error' : 'admin-info'}
                aria-live="polite"
              >
                {used === null
                  ? t('labelFormatLayoutUnknown', { total: LABEL_BODY_LENGTH })
                  : t(layoutProblem ? 'labelFormatLayoutInvalid' : 'labelFormatLayoutValid', {
                      used,
                      total: LABEL_BODY_LENGTH,
                    })}
              </p>
            </fieldset>
            {draft.kind === 'weight' ? (
              <label>
                {t('labelFormatUnit')}
                <select
                  aria-label={t('labelFormatUnit')}
                  value={draft.value_unit_code}
                  aria-invalid={invalid('unit')}
                  onChange={(event) => set('value_unit_code', event.target.value)}
                >
                  <option value="">{t('labelFormatChooseUnit')}</option>
                  {LABEL_WEIGHT_UNITS.map((unit) => (
                    <option key={unit} value={unit}>
                      {unit}
                    </option>
                  ))}
                </select>
              </label>
            ) : (
              <label>
                {t('labelFormatTolerance')}
                <input
                  aria-label={t('labelFormatTolerance')}
                  inputMode="decimal"
                  value={draft.price_tolerance}
                  aria-invalid={invalid('tolerance')}
                  aria-describedby="label-tolerance-hint"
                  onChange={(event) => set('price_tolerance', event.target.value)}
                />
                <small id="label-tolerance-hint">{t('labelFormatToleranceHint')}</small>
              </label>
            )}
            {format ? <p className="admin-info">{t('labelFormatVersionNote')}</p> : null}
          </fieldset>
          {dirty && problems.length ? (
            <ul className="error label-format-problems" aria-live="polite">
              {problems.map((problem) => (
                <li key={problem}>
                  {t(`labelFormatProblem_${problem}`, { total: LABEL_BODY_LENGTH })}
                </li>
              ))}
            </ul>
          ) : null}
          {error ? (
            <p role="alert" className="error">
              {error}
            </p>
          ) : null}
          <div className="topology-dialog-actions">
            <button type="button" disabled={busy} onClick={close}>
              {t('adminCancel')}
            </button>
            <button
              type="submit"
              className="primary-button"
              disabled={busy || !dirty || problems.length > 0}
            >
              {busy ? t('waiting') : t('save')}
            </button>
          </div>
        </form>
      )}
    </AdminDialog>
  );
}
