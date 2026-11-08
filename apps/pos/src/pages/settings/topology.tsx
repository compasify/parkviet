import { Link } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../../components/pos-icon';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import {
  type TopologyDraft,
  TopologyEditor,
  type TopologyKind,
} from '../../components/topology-editor';
import { useBranchModules } from '../../hooks/use-branch-modules';
import { useBusinessProfiles } from '../../hooks/use-business-profiles';
import { useStoreProfile } from '../../hooks/use-onboarding';
import {
  useBranches,
  useLocationOptions,
  useMemberships,
  useRegisters,
  useStaffOptions,
} from '../../hooks/use-topology';
import { session } from '../../lib/app-session';
import { administrationAccess } from '../../lib/pos-administration';
import { posCapabilities } from '../../lib/pos-capabilities';
import type { PosBranch } from '../../lib/pos-context';
import { queryClient } from '../../lib/query-client';
import { posFailureKey } from '../../lib/request-failure';
import { branchSettingVisible } from '../../modules/registry';

// Scale label formats are a `retail.measured` page: a branch without the
// module does not offer the link (the page itself still opens by URL).
function LabelFormatsLink({ branch }: { branch: PosBranch }) {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const modules = useBranchModules(branch.id);
  if (!branchSettingVisible({ ...context.data, modules }, 'label-formats')) return null;
  return (
    <Link
      className="button-link"
      to="/settings/branches/$branchId/label-formats"
      params={{ branchId: branch.id }}
      aria-label={t('labelFormatsFor', { name: branch.name })}
    >
      <PosIcon name="list" />
      {t('labelFormatsTitle')}
    </Link>
  );
}

export function TopologyPage() {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const access = administrationAccess(context.data);
  const branches = useBranches(access.read);
  const registers = useRegisters(access.read);
  const memberships = useMemberships(access.read);
  const staff = useStaffOptions(access.read);
  const locations = useLocationOptions(access.read);
  // A new branch picks its industry; it starts on the store's main profile.
  // Neither read gates the page: without them the form has no profile field
  // and the server gives the branch the store's profile.
  const storeId = context.data?.store.id ?? null;
  const catalogue = useBusinessProfiles(storeId, access.write);
  const storeProfile = useStoreProfile(storeId, access.write);
  const branchProfiles = (catalogue.data?.profiles ?? []).filter(
    (profile) => profile.status === 'available',
  );
  const [kind, setKind] = useState<TopologyKind>('branches');
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('all');
  const [branchFilter, setBranchFilter] = useState('');
  const [editor, setEditor] = useState<{ kind: TopologyKind; record: TopologyDraft } | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [failed, setFailed] = useState(false);
  const branchRows = branches.data?.data ?? [];
  const membershipRows = memberships.data?.data ?? [];
  // Lot picking is a `retail.traceability` setting: an existing branch without
  // the module does not offer it (its stored value is sent back unchanged).
  // A new branch gets its modules from its profile, so the field stays.
  const editedBranchModules = useBranchModules(
    editor?.kind === 'branches' ? (editor.record.id ?? null) : null,
  );
  const hideLotSelection =
    editor?.kind === 'branches' &&
    Boolean(editor.record.id) &&
    !branchSettingVisible({ ...context.data, modules: editedBranchModules }, 'lot-selection');
  const currentQuery =
    kind === 'branches' ? branches : kind === 'registers' ? registers : memberships;
  const dependencies = [branches, registers, memberships, staff, locations];
  const dependentError = dependencies.find((query) => query.isError);
  const ready = dependencies.every((query) => query.isSuccess);
  const branchName = (id?: string) =>
    branchRows.find((branch) => branch.id === id)?.name ?? t('adminUnavailable');
  const staffName = (id: string) => {
    const user =
      staff.data?.data.find((item) => item.id === id) ??
      membershipRows.find((item) => item.staff_id === id)?.staff;
    return user
      ? `${user.full_name ? `${user.full_name} · ` : ''}${user.email}`
      : t('adminUnavailable');
  };
  const canRecover = (branchId: string) =>
    membershipRows.some(
      (membership) =>
        membership.branch_id === branchId &&
        membership.staff_id === context.data?.staff.id &&
        membership.capabilities.includes('pos.topology.recover'),
    );

  async function refresh() {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ['pos', 'topology'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'context'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'context-branches'] }),
      queryClient.invalidateQueries({ queryKey: ['pos', 'context-registers'] }),
    ]);
  }
  async function save(body: Record<string, unknown>) {
    if (!editor || !access.write) throw Object.assign(new Error('Access denied'), { status: 403 });
    await session.request(
      editor.record.id ? 'PATCH' : 'POST',
      `/pos/${editor.kind}${editor.record.id ? `/${editor.record.id}` : ''}`,
      { body },
    );
    setFailed(false);
    setMessage(t('saved'));
    await refresh();
  }
  async function changeStatus(id: string, name: string, previous: string) {
    if (
      busy ||
      !access.write ||
      !window.confirm(
        t(previous === 'active' ? 'adminConfirmDisable' : 'adminConfirmEnable', { name }),
      )
    )
      return;
    setBusy(true);
    setMessage('');
    try {
      await session.request(
        'POST',
        `/pos/${kind}/${id}/${previous === 'active' ? 'disable' : 'enable'}`,
        { body: {} },
      );
      setFailed(false);
      setMessage(t('saved'));
      await refresh();
    } catch (error) {
      setFailed(true);
      setMessage(t(posFailureKey(error)));
    } finally {
      setBusy(false);
    }
  }
  function visible(item: { status: string; branch_id?: string }, name: string) {
    return (
      (status === 'all' || status === item.status) &&
      (!branchFilter || kind === 'branches' || item.branch_id === branchFilter) &&
      name.toLocaleLowerCase().includes(search.trim().toLocaleLowerCase())
    );
  }
  function actions(
    record: TopologyDraft & { id: string; status: string },
    name: string,
    branchId: string,
  ) {
    return (
      <div className="admin-record-actions">
        <button
          type="button"
          disabled={busy || !access.write || !ready}
          onClick={() => {
            setMessage('');
            setEditor({ kind, record });
          }}
          aria-label={t('adminEditName', { name })}
        >
          {t('adminEdit')}
        </button>
        {record.status === 'active' || canRecover(branchId) ? (
          <button
            type="button"
            disabled={busy || !access.write}
            className={record.status === 'active' ? 'danger-button' : ''}
            onClick={() => void changeStatus(record.id, name, record.status)}
          >
            {t(record.status === 'active' ? 'adminDisable' : 'adminEnable')}
          </button>
        ) : (
          <small>{t('adminRecoveryRequired')}</small>
        )}
      </div>
    );
  }
  const filteredBranches = branchRows.filter((item) => visible(item, `${item.name} ${item.code}`));
  const filteredRegisters = (registers.data?.data ?? []).filter((item) =>
    visible(item, `${item.name} ${item.code} ${branchName(item.branch_id)}`),
  );
  const filteredMemberships = membershipRows.filter((item) =>
    visible(item, `${staffName(item.staff_id)} ${branchName(item.branch_id)}`),
  );
  const count =
    kind === 'branches'
      ? filteredBranches.length
      : kind === 'registers'
        ? filteredRegisters.length
        : filteredMemberships.length;

  return (
    <PosPage title={t('settings')} description={t('adminIntro')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !access.read ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <div className="pos-administration">
          <div className="admin-overview">
            <div>
              <span className="admin-eyebrow">{t('adminWorkspace')}</span>
              <h2>{context.data?.store.name}</h2>
              <p>{t('adminScopeNote')}</p>
            </div>
            <span className="status-tag">
              {t(access.write ? 'adminWriteAccess' : 'adminReadAccess')}
            </span>
          </div>
          <nav className="admin-branch-nav" aria-label={t('receiptTemplates.settingsHint')}>
            <Link className="button-link" to="/settings/receipt-templates">
              <PosIcon name="print" />
              {t('receiptTemplates.settingsLink')}
            </Link>
          </nav>
          <nav className="admin-tabs" aria-label={t('adminSections')}>
            {(['branches', 'registers', 'memberships'] as const).map((value) => (
              <button
                type="button"
                key={value}
                aria-pressed={kind === value}
                onClick={() => {
                  setKind(value);
                  setSearch('');
                  setStatus('all');
                }}
              >
                <PosIcon
                  name={value === 'memberships' ? 'user' : value === 'branches' ? 'box' : 'cash'}
                />
                <span>{t(`adminResource_${value}`)}</span>
                <b>
                  {value === 'branches'
                    ? branchRows.length
                    : value === 'registers'
                      ? (registers.data?.data.length ?? 0)
                      : membershipRows.length}
                </b>
              </button>
            ))}
          </nav>
          {message ? (
            <p className={failed ? 'error' : 'page-success'} role={failed ? 'alert' : 'status'}>
              {message}
            </p>
          ) : null}
          {dependentError ? (
            <PageState kind="error" title={t(posFailureKey(dependentError.error))}>
              <p>{t('adminOptionsError')}</p>
              <button
                type="button"
                onClick={() => void Promise.all(dependencies.map((query) => query.refetch()))}
              >
                {t('retry')}
              </button>
            </PageState>
          ) : null}
          <section className="page-card admin-content" aria-label={t(`adminResource_${kind}`)}>
            <div className="section-heading">
              <div>
                <h2>{t(`adminResource_${kind}`)}</h2>
                <p>{t(`adminHint_${kind}`)}</p>
              </div>
              {access.write ? (
                <button
                  type="button"
                  className="primary-button"
                  disabled={busy || !ready}
                  onClick={() => {
                    setMessage('');
                    setEditor({ kind, record: {} });
                  }}
                >
                  <PosIcon name="plus" />
                  {t(
                    kind === 'branches'
                      ? 'createBranch'
                      : kind === 'registers'
                        ? 'createRegister'
                        : 'assignMembership',
                  )}
                </button>
              ) : null}
            </div>
            <div className="admin-filters">
              <label className="admin-search">
                {t('adminSearch')}
                <input
                  type="search"
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder={t(kind === 'memberships' ? 'adminSearchStaff' : 'adminSearchName')}
                />
              </label>
              {kind !== 'branches' ? (
                <label>
                  {t('branch')}
                  <select
                    value={branchFilter}
                    onChange={(event) => setBranchFilter(event.target.value)}
                  >
                    <option value="">{t('adminAllBranches')}</option>
                    {branchRows.map((branch) => (
                      <option key={branch.id} value={branch.id}>
                        {branch.name}
                      </option>
                    ))}
                  </select>
                </label>
              ) : null}
              <label>
                {t('adminStatus')}
                <select value={status} onChange={(event) => setStatus(event.target.value)}>
                  <option value="all">{t('adminAllStatuses')}</option>
                  <option value="active">{t('statusActive')}</option>
                  <option value="disabled">{t('statusDisabled')}</option>
                </select>
              </label>
            </div>
            {currentQuery.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
            {currentQuery.isSuccess && count === 0 ? (
              <PageState title={t('adminNoResults')}>
                <p>{t('adminEmptyHint')}</p>
              </PageState>
            ) : null}
            <ul
              className="admin-records"
              aria-label={t(
                kind === 'branches'
                  ? 'branchList'
                  : kind === 'registers'
                    ? 'adminRegisterList'
                    : 'staffList',
              )}
            >
              {kind === 'branches'
                ? filteredBranches.map((branch) => (
                    <li key={branch.id}>
                      <div className="admin-record-copy">
                        <strong>{branch.name}</strong>
                        <small>
                          {branch.code} · {branch.timezone}
                        </small>
                        <p>
                          {locations.data?.data.find(
                            (location) => location.id === branch.stock_location_id,
                          )?.name ?? t('adminUnavailable')}
                        </p>
                        {branch.receiving_note ? <small>{branch.receiving_note}</small> : null}
                      </div>
                      <span className="status-tag" data-warning={branch.status === 'disabled'}>
                        {t(branch.status === 'disabled' ? 'statusDisabled' : 'statusActive')}
                      </span>
                      {actions(branch, branch.name, branch.id)}
                      <div className="admin-record-actions admin-branch-links">
                        <Link
                          className="button-link"
                          to="/settings/branches/$branchId/products"
                          params={{ branchId: branch.id }}
                          aria-label={t('branchProductsFor', { name: branch.name })}
                        >
                          <PosIcon name="box" />
                          {t('branchProductsTitle')}
                        </Link>
                        <LabelFormatsLink branch={branch} />
                        <Link
                          className="button-link"
                          to="/settings/branches/$branchId/features"
                          params={{ branchId: branch.id }}
                          aria-label={t('branchFeaturesFor', { name: branch.name })}
                        >
                          <PosIcon name="cog" />
                          {t('branchFeaturesTitle')}
                        </Link>
                        <Link
                          className="button-link"
                          to="/settings/branches/$branchId/business-model"
                          params={{ branchId: branch.id }}
                          aria-label={t('businessModel.titleFor', { name: branch.name })}
                        >
                          <PosIcon name="grid" />
                          {t('businessModel.title')}
                        </Link>
                      </div>
                    </li>
                  ))
                : null}
              {kind === 'registers'
                ? filteredRegisters.map((register) => (
                    <li key={register.id}>
                      <div className="admin-record-copy">
                        <strong>{register.name}</strong>
                        <small>
                          {register.code} · {branchName(register.branch_id)}
                        </small>
                      </div>
                      <span className="status-tag" data-warning={register.status === 'disabled'}>
                        {t(register.status === 'disabled' ? 'statusDisabled' : 'statusActive')}
                      </span>
                      {actions(register, register.name, register.branch_id)}
                    </li>
                  ))
                : null}
              {kind === 'memberships'
                ? filteredMemberships.map((membership) => (
                    <li key={membership.id}>
                      <div className="admin-record-copy">
                        <strong>{staffName(membership.staff_id)}</strong>
                        <small>{branchName(membership.branch_id)}</small>
                        <div className="admin-capability-tags">
                          {membership.capabilities.map((capability) => (
                            <span key={capability}>
                              {t(
                                posCapabilities.find(([value]) => value === capability)?.[1] ??
                                  'adminUnknownPermission',
                              )}
                            </span>
                          ))}
                        </div>
                      </div>
                      <span className="status-tag" data-warning={membership.status === 'disabled'}>
                        {t(membership.status === 'disabled' ? 'statusDisabled' : 'statusActive')}
                      </span>
                      {actions(membership, staffName(membership.staff_id), membership.branch_id)}
                    </li>
                  ))
                : null}
            </ul>
            <p className="admin-record-count">{t('adminResultCount', { count })}</p>
          </section>
        </div>
      )}
      {editor ? (
        <TopologyEditor
          kind={editor.kind}
          record={editor.record}
          hideLotSelection={hideLotSelection}
          profiles={branchProfiles}
          defaultProfileKey={storeProfile.data?.profile_key ?? 'khac'}
          branches={branchRows}
          staff={[
            ...(staff.data?.data ?? []),
            ...membershipRows.flatMap((membership) =>
              membership.staff && !staff.data?.data.some((user) => user.id === membership.staff_id)
                ? [membership.staff]
                : [],
            ),
          ].filter(
            (user, index, users) =>
              users.findIndex((candidate) => candidate.id === user.id) === index,
          )}
          locations={locations.data?.data ?? []}
          memberships={membershipRows}
          onSave={save}
          onClose={() => setEditor(null)}
        />
      ) : null}
    </PosPage>
  );
}
