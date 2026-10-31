# Dashboard slots catalog

Every named `<Slot>` the React dashboard renders, with the props your component receives. Source of truth: the `<Slot name="…">` call sites in `packages/dashboard/src/routes/**`, `packages/dashboard-core/src/components/page-header.tsx` / `page-tabs.tsx`, and `packages/seller-dashboard/src/pages/team.tsx`. If a slot you want isn't listed, grep the installed `@spree/dashboard` source for `<Slot` before assuming it exists.

Register with `defineDashboardPlugin({ slots: { '<name>': [{ id, component, position?, if? }] } })` or `registerSlot<Ctx>('<name>', { … })`.

**Ambient context is not wired yet.** `SlotAmbientContext` (`permissions`, `store`, `user`) exists as a type, but `<Slot>` currently passes `{}` — components receive only the slot-specific context below. Read the rest with `usePermissions()`, `useStore()`, `useAuth()`. The entry-level `if` predicate also sees only the slot context, so gate permissions inside the component.

## Page header (every page using `<PageHeader>`)

| Slot | Where | Context | Use |
|---|---|---|---|
| `page.actions` | Top-right action zone, left of the page's own `actions` | `{ resource, ...slotContext }` — `resource` is whatever the page passed to `<PageHeader resource={…}>`; `undefined` on most list pages | Primary buttons ("Send invoice", "Sync to ERP") |
| `page.actions_dropdown` | Inside the `⋯` menu, above Copy ID / Delete | same as `page.actions` | `<DropdownMenuItem>` secondary actions |

Both slots render on every page that uses `<PageHeader>`, so check the resource shape (e.g. `resource?.id?.startsWith('or_')`) or the route before rendering.

## Page tabs

| Slot | Where | Context |
|---|---|---|
| `page.tabs` (default `slotName` of `<PageTabs>`) | After the built-in tab strip | `{ tabs, ...slotContext }` — `tabs` is the built-in tab array |

`<PageTabs slotName="…">` can scope a slot to one resource; today only the default `page.tabs` is used in production.

## Detail-page form slots

"Host form: yes" means the slot renders **inside** the page's react-hook-form `<form>` — use `useHostForm()` + a `formFields` registration (form key in parentheses) so your input hydrates, dirty-tracks and saves with the page's Save button. Never render a nested `<form>` there. On "no" pages, `useHostForm()` throws — use `useOptionalHostForm()` or save through your own mutation.

| Slot | Page (route under `/$storeId`) | Context | Host form |
|---|---|---|---|
| `product.form_sidebar` | `products/$productId` (and `products/new`) — end of sidebar | `{ product }` | yes (`product`) |
| `category.form_sidebar` | `products/categories/$categoryId` — end of sidebar | `{ category }` (may be briefly `undefined` while refetching) | yes (`category`) |
| `collection.form_sidebar` | `products/collections/$collectionId` — end of sidebar | `{ collection }` | yes (`collection`) |
| `store.form_main` | `settings/store` — end of main column | `{ store }` | yes (`store`) |
| `order.form_sidebar` | `orders/$orderId` — end of sidebar | `{ order }` | no |
| `customer.form_sidebar` | `customers/$customerId` — end of sidebar | `{ customer }` | no (page edits through sheets) |
| `company.form_main` | `companies/$companyId` — end of main column | `{ company, kind, canEdit }` | no |
| `company.form_sidebar` | `companies/$companyId` — end of sidebar | `{ company, kind, canEdit }` | no |
| `seller.form_main` | `sellers/$sellerId` — end of main column | `{ seller, canEdit }` | no |
| `seller.form_sidebar` | `sellers/$sellerId` — end of sidebar | `{ seller, canEdit }` | no |

## B2B company memberships (`companies/$companyId`)

| Slot | Context | Use |
|---|---|---|
| `company_membership.row_meta` | `{ membership, companyId, canEdit }` | Extra metadata next to a member row |
| `company_membership.row_actions` | `{ membership, companyId }` | `<DropdownMenuItem>`s in a member row's menu |
| `company_membership.form_fields` | `{ companyId, onChange }` — call `onChange(extraParams)` to merge params into the invite payload | Extra fields on the add-member form (falls back to an upsell when empty) |

## Seller panel (`@spree/seller-dashboard`)

| Slot | Where | Context |
|---|---|---|
| `seller.team.actions` | Team screen header actions | `{ sellerId }` |
| `seller.team.after` | Below the team member list | `{ sellerId }` |

## Sign-in: no store access

| Slot | Where | Context |
|---|---|---|
| `no_store_access` (`NO_STORE_ACCESS_SLOT`) | Full-screen message for a signed-in admin who holds a role on no store (not yet invited, or removed from all). Registering any entry **replaces** the built-in message | `{ user, signOut }` (`NoStoreAccessSlotContext`) |

Use it to show a different call to action ("Request access", a link to your onboarding) or redirect from an effect. `GET /api/v3/admin/me` answers for such users when no `X-Spree-Store-Id` is sent.

## Dynamic, per-type editor slots

The slot name is computed from the type's wire shorthand (what `Spree::Base.api_type` returns / what the API reports as `type`). Registering against the right name replaces or augments the generated editor. These are how a backend gem that adds a payment method, promotion rule/action, price rule or setup task ships its dashboard UI.

| Slot name | Where | Context |
|---|---|---|
| `payment_method.guide.<type>` | Payment method sheet, above the preferences form | `PaymentMethodEditorContext` |
| `payment_method.form.<type>` | Replaces the auto-generated preferences form | `PaymentMethodEditorContext` |
| `payment_method.actions.<type>` | Sheet footer, before Save/Cancel ("Test connection") | `PaymentMethodEditorContext` |
| `promotion.rule_form.<type>` | Promotion rule editor (fallback: default editor) | `{ draft, onSave(next), onClose }` |
| `promotion.action_form.<type>` | Promotion action editor (fallback: default editor) | `{ draft, onSave(next), onClose }` |
| `price_list.rule_form.<type>` | Price-list rule editor (fallback: default editor) | `{ draft, onSave(next), onClose }` |
| `getting-started.task.<task_name>` | A Getting Started checklist task | `{ task, store, storeId }` |

```ts
interface PaymentMethodEditorContext {
  mode: 'create' | 'edit'
  type: string                                  // STI shorthand: 'stripe', 'bogus', …
  paymentMethod: PaymentMethod | null           // null in create mode
  preferenceSchema: PreferenceField[]
  preferences: Record<string, unknown>
  onPreferencesChange: (next: Record<string, unknown>) => void
  form: UseFormReturn<PaymentMethodFormValues>  // RHF instance for top-level fields
}
```

Only the payment-method name helpers are a public subpath export:

```ts
import {
  paymentMethodGuideSlot, paymentMethodFormSlot, paymentMethodActionsSlot,
} from '@spree/dashboard/components/spree/payment-method-editors/types'

paymentMethodFormSlot('stripe') // "payment_method.form.stripe"
```

For the promotion / price-list / setup-task slots, spell the string yourself (`` `promotion.rule_form.${type}` ``). Editors mutate `draft` locally and call `onSave(next)`; the parent persists everything in one PATCH when the page's Save is pressed.

(`promotion.rule_summary.<type>` / `promotion.action_summary.<type>` name helpers exist in the source but no page renders them yet — don't rely on them.)

## Adding a new slot

A new injection point in a built-in page is a PR to Spree: `<Slot name="<resource>.<area>" context={{ … }} />` at the call site plus a docs entry in `docs/developer/dashboard/slots-catalog.mdx`. Until then, use the nearest existing slot or a custom route.
