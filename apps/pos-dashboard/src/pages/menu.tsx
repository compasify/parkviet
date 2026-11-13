import { formatMoney } from '@parkviet/pos-shared/money'
import { conflictReason, describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosMenuCategory, PosMenuModifierGroup } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import {
  ActiveBadge,
  Badge,
  Button,
  Checkbox,
  DialogFooter,
  Field,
  FieldLabel,
  useConfirm,
} from '@spree/dashboard-ui'
import { BookOpenIcon } from '@spree/dashboard-ui/icons'
import { type ReactNode, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { type ProductHit, ProductSearch } from '../components/product-search'
import { RecipeEditor } from '../components/recipe-editor'
import { ModelCard } from '../components/setup/model-ui'
import { TopologyDialog } from '../components/topology-dialog'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import {
  type MenuItemConfig,
  type MenuSchedule,
  type MenuTaxDefaults,
  useBranchMenu,
  useMenuCategories,
  useMenuItems,
  useMenuSchedules,
  useMenuTaxDefaults,
  useMenuWrite,
  useModifierGroups,
} from '../hooks/use-menu-admin'
import { usePosSession } from '../hooks/use-pos-session'
import {
  canManageMenu,
  canManageRecipes,
  canSetSoldOut,
  type PosAccess,
  runsRecipes,
} from '../lib/pos-access'

type Notice = { text: string; failed: boolean } | null
type Save = (method: string, path: string, body?: unknown) => Promise<void>

const MENU_REFUSALS = [
  'combo_empty',
  'menu_schedule_days_invalid',
  'menu_favorites_limit',
  'menu_favorites_duplicate',
] as const

function menuFailure(error: unknown, t: (key: string) => string) {
  const reason = conflictReason(error)
  return reason && (MENU_REFUSALS as readonly string[]).includes(reason)
    ? t(`menuAdmin.failure_${reason}`)
    : describeFailure(error, t)
}

// The store's menu: categories, items (an existing product each), option
// groups, combos and time-of-day menus; and for the selected branch its
// favourites row and today's sold-out marks.
export function MenuPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const { context, selection } = usePosSession()
  const { permissionKeys } = usePermissions()
  const access: PosAccess = { permissionKeys, context: context.data }
  const manage = canManageMenu(access)
  const soldOut = canSetSoldOut(access)
  const editRecipes = canManageRecipes(access)
  // Menu managers read the recipes; inventory managers change them.
  const recipes = runsRecipes(access) && (manage || editRecipes)
  const categories = useMenuCategories(true)
  const items = useMenuItems(true)
  const groups = useModifierGroups(true)
  const schedules = useMenuSchedules(true)
  const branchMenu = useBranchMenu(selection.branchId)
  const write = useMenuWrite()
  const [notice, setNotice] = useState<Notice>(null)
  const [dialog, setDialog] = useState<ReactNode>(null)

  const save: Save = async (method, path, body) => {
    await write.mutateAsync({ method, path, body })
    setNotice({ text: t('saved'), failed: false })
  }
  async function run(action: () => Promise<void>) {
    setNotice(null)
    try {
      await action()
    } catch (failure) {
      setNotice({ text: menuFailure(failure, t), failed: true })
    }
  }
  async function remove(path: string, name: string) {
    if (
      !(await confirm({
        message: t('menuAdmin.confirmDelete', { name }),
        variant: 'destructive',
        confirmLabel: t('menuAdmin.delete'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    await run(() => save('DELETE', path))
  }
  const close = () => setDialog(null)
  const categoryRows = categories.data ?? []
  const itemRows = items.data ?? []
  const groupRows = groups.data ?? []
  const loading = [categories, items, groups, schedules].find((query) => query.isError)

  return (
    <div className="space-y-6">
      <PageHeader
        title={t('menuAdmin.title')}
        description={t('menuAdmin.intro')}
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
      {loading?.error && (
        <div role="alert" className="text-destructive">
          {menuFailure(loading.error, t)}{' '}
          <Button variant="outline" onClick={() => void loading.refetch()}>
            {t('retry')}
          </Button>
        </div>
      )}

      <Section
        title={t('menuAdmin.categories')}
        action={
          manage && (
            <Button
              disabled={write.isPending}
              onClick={() => setDialog(<CategoryDialog save={save} onClose={close} />)}
            >
              {t('menuAdmin.addCategory')}
            </Button>
          )
        }
      >
        <Rows
          empty={t('menuAdmin.none')}
          rows={categoryRows.map((category) => ({
            id: category.id,
            cells: [
              <span key="name" className="font-medium">
                {category.color && (
                  <span
                    aria-hidden="true"
                    className="mr-2 inline-block size-3 rounded-full align-middle"
                    style={{ background: category.color }}
                  />
                )}
                {category.name}
              </span>,
              <ActiveBadge
                key="active"
                active={category.active}
                activeLabel={t('statusActive')}
                inactiveLabel={t('statusDisabled')}
              />,
            ],
            actions: manage && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setDialog(<CategoryDialog category={category} save={save} onClose={close} />)
                  }
                >
                  {t('adminEdit')}
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => void remove(`/pos/menu_categories/${category.id}`, category.name)}
                >
                  {t('menuAdmin.delete')}
                </Button>
              </>
            ),
          }))}
        />
      </Section>

      <Section
        title={t('menuAdmin.items')}
        action={
          manage && (
            <Button
              disabled={write.isPending || !selection.branchId}
              onClick={() =>
                setDialog(
                  <ItemDialog
                    branchId={selection.branchId}
                    categories={categoryRows}
                    groups={groupRows}
                    save={save}
                    onClose={close}
                  />,
                )
              }
            >
              {t('menuAdmin.addItem')}
            </Button>
          )
        }
      >
        <Rows
          empty={t('menuAdmin.none')}
          rows={itemRows.map((item) => ({
            id: item.id,
            cells: [
              <span key="name" className="font-medium">
                {item.name}
                {item.kind === 'combo' && (
                  <Badge variant="outline" className="ml-2">
                    {t('menuAdmin.combo')}
                  </Badge>
                )}
              </span>,
              <span key="category" className="text-muted-foreground">
                {categoryRows.find((row) => row.id === item.menu_category_id)?.name ?? '—'}
              </span>,
              <span key="groups" className="text-muted-foreground">
                {item.kind === 'combo'
                  ? item.components.map((row) => `${row.name} ×${row.quantity}`).join(', ')
                  : item.modifier_group_ids
                      .map((id) => groupRows.find((row) => row.id === id)?.name)
                      .filter(Boolean)
                      .join(', ') || '—'}
              </span>,
              <span key="kitchen" className="text-muted-foreground">
                {item.kitchen_category ?? '—'}
              </span>,
              <ActiveBadge
                key="active"
                active={item.active}
                activeLabel={t('statusActive')}
                inactiveLabel={t('statusDisabled')}
              />,
            ],
            actions: (manage || recipes) && (
              <>
                {recipes && item.kind !== 'combo' && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() =>
                      setDialog(
                        <RecipeEditor
                          item={item}
                          groups={groupRows}
                          branchId={selection.branchId}
                          canEdit={editRecipes}
                          onClose={close}
                        />,
                      )
                    }
                  >
                    {t('recipes.open')}
                  </Button>
                )}
                {manage && (
                  <>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        setDialog(
                          <ItemDialog
                            item={item}
                            branchId={selection.branchId}
                            categories={categoryRows}
                            groups={groupRows}
                            save={save}
                            onClose={close}
                          />,
                        )
                      }
                    >
                      {t('adminEdit')}
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => void remove(`/pos/menu_items/${item.id}`, item.name)}
                    >
                      {t('menuAdmin.delete')}
                    </Button>
                  </>
                )}
              </>
            ),
          }))}
        />
      </Section>

      <Section
        title={t('menuAdmin.groups')}
        action={
          manage && (
            <Button
              disabled={write.isPending}
              onClick={() => setDialog(<GroupDialog save={save} onClose={close} />)}
            >
              {t('menuAdmin.addGroup')}
            </Button>
          )
        }
      >
        <Rows
          empty={t('menuAdmin.none')}
          rows={groupRows.map((group) => ({
            id: group.id,
            cells: [
              <span key="name" className="font-medium">
                {group.name}
              </span>,
              <span key="range" className="text-muted-foreground">
                {t('menuAdmin.range', { min: group.min_select, max: group.max_select })}
              </span>,
              <span key="options" className="text-muted-foreground">
                {group.options
                  .filter((option) => option.active)
                  .map((option) =>
                    Number(option.price_delta) === 0
                      ? option.name
                      : `${option.name} (+${formatMoney(option.price_delta)})`,
                  )
                  .join(', ')}
              </span>,
            ],
            actions: manage && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setDialog(<GroupDialog group={group} save={save} onClose={close} />)
                  }
                >
                  {t('adminEdit')}
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => void remove(`/pos/modifier_groups/${group.id}`, group.name)}
                >
                  {t('menuAdmin.delete')}
                </Button>
              </>
            ),
          }))}
        />
      </Section>

      <Section
        title={t('menuAdmin.schedules')}
        action={
          manage && (
            <Button
              disabled={write.isPending}
              onClick={() =>
                setDialog(<ScheduleDialog items={itemRows} save={save} onClose={close} />)
              }
            >
              {t('menuAdmin.addSchedule')}
            </Button>
          )
        }
      >
        <Rows
          empty={t('menuAdmin.none')}
          rows={(schedules.data ?? []).map((schedule) => ({
            id: schedule.id,
            cells: [
              <span key="name" className="font-medium">
                {schedule.name}
              </span>,
              <span key="window" className="text-muted-foreground tabular-nums">
                {schedule.starts_at}–{schedule.ends_at} ·{' '}
                {schedule.days_of_week.length === 0
                  ? t('menuAdmin.everyDay')
                  : schedule.days_of_week.map((day) => t(`menuAdmin.day_${day}`)).join(', ')}
              </span>,
              <span key="items" className="text-muted-foreground">
                {t('menuAdmin.scheduleItems', { count: schedule.items.length })}
              </span>,
            ],
            actions: manage && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setDialog(
                      <ScheduleDialog
                        schedule={schedule}
                        items={itemRows}
                        save={save}
                        onClose={close}
                      />,
                    )
                  }
                >
                  {t('adminEdit')}
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => void remove(`/pos/menu_schedules/${schedule.id}`, schedule.name)}
                >
                  {t('menuAdmin.delete')}
                </Button>
              </>
            ),
          }))}
        />
      </Section>

      <Section title={t('menuAdmin.branchTitle')}>
        {branchMenu.isPending && <p role="status">{t('contextWaiting')}</p>}
        {branchMenu.isError && (
          <p role="alert" className="text-destructive">
            {menuFailure(branchMenu.error, t)}
          </p>
        )}
        {branchMenu.data && (
          <BranchMenu
            menu={branchMenu.data.items.map((item) => ({
              id: item.id,
              name: item.name,
              soldOut: item.sold_out,
            }))}
            favorites={branchMenu.data.favorites}
            canFavorite={manage}
            canSoldOut={soldOut}
            busy={write.isPending}
            onFavorites={(ids) =>
              run(() =>
                save('PUT', '/pos/menu_favorites', {
                  branch_id: selection.branchId,
                  menu_item_ids: ids,
                }),
              )
            }
            onSoldOut={(id, value) =>
              run(() =>
                save('PUT', '/pos/menu_availabilities', {
                  branch_id: selection.branchId,
                  menu_item_id: id,
                  sold_out: value,
                }),
              )
            }
          />
        )}
      </Section>
      {dialog}
    </div>
  )
}

function Section({
  title,
  action,
  children,
}: {
  title: string
  action?: ReactNode
  children: ReactNode
}) {
  const id = useId()
  return (
    <ModelCard title={title} id={id} icon={<BookOpenIcon />} action={action}>
      {children}
    </ModelCard>
  )
}

function Rows({
  rows,
  empty,
}: {
  rows: { id: string; cells: ReactNode[]; actions?: ReactNode }[]
  empty: string
}) {
  if (rows.length === 0) return <p className="text-muted-foreground">{empty}</p>
  return (
    <ul className="divide-y">
      {rows.map((row) => (
        <li key={row.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 py-2">
          {row.cells}
          {row.actions && <span className="ml-auto flex gap-2">{row.actions}</span>}
        </li>
      ))}
    </ul>
  )
}

function useDialogSubmit(onClose: () => void) {
  const { t } = useTranslation()
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  async function submit(action: () => Promise<void>) {
    setBusy(true)
    setError('')
    try {
      await action()
      onClose()
    } catch (failure) {
      setError(menuFailure(failure, t))
    } finally {
      setBusy(false)
    }
  }
  return { busy, error, submit }
}

function DialogActions({
  busy,
  error,
  close,
  disabled,
}: {
  busy: boolean
  error: string
  close: () => void
  disabled?: boolean
}) {
  const { t } = useTranslation()
  return (
    <>
      {error && (
        <p role="alert" className="text-sm text-destructive">
          {error}
        </p>
      )}
      <DialogFooter>
        <Button type="button" variant="outline" disabled={busy} onClick={close}>
          {t('adminCancel')}
        </Button>
        <Button type="submit" disabled={busy || disabled}>
          {t(busy ? 'waiting' : 'save')}
        </Button>
      </DialogFooter>
    </>
  )
}

function TextField({
  label,
  value,
  onChange,
  hint,
  maxLength,
  inputMode,
  type,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  hint?: string
  maxLength?: number
  inputMode?: 'numeric' | 'text'
  type?: string
}) {
  return (
    <TopologyField label={label} hint={hint}>
      {(id, describedBy) => (
        <Input
          id={id}
          aria-describedby={describedBy}
          value={value}
          maxLength={maxLength}
          inputMode={inputMode}
          type={type}
          onChange={(event) => onChange(event.target.value)}
        />
      )}
    </TopologyField>
  )
}

function CheckField({
  label,
  checked,
  onChange,
}: {
  label: string
  checked: boolean
  onChange: (checked: boolean) => void
}) {
  const id = useId()
  return (
    <Field orientation="horizontal">
      <Checkbox id={id} checked={checked} onCheckedChange={(value) => onChange(value === true)} />
      <FieldLabel htmlFor={id}>{label}</FieldLabel>
    </Field>
  )
}

function CategoryDialog({
  category,
  save,
  onClose,
}: {
  category?: PosMenuCategory
  save: Save
  onClose: () => void
}) {
  const { t } = useTranslation()
  const [name, setName] = useState(category?.name ?? '')
  const [position, setPosition] = useState(String(category?.position ?? 0))
  const [color, setColor] = useState(category?.color ?? '')
  const [active, setActive] = useState(category?.active ?? true)
  const { busy, error, submit } = useDialogSubmit(onClose)
  return (
    <TopologyDialog
      title={t(category ? 'menuAdmin.editCategory' : 'menuAdmin.addCategory')}
      subtitle={category?.name}
      dirty
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit(() =>
              save(
                category ? 'PATCH' : 'POST',
                `/pos/menu_categories${category ? `/${category.id}` : ''}`,
                {
                  name: name.trim(),
                  position: Number(position) || 0,
                  color: color.trim() || null,
                  active,
                },
              ),
            )
          }}
        >
          <TextField label={t('adminName')} value={name} onChange={setName} maxLength={80} />
          <div className="grid gap-4 sm:grid-cols-2">
            <TextField
              label={t('menuAdmin.position')}
              value={position}
              onChange={setPosition}
              inputMode="numeric"
            />
            <TextField
              label={t('menuAdmin.color')}
              value={color}
              onChange={setColor}
              hint="#7b4a2e"
              maxLength={7}
            />
          </div>
          <CheckField label={t('statusActive')} checked={active} onChange={setActive} />
          <DialogActions busy={busy} error={error} close={close} disabled={!name.trim()} />
        </form>
      )}
    </TopologyDialog>
  )
}

function ItemDialog({
  item,
  branchId,
  categories,
  groups,
  save,
  onClose,
}: {
  item?: MenuItemConfig
  branchId: string | null
  categories: PosMenuCategory[]
  groups: PosMenuModifierGroup[]
  save: Save
  onClose: () => void
}) {
  const { t } = useTranslation()
  const [product, setProduct] = useState<ProductHit | null>(null)
  const [kind, setKind] = useState<'single' | 'combo'>(item?.kind ?? 'single')
  const [categoryId, setCategoryId] = useState(item?.menu_category_id ?? '')
  const [kitchen, setKitchen] = useState(item?.kitchen_category ?? '')
  const [cupLabel, setCupLabel] = useState(item?.cup_label === true)
  const [qrOrderable, setQrOrderable] = useState(item?.qr_orderable !== false)
  const [drinkCredit, setDrinkCredit] = useState(item?.drink_credit?.replace(/\.0+$/, '') ?? '')
  const [creditCategories, setCreditCategories] = useState(
    (item?.drink_credit_categories ?? []).join(', '),
  )
  const creditValid = drinkCredit.trim() === '' || /^[1-9]\d*$/.test(drinkCredit.trim())
  const taxDefaults = useMenuTaxDefaults(true).data
  const initialTax = item?.tax_category_id ?? ''
  const [tax, setTax] = useState(initialTax)
  const taxOptions = taxChoices(t, taxDefaults, initialTax)
  const [active, setActive] = useState(item?.active ?? true)
  const [groupIds, setGroupIds] = useState<string[]>(item?.modifier_group_ids ?? [])
  const [components, setComponents] = useState(
    (item?.components ?? []).map((row) => ({
      variantId: row.variant_id,
      name: row.name,
      quantity: String(row.quantity),
    })),
  )
  const { busy, error, submit } = useDialogSubmit(onClose)
  const ready = (item || product) && (kind === 'single' || components.length > 0) && creditValid
  return (
    <TopologyDialog
      title={t(item ? 'menuAdmin.editItem' : 'menuAdmin.addItem')}
      subtitle={item?.name ?? product?.name}
      dirty
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit(() =>
              save(item ? 'PATCH' : 'POST', `/pos/menu_items${item ? `/${item.id}` : ''}`, {
                ...(item ? {} : { product_id: product?.productId }),
                kind,
                menu_category_id: categoryId || null,
                kitchen_category: kitchen.trim() || null,
                cup_label: cupLabel,
                qr_orderable: qrOrderable,
                drink_credit: drinkCredit.trim() || null,
                drink_credit_categories: creditCategories
                  .split(',')
                  .map((value) => value.trim())
                  .filter(Boolean),
                ...(tax !== initialTax ? { tax_category_id: tax || null } : {}),
                active,
                modifier_group_ids: kind === 'single' ? groupIds : [],
                ...(kind === 'combo'
                  ? {
                      components: components.map((row) => ({
                        variant_id: row.variantId,
                        quantity: Number(row.quantity) || 1,
                      })),
                    }
                  : item?.kind === 'combo'
                    ? { components: [] }
                    : {}),
              }),
            )
          }}
        >
          {!item && (
            <>
              <ProductSearch
                branchId={branchId}
                label={t('menuAdmin.product')}
                onPick={setProduct}
              />
              {product && (
                <p className="text-sm">{t('menuAdmin.productPicked', { name: product.name })}</p>
              )}
              <p className="text-sm text-muted-foreground">{t('menuAdmin.productHint')}</p>
            </>
          )}
          <div className="grid gap-4 sm:grid-cols-2">
            <TopologyField label={t('menuAdmin.kind')}>
              {(id) => (
                <TopologySelect
                  id={id}
                  value={kind}
                  options={[
                    { value: 'single', label: t('menuAdmin.single') },
                    { value: 'combo', label: t('menuAdmin.combo') },
                  ]}
                  onChange={(value) => setKind(value === 'combo' ? 'combo' : 'single')}
                />
              )}
            </TopologyField>
            <TopologyField label={t('menuAdmin.category')}>
              {(id) => (
                <TopologySelect
                  id={id}
                  value={categoryId}
                  options={[
                    { value: '', label: t('menuAdmin.noCategory') },
                    ...categories.map((row) => ({ value: row.id, label: row.name })),
                  ]}
                  onChange={setCategoryId}
                />
              )}
            </TopologyField>
            <TextField
              label={t('menuAdmin.kitchen')}
              hint={t('menuAdmin.kitchenHint')}
              value={kitchen}
              onChange={setKitchen}
              maxLength={40}
            />
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <TextField
              label={t('menuAdmin.drinkCredit')}
              hint={t(creditValid ? 'menuAdmin.drinkCreditHint' : 'menuAdmin.drinkCreditInvalid')}
              value={drinkCredit}
              onChange={setDrinkCredit}
              maxLength={12}
            />
            <TextField
              label={t('menuAdmin.drinkCreditCategories')}
              hint={t('menuAdmin.drinkCreditCategoriesHint')}
              value={creditCategories}
              onChange={setCreditCategories}
              maxLength={200}
            />
          </div>
          {taxOptions.length > 1 ? (
            <TopologyField label={t('menuAdmin.tax')}>
              {(id) => (
                <TopologySelect id={id} value={tax} options={taxOptions} onChange={setTax} />
              )}
            </TopologyField>
          ) : null}
          <CheckField label={t('menuAdmin.cupLabel')} checked={cupLabel} onChange={setCupLabel} />
          <CheckField
            label={t('menuAdmin.qrOrderable')}
            checked={qrOrderable}
            onChange={setQrOrderable}
          />
          {kind === 'single' ? (
            <fieldset className="space-y-2">
              <legend className="text-sm font-medium">{t('menuAdmin.groups')}</legend>
              {groups.length === 0 && (
                <p className="text-sm text-muted-foreground">{t('menuAdmin.none')}</p>
              )}
              {groups.map((group) => (
                <CheckField
                  key={group.id}
                  label={group.name}
                  checked={groupIds.includes(group.id)}
                  onChange={(checked) =>
                    setGroupIds((current) =>
                      checked ? [...current, group.id] : current.filter((id) => id !== group.id),
                    )
                  }
                />
              ))}
            </fieldset>
          ) : (
            <fieldset className="space-y-2">
              <legend className="text-sm font-medium">{t('menuAdmin.components')}</legend>
              {components.map((row, index) => (
                <div key={row.variantId} className="flex items-end gap-2">
                  <span className="flex-1 pb-2">{row.name}</span>
                  <TextField
                    label={t('menuAdmin.quantity')}
                    value={row.quantity}
                    inputMode="numeric"
                    onChange={(value) =>
                      setComponents((current) =>
                        current.map((entry, at) =>
                          at === index ? { ...entry, quantity: value } : entry,
                        ),
                      )
                    }
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() =>
                      setComponents((current) => current.filter((_, at) => at !== index))
                    }
                  >
                    {t('menuAdmin.delete')}
                  </Button>
                </div>
              ))}
              <ProductSearch
                branchId={branchId}
                label={t('menuAdmin.addComponent')}
                onPick={(hit) =>
                  setComponents((current) =>
                    current.some((row) => row.variantId === hit.variantId)
                      ? current
                      : [...current, { variantId: hit.variantId, name: hit.name, quantity: '1' }],
                  )
                }
              />
            </fieldset>
          )}
          <CheckField label={t('statusActive')} checked={active} onChange={setActive} />
          <DialogActions busy={busy} error={error} close={close} disabled={!ready} />
        </form>
      )}
    </TopologyDialog>
  )
}

type OptionDraft = { id?: string; name: string; price_delta: string; default_selected: boolean }

function GroupDialog({
  group,
  save,
  onClose,
}: {
  group?: PosMenuModifierGroup
  save: Save
  onClose: () => void
}) {
  const { t } = useTranslation()
  const [name, setName] = useState(group?.name ?? '')
  const [min, setMin] = useState(String(group?.min_select ?? 0))
  const [max, setMax] = useState(String(group?.max_select ?? 1))
  const [allowQuantity, setAllowQuantity] = useState(group?.allow_quantity ?? false)
  const [options, setOptions] = useState<OptionDraft[]>(
    (group?.options ?? [])
      .filter((option) => option.active)
      .map((option) => ({
        id: option.id,
        name: option.name,
        price_delta: option.price_delta.replace(/\.0+$/, ''),
        default_selected: option.default_selected,
      })),
  )
  const { busy, error, submit } = useDialogSubmit(onClose)
  const minValue = Number(min)
  const maxValue = Number(max)
  const valid =
    name.trim() &&
    Number.isInteger(minValue) &&
    Number.isInteger(maxValue) &&
    minValue >= 0 &&
    maxValue >= 1 &&
    minValue <= maxValue &&
    options.length > 0 &&
    options.every((option) => option.name.trim() && /^-?\d+(\.\d+)?$/.test(option.price_delta))
  const update = (index: number, change: Partial<OptionDraft>) =>
    setOptions((current) => current.map((row, at) => (at === index ? { ...row, ...change } : row)))
  return (
    <TopologyDialog
      title={t(group ? 'menuAdmin.editGroup' : 'menuAdmin.addGroup')}
      subtitle={group?.name}
      dirty
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit(() =>
              save(group ? 'PATCH' : 'POST', `/pos/modifier_groups${group ? `/${group.id}` : ''}`, {
                name: name.trim(),
                min_select: minValue,
                max_select: maxValue,
                allow_quantity: allowQuantity,
                options: options.map((option, position) => ({
                  ...option,
                  name: option.name.trim(),
                  position,
                })),
              }),
            )
          }}
        >
          <TextField label={t('adminName')} value={name} onChange={setName} maxLength={80} />
          <div className="grid gap-4 sm:grid-cols-2">
            <TextField
              label={t('menuAdmin.min')}
              hint={t('menuAdmin.minHint')}
              value={min}
              onChange={setMin}
              inputMode="numeric"
            />
            <TextField
              label={t('menuAdmin.max')}
              value={max}
              onChange={setMax}
              inputMode="numeric"
            />
          </div>
          <CheckField
            label={t('menuAdmin.allowQuantity')}
            checked={allowQuantity}
            onChange={setAllowQuantity}
          />
          <fieldset className="space-y-2">
            <legend className="text-sm font-medium">{t('menuAdmin.options')}</legend>
            {options.map((option, index) => (
              <div key={option.id ?? `new-${index}`} className="flex flex-wrap items-end gap-2">
                <div className="flex-1">
                  <TextField
                    label={t('adminName')}
                    value={option.name}
                    maxLength={80}
                    onChange={(value) => update(index, { name: value })}
                  />
                </div>
                <TextField
                  label={t('menuAdmin.priceDelta')}
                  value={option.price_delta}
                  inputMode="numeric"
                  onChange={(value) => update(index, { price_delta: value })}
                />
                <CheckField
                  label={t('menuAdmin.default')}
                  checked={option.default_selected}
                  onChange={(checked) => update(index, { default_selected: checked })}
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setOptions((current) => current.filter((_, at) => at !== index))}
                >
                  {t('menuAdmin.delete')}
                </Button>
              </div>
            ))}
            <Button
              type="button"
              variant="outline"
              onClick={() =>
                setOptions((current) => [
                  ...current,
                  { name: '', price_delta: '0', default_selected: false },
                ])
              }
            >
              {t('menuAdmin.addOption')}
            </Button>
          </fieldset>
          <DialogActions busy={busy} error={error} close={close} disabled={!valid} />
        </form>
      )}
    </TopologyDialog>
  )
}

const DAYS = [1, 2, 3, 4, 5, 6, 0] as const

function ScheduleDialog({
  schedule,
  items,
  save,
  onClose,
}: {
  schedule?: MenuSchedule
  items: MenuItemConfig[]
  save: Save
  onClose: () => void
}) {
  const { t } = useTranslation()
  const [name, setName] = useState(schedule?.name ?? '')
  const [label, setLabel] = useState(schedule?.label ?? '')
  const [startsAt, setStartsAt] = useState(schedule?.starts_at ?? '14:00')
  const [endsAt, setEndsAt] = useState(schedule?.ends_at ?? '16:00')
  const [days, setDays] = useState<number[]>(schedule?.days_of_week ?? [])
  const [active, setActive] = useState(schedule?.active ?? true)
  const [rows, setRows] = useState(
    (schedule?.items ?? []).map((row) => ({
      menuItemId: row.menu_item_id,
      price: row.price?.replace(/\.0+$/, '') ?? '',
      hidden: row.hidden,
    })),
  )
  const { busy, error, submit } = useDialogSubmit(onClose)
  const valid =
    name.trim() &&
    /^\d{2}:\d{2}$/.test(startsAt) &&
    /^\d{2}:\d{2}$/.test(endsAt) &&
    startsAt !== endsAt &&
    rows.every((row) => row.hidden || /^\d+$/.test(row.price))
  const unused = items.filter((item) => !rows.some((row) => row.menuItemId === item.id))
  return (
    <TopologyDialog
      title={t(schedule ? 'menuAdmin.editSchedule' : 'menuAdmin.addSchedule')}
      subtitle={schedule?.name}
      dirty
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form
          className="space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submit(() =>
              save(
                schedule ? 'PATCH' : 'POST',
                `/pos/menu_schedules${schedule ? `/${schedule.id}` : ''}`,
                {
                  name: name.trim(),
                  label: label.trim() || null,
                  starts_at: startsAt,
                  ends_at: endsAt,
                  days_of_week: days,
                  active,
                  items: rows.map((row) => ({
                    menu_item_id: row.menuItemId,
                    hidden: row.hidden,
                    price: row.hidden ? null : row.price,
                  })),
                },
              ),
            )
          }}
        >
          <TextField label={t('adminName')} value={name} onChange={setName} maxLength={80} />
          <TextField
            label={t('menuAdmin.scheduleLabel')}
            hint={t('menuAdmin.scheduleLabelHint')}
            value={label}
            onChange={setLabel}
            maxLength={40}
          />
          <div className="grid gap-4 sm:grid-cols-2">
            <TextField
              label={t('menuAdmin.startsAt')}
              value={startsAt}
              onChange={setStartsAt}
              type="time"
            />
            <TextField
              label={t('menuAdmin.endsAt')}
              hint={t('menuAdmin.endsAtHint')}
              value={endsAt}
              onChange={setEndsAt}
              type="time"
            />
          </div>
          <fieldset className="flex flex-wrap gap-3">
            <legend className="mb-1 text-sm font-medium">{t('menuAdmin.days')}</legend>
            {DAYS.map((day) => (
              <CheckField
                key={day}
                label={t(`menuAdmin.day_${day}`)}
                checked={days.includes(day)}
                onChange={(checked) =>
                  setDays((current) =>
                    checked ? [...current, day] : current.filter((value) => value !== day),
                  )
                }
              />
            ))}
          </fieldset>
          <p className="text-sm text-muted-foreground">{t('menuAdmin.daysHint')}</p>
          <fieldset className="space-y-2">
            <legend className="text-sm font-medium">{t('menuAdmin.scheduleItemsTitle')}</legend>
            {rows.map((row, index) => (
              <div key={row.menuItemId} className="flex flex-wrap items-end gap-2">
                <span className="flex-1 pb-2">
                  {items.find((item) => item.id === row.menuItemId)?.name ?? row.menuItemId}
                </span>
                {!row.hidden && (
                  <TextField
                    label={t('menuAdmin.price')}
                    value={row.price}
                    inputMode="numeric"
                    onChange={(value) =>
                      setRows((current) =>
                        current.map((entry, at) =>
                          at === index ? { ...entry, price: value } : entry,
                        ),
                      )
                    }
                  />
                )}
                <CheckField
                  label={t('menuAdmin.hidden')}
                  checked={row.hidden}
                  onChange={(checked) =>
                    setRows((current) =>
                      current.map((entry, at) =>
                        at === index ? { ...entry, hidden: checked } : entry,
                      ),
                    )
                  }
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setRows((current) => current.filter((_, at) => at !== index))}
                >
                  {t('menuAdmin.delete')}
                </Button>
              </div>
            ))}
            {unused.length > 0 && (
              <TopologyField label={t('menuAdmin.addScheduleItem')}>
                {(id) => (
                  <TopologySelect
                    id={id}
                    value=""
                    options={[
                      { value: '', label: '—' },
                      ...unused.map((item) => ({ value: item.id, label: item.name })),
                    ]}
                    onChange={(value) => {
                      if (value)
                        setRows((current) => [
                          ...current,
                          { menuItemId: value, price: '', hidden: false },
                        ])
                    }}
                  />
                )}
              </TopologyField>
            )}
          </fieldset>
          <CheckField label={t('statusActive')} checked={active} onChange={setActive} />
          <DialogActions busy={busy} error={error} close={close} disabled={!valid} />
        </form>
      )}
    </TopologyDialog>
  )
}

// The selected branch: its favourites row (in order) and today's sold-out marks.
function BranchMenu({
  menu,
  favorites,
  canFavorite,
  canSoldOut,
  busy,
  onFavorites,
  onSoldOut,
}: {
  menu: { id: string; name: string; soldOut: boolean }[]
  favorites: string[]
  canFavorite: boolean
  canSoldOut: boolean
  busy: boolean
  onFavorites: (ids: string[]) => Promise<void>
  onSoldOut: (id: string, soldOut: boolean) => Promise<void>
}) {
  const { t } = useTranslation()
  if (menu.length === 0) return <p className="text-muted-foreground">{t('menuAdmin.none')}</p>
  return (
    <ul className="divide-y">
      {menu.map((item) => {
        const favorite = favorites.includes(item.id)
        return (
          <li key={item.id} className="flex flex-wrap items-center gap-3 py-2">
            <span className="flex-1 font-medium">{item.name}</span>
            {favorite && (
              <Badge variant="outline">
                {t('menuAdmin.favoriteAt', { position: favorites.indexOf(item.id) + 1 })}
              </Badge>
            )}
            {item.soldOut && <Badge variant="destructive">{t('menuAdmin.soldOut')}</Badge>}
            {canFavorite && (
              <Button
                variant="outline"
                size="sm"
                disabled={busy}
                onClick={() =>
                  void onFavorites(
                    favorite ? favorites.filter((id) => id !== item.id) : [...favorites, item.id],
                  )
                }
              >
                {t(favorite ? 'menuAdmin.unfavorite' : 'menuAdmin.favorite')}
              </Button>
            )}
            {canSoldOut && (
              <Button
                variant="outline"
                size="sm"
                disabled={busy}
                onClick={() => void onSoldOut(item.id, !item.soldOut)}
              >
                {t(item.soldOut ? 'menuAdmin.backOnSale' : 'menuAdmin.markSoldOut')}
              </Button>
            )}
          </li>
        )
      })}
    </ul>
  )
}

// The tax choices of an item: the store's food and alcohol defaults from the
// F&B setup, the item's own category when it is neither, and "not set" (a new
// item then takes the food default).
function taxChoices(
  t: (key: string) => string,
  defaults: MenuTaxDefaults | undefined,
  current: string,
) {
  const options = [{ value: '', label: t('menuAdmin.taxUnset') }]
  if (defaults?.food) options.push({ value: defaults.food, label: t('menuAdmin.taxFood') })
  if (defaults?.alcohol && defaults.alcohol !== defaults.food)
    options.push({ value: defaults.alcohol, label: t('menuAdmin.taxAlcohol') })
  if (current && !options.some((row) => row.value === current))
    options.push({ value: current, label: t('menuAdmin.taxOther') })
  return options
}
