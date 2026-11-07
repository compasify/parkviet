import {
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  redirect,
} from '@tanstack/react-router';
import { PosShell } from './components/pos-shell';
import { session } from './lib/app-session';
import { LoginPage } from './pages/login';
import { PaymentAttentionPage, ReceivedFundsPage } from './pages/received-funds';
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
      attentionRoute,
    ]),
  ]),
  basepath: '/pos',
});

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
