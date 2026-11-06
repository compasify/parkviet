import { useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { session } from '../lib/app-session';
import { commandDigest, commandQueue } from '../lib/command-queue';
import type { PosWorkspace } from '../lib/pos-context';
import { posWorkspacesKey } from '../lib/query-keys';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { beginIntent, finishIntent, forgetIntent, hasIntent } from '../lib/uncertain-intents';
import { browserWorkspaceChannel, workspaceHint } from '../lib/workspace-channel';
import { readLayout, writeLayout } from '../lib/workspace-storage';
import { useSession } from './use-session';

const channel = browserWorkspaceChannel();
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
  ) {
    const result = await commandQueue.enqueue(workspaceId, key, commandDigest(body), () =>
      session.request<{ data: PosWorkspace }>('POST', path, {
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
    queryClient.setQueriesData<Page | { data: PosWorkspace }>({ queryKey: base }, (current) => {
      if (!current) return current;
      const update = (previous: PosWorkspace) =>
        previous.id === workspace.id &&
        previous.revision <= workspace.revision &&
        previous.lease_generation <= workspace.lease_generation
          ? workspace
          : previous;
      return 'meta' in current
        ? { ...current, data: current.data.map(update) }
        : { ...current, data: update(current.data) };
    });
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

  async function sendIntent(workspaceId: string, body: Record<string, unknown>, path: string) {
    const { editor_id: _editor, ...stableBody } = body;
    const intent = JSON.stringify([staffId, storeId, workspaceId, path, commandDigest(stableBody)]);
    const wasUncertain = hasIntent(intent);
    const key = beginIntent(intent);
    try {
      const result = await send(workspaceId, key, body, path);
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
      // A fresh request rejected by the server is not a lost response. Existing
      // uncertain attempts stay until a receipt or an exact retry resolves them.
      if (!wasUncertain && posFailureKey(error) !== 'offline') forgetIntent(intent);
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
    owns(workspace: PosWorkspace) {
      return owned[workspace.id] === workspace.lease_generation;
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
          setOwned((current) => {
            const next = { ...current };
            delete next[workspace.id];
            return next;
          });
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
      const scope = JSON.stringify([
        staffId,
        storeId,
        workspace.id,
        `/pos/workspaces/${workspace.id}/items/${saleLineId}/line_discount:delete`,
        commandDigest(body),
      ]);
      const wasUncertain = hasIntent(scope);
      const key = beginIntent(scope);
      try {
        const result = await session.request<{ data: PosWorkspace }>(
          'DELETE',
          `/pos/workspaces/${workspace.id}/items/${saleLineId}/line_discount`,
          { body: { ...body, idempotency_key: key }, idempotencyKey: key },
        );
        forgetIntent(scope);
        await acceptWorkspace(result.data);
        return result.data;
      } catch (error) {
        if (!wasUncertain && posFailureKey(error) !== 'offline') forgetIntent(scope);
        abandonIfNeeded(error);
        throw error;
      } finally {
        finishIntent(scope);
      }
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
        setOwned((current) => {
          if (current[workspace.id] !== workspace.lease_generation) return current;
          const next = { ...current };
          delete next[workspace.id];
          return next;
        });
        abandonIfNeeded(error);
        throw error;
      }
    },
    async handover(workspace: PosWorkspace) {
      try {
        const key = crypto.randomUUID();
        const result = await session.request<{ data: PosWorkspace }>(
          'POST',
          `/pos/workspaces/${workspace.id}/handover`,
          { body: { idempotency_key: key }, idempotencyKey: key },
        );
        await refresh();
        return result.data;
      } catch (error) {
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
