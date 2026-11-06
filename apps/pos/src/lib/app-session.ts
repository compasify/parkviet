import { queryClient } from './query-client';
import { browserSessionChannel, createSessionCoordinator } from './session-coordinator';
import { clearIntents } from './uncertain-intents';
import { clearLayout } from './workspace-storage';

export const session = createSessionCoordinator({
  origin: window.location.origin,
  channel: browserSessionChannel(),
  onCleared: (explicitLogout) => {
    queryClient.clear();
    clearLayout();
    if (explicitLogout) clearIntents();
  },
});
