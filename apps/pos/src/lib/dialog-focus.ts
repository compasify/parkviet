import { type RefObject, useEffect, useRef } from 'react';

const FOCUSABLE =
  'button:not(:disabled), input:not(:disabled), select:not(:disabled), textarea:not(:disabled), [href], [tabindex]:not([tabindex="-1"])';

function focusables(root: HTMLElement): HTMLElement[] {
  return [...root.querySelectorAll<HTMLElement>(FOCUSABLE)];
}

export function focusFirst(root: HTMLElement | null) {
  (
    root?.querySelector<HTMLElement>('input:not(:disabled), select:not(:disabled)') ??
    root?.querySelector<HTMLElement>('button:not(:disabled)') ??
    root
  )?.focus();
}

// Everything outside the dialog becomes inert, walking up from its backdrop so
// only the dialog's own branch stays reachable. Returns the undo.
function inertOutside(root: HTMLElement): () => void {
  const changed: HTMLElement[] = [];
  let node: HTMLElement | null = root.closest<HTMLElement>('.pos-popup-backdrop') ?? root;
  while (node?.parentElement) {
    for (const sibling of node.parentElement.children) {
      if (sibling !== node && sibling instanceof HTMLElement && !sibling.inert) {
        sibling.inert = true;
        changed.push(sibling);
      }
    }
    if (node.parentElement === document.body) break;
    node = node.parentElement;
  }
  return () => {
    for (const element of changed) element.inert = false;
  };
}

// Modal behaviour for a dialog element: focus starts inside and stays inside
// (also when the focused button becomes disabled while a command runs), Tab
// wraps, Escape asks to close, the page behind is inert, and focus returns to
// the control that opened the dialog when it closes.
export function useModalFocus(root: RefObject<HTMLElement | null>, onEscape: () => void) {
  const escapeHandler = useRef(onEscape);
  escapeHandler.current = onEscape;

  useEffect(() => {
    const element = root.current;
    if (!element) return;
    const trigger = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const restoreInert = inertOutside(element);
    focusFirst(element);

    const keep = () => {
      if (!element.contains(document.activeElement)) element.focus();
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        event.stopPropagation();
        escapeHandler.current();
        return;
      }
      if (event.key !== 'Tab') return;
      const items = focusables(element);
      if (items.length === 0) {
        event.preventDefault();
        element.focus();
        return;
      }
      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement;
      if (!element.contains(active)) {
        event.preventDefault();
        first.focus();
      } else if (event.shiftKey && (active === first || active === element)) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && active === last) {
        event.preventDefault();
        first.focus();
      }
    };
    const observer = new MutationObserver(keep);
    observer.observe(element, { attributes: true, attributeFilter: ['disabled'], subtree: true });
    document.addEventListener('keydown', onKeyDown, true);
    document.addEventListener('focusin', keep);
    return () => {
      observer.disconnect();
      document.removeEventListener('keydown', onKeyDown, true);
      document.removeEventListener('focusin', keep);
      restoreInert();
      if (trigger?.isConnected) trigger.focus();
    };
  }, [root]);
}
