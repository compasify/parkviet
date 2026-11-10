import {
  describeInventoryFailure,
  type PosLot,
  type PosSerialUnit,
} from '@parkviet/pos-shared/traceability'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useInventoryCommand } from '../../hooks/use-inventory'
import { ReasonDialog } from './inventory-shared'

export type HoldTarget = {
  kind: 'lots' | 'serial_units'
  id: string
  label: string
  release: boolean
}

// Quarantine or release of one lot or serial unit, with its reason.
export function HoldDialog({
  branchId,
  target,
  onClose,
  onDone,
}: {
  branchId: string
  target: HoldTarget
  onClose: () => void
  onDone: (message: string) => void
}) {
  const { t } = useTranslation()
  const command = useInventoryCommand<PosLot | PosSerialUnit>()
  const [error, setError] = useState('')
  const action = target.release ? 'release' : 'quarantine'
  return (
    <ReasonDialog
      title={t(target.release ? 'inventoryReleaseTitle' : 'inventoryQuarantineTitle', {
        label: target.label,
      })}
      submitLabel={t(target.release ? 'inventoryRelease' : 'inventoryQuarantine')}
      destructive={!target.release}
      command={command}
      error={error}
      onClose={onClose}
      onSubmit={(reason) => {
        setError('')
        command.run(
          {
            branchId,
            action,
            path: `/pos/${target.kind}/${target.id}/${action}`,
            body: { reason },
          },
          {
            onSuccess: () =>
              onDone(
                t(target.release ? 'inventoryReleased' : 'inventoryQuarantined', {
                  label: target.label,
                }),
              ),
            onError: (failure) => setError(describeInventoryFailure(failure, t)),
          },
        )
      }}
    />
  )
}
