import { type KeyboardEvent, useEffect, useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';

export type SearchableOption = { value: string; label: string };

type Props = {
  label: string;
  placeholder: string;
  searchPlaceholder: string;
  value: string | null;
  options: SearchableOption[];
  onChange: (value: string) => void;
  /** Server-side search; the typed text is also matched locally against loaded options. */
  onSearch?: (query: string) => void;
  disabled?: boolean;
  page?: number;
  pages?: number;
  onPage?: (page: number) => void;
};

const fold = (text: string) =>
  text.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'D').toLowerCase();

/**
 * A combobox that searches inside the dropdown itself, so pickers never need a
 * separate search field next to them.
 */
export function SearchableSelect({
  label,
  placeholder,
  searchPlaceholder,
  value,
  options,
  onChange,
  onSearch,
  disabled,
  page = 1,
  pages = 1,
  onPage,
}: Props) {
  const { t } = useTranslation();
  const id = useId();
  const listId = `${id}-list`;
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [active, setActive] = useState(0);
  // Debounce server search; the loaded options are filtered locally on every keystroke.
  const search = useRef(onSearch);
  search.current = onSearch;
  const searched = useRef('');
  useEffect(() => {
    if (query === searched.current) return;
    const timer = setTimeout(
      () => {
        searched.current = query;
        search.current?.(query);
      },
      query ? 250 : 0,
    );
    return () => clearTimeout(timer);
  }, [query]);
  const selected = options.find((option) => option.value === value);
  const needle = fold(query.trim());
  const visible = needle
    ? options.filter((option) => fold(option.label).includes(needle))
    : options;
  const activeIndex = Math.min(active, Math.max(visible.length - 1, 0));
  useEffect(() => {
    if (open)
      document.getElementById(`${id}-opt-${activeIndex}`)?.scrollIntoView({ block: 'nearest' });
  }, [open, id, activeIndex]);

  const close = () => {
    setOpen(false);
    setQuery('');
  };
  const openList = () => {
    if (disabled || open) return;
    const current = options.findIndex((option) => option.value === value);
    setActive(Math.max(current, 0));
    setOpen(true);
  };
  const choose = (option: SearchableOption | undefined) => {
    if (!option) return;
    close();
    if (option.value !== value) onChange(option.value);
  };
  const onKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      if (!open) return openList();
      const step = event.key === 'ArrowDown' ? 1 : -1;
      setActive(Math.max(0, Math.min(visible.length - 1, activeIndex + step)));
    } else if (event.key === 'Enter') {
      if (!open) return;
      event.preventDefault();
      choose(visible[activeIndex]);
    } else if (event.key === 'Escape' && open) {
      // Close only the list, not the surrounding dialog or popover.
      event.preventDefault();
      event.stopPropagation();
      close();
    } else if (event.key === 'Tab' && open) {
      close();
    }
  };

  return (
    // biome-ignore lint/a11y/noStaticElementInteractions: only tracks focus leaving the picker
    <div
      className="searchable-select"
      data-open={open}
      onBlur={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget as Node | null)) close();
      }}
    >
      <label htmlFor={id}>{label}</label>
      <div className="searchable-select-field">
        <input
          id={id}
          role="combobox"
          aria-expanded={open}
          aria-controls={listId}
          aria-autocomplete="list"
          aria-activedescendant={open && visible.length ? `${id}-opt-${activeIndex}` : undefined}
          autoComplete="off"
          data-value={value ?? ''}
          disabled={disabled}
          value={open ? query : (selected?.label ?? '')}
          placeholder={open ? searchPlaceholder : placeholder}
          onClick={openList}
          onKeyDown={onKeyDown}
          onChange={(event) => {
            if (!open) setOpen(true);
            setQuery(event.target.value);
            setActive(0);
            onPage?.(1);
          }}
        />
      </div>
      {open ? (
        <div className="searchable-select-panel">
          <div id={listId} role="listbox">
            {visible.map((option, index) => (
              // biome-ignore lint/a11y/useKeyWithClickEvents: keys are handled by the combobox input (aria-activedescendant)
              <div
                key={option.value}
                id={`${id}-opt-${index}`}
                role="option"
                tabIndex={-1}
                data-value={option.value}
                aria-selected={option.value === value}
                data-active={index === activeIndex}
                onMouseDown={(event) => event.preventDefault()}
                onMouseEnter={() => setActive(index)}
                onClick={() => choose(option)}
              >
                {option.label}
              </div>
            ))}
          </div>
          {visible.length === 0 ? (
            <p className="searchable-select-empty">{t('searchNoMatch')}</p>
          ) : null}
          {pages > 1 && onPage ? (
            <div className="row searchable-select-pages">
              <button
                type="button"
                tabIndex={-1}
                disabled={page <= 1}
                onMouseDown={(event) => event.preventDefault()}
                onClick={() => onPage(page - 1)}
              >
                {t('previousPage')}
              </button>
              <span>
                {page} / {pages}
              </span>
              <button
                type="button"
                tabIndex={-1}
                disabled={page >= pages}
                onMouseDown={(event) => event.preventDefault()}
                onClick={() => onPage(page + 1)}
              >
                {t('nextPage')}
              </button>
            </div>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
