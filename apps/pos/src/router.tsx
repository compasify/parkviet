import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  redirect,
} from '@tanstack/react-router';
import { PosShell } from './components/pos-shell';
import { session } from './lib/app-session';
import { BottleKeepsPage } from './pages/bottle-keeps';
import { CollectPage } from './pages/collect';
import { CustomerDisplayPage } from './pages/customer-display';
import { LoginPage } from './pages/login';
import { MealAccountsPage } from './pages/meal-accounts';
import { ReceiptPage } from './pages/receipt';
import { ReservationsPage } from './pages/reservations';
import { ReturnExchangePage } from './pages/return-exchange';
import { SalePage } from './pages/sale';
import { ShiftsPage } from './pages/shifts';
import { TipsPage } from './pages/tips';

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
  },
  component: PosShell,
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

const customerDisplayRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/display',
  component: CustomerDisplayPage,
});

export const router = createRouter({
  routeTree: rootRoute.addChildren([
    loginRoute,
    customerDisplayRoute,
    authedRoute.addChildren([
      saleRoute,
      returnsRoute,
      shiftsRoute,
      collectRoute,
      reservationsRoute,
      bottleKeepsRoute,
      mealAccountsRoute,
      tipsRoute,
      receiptsRoute,
    ]),
  ]),
  basepath: import.meta.env.BASE_URL.replace(/\/$/, '') || '/',
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
