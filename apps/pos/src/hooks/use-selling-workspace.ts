import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { isTableSurface, sellingSurfaceOf, tableSurfaceOf } from '@parkviet/pos-shared/pos-modules';
import { describeTraceFailure } from '@parkviet/pos-shared/traceability';
import { useNavigate, useSearch } from '@tanstack/react-router';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { ScanNotice } from '../components/catalog-search';
import { usePosSelection } from '../components/pos-selection';
import { useScannerCalibration } from '../components/scanner-calibration';
import { canCollectKioskOrders } from '../lib/kiosk-orders';
import { MEAL_ACCOUNTS_MODULE } from '../lib/meal-accounts';
import { resolveScan, type ScanOutcome } from '../lib/measured-label';
import { soldOutVariantIds } from '../lib/menu-selection';
import {
  type PosLineItem,
  type PosTimedSegment,
  type PosWorkspace,
  writesLocked,
} from '../lib/pos-context';
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
import { appendable } from '../lib/table-kitchen';
import { inSelection, isTableOrder, savedTableSurface, tableOrderOf } from '../lib/tables';
import { VEHICLE_COMMISSION_MODULE } from '../lib/vehicle-visits';
import { workspaceHasContent, workspaceIsSettled, workspacePhase } from '../lib/workspace-content';
import { createWorkspaceSerializer } from '../lib/workspace-serializer';
import { readLayout } from '../lib/workspace-storage';
import { fetchCatalogPage, parseMeasurementBarcode } from './use-catalog';
import { useInvoiceNumbers } from './use-invoice-numbers';
import { useWorkspaceMeal } from './use-meal-accounts';
import { useMenu } from './use-menu';
import { DraftReplayRefused, useWorkspaces } from './use-workspaces';

type ScanPlan = { workspace?: PosWorkspace } & (
  | { kind: 'variant'; variantId: string }
  | { kind: 'label'; barcode: string; eventId: string }
);

// The selling state of the counter: the open workspaces, the selected one,
// the command serializer and lease, the URL `?order`, the scanner and the
// module switches. Both selling layouts draw from it.
// The frame of a layout that has several (the table board, the order, its
// payment); it is written to the URL with the order. The counter has none.
export type SellingView = 'board' | 'order' | 'pay';

export function useSellingWorkspace(options: { view?: SellingView } = {}) {
  const view = options.view;
  // The counter always shows some open invoice: the first tab stands in for
  // a selection that is missing. A layout with frames shows the order it is
  // for or none: another order in its place would take its payment or dishes.
  const fallback = view === undefined;
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
  const activeSummary =
    rows.find((workspace) => workspace.id === activeId) ?? (fallback ? visible[0] : null) ?? null;
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
  // Guests ordering from the table's QR: their orders and calls wait in a tray.
  const guestOrders =
    data?.modules?.['fnb.qr_order'] === true &&
    contextFeature(data, 'qr_order') &&
    Boolean(
      data?.capabilities.some((capability) =>
        ['pos.guest_order.decide', 'pos.table.serve', 'pos.shift.open'].includes(capability),
      ),
    );
  // Self-ordering kiosks: orders left for the counter wait in a tray for a cashier.
  const kioskOrders =
    data?.modules?.['fnb.kiosk'] === true && canCollectKioskOrders(data?.capabilities);
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
  const writtenView = useRef<SellingView | undefined>(search.view);
  // A tab selected for the URL whose render has not happened yet.
  const selecting = useRef<string | null>(null);
  const listLoaded = workspaces.query.isSuccess;
  // Frames only: an order the URL asks for that is not in this register's
  // list (a table order booked on the branch's table register) is looked up
  // among the branch's open orders instead of being dropped.
  const [lookingUp, setLookingUp] = useState<string | null>(null);
  // The order being looked up.
  const lookedUp = useRef<string | null>(null);
  // Once the register is settled (its context says whether a shift is open).
  // Without a shift there is no list; a table order still opens by itself.
  const listSettled = selectionComplete && (listLoaded || !data?.shift);
  function lookUp(wanted: string) {
    lookedUp.current = wanted;
    setLookingUp(wanted);
    const started = scopeRef.current;
    void workspaces
      .findOrder(wanted)
      .then((found) => {
        if (requestedOrder.current !== wanted || started !== scopeRef.current) return;
        requestedOrder.current = null;
        if (
          found &&
          inSelection(found, selection) &&
          (data?.shift || isTableOrder(found)) &&
          found.id !== activeIdRef.current
        ) {
          selecting.current = found.id;
          selectOrder(found.id);
        }
      })
      .catch(() => {
        // Not found or not reachable: the frame goes back to the board.
        if (requestedOrder.current === wanted) requestedOrder.current = null;
      })
      .finally(() => {
        if (lookedUp.current === wanted) lookedUp.current = null;
        setLookingUp((current) => (current === wanted ? null : current));
      });
  }
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
    } else if (!fallback && listSettled) {
      // Once per request: the lookup clears it whatever it finds.
      if (lookedUp.current !== wanted) lookUp(wanted);
    } else if (listLoaded) {
      requestedOrder.current = null;
    }
  });
  // Frames: the selected order is on its way (the URL's order being looked
  // up, or the details of an order outside the list); nothing stands in.
  const activeLoading =
    !fallback &&
    !active &&
    (Boolean(requestedOrder.current) ||
      lookingUp !== null ||
      (activeId !== null &&
        !workspaces.query.isError &&
        !workspaces.selectedQuery.isError &&
        workspaces.selectedQuery.isPending));
  const activeOrder = active?.order_id ?? null;
  useEffect(() => {
    if (requestedOrder.current || activeLoading) return;
    if (selecting.current) {
      if (active?.id !== selecting.current) return;
      selecting.current = null;
    }
    // Already in the URL, or already on its way there.
    if (writtenOrder.current === activeOrder && writtenView.current === view) return;
    writtenOrder.current = activeOrder;
    writtenView.current = view;
    void navigate({
      to: '/',
      search: { ...(activeOrder ? { order: activeOrder } : {}), ...(view ? { view } : {}) },
      replace: true,
    });
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
    // A layout with frames goes back to its board instead.
    if (fallback && canCreate && !rowsRef.current.some((row) => !next.includes(row.id)))
      createDraft();
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

  // Frames: no order is selected any more (it could not be shown).
  function leaveOrder() {
    requestedOrder.current = null;
    selecting.current = null;
    activeIdRef.current = null;
    setActiveId(null);
    workspaces.rememberView(null, workspaces.page);
  }

  const canCreate = Boolean(
    !channelUnavailable &&
      !locked &&
      selectionComplete &&
      data?.shift &&
      data.shift.owner_id === data.staff.id,
  );

  // The new draft, or null when none was created (not allowed, one already
  // on its way, or refused: the refusal is in the page's message).
  function createDraft(): Promise<PosWorkspace | null> {
    if (!canCreate || creating) return Promise.resolve(null);
    const started = scopeRef.current;
    const selectedAtStart = activeIdRef.current;
    setCreating(true);
    return run(() => workspaces.create(selection.registerId)).then((created) => {
      setCreating(false);
      if (created && started === scopeRef.current && selectedAtStart === activeIdRef.current) {
        setActiveId(created.id);
        workspaces.rememberView(created.id, workspaces.page);
      }
      return created ?? null;
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
  // The stretch of a room's clock whose times are being corrected.
  const [editingSegment, setEditingSegment] = useState<{
    sessionId: string;
    segment: PosTimedSegment;
  } | null>(null);
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

  return {
    data,
    selection,
    selectionComplete,
    staffId,
    storeId,
    workspaces,
    locked,
    channelUnavailable,
    query,
    setQuery,
    message,
    pendingCounts,
    serializer,
    scanNotice,
    blockedScans,
    setBlockedScans,
    leaseWait,
    leaseSeconds,
    hidden,
    setHidden,
    closeRequest,
    setCloseRequest,
    closing,
    setClosing,
    rows,
    tabNumbers,
    visible,
    overflow,
    active,
    activeLoading,
    setActiveId,
    isEditor,
    activePhase,
    busy,
    editable,
    editDisabled,
    sourceDisabled,
    canAppend,
    quickAddDisabled,
    lockReason,
    menuSurface,
    menu,
    soldOut,
    callNumbers,
    cupLabels,
    platformOrders,
    guestOrders,
    kioskOrders,
    setSavedSurface,
    tableSurface,
    postpay,
    mealAccounts,
    meal,
    vehicleCommission,
    activeTable,
    tablist,
    showFloor,
    setFloorChoice,
    tabSurface,
    showTabs,
    setTabsChoice,
    strictLease,
    autoClaimFailed,
    command,
    quickAdd,
    run,
    hideWorkspace,
    selectOrder,
    leaveOrder,
    canCreate,
    createDraft,
    cancellable,
    cancelAndHide,
    requestClose,
    scanner,
    calibration,
    prebillOpen,
    setPrebillOpen,
    voiding,
    setVoiding,
    editingSegment,
    setEditingSegment,
    kitchenOn,
    placement,
    setPlacement,
    tableAddExtra,
    enqueueScan,
  };
}
