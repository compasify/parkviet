import { describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  defineTable,
  ResourceTable,
  resourceSearchSchema,
  useResourceMutation,
} from '@spree/dashboard-core'
import { Badge, ResourceNameCell, RowActions, useConfirm } from '@spree/dashboard-ui'
import { PackageCheckIcon, PackageXIcon, TagIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { type BranchScope, useBranchScope } from '../components/branch-detail'
import { VariantUnitEditor } from '../components/variant-unit-editor'
import {
  assignBranchProduct,
  type BranchProduct,
  fetchBranchProducts,
  removeBranchProduct,
} from '../hooks/use-branch-catalog'
import { hiddenTimestamps } from '../tables/columns'

export function BranchProductsTab() {
  const scope = useBranchScope()
  return <BranchProducts key={scope.branch.id} {...scope} />
}
function BranchProducts({ branch, access, storeId }: BranchScope) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const [unitProduct, setUnitProduct] = useState<BranchProduct | null>(null)
  const mutation = useResourceMutation({
    mutationFn: async (product: BranchProduct) => {
      if (!access.write) throw Object.assign(new Error('Access denied'), { status: 403 })
      if (product.assigned) await removeBranchProduct(branch.id, product.id)
      else await assignBranchProduct(branch.id, product.id)
    },
    successMessage: false,
    errorMessage: false,
  })
  async function toggle(product: BranchProduct) {
    if (!access.write || mutation.isPending) return
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
  const tableKey = 'pos-branch-products'
  defineTable<BranchProduct>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('branchProductsSearchPlaceholder'),
    emptyMessage: t('branchProductsEmpty'),
    columns: [
      {
        key: 'name',
        label: t('adminName'),
        default: true,
        render: (product) => (
          <ResourceNameCell
            id={product.id}
            name={product.name}
            secondary={[
              product.skus.length ? product.skus.join(', ') : t('branchProductNoSku'),
              ...(product.status === 'active'
                ? []
                : [t('branchProductStatus', { status: product.status })]),
            ].join(' · ')}
          />
        ),
      },
      {
        key: 'assigned',
        label: t('adminStatus'),
        default: true,
        filterable: true,
        filterType: 'enum',
        quickFilter: true,
        filterOptions: [
          { value: 'true', label: t('branchProductsFilterAssigned') },
          { value: 'false', label: t('branchProductsFilterUnassigned') },
        ],
        render: (product) => (
          <Badge variant={product.assigned ? 'default' : 'outline'}>
            {t(product.assigned ? 'branchProductAssigned' : 'branchProductUnassigned')}
          </Badge>
        ),
      },
      ...hiddenTimestamps<BranchProduct>(),
    ],
  })
  return (
    <div className="space-y-4">
      <p className="text-sm text-muted-foreground">
        {t(access.write ? 'branchProductsHint' : 'branchProductsReadOnly')}
      </p>
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      <ResourceTable<BranchProduct>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'branch-products', branch.id, 'table']}
        queryFn={(params: Record<string, unknown>) => fetchBranchProducts(branch.id, params)}
        searchParams={searchParams}
        rowActions={(product) => (
          <RowActions
            actions={[
              {
                key: 'units',
                label: t('branchProductUnits'),
                icon: <TagIcon className="size-4" />,
                visible: product.assigned,
                onSelect: () => setUnitProduct(product),
              },
              {
                key: product.assigned ? 'remove' : 'add',
                label: t(product.assigned ? 'branchProductRemove' : 'branchProductAdd'),
                icon: product.assigned ? (
                  <PackageXIcon className="size-4" />
                ) : (
                  <PackageCheckIcon className="size-4" />
                ),
                visible: access.write,
                destructive: product.assigned,
                disabled: mutation.isPending,
                onSelect: () => void toggle(product),
              },
            ]}
          />
        )}
      />
      {unitProduct && (
        <VariantUnitEditor
          branchId={branch.id}
          storeId={storeId}
          product={unitProduct}
          canWrite={access.write}
          onClose={() => setUnitProduct(null)}
        />
      )}
    </div>
  )
}
