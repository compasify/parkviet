import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { session } from '../lib/app-session';
import { commandDigest, commandQueue } from '../lib/command-queue';
import type { OrderSource } from '../lib/order-source';
import type { PosModifierSelection, PosWorkspace } from '../lib/pos-context';
import { posWorkspacesKey } from '../lib/query-keys';
import { leaseConflict, posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { beginIntent, finishIntent, forgetIntent, hasIntent } from '../lib/uncertain-intents';
import { writeWorkspaceToCache } from '../lib/workspace-cache';
import { browserWorkspaceChannel, workspaceHint } from '../lib/workspace-channel';
import { readLayout, writeLayout } from '../lib/workspace-storage';
import { useSession } from './use-session';

const channel = browserWorkspaceChannel();

export class DraftReplayRefused extends Error {
  constructor() {
    super('draft-replay-refused');
    this.name = 'DraftReplayRefused';
  }
}
// Per-page, not localStorage/sessionStorage: duplicate tabs must not share an editor.
export const workspaceEditorId = crypto.randomUUID();
const editorId = workspaceEditorId;

type Page = { data: PosWorkspace[]; meta: { page: number; pages: number; count: number } };

function abandonIfNeeded(error: unknown) {
  if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
    session.abandon();
}

export function useWorkspaces(
  storeId: string | null,
  staffId: string | null,
  enabled: boolean,
  branchId: string | null,
  registerId: string | null,
  activeId: string | null,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [owned, setOwned] = useState<Record<string, number>>({});
  useEffect(() => {
    if (!staffId || !storeId) return;
    const saved = readLayout(staffId, storeId);
    setPage(
      saved?.branchId === branchId && saved?.registerId === registerId
        ? (saved.workspacePage ?? 1)
        : 1,
    );
  }, [staffId, storeId, branchId, registerId]);
  const query = useQuery({
    queryKey: [...posWorkspacesKey(snapshot.generation, storeId), branchId, registerId, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(storeId),
    queryFn: async (): Promise<Page> => {
      try {
        return await session.request<Page>('GET', '/pos/workspaces', {
          params: {
            limit: '25',
            page: String(page),
            branch_id: branchId ?? undefined,
            register_id: registerId ?? undefined,
            // Tabs are open work only. A canceled or paid invoice stays on screen
            // while it is the selected tab (see `selectedQuery`) and is reviewed
            // from the orders page afterwards; it never comes back as a tab.
            status: 'editing,parked',
            // Delivery platform orders are worked from their own tray.
            platform: 'exclude',
          },
        });
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
  const detailId =
    activeId ??
    query.data?.data.find(
      (workspace) => workspace.branch_id === branchId && workspace.register_id === registerId,
    )?.id ??
    null;
  const selectedQuery = useQuery({
    queryKey: [
      ...posWorkspacesKey(snapshot.generation, storeId),
      'selected',
      branchId,
      registerId,
      detailId,
    ],
    enabled:
      enabled &&
      snapshot.status === 'authenticated' &&
      Boolean(storeId && branchId && detailId) &&
      query.isSuccess,
    queryFn: async () => {
      try {
        return await session.request<{ data: PosWorkspace }>('GET', `/pos/workspaces/${detailId}`);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });

  async function refresh() {
    await queryClient.invalidateQueries({
      queryKey: posWorkspacesKey(snapshot.generation, storeId),
    });
  }

  async function send(
    workspaceId: string,
    key: string,
    body: Record<string, unknown>,
    path: string,
    method: 'POST' | 'DELETE' | 'PATCH' = 'POST',
  ) {
    const result = await commandQueue.enqueue(workspaceId, key, commandDigest(body), () =>
      session.request<{ data: PosWorkspace }>(method, path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      }),
    );
    await acceptWorkspace(result.data);
    channel?.postMessage(workspaceHint(result.data.id));
    return result.data;
  }

  async function acceptWorkspace(workspace: PosWorkspace) {
    const base = posWorkspacesKey(snapshot.generation, storeId);
    // The mutation already returned the canonical full workspace. Cancel older
    // reads so they cannot replace it, then update the view without two GETs.
    await queryClient.cancelQueries({ queryKey: base });
    writeWorkspaceToCache(queryClient, snapshot.generation, storeId, workspace);
    queryClient.setQueryData(
      [...base, 'selected', branchId, registerId, workspace.id],
      (current: { data: PosWorkspace } | undefined) =>
        current &&
        (current.data.revision > workspace.revision ||
          current.data.lease_generation > workspace.lease_generation)
          ? current
          : { data: workspace },
    );
    void queryClient.invalidateQueries({ queryKey: base, refetchType: 'none' });
    // Creation may change pagination; refresh that list in the background only.
    if (!query.data?.data.some((row) => row.id === workspace.id)) void refresh();
  }

  function release(workspaceId: string, generation?: number) {
    setOwned((current) => {
      if (!(workspaceId in current)) return current;
      if (generation !== undefined && current[workspaceId] !== generation) return current;
      const next = { ...current };
      delete next[workspaceId];
      return next;
    });
  }

  async function sendIntent(
    workspaceId: string,
    body: Record<string, unknown>,
    path: string,
    method: 'POST' | 'DELETE' | 'PATCH' = 'POST',
  ) {
    const { editor_id: _editor, ...stableBody } = body;
    const target = method === 'POST' ? path : `${path}:${method.toLowerCase()}`;
    const intent = JSON.stringify([
      staffId,
      storeId,
      workspaceId,
      target,
      commandDigest(stableBody),
    ]);
    const wasUncertain = hasIntent(intent);
    const key = beginIntent(intent);
    try {
      const result = await send(workspaceId, key, body, path, method);
      forgetIntent(intent);
      return { workspace: result, recovered: false };
    } catch (error) {
      if (posFailureKey(error) === 'conflict') {
        try {
          const receipt = await session.request<{ data: PosWorkspace }>(
            'GET',
            '/pos/command_receipts',
            {
              params: { idempotency_key: key },
            },
          );
          forgetIntent(intent);
          await acceptWorkspace(receipt.data);
          return { workspace: receipt.data, recovered: true };
        } catch {
          // A missing receipt does not prove that the original request will not commit.
        }
      }
      // A lost draft-create replayed after its shift closed is refused (403)
      // instead of answered: nothing new was made, and a draft the first
      // attempt may have made is in the list. Stop retrying and show the list.
      if (wasUncertain && path === '/pos/workspaces' && posFailureKey(error) === 'forbidden') {
        forgetIntent(intent);
        void refresh();
        throw new DraftReplayRefused();
      }
      // A fresh request rejected by the server is not a lost response. Existing
      // uncertain attempts stay until a receipt or an exact retry resolves them.
      if (!wasUncertain && posFailureKey(error) !== 'offline') forgetIntent(intent);
      // Another editor holds the lease now: this page is read-only until it claims again.
      if (leaseConflict(error)?.reason === 'lease_stale') {
        release(workspaceId);
        void refresh();
      }
      throw error;
    } finally {
      finishIntent(intent);
    }
  }

  return {
    query,
    selectedQuery,
    page,
    setPage,
    refresh,
    owns(workspace: PosWorkspace) {
      return owned[workspace.id] === workspace.lease_generation;
    },
    // Full workspace for one tab; list rows omit lines and customer.
    async detail(workspaceId: string) {
      try {
        return (
          await session.request<{ data: PosWorkspace }>('GET', `/pos/workspaces/${workspaceId}`)
        ).data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async create(registerId: string | null) {
      try {
        const { workspace: result, recovered } = await sendIntent(
          registerId ? `register:${registerId}` : `branch:${branchId}`,
          {
            ...(registerId ? { register_id: registerId } : { branch_id: branchId }),
            editor_id: editorId,
          },
          '/pos/workspaces',
        );
        if (!recovered)
          setOwned((current) => ({ ...current, [result.id]: result.lease_generation }));
        return result;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async change(workspace: PosWorkspace, status: 'park' | 'cancel' | 'reopen') {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      try {
        return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/${status}`))
          .workspace;
      } catch (error) {
        if (posFailureKey(error) === 'conflict' || posFailureKey(error) === 'forbidden') {
          release(workspace.id);
          void refresh();
        }
        abandonIfNeeded(error);
        throw error;
      }
    },
    async addItem(
      workspace: PosWorkspace,
      variantId: string,
      quantity = 1,
      extra: Partial<{
        sale_quantity: string;
        sale_unit_code: string;
        lot_code: string;
        expiry_on: string;
        serial_codes: string[];
        price_override: string;
        merge: boolean;
        // Menu lines: absent options mean the item's defaults, [] means none.
        modifiers: PosModifierSelection[];
        note: string;
      }> = {},
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        variant_id: variantId,
        quantity,
        ...extra,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/items`))
        .workspace;
    },
    // The server reads the scale label itself; quantity, price and variant come
    // from the label, never from this client. One measurement id per scan makes
    // a retry an exact replay and a second scan of the same label a new line.
    async addLabelItem(workspace: PosWorkspace, labelBarcode: string, measurementEventId: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        label_barcode: labelBarcode,
        measurement_event_id: measurementEventId,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/items`))
        .workspace;
    },
    async updateItem(
      workspace: PosWorkspace,
      lineItemId: string,
      input: { quantity?: number; sale_quantity?: string },
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        ...input,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${lineItemId}/update`,
        )
      ).workspace;
    },
    // Replaces the options and note of a menu line. The server prices the
    // line again on its base price and may merge it into a twin line.
    async updateModifiers(
      workspace: PosWorkspace,
      saleLineId: string,
      input: { modifiers: PosModifierSelection[]; note: string | null },
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        modifiers: input.modifiers,
        note: input.note ?? undefined,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${saleLineId}/modifiers`,
          'PATCH',
        )
      ).workspace;
    },
    async removeItem(workspace: PosWorkspace, lineItemId: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${lineItemId}/remove`,
        )
      ).workspace;
    },
    // Reserves the FEFO lots and re-reserves the serials of traced lines now,
    // so payment can start; refused with the same trace reasons as payment.
    async reserveTrace(workspace: PosWorkspace) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      return (
        await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/trace_allocations`)
      ).workspace;
    },
    async assignCustomer(workspace: PosWorkspace, profileId: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        profile_id: profileId,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/customer`))
        .workspace;
    },
    async clearCustomer(workspace: PosWorkspace) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      return (
        await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/customer/clear`)
      ).workspace;
    },
    async discount(
      workspace: PosWorkspace,
      input: { valueType: 'flat' | 'percent'; value: string; reason: string; approvalId?: string },
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        value_type: input.valueType,
        value: input.value,
        reason: input.reason,
        approval_id: input.approvalId || undefined,
      };
      try {
        return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/discount`))
          .workspace;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async clearDiscount(workspace: PosWorkspace, approvalId?: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        approval_id: approvalId || undefined,
      };
      try {
        return (
          await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/discount/clear`)
        ).workspace;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async applyCoupon(workspace: PosWorkspace, couponCode: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        coupon_code: couponCode,
      };
      try {
        return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/coupon`))
          .workspace;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async clearCoupon(workspace: PosWorkspace) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      try {
        return (
          await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/coupon/clear`)
        ).workspace;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
    async updateNote(workspace: PosWorkspace, note: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        note,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/note`))
        .workspace;
    },
    // Marks the draft as an order to deliver; the server adds the fee to the
    // order total.
    async setDelivery(workspace: PosWorkspace, input: { deliverer: string; fee: string }) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        deliverer: input.deliverer,
        fee: input.fee,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/delivery`))
        .workspace;
    },
    async setServiceMode(workspace: PosWorkspace, serviceMode: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        service_mode: serviceMode,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/service_mode`,
          'PATCH',
        )
      ).workspace;
    },
    async setOrderSource(workspace: PosWorkspace, orderSource: OrderSource) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        order_source: orderSource,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/order_source`))
        .workspace;
    },
    // The name the guest gives at the counter, called out and printed on the
    // cup labels; blank clears it.
    async setGuestName(workspace: PosWorkspace, guestName: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        guest_name: guestName,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/guest_name`))
        .workspace;
    },
    // "Báo bếp": the part of every menu line the kitchen has not heard yet.
    async sendToKitchen(workspace: PosWorkspace) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      return (await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/kitchen_sends`))
        .workspace;
    },
    async clearDelivery(workspace: PosWorkspace) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
      };
      return (
        await sendIntent(workspace.id, body, `/pos/workspaces/${workspace.id}/delivery/clear`)
      ).workspace;
    },
    async lineDiscount(
      workspace: PosWorkspace,
      saleLineId: string,
      input: {
        valueType: 'flat' | 'percent' | 'unit_price' | 'item_flat' | 'item_percent';
        value: string;
        reason: string;
        approvalId?: string;
      },
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        sale_line_id: saleLineId,
        value_type: input.valueType,
        value: input.value,
        reason: input.reason,
        approval_id: input.approvalId || undefined,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${saleLineId}/line_discount`,
        )
      ).workspace;
    },
    async clearLineDiscount(workspace: PosWorkspace, saleLineId: string, approvalId?: string) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        sale_line_id: saleLineId,
        approval_id: approvalId || undefined,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${saleLineId}/line_discount`,
          'DELETE',
        )
      ).workspace;
    },
    async priceOverride(
      workspace: PosWorkspace,
      saleLineId: string,
      input: { price: string; reason: string; approvalId?: string },
    ) {
      const body = {
        expected_revision: workspace.revision,
        lease_generation: workspace.lease_generation,
        editor_id: editorId,
        sale_line_id: saleLineId,
        price: input.price,
        reason: input.reason,
        approval_id: input.approvalId || undefined,
      };
      return (
        await sendIntent(
          workspace.id,
          body,
          `/pos/workspaces/${workspace.id}/items/${saleLineId}/price_override`,
        )
      ).workspace;
    },
    async claim(workspace: PosWorkspace, takeover = false) {
      const { workspace: result, recovered } = await sendIntent(
        workspace.id,
        { editor_id: editorId, takeover },
        `/pos/workspaces/${workspace.id}/lease`,
      );
      if (!recovered) setOwned((current) => ({ ...current, [result.id]: result.lease_generation }));
      return result;
    },
    async heartbeat(workspace: PosWorkspace) {
      const key = crypto.randomUUID();
      try {
        const result = await commandQueue.enqueue(
          workspace.id,
          key,
          `heartbeat:${workspace.lease_generation}`,
          () =>
            session.request<{ data: PosWorkspace }>(
              'PATCH',
              `/pos/workspaces/${workspace.id}/lease`,
              {
                body: {
                  editor_id: editorId,
                  lease_generation: workspace.lease_generation,
                  idempotency_key: key,
                },
                idempotencyKey: key,
              },
            ),
        );
        if (result?.data) await acceptWorkspace(result.data);
      } catch (error) {
        release(workspace.id, workspace.lease_generation);
        abandonIfNeeded(error);
        throw error;
      }
    },
    rememberedIds() {
      if (!staffId || !storeId) return [];
      return readLayout(staffId, storeId)?.openWorkspaceIds ?? [];
    },
    remember(ids: string[]) {
      if (!staffId || !storeId) return;
      const current = readLayout(staffId, storeId);
      writeLayout({
        staffId,
        storeId,
        savedAt: Date.now(),
        branchId: current?.branchId ?? null,
        registerId: current?.registerId ?? null,
        openWorkspaceIds: ids.slice(0, 50),
        closedWorkspaceIds: current?.closedWorkspaceIds,
        activeWorkspaceId: current?.activeWorkspaceId,
        workspacePage: current?.workspacePage,
        tabNumbers: current?.tabNumbers,
      });
    },
    rememberView(activeWorkspaceId: string | null, workspacePage: number) {
      if (!staffId || !storeId || !branchId) return;
      const current = readLayout(staffId, storeId);
      if (current?.branchId !== branchId || current.registerId !== registerId) return;
      writeLayout({ ...current, savedAt: Date.now(), activeWorkspaceId, workspacePage });
    },
    rememberClosed(closedWorkspaceIds: string[]) {
      if (!staffId || !storeId || !branchId) return;
      const current = readLayout(staffId, storeId);
      if (current?.branchId !== branchId || current.registerId !== registerId) return;
      writeLayout({ ...current, savedAt: Date.now(), closedWorkspaceIds });
    },
  };
}
