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
import { LoginPage } from './pages/login';
import { OrdersPage } from './pages/orders';
import { ReceivablesPage } from './pages/receivables';
import { PaymentAttentionPage, ReceivedFundsPage } from './pages/received-funds';
import { ReturnExchangePage } from './pages/return-exchange';
import { SalePage } from './pages/sale';
import { BranchProductsPage } from './pages/settings/branch-products';
import { LabelFormatsPage } from './pages/settings/label-formats';
import { TopologyPage } from './pages/settings/topology';

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

const fundsRoute = createRoute({
  getParentRoute: () => authedRoute,
  path: '/funds',
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

export const router = createRouter({
  routeTree: rootRoute.addChildren([
    loginRoute,
    authedRoute.addChildren([
      saleRoute,
      settingsRoute,
      branchProductsRoute,
      labelFormatsRoute,
      fundsRoute,
      receivablesRoute,
      creditAccountsRoute,
      creditApprovalsRoute,
      attentionRoute,
      ordersRoute,
      returnsRoute,
    ]),
  ]),
  basepath: '/pos',
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
