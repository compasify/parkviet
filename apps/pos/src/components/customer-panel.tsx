import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useCreateCustomer,
  useCustomerSearch,
  useUpdateCustomer,
} from '../hooks/use-pos-customers';
import type { PosWorkspace } from '../lib/pos-context';
import { describeFailure, posFailureKey } from '../lib/request-failure';
import { customerSubmissionContent } from '../lib/submission-key';
import { PosIcon } from './pos-icon';

// Where to deliver, written the way the seller says it.
function AddressField({ value, onChange }: { value: string; onChange: (value: string) => void }) {
  const { t } = useTranslation();
  return (
    <label>
      {t('customerAddress')}
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        maxLength={255}
        placeholder={t('customerAddressHint')}
      />
    </label>
  );
}

export function CustomerPanel({
  workspace,
  branchId,
  storeId,
  canCreate,
  disabled,
  disabledReason,
  onAssign,
  onClear,
}: {
  workspace: PosWorkspace;
  branchId: string | null;
  storeId: string | null;
  canCreate: boolean;
  disabled: boolean;
  disabledReason?: string;
  onAssign: (profileId: string) => Promise<PosWorkspace>;
  onClear: () => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const [input, setInput] = useState('');
  const [query, setQuery] = useState('');
  const [resultsOpen, setResultsOpen] = useState(false);
  const [createOpen, setCreateOpen] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [editOpen, setEditOpen] = useState(false);
  const [editName, setEditName] = useState('');
  const [editPhone, setEditPhone] = useState('');
  const [editAddress, setEditAddress] = useState('');
  const [error, setError] = useState('');
  const [warning, setWarning] = useState('');
  const panelRef = useRef<HTMLDivElement>(null);
  // A profile created by a submission whose assignment then failed. Resubmitting
  // the same form assigns this profile instead of creating another one.
  const created = useRef<{ content: string; profileId: string } | null>(null);
  const search = useCustomerSearch(storeId, branchId, query);
  const create = useCreateCustomer(storeId);
  const update = useUpdateCustomer(storeId);
  const customer = workspace.customer;

  useEffect(() => {
    const trimmed = input.trim();
    if (!trimmed) {
      setQuery('');
      setResultsOpen(false);
      return;
    }
    const timer = window.setTimeout(() => {
      setQuery(trimmed);
      setResultsOpen(true);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [input]);

  useEffect(() => {
    const dismiss = (event: Event) => {
      if (event.target instanceof Node && !panelRef.current?.contains(event.target)) {
        setResultsOpen(false);
      }
    };
    const onEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setResultsOpen(false);
        setCreateOpen(false);
        setEditOpen(false);
      }
    };
    document.addEventListener('pointerdown', dismiss);
    document.addEventListener('keydown', onEscape);
    return () => {
      document.removeEventListener('pointerdown', dismiss);
      document.removeEventListener('keydown', onEscape);
    };
  }, []);

  async function assign(action: () => Promise<PosWorkspace>) {
    if (disabled) return;
    setError('');
    setWarning('');
    try {
      await action();
    } catch (failure) {
      setError(describeFailure(failure, t));
    }
  }

  async function createCustomer(event: React.FormEvent) {
    event.preventDefault();
    if (!branchId || disabled || create.isPending) return;
    const input = {
      branchId,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
    };
    const content = customerSubmissionContent(input);
    setError('');
    setWarning('');
    try {
      let profileId = created.current?.content === content ? created.current.profileId : null;
      if (!profileId) {
        const profile = await create.mutateAsync(input);
        profileId = profile.id;
        created.current = { content, profileId };
        if ((profile.duplicates?.length ?? 0) > 1) setWarning(t('customerDuplicateWarning'));
      }
      await onAssign(profileId);
      created.current = null;
      setName('');
      setPhone('');
      setEmail('');
      setAddress('');
      setCreateOpen(false);
    } catch (failure) {
      setError(describeFailure(failure, t));
    }
  }

  function openEdit() {
    if (!customer?.id) return;
    setError('');
    setEditName(customer.name ?? '');
    setEditPhone(customer.phone ?? '');
    setEditAddress(customer.address ?? '');
    setEditOpen(true);
  }

  // Saves the profile, then assigns it again so the order (and every print
  // of it) carries the corrected address.
  async function saveEdit(event: React.FormEvent) {
    event.preventDefault();
    const profileId = customer?.id;
    if (!branchId || !profileId || disabled || update.isPending) return;
    setError('');
    setWarning('');
    try {
      const profile = await update.mutateAsync({
        branchId,
        profileId,
        name: editName.trim(),
        phone: editPhone.trim(),
        address: editAddress.trim(),
      });
      if ((profile.duplicates?.length ?? 0) > 1) setWarning(t('customerDuplicateWarning'));
      await onAssign(profileId);
      setEditOpen(false);
    } catch (failure) {
      setError(describeFailure(failure, t));
    }
  }

  return (
    <div className="customer-panel" ref={panelRef}>
      <div className="customer-header">
        <h3>{t('customerTitle')}</h3>
        <form
          className="customer-search-row"
          onSubmit={(event) => {
            event.preventDefault();
            const trimmed = input.trim();
            if (!trimmed) return;
            setQuery(trimmed);
            setResultsOpen(true);
          }}
        >
          <input
            type="search"
            value={input}
            disabled={!branchId}
            aria-label={t('customerSearch')}
            placeholder={t('customerSearch')}
            onFocus={() => {
              if (query.trim()) setResultsOpen(true);
            }}
            onChange={(event) => setInput(event.target.value)}
          />
          <button
            type="submit"
            className="customer-icon-button"
            aria-label={t('customerFind')}
            title={t('customerFind')}
            disabled={!branchId || !input.trim()}
          >
            <PosIcon name="search" />
          </button>
          {canCreate ? (
            <button
              type="button"
              className="customer-icon-button"
              aria-label={t('customerCreate')}
              title={disabledReason ?? t('customerCreate')}
              disabled={disabled || !branchId}
              onClick={() => {
                setError('');
                setCreateOpen(true);
              }}
            >
              <PosIcon name="plus" />
            </button>
          ) : null}
        </form>
      </div>
      {resultsOpen && query ? (
        <div className="customer-results-popover">
          {search.isLoading ? <p role="status">{t('waiting')}</p> : null}
          {search.isSuccess && search.data.data.length === 0 ? (
            <p className="muted">{t('customerEmpty')}</p>
          ) : null}
          {search.isError ? (
            <p className="error" role="alert">
              {t(posFailureKey(search.error))}
            </p>
          ) : null}
          {search.data && search.data.meta.duplicate_candidates > 1 ? (
            <p className="warning" role="status">
              {t('customerDuplicateWarning')}
            </p>
          ) : null}
          {search.data?.data.length ? (
            <ul className="customer-results-list" aria-label={t('customerResults')}>
              {customer ? (
                <li>
                  <div className="customer-result-info">
                    <strong>{t('customerWalkIn')}</strong>
                  </div>
                  <button
                    type="button"
                    disabled={disabled}
                    title={disabledReason}
                    onClick={() =>
                      void assign(async () => {
                        const updated = await onClear();
                        setResultsOpen(false);
                        setInput('');
                        setQuery('');
                        return updated;
                      })
                    }
                  >
                    {t('customerAssign')}
                  </button>
                </li>
              ) : null}
              {search.data.data.map((profile) => (
                <li key={profile.id}>
                  <div className="customer-result-info">
                    <strong>{profile.name}</strong>
                    {profile.phone || profile.email ? (
                      <small>{profile.phone ?? profile.email}</small>
                    ) : null}
                    {profile.address ? (
                      <small className="customer-address-text">{profile.address}</small>
                    ) : null}
                  </div>
                  <button
                    type="button"
                    disabled={disabled}
                    title={disabledReason}
                    onClick={() =>
                      void assign(async () => {
                        const updated = await onAssign(profile.id);
                        setResultsOpen(false);
                        setInput('');
                        setQuery('');
                        return updated;
                      })
                    }
                  >
                    {t('customerAssign')}
                  </button>
                </li>
              ))}
            </ul>
          ) : null}
        </div>
      ) : null}
      <div className="customer-selected">
        <PosIcon name="user" />
        <div className="customer-selected-info">
          <strong>{customer?.name ?? t('customerWalkIn')}</strong>
          {customer?.phone || customer?.email ? (
            <small>{customer.phone ?? customer.email}</small>
          ) : null}
          {customer?.address ? (
            <small className="customer-address-text">
              <PosIcon name="location" /> {customer.address}
            </small>
          ) : null}
        </div>
        {customer?.id && canCreate ? (
          <button
            type="button"
            className="cell-edit-button"
            aria-label={t('customerEditAddress')}
            title={disabledReason ?? t('customerEditAddress')}
            disabled={disabled || !branchId}
            onClick={openEdit}
          >
            <PosIcon name="edit" />
          </button>
        ) : null}
        {customer ? (
          <button
            type="button"
            className="cell-edit-button cell-clear-button"
            aria-label={t('customerClear')}
            title={disabledReason ?? t('customerClear')}
            disabled={disabled}
            onClick={() => void assign(onClear)}
          >
            <PosIcon name="close" />
          </button>
        ) : null}
      </div>
      {createOpen ? (
        <div className="pos-popup-backdrop">
          <form className="customer-create-form pos-popup-card" onSubmit={createCustomer}>
            <div className="pos-popup-header">
              <strong>{t('customerCreate')}</strong>
            </div>
            <label>
              {t('customerName')}
              <input
                value={name}
                onChange={(event) => setName(event.target.value)}
                required
                maxLength={120}
              />
            </label>
            <label>
              {t('customerPhone')}
              <input
                value={phone}
                onChange={(event) => setPhone(event.target.value)}
                maxLength={32}
              />
            </label>
            <label>
              {t('customerEmail')}
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                maxLength={254}
              />
            </label>
            <AddressField value={address} onChange={setAddress} />
            <div className="row">
              <button
                type="submit"
                className="primary-button"
                disabled={
                  disabled || create.isPending || !name.trim() || (!phone.trim() && !email.trim())
                }
                title={disabledReason}
              >
                {t('customerCreateAndAssign')}
              </button>
              <button type="button" onClick={() => setCreateOpen(false)}>
                {t('adminClose')}
              </button>
            </div>
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </form>
        </div>
      ) : null}
      {editOpen ? (
        <div className="pos-popup-backdrop">
          <form className="customer-create-form pos-popup-card" onSubmit={saveEdit}>
            <div className="pos-popup-header">
              <strong>{t('customerEditAddress')}</strong>
            </div>
            <label>
              {t('customerName')}
              <input
                value={editName}
                onChange={(event) => setEditName(event.target.value)}
                required
                maxLength={120}
              />
            </label>
            <label>
              {t('customerPhone')}
              <input
                value={editPhone}
                onChange={(event) => setEditPhone(event.target.value)}
                maxLength={32}
              />
            </label>
            <AddressField value={editAddress} onChange={setEditAddress} />
            <div className="row">
              <button
                type="submit"
                className="primary-button"
                disabled={
                  disabled ||
                  update.isPending ||
                  !editName.trim() ||
                  (!editPhone.trim() && !customer?.email)
                }
                title={disabledReason}
              >
                {t('customerSaveAddress')}
              </button>
              <button type="button" onClick={() => setEditOpen(false)}>
                {t('adminClose')}
              </button>
            </div>
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </form>
        </div>
      ) : null}
      {warning ? (
        <p className="warning" role="status">
          {warning}
        </p>
      ) : null}
      {error && !createOpen && !editOpen ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  );
}
