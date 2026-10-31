# Dashboard public import surface

Host apps import **everything** from `@spree/dashboard` (it re-exports `@spree/dashboard-core` and `@spree/dashboard-ui`). Distributed plugins import from `@spree/dashboard-core` + `@spree/dashboard-ui` directly and never from `@spree/dashboard`. Treat anything not listed here as internal, and never deep-import `…/src/…` paths. Canonical lists: `packages/dashboard-core/src/index.ts`, `packages/dashboard-ui/src/index.ts`.

Packages are `1.0.0-beta.x` (Developer Preview) — names can still move between releases; check the installed version's barrel when something doesn't resolve.

## `@spree/dashboard-core` — framework

| Kind | Exports |
|---|---|
| Plugin facade | `defineDashboardPlugin` (also at `@spree/dashboard-core/plugin`) |
| Registries | `nav`, `settingsNav`, `pluginRoutes`, `matchPluginRoute`, `usePluginRoutes`, `registerSlot`, `removeSlot`, `updateSlot`, `useSlotEntries`, `tables`, `defineTable`, `formFields`, `customFieldComponents` |
| Page chrome | `PageHeader`, `PageTabs`, `Slot`, `AppSidebar`, `SettingsSidebar`, `MobileTopBar`, `StoreSwitcher` |
| Tables | `ResourceTable`, `resourceSearchSchema`, `type ResourceSearch`, `TableToolbar`, `BulkActionBar`, `filtersToRansack` |
| Form widgets | `StoreDatePicker`, `CountryCombobox`, `CountryStateFields`, `CurrencySelect`, `LocaleSelect`, `MarketCombobox`, `ResourceCombobox`, `ResourceMultiAutocomplete`, `TagCombobox`, `PreferencesForm`, `AddressFormDialog` |
| Permission | `Can`, `usePermissions`, `Subject`, `Action`, `type SubjectName`, `type ActionName` — customers are `'Spree::Customer'` (`Subject.Customer`); `'Spree::User'` is the pre-6.0 name the API no longer recognizes |
| Hooks | `useAuth`, `useStore`, `useCommandPalette`, `useGlobalSearch`, `useCountries`, `useCustomFields`, `useDirectUpload`, `useExport`, `useResourceKey`, `useResourceKeyBuilder`, `useResourceMutation`, `useHostForm`, `useOptionalHostForm` |
| Helpers | `mapSpreeErrorsToForm`, `formatPrice`, `normalizeMoneyInput(raw, locale)` (turns a typed amount into what you save — reads a lone `.`/`,` not followed by three digits as the decimal mark, so `19.50` under `de` isn't saved as 1950), `formatStoreDateTime`, `getInitials`, `blankToNull`, `blankToUndefined`, `withStoreScope`, `resourceKey`, `i18n` |
| SDK client | `adminClient` (the configured `@spree/admin-sdk` singleton) |
| Providers | `AuthProvider`, `PermissionProvider`, `StoreProvider` (the shell mounts these; only needed for a custom shell) |
| Export | `ExportButton` |
| Vite | `spreeDashboardPlugin` from `@spree/dashboard-core/vite` (core-only hosts; full-shell hosts use `@spree/dashboard/vite`) |
| Built-in slot names | `NO_STORE_ACCESS_SLOT` (`'no_store_access'`), `type NoStoreAccessSlotContext` (`{ user, signOut }`) |

### Lightweight subpath entries

The package entry loads the whole framework (every registry, component and translation). A small host app that builds its own screens and needs only the client and sign-in imports subpaths instead, keeping the rest out of its bundle:

```ts
import { adminClient } from '@spree/dashboard-core/client'               // the SDK instance alone
import { setApiClient } from '@spree/dashboard-core/api-client'          // registers the client the providers use
import { AuthProvider } from '@spree/dashboard-core/providers/auth-provider'
import { useAuth } from '@spree/dashboard-core/hooks/use-auth'
```

Other exported subpaths: `@spree/dashboard-core/plugin`, `/vite`, `/vite/discover`, `/providers/*`, `/hooks/*`, `/lib/*`, `/locales/en.json`. Distributed plugins keep importing from the package root — subpaths are for trimming a custom app's bundle.

## `@spree/dashboard-ui` — design system (props in, no providers/hooks)

- shadcn-style primitives: `Button`, `Card*`, `Dialog*`, `Sheet*`, `DropdownMenu*`, `Input`, `Textarea`, `Checkbox`, `RadioGroup`, `Switch`, `Select*`, `Combobox`, `Field`, `FieldLabel`, `FieldError`, `FieldDescription`, `Table*`, `Badge`, `Avatar`, `Skeleton`, `Tooltip*`, `Toaster`
- Composed: `ResourceLayout` (header / main / sidebar grid), `Empty`, `EmptyHeader`, `EmptyMedia`, `EmptyTitle`, `EmptyDescription`, `EmptyContent`, `ColorPicker`, `RelativeTime`, `useConfirm`
- Utility: `cn` (clsx + tailwind-merge)
- Toasts: `import { toast } from 'sonner'` directly; `<Toaster>` is already mounted by the shell.

A few names exist in both packages (`ResourceCombobox`, `ResourceMultiAutocomplete`, `Slot`, `StatusCard`, `DateRange`): `@spree/dashboard` gives you the framework (data-fetching) version; import from `@spree/dashboard-ui` for the presentational one that takes options as props.

## `@spree/dashboard` — app shell

- Everything above, re-exported.
- `Dashboard` (provider stack + router; `<Dashboard router={router} />`) and `createDashboardRouter(routeTree, { basepath })` — wired in the starter's `main.tsx`.
- `@spree/dashboard/vite` → `spreeDashboardPlugin()` (Tailwind, plugin discovery, `virtual:spree-dashboard-plugins`, route-tree composition).
- `@spree/dashboard/styles.css` — CSS entry, imported first in `src/styles.css`.
- `@spree/dashboard/components/spree/payment-method-editors/types` — `paymentMethodGuideSlot` / `paymentMethodFormSlot` / `paymentMethodActionsSlot`.
- Sign-in / onboarding building blocks, for a host that builds its own auth screens instead of mounting `<Dashboard />` (their translations ship in `@spree/dashboard-core`, so they render translated once its i18n loads):
  - `@spree/dashboard/components/spree/auth-shell` → `AuthShell` (two-column sign-in layout)
  - `@spree/dashboard/components/spree/store-setup-fields` → `StoreSetupFields` (store name, country, language, currency)
  - `@spree/dashboard/hooks/use-auth-providers` → `useAuthProviders`, `authCallbackErrorKey` (password + SSO options, SSO callback error copy)
  - `@spree/dashboard/schemas/auth` → `loginFormSchema`, `resetPasswordFormSchema` (Zod)

## `@spree/admin-sdk`

Import types and `SpreeError` directly (`import { type Product, type PaginatedResponse, SpreeError } from '@spree/admin-sdk'`). Never construct a second client — use `adminClient`.
