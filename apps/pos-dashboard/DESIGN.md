# POS dashboard screens

Screens in this app follow the Spree settings pages, for example
`/$storeId/settings/emails` in the admin at `http://localhost:5173`.
A screen is a page title, pill tabs when the page has sections, then blocks
whose title and icon sit above the card.

Reference implementation: `PillTabs` and a branch page
(`src/components/branch-detail.tsx`), especially hardware
(`src/pages/branch-hardware.tsx`).

## Page

- Stack the header, the tabs, and the content with `space-y-6` or
  `flex flex-col gap-6`.
- A short introduction is `text-base text-muted-foreground`, above the first
  block. It is not a heading inside a card.
- Every visible string goes through i18next, in both `locales/vi.json` and
  `locales/en.json`.

## Tabs

Sub-navigation is the pill control from `@spree/dashboard-ui`: `Tabs`,
`TabsList`, `TabsTrigger`. The selected tab is the white pill on the recessed
track. Do not use `PageTabs` for these screens; that control is an underline.

When a tab changes the URL, use `PillTabs` in `src/components/pill-tabs.tsx`.
It renders each trigger as a router `Link` and scrolls inside itself when the
labels are wider than the page. Do not build a second tab strip.

## Blocks

A block is a title outside the card, then the card.

- The title is a `SectionTitle` (`@spree/dashboard-ui`). Pass an icon element
  as its first child. The icon is drawn in a rounded tile; do not size or
  frame it yourself.
- Icons come from `@spree/dashboard-ui/icons`. Do not import `lucide-react`
  for a new screen.
- The card holds only the body: fields, rows, or empty text. Do not put
  `CardHeader` / `CardTitle` on a settings block.

Use `ModelCard` in `src/components/setup/model-ui.tsx` for a settings block.
Give it `title`, `id`, and `icon`. The `id` is the heading id and the name of
the region.

`SettingsSection` from `@spree/dashboard-core` is the same shape when the
block is not a `ModelCard`. Put `CardContent` inside it.

```tsx
<ModelCard title={t('branchPayments.title')} id="branch-payments" icon={<CreditCardIcon />}>
  <p className="text-sm text-muted-foreground">{t('branchPayments.intro')}</p>
  {/* fields */}
</ModelCard>
```

Several blocks on one page stay as separate titled cards, stacked with
`gap-6`. Do not merge them into one card with headings inside.

## Rows

A label with a short control or a status uses `SettingsFieldGroup` and
`SettingsRow` from `@spree/dashboard-core`:

- The label and its help sit on the left. Help is the `help` prop.
- The control, link, or badge sits on the right.
- The group draws the rule between rows. Do not add a second divider.

A list of records with no control on the right can still be a `SettingsRow`
whose right side is secondary text.

## Tables

A resource table (`ResourceTable`) keeps the Spree table. Above it, put a
`SectionTitle` with an icon and the page hint as `text-base text-muted-foreground`.
The table is not wrapped in another card that repeats the title. See the
branch products tab and the registers and staff tabs in `src/pages/topology.tsx`.

## Leave alone

- The app shell, sidebar, and `PageHeader` of a store-level page stay as Spree
  ships them.
- Do not restyle `apps/dashboard`. POS administration lives in this app.
