import { createContext, type ReactNode, useContext, useEffect, useRef, useState } from 'react';
import { useContextBranches, useContextRegisters } from '../hooks/use-context-options';
import { usePosContext } from '../hooks/use-pos-context';
import { useSession } from '../hooks/use-session';
import { emptySelection, type PosSelection } from '../lib/pos-context';
import { emptyOptions, onlyActiveOption } from '../lib/pos-selection-rules';
import { posFailureKey } from '../lib/request-failure';
import { handoffBranch } from '../lib/requested-store';
import { readLayout, writeLayout } from '../lib/workspace-storage';

type PosSelectionValue = {
  selection: PosSelection;
  setSelection: (next: PosSelection) => void;
  context: ReturnType<typeof usePosContext>;
  notice: string;
  registerMode: 'loading' | 'none' | 'required' | 'error';
  selectionComplete: boolean;
  needsSelection: boolean;
};

const SelectionContext = createContext<PosSelectionValue | null>(null);

export function PosSelectionProvider({ children }: { children: ReactNode }) {
  const snapshot = useSession();
  const [selection, setSelectionState] = useState<PosSelection>(emptySelection);
  const [ready, setReady] = useState(false);
  const [notice, setNotice] = useState('');
  const context = usePosContext(selection);
  const branchOptions = useContextBranches(
    context.data?.store.id ?? null,
    ready && context.isSuccess,
  );
  const registerOptions = useContextRegisters(
    context.data?.store.id ?? null,
    selection.branchId,
    ready && context.isSuccess,
  );
  const soleBranch = onlyActiveOption(branchOptions.isSuccess ? branchOptions.data : undefined);
  const soleRegister = onlyActiveOption(
    registerOptions.isSuccess ? registerOptions.data : undefined,
  );
  const registerMode = registerOptions.isError
    ? 'error'
    : !registerOptions.isSuccess
      ? 'loading'
      : emptyOptions(registerOptions.data)
        ? 'none'
        : 'required';
  const validated =
    ready &&
    context.isSuccess &&
    context.data?.selection.branch_id === selection.branchId &&
    (context.data?.selection.register_id ?? null) === selection.registerId;
  const selectionComplete = Boolean(
    validated &&
      selection.branchId &&
      (selection.registerId || (registerOptions.isSuccess && registerMode === 'none')),
  );
  const needsSelection = Boolean(
    validated &&
      (!selection.branchId
        ? (branchOptions.isSuccess && !soleBranch) || branchOptions.isError
        : !selection.registerId &&
          ((registerOptions.isSuccess && registerMode === 'required' && !soleRegister) ||
            registerOptions.isError)),
  );
  const lastGood = useRef(emptySelection);

  // biome-ignore lint/correctness/useExhaustiveDependencies: generation is the session boundary
  useEffect(() => {
    setSelectionState(emptySelection);
    setReady(false);
    setNotice('');
    lastGood.current = emptySelection;
  }, [snapshot.generation]);

  useEffect(() => {
    if (ready || !context.data) return;
    const saved = readLayout(context.data.staff.id, context.data.store.id);
    // The dashboard named this branch for this store. A saved layout of
    // another visit must not override the screen the reader just left.
    const requested = handoffBranch(context.data.store.id);
    if (requested) {
      setSelectionState({ branchId: requested, registerId: null });
    } else if (saved?.branchId) {
      setSelectionState({ branchId: saved.branchId, registerId: saved.registerId });
    }
    setReady(true);
  }, [context.data, ready]);

  useEffect(() => {
    if (!validated) return;
    if (!selection.branchId && soleBranch) {
      setSelectionState({ branchId: soleBranch.id, registerId: null });
    } else if (selection.branchId && !selection.registerId && soleRegister) {
      setSelectionState({ branchId: selection.branchId, registerId: soleRegister.id });
    }
  }, [validated, selection.branchId, selection.registerId, soleBranch, soleRegister]);

  useEffect(() => {
    if (!ready || !context.isSuccess || !context.data) return;
    if (context.data.selection.branch_id !== selection.branchId) return;
    if ((context.data.selection.register_id ?? null) !== selection.registerId) return;
    lastGood.current = selection;
    const current = readLayout(context.data.staff.id, context.data.store.id);
    writeLayout({
      staffId: context.data.staff.id,
      storeId: context.data.store.id,
      savedAt: Date.now(),
      branchId: context.data.selection.branch_id,
      registerId: context.data.selection.register_id,
      openWorkspaceIds: current?.openWorkspaceIds ?? [],
      tabNumbers:
        current?.branchId === selection.branchId && current?.registerId === selection.registerId
          ? current?.tabNumbers
          : {},
      closedWorkspaceIds:
        current?.branchId === selection.branchId && current?.registerId === selection.registerId
          ? current.closedWorkspaceIds
          : [],
      activeWorkspaceId:
        current?.branchId === selection.branchId && current?.registerId === selection.registerId
          ? current.activeWorkspaceId
          : null,
      workspacePage:
        current?.branchId === selection.branchId && current?.registerId === selection.registerId
          ? current.workspacePage
          : 1,
    });
  }, [context.data, context.isSuccess, ready, selection]);

  useEffect(() => {
    if (!context.isError) return;
    const failure = posFailureKey(context.error);
    if (failure !== 'forbidden' && failure !== 'missing') return;
    const good = lastGood.current;
    if (good.branchId === selection.branchId && good.registerId === selection.registerId) return;
    setNotice('selectionRestored');
    setSelectionState(good);
  }, [context.error, context.isError, selection]);

  function setSelection(next: PosSelection) {
    setNotice('');
    setSelectionState(next);
  }

  return (
    <SelectionContext.Provider
      value={{
        selection,
        setSelection,
        context,
        notice,
        registerMode,
        selectionComplete,
        needsSelection,
      }}
    >
      {children}
    </SelectionContext.Provider>
  );
}

export function usePosSelection() {
  const value = useContext(SelectionContext);
  if (!value) throw new Error('POS selection is unavailable.');
  return value;
}
