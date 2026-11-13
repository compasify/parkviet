import type { BoardTable } from '@parkviet/pos-shared/tables';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../lib/dialog-focus';
import type { PosWorkspace } from '../lib/pos-context';
import { canSplitBySeat, seatsOf, sharedLines } from '../lib/table-courses';
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
  onSplitBySeat,
  onClose,
  initialMode = 'lines',
}: {
  workspace: PosWorkspace;
  tableId: string | null;
  tables: BoardTable[];
  busy: boolean;
  error: string;
  onSplit: (input: { saleLineIds: string[]; resourceId?: string }) => void;
  // One bill per seat, each shared dish on the seat picked for it.
  onSplitBySeat?: (shared: Record<string, number>) => void;
  onClose: () => void;
  // The way it opens: by lines, or by seat where seats are tracked.
  initialMode?: 'lines' | 'seat';
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const card = useRef<HTMLDivElement>(null);
  const [picked, setPicked] = useState<string[]>([]);
  const [target, setTarget] = useState('');
  const bySeat = Boolean(onSplitBySeat) && canSplitBySeat(workspace);
  const [mode, setMode] = useState<'lines' | 'seat'>(initialMode);
  const seats = seatsOf(workspace);
  const shared = sharedLines(workspace);
  const [sharedSeat, setSharedSeat] = useState<Record<string, number>>({});
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
        {bySeat ? (
          <div className="row split-order-mode" role="radiogroup" aria-label={t('tableSplitMode')}>
            <label>
              <input
                type="radio"
                name="split-mode"
                checked={mode === 'lines'}
                onChange={() => setMode('lines')}
              />
              {t('tableSplitByLines')}
            </label>
            <label>
              <input
                type="radio"
                name="split-mode"
                checked={mode === 'seat'}
                onChange={() => setMode('seat')}
              />
              {t('tableSplitBySeat')}
            </label>
          </div>
        ) : null}
        {bySeat && mode === 'seat' ? (
          <>
            <p className="workspace-hint">{t('tableSplitBySeatHint', { count: seats.length })}</p>
            {shared.length > 0 ? (
              <fieldset className="split-order-lines">
                <legend>{t('tableSplitShared')}</legend>
                {shared.map((line) => (
                  <label key={line.sale_line_id}>
                    <span>
                      {line.quantity} × {line.name}
                    </span>
                    <select
                      value={sharedSeat[line.sale_line_id ?? ''] ?? seats[0]}
                      onChange={(event) =>
                        setSharedSeat((current) => ({
                          ...current,
                          [line.sale_line_id ?? '']: Number(event.target.value),
                        }))
                      }
                    >
                      {seats.map((seat) => (
                        <option key={seat} value={seat}>
                          {t('seatNumber', { seat })}
                        </option>
                      ))}
                    </select>
                  </label>
                ))}
              </fieldset>
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
                disabled={busy}
                onClick={() =>
                  onSplitBySeat?.(
                    Object.fromEntries(
                      shared.map((line) => [
                        line.sale_line_id ?? '',
                        sharedSeat[line.sale_line_id ?? ''] ?? seats[0],
                      ]),
                    ),
                  )
                }
              >
                {busy ? t('waiting') : t('tableSplitBySeatAction', { count: seats.length })}
              </button>
              <button type="button" disabled={busy} onClick={onClose}>
                {t('creditClose')}
              </button>
            </div>
          </>
        ) : (
          <>
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
          </>
        )}
      </div>
    </div>
  );
}
