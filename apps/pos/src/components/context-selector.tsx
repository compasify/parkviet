import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useContextBranches, useContextRegisters } from '../hooks/use-context-options';
import type { PosSelection } from '../lib/pos-context';
import { emptyOptions } from '../lib/pos-selection-rules';
import { posFailureKey } from '../lib/request-failure';
import { usePosSelection } from './pos-selection';
import { SearchableSelect } from './searchable-select';

// With `draft`, the picks only change that draft (the header picker saves it
// on confirm); without it they change the live selection (the setup popup).
export function ContextSelector({
  draft,
}: {
  draft?: { selection: PosSelection; onChange: (next: PosSelection) => void };
}) {
  const { t } = useTranslation();
  const live = usePosSelection();
  const { context, notice, storeId } = live;
  const selection = draft?.selection ?? live.selection;
  const setSelection = draft?.onChange ?? live.setSelection;
  // The loaded context describes the live selection only.
  const current = selection.branchId === live.selection.branchId;
  const [branchSearch, setBranchSearch] = useState('');
  const [registerSearch, setRegisterSearch] = useState('');
  const [branchPage, setBranchPage] = useState(1);
  const [registerPage, setRegisterPage] = useState(1);
  // Keyed on the session's store, not the context being reloaded, so the
  // lists stay on screen while a new branch loads.
  const branchQuery = useContextBranches(storeId, true, branchSearch, branchPage);
  const registerQuery = useContextRegisters(
    storeId,
    selection.branchId,
    true,
    registerSearch,
    registerPage,
  );
  const registersLoading = Boolean(
    selection.branchId && !registerSearch && (registerQuery.isPending || context.isPending),
  );
  const noRegisters = Boolean(
    !registerSearch && registerQuery.isSuccess && emptyOptions(registerQuery.data),
  );
  const branches = [...(branchQuery.data?.data ?? context.data?.branches ?? [])];
  const registers = [
    ...(registerQuery.data?.data ?? (current ? context.data?.registers : undefined) ?? []),
  ];
  const selectedBranch = context.data?.branches.find((branch) => branch.id === selection.branchId);
  const selectedRegister = current
    ? context.data?.registers.find((register) => register.id === selection.registerId)
    : undefined;
  if (selectedBranch && !branches.some((branch) => branch.id === selectedBranch.id))
    branches.push(selectedBranch);
  if (selectedRegister && !registers.some((register) => register.id === selectedRegister.id))
    registers.push(selectedRegister);

  const optionLabel = (row: { name: string; status: string }) =>
    `${row.name} · ${t(row.status === 'disabled' ? 'statusDisabled' : 'statusActive')}`;

  return (
    <div className="selector" data-registers={noRegisters ? 'none' : 'required'}>
      <div className="selector-group">
        <SearchableSelect
          label={t('branch')}
          placeholder={t('chooseBranch')}
          searchPlaceholder={t('searchBranch')}
          value={selection.branchId}
          options={branches.map((branch) => ({ value: branch.id, label: optionLabel(branch) }))}
          onSearch={setBranchSearch}
          page={branchPage}
          pages={branchQuery.data?.meta.pages ?? 1}
          onPage={setBranchPage}
          onChange={(branchId) => {
            setRegisterPage(1);
            setRegisterSearch('');
            setSelection({ branchId, registerId: null });
          }}
        />
      </div>
      {selection.branchId && !noRegisters ? (
        <div className="selector-group">
          <SearchableSelect
            label={t('register')}
            placeholder={t(registersLoading ? 'registersLoading' : 'chooseRegister')}
            searchPlaceholder={t('searchRegister')}
            value={selection.registerId}
            // A search in flight must not disable (and blur) the field being typed in.
            disabled={registersLoading || registerQuery.isError || !context.isSuccess}
            options={registers.map((register) => ({
              value: register.id,
              label: optionLabel(register),
            }))}
            onSearch={setRegisterSearch}
            page={registerPage}
            pages={registerQuery.data?.meta.pages ?? 1}
            onPage={setRegisterPage}
            onChange={(registerId) => setSelection({ branchId: selection.branchId, registerId })}
          />
        </div>
      ) : null}
      {branchQuery.isLoading || registersLoading ? (
        <p role="status" className="selector-loading">
          <span className="selector-spinner" aria-hidden />
          {t(branchQuery.isLoading ? 'branchesLoading' : 'registersLoading')}
        </p>
      ) : null}
      {branchQuery.isError || (selection.branchId && registerQuery.isError) ? (
        <div className="error" role="alert">
          <p>{t(posFailureKey(branchQuery.error ?? registerQuery.error))}</p>
          <button
            type="button"
            onClick={() => {
              void branchQuery.refetch();
              if (selection.branchId) void registerQuery.refetch();
            }}
          >
            {t('retry')}
          </button>
        </div>
      ) : null}
      {branchQuery.isSuccess && branches.length === 0 ? (
        <p role="status">
          {t('branchesEmpty')}
          {/* The store is not set up yet and this account may not do it. */}
          {context.data?.onboarding?.required && !context.data.onboarding.can_setup ? (
            <> {t('setup.askAdmin')}</>
          ) : null}
        </p>
      ) : null}
      {notice ? <p role="status">{t(notice)}</p> : null}
    </div>
  );
}

// The header picker: branch and register are picked as a draft, and the
// counter switches only on Save, so a stray pick never reloads the screen.
export function ContextPickerForm({ onClose }: { onClose: () => void }) {
  const { t } = useTranslation();
  const { selection, setSelection, storeId } = usePosSelection();
  const [draft, setDraft] = useState(selection);
  const registers = useContextRegisters(storeId, draft.branchId, true);
  const noRegisters = registers.isSuccess && emptyOptions(registers.data);
  const complete = Boolean(draft.branchId && (draft.registerId || noRegisters));
  const changed =
    draft.branchId !== selection.branchId || draft.registerId !== selection.registerId;
  return (
    <>
      <ContextSelector draft={{ selection: draft, onChange: setDraft }} />
      <div className="context-picker-actions">
        <button type="button" onClick={onClose}>
          {t('contextCancel')}
        </button>
        <button
          type="button"
          className="primary-button"
          disabled={!complete || !changed}
          onClick={() => {
            setSelection(draft);
            onClose();
          }}
        >
          {t('save')}
        </button>
      </div>
    </>
  );
}
