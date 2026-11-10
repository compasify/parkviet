import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  useConfirm,
} from '@spree/dashboard-ui'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

export function TopologyDialog({
  title,
  subtitle,
  dirty,
  busy,
  onClose,
  children,
}: {
  title: string
  subtitle?: string
  dirty: boolean
  busy: boolean
  onClose: () => void
  children: (close: () => void) => ReactNode
}) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  async function close() {
    if (busy) return
    if (
      dirty &&
      !(await confirm({
        message: t('adminDiscard'),
        variant: 'destructive',
        confirmLabel: t('adminClose'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    onClose()
  }
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open) void close()
      }}
    >
      <DialogContent showCloseButton={false} className="max-h-[90dvh] overflow-y-auto sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{subtitle || t('adminWorkspace')}</DialogDescription>
        </DialogHeader>
        {children(() => void close())}
      </DialogContent>
    </Dialog>
  )
}
