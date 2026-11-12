import type { TFunction } from 'i18next';
import { useId, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { MAX_LINE_QUANTITY, NOTE_MAX } from '../lib/cart';
import {
  defaultPicks,
  fromHundredths,
  groupProblem,
  itemGroups,
  type Picks,
  pickNames,
  picksReady,
  stepPick,
  togglePick,
  toHundredths,
  unitPrice,
} from '../lib/modifiers';
import { formatMoney } from '../lib/money';
import type { GuestMenu, MenuItem, ModifierGroup } from '../lib/types';

export type PickedItem = {
  itemId: string;
  variantId: string;
  name: string;
  size: string | null;
  quantity: number;
  picks: Picks;
  options: string[];
  note: string;
  unitPrice: string;
};

function groupRule(group: ModifierGroup, t: TFunction) {
  if (group.min_select > 0)
    return t('groupRange', { min: group.min_select, max: group.max_select });
  return t('groupUpTo', { max: group.max_select });
}

// One dish: its size, its option groups (with the counter's min / max rules),
// how many and a note for the kitchen.
export function ItemScreen({
  menu,
  item,
  onAdd,
  onBack,
}: {
  menu: GuestMenu;
  item: MenuItem;
  onAdd: (picked: PickedItem) => void;
  onBack: () => void;
}) {
  const { t, i18n } = useTranslation();
  const groups = itemGroups(menu, item);
  const [variantId, setVariantId] = useState(item.variants[0]?.id ?? '');
  const [picks, setPicks] = useState<Picks>(() => defaultPicks(groups));
  const [quantity, setQuantity] = useState(1);
  const [note, setNote] = useState('');
  const noteId = useId();
  const variant = item.variants.find((row) => row.id === variantId) ?? item.variants[0];
  const unit = variant ? unitPrice(variant.price, groups, picks) : null;
  const ready = Boolean(variant && unit !== null && picksReady(groups, picks));
  const hundredths = unit === null ? null : toHundredths(unit);
  const total = hundredths === null ? null : fromHundredths(hundredths * BigInt(quantity));

  return (
    <section className="item-screen" aria-label={item.name}>
      <button type="button" className="link" onClick={onBack}>
        ← {t('back')}
      </button>
      <h2>{item.name}</h2>
      {item.variants.length > 1 ? (
        <fieldset>
          <legend>{t('size')}</legend>
          {item.variants.map((row) => (
            <label key={row.id} className="option">
              <input
                type="radio"
                name="variant"
                checked={row.id === variantId}
                onChange={() => setVariantId(row.id)}
              />
              <span>{row.name ?? item.name}</span>
              <span className="price">{formatMoney(row.price, menu.currency, i18n.language)}</span>
            </label>
          ))}
        </fieldset>
      ) : null}
      {groups.map((group) => {
        const problem = groupProblem(group, picks);
        return (
          <fieldset
            key={group.id}
            data-testid={`group-${group.id}`}
            aria-invalid={problem !== null}
          >
            <legend>
              {group.name}{' '}
              <small>
                {group.required || group.min_select > 0 ? `${t('groupRequired')} · ` : ''}
                {groupRule(group, t)}
              </small>
            </legend>
            {group.options.map((option) => {
              const count = picks[option.id] ?? 0;
              const delta = Number(option.price_delta);
              return (
                <div key={option.id} className="option">
                  <label>
                    <input
                      type={group.max_select === 1 && !group.allow_quantity ? 'radio' : 'checkbox'}
                      name={group.id}
                      checked={count > 0}
                      onChange={() => setPicks((current) => togglePick(group, current, option.id))}
                    />
                    <span>{option.name}</span>
                  </label>
                  {delta !== 0 ? (
                    <span className="price">
                      +{formatMoney(option.price_delta, menu.currency, i18n.language)}
                    </span>
                  ) : null}
                  {group.allow_quantity && count > 0 ? (
                    <span className="stepper">
                      <button
                        type="button"
                        aria-label={`${t('less')} ${option.name}`}
                        onClick={() =>
                          setPicks((current) => stepPick(group, current, option.id, -1))
                        }
                      >
                        −
                      </button>
                      <span>{count}</span>
                      <button
                        type="button"
                        aria-label={`${t('more')} ${option.name}`}
                        onClick={() =>
                          setPicks((current) => stepPick(group, current, option.id, 1))
                        }
                      >
                        +
                      </button>
                    </span>
                  ) : null}
                </div>
              );
            })}
            {problem ? (
              <p className="error" role="alert">
                {problem === 'min'
                  ? t('groupMin', { min: group.min_select })
                  : t('groupMax', { max: group.max_select })}
              </p>
            ) : null}
          </fieldset>
        );
      })}
      <div className="stepper quantity">
        <span>{t('quantity')}</span>
        <button
          type="button"
          aria-label={t('less')}
          disabled={quantity <= 1}
          onClick={() => setQuantity((value) => Math.max(1, value - 1))}
        >
          −
        </button>
        <output data-testid="item-quantity">{quantity}</output>
        <button
          type="button"
          aria-label={t('more')}
          disabled={quantity >= MAX_LINE_QUANTITY}
          onClick={() => setQuantity((value) => Math.min(MAX_LINE_QUANTITY, value + 1))}
        >
          +
        </button>
      </div>
      <label htmlFor={noteId}>{t('note')}</label>
      <input
        id={noteId}
        value={note}
        maxLength={NOTE_MAX}
        placeholder={t('notePlaceholder')}
        onChange={(event) => setNote(event.target.value)}
      />
      <button
        type="button"
        className="primary block"
        disabled={!ready}
        data-testid="add-to-cart"
        onClick={() => {
          if (!variant || unit === null) return;
          onAdd({
            itemId: item.id,
            variantId: variant.id,
            name: item.name,
            size: item.variants.length > 1 ? variant.name : null,
            quantity,
            picks,
            options: pickNames(groups, picks),
            note,
            unitPrice: unit,
          });
        }}
      >
        {t('addToCart', { price: formatMoney(total, menu.currency, i18n.language) })}
      </button>
    </section>
  );
}
