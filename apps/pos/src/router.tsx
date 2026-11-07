import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  redirect,
} from '@tanstack/react-router';
import { PosShell } from './components/pos-shell';
import { session } from './lib/app-session';
import { CreditAccountsPage } from './pages/credit-accounts';
import { CreditApprovalsPage } from './pages/credit-approvals';
import { CustomerDisplayPage } from './pages/customer-display';
import { InventoryTraceabilityPage } from './pages/inventory-traceability';
import { LoginPage } from './pages/login';
import { OrdersPage } from './pages/orders';
import { ReceiptPage } from './pages/receipt';
import { ReceivablesPage } from './pages/receivables';
import { PaymentAttentionPage, ReceivedFundsPage } from './pages/received-funds';
import { ReportsPage } from './pages/reports';
import { ReturnExchangePage } from './pages/return-exchange';
import { SalePage } from './pages/sale';
import { BranchFeaturesPage } from './pages/settings/branch-features';
import { BranchProductsPage } from './pages/settings/branch-products';
import { LabelFormatsPage } from './pages/settings/label-formats';
import { TopologyPage } from './pages/settings/topology';
import { ShiftsPage } from './pages/shifts';

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
  component: SalePage,
});

const settingsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/settings',
  component: TopologyPage,
});

const branchProductsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/settings/branches/$branchId/products',
  component: BranchProductsPage,
});

const labelFormatsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/settings/branches/$branchId/label-formats',
  component: LabelFormatsPage,
});

const branchFeaturesRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/settings/branches/$branchId/features',
  component: BranchFeaturesPage,
});

const fundsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/funds',
  // The received funds to open, when a shift close checklist links to it.
  validateSearch: (search: Record<string, unknown>): { fundsId?: string } =>
    typeof search.fundsId === 'string' && /^[\w-]{1,64}$/.test(search.fundsId)
      ? { fundsId: search.fundsId }
      : {},
  component: ReceivedFundsPage,
});

const receivablesRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/receivables',
  component: ReceivablesPage,
});

const creditAccountsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/credit-accounts',
  component: CreditAccountsPage,
});

const creditApprovalsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/credit-approvals',
  component: CreditApprovalsPage,
});

const ordersRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/orders',
  component: OrdersPage,
});

const returnsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/returns',
  // The order to return from (wizard opened from order history), or the
  // return to reopen (after a reload, from an order or from approvals).
  validateSearch: (search: Record<string, unknown>): { orderId?: string; returnId?: string } => {
    const id = (value: unknown) =>
      typeof value === 'string' && /^[\w-]{1,64}$/.test(value) ? value : undefined;
    const orderId = id(search.orderId);
    const returnId = id(search.returnId);
    return { ...(orderId ? { orderId } : {}), ...(returnId ? { returnId } : {}) };
  },
  component: ReturnExchangePage,
});

const attentionRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/payment-attention',
  component: PaymentAttentionPage,
});

// Shift close, drawer cash and reports.
const shiftsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/shifts',
  component: ShiftsPage,
});

const reportsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/reports',
  component: ReportsPage,
});

// Serial and lot stock: receipts, transfers, counts, quarantine and recall.
const inventoryRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/inventory',
  component: InventoryTraceabilityPage,
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
      settingsRoute,
      branchProductsRoute,
      labelFormatsRoute,
      branchFeaturesRoute,
      fundsRoute,
      receivablesRoute,
      creditAccountsRoute,
      creditApprovalsRoute,
      attentionRoute,
      ordersRoute,
      returnsRoute,
      shiftsRoute,
      reportsRoute,
      receiptsRoute,
      inventoryRoute,
    ]),
  ]),
  basepath: '/pos',
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
