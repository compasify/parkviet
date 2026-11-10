import { formatMoney, parseVndAmount, parseVndInput } from '@parkviet/pos-shared/money';
import { useId, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { useCustomerSearch } from '../hooks/use-pos-customers';
import {
  type CreditTermsInput,
  useConfigureCredit,
  useCreditAccounts,
} from '../hooks/use-receivables';
import type { PosCreditAccount, PosCustomerProfile } from '../lib/pos-context';
import { writesLocked } from '../lib/pos-context';
import { describeCreditFailure } from '../lib/receivables';
import { posFailureKey } from '../lib/request-failure';

const MAX_DUE_DAYS = 3650;

function parseDueDays(value: string): number | null {
  if (!/^\d{1,4}$/.test(value.trim())) return null;
  const days = Number(value.trim());
  return days <= MAX_DUE_DAYS ? days : null;
}

// Limit and due days, shared by the create and edit forms.
function TermsFields({
  limit,
  days,
  disabled,
  onLimit,
  onDays,
}: {
  limit: string;
  days: string;
  disabled: boolean;
  onLimit: (value: string) => void;
  onDays: (value: string) => void;
}) {
  const { t } = useTranslation();
  const hintId = useId();
  const limitInvalid = limit.trim() !== '' && parseVndInput(limit) === null;
  const daysInvalid = days.trim() !== '' && parseDueDays(days) === null;
  return (
    <>
      <label>
        {t('creditLimit')}
        <input
          className="money-input"
          inputMode="numeric"
          autoComplete="off"
          value={limit}
          aria-invalid={limitInvalid}
          disabled={disabled}
          required
          onChange={(event) => onLimit(event.target.value)}
        />
      </label>
      <label>
        {t('creditDueDays')}
        <input
          inputMode="numeric"
          autoComplete="off"
          value={days}
          aria-invalid={daysInvalid}
          aria-describedby={hintId}
          disabled={disabled}
          required
          onChange={(event) => onDays(event.target.value)}
        />
        <small className="muted" id={hintId}>
          {t('creditDueDaysHint')}
        </small>
      </label>
    </>
  );
}

function AccountRow({
  account,
  disabled,
  onSave,
}: {
  account: PosCreditAccount;
  disabled: boolean;
  onSave: (input: Omit<CreditTermsInput, 'branchId'>) => Promise<boolean>;
}) {
  const { t } = useTranslation();
  const [editing, setEditing] = useState(false);
  const [limit, setLimit] = useState(parseVndAmount(account.credit_limit) ?? '');
  const [days, setDays] = useState(String(account.due_days));
  const parsedLimit = parseVndInput(limit);
  const parsedDays = parseDueDays(days);
  const suspended = account.status === 'suspended';
  return (
    <li className="credit-account-row">
      <div className="record-copy">
        <strong>{account.customer_name}</strong>
        <small>{account.customer_phone ?? ''}</small>
        <span className="status-tag" data-warning={suspended}>
          {t(`creditAccountStatus_${account.status}`)}
        </span>
      </div>
      <dl className="receivable-breakdown">
        <div>
          <dt>{t('creditLimit')}</dt>
          <dd>{formatMoney(account.credit_limit, account.currency)}</dd>
        </div>
        <div>
          <dt>{t('creditDueDays')}</dt>
          <dd>{account.due_days}</dd>
        </div>
        <div>
          <dt>{t('creditOpenDebt')}</dt>
          <dd>{formatMoney(account.open_debt, account.currency)}</dd>
        </div>
        <div>
          <dt>{t('creditReserved')}</dt>
          <dd>{formatMoney(account.reserved, account.currency)}</dd>
        </div>
        <div>
          <dt>{t('creditAvailable')}</dt>
          <dd>{formatMoney(account.available, account.currency)}</dd>
        </div>
      </dl>
      {editing ? (
        <form
          className="credit-terms-form"
          aria-label={t('creditEditTerms', { name: account.customer_name })}
          onSubmit={(event) => {
            event.preventDefault();
            if (parsedLimit === null || parsedDays === null) return;
            void onSave({
              accountId: account.id,
              creditLimit: parsedLimit,
              dueDays: parsedDays,
            }).then((done) => {
              if (done) setEditing(false);
            });
          }}
        >
          <TermsFields
            limit={limit}
            days={days}
            disabled={disabled}
            onLimit={setLimit}
            onDays={setDays}
          />
          <button type="submit" disabled={disabled || parsedLimit === null || parsedDays === null}>
            {t('creditSaveTerms')}
          </button>
          <button type="button" disabled={disabled} onClick={() => setEditing(false)}>
            {t('paymentCancelNo')}
          </button>
        </form>
      ) : (
        <div className="row">
          <button type="button" disabled={disabled} onClick={() => setEditing(true)}>
            {t('creditEdit')}
          </button>
          <button
            type="button"
            disabled={disabled}
            onClick={() =>
              void onSave({ accountId: account.id, status: suspended ? 'active' : 'suspended' })
            }
          >
            {t(suspended ? 'creditActivate' : 'creditSuspend')}
          </button>
        </div>
      )}
    </li>
  );
}

export function CreditAccountsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <CreditAccountsAdmin key={scope} />;
}

function CreditAccountsAdmin() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const canManage = Boolean(data?.capabilities.includes('pos.credit.manage'));
  const accounts = useCreditAccounts(branchId, canManage);
  const configure = useConfigureCredit();
  const [query, setQuery] = useState('');
  const [customer, setCustomer] = useState<PosCustomerProfile | null>(null);
  const [limit, setLimit] = useState('');
  const [days, setDays] = useState('30');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const search = useCustomerSearch(data?.store.id ?? null, branchId, customer ? '' : query);
  const locked = !data || writesLocked(data, selection) || configure.isPending;
  const parsedLimit = parseVndInput(limit);
  const parsedDays = parseDueDays(days);

  async function save(input: Omit<CreditTermsInput, 'branchId'>): Promise<boolean> {
    if (!branchId) return false;
    setError('');
    setNotice('');
    try {
      const account = await configure.mutateAsync({ ...input, branchId });
      setNotice(t('creditSaved', { name: account.customer_name }));
      return true;
    } catch (failure) {
      setError(describeCreditFailure(failure, t));
      return false;
    }
  }

  return (
    <PosPage title={t('creditAccountsTitle')} description={t('creditAccountsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !canManage ? (
        <PageState title={t('forbidden')} />
      ) : (
        <>
          <section className="page-card" aria-label={t('creditAccountCreate')}>
            <h2>{t('creditAccountCreate')}</h2>
            <form
              className="credit-terms-form"
              onSubmit={(event) => {
                event.preventDefault();
                if (!customer || parsedLimit === null || parsedDays === null) return;
                void save({
                  customerId: customer.id,
                  creditLimit: parsedLimit,
                  dueDays: parsedDays,
                }).then((done) => {
                  if (!done) return;
                  setCustomer(null);
                  setQuery('');
                  setLimit('');
                });
              }}
            >
              {customer ? (
                <p>
                  {t('creditCustomer')}: <strong>{customer.name}</strong> {customer.phone ?? ''}{' '}
                  <button type="button" disabled={locked} onClick={() => setCustomer(null)}>
                    {t('creditChangeCustomer')}
                  </button>
                </p>
              ) : (
                <>
                  <label>
                    {t('creditCustomerSearch')}
                    <input
                      type="search"
                      value={query}
                      autoComplete="off"
                      disabled={locked}
                      onChange={(event) => setQuery(event.target.value)}
                    />
                  </label>
                  {search.isError ? (
                    <p className="error">{t(posFailureKey(search.error))}</p>
                  ) : null}
                  <ul className="record-list" aria-label={t('creditCustomerResults')}>
                    {(search.data?.data ?? []).map((profile) => (
                      <li key={profile.id}>
                        <button
                          type="button"
                          disabled={locked}
                          onClick={() => setCustomer(profile)}
                        >
                          {profile.name} {profile.phone ?? ''}
                        </button>
                      </li>
                    ))}
                  </ul>
                </>
              )}
              <TermsFields
                limit={limit}
                days={days}
                disabled={locked}
                onLimit={setLimit}
                onDays={setDays}
              />
              <button
                type="submit"
                className="checkout-submit"
                disabled={locked || !customer || parsedLimit === null || parsedDays === null}
              >
                {t('creditAccountCreate')}
              </button>
            </form>
          </section>
          {notice ? (
            <p className="muted" role="status">
              {notice}
            </p>
          ) : null}
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <section className="page-card" aria-label={t('creditAccountsList')}>
            <h2>{t('creditAccountsList')}</h2>
            {accounts.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
            {accounts.isError ? (
              <PageState kind="error" title={t(posFailureKey(accounts.error))} />
            ) : null}
            {accounts.isSuccess && accounts.data.data.length === 0 ? (
              <PageState kind="empty" title={t('creditAccountsEmpty')} />
            ) : null}
            <ul className="record-list" aria-label={t('creditAccountsList')}>
              {(accounts.data?.data ?? []).map((account) => (
                <AccountRow key={account.id} account={account} disabled={locked} onSave={save} />
              ))}
            </ul>
          </section>
        </>
      )}
    </PosPage>
  );
}
