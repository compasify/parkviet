const HINT = 'pos.workspace';

export type WorkspaceHint = {
  type: typeof HINT;
  workspaceId: string;
  event: 'invalidated';
};

type HintChannel = {
  postMessage: (data: WorkspaceHint) => void;
  subscribe: (handler: (data: WorkspaceHint) => void) => () => void;
};

export function browserWorkspaceChannel(): HintChannel | null {
  if (typeof BroadcastChannel === 'undefined') return null;
  const channel = new BroadcastChannel('parkviet-pos-workspaces');
  return {
    postMessage: (data) => channel.postMessage(data),
    subscribe: (handler) => {
      const listener = (event: MessageEvent<WorkspaceHint>) => handler(event.data);
      channel.addEventListener('message', listener);
      return () => channel.removeEventListener('message', listener);
    },
  };
}

export function workspaceHint(workspaceId: string): WorkspaceHint {
  return { type: HINT, workspaceId, event: 'invalidated' };
}
