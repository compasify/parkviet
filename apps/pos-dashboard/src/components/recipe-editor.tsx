import { formatMoney } from '@parkviet/pos-shared/money'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosMenuModifierGroup } from '@parkviet/pos-shared/types/pos-context'
import { Badge, Button, DialogBody, DialogFooter, useConfirm } from '@spree/dashboard-ui'
import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { readUnits } from '../hooks/use-master-data'
import type { MenuItemConfig } from '../hooks/use-menu-admin'
import {
  type RecipeOwner,
  type RecipeOwnerRef,
  type RecipeRow,
  useRecipe,
  useSaveRecipe,
} from '../hooks/use-recipes'
import { useSession } from '../hooks/use-session'
import { posKey } from '../lib/query-keys'
import { PageSkeleton } from './page-skeleton'
import { ProductSearch } from './product-search'
import { TopologyDialog } from './topology-dialog'
import { Input, TopologyField, TopologySelect } from './topology-fields'

const RECIPE_REFUSALS = [
  'recipe_ingredient_tracked',
  'recipe_unit_dimension',
  'recipe_unit_unknown',
  'recipe_quantity_inexact',
  'recipe_quantity_invalid',
  'recipe_ingredient_duplicate',
  'recipe_ingredient_self',
  'recipe_rows_limit',
] as const

export function recipeFailure(error: unknown, t: (key: string) => string) {
  const reason = conflictReason(error)
  return reason && (RECIPE_REFUSALS as readonly string[]).includes(reason)
    ? t(`recipes.failure_${reason}`)
    : describeFailure(error, t)
}

type Owner = { key: string; label: string; ref: RecipeOwnerRef }
type Row = { variantId: string; name: string; quantity: string; unitCode: string }

// The recipes of one menu item: one ingredient table for each size, and one
// for each option the item offers. Quantities are entered in any unit that
// measures what the ingredient is stocked in; the server converts them.
export function RecipeEditor({
  item,
  groups,
  branchId,
  canEdit,
  onClose,
}: {
  item: MenuItemConfig
  groups: PosMenuModifierGroup[]
  branchId: string | null
  canEdit: boolean
  onClose: () => void
}) {
  const { t } = useTranslation()
  const owners: Owner[] = [
    ...item.variants.map((variant) => ({
      key: variant.id,
      label: t('recipes.sizeOwner', { name: variant.name ?? item.name }),
      ref: { variant_id: variant.id },
    })),
    ...groups
      .filter((group) => item.modifier_group_ids.includes(group.id))
      .flatMap((group) =>
        group.options.map((option) => ({
          key: option.id,
          label: t('recipes.optionOwner', { group: group.name, name: option.name }),
          ref: { modifier_option_id: option.id },
        })),
      ),
  ]
  const [ownerKey, setOwnerKey] = useState(owners[0]?.key ?? '')
  const owner = owners.find((row) => row.key === ownerKey) ?? null
  return (
    <TopologyDialog
      title={t('recipes.title')}
      subtitle={item.name}
      dirty={false}
      busy={false}
      onClose={onClose}
    >
      {(close) => (
        <div className="flex min-h-0 flex-col">
          <DialogBody className="flex-none space-y-4 pb-0">
            <p className="text-sm text-muted-foreground">{t('recipes.intro')}</p>
            <TopologyField label={t('recipes.owner')}>
              {(id) => (
                <TopologySelect
                  id={id}
                  value={ownerKey}
                  onChange={setOwnerKey}
                  options={owners.map((row) => ({ value: row.key, label: row.label }))}
                />
              )}
            </TopologyField>
          </DialogBody>
          {owner && (
            <OwnerRecipe
              key={owner.key}
              owner={owner}
              branchId={branchId}
              canEdit={canEdit}
              close={close}
            />
          )}
        </div>
      )}
    </TopologyDialog>
  )
}

function rowsOf(recipe: RecipeOwner | undefined): Row[] {
  return (recipe?.active?.ingredients ?? []).map((row) => ({
    variantId: row.variant_id,
    name: [row.name, row.options_text].filter(Boolean).join(' · ') || row.variant_id,
    quantity: row.quantity,
    unitCode: row.unit_code,
  }))
}

function OwnerRecipe({
  owner,
  branchId,
  canEdit,
  close,
}: {
  owner: Owner
  branchId: string | null
  canEdit: boolean
  close: () => void
}) {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const confirm = useConfirm()
  const recipe = useRecipe(owner.ref)
  const units = useQuery({
    queryKey: posKey(storeId, 'units', 'active'),
    queryFn: () => readUnits(false),
  })
  const saveRecipe = useSaveRecipe()
  const [rows, setRows] = useState<Row[] | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const current = rows ?? rowsOf(recipe.data)
  const unitOptions = (units.data ?? []).map((unit) => ({
    value: unit.code,
    label: `${unit.name} (${unit.code})`,
  }))
  const update = (index: number, patch: Partial<Row>) =>
    setRows(current.map((row, at) => (at === index ? { ...row, ...patch } : row)))
  const valid = current.every((row) => /^\d+(\.\d{1,4})?$/.test(row.quantity) && row.unitCode)

  async function save() {
    setNotice(null)
    const body = {
      ...owner.ref,
      ingredients: current.map(
        (row): RecipeRow => ({
          variant_id: row.variantId,
          quantity: row.quantity,
          unit_code: row.unitCode,
        }),
      ),
    }
    try {
      try {
        await saveRecipe.mutateAsync(body)
      } catch (failure) {
        if (conflictReason(failure) !== 'recipe_variant_has_stock') throw failure
        const stocked = await confirm({
          message: t('recipes.confirmWriteOff'),
          variant: 'destructive',
          confirmLabel: t('recipes.writeOff'),
          cancelLabel: t('adminCancel'),
        })
        if (!stocked) return
        await saveRecipe.mutateAsync({ ...body, confirm_stock_write_off: true })
      }
      setRows(null)
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: recipeFailure(failure, t), failed: true })
    }
  }

  if (recipe.isPending)
    return (
      <DialogBody>
        <PageSkeleton />
      </DialogBody>
    )
  if (recipe.isError)
    return (
      <DialogBody>
        <p role="alert" className="text-destructive">
          {recipeFailure(recipe.error, t)}
        </p>
      </DialogBody>
    )
  const active = recipe.data.active
  return (
    <div className="flex min-h-0 flex-col">
      <DialogBody className="space-y-4">
        <div className="flex flex-wrap items-center gap-2 text-sm">
          {active ? (
            <Badge variant="outline">{t('recipes.version', { version: active.version })}</Badge>
          ) : (
            <span className="text-muted-foreground">{t('recipes.none')}</span>
          )}
          {active && (
            <span className="text-muted-foreground">
              {active.estimated_cost == null
                ? t('recipes.costUnknown')
                : t('recipes.estimatedCost', { cost: formatMoney(active.estimated_cost) })}
            </span>
          )}
          {recipe.data.track_inventory === false && (
            <span className="text-muted-foreground">{t('recipes.madeToOrder')}</span>
          )}
        </div>
        {current.length === 0 ? (
          <p className="text-muted-foreground">{t('recipes.empty')}</p>
        ) : (
          <ul className="divide-y" aria-label={t('recipes.ingredients')}>
            {current.map((row, index) => {
              const saved = rows
                ? undefined
                : active?.ingredients.find((line) => line.variant_id === row.variantId)
              return (
                <li key={row.variantId} className="flex flex-wrap items-end gap-3 py-2">
                  <span className="min-w-40 flex-1 font-medium">
                    {row.name}
                    {saved && (
                      <span className="block text-xs font-normal text-muted-foreground">
                        {t('recipes.inStockUnit', {
                          quantity: saved.base_quantity,
                          unit: saved.base_unit,
                        })}
                        {saved.cost != null && ` · ${formatMoney(saved.cost)}`}
                      </span>
                    )}
                  </span>
                  <div className="w-28">
                    <TopologyField label={t('recipes.quantity')}>
                      {(id) => (
                        <Input
                          id={id}
                          inputMode="decimal"
                          value={row.quantity}
                          disabled={!canEdit}
                          onChange={(event) =>
                            update(index, { quantity: event.target.value.trim() })
                          }
                        />
                      )}
                    </TopologyField>
                  </div>
                  <div className="w-44">
                    <TopologyField label={t('recipes.unit')}>
                      {(id) => (
                        <TopologySelect
                          id={id}
                          value={row.unitCode}
                          disabled={!canEdit}
                          onChange={(value) => update(index, { unitCode: value })}
                          options={unitOptions}
                        />
                      )}
                    </TopologyField>
                  </div>
                  {canEdit && (
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() => setRows(current.filter((_, at) => at !== index))}
                    >
                      {t('recipes.remove')}
                    </Button>
                  )}
                </li>
              )
            })}
          </ul>
        )}
        {canEdit && (
          <ProductSearch
            branchId={branchId}
            label={t('recipes.addIngredient')}
            onPick={(hit) => {
              if (current.some((row) => row.variantId === hit.variantId)) return
              setRows([
                ...current,
                { variantId: hit.variantId, name: hit.name, quantity: '', unitCode: '' },
              ])
            }}
          />
        )}
        {notice && (
          <p
            role={notice.failed ? 'alert' : 'status'}
            className={notice.failed ? 'text-sm text-destructive' : 'text-sm text-muted-foreground'}
          >
            {notice.text}
          </p>
        )}
      </DialogBody>
      <DialogFooter>
        <Button type="button" variant="outline" onClick={close}>
          {t('adminClose')}
        </Button>
        {canEdit && (
          <Button
            type="button"
            disabled={saveRecipe.isPending || rows === null || !valid}
            onClick={() => void save()}
          >
            {t(saveRecipe.isPending ? 'waiting' : 'save')}
          </Button>
        )}
      </DialogFooter>
    </div>
  )
}
