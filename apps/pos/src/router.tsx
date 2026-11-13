import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  redirect,
} from '@tanstack/react-router';
import { PosShell } from './components/pos-shell';
import { session } from './lib/app-session';
import { needsStoreChoice } from './lib/session-coordinator';
import { BottleKeepsPage } from './pages/bottle-keeps';
import { CollectPage } from './pages/collect';
import { CustomerDisplayPage } from './pages/customer-display';
import { LoginPage } from './pages/login';
import { MealAccountsPage } from './pages/meal-accounts';
import { OfflineReviewPage } from './pages/offline-review';
import { OfflineSalePage } from './pages/offline-sale';
import { ReceiptPage } from './pages/receipt';
import { ReservationsPage } from './pages/reservations';
import { ReturnExchangePage } from './pages/return-exchange';
import { SalePage } from './pages/sale';
import { ShiftsPage } from './pages/shifts';
import { StorePickerPage } from './pages/store-picker';
import { StoredValuePage } from './pages/stored-value';
import { TipsPage } from './pages/tips';
import { VehicleVisitsPage } from './pages/vehicle-visits';

const rootRoute = createRootRoute({
  component: () => <Outlet />,
});

const loginRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/login',
  beforeLoad: () => {
    if (session.getSnapshot().status === 'authenticated') throw redirect({ to: '/' });
  },
  component: LoginPage,
});

const authedRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: 'authed',
  beforeLoad: async () => {
    if (session.getSnapshot().status !== 'authenticated') await session.restore();
    if (session.getSnapshot().status !== 'authenticated') throw redirect({ to: '/login' });
    if (needsStoreChoice(session.getSnapshot())) throw redirect({ to: '/store' });
  },
  component: PosShell,
});

// A cashier working in several stores picks the one this tab sells for.
const storeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/store',
  beforeLoad: async () => {
    if (session.getSnapshot().status !== 'authenticated') await session.restore();
    if (session.getSnapshot().status !== 'authenticated') throw redirect({ to: '/login' });
  },
  component: StorePickerPage,
});

const saleRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/',
  // The order of the selected invoice tab, so a reload or a shared link
  // opens the same tab.
  validateSearch: (search: Record<string, unknown>): { order?: string } =>
    typeof search.order === 'string' && /^[\w-]{1,64}$/.test(search.order)
      ? { order: search.order }
      : {},
  component: SalePage,
});

const returnsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/returns',
  // The order to return from, or the return to reopen (after a reload or from
  // the shift close checklist).
  validateSearch: (search: Record<string, unknown>): { orderId?: string; returnId?: string } => {
    const id = (value: unknown) =>
      typeof value === 'string' && /^[\w-]{1,64}$/.test(value) ? value : undefined;
    const orderId = id(search.orderId);
    const returnId = id(search.returnId);
    return { ...(orderId ? { orderId } : {}), ...(returnId ? { returnId } : {}) };
  },
  component: ReturnExchangePage,
});

// The cashier's own shift: open, cash in/out requests and the blind close.
const shiftsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/shifts',
  component: ShiftsPage,
});

// Debt collection into the cashier's open shift.
const collectRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/collect',
  component: CollectPage,
});

// A branch's bookings: the day's tables, deposits and seating.
const reservationsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/reservations',
  component: ReservationsPage,
});

// A bar's bottle-keeping book: kept bottles, pours, levels and labels.
const bottleKeepsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/bottle-keeps',
  component: BottleKeepsPage,
});

// A canteen's meal accounts: balances, wallet history, top-ups and refunds.
const mealAccountsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/meal-accounts',
  component: MealAccountsPage,
});

// Prepaid money and minutes cards: selling, balances, history and top-ups.
const storedValueRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/stored-value',
  component: StoredValuePage,
});

// A rest stop's coach visits: closing, the commission and paying the driver.
const vehicleVisitsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/vehicle-visits',
  component: VehicleVisitsPage,
});

// The tips of a business day and paying them to the staff.
const tipsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/tips',
  component: TipsPage,
});

// Receipts (authed) and the customer display, which has no staff session:
// it reads only with its own display token.
const receiptsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/receipts',
  validateSearch: (search: Record<string, unknown>): { source?: string; receiptId?: string } => {
    const id = (value: unknown) =>
      typeof value === 'string' && /^[\w-]{1,64}$/.test(value) ? value : undefined;
    const source = id(search.source);
    const receiptId = id(search.receiptId);
    return { ...(source ? { source } : {}), ...(receiptId ? { receiptId } : {}) };
  },
  component: ReceiptPage,
});

// Offline sales the server holds for review, finished by the cashier who
// took the cash or rejected by a manager.
const offlineReviewRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/offline-review',
  component: OfflineReviewPage,
});

// Cash sales while the server is out of reach. Outside the signed-in shell
// on purpose: after a reload offline there is no session to restore, and
// the page sells only from the register's stored snapshot.
const offlineSaleRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/offline',
  component: OfflineSalePage,
});

const customerDisplayRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/display',
  component: CustomerDisplayPage,
});

export const router = createRouter({
  routeTree: rootRoute.addChildren([
    loginRoute,
    storeRoute,
    customerDisplayRoute,
    offlineSaleRoute,
    authedRoute.addChildren([
      saleRoute,
      returnsRoute,
      shiftsRoute,
      collectRoute,
      reservationsRoute,
      bottleKeepsRoute,
      mealAccountsRoute,
      storedValueRoute,
      vehicleVisitsRoute,
      tipsRoute,
      receiptsRoute,
      offlineReviewRoute,
    ]),
  ]),
  basepath: import.meta.env.BASE_URL.replace(/\/$/, '') || '/',
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
