import type { BoardTable } from '@parkviet/pos-shared/tables';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

// Picks the lines that leave this table order for a new one, at the same
// table or a free one. At least one line stays behind.
export function SplitOrderDialog({
  workspace,
  tableId,
  tables,
  busy,
  error,
  onSplit,
  onClose,
}: {
  workspace: PosWorkspace;
  tableId: string | null;
  tables: BoardTable[];
  busy: boolean;
  error: string;
  onSplit: (input: { saleLineIds: string[]; resourceId?: string }) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const [picked, setPicked] = useState<string[]>([]);
  const [target, setTarget] = useState('');
  useModalFocus(card, () => {
    if (!busy) onClose();
  });
  const lines = (workspace.line_items ?? []).flatMap((line) =>
    line.sale_line_id ? [{ id: line.sale_line_id, name: line.name, quantity: line.quantity }] : [],
  );
  const toggle = (id: string) =>
    setPicked((current) =>
      current.includes(id) ? current.filter((row) => row !== id) : [...current, id],
    );
  const tooMany = picked.length >= lines.length;
  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card split-order-dialog"
      >
        <div className="pos-popup-header">
          <h4 id={titleId}>{t('tableSplitTitle')}</h4>
          <button
            type="button"
            className="cell-edit-button"
            onClick={onClose}
            disabled={busy}
            aria-label={t('creditClose')}
            title={t('creditClose')}
          >
            <PosIcon name="close" />
          </button>
        </div>
        <fieldset className="split-order-lines">
          <legend>{t('tableSplitLines')}</legend>
          {lines.map((line) => (
            <label key={line.id}>
              <input
                type="checkbox"
                checked={picked.includes(line.id)}
                onChange={() => toggle(line.id)}
              />
              <span>
                {line.quantity} × {line.name}
              </span>
            </label>
          ))}
        </fieldset>
        <label>
          {t('tableSplitTarget')}
          <select value={target} onChange={(event) => setTarget(event.target.value)}>
            <option value="">{t('tableSplitSameTable')}</option>
            {tables
              .filter((row) => row.id !== tableId && row.state === 'available')
              .map((row) => (
                <option key={row.id} value={row.id}>
                  {row.name}
                </option>
              ))}
          </select>
        </label>
        {tooMany ? (
          <p className="workspace-hint" role="status">
            {t('tableFailure_split_all_lines')}
          </p>
        ) : null}
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
        <div className="payment-popup-actions">
          <button
            type="button"
            className="checkout-submit"
            disabled={busy || picked.length === 0 || tooMany}
            onClick={() => onSplit({ saleLineIds: picked, resourceId: target || undefined })}
          >
            {busy ? t('waiting') : t('tableSplitAction')}
          </button>
          <button type="button" disabled={busy} onClick={onClose}>
            {t('creditClose')}
          </button>
        </div>
      </div>
    </div>
  );
}
