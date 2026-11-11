import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { Button } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { fetchCatalogPage } from '../hooks/use-catalog'
import { Input, TopologyField } from './topology-fields'

export type ProductHit = { productId: string; variantId: string; name: string }

// Finds sellable products of the branch's catalogue by name, SKU or barcode.
export function ProductSearch({
  branchId,
  onPick,
  label,
}: {
  branchId: string | null
  onPick: (hit: ProductHit) => void
  label: string
}) {
  const { t } = useTranslation()
  const [query, setQuery] = useState('')
  const [hits, setHits] = useState<ProductHit[]>([])
  const [error, setError] = useState('')
  async function search() {
    setError('')
    try {
      const page = await fetchCatalogPage(branchId, { q: query.trim(), limit: 10 })
      setHits(
        page.data.map((row) => ({ productId: row.product_id, variantId: row.id, name: row.name })),
      )
    } catch (failure) {
      setError(describeFailure(failure, t))
    }
  }
  return (
    <div className="space-y-2">
      <div className="flex items-end gap-2">
        <div className="flex-1">
          <TopologyField label={label}>
            {(id, describedBy) => (
              <Input
                id={id}
                aria-describedby={describedBy}
                value={query}
                onChange={(event) => setQuery(event.target.value)}
              />
            )}
          </TopologyField>
        </div>
        <Button
          type="button"
          variant="outline"
          disabled={!query.trim()}
          onClick={() => void search()}
        >
          {t('menuAdmin.search')}
        </Button>
      </div>
      {error && (
        <p role="alert" className="text-sm text-destructive">
          {error}
        </p>
      )}
      {hits.length > 0 && (
        <ul className="divide-y rounded border">
          {hits.map((hit) => (
            <li key={hit.variantId}>
              <button
                type="button"
                className="w-full px-3 py-2 text-left hover:bg-muted"
                onClick={() => {
                  onPick(hit)
                  setHits([])
                }}
              >
                {hit.name}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
