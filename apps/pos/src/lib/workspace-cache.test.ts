import { QueryClient } from '@tanstack/react-query';
import { describe, expect, it } from 'vitest';
import type { PosWorkspace } from './pos-context';
import { posWorkspacesKey } from './query-keys';
import { writeWorkspaceToCache } from './workspace-cache';

const workspace = (revision: number) =>
  ({ id: 'ws_1', revision, lease_generation: 1 }) as unknown as PosWorkspace;

describe('writeWorkspaceToCache', () => {
  it('updates list pages and selected entries and leaves the open tabs list alone', () => {
    const client = new QueryClient();
    const base = posWorkspacesKey(1, 'store_1');
    const tabs = [
      {
        id: 'ws_1',
        tabName: 'Anh Nam',
        table: null,
        orderNumber: null,
        openedAt: null,
        total: '0',
      },
    ];
    client.setQueryData([...base, 'list'], {
      data: [workspace(1)],
      meta: { page: 1, pages: 1, count: 1 },
    });
    client.setQueryData([...base, 'selected', 'br_1', 'reg_1', 'ws_1'], { data: workspace(1) });
    client.setQueryData([...base, 'tabs', 'br_1', ''], tabs);

    writeWorkspaceToCache(client, 1, 'store_1', workspace(2));

    expect(client.getQueryData<{ data: PosWorkspace[] }>([...base, 'list'])?.data[0].revision).toBe(
      2,
    );
    expect(
      client.getQueryData<{ data: PosWorkspace }>([...base, 'selected', 'br_1', 'reg_1', 'ws_1'])
        ?.data.revision,
    ).toBe(2);
    expect(client.getQueryData([...base, 'tabs', 'br_1', ''])).toBe(tabs);
  });
});
