import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { Badge, Button, Card, CardContent, useConfirm } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { type ProductHit, ProductSearch } from '../components/product-search'
import { Input, TopologyField } from '../components/topology-fields'
import { usePosSession } from '../hooks/use-pos-session'
import { type StockAlert, useSetStockAlert, useStockAlerts } from '../hooks/use-recipes'
import { canManageRecipes, type PosAccess } from '../lib/pos-access'

type Notice = { text: string; failed: boolean } | null

function alertFailure(error: unknown, t: (key: string) => string) {
  return conflictReason(error) === 'stock_alert_invalid'
    ? t('stockAlerts.failure_stock_alert_invalid')
    : describeFailure(error, t)
}

// "Cảnh báo tồn": the ingredients and goods of the selected branch that warn
// when their shelf falls below a threshold, lowest first. Recipe sales record
// a warning the moment a sale takes the shelf below its threshold.
export function StockAlertsPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const { context, selection } = usePosSession()
  const { permissionKeys } = usePermissions()
  const access: PosAccess = { permissionKeys, context: context.data }
  const manage = canManageRecipes(access)
  const branchId = selection.branchId
  const alerts = useStockAlerts(branchId)
  const setAlert = useSetStockAlert()
  const [notice, setNotice] = useState<Notice>(null)
  const [picked, setPicked] = useState<ProductHit | null>(null)
  const [minimum, setMinimum] = useState('')

  async function write(variantId: string, minQuantity: number | null) {
    if (!branchId) return
    setNotice(null)
    try {
      await setAlert.mutateAsync({
        branch_id: branchId,
        variant_id: variantId,
        min_quantity: minQuantity,
      })
      setNotice({ text: t('saved'), failed: false })
      setPicked(null)
      setMinimum('')
    } catch (failure) {
      setNotice({ text: alertFailure(failure, t), failed: true })
    }
  }

  async function remove(alert: StockAlert) {
    if (
      !(await confirm({
        message: t('stockAlerts.confirmRemove', { name: alert.name ?? alert.sku ?? '' }),
        variant: 'destructive',
        confirmLabel: t('stockAlerts.remove'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await write(alert.variant_id, null)
  }

  const validMinimum = /^[1-9]\d{0,8}$/.test(minimum)
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('stockAlerts.title')}
        description={t('stockAlerts.intro')}
        actions={
          <div className="flex items-center gap-2">
            <BranchPicker />
            {!manage && <Badge variant="outline">{t('adminReadAccess')}</Badge>}
          </div>
        }
      />
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      {!branchId ? (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      ) : (
        <Card>
          <CardContent className="space-y-4 pt-6">
            {manage && (
              <div className="space-y-2">
                {picked ? (
                  <div className="flex flex-wrap items-end gap-3">
                    <span className="flex-1 font-medium">{picked.name}</span>
                    <div className="w-40">
                      <TopologyField label={t('stockAlerts.minQuantity')}>
                        {(id) => (
                          <Input
                            id={id}
                            inputMode="numeric"
                            value={minimum}
                            onChange={(event) => setMinimum(event.target.value.trim())}
                          />
                        )}
                      </TopologyField>
                    </div>
                    <Button
                      type="button"
                      disabled={!validMinimum || setAlert.isPending}
                      onClick={() => void write(picked.variantId, Number(minimum))}
                    >
                      {t('save')}
                    </Button>
                    <Button type="button" variant="outline" onClick={() => setPicked(null)}>
                      {t('adminCancel')}
                    </Button>
                  </div>
                ) : (
                  <ProductSearch
                    branchId={branchId}
                    label={t('stockAlerts.add')}
                    onPick={(hit) => {
                      setPicked(hit)
                      const existing = alerts.data?.find((row) => row.variant_id === hit.variantId)
                      setMinimum(existing ? String(existing.min_quantity) : '')
                    }}
                  />
                )}
              </div>
            )}
            {alerts.isPending ? (
              <p role="status">{t('contextWaiting')}</p>
            ) : alerts.isError ? (
              <p role="alert" className="text-destructive">
                {alertFailure(alerts.error, t)}
              </p>
            ) : alerts.data.length === 0 ? (
              <p className="text-muted-foreground">{t('stockAlerts.none')}</p>
            ) : (
              <ul className="divide-y" aria-label={t('stockAlerts.title')}>
                {alerts.data.map((alert) => (
                  <li key={alert.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 py-2">
                    <span className="min-w-40 flex-1 font-medium">
                      {[alert.name, alert.options_text].filter(Boolean).join(' · ')}
                      {alert.sku && (
                        <span className="ml-2 text-xs font-normal text-muted-foreground">
                          {alert.sku}
                        </span>
                      )}
                    </span>
                    <span className="tabular-nums">
                      {t('stockAlerts.levels', {
                        onHand: alert.on_hand,
                        min: alert.min_quantity,
                        unit: alert.base_unit,
                      })}
                    </span>
                    {alert.low && <Badge variant="destructive">{t('stockAlerts.low')}</Badge>}
                    {manage && (
                      <span className="ml-auto flex gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => {
                            setPicked({
                              productId: '',
                              variantId: alert.variant_id,
                              name: alert.name ?? alert.variant_id,
                            })
                            setMinimum(String(alert.min_quantity))
                          }}
                        >
                          {t('adminEdit')}
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={setAlert.isPending}
                          onClick={() => void remove(alert)}
                        >
                          {t('stockAlerts.remove')}
                        </Button>
                      </span>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
