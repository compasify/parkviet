import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useContextBranches, useContextRegisters } from '../hooks/use-context-options';
import { posFailureKey } from '../lib/request-failure';
import { usePosSelection } from './pos-selection';
import { SearchableSelect } from './searchable-select';

export function ContextSelector({ onRegisterSelected }: { onRegisterSelected?: () => void }) {
  const { t } = useTranslation();
  const { selection, setSelection, context, notice, registerMode } = usePosSelection();
  const [branchSearch, setBranchSearch] = useState('');
  const [registerSearch, setRegisterSearch] = useState('');
  const [branchPage, setBranchPage] = useState(1);
  const [registerPage, setRegisterPage] = useState(1);
  const branchQuery = useContextBranches(
    context.data?.store.id ?? null,
    context.isSuccess,
    branchSearch,
    branchPage,
  );
  const registerQuery = useContextRegisters(
    context.data?.store.id ?? null,
    selection.branchId,
    context.isSuccess,
    registerSearch,
    registerPage,
  );
  const branches = [...(branchQuery.data?.data ?? context.data?.branches ?? [])];
  const registers = [...(registerQuery.data?.data ?? context.data?.registers ?? [])];
  const selectedBranch = context.data?.branches.find((branch) => branch.id === selection.branchId);
  const selectedRegister = context.data?.registers.find(
    (register) => register.id === selection.registerId,
  );
  if (selectedBranch && !branches.some((branch) => branch.id === selectedBranch.id))
    branches.push(selectedBranch);
  if (selectedRegister && !registers.some((register) => register.id === selectedRegister.id))
    registers.push(selectedRegister);

  const optionLabel = (row: { name: string; status: string }) =>
    `${row.name} · ${t(row.status === 'disabled' ? 'statusDisabled' : 'statusActive')}`;

  return (
    <div className="selector" data-registers={registerMode}>
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
      {selection.branchId && registerMode !== 'none' ? (
        <div className="selector-group">
          <SearchableSelect
            label={t('register')}
            placeholder={t('chooseRegister')}
            searchPlaceholder={t('searchRegister')}
            value={selection.registerId}
            // A search in flight must not disable (and blur) the field being typed in.
            disabled={
              !context.isSuccess ||
              registerQuery.isError ||
              (!registerQuery.isSuccess && !registerSearch)
            }
            options={registers.map((register) => ({
              value: register.id,
              label: optionLabel(register),
            }))}
            onSearch={setRegisterSearch}
            page={registerPage}
            pages={registerQuery.data?.meta.pages ?? 1}
            onPage={setRegisterPage}
            onChange={(registerId) => {
              setSelection({ branchId: selection.branchId, registerId });
              onRegisterSelected?.();
            }}
          />
        </div>
      ) : null}
      {branchQuery.isLoading || (selection.branchId && registerQuery.isLoading) ? (
        <p role="status">{t('contextWaiting')}</p>
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
