import { POS_FEATURES } from '@parkviet/pos-shared/pos-features'
import { describeFailure, failureStatus, posFailureKey } from '@parkviet/pos-shared/request-failure'
import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { useStore } from '@spree/dashboard-core'
import { useMutation } from '@tanstack/react-query'
import { useParams } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import {
  type FeatureChange,
  FeatureSwitchRow,
  featureChangeText,
} from '../components/feature-switch-row'
import { ModelCard, ModelNotice, ModelPage, ModelState } from '../components/setup/model-ui'
import { setFeature, useBranchFeatures } from '../hooks/use-branch-features'
import { useBranchSelection } from '../hooks/use-branch-selection'
import { refreshBusinessModel } from '../hooks/use-onboarding'
import { usePosContext } from '../hooks/use-pos-context'

export function BranchFeaturesPage() {
  const { t } = useTranslation()
  const storeContext = usePosContext()
  const { selection } = useBranchSelection(storeContext.data?.branches)
  const context = usePosContext(selection)
  const { branchId } = useParams({ strict: false })
  const branch = context.data?.branches.find((row) => row.id === (branchId ?? selection.branchId))
  const access = context.data?.administration
  const manager = Boolean(
    branch &&
      branch.id === selection.branchId &&
      context.data?.capabilities.includes('pos.topology.manage'),
  )
  return (
    <ModelPage
      title={branch ? `${t('branchFeaturesTitle')} · ${branch.name}` : t('branchFeaturesTitle')}
      description={t('branchFeaturesIntro')}
      actions={<BranchPicker />}
    >
      {context.isPending ? (
        <ModelState title={t('contextWaiting')} />
      ) : context.isError ? (
        <ModelState
          error
          title={t(posFailureKey(context.error))}
          retry={() => void context.refetch()}
        />
      ) : !access?.read && !manager ? (
        <ModelState error title={t('adminAccessDenied')} />
      ) : !branch ? (
        <ModelState title={t('branchesEmpty')} />
      ) : (
        <BranchFeatures
          key={branch.id}
          branch={branch}
          storeWrite={access?.write === true}
          branchWrite={access?.write === true || manager}
        />
      )}
    </ModelPage>
  )
}

function BranchFeatures({
  branch,
  storeWrite,
  branchWrite,
}: {
  branch: PosBranch
  storeWrite: boolean
  branchWrite: boolean
}) {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const mutation = useMutation({
    mutationFn: (input: { change: FeatureChange; reason: string }) =>
      setFeature(
        input.change.feature,
        input.change.enabled,
        input.reason,
        input.change.scope === 'branch' ? branch.id : undefined,
      ),
  })
  const flags = useBranchFeatures(branch.id, true)
  const [change, setChange] = useState<FeatureChange | null>(null)
  const [reason, setReason] = useState('')
  const [busy, setBusy] = useState(false)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  async function save() {
    const note = reason.trim()
    if (
      !change ||
      !note ||
      busy ||
      (change.scope === 'store'
        ? !storeWrite
        : !branchWrite || (change.enabled !== false && !storeWrite))
    )
      return
    setBusy(true)
    setNotice(null)
    try {
      await mutation.mutateAsync({ change, reason: note })
      setNotice({
        text: t(featureChangeText(change, 'saved'), { name: t(`featureName_${change.feature}`) }),
        failed: false,
      })
      setChange(null)
    } catch (error) {
      setNotice({ text: describeFailure(error, t), failed: true })
    } finally {
      try {
        await refreshBusinessModel(storeId)
      } finally {
        setBusy(false)
      }
    }
  }
  return (
    <ModelCard title={t('branchFeaturesTitle')} id="branch-features-heading">
      {!storeWrite && !branchWrite ? (
        <p>{t('featureReadOnly')}</p>
      ) : !storeWrite ? (
        <p>{t('featureBranchOnly')}</p>
      ) : null}
      <ModelNotice notice={notice} />
      {flags.isPending ? (
        <ModelState title={t('waiting')} />
      ) : flags.isError ? (
        <ModelState
          error
          title={t(
            failureStatus(flags.error) === 404
              ? 'branchFeaturesUnsupported'
              : posFailureKey(flags.error),
          )}
          retry={failureStatus(flags.error) === 404 ? undefined : () => void flags.refetch()}
        />
      ) : null}
      {flags.data && !flags.isError ? (
        <ul className="divide-y" aria-label={t('branchFeaturesList')}>
          {POS_FEATURES.map((feature) => (
            <FeatureSwitchRow
              key={feature}
              feature={feature}
              flags={flags.data}
              timeZone={branch.timezone}
              storeWrite={storeWrite}
              branchWrite={branchWrite}
              busy={busy}
              change={change?.feature === feature ? change : null}
              reason={reason}
              onStart={(next) => {
                setNotice(null)
                setReason('')
                setChange(next)
              }}
              onReason={setReason}
              onCancel={() => setChange(null)}
              onSave={() => void save()}
            />
          ))}
        </ul>
      ) : null}
    </ModelCard>
  )
}
