import { formatMoney } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { isTableSurface, sellingSurfaceOf, tableSurfaceOf } from '@parkviet/pos-shared/pos-modules';
import { rateLabel } from '@parkviet/pos-shared/receipt-template/data';
import { describeTraceFailure } from '@parkviet/pos-shared/traceability';
import { useNavigate, useSearch } from '@tanstack/react-router';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { fetchCatalogPage, parseMeasurementBarcode } from '../hooks/use-catalog';
import { useInvoiceNumbers } from '../hooks/use-invoice-numbers';
import { useWorkspaceMeal } from '../hooks/use-meal-accounts';
import { useMenu } from '../hooks/use-menu';
import { DraftReplayRefused, useWorkspaces } from '../hooks/use-workspaces';
import { commandQueue } from '../lib/command-queue';
import { MEAL_ACCOUNTS_MODULE } from '../lib/meal-accounts';
import { resolveScan, type ScanOutcome } from '../lib/measured-label';
import { soldOutVariantIds } from '../lib/menu-selection';
import { type PosLineItem, type PosWorkspace, writesLocked } from '../lib/pos-context';
import {
  describeFailure,
  leaseConflict,
  posFailureKey,
  snapshotLocked,
} from '../lib/request-failure';
import { SCAN_LOOKUP_LIMIT } from '../lib/scan-lookup';
import {
  createScannerKeyBuffer,
  createScannerQueue,
  type ScanIntent,
  type ScanResult,
  shouldCaptureScannerKey,
} from '../lib/scanner-queue';
import type { TablePlacement } from '../lib/table-courses';
import { appendable, voidReasons } from '../lib/table-kitchen';
import {
  canServeTables,
  inSelection,
  isTab,
  isTableOrder,
  savedTableSurface,
  tableOrderName,
  tableOrderOf,
} from '../lib/tables';
import { canRunClock } from '../lib/timed-clock';
import { VEHICLE_COMMISSION_MODULE } from '../lib/vehicle-visits';
import { workspaceHasContent, workspaceIsSettled, workspacePhase } from '../lib/workspace-content';
import { createWorkspaceSerializer } from '../lib/workspace-serializer';
import { readLayout } from '../lib/workspace-storage';
import { BuffetTierPicker } from './buffet-tier-picker';
import { CatalogSearch, type ScanNotice } from './catalog-search';
import { CloseTabDialog } from './close-tab-dialog';
import { CourseSeatPicker } from './course-seat-picker';
import { CustomerPanel } from './customer-panel';
import { DeliveryForm } from './delivery-form';
import { DiscountForm } from './discount-form';
import { DisplayPinControl } from './display-pin-control';
import { GuestNameField } from './guest-name-field';
import { KitchenHistory } from './kitchen-history';
import { MealBanner } from './meal-banner';
import { MenuGrid } from './menu-grid';
import { MinimumSpendLines } from './minimum-spend-lines';
import { NoteForm } from './note-form';
import { OrderLines } from './order-lines';
import { OrderSourcePicker } from './order-source-picker';
import { PaymentPanel } from './payment-panel';
import { PickupQueue } from './pickup-queue';
import { PlatformOrderTray } from './platform-order-tray';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';
import { PrebillDialog } from './prebill-dialog';
import { ReservationDepositNote } from './reservation-deposit-note';
import { ScanInput } from './scan-input';
import { useScannerCalibration } from './scanner-calibration';
import { ServiceModeControl } from './service-mode-control';
import { TabList } from './tab-list';
import { TableOrderBar } from './table-actions';
import { TableFloor } from './table-floor';
import { VehicleVisitBar } from './vehicle-visit-bar';
import { VoidItemDialog } from './void-item-dialog';

type ScanPlan = { workspace?: PosWorkspace } & (
  | { kind: 'variant'; variantId: string }
  | { kind: 'label'; barcode: string; eventId: string }
);

export function WorkspaceTabs() {
  const { t } = useTranslation();
  const { selection, context, selectionComplete } = usePosSelection();
  const data = context.data;
  const staffId = data?.staff.id ?? null;
  const storeId = data?.store.id ?? null;
  const [activeId, setActiveId] = useState<string | null>(null);
  const activeIdRef = useRef(activeId);
  activeIdRef.current = activeId;
  const workspaces = useWorkspaces(
    storeId,
    staffId,
    Boolean(data?.shift),
    selection.branchId,
    selection.registerId,
    activeId,
  );
  const locked = writesLocked(data, selection);
  const channelUnavailable = Boolean(data?.sales_channel && data.sales_channel.status !== 'active');
  const [query, setQuery] = useState('');
  const [message, setMessage] = useState('');
  const [creating, setCreating] = useState(false);
  // Commands still running per workspace; every control of that workspace waits.
  const [pendingCounts, setPendingCounts] = useState<Record<string, number>>({});
  const [serializer] = useState(() =>
    createWorkspaceSerializer<PosWorkspace>((workspaceId, pending) =>
      setPendingCounts((current) => {
        if ((current[workspaceId] ?? 0) === pending) return current;
        const next = { ...current };
        if (pending > 0) next[workspaceId] = pending;
        else delete next[workspaceId];
        return next;
      }),
    ),
  );
  const [scanNotice, setScanNotice] = useState<ScanNotice | null>(null);
  const noticeSeq = useRef(0);
  // Workspaces whose head scan has an unknown outcome, with the scanned code.
  const [blockedScans, setBlockedScans] = useState<Record<string, string>>({});
  // Resolved target and the exact workspace snapshot of each scan's first
  // attempt, so a retry resends an identical command under the same key. A
  // scale label keeps the measurement id it was given on the first attempt.
  const scanPlans = useRef(new Map<string, ScanPlan>());
  const [leaseWait, setLeaseWait] = useState<{ workspaceId: string; until: number } | null>(null);
  const [leaseSeconds, setLeaseSeconds] = useState(0);
  const [hidden, setHidden] = useState<string[]>([]);
  const hiddenRef = useRef(hidden);
  hiddenRef.current = hidden;
  const [closeRequest, setCloseRequest] = useState<{ workspace: PosWorkspace } | null>(null);
  // Tab whose close is being decided; its details are loading or its cancel is running.
  const [closing, setClosing] = useState<string | null>(null);
  const scope = `${staffId}:${storeId}:${selection.branchId}:${selection.registerId}`;
  const scopeRef = useRef(scope);
  scopeRef.current = scope;
  useEffect(() => {
    setActiveId(null);
    setHidden([]);
    setQuery('');
    setScanNotice(null);
    if (!staffId || !storeId || !selection.branchId) return;
    const saved = readLayout(staffId, storeId);
    if (saved?.branchId === selection.branchId && saved.registerId === selection.registerId) {
      setActiveId(saved.activeWorkspaceId ?? null);
      setHidden(saved.closedWorkspaceIds ?? []);
    }
  }, [staffId, storeId, selection.branchId, selection.registerId]);
  // A table order is booked on the branch's table register, which may not be
  // the one selected here: picked on the floor, it joins the tabs while selected.
  const rows = (workspaces.query.data?.data ?? []).filter(
    (workspace) => !hidden.includes(workspace.id) && inSelection(workspace, selection),
  );
  const pinned = workspaces.selectedQuery.isError ? undefined : workspaces.selectedQuery.data?.data;
  if (
    pinned &&
    pinned.id === activeId &&
    inSelection(pinned, selection) &&
    // Without a shift only a table order opens (someone serving tables).
    (data?.shift || isTableOrder(pinned)) &&
    !hidden.includes(pinned.id) &&
    !rows.some((row) => row.id === pinned.id)
  )
    rows.unshift(pinned);
  const rowsRef = useRef(rows);
  rowsRef.current = rows;
  const matching = rows.filter((workspace) => workspace.order_id.includes(query.trim()));
  const tabNumbers = useInvoiceNumbers(
    staffId,
    storeId,
    selection.branchId,
    selection.registerId,
    rows.map((workspace) => workspace.id).reverse(),
    hidden,
  );
  matching.sort((left, right) => tabNumbers[left.id] - tabNumbers[right.id]);
  const visible = matching.slice(0, 8);
  const selectedMatch = matching.find((workspace) => workspace.id === activeId);
  if (selectedMatch && !visible.some((workspace) => workspace.id === selectedMatch.id)) {
    visible[7] = selectedMatch;
  }
  const overflow = rows.length - visible.length;
  const activeSummary = rows.find((workspace) => workspace.id === activeId) ?? visible[0] ?? null;
  const active = pinned && activeSummary && pinned.id === activeSummary.id ? pinned : activeSummary;
  const isEditor = active ? workspaces.owns(active) : false;
  const activePhase = active ? workspacePhase(active) : 'editing';
  const busy =
    creating || (active ? Boolean(pendingCounts[active.id]) || active.id in blockedScans : false);
  // Recorded payments freeze the basket: the tender was prepared for these lines.
  const editable = Boolean(
    active && isEditor && !locked && active.operational_status === 'editing' && !active.payments,
  );
  const editDisabled = !editable || busy;
  // The order source moves no money: it stays open while a payment is taken.
  const sourceDisabled =
    !(active && isEditor && !locked && active.operational_status === 'editing') || busy;
  // Tapping a product does not wait for the previous add: the serializer
  // queues it on the newest revision. Only a blocked scan or a draft still
  // being created stops it.
  // A table order takes additions and changes to unsent lines from anyone
  // serving it, without the lease.
  const canAppend = appendable(active, data?.modules?.['fnb.tables'] === true, locked);
  const quickAddDisabled =
    channelUnavailable ||
    !(editable || canAppend) ||
    creating ||
    (active ? active.id in blockedScans : false);
  const lockReason = active?.payments ? t('editLockedPayments') : undefined;
  // A branch running the menu sells from picture tiles unless its profile asks for the catalogue.
  const menuSurface = sellingSurfaceOf(data) === 'menu_grid';
  // The catalogue of a branch running the menu still dims sold-out dishes.
  const menu = useMenu(selection.branchId, menuSurface || data?.modules?.['fnb.menu'] === true);
  const soldOut = useMemo(() => soldOutVariantIds(menu.data), [menu.data]);
  // Counter service: call numbers per business day and cup labels.
  const callNumbers = data?.modules?.['fnb.order_number'] === true;
  const cupLabels = data?.modules?.['fnb.cup_label'] === true;
  // Delivery platform orders typed in at the counter; they keep to their own tray.
  const platformOrders = data?.modules?.['fnb.delivery_platforms'] === true;
  // Table service: the floor (tiles or plan, chosen per device) beside selling.
  const [savedSurface, setSavedSurface] = useState(() => savedTableSurface());
  const tableSurface = tableSurfaceOf(data, savedSurface);
  const postpay = data?.modules?.['fnb.postpay'] === true;
  // Canteen: the scan field records meals; the eater and the split come back per order.
  const mealAccounts = data?.modules?.[MEAL_ACCOUNTS_MODULE] === true;
  const mealQuery = useWorkspaceMeal(active, mealAccounts);
  const meal = mealAccounts ? (mealQuery.data?.meal ?? null) : null;
  // Rest stop: orders go on the coach that brought the guests.
  const vehicleCommission = data?.modules?.[VEHICLE_COMMISSION_MODULE] === true;
  const activeTable = tableOrderOf(active);
  const tablist = useRef<HTMLDivElement>(null);
  const discountDetailsRef = useRef<HTMLDetailsElement>(null);
  const noteDetailsRef = useRef<HTMLDetailsElement>(null);
  const deliveryDetailsRef = useRef<HTMLDetailsElement>(null);
  const activeTabId = active?.id;
  useEffect(() => {
    if (!leaseWait || leaseWait.workspaceId !== activeTabId) {
      setLeaseSeconds(0);
      return;
    }
    const update = () =>
      setLeaseSeconds(Math.max(0, Math.ceil((leaseWait.until - Date.now()) / 1000)));
    update();
    const timer = window.setInterval(update, 1000);
    return () => window.clearInterval(timer);
  }, [leaseWait, activeTabId]);
  useEffect(() => {
    if (!activeTabId) return;
    const list = tablist.current;
    // Measure the tab's wrapper, which also holds its close button.
    const selected = list
      ?.querySelector<HTMLElement>('[aria-selected="true"]')
      ?.closest<HTMLElement>('.workspace-tab');
    if (!list || !selected) return;
    // Scroll only the tab strip, never jump the cashier's document position.
    const left = selected.offsetLeft - list.offsetLeft;
    if (left < list.scrollLeft) list.scrollLeft = left;
    else if (left + selected.offsetWidth > list.scrollLeft + list.clientWidth)
      list.scrollLeft = left + selected.offsetWidth - list.clientWidth;
  }, [activeTabId]);
  // The URL and the page title follow the selected tab (`/?order=R250`,
  // "R250 · Hóa đơn 1 – ParkViet POS"). An order asked for by the URL (reload,
  // shared link) wins over the remembered tab until the list has loaded.
  const search = useSearch({ from: '/authed/' });
  const navigate = useNavigate();
  // The floor is the first screen where the profile starts on a table
  // surface; an order asked for by the URL opens for selling instead.
  const [floorChoice, setFloorChoice] = useState<boolean | null>(null);
  const [orderAtStart] = useState(() => search.order ?? null);
  const showFloor =
    tableSurface !== null &&
    (floorChoice ?? (isTableSurface(data?.profile?.display.surface) && !orderAtStart));
  // A bar starts on its open tabs (profile surface `tab_list`, `fnb.postpay`).
  const tabSurface = postpay;
  const [tabsChoice, setTabsChoice] = useState<boolean | null>(null);
  const showTabs =
    tabSurface &&
    !showFloor &&
    (tabsChoice ?? (data?.profile?.display.surface === 'tab_list' && !orderAtStart));
  // Order the URL asks for and that is not selected yet.
  const requestedOrder = useRef<string | null>(search.order ?? null);
  // The URL as of the last render, and the order this component last wrote
  // to it: a URL change that is not our own write (back, a link) is a request.
  const lastSearchOrder = useRef(search.order ?? null);
  const writtenOrder = useRef<string | null>(search.order ?? null);
  // A tab selected for the URL whose render has not happened yet.
  const selecting = useRef<string | null>(null);
  const listLoaded = workspaces.query.isSuccess;
  useEffect(() => {
    const order = search.order ?? null;
    if (order !== lastSearchOrder.current) {
      lastSearchOrder.current = order;
      if (order !== writtenOrder.current) {
        writtenOrder.current = order;
        requestedOrder.current = order;
      }
    }
    const wanted = requestedOrder.current;
    if (!wanted) return;
    const match = rows.find((workspace) => workspace.order_id === wanted);
    if (match) {
      requestedOrder.current = null;
      if (match.id !== activeIdRef.current) {
        selecting.current = match.id;
        setActiveId(match.id);
        workspaces.rememberView(match.id, workspaces.page);
      }
    } else if (listLoaded) {
      requestedOrder.current = null;
    }
  });
  const activeOrder = active?.order_id ?? null;
  useEffect(() => {
    if (requestedOrder.current) return;
    if (selecting.current) {
      if (active?.id !== selecting.current) return;
      selecting.current = null;
    }
    // Already in the URL, or already on its way there.
    if (writtenOrder.current === activeOrder) return;
    writtenOrder.current = activeOrder;
    void navigate({ to: '/', search: activeOrder ? { order: activeOrder } : {}, replace: true });
  });
  const baseTitle = useRef(document.title);
  const activeTitle =
    active && activeOrder
      ? `${activeOrder} · ${t('invoiceTab', { number: tabNumbers[active.id] })} – ${baseTitle.current}`
      : baseTitle.current;
  useEffect(() => {
    document.title = activeTitle;
  }, [activeTitle]);
  useEffect(() => {
    const base = baseTitle.current;
    return () => {
      document.title = base;
    };
  }, []);
  const heartbeat = useRef(workspaces.heartbeat);
  heartbeat.current = workspaces.heartbeat;
  const claim = useRef(workspaces.claim);
  claim.current = workspaces.claim;
  const heartbeatWorkspace = useRef(active);
  heartbeatWorkspace.current = active;
  const leaseWorkspaceId = active?.id;
  const leaseGeneration = active?.lease_generation;
  const leaseStatus = active?.operational_status;
  // Strict editing locks are opt-in (`edit_lease`); without them this page
  // takes editing of the selected draft over by itself, silently.
  const strictLease = contextFeature(data, 'edit_lease');
  const strictLeaseRef = useRef(strictLease);
  strictLeaseRef.current = strictLease;
  // Draft this page already tried to take over since it was selected or the
  // window was focused, and the draft where that attempt failed.
  const autoClaimed = useRef<string | null>(null);
  const [autoClaimFailed, setAutoClaimFailed] = useState<string | null>(null);
  const [focusTick, setFocusTick] = useState(0);
  useEffect(() => {
    const regain = () => {
      if (document.visibilityState !== 'visible') return;
      autoClaimed.current = null;
      setFocusTick((tick) => tick + 1);
    };
    window.addEventListener('focus', regain);
    document.addEventListener('visibilitychange', regain);
    return () => {
      window.removeEventListener('focus', regain);
      document.removeEventListener('visibilitychange', regain);
    };
  }, []);
  const autoClaimTarget =
    !strictLease &&
    active &&
    !isEditor &&
    !locked &&
    !busy &&
    active.operational_status !== 'canceled'
      ? active
      : null;
  // biome-ignore lint/correctness/useExhaustiveDependencies: a newly selected draft re-arms the takeover
  useEffect(() => {
    autoClaimed.current = null;
    setAutoClaimFailed(null);
  }, [leaseWorkspaceId]);
  // biome-ignore lint/correctness/useExhaustiveDependencies: focusTick re-arms the takeover
  useEffect(() => {
    if (!autoClaimTarget || document.visibilityState !== 'visible') return;
    // Once per selection or focus, so two open windows do not keep stealing it.
    if (autoClaimed.current === autoClaimTarget.id) return;
    autoClaimed.current = autoClaimTarget.id;
    const target = autoClaimTarget;
    void run(() => command(target, (current) => workspaces.claim(current, true))).then((claimed) =>
      setAutoClaimFailed(claimed ? null : target.id),
    );
  }, [autoClaimTarget?.id, autoClaimTarget?.lease_generation, focusTick]);

  useEffect(() => {
    if (!leaseWorkspaceId || !isEditor || locked || leaseStatus === 'canceled') return;
    const renew = () => {
      const workspace = heartbeatWorkspace.current;
      if (workspace?.id !== leaseWorkspaceId || workspace.lease_generation !== leaseGeneration)
        return;
      void heartbeat.current(workspace).catch(async (error: unknown) => {
        if (
          heartbeatWorkspace.current?.id !== leaseWorkspaceId ||
          heartbeatWorkspace.current.lease_generation !== leaseGeneration
        )
          return;
        // A background tab lets its lease lapse. When nobody else claimed it in the
        // meantime, take it back instead of dropping the cashier to read-only.
        // Without strict locks a hidden window must not take a draft back from
        // the one in use; it takes it over again when it is focused.
        const mayReclaim = strictLeaseRef.current || document.visibilityState === 'visible';
        if (leaseConflict(error)?.reason === 'lease_stale' && mayReclaim) {
          try {
            await claim.current(workspace);
            return;
          } catch {
            // Someone else holds the lease now; show the read-only notice below.
          }
        }
        if (heartbeatWorkspace.current?.id === leaseWorkspaceId) setMessage(t('leaseLost'));
      });
    };
    renew();
    const timer = window.setInterval(renew, 40_000);
    return () => window.clearInterval(timer);
  }, [leaseWorkspaceId, leaseGeneration, leaseStatus, isEditor, locked, t]);

  function command(
    workspace: PosWorkspace,
    action: (current: PosWorkspace) => Promise<PosWorkspace>,
  ): Promise<PosWorkspace> {
    return serializer.run(workspace, action).catch((error: unknown) => {
      // A tender was prepared meanwhile: reload so the basket shows as locked.
      if (snapshotLocked(error)) void workspaces.refresh();
      throw error;
    });
  }

  // Taps on a product that wait behind another command are merged into one
  // add with the summed quantity, so ten quick taps cost one request.
  const quickAdds = useRef(new Map<string, { quantity: number }>());
  function quickAdd(workspace: PosWorkspace, variantId: string) {
    const key = `${workspace.id}:${variantId}`;
    const queued = quickAdds.current.get(key);
    if (queued) {
      queued.quantity += 1;
      return;
    }
    const entry = { quantity: 1 };
    quickAdds.current.set(key, entry);
    void run(() =>
      command(workspace, (current) => {
        // From here on a new tap starts a new add.
        if (quickAdds.current.get(key) === entry) quickAdds.current.delete(key);
        return workspaces.addItem(current, variantId, entry.quantity, { merge: true });
      }),
    ).finally(() => {
      if (quickAdds.current.get(key) === entry) quickAdds.current.delete(key);
    });
  }

  async function run(action: () => Promise<PosWorkspace | undefined>) {
    setMessage('');
    const started = scopeRef.current;
    const hadActiveWorkspace = Boolean(active);
    try {
      const workspace = await action();
      if (started === scopeRef.current) setLeaseWait(null);
      if (workspace && !hadActiveWorkspace && started === scopeRef.current)
        setActiveId((current) => current ?? workspace.id);
      return workspace;
    } catch (error) {
      if (started === scopeRef.current) {
        const conflict = leaseConflict(error);
        // Without strict locks the page takes the draft back by itself.
        // The refused action is not retried: the cashier repeats it.
        if (!strictLeaseRef.current && conflict?.reason === 'lease_stale') {
          autoClaimed.current = null;
          setMessage(t('leaseRetaken'));
          return;
        }
        setMessage(
          error instanceof DraftReplayRefused
            ? t('draftReplayRefused')
            : describeTraceFailure(error, t),
        );
        if (conflict?.reason === 'lease_busy' && active)
          setLeaseWait({ workspaceId: active.id, until: Date.now() + conflict.seconds * 1000 });
      }
    }
  }

  function hideWorkspace(workspaceId: string) {
    // Read the latest list: an async close may finish after other tabs closed.
    const next = [...hiddenRef.current, workspaceId];
    hiddenRef.current = next;
    setHidden(next);
    workspaces.rememberClosed(next);
    if (workspaceId === activeIdRef.current || workspaceId === active?.id) {
      activeIdRef.current = null;
      setActiveId(null);
      workspaces.rememberView(null, workspaces.page);
    }
    if (staffId && storeId) {
      workspaces.remember(workspaces.rememberedIds().filter((id) => id !== workspaceId));
    }
    setCloseRequest((current) => (current?.workspace.id === workspaceId ? null : current));
    // The counter always keeps one invoice open: closing the last tab starts a
    // fresh draft. Read the latest rows; an async close may finish late.
    if (canCreate && !rowsRef.current.some((row) => !next.includes(row.id))) createDraft();
  }

  // An order picked on the floor (or just seated) opens for selling, even one
  // whose tab was closed here before.
  function selectOrder(workspaceId: string) {
    if (hiddenRef.current.includes(workspaceId)) {
      const next = hiddenRef.current.filter((id) => id !== workspaceId);
      hiddenRef.current = next;
      setHidden(next);
      workspaces.rememberClosed(next);
    }
    activeIdRef.current = workspaceId;
    setActiveId(workspaceId);
    workspaces.rememberView(workspaceId, workspaces.page);
    setFloorChoice(false);
  }

  const canCreate = Boolean(
    !channelUnavailable &&
      !locked &&
      selectionComplete &&
      data?.shift &&
      data.shift.owner_id === data.staff.id,
  );

  function createDraft() {
    if (!canCreate || creating) return;
    const started = scopeRef.current;
    const selectedAtStart = activeIdRef.current;
    setCreating(true);
    void run(() => workspaces.create(selection.registerId)).then((created) => {
      setCreating(false);
      if (created && started === scopeRef.current && selectedAtStart === activeIdRef.current) {
        setActiveId(created.id);
        workspaces.rememberView(created.id, workspaces.page);
      }
    });
  }

  // Only the lease holder may cancel, and recorded payments must be settled first.
  function cancellable(workspace: PosWorkspace) {
    return (
      workspaces.owns(workspace) &&
      !locked &&
      workspace.operational_status === 'editing' &&
      !workspace.payments
    );
  }

  async function cancelAndHide(workspace: PosWorkspace) {
    await command(workspace, (current) => workspaces.change(current, 'cancel'));
    hideWorkspace(workspace.id);
  }

  // A blank tab is discarded at once; a tab holding work asks first.
  async function requestClose(summary: PosWorkspace) {
    if (closing) return;
    if (workspaceIsSettled(summary)) {
      hideWorkspace(summary.id);
      return;
    }
    setClosing(summary.id);
    setMessage('');
    try {
      const detail =
        active && active.id === summary.id && active.line_items
          ? active
          : await workspaces.detail(summary.id);
      if (workspaceHasContent(detail)) {
        setCloseRequest({ workspace: detail });
        return;
      }
      if (cancellable(detail)) {
        // Best effort: a lapsed lease leaves the empty draft on the server, hidden here.
        await cancelAndHide(detail).catch(() => hideWorkspace(detail.id));
      } else hideWorkspace(detail.id);
    } catch (error) {
      setMessage(describeFailure(error, t));
    } finally {
      setClosing(null);
    }
  }

  const sendScan = useRef<(intent: ScanIntent) => Promise<ScanResult>>(async () => 'rejected');
  sendScan.current = async ({ workspaceId, barcode: code, sequence }) => {
    const notify = (text: string, added = false) => {
      noticeSeq.current += 1;
      setScanNotice({ seq: noticeSeq.current, code, message: text, added });
    };
    const block = () => setBlockedScans((current) => ({ ...current, [workspaceId]: code }));
    const base = serializer.latest(workspaceId);
    if (!base) {
      notify(t('scanRejected', { code, reason: t('missing') }));
      return 'rejected';
    }
    const planKey = `${workspaceId}:${sequence}`;
    let plan = scanPlans.current.get(planKey);
    if (!plan) {
      let found: ScanOutcome;
      try {
        found = await resolveScan(
          code,
          (barcode) => parseMeasurementBarcode(base.branch_id, barcode),
          ({ q, barcode }) =>
            fetchCatalogPage(base.branch_id, { q, barcode, limit: SCAN_LOOKUP_LIMIT }),
        );
      } catch (error) {
        if (posFailureKey(error) === 'offline') {
          block();
          return 'unknown';
        }
        notify(t('scanRejected', { code, reason: describeFailure(error, t) }));
        return 'rejected';
      }
      if (found.kind === 'label_invalid') {
        notify(t('scanLabelRejected', { code, reason: found.message ?? t('scanLabelUnreadable') }));
        return 'rejected';
      }
      if (found.kind !== 'match' && found.kind !== 'label') {
        notify(
          t(
            found.kind === 'ambiguous'
              ? 'scanAmbiguous'
              : found.kind === 'no_price'
                ? 'scanNoPrice'
                : 'scanNotFound',
            { code },
          ),
        );
        return 'rejected';
      }
      plan =
        found.kind === 'label'
          ? { kind: 'label', barcode: found.label.barcode, eventId: crypto.randomUUID() }
          : { kind: 'variant', variantId: found.item.id };
      scanPlans.current.set(planKey, plan);
    }
    const attempt = plan;
    try {
      await command(base, (latest) => {
        // Bind the first attempt to the newest workspace; a retry reuses it.
        attempt.workspace ??= latest;
        return attempt.kind === 'label'
          ? workspaces.addLabelItem(attempt.workspace, attempt.barcode, attempt.eventId)
          : workspaces.addItem(attempt.workspace, attempt.variantId, 1, { merge: true });
      });
    } catch (error) {
      if (posFailureKey(error) === 'offline') {
        block();
        return 'unknown';
      }
      scanPlans.current.delete(planKey);
      notify(t('scanRejected', { code, reason: describeTraceFailure(error, t) }));
      return 'rejected';
    }
    scanPlans.current.delete(planKey);
    notify('', true);
    return 'applied';
  };
  const [scanner] = useState(() => createScannerQueue((intent) => sendScan.current(intent)));
  // The register's calibrated terminator and timing (device setting).
  const calibration = useScannerCalibration(selection.registerId);
  const keyBuffer = useMemo(
    () =>
      createScannerKeyBuffer({
        terminator: calibration.terminator,
        maxGapMs: calibration.maxGapMs,
      }),
    [calibration.terminator, calibration.maxGapMs],
  );
  const [prebillOpen, setPrebillOpen] = useState(false);
  // The sent line whose items are being voided.
  const [voiding, setVoiding] = useState<PosLineItem | null>(null);
  const kitchenOn = data?.modules?.['fnb.kitchen'] === true;
  // Course, seat and buffet cover of the next dishes, per table order.
  const [placementOf, setPlacementOf] = useState<{ id: string; value: TablePlacement } | null>(
    null,
  );
  const placement: TablePlacement =
    active && placementOf?.id === active.id ? placementOf.value : {};
  const setPlacement = (value: TablePlacement) => {
    if (active) setPlacementOf({ id: active.id, value });
  };
  const tableAddExtra = <T extends object>(extra: T) =>
    active && activeTable.table && kitchenOn ? { ...extra, placement } : extra;
  const enqueueScan = useRef<(code: string) => void>(() => undefined);
  enqueueScan.current = (code) => {
    if (!active || !editable || channelUnavailable) return;
    serializer.observe(active);
    scanner.enqueue(active.id, code);
  };
  const scanTarget = editable && !channelUnavailable ? (active?.id ?? null) : null;
  useEffect(() => {
    keyBuffer.reset();
    if (!scanTarget) return;
    const capture = (event: KeyboardEvent) => {
      const code = keyBuffer.push(event, shouldCaptureScannerKey(event));
      if (code === null) return;
      // The scanner's Enter must not also activate whatever button has focus.
      event.preventDefault();
      enqueueScan.current(code);
    };
    window.addEventListener('keydown', capture);
    return () => window.removeEventListener('keydown', capture);
  }, [scanTarget, keyBuffer]);

  return (
    <section className="draft-workspace" aria-label={t('draftList')}>
      <div className="draft-toolbar">
        {tabSurface ? (
          <button
            type="button"
            className="floor-toggle"
            aria-pressed={showTabs}
            onClick={() => {
              setTabsChoice(!showTabs);
              if (!showTabs && showFloor) setFloorChoice(false);
            }}
          >
            <PosIcon name={showTabs ? 'back' : 'grid'} />{' '}
            {showTabs ? t('tableBackToSale') : t('tabListTitle')}
          </button>
        ) : null}
        {tableSurface ? (
          <button type="button" className="floor-toggle" onClick={() => setFloorChoice(!showFloor)}>
            <PosIcon name={showFloor ? 'back' : 'grid'} />{' '}
            {showFloor ? t('tableBackToSale') : t('tableFloorOpen')}
          </button>
        ) : null}
        <button
          type="button"
          disabled={busy || !canCreate}
          onClick={() => {
            createDraft();
            if (showFloor) setFloorChoice(false);
          }}
        >
          <PosIcon name="plus" /> {t('newDraft')}
        </button>
        <details className="draft-filter">
          <summary title={t('search')}>
            <PosIcon name="search" />
            <span className="visually-hidden">{t('search')}</span>
          </summary>
          <label>
            {t('search')}
            <input value={query} onChange={(event) => setQuery(event.target.value)} />
          </label>
        </details>
        {hidden.length > 0 ? (
          <button
            type="button"
            onClick={() => {
              setHidden([]);
              workspaces.rememberClosed([]);
            }}
          >
            {t('showClosedViews')}
          </button>
        ) : null}
        <div className="tablist" ref={tablist} role="tablist" aria-label={t('draftList')}>
          {visible.map((workspace) => {
            const phase = workspacePhase(workspace.id === active?.id ? active : workspace);
            const seat = tableOrderOf(workspace);
            return (
              <span key={workspace.id} className="workspace-tab" role="presentation">
                <button
                  type="button"
                  role="tab"
                  aria-label={t('invoiceTab', { number: tabNumbers[workspace.id] })}
                  aria-description={t(`workspacePhase_${phase}`)}
                  data-workspace-id={workspace.id}
                  title={t(`workspacePhase_${phase}`)}
                  aria-selected={workspace.id === active?.id}
                  onClick={() => {
                    setActiveId(workspace.id);
                    workspaces.rememberView(workspace.id, workspaces.page);
                    if (showFloor) setFloorChoice(false);
                  }}
                >
                  <strong>{t('invoiceTab', { number: tabNumbers[workspace.id] })}</strong>
                  {/* The table a table order is served at. */}
                  {seat.table ? (
                    <span className="workspace-table-name">
                      {tableOrderName(seat.table.name, seat.label)}
                    </span>
                  ) : isTab(workspace) ? (
                    <span className="workspace-table-name">{workspace.tab_name}</span>
                  ) : null}
                  {/* The call number the counter calls out, once the order has one. */}
                  {workspace.order_number != null ? (
                    <span className="workspace-call-number" data-testid="tab-call-number">
                      {t('callNumberShort', { number: workspace.order_number })}
                    </span>
                  ) : null}
                  {/* Selling is the default; only a state that changes what to do is badged. */}
                  {phase === 'editing' ? null : (
                    <span className={`workspace-phase workspace-phase-${phase}`} aria-hidden="true">
                      {t(`workspacePhase_${phase}`)}
                    </span>
                  )}
                </button>
                <button
                  type="button"
                  className="workspace-tab-close"
                  aria-label={t('closeTabAction', { number: tabNumbers[workspace.id] })}
                  title={t('closeTabAction', { number: tabNumbers[workspace.id] })}
                  disabled={closing === workspace.id || Boolean(pendingCounts[workspace.id])}
                  onClick={() => void requestClose(workspace)}
                >
                  <PosIcon name="close" />
                </button>
              </span>
            );
          })}
        </div>
      </div>
      {closeRequest ? (
        <CloseTabDialog
          workspace={closeRequest.workspace}
          number={tabNumbers[closeRequest.workspace.id]}
          canCancel={cancellable(closeRequest.workspace)}
          busy={closing === closeRequest.workspace.id}
          onDismiss={() => setCloseRequest(null)}
          onKeep={() => hideWorkspace(closeRequest.workspace.id)}
          onCancelInvoice={() => {
            const target = closeRequest.workspace;
            setClosing(target.id);
            void run(() => cancelAndHide(target).then(() => undefined)).finally(() => {
              setClosing(null);
              setCloseRequest((current) => (current?.workspace.id === target.id ? null : current));
            });
          }}
        />
      ) : null}
      {overflow > 0 ? (
        <label>
          {t('moreDrafts')}
          <select
            value={active?.id ?? ''}
            onChange={(event) => {
              setActiveId(event.target.value || null);
              workspaces.rememberView(event.target.value || null, workspaces.page);
            }}
          >
            <option value="">{t('chooseDraft')}</option>
            {rows.map((workspace) => (
              <option key={workspace.id} value={workspace.id}>
                {t('invoiceTab', { number: tabNumbers[workspace.id] })}
              </option>
            ))}
          </select>
        </label>
      ) : null}
      {(workspaces.query.data?.meta.pages ?? 1) > 1 ? (
        <div className="row">
          <button
            type="button"
            disabled={workspaces.page <= 1}
            onClick={() => {
              setActiveId(null);
              workspaces.rememberView(null, workspaces.page - 1);
              workspaces.setPage(workspaces.page - 1);
            }}
          >
            {t('previousPage')}
          </button>
          <span>
            {workspaces.page} / {workspaces.query.data?.meta.pages || 1}
          </span>
          <button
            type="button"
            disabled={workspaces.page >= (workspaces.query.data?.meta.pages ?? 1)}
            onClick={() => {
              setActiveId(null);
              workspaces.rememberView(null, workspaces.page + 1);
              workspaces.setPage(workspaces.page + 1);
            }}
          >
            {t('nextPage')}
          </button>
        </div>
      ) : null}
      {!selectionComplete ? (
        <p className="workspace-hint" role="status">
          {t('workspaceChooseContext')}
        </p>
      ) : !data?.shift ? (
        <p className="workspace-hint" role="status">
          {t('workspaceNeedShift')}
        </p>
      ) : data.shift.owner_id !== data.staff.id ? (
        <p className="workspace-hint" role="status">
          {t('workspaceShiftOwned')}
        </p>
      ) : null}
      {data?.store.currency &&
      data.shift?.currency &&
      data.shift.currency !== data.store.currency ? (
        <p className="workspace-hint" role="status">
          {t('workspaceCurrencyChanged', {
            currency: data.shift.currency,
            current: data.store.currency,
          })}
        </p>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {workspaces.query.isLoading ? <p role="status">{t('workspaceLoading')}</p> : null}
      {workspaces.query.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(workspaces.query.error))}
        </p>
      ) : null}
      {workspaces.selectedQuery.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(workspaces.selectedQuery.error))}
        </p>
      ) : null}
      {active &&
      !isEditor &&
      active.operational_status !== 'canceled' &&
      (strictLease || autoClaimFailed === active.id) ? (
        <div className="lease-notice" role="status">
          <span>{t('leaseReadOnly')}</span>
          {leaseWait?.workspaceId === active.id ? (
            <span className="lease-wait" role="status">
              {t(leaseSeconds > 0 ? 'leaseRetryIn' : 'leaseRetryReady', { seconds: leaseSeconds })}
            </span>
          ) : null}
          <details className="lease-help">
            <summary>{t('leaseWhy')}</summary>
            <p>{t('leaseExplanation')}</p>
            <p>{t('leaseInstruction')}</p>
          </details>
          <button
            type="button"
            disabled={locked || busy || (leaseWait?.workspaceId === active.id && leaseSeconds > 0)}
            onClick={() => void run(() => command(active, (current) => workspaces.claim(current)))}
          >
            {t('claimLease')}
          </button>
          {data?.capabilities.includes('pos.workspace.takeover') ? (
            <button
              type="button"
              disabled={locked || busy}
              onClick={() =>
                void run(() => command(active, (current) => workspaces.claim(current, true)))
              }
            >
              {t('takeoverLease')}
            </button>
          ) : null}
        </div>
      ) : null}
      {active && (activePhase === 'parked' || workspaceIsSettled(active)) ? (
        <div className={`lease-notice phase-notice phase-notice-${activePhase}`} role="status">
          <span>{t(`workspacePhaseHint_${activePhase}`)}</span>
          {activePhase === 'parked' ? null : (
            <button type="button" onClick={() => hideWorkspace(active.id)}>
              {t('closeView')}
            </button>
          )}
        </div>
      ) : null}
      {platformOrders && selectionComplete ? (
        <PlatformOrderTray
          key={`${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          registerId={selection.registerId}
          canEnter={Boolean(
            data?.shift && data.shift.owner_id === data.staff.id && !locked && !channelUnavailable,
          )}
          canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
        />
      ) : null}
      {showTabs ? (
        <TabList
          key={`tabs:${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          storeId={storeId}
          currency={data?.store.currency ?? 'VND'}
          canOpen={canServeTables(data) && !locked && selectionComplete}
          onOpenTab={async (name) => {
            const created = await workspaces.openTab(name);
            selectOrder(created.id);
            setTabsChoice(false);
          }}
          onSelectOrder={(id) => {
            selectOrder(id);
            setTabsChoice(false);
          }}
        />
      ) : showFloor && tableSurface ? (
        <TableFloor
          key={`${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          surface={tableSurface}
          onSurface={setSavedSurface}
          canServe={canServeTables(data)}
          locked={locked || !selectionComplete}
          onOpenTable={async (table, input) => {
            const created = await workspaces.openTable(table.id, input);
            selectOrder(created.id);
          }}
          onSelectOrder={selectOrder}
          canTime={canRunClock(data)}
          onStartClock={async (table) => {
            const started = await workspaces.startClock(table.id, table.orders.length === 0);
            selectOrder(started.id);
          }}
        />
      ) : (
        <>
          <nav className="sale-panel-nav" aria-label={t('sellingArea')}>
            {[
              ['pos-catalog', 'catalogTitle'],
              ['pos-basket', 'basketTitle'],
              ['pos-checkout', 'checkoutTitle'],
            ].map(([id, label]) => (
              <a
                key={id}
                href={`#${id}`}
                onClick={(event) => {
                  event.preventDefault();
                  document
                    .getElementById(id)
                    ?.scrollIntoView({ block: 'nearest', inline: 'start' });
                }}
              >
                {t(label)}
              </a>
            ))}
          </nav>
          <div className="sale-layout">
            <section
              className="selling-panel catalog-panel"
              id="pos-catalog"
              aria-label={t('catalogTitle')}
            >
              {active && blockedScans[active.id] ? (
                <div className="workspace-hint" role="alert">
                  <span>
                    {t('scanUnknown', {
                      code: blockedScans[active.id],
                      count: scanner.snapshot(active.id).pending.length,
                    })}
                  </span>
                  <button
                    type="button"
                    onClick={() => {
                      setBlockedScans((current) => {
                        const next = { ...current };
                        delete next[active.id];
                        return next;
                      });
                      scanner.retry(active.id);
                    }}
                  >
                    {t('scanRetry')}
                  </button>
                </div>
              ) : null}
              {mealAccounts ? (
                <ScanInput
                  key={`meal-scan:${storeId}:${selection.branchId}`}
                  branchId={selection.branchId}
                  workspace={active}
                  disabled={!editable || channelUnavailable}
                  onSwipe={(input) => {
                    if (!active) return Promise.reject(new Error('workspace-required'));
                    return command(active, async (current) => {
                      const swiped = await workspaces.mealSwipe(current, input);
                      return swiped.workspace;
                    });
                  }}
                  onBarcode={
                    editable && !channelUnavailable
                      ? (code) => enqueueScan.current(code)
                      : undefined
                  }
                  barcodeNotice={menuSurface ? scanNotice : null}
                />
              ) : null}
              {vehicleCommission ? (
                <VehicleVisitBar
                  key={`vehicle-bar:${storeId}:${selection.branchId}`}
                  branchId={selection.branchId}
                  staffId={staffId}
                  storeId={storeId}
                  workspace={active}
                  disabled={!editable || channelUnavailable}
                  onAttach={(visitId) => {
                    if (!active) return Promise.reject(new Error('workspace-required'));
                    return command(active, (current) => workspaces.vehicleVisit(current, visitId));
                  }}
                />
              ) : null}
              {menuSurface ? (
                <MenuGrid
                  key={`${storeId}:${selection.branchId}`}
                  branchId={selection.branchId}
                  addDisabled={quickAddDisabled}
                  addDisabledReason={lockReason}
                  drinksFirst={isTab(active)}
                  canSetSoldOut={Boolean(
                    data?.capabilities.includes('pos.menu.sold_out') ||
                      data?.capabilities.includes('pos.menu.manage'),
                  )}
                  onAdd={
                    active
                      ? (variantId, extra) =>
                          command(active, (current) =>
                            workspaces.addItem(current, variantId, 1, tableAddExtra(extra)),
                          )
                      : undefined
                  }
                />
              ) : (
                <CatalogSearch
                  key={`${storeId}:${selection.branchId}`}
                  storeId={storeId}
                  branchId={selection.branchId}
                  workspaceId={active?.id ?? null}
                  addDisabled={quickAddDisabled}
                  addDisabledReason={lockReason}
                  scanNotice={scanNotice}
                  soldOutVariantIds={soldOut}
                  onScan={
                    editable && !channelUnavailable
                      ? (code) => enqueueScan.current(code)
                      : undefined
                  }
                  scanTerminator={calibration.terminator}
                  onAdd={active ? (variantId) => quickAdd(active, variantId) : undefined}
                  onAddForm={
                    active
                      ? (variantId, quantity, extra) =>
                          command(active, (current) =>
                            workspaces.addItem(current, variantId, quantity, extra),
                          )
                      : undefined
                  }
                />
              )}
            </section>
            <section
              className="selling-panel basket-panel"
              id="pos-basket"
              aria-label={t('basketTitle')}
            >
              <div className="basket-heading">
                <h2>{t('basketTitle')}</h2>
                {active ? (
                  <span
                    className={`workspace-phase workspace-phase-${activePhase}`}
                    role="status"
                    title={t(`workspacePhaseHint_${activePhase}`)}
                  >
                    {t(`workspacePhase_${activePhase}`)}
                  </span>
                ) : null}
                {active ? (
                  <span>
                    {active.line_items?.length ?? 0} {t('basketLines')}
                  </span>
                ) : null}
                {active ? (
                  <div className="row basket-actions">
                    <button
                      type="button"
                      disabled={
                        busy || locked || !isEditor || active.operational_status === 'canceled'
                      }
                      onClick={() =>
                        void run(() =>
                          command(active, (current) =>
                            workspaces.change(
                              current,
                              current.operational_status === 'parked' ? 'reopen' : 'park',
                            ),
                          ),
                        )
                      }
                    >
                      {t(active.operational_status === 'parked' ? 'reopenDraft' : 'park')}
                    </button>
                    <details className="order-more">
                      <summary>
                        {t('orderMore')} <PosIcon name="chevron" />
                      </summary>
                      <div className="order-more-menu">
                        <button
                          type="button"
                          disabled={
                            busy ||
                            locked ||
                            !isEditor ||
                            active.operational_status === 'canceled' ||
                            active.payments
                          }
                          title={active.payments ? t('cancelDraftPayments') : undefined}
                          onClick={() => {
                            if (window.confirm(t('cancelDraftConfirm', { order: active.order_id })))
                              void run(() =>
                                command(active, (current) => workspaces.change(current, 'cancel')),
                              );
                          }}
                        >
                          {t('cancelDraft')}
                        </button>
                        <button type="button" onClick={() => hideWorkspace(active.id)}>
                          {t('closeView')}
                        </button>
                        <button
                          type="button"
                          disabled={active.operational_status !== 'editing'}
                          onClick={() => setPrebillOpen(true)}
                        >
                          {t('receiptPrebillOpen')}
                        </button>
                      </div>
                    </details>
                    {prebillOpen && active.operational_status === 'editing' ? (
                      <PrebillDialog
                        workspace={active}
                        names={{
                          storeName: data?.store.name,
                          branchName: data?.branches.find((row) => row.id === active.branch_id)
                            ?.name,
                          registerName: data?.registers.find((row) => row.id === active.register_id)
                            ?.name,
                        }}
                        timeZone={
                          data?.branches.find((row) => row.id === active.branch_id)?.timezone ??
                          data?.store.timezone ??
                          'Asia/Ho_Chi_Minh'
                        }
                        record={postpay && activeTable.table !== null}
                        staffId={staffId}
                        canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
                        onClose={() => setPrebillOpen(false)}
                      />
                    ) : null}
                  </div>
                ) : null}
              </div>
              {active && activeTable.table ? (
                <TableOrderBar
                  key={active.id}
                  workspace={active}
                  branchId={selection.branchId}
                  staffId={staffId}
                  editDisabled={editDisabled}
                  actionDisabled={locked || busy}
                  canWaive={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                  canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
                  postpay={postpay}
                  onMove={(resourceId) =>
                    command(active, (current) => workspaces.moveTable(current, resourceId))
                  }
                  onMerge={async (targetId) => {
                    const target = await command(active, (current) =>
                      workspaces.mergeTable(current, targetId),
                    );
                    selectOrder(target.id);
                  }}
                  onSplit={(input) =>
                    command(
                      active,
                      async (current) => (await workspaces.splitTable(current, input)).workspace,
                    )
                  }
                  onSplitBySeat={
                    kitchenOn
                      ? (shared) =>
                          command(
                            active,
                            async (current) =>
                              (await workspaces.splitBySeat(current, shared)).workspace,
                          )
                      : undefined
                  }
                  onServiceCharge={(waived) =>
                    command(active, (current) => workspaces.setServiceCharge(current, waived))
                  }
                  onRequestPayment={() =>
                    command(active, (current) => workspaces.requestPayment(current))
                  }
                  onResolvePayment={(status) =>
                    command(active, (current) => workspaces.resolvePaymentRequest(current, status))
                  }
                  onPrebillChanged={() => void workspaces.refresh()}
                />
              ) : null}
              {active && activeTable.table && kitchenOn && !active.payments ? (
                <div className="table-service-panel">
                  <CourseSeatPicker
                    workspace={active}
                    value={placement}
                    onChange={setPlacement}
                    disabled={!canAppend || busy}
                    onFire={(course) =>
                      command(active, (current) => workspaces.fireCourse(current, course))
                    }
                  />
                  <BuffetTierPicker
                    workspace={active}
                    branchId={selection.branchId}
                    placement={placement}
                    onPlacement={setPlacement}
                    disabled={!canAppend || busy}
                    onAddCover={(tierId, guests) =>
                      command(active, (current) =>
                        workspaces.addBuffetCover(current, tierId, guests),
                      )
                    }
                  />
                </div>
              ) : null}
              {active ? (
                <article className="draft-detail">
                  {active.order_number != null ? (
                    <p
                      className={`call-number-banner${
                        active.operational_status === 'completed' ? ' call-number-banner-done' : ''
                      }`}
                      data-testid="call-number"
                    >
                      {t('callNumber', { number: active.order_number })}
                      {active.guest_name ? <small> · {active.guest_name}</small> : null}
                    </p>
                  ) : null}
                  {callNumbers || cupLabels ? (
                    <GuestNameField
                      key={`:guest:${active.guest_name ?? ''}`}
                      workspace={active}
                      disabled={sourceDisabled}
                      disabledReason={lockReason}
                      onSave={(guestName) =>
                        command(active, (current) => workspaces.setGuestName(current, guestName))
                      }
                    />
                  ) : null}
                  <OrderLines
                    key={active.id}
                    workspace={active}
                    disabled={editDisabled}
                    disabledReason={lockReason}
                    appendOnly={canAppend && !busy}
                    onVoid={kitchenOn && !active.payments ? setVoiding : undefined}
                    onStale={() => void workspaces.refresh()}
                    canApplyDiscount={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                    canOverridePrice={Boolean(data?.capabilities.includes('pos.price.override'))}
                    onUpdate={(lineId, input) =>
                      command(active, (current) => workspaces.updateItem(current, lineId, input))
                    }
                    onRemove={(lineId) =>
                      command(active, (current) => workspaces.removeItem(current, lineId))
                    }
                    onLineDiscount={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.lineDiscount(current, saleLineId, input),
                      )
                    }
                    onClearLineDiscount={(saleLineId, approvalId) =>
                      command(active, (current) =>
                        workspaces.clearLineDiscount(current, saleLineId, approvalId),
                      )
                    }
                    onPriceOverride={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.priceOverride(current, saleLineId, input),
                      )
                    }
                    menu={menuSurface ? (menu.data ?? null) : null}
                    onUpdateModifiers={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.updateModifiers(current, saleLineId, input),
                      )
                    }
                    onAddSame={(variantId, input) =>
                      command(active, (current) =>
                        workspaces.addItem(current, variantId, 1, { ...input, merge: true }),
                      )
                    }
                    cupLabels={cupLabels}
                  />
                  {voiding?.sale_line_id ? (
                    <VoidItemDialog
                      key={voiding.id}
                      line={voiding}
                      reasons={voidReasons(
                        data?.branches.find((row) => row.id === active.branch_id),
                      )}
                      canVoid={Boolean(data?.capabilities.includes('pos.kitchen.void'))}
                      onVoid={(input) =>
                        command(active, (current) =>
                          workspaces.voidSent(current, voiding.sale_line_id as string, input),
                        )
                      }
                      onClose={() => setVoiding(null)}
                    />
                  ) : null}
                  {lockReason && isEditor ? (
                    <p className="workspace-hint" role="status">
                      {lockReason}
                    </p>
                  ) : null}
                  {busy || commandQueue.hasPending(active.id) ? (
                    <p className="muted" role="status">
                      {t('waiting')}
                    </p>
                  ) : null}
                </article>
              ) : (
                <div className="empty">
                  <strong>{t('basketEmpty')}</strong>
                  <p>{t('basketStart')}</p>
                </div>
              )}
            </section>
            <aside
              className="checkout-panel"
              id="pos-checkout"
              tabIndex={-1}
              aria-label={t('checkoutTitle')}
            >
              {active ? (
                <div className="checkout-section" key={active.id}>
                  <CustomerPanel
                    key={active.id}
                    workspace={active}
                    branchId={selection.branchId}
                    storeId={storeId}
                    canCreate={Boolean(data?.capabilities.includes('pos.customer.write'))}
                    disabled={editDisabled}
                    disabledReason={lockReason}
                    onAssign={(profileId) =>
                      command(active, (current) => workspaces.assignCustomer(current, profileId))
                    }
                    onClear={() => command(active, (current) => workspaces.clearCustomer(current))}
                  />
                  <ServiceModeControl
                    value={active.service_mode}
                    enabled={data?.modules?.['fnb.menu'] === true}
                    disabled={sourceDisabled}
                    onPick={(mode) =>
                      void run(() =>
                        command(active, (current) => workspaces.setServiceMode(current, mode)),
                      )
                    }
                  />
                  <OrderSourcePicker
                    value={active.order_source}
                    disabled={sourceDisabled}
                    onPick={(source) =>
                      void run(() =>
                        command(active, (current) => workspaces.setOrderSource(current, source)),
                      )
                    }
                  />
                  <section className="checkout-totals" aria-label={t('orderDetails')}>
                    <div className="checkout-totals-header">
                      <h2>{t('orderDetails')}</h2>
                      <div className="checkout-tools">
                        <details className="checkout-optional" ref={discountDetailsRef}>
                          <summary title={lockReason}>
                            <PosIcon name="edit" /> {t('discountTitle')}
                          </summary>
                          <div className="pos-popup-backdrop">
                            <DiscountForm
                              key={`${active.id}:${active.revision}:${active.discount?.id ?? 'new'}:${active.coupon?.code ?? 'no-coupon'}`}
                              workspace={active}
                              canApply={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                              disabled={editDisabled}
                              disabledReason={lockReason}
                              onApply={(input) =>
                                command(active, (current) => workspaces.discount(current, input))
                              }
                              onClear={(approvalId) =>
                                command(active, (current) =>
                                  workspaces.clearDiscount(current, approvalId),
                                )
                              }
                              onApplyCoupon={(code) =>
                                command(active, (current) => workspaces.applyCoupon(current, code))
                              }
                              onClearCoupon={() =>
                                command(active, (current) => workspaces.clearCoupon(current))
                              }
                              onClose={() => {
                                if (discountDetailsRef.current)
                                  discountDetailsRef.current.open = false;
                              }}
                            />
                          </div>
                        </details>
                        <details className="checkout-optional" ref={noteDetailsRef}>
                          <summary title={lockReason}>
                            <PosIcon name="edit" /> {t('noteTitle')}
                          </summary>
                          <div className="pos-popup-backdrop">
                            <NoteForm
                              key={`${active.id}:note:${active.note ?? ''}`}
                              workspace={active}
                              disabled={editDisabled}
                              disabledReason={lockReason}
                              onSave={(note) =>
                                command(active, (current) => workspaces.updateNote(current, note))
                              }
                              onClose={() => {
                                if (noteDetailsRef.current) noteDetailsRef.current.open = false;
                              }}
                            />
                          </div>
                        </details>
                        {/* Delivery orders (`delivery` switch); an order already
                        marked keeps the entry so it can be undone. */}
                        {data?.features?.delivery === true || active.delivery ? (
                          <details className="checkout-optional" ref={deliveryDetailsRef}>
                            <summary title={lockReason}>
                              <PosIcon name="box" /> {t('deliveryTitle')}
                            </summary>
                            <div className="pos-popup-backdrop">
                              <DeliveryForm
                                key={`${active.id}:delivery:${active.revision}`}
                                workspace={active}
                                disabled={editDisabled}
                                disabledReason={lockReason}
                                onSave={(input) =>
                                  command(active, (current) =>
                                    workspaces.setDelivery(current, input),
                                  )
                                }
                                onClear={() =>
                                  command(active, (current) => workspaces.clearDelivery(current))
                                }
                                onClose={() => {
                                  if (deliveryDetailsRef.current)
                                    deliveryDetailsRef.current.open = false;
                                }}
                              />
                            </div>
                          </details>
                        ) : null}
                      </div>
                    </div>
                    {active.totals ? (
                      <>
                        <div className="checkout-line">
                          <span>{t('subtotal')}</span>
                          <strong>
                            {formatMoney(active.totals.item_total, active.totals.currency)}
                          </strong>
                        </div>
                        <div className="checkout-line">
                          <span>
                            {t('discount')}{' '}
                            {active.coupon ? (
                              <small className="item-discount-source">{active.coupon.code}</small>
                            ) : null}
                          </span>
                          <strong>
                            {formatMoney(active.totals.discount_total, active.totals.currency)}
                          </strong>
                        </div>
                        {active.delivery ? (
                          <div className="checkout-line">
                            <span>
                              {t('deliveryFee')}{' '}
                              <small className="item-discount-source">
                                {active.delivery.deliverer
                                  ? t('deliveryBadgeNamed', { name: active.delivery.deliverer })
                                  : t('deliveryBadge')}
                              </small>
                            </span>
                            <strong>
                              {formatMoney(
                                active.totals.fee_total ?? active.delivery.fee,
                                active.totals.currency,
                              )}
                            </strong>
                          </div>
                        ) : null}
                        {activeTable.serviceCharge?.applies && !activeTable.serviceCharge.waived ? (
                          <div className="checkout-line">
                            <span>
                              {t('tableServiceCharge')}
                              {activeTable.serviceCharge.rate
                                ? ` (${activeTable.serviceCharge.rate.replace(/\.0+$/, '')}%)`
                                : ''}
                            </span>
                            <strong>
                              {formatMoney(
                                activeTable.serviceCharge.amount,
                                active.totals.currency,
                              )}
                            </strong>
                          </div>
                        ) : null}
                        <MinimumSpendLines
                          workspace={active}
                          currency={active.totals.currency}
                          canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
                          disabled={editDisabled}
                          onWaive={(waived, approvalId) =>
                            command(active, (current) =>
                              workspaces.setMinimumSpend(current, waived, approvalId),
                            )
                          }
                        />
                        {(active.totals.taxes ?? []).map((tax) => (
                          <div className="checkout-line" key={`${tax.rate}:${tax.label}`}>
                            <span>
                              {tax.label} ({rateLabel(tax.rate)})
                            </span>
                            <strong>
                              {formatMoney(tax.amount, active.totals?.currency ?? 'VND')}
                            </strong>
                          </div>
                        ))}
                        <div className="checkout-line checkout-total">
                          <span>{t('orderTotal')}</span>
                          <strong>
                            {formatMoney(active.totals.total, active.totals.currency)}
                          </strong>
                        </div>
                      </>
                    ) : (
                      <p>{t('totalsUnavailable')}</p>
                    )}
                  </section>
                  {active.note ? <p className="checkout-note-preview">{active.note}</p> : null}
                  {kitchenOn && data ? (
                    <KitchenHistory
                      workspace={active}
                      manual={
                        data.branches.find((row) => row.id === active.branch_id)
                          ?.kitchen_send_trigger === 'manual'
                      }
                      // Anyone serving a table sends its additions; a counter
                      // order is sent by the person holding it.
                      disabled={
                        activeTable.table
                          ? locked ||
                            busy ||
                            !['editing', 'parked'].includes(active.operational_status)
                          : editDisabled || !isEditor
                      }
                      disabledReason={lockReason}
                      onSend={() =>
                        run(() => command(active, (current) => workspaces.sendToKitchen(current)))
                      }
                    />
                  ) : null}
                  {callNumbers ? <PickupQueue branchId={active.branch_id} /> : null}
                  {active.reservation ? (
                    <ReservationDepositNote
                      workspace={active}
                      disabled={
                        locked || busy || !isEditor || active.operational_status !== 'editing'
                      }
                      onApply={() =>
                        command(active, (current) => workspaces.applyDeposits(current))
                      }
                    />
                  ) : null}
                  {meal ? (
                    <MealBanner
                      workspace={active}
                      meal={meal}
                      staffId={staffId}
                      storeId={storeId}
                      canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
                      drawerOpen={Boolean(
                        data?.shift &&
                          data.shift.id === active.shift_id &&
                          data.shift.owner_id === data.staff.id,
                      )}
                      disabled={locked || busy || !isEditor}
                      command={(action) => command(active, action)}
                    />
                  ) : null}
                  <PaymentPanel
                    workspace={active}
                    mealSponsorAmount={meal?.plan?.sponsor_amount ?? null}
                    staffId={staffId}
                    storeId={storeId}
                    canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
                    canResolve={Boolean(data?.capabilities.includes('pos.payment.resolve'))}
                    canSellCredit={Boolean(data?.capabilities.includes('pos.credit.sell'))}
                    creditEnabled={contextFeature(data, 'credit')}
                    einvoiceType={data?.einvoice_type ?? 'none'}
                    // Only an explicit switch skips the second person.
                    quickCredit={data?.features?.quick_credit === true}
                    // A table order without money yet moves to the shift of whoever
                    // collects it, so the collector's own open drawer is enough.
                    drawerOpen={Boolean(
                      data?.shift &&
                        (data.shift.id === active.shift_id ||
                          (activeTable.table !== null && !active.payments)) &&
                        data.shift.owner_id === data.staff.id,
                    )}
                    disabled={
                      locked ||
                      busy ||
                      !isEditor ||
                      (active.operational_status !== 'editing' &&
                        active.operational_status !== 'completed')
                    }
                    command={(action) => command(active, action)}
                    reserveTrace={(current) => workspaces.reserveTrace(current)}
                    ticketNames={{
                      storeName: data?.store.name,
                      branchName: data?.branches.find((row) => row.id === active.branch_id)?.name,
                      registerName: data?.registers.find((row) => row.id === active.register_id)
                        ?.name,
                      cashier: data?.staff.full_name || data?.staff.email,
                    }}
                    timeZone={
                      data?.branches.find((row) => row.id === active.branch_id)?.timezone ??
                      data?.store.timezone ??
                      'Asia/Ho_Chi_Minh'
                    }
                  />
                  <DisplayPinControl
                    shiftId={data?.shift?.id ?? null}
                    ownsShift={Boolean(data?.shift && data.shift.owner_id === data.staff.id)}
                    enabled={contextFeature(data, 'customer_display')}
                    callBoard={callNumbers}
                    workspace={active}
                  />
                </div>
              ) : (
                <div className="checkout-section">
                  <h2>{t('customerTitle')}</h2>
                  <p className="muted">{t('checkoutChooseDraft')}</p>
                  <div className="checkout-totals">
                    <h2>{t('orderDetails')}</h2>
                    <p className="muted">{t('checkoutNoTotals')}</p>
                  </div>
                  <div className="checkout-totals">
                    <h2>{t('paymentTitle')}</h2>
                    <p className="muted">{t('checkoutNoPayment')}</p>
                  </div>
                </div>
              )}
            </aside>
          </div>
        </>
      )}
    </section>
  );
}
