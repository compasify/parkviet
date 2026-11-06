import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useContextBranches, useContextRegisters } from '../hooks/use-context-options';
import { posFailureKey } from '../lib/request-failure';
import { usePosSelection } from './pos-selection';

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

  return (
    <div className="selector" data-registers={registerMode}>
      <div className="selector-group">
        {(branchQuery.data?.meta.count ?? branches.length) > 5 || branchSearch ? (
          <label>
            {t('searchBranch')}
            <input
              value={branchSearch}
              onChange={(event) => {
                setBranchSearch(event.target.value);
                setBranchPage(1);
              }}
            />
          </label>
        ) : null}
        <label>
          {t('branch')}
          <select
            value={selection.branchId ?? ''}
            onChange={(event) => {
              setRegisterPage(1);
              setRegisterSearch('');
              setSelection({ branchId: event.target.value || null, registerId: null });
            }}
          >
            <option value="">{t('chooseBranch')}</option>
            {branches.map((branch) => (
              <option key={branch.id} value={branch.id}>
                {branch.name} ·{' '}
                {t(branch.status === 'disabled' ? 'statusDisabled' : 'statusActive')}
              </option>
            ))}
          </select>
        </label>
        {(branchQuery.data?.meta.pages ?? 1) > 1 ? (
          <div className="row">
            <button
              type="button"
              disabled={branchPage <= 1}
              onClick={() => setBranchPage(branchPage - 1)}
            >
              {t('previousPage')}
            </button>
            <span>
              {branchPage} / {branchQuery.data?.meta.pages}
            </span>
            <button
              type="button"
              disabled={branchPage >= (branchQuery.data?.meta.pages ?? 1)}
              onClick={() => setBranchPage(branchPage + 1)}
            >
              {t('nextPage')}
            </button>
          </div>
        ) : null}
      </div>
      {selection.branchId && registerMode !== 'none' ? (
        <div className="selector-group">
          {(registerQuery.data?.meta.count ?? registers.length) > 5 || registerSearch ? (
            <label>
              {t('searchRegister')}
              <input
                value={registerSearch}
                onChange={(event) => {
                  setRegisterSearch(event.target.value);
                  setRegisterPage(1);
                }}
              />
            </label>
          ) : null}
          <label>
            {t('register')}
            <select
              value={selection.registerId ?? ''}
              disabled={!registerQuery.isSuccess}
              onChange={(event) => {
                setSelection({
                  branchId: selection.branchId,
                  registerId: event.target.value || null,
                });
                if (event.target.value) onRegisterSelected?.();
              }}
            >
              <option value="">{t('chooseRegister')}</option>
              {registers.map((register) => (
                <option key={register.id} value={register.id}>
                  {register.name} ·{' '}
                  {t(register.status === 'disabled' ? 'statusDisabled' : 'statusActive')}
                </option>
              ))}
            </select>
          </label>
          {(registerQuery.data?.meta.pages ?? 1) > 1 ? (
            <div className="row">
              <button
                type="button"
                disabled={registerPage <= 1}
                onClick={() => setRegisterPage(registerPage - 1)}
              >
                {t('previousPage')}
              </button>
              <span>
                {registerPage} / {registerQuery.data?.meta.pages}
              </span>
              <button
                type="button"
                disabled={registerPage >= (registerQuery.data?.meta.pages ?? 1)}
                onClick={() => setRegisterPage(registerPage + 1)}
              >
                {t('nextPage')}
              </button>
            </div>
          ) : null}
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
        <p role="status">{t('branchesEmpty')}</p>
      ) : null}
      {notice ? <p role="status">{t(notice)}</p> : null}
    </div>
  );
}
