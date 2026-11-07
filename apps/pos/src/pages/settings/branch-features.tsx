import { useParams } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import { setFeature, useBranchFeatures } from '../../hooks/use-branch-features';
import { administrationAccess } from '../../lib/pos-administration';
import type { PosBranch } from '../../lib/pos-context';
import {
  branchOverride,
  type BranchFeatures as Flags,
  offReason,
  POS_FEATURES,
  type PosFeature,
} from '../../lib/pos-features';
import { queryClient } from '../../lib/query-client';
import { describeFailure, failureStatus, posFailureKey } from '../../lib/request-failure';
import { formatInZone } from '../../lib/shifts';
import { BranchSettingsFrame } from './branch-settings';

// Store administrators reach this page from Settings and may switch the store
// defaults; a branch manager (`pos.topology.manage` at the selected branch)
// reaches it for that branch only and may switch features off there.
export function BranchFeaturesPage() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const admin = administrationAccess(context.data);
  const branchId = useParams({ strict: false }).branchId ?? '';
  if (admin.read)
    return (
      <BranchSettingsFrame section="features">
        {({ branch, access }) => (
          <BranchFeatures
            key={branch.id}
            branch={branch}
            storeWrite={access.write}
            branchWrite={
              access.write ||
              managesBranch(context.data?.capabilities, selection.branchId, branch.id)
            }
          />
        )}
      </BranchSettingsFrame>
    );
  const branch = context.data?.branches.find((row) => row.id === branchId);
  const manager = managesBranch(context.data?.capabilities, selection.branchId, branchId);
  return (
    <PosPage
      title={branch ? `${t('branchFeaturesTitle')} · ${branch.name}` : t('branchFeaturesTitle')}
      description={t('branchFeaturesIntro')}
    >
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !manager || !branch ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <BranchFeatures branch={branch} storeWrite={false} branchWrite />
      )}
    </PosPage>
  );
}

// Context capabilities are those of the selected branch.
function managesBranch(
  capabilities: string[] | undefined,
  selected: string | null,
  branchId: string,
) {
  return selected === branchId && Boolean(capabilities?.includes('pos.topology.manage'));
}

// The change being written: the store default, or this branch's switch.
type Change = { feature: PosFeature; scope: 'store' | 'branch'; enabled: boolean | null };

function BranchFeatures({
  branch,
  storeWrite,
  branchWrite,
}: {
  branch: PosBranch;
  storeWrite: boolean;
  branchWrite: boolean;
}) {
  const { t } = useTranslation();
  const flags = useBranchFeatures(branch.id, true);
  const [change, setChange] = useState<Change | null>(null);
  const [reason, setReason] = useState('');
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);

  function start(next: Change) {
    setNotice(null);
    setReason('');
    setChange(next);
  }

  async function save() {
    const note = reason.trim();
    if (!change || !note || busy) return;
    const name = t(`featureName_${change.feature}`);
    setBusy(true);
    setNotice(null);
    try {
      await setFeature(
        change.feature,
        change.enabled,
        note,
        change.scope === 'branch' ? branch.id : undefined,
      );
      setNotice({ text: t(changeText(change, 'saved'), { name }), failed: false });
      setChange(null);
    } catch (error) {
      setNotice({ text: describeFailure(error, t), failed: true });
    } finally {
      // Fresh switches first, so the row never shows the old state as editable.
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ['pos', 'branch-features'] }),
        // The selling screens read the flags from the context.
        queryClient.invalidateQueries({ queryKey: ['pos', 'context'] }),
      ]);
      setBusy(false);
    }
  }

  return (
    <section className="page-card admin-content" aria-labelledby="branch-features-heading">
      <div className="section-heading">
        <div>
          <h2 id="branch-features-heading">{t('branchFeaturesTitle')}</h2>
          <p>{t('branchFeaturesIntro')}</p>
        </div>
      </div>
      {!storeWrite && !branchWrite ? <p className="muted">{t('featureReadOnly')}</p> : null}
      {!storeWrite && branchWrite ? <p className="muted">{t('featureBranchOnly')}</p> : null}
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      {flags.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
      {flags.isError && failureStatus(flags.error) === 404 ? (
        <PageState title={t('branchFeaturesUnsupported')} />
      ) : flags.isError ? (
        <PageState kind="error" title={t(posFailureKey(flags.error))}>
          <button type="button" onClick={() => void flags.refetch()}>
            {t('retry')}
          </button>
        </PageState>
      ) : null}
      {flags.data ? (
        <ul className="admin-records" aria-label={t('branchFeaturesList')}>
          {POS_FEATURES.map((feature) => (
            <FeatureRow
              key={feature}
              feature={feature}
              flags={flags.data}
              timeZone={branch.timezone}
              storeWrite={storeWrite}
              branchWrite={branchWrite}
              busy={busy}
              change={change?.feature === feature ? change : null}
              reason={reason}
              onStart={start}
              onReason={setReason}
              onCancel={() => setChange(null)}
              onSave={() => void save()}
            />
          ))}
        </ul>
      ) : null}
    </section>
  );
}

function changeText(change: Change, kind: 'confirm' | 'saved') {
  const action =
    change.scope === 'store'
      ? change.enabled
        ? 'StoreOn'
        : 'StoreOff'
      : change.enabled === null
        ? 'BranchRestore'
        : 'BranchOff';
  return `feature${kind === 'confirm' ? 'Confirm' : 'Saved'}${action}`;
}

function FeatureRow({
  feature,
  flags,
  timeZone,
  storeWrite,
  branchWrite,
  busy,
  change,
  reason,
  onStart,
  onReason,
  onCancel,
  onSave,
}: {
  feature: PosFeature;
  flags: Flags;
  timeZone: string;
  storeWrite: boolean;
  branchWrite: boolean;
  busy: boolean;
  change: Change | null;
  reason: string;
  onStart: (change: Change) => void;
  onReason: (value: string) => void;
  onCancel: () => void;
  onSave: () => void;
}) {
  const { t, i18n } = useTranslation();
  const on = flags.features[feature] === true;
  const storeOn = flags.store_defaults[feature] === true;
  const branchOff = branchOverride(flags, feature) === false;
  const why = offReason(flags, feature);
  const name = t(`featureName_${feature}`);
  const latest = [...flags.settings]
    .filter((row) => row.feature === feature)
    .sort((a, b) => (b.changed_at ?? '').localeCompare(a.changed_at ?? ''))[0];
  const reasonId = `feature-reason-${feature}`;
  return (
    <li data-feature={feature}>
      <div className="admin-record-copy">
        <strong>{name}</strong>
        <small>{t(`featureHint_${feature}`)}</small>
        <small>
          {t('featureStoreState', { state: t(storeOn ? 'featureStatusOn' : 'featureStatusOff') })}
          {' · '}
          {t(branchOff ? 'featureBranchOffState' : 'featureBranchFollows')}
        </small>
        {latest ? (
          <small>
            {t('featureLastChange', {
              name: latest.changed_by_name ?? '—',
              at: formatInZone(latest.changed_at, i18n.language, timeZone),
              reason: latest.reason,
            })}
          </small>
        ) : null}
      </div>
      <span className="status-tag" data-warning={!on}>
        {on
          ? t('featureStatusOn')
          : t(why === 'branch' ? 'featureOffByBranch' : 'featureOffByStore')}
      </span>
      {!change && (storeWrite || branchWrite) ? (
        <div className="admin-record-actions">
          {storeWrite ? (
            <button
              type="button"
              className={storeOn ? 'danger-button' : ''}
              disabled={busy}
              onClick={() => onStart({ feature, scope: 'store', enabled: !storeOn })}
            >
              {t(storeOn ? 'featureStoreTurnOff' : 'featureStoreTurnOn', { name })}
            </button>
          ) : null}
          {/* Switching off needs branch rights; dropping that switch needs store rights. */}
          {branchWrite && (!branchOff || storeWrite) ? (
            <button
              type="button"
              className={branchOff ? '' : 'danger-button'}
              disabled={busy}
              onClick={() =>
                onStart({ feature, scope: 'branch', enabled: branchOff ? null : false })
              }
            >
              {t(branchOff ? 'featureBranchRestore' : 'featureBranchTurnOff', { name })}
            </button>
          ) : null}
        </div>
      ) : null}
      {change ? (
        <form
          className="admin-record-actions feature-change"
          aria-label={t('featureChangeFor', { name })}
          onSubmit={(event) => {
            event.preventDefault();
            onSave();
          }}
        >
          <p className="muted" id={`${reasonId}-hint`}>
            {t(changeText(change, 'confirm'), { name })}
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
            onChange={(event) => onReason(event.target.value)}
          />
          <button
            type="submit"
            className={change.enabled === false ? 'danger-button' : 'primary-button'}
            disabled={busy || !reason.trim()}
          >
            {busy ? t('waiting') : t('featureSave')}
          </button>
          <button type="button" disabled={busy} onClick={onCancel}>
            {t('adminCancel')}
          </button>
        </form>
      ) : null}
    </li>
  );
}
