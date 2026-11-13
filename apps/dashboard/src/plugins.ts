// Dashboard customizations for this store.
//
// Register nav entries, routes, slot widgets, and table columns against the
// shared registries — the same API distributed plugins use. Imported once
// from main.tsx, before the dashboard renders.
//
// Keep this file a map of what you added: the registrations live here, the
// implementations live in pages/, hooks/, tables/ and schemas/. See the
// README for what belongs where.
//
// Example:
//
//   import { defineDashboardPlugin } from '@spree/dashboard'
//   import { AnalyticsPage } from './pages/analytics'
//
//   defineDashboardPlugin({
//     nav: [{
//       key: 'analytics',
//       label: i18n.t('admin.analytics.nav'),
//       path: '/analytics',
//       position: 650,
//     }],
//     routes: [{ key: 'analytics', path: '/analytics', component: AnalyticsPage }],
//   })
//
// Docs: https://spreecommerce.org/docs/developer/dashboard/customization/quickstart

import { defineDashboardPlugin, i18n, Subject } from '@spree/dashboard'
import { BanknoteIcon, Building2Icon } from '@spree/dashboard-ui/icons'
import en from './locales/en.json'
import vi from './locales/vi.json'
import { StoresPage } from './pages/stores'
import { VietqrSettingsPage } from './pages/vietqr-settings'
import { VietqrPaymentMethodGuide } from './slots/vietqr-payment-method-guide'
import { registerStoresTable } from './tables/stores'

// Merges your `admin.*` keys into the dashboard's namespace without dropping
// its own. Add a bundle per locale you ship.
i18n.addResourceBundle('en', 'translation', en, true, true)
i18n.addResourceBundle('vi', 'translation', vi, true, true)
registerStoresTable()

// Several stores in one dashboard: listing them and opening a new one. The
// API only lets an admin of the current store create one.
defineDashboardPlugin({
  settingsNav: [
    {
      key: 'settings.stores',
      labelKey: 'admin.multi_store.nav',
      descriptionKey: 'admin.multi_store.nav_description',
      keywords: ['stores', 'multi store', 'cửa hàng', 'nhà hàng', 'chi nhánh'],
      path: '/stores',
      icon: Building2Icon,
      group: 'store',
      position: 50,
      subject: Subject.Store,
      action: 'update',
    },
  ],
  routes: [
    {
      key: 'settings.stores',
      path: '/settings/stores',
      component: StoresPage,
      subject: Subject.Store,
    },
  ],
})

// VietQR (spree_vietqr): receiving accounts and bank webhooks live in
// Settings; the payment method editor links there.
defineDashboardPlugin({
  settingsNav: [
    {
      key: 'settings.vietqr',
      labelKey: 'admin.vietqr.nav',
      descriptionKey: 'admin.vietqr.nav_description',
      keywords: ['vietqr', 'qr', 'bank transfer', 'chuyển khoản', 'sepay', 'payos', 'webhook'],
      path: '/vietqr',
      icon: BanknoteIcon,
      group: 'selling',
      position: 210,
      subject: Subject.PaymentMethod,
    },
  ],
  routes: [
    {
      key: 'settings.vietqr',
      path: '/settings/vietqr',
      component: VietqrSettingsPage,
      subject: Subject.PaymentMethod,
    },
  ],
  slots: {
    'payment_method.guide.vietqr': [
      { id: 'vietqr-guide', component: VietqrPaymentMethodGuide as never },
    ],
  },
})
