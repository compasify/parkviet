import {
  type BusinessModule,
  type BusinessProfile,
  modulesEnabledWith,
  modulesRequiring,
  moduleTextKey,
  type PosModules,
  profileDescriptionKey,
  profileLabelKey,
} from '@parkviet/pos-shared/pos-modules';
import { useParams } from '@tanstack/react-router';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import { ProfileDiff } from '../../components/profile-diff';
import { ModuleDescription } from '../../components/setup/setup-preview-step';
import {
  applyBranchProfile,
  type ProfilePreview,
  previewBranchProfile,
  setBranchModule,
  useBranchModuleDetail,
} from '../../hooks/use-branch-modules';
import { useBusinessProfiles } from '../../hooks/use-business-profiles';
import {
  refreshBusinessModel,
  type StoreProfile,
  saveStoreProfile,
  useStoreProfile,
} from '../../hooks/use-onboarding';
import { administrationAccess } from '../../lib/pos-administration';
import type { PosBranch } from '../../lib/pos-context';
import { conflictReason, describeFailure, posFailureKey } from '../../lib/request-failure';
import { formatInZone } from '../../lib/shifts';
import '../../styles/setup.css';
import { BranchSettingsFrame } from './branch-settings';

type Translate = (key: string, options?: Record<string, unknown>) => string;

// Refusals of the business model commands, in words; anything else falls back
// to the shared wording.
function modelFailure(error: unknown, t: Translate) {
  const reason = conflictReason(error);
  if (reason === 'module_required_by') {
    const details = (error as { details?: { required_by?: unknown } }).details;
    const names = Array.isArray(details?.required_by)
      ? details.required_by
          .filter((key): key is string => typeof key === 'string')
          .map((key) => moduleName(t, key))
      : [];
    return t('businessModel.requiredBy', { list: names.join(', ') });
  }
  if (
    reason === 'profile_conflict' ||
    reason === 'profile_unavailable' ||
    reason === 'module_unavailable' ||
    reason === 'reason_required' ||
    reason === 'onboarding_required'
  )
    return t(`businessModel.failure_${reason}`);
  return describeFailure(error, t);
}

function moduleName(t: Translate, key: string) {
  const text = moduleTextKey(key);
  return text ? t(`posModules.${text}.label`) : key;
}

// Store administrators reach this page from Settings; they change the
// branch's industry, its modules and the store's main profile. A branch
// manager (`pos.topology.manage` at the selected branch) reaches it for that
// branch only and switches its modules.
export function BusinessModelPage() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const admin = administrationAccess(context.data);
  const branchId = useParams({ strict: false }).branchId ?? '';
  const manager =
    selection.branchId === branchId &&
    Boolean(context.data?.capabilities.includes('pos.topology.manage'));
  if (admin.read)
    return (
      <BranchSettingsFrame section="model">
        {({ branch, access, storeId }) => (
          <BusinessModel
            key={branch.id}
            branch={branch}
            storeId={storeId}
            storeWrite={access.write}
            branchWrite={access.write || manager}
          />
        )}
      </BranchSettingsFrame>
    );
  const branch = context.data?.branches.find((row) => row.id === branchId);
  return (
    <PosPage
      title={branch ? `${t('businessModel.title')} · ${branch.name}` : t('businessModel.title')}
      description={t('businessModel.intro')}
    >
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !manager || !branch ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <BusinessModel
          branch={{ ...branch, profile_key: branch.profile_key ?? context.data?.profile?.key }}
          storeId={context.data?.store.id ?? null}
          storeWrite={false}
          branchWrite
        />
      )}
    </PosPage>
  );
}

function BusinessModel({
  branch,
  storeId,
  storeWrite,
  branchWrite,
}: {
  branch: PosBranch;
  storeId: string | null;
  storeWrite: boolean;
  branchWrite: boolean;
}) {
  const { t } = useTranslation();
  const catalogue = useBusinessProfiles(storeId);
  const detail = useBranchModuleDetail(branch.id);
  const profiles = catalogue.data?.profiles ?? [];
  const current = profiles.find((profile) => profile.key === branch.profile_key);
  return (
    <div className="business-model">
      <section className="page-card admin-content" aria-labelledby="business-model-current">
        <div className="section-heading">
          <div>
            <h2 id="business-model-current">{t('businessModel.currentTitle')}</h2>
            <p>{t('businessModel.intro')}</p>
          </div>
        </div>
        {catalogue.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
        {catalogue.isError ? (
          <PageState kind="error" title={t(posFailureKey(catalogue.error))}>
            <button type="button" onClick={() => void catalogue.refetch()}>
              {t('retry')}
            </button>
          </PageState>
        ) : null}
        {branch.profile_key ? (
          <div className="business-model-profile" data-profile={branch.profile_key}>
            <strong>
              {t(profileLabelKey(branch.profile_key), { defaultValue: branch.profile_key })}
            </strong>
            <small>{t(profileDescriptionKey(branch.profile_key), { defaultValue: '' })}</small>
          </div>
        ) : (
          <p className="muted">{t('businessModel.profileUnknown')}</p>
        )}
        {storeWrite && catalogue.data ? (
          <ChangeProfile branch={branch} profiles={profiles} current={current} />
        ) : null}
      </section>
      <ModuleSwitches
        branch={branch}
        catalogue={catalogue.data?.modules ?? []}
        detail={detail}
        write={branchWrite}
      />
      {storeWrite && catalogue.data ? (
        <StoreProfileSection storeId={storeId} profiles={profiles} />
      ) : null}
    </div>
  );
}

function ChangeProfile({
  branch,
  profiles,
  current,
}: {
  branch: PosBranch;
  profiles: BusinessProfile[];
  current: BusinessProfile | undefined;
}) {
  const { t } = useTranslation();
  const choices = profiles.filter(
    (profile) => profile.status === 'available' && profile.key !== branch.profile_key,
  );
  const [target, setTarget] = useState('');
  const [preview, setPreview] = useState<ProfilePreview | null>(null);
  const [applyModules, setApplyModules] = useState(true);
  const [applyDefaults, setApplyDefaults] = useState<string[]>([]);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);

  async function loadPreview(key: string) {
    setBusy(true);
    try {
      setPreview(await previewBranchProfile(branch.id, key));
      setApplyModules(true);
      setApplyDefaults([]);
    } catch (error) {
      setPreview(null);
      setNotice({ text: modelFailure(error, t), failed: true });
    } finally {
      setBusy(false);
    }
  }

  async function apply(event: FormEvent) {
    event.preventDefault();
    const note = reason.trim();
    if (!preview || !note || busy) return;
    setBusy(true);
    setNotice(null);
    const name = t(profileLabelKey(preview.to));
    try {
      await applyBranchProfile(branch.id, {
        profile_key: preview.to,
        // The profile the diff was made from: a change made meanwhile is refused.
        expected_profile_key: preview.from,
        apply_modules: applyModules,
        apply_defaults: applyDefaults,
        reason: note,
      });
      setPreview(null);
      setTarget('');
      setReason('');
      setNotice({ text: t('businessModel.profileSaved', { name }), failed: false });
      await refreshBusinessModel();
    } catch (error) {
      if (conflictReason(error) === 'profile_conflict') {
        // Someone moved the branch meanwhile: show the diff from where it is now.
        setNotice({ text: t('businessModel.failure_profile_conflict'), failed: true });
        await refreshBusinessModel();
        await loadPreview(preview.to);
      } else {
        setNotice({ text: modelFailure(error, t), failed: true });
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="business-model-change">
      <h3 id="business-model-change">{t('businessModel.changeTitle')}</h3>
      <p className="muted">{t('businessModel.changeIntro')}</p>
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      <form
        className="business-model-pick"
        aria-labelledby="business-model-change"
        onSubmit={(event) => {
          event.preventDefault();
          if (target) void loadPreview(target);
        }}
      >
        <label>
          {t('businessModel.newProfile')}
          <select
            value={target}
            disabled={busy}
            onChange={(event) => {
              setTarget(event.target.value);
              setPreview(null);
              setNotice(null);
            }}
          >
            <option value="">{t('businessModel.chooseProfile')}</option>
            {choices.map((profile) => (
              <option key={profile.key} value={profile.key}>
                {t(profileLabelKey(profile.key), { defaultValue: profile.key })}
              </option>
            ))}
          </select>
        </label>
        <button type="submit" disabled={busy || !target}>
          {t('businessModel.previewButton')}
        </button>
      </form>
      {preview ? (
        <form
          className="business-model-apply"
          aria-label={t('businessModel.applyFormLabel', { name: t(profileLabelKey(preview.to)) })}
          onSubmit={(event) => void apply(event)}
        >
          <p>
            {t('businessModel.diffIntro', {
              from: t(profileLabelKey(preview.from), {
                defaultValue: preview.from || current?.key || '—',
              }),
              to: t(profileLabelKey(preview.to)),
            })}
          </p>
          <ProfileDiff
            branchId={branch.id}
            preview={preview}
            applyModules={applyModules}
            applyDefaults={applyDefaults}
            disabled={busy}
            onApplyModules={setApplyModules}
            onApplyDefault={(field, value) =>
              setApplyDefaults((fields) =>
                value
                  ? [...fields.filter((item) => item !== field), field]
                  : fields.filter((item) => item !== field),
              )
            }
          />
          <label htmlFor="business-model-reason">{t('featureReason')}</label>
          <input
            id="business-model-reason"
            value={reason}
            maxLength={200}
            required
            autoComplete="off"
            disabled={busy}
            onChange={(event) => setReason(event.target.value)}
          />
          <div className="admin-record-actions">
            <button type="submit" className="primary-button" disabled={busy || !reason.trim()}>
              {busy
                ? t('waiting')
                : t('businessModel.applyButton', { name: t(profileLabelKey(preview.to)) })}
            </button>
            <button
              type="button"
              disabled={busy}
              onClick={() => {
                setPreview(null);
                setNotice(null);
              }}
            >
              {t('adminCancel')}
            </button>
          </div>
        </form>
      ) : null}
    </div>
  );
}

type Change = { key: string; enabled: boolean; alsoEnabled: string[] };

function ModuleSwitches({
  branch,
  catalogue,
  detail,
  write,
}: {
  branch: PosBranch;
  catalogue: BusinessModule[];
  detail: ReturnType<typeof useBranchModuleDetail>;
  write: boolean;
}) {
  const { t, i18n } = useTranslation();
  const [change, setChange] = useState<Change | null>(null);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const modules: PosModules = detail.data?.modules ?? {};
  // Available modules of the catalogue, then any module the branch reports
  // that this catalogue does not list (kept, never hidden: D3).
  const keys = [
    ...catalogue.filter((item) => item.status === 'available').map((item) => item.key),
    ...Object.keys(modules).filter((key) => !catalogue.some((item) => item.key === key)),
  ];

  async function save(event: FormEvent) {
    event.preventDefault();
    const note = reason.trim();
    if (!change || !note || busy) return;
    setBusy(true);
    setNotice(null);
    const name = moduleName(t, change.key);
    try {
      const result = await setBranchModule(branch.id, change.key, change.enabled, note);
      setNotice({
        text: change.enabled
          ? result.alsoEnabled.length
            ? t('businessModel.moduleOnWith', {
                name,
                list: result.alsoEnabled.map((key) => moduleName(t, key)).join(', '),
              })
            : t('businessModel.moduleOnSaved', { name })
          : t('businessModel.moduleOffSaved', { name }),
        failed: false,
      });
      setChange(null);
      setReason('');
    } catch (error) {
      setNotice({ text: modelFailure(error, t), failed: true });
    } finally {
      await refreshBusinessModel();
      setBusy(false);
    }
  }

  return (
    <section className="page-card admin-content" aria-labelledby="business-model-modules">
      <div className="section-heading">
        <div>
          <h2 id="business-model-modules">{t('businessModel.modulesTitle')}</h2>
          <p>{t('businessModel.modulesIntro')}</p>
        </div>
      </div>
      {!write ? <p className="muted">{t('featureReadOnly')}</p> : null}
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      {detail.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
      {detail.isError ? (
        <PageState kind="error" title={t(posFailureKey(detail.error))}>
          <button type="button" onClick={() => void detail.refetch()}>
            {t('retry')}
          </button>
        </PageState>
      ) : null}
      {detail.data ? (
        <ul className="admin-records" aria-label={t('businessModel.modulesList')}>
          {keys.map((key) => {
            const on = modules[key] === true;
            const name = moduleName(t, key);
            const latest = detail.data.settings.find((row) => row.module === key);
            const requiredBy = on ? modulesRequiring(key, catalogue, modules) : [];
            const enabledWith = on ? [] : modulesEnabledWith(key, catalogue, modules);
            const editing = change?.key === key;
            const reasonId = `module-reason-${key.replaceAll('.', '-')}`;
            const blockedId = `module-blocked-${key.replaceAll('.', '-')}`;
            return (
              <li key={key} data-module={key}>
                <div className="admin-record-copy">
                  <strong>{name}</strong>
                  <small>
                    <ModuleDescription moduleKey={key} />
                  </small>
                  {latest?.changed_at ? (
                    <small>
                      {t('featureLastChange', {
                        name: latest.changed_by_name ?? '—',
                        at: formatInZone(latest.changed_at, i18n.language, branch.timezone),
                        reason: latest.reason,
                      })}
                    </small>
                  ) : null}
                  {requiredBy.length ? (
                    <small id={blockedId}>
                      {t('businessModel.requiredBy', {
                        list: requiredBy.map((item) => moduleName(t, item)).join(', '),
                      })}
                    </small>
                  ) : null}
                </div>
                <span className="status-tag" data-warning={!on}>
                  {t(on ? 'featureStatusOn' : 'featureStatusOff')}
                </span>
                {write && !editing ? (
                  <div className="admin-record-actions">
                    <button
                      type="button"
                      className={on ? 'danger-button' : ''}
                      disabled={busy || requiredBy.length > 0}
                      aria-describedby={requiredBy.length ? blockedId : undefined}
                      onClick={() => {
                        setNotice(null);
                        setReason('');
                        setChange({ key, enabled: !on, alsoEnabled: enabledWith });
                      }}
                    >
                      {t(on ? 'businessModel.moduleTurnOff' : 'businessModel.moduleTurnOn', {
                        name,
                      })}
                    </button>
                  </div>
                ) : null}
                {editing && change ? (
                  <form
                    className="admin-record-actions feature-change"
                    aria-label={t('featureChangeFor', { name })}
                    onSubmit={(event) => void save(event)}
                  >
                    <p className="muted" id={`${reasonId}-hint`}>
                      {change.enabled
                        ? change.alsoEnabled.length
                          ? t('businessModel.moduleConfirmOnWith', {
                              name,
                              list: change.alsoEnabled
                                .map((item) => moduleName(t, item))
                                .join(', '),
                            })
                          : t('businessModel.moduleConfirmOn', { name })
                        : t('businessModel.moduleConfirmOff', { name })}
                    </p>
                    <label htmlFor={reasonId}>{t('featureReason')}</label>
                    <input
                      id={reasonId}
                      value={reason}
                      maxLength={200}
                      required
                      autoComplete="off"
                      aria-describedby={`${reasonId}-hint`}
                      disabled={busy}
                      // biome-ignore lint/a11y/noAutofocus: the reason is the only next step of this change
                      autoFocus
                      onChange={(event) => setReason(event.target.value)}
                    />
                    <button
                      type="submit"
                      className={change.enabled ? 'primary-button' : 'danger-button'}
                      disabled={busy || !reason.trim()}
                    >
                      {busy ? t('waiting') : t('featureSave')}
                    </button>
                    <button type="button" disabled={busy} onClick={() => setChange(null)}>
                      {t('adminCancel')}
                    </button>
                  </form>
                ) : null}
              </li>
            );
          })}
        </ul>
      ) : null}
    </section>
  );
}

function StoreProfileSection({
  storeId,
  profiles,
}: {
  storeId: string | null;
  profiles: BusinessProfile[];
}) {
  const { t } = useTranslation();
  const query = useStoreProfile(storeId, true);
  if (query.isPending) return <PageState kind="loading" title={t('waiting')} />;
  if (query.isError)
    return (
      <PageState kind="error" title={t(posFailureKey(query.error))}>
        <button type="button" onClick={() => void query.refetch()}>
          {t('retry')}
        </button>
      </PageState>
    );
  // Mounted once loaded: the form starts from the stored row and compares
  // with each fresh read, so a saved change leaves nothing to save.
  return <StoreProfileForm stored={query.data ?? null} profiles={profiles} />;
}

function StoreProfileForm({
  stored,
  profiles,
}: {
  stored: StoreProfile | null;
  profiles: BusinessProfile[];
}) {
  const { t } = useTranslation();
  const available = profiles.filter((profile) => profile.status === 'available');
  const soon = profiles.filter((profile) => profile.status === 'coming_soon');
  const [profileKey, setProfileKey] = useState(stored?.profile_key ?? 'khac');
  const [wholesale, setWholesale] = useState(stored?.wholesale ?? false);
  const [interests, setInterests] = useState<string[]>(stored?.interests ?? []);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const changed =
    !stored ||
    profileKey !== stored.profile_key ||
    wholesale !== stored.wholesale ||
    [...interests].sort().join() !== [...stored.interests].sort().join();

  async function save(event: FormEvent) {
    event.preventDefault();
    const note = reason.trim();
    if (!note || busy || !changed) return;
    setBusy(true);
    setNotice(null);
    try {
      await saveStoreProfile({ profile_key: profileKey, wholesale, interests, reason: note });
      setReason('');
      setNotice({ text: t('businessModel.storeSaved'), failed: false });
      await refreshBusinessModel();
    } catch (error) {
      setNotice({ text: modelFailure(error, t), failed: true });
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="page-card admin-content" aria-labelledby="business-model-store">
      <div className="section-heading">
        <div>
          <h2 id="business-model-store">{t('businessModel.storeTitle')}</h2>
          <p>{t('businessModel.storeIntro')}</p>
        </div>
      </div>
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      <form className="setup-form" onSubmit={(event) => void save(event)}>
        <label>
          {t('businessModel.storeProfile')}
          <select
            value={profileKey}
            disabled={busy}
            onChange={(event) => setProfileKey(event.target.value)}
          >
            {available.map((profile) => (
              <option key={profile.key} value={profile.key}>
                {t(profileLabelKey(profile.key), { defaultValue: profile.key })}
              </option>
            ))}
          </select>
        </label>
        <label className="setup-check">
          <input
            type="checkbox"
            checked={wholesale}
            disabled={busy}
            onChange={(event) => setWholesale(event.target.checked)}
          />
          <span>
            <strong>{t('businessModel.storeWholesale')}</strong>
            <small>{t('setup.wholesaleNote')}</small>
          </span>
        </label>
        {soon.length ? (
          <fieldset className="setup-features">
            <legend>{t('businessModel.storeInterests')}</legend>
            {soon.map((profile) => (
              <label key={profile.key} className="setup-check">
                <input
                  type="checkbox"
                  checked={interests.includes(profile.key)}
                  disabled={busy}
                  onChange={(event) =>
                    setInterests((keys) =>
                      event.target.checked
                        ? [...keys.filter((key) => key !== profile.key), profile.key]
                        : keys.filter((key) => key !== profile.key),
                    )
                  }
                />
                <span>{t(profileLabelKey(profile.key), { defaultValue: profile.key })}</span>
              </label>
            ))}
          </fieldset>
        ) : null}
        <label>
          {t('featureReason')}
          <input
            value={reason}
            maxLength={200}
            required
            autoComplete="off"
            disabled={busy}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
        <div className="admin-record-actions">
          <button
            type="submit"
            className="primary-button"
            disabled={busy || !changed || !reason.trim()}
          >
            {busy ? t('waiting') : t('businessModel.storeSave')}
          </button>
        </div>
      </form>
    </section>
  );
}
