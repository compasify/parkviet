import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CollectionDialog } from '../components/collection-dialog';
import { DebtReminderActions } from '../components/debt-reminder-actions';
import { LocalFinancialRecords } from '../components/local-financial-records';
import { PosIcon } from '../components/pos-icon';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import {
  type ReceivableStatus,
  useCollections,
  usePendingCollections,
  useReceivableAccounts,
  useReceivables,
  useRecheckCollection,
} from '../hooks/use-receivables';
import { canRemindDebt, matchesDebtor, shortDate } from '../lib/debt-reminder';
import { formatMoney } from '../lib/money';
import type { PosCollection, PosReceivable, PosReceivableAccount } from '../lib/pos-context';
import { writesLocked } from '../lib/pos-context';
import { contextFeature } from '../lib/pos-features';
import {
  amountSign,
  canReadReceivables,
  describeCreditFailure,
  formatDueDate,
  formatInstant,
} from '../lib/receivables';
import { posFailureKey } from '../lib/request-failure';

const AGING = ['current', 'days_1_30', 'days_31_60', 'days_61_90', 'days_over_90'] as const;
const STATUSES: ReceivableStatus[] = ['open', 'overdue', 'all'];

function DebtRow({ debt }: { debt: PosReceivable }) {
  const { t } = useTranslation();
  const currency = debt.currency;
  return (
    <li className="receivable-row" data-overdue={debt.overdue}>
      <div className="record-copy">
        <strong>{debt.order_number}</strong>
        <small>
          {debt.customer.name}
          {debt.customer.phone ? ` · ${debt.customer.phone}` : ''}
        </small>
        <span className="status-tag" data-warning={debt.overdue}>
          {debt.overdue
            ? t('receivablesDaysOverdue', { count: debt.days_overdue })
            : `${t('receivablesDue')}: ${formatDueDate(debt.due_on)}`}
        </span>
      </div>
      <dl className="receivable-breakdown">
        <div>
          <dt>{t('receivablesOriginal')}</dt>
          <dd>{formatMoney(debt.original_total, currency)}</dd>
        </div>
        <div>
          <dt>{t('receivablesPaidAtSale')}</dt>
          <dd>{formatMoney(debt.paid_at_sale, currency)}</dd>
        </div>
        <div>
          <dt>{t('receivablesDebt')}</dt>
          <dd>{formatMoney(debt.debt, currency)}</dd>
        </div>
        {amountSign(debt.credit_notes) !== 0 ? (
          <div>
            <dt>{t('receivablesCreditNotes')}</dt>
            <dd>{formatMoney(debt.credit_notes, currency)}</dd>
          </div>
        ) : null}
        <div>
          <dt>{t('receivablesCollected')}</dt>
          <dd>{formatMoney(debt.collected, currency)}</dd>
        </div>
        {amountSign(debt.refunds) !== 0 ? (
          <div>
            <dt>{t('receivablesRefunds')}</dt>
            <dd>{formatMoney(debt.refunds, currency)}</dd>
          </div>
        ) : null}
        <div className="remaining-row">
          <dt>{t('receivablesBalance')}</dt>
          <dd>{formatMoney(debt.balance, currency)}</dd>
        </div>
      </dl>
    </li>
  );
}

function AccountRow({
  account,
  selected,
  onSelect,
}: {
  account: PosReceivableAccount;
  selected: boolean;
  onSelect: () => void;
}) {
  const { t, i18n } = useTranslation();
  const phone = account.customer.phone;
  // Only an unmasked phone is dialable.
  const dialable = phone && /^[+\d\s.-]+$/.test(phone) ? phone.replace(/[\s.-]/g, '') : null;
  return (
    <li className="debtor-row">
      <button className="fund-row" type="button" aria-pressed={selected} onClick={onSelect}>
        <span className="record-copy">
          <strong>{account.customer.name}</strong>
          <small>
            {phone && !dialable ? `${phone} · ` : ''}
            {t('receivablesOrderCount', { count: account.orders })}
            {account.oldest_placed_at
              ? ` · ${t('debtorsSince', { date: shortDate(account.oldest_placed_at), count: account.days_owed ?? 0 })}`
              : ''}
          </small>
          {account.customer.address ? <small>{account.customer.address}</small> : null}
          {amountSign(account.overdue) > 0 ? (
            <span className="status-tag" data-warning="true">
              {(account.days_overdue ?? 0) > 0
                ? t('receivablesDaysOverdue', { count: account.days_overdue })
                : t('receivablesOverdue')}
              : {formatMoney(account.overdue, account.currency)}
            </span>
          ) : null}
          <small className="muted">
            {account.last_reminded_at
              ? t('debtorsLastReminded', {
                  time: formatInstant(account.last_reminded_at, i18n.language),
                })
              : t('debtorsNeverReminded')}
          </small>
        </span>
        <span className="fund-row-money">
          <strong>{formatMoney(account.balance, account.currency)}</strong>
        </span>
      </button>
      {dialable ? (
        <a className="debtor-phone" href={`tel:${dialable}`}>
          <PosIcon name="user" />
          {phone}
        </a>
      ) : null}
    </li>
  );
}

export function ReceivablesPage() {
  const { context, selection } = usePosSelection();
  // A new staff, store or branch must not keep the previous scope's debts on screen.
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <ReceivablesLedger key={scope} />;
}

function ReceivablesLedger() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const staffId = data?.staff.id ?? null;
  const storeId = data?.store.id ?? null;
  const canRead = Boolean(branchId && canReadReceivables(data?.capabilities));
  const canCollect = Boolean(data?.capabilities.includes('pos.payment.collect'));
  // The server books a collection on any open shift the collector owns at the
  // branch (maybe at another register than the selected one) and refuses
  // with `shift_required` otherwise; this page only sees the selected
  // register's shift, so it hints instead of blocking.
  const ownShift = Boolean(
    data?.shift && data.shift.owner_id === staffId && data.shift.branch_id === branchId,
  );
  const [status, setStatus] = useState<ReceivableStatus>('open');
  const [accountId, setAccountId] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  // The dialog keeps its own copy: a fully paid customer drops off the list.
  const [collecting, setCollecting] = useState<PosReceivableAccount | null>(null);
  const [done, setDone] = useState<{ collection: PosCollection; recovered: boolean } | null>(null);
  const [collectError, setCollectError] = useState('');
  const [notice, setNotice] = useState('');
  const [search, setSearch] = useState('');
  // Reminders belong to credit sales: hidden while `credit` is off.
  const canRemind = Boolean(
    data && contextFeature(data, 'credit') && canRemindDebt(data.capabilities),
  );
  const accounts = useReceivableAccounts(branchId, canRead);
  const debtors = (accounts.data?.data ?? []).filter((row) => matchesDebtor(row, search));
  const selected = accounts.data?.data.find((row) => row.credit_account_id === accountId) ?? null;
  const debts = useReceivables(
    branchId,
    { status, customerId: selected?.customer.id ?? null, page },
    canRead,
  );
  const collections = useCollections(staffId, storeId);
  const recheck = useRecheckCollection(staffId, storeId);
  const pending = usePendingCollections(staffId, storeId);
  const rows = debts.data?.data ?? [];
  const dialogDebts = collecting
    ? rows.filter(
        (row) =>
          row.credit_account_id === collecting.credit_account_id && amountSign(row.balance) > 0,
      )
    : [];
  const totals = accounts.data?.meta.totals;
  const currency = data?.store.currency ?? 'VND';
  const selectedPending = Boolean(
    selected && pending.accounts.includes(selected.credit_account_id),
  );

  function select(id: string | null) {
    setAccountId(id);
    setPage(1);
    setNotice('');
    setCollectError('');
  }

  function reportDone(result: { collection: PosCollection; recovered: boolean }) {
    setNotice(
      t(result.recovered ? 'collectionRecovered' : 'collectionDone', {
        amount: formatMoney(result.collection.funds.received_net, result.collection.funds.currency),
      }),
    );
  }

  return (
    <PosPage title={t('receivablesTitle')} description={t('receivablesHint')}>
      {staffId && storeId ? <LocalFinancialRecords staffId={staffId} storeId={storeId} /> : null}
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !canRead ? (
        <PageState title={t('forbidden')} />
      ) : (
        <>
          <div className="page-toolbar">
            <label>
              {t('receivablesStatus')}
              <select
                value={status}
                onChange={(event) => {
                  setStatus(event.target.value as ReceivableStatus);
                  setPage(1);
                }}
              >
                {STATUSES.map((value) => (
                  <option key={value} value={value}>
                    {t(`receivablesStatus_${value}`)}
                  </option>
                ))}
              </select>
            </label>
            {totals ? (
              <span>
                {t('receivablesTotal')}: <strong>{formatMoney(totals.balance, currency)}</strong> ·{' '}
                {t('receivablesOverdue')}: <strong>{formatMoney(totals.overdue, currency)}</strong>
              </span>
            ) : null}
            <button
              type="button"
              disabled={accounts.isFetching || debts.isFetching}
              onClick={() => void Promise.all([accounts.refetch(), debts.refetch()])}
            >
              {t('refresh')}
            </button>
          </div>
          {totals ? (
            <dl className="receivable-aging" aria-label={t('receivablesAging')}>
              {AGING.map((bucket) => (
                <div key={bucket}>
                  <dt>{t(`aging_${bucket}`)}</dt>
                  <dd>{formatMoney(totals[bucket], currency)}</dd>
                </div>
              ))}
            </dl>
          ) : null}
          {notice ? (
            <p className="muted" role="status">
              {notice}
            </p>
          ) : null}
          {collectError && !collecting ? (
            <p className="error" role="alert">
              {collectError}
            </p>
          ) : null}
          <div className="funds-layout">
            <section className="page-card funds-list-panel" aria-label={t('receivablesCustomers')}>
              <h2>{t('receivablesCustomers')}</h2>
              <label className="debtor-search">
                <span className="visually-hidden">{t('debtorsSearch')}</span>
                <input
                  type="search"
                  value={search}
                  placeholder={t('debtorsSearch')}
                  onChange={(event) => setSearch(event.target.value)}
                />
              </label>
              {accounts.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
              {accounts.isError ? (
                <PageState kind="error" title={t(posFailureKey(accounts.error))} />
              ) : null}
              {accounts.isSuccess && accounts.data.data.length === 0 ? (
                <PageState kind="empty" title={t('receivablesEmpty')} />
              ) : null}
              {accounts.isSuccess && accounts.data.data.length > 0 && debtors.length === 0 ? (
                <PageState kind="empty" title={t('debtorsNoMatch')} />
              ) : null}
              <ul className="fund-list">
                <li>
                  <button
                    className="fund-row"
                    type="button"
                    aria-pressed={accountId === null}
                    onClick={() => select(null)}
                  >
                    <span className="record-copy">
                      <strong>{t('receivablesAllCustomers')}</strong>
                    </span>
                  </button>
                </li>
                {debtors.map((account) => (
                  <AccountRow
                    key={account.credit_account_id}
                    account={account}
                    selected={account.credit_account_id === accountId}
                    onSelect={() => select(account.credit_account_id)}
                  />
                ))}
              </ul>
            </section>
            <section className="page-card fund-detail" aria-label={t('receivablesOrders')}>
              <div className="fund-detail-heading">
                <h2>{selected ? selected.customer.name : t('receivablesOrders')}</h2>
                {selected && canCollect && !selectedPending ? (
                  <button
                    type="button"
                    className="checkout-submit"
                    disabled={
                      !data ||
                      writesLocked(data, selection) ||
                      pending.unavailable ||
                      !rows.some((row) => amountSign(row.balance) > 0)
                    }
                    aria-describedby={ownShift ? undefined : 'collection-needs-shift'}
                    onClick={() => {
                      setCollectError('');
                      setNotice('');
                      setDone(null);
                      setCollecting(selected);
                    }}
                  >
                    <PosIcon name="cash" />
                    {t('collectionAction')}
                  </button>
                ) : null}
                {selected && canCollect && !selectedPending && !ownShift ? (
                  <small className="muted" id="collection-needs-shift">
                    {t('collectionShiftHint')}
                  </small>
                ) : null}
                {selected && canRemind && branchId ? (
                  <DebtReminderActions
                    key={selected.credit_account_id}
                    account={selected}
                    branchId={branchId}
                    storeName={data?.store.name}
                  />
                ) : null}
              </div>
              {selected && selectedPending ? (
                <div className="payment-held" role="status">
                  <p>{t('collectionChecking')}</p>
                  <button
                    type="button"
                    disabled={recheck.isPending}
                    onClick={() => {
                      setCollectError('');
                      recheck.mutate(selected.credit_account_id, {
                        onSuccess: (result) => {
                          if (result) reportDone(result);
                          pending.refresh();
                        },
                        onError: (failure) => {
                          setCollectError(describeCreditFailure(failure, t));
                          pending.refresh();
                        },
                      });
                    }}
                  >
                    {recheck.isPending ? t('waiting') : t('collectionRecheck')}
                  </button>
                </div>
              ) : null}
              {debts.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
              {debts.isError ? (
                <PageState kind="error" title={t(posFailureKey(debts.error))}>
                  <button type="button" onClick={() => void debts.refetch()}>
                    {t('retry')}
                  </button>
                </PageState>
              ) : null}
              {debts.isSuccess && rows.length === 0 ? (
                <PageState kind="empty" title={t('receivablesEmpty')} />
              ) : null}
              <ul className="record-list receivable-list" aria-label={t('receivablesOrders')}>
                {rows.map((debt) => (
                  <DebtRow key={debt.order_id} debt={debt} />
                ))}
              </ul>
              {debts.data && debts.data.meta.pages > 1 ? (
                <div className="page-pagination">
                  <button
                    type="button"
                    disabled={page <= 1 || debts.isFetching}
                    onClick={() => setPage((value) => value - 1)}
                  >
                    {t('previousPage')}
                  </button>
                  <span>
                    {page} / {debts.data.meta.pages}
                  </span>
                  <button
                    type="button"
                    disabled={page >= debts.data.meta.pages || debts.isFetching}
                    onClick={() => setPage((value) => value + 1)}
                  >
                    {t('nextPage')}
                  </button>
                </div>
              ) : null}
            </section>
          </div>
          {collecting && branchId ? (
            <CollectionDialog
              account={collecting}
              debts={dialogDebts}
              branchId={branchId}
              busy={collections.isPending}
              error={collectError}
              done={done}
              onClose={() => {
                setCollecting(null);
                pending.refresh();
              }}
              onSubmit={async (input) => {
                setCollectError('');
                try {
                  const result = await collections.mutateAsync(input);
                  setDone(result);
                  reportDone(result);
                } catch (failure) {
                  setCollectError(describeCreditFailure(failure, t));
                } finally {
                  pending.refresh();
                }
              }}
            />
          ) : null}
        </>
      )}
    </PosPage>
  );
}
