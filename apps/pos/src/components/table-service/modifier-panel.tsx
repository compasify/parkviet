import { formatMoney } from '@parkviet/pos-shared/money';
import { type ReactNode, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosMenu, PosMenuItem } from '../../lib/pos-context';
import { ModifierForm, type ModifierSheetResult } from '../modifier-sheet';
import { PosIcon } from '../pos-icon';

// The options of one dish in place of the categories and the dishes, so the
// ticket beside it stays in sight. Escape or the back arrow returns to the
// dishes; a successful add does too.
export function ModifierPanel({
  menu,
  item,
  placement,
  onSubmit,
  onClose,
}: {
  menu: PosMenu;
  item: PosMenuItem;
  // Seat and course of the dish, at the bottom of the panel.
  placement?: ReactNode;
  onSubmit: (result: ModifierSheetResult) => Promise<unknown>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();
  const heading = useRef<HTMLHeadingElement>(null);
  const [busy, setBusy] = useState(false);
  const quickNotes = t('menuQuickNoteList', { returnObjects: true });
  const notes = Array.isArray(quickNotes)
    ? quickNotes.filter((row): row is string => typeof row === 'string')
    : [];
  const basePrice = item.variants[0]?.price ?? null;

  useEffect(() => {
    heading.current?.focus();
  }, []);

  return (
    <section
      className="modifier-panel"
      aria-labelledby={titleId}
      onKeyDown={(event) => {
        if (event.key !== 'Escape' || busy) return;
        event.preventDefault();
        onClose();
      }}
    >
      <header className="modifier-panel-header">
        <button
          type="button"
          className="modifier-panel-back"
          onClick={onClose}
          disabled={busy}
          aria-label={t('menuBackToDishes')}
          title={t('menuBackToDishes')}
        >
          <PosIcon name="back" />
        </button>
        <div>
          <h3 id={titleId} ref={heading} tabIndex={-1}>
            {item.name}
          </h3>
          {basePrice ? (
            <small>{t('menuBasePrice', { price: formatMoney(basePrice, menu.currency) })}</small>
          ) : null}
        </div>
      </header>
      <ModifierForm
        key={item.id}
        menu={menu}
        item={item}
        onSubmit={onSubmit}
        onDone={onClose}
        onBusyChange={setBusy}
        panel={{ quickNotes: notes, placement }}
      />
    </section>
  );
}
