import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { useResourceMutation } from '@spree/dashboard-core'
import { Badge, Button, Card, CardContent, useConfirm } from '@spree/dashboard-ui'
import { useQueryClient } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchSettingsFrame, type BranchSettingsScope } from '../components/branch-settings-frame'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import { VariantUnitEditor } from '../components/variant-unit-editor'
import {
  type AssignmentFilter,
  assignBranchProduct,
  type BranchProduct,
  removeBranchProduct,
  useBranchProducts,
} from '../hooks/use-branch-catalog'
import { BranchProductsTable } from '../tables/branch-products'

export function BranchProductsPage() {
  return (
    <BranchSettingsFrame section="products">
      {(scope) => <BranchProducts key={scope.branch.id} {...scope} />}
    </BranchSettingsFrame>
  )
}
export function BranchProducts({ branch, access, storeId }: BranchSettingsScope) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const [input, setInput] = useState('')
  const [query, setQuery] = useState('')
  const [assigned, setAssigned] = useState<AssignmentFilter>('all')
  const [page, setPage] = useState(1)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const [unitProduct, setUnitProduct] = useState<BranchProduct | null>(null)
  const products = useBranchProducts(branch.id, { q: query, assigned, page }, access.read)
  const mutation = useResourceMutation({
    mutationFn: async (product: BranchProduct) => {
      if (!access.write) throw Object.assign(new Error('Access denied'), { status: 403 })
      if (product.assigned) await removeBranchProduct(branch.id, product.id)
      else await assignBranchProduct(branch.id, product.id)
    },
    successMessage: false,
    errorMessage: false,
  })
  useEffect(() => {
    const timer = window.setTimeout(() => {
      setQuery(input.trim())
      setPage(1)
    }, 300)
    return () => window.clearTimeout(timer)
  }, [input])
  const rows = products.data?.data ?? []
  const pages = Math.max(1, products.data?.meta.pages ?? 1)
  const lastPage = products.isSuccess && !products.isPlaceholderData ? pages : null
  useEffect(() => {
    if (lastPage !== null) setPage((current) => Math.min(current, lastPage))
  }, [lastPage])
  async function toggle(product: BranchProduct) {
    if (!access.write || mutation.isPending || products.isFetching) return
    if (
      product.assigned &&
      !(await confirm({
        message: t('branchProductRemoveFor', { name: product.name }),
        variant: 'destructive',
        confirmLabel: t('branchProductRemove'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await mutation.mutateAsync(product)
      setNotice({
        text: t(product.assigned ? 'branchProductRemoved' : 'branchProductAdded', {
          name: product.name,
        }),
        failed: false,
      })
    } catch (failure) {
      setNotice({
        text: t('branchProductFailed', { name: product.name, reason: describeFailure(failure, t) }),
        failed: true,
      })
    } finally {
      await Promise.all(
        ['branch-products', 'catalog'].map((resource) =>
          client.invalidateQueries({ queryKey: ['pos', storeId, resource] }),
        ),
      )
    }
  }
  return (
    <Card>
      <CardContent className="space-y-4 pt-6">
        <p>{t(access.write ? 'branchProductsHint' : 'branchProductsReadOnly')}</p>
        <form
          className="grid gap-4 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            setQuery(input.trim())
            setPage(1)
          }}
        >
          <TopologyField label={t('branchProductsSearch')}>
            {(id) => (
              <Input
                id={id}
                type="search"
                maxLength={100}
                value={input}
                placeholder={t('branchProductsSearchPlaceholder')}
                onChange={(event) => setInput(event.target.value)}
              />
            )}
          </TopologyField>
          <TopologyField label={t('branchProductsFilter')}>
            {(id) => (
              <TopologySelect
                id={id}
                value={assigned}
                onChange={(value) => {
                  setAssigned(value as AssignmentFilter)
                  setPage(1)
                }}
                options={(['all', 'assigned', 'unassigned'] as const).map((value) => ({
                  value,
                  label: t(
                    value === 'all'
                      ? 'branchProductsFilterAll'
                      : value === 'assigned'
                        ? 'branchProductsFilterAssigned'
                        : 'branchProductsFilterUnassigned',
                  ),
                }))}
              />
            )}
          </TopologyField>
        </form>
        {notice && (
          <p
            role={notice.failed ? 'alert' : 'status'}
            className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
          >
            {notice.text}
          </p>
        )}
        {products.isPending && <p role="status">{t('waiting')}</p>}
        {products.isError && (
          <div role="alert">
            <p>{describeFailure(products.error, t)}</p>
            <Button onClick={() => void products.refetch()}>{t('retry')}</Button>
          </div>
        )}
        {products.isSuccess && rows.length === 0 && (
          <div>
            <p>{t('adminNoResults')}</p>
            <p>{t('branchProductsEmpty')}</p>
          </div>
        )}
        <BranchProductsTable
          label={t('branchProductList')}
          rows={rows}
          busy={products.isFetching}
          columns={[
            {
              label: t('adminName'),
              cell: (product) => (
                <div>
                  <strong>{product.name}</strong>
                  <p>
                    {product.skus.length
                      ? `${t('itemSkuColumn')}: ${product.skus.join(', ')}`
                      : t('branchProductNoSku')}
                  </p>
                  {product.status !== 'active' && (
                    <p>{t('branchProductStatus', { status: product.status })}</p>
                  )}
                </div>
              ),
            },
            {
              label: t('adminStatus'),
              cell: (product) => (
                <Badge variant="outline">
                  {t(product.assigned ? 'branchProductAssigned' : 'branchProductUnassigned')}
                </Badge>
              ),
            },
            {
              label: t('adminEdit'),
              cell: (product) => (
                <div className="flex flex-wrap gap-2">
                  {product.assigned && (
                    <Button
                      variant="outline"
                      aria-label={t('branchProductUnitsFor', { name: product.name })}
                      onClick={() => setUnitProduct(product)}
                    >
                      {t('branchProductUnits')}
                    </Button>
                  )}
                  {access.write && (
                    <Button
                      variant={product.assigned ? 'destructive' : 'default'}
                      disabled={mutation.isPending || products.isFetching}
                      aria-label={t(
                        product.assigned ? 'branchProductRemoveFor' : 'branchProductAddFor',
                        { name: product.name },
                      )}
                      onClick={() => void toggle(product)}
                    >
                      {t(
                        mutation.isPending && mutation.variables?.id === product.id
                          ? 'waiting'
                          : product.assigned
                            ? 'branchProductRemove'
                            : 'branchProductAdd',
                      )}
                    </Button>
                  )}
                </div>
              ),
            },
          ]}
        />
        <nav
          className="flex flex-wrap items-center justify-between gap-3"
          aria-label={t('branchProductsPages')}
        >
          <Button
            variant="outline"
            disabled={page <= 1 || products.isFetching}
            onClick={() => setPage((current) => Math.max(1, current - 1))}
          >
            {t('previousPage')}
          </Button>
          <span aria-live="polite">
            {t('branchProductsPageStatus', { page, pages, count: products.data?.meta.count ?? 0 })}
          </span>
          <Button
            variant="outline"
            disabled={page >= pages || products.isFetching}
            onClick={() => setPage((current) => current + 1)}
          >
            {t('nextPage')}
          </Button>
        </nav>
        {unitProduct && (
          <VariantUnitEditor
            branchId={branch.id}
            storeId={storeId}
            product={unitProduct}
            canWrite={access.write}
            onClose={() => setUnitProduct(null)}
          />
        )}
      </CardContent>
    </Card>
  )
}
