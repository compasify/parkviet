import { queryClient } from './query-client';
import { conflictReason } from './request-failure';
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

// A manager switched a feature off while this page was open: reload the
// context so its entry points hide without waiting for a page reload.
const sendRequest = session.request;
session.request = (async (...args: Parameters<typeof sendRequest>) => {
  try {
    return await sendRequest(...args);
  } catch (error) {
    if (conflictReason(error) === 'feature_disabled')
      void queryClient.invalidateQueries({ queryKey: ['pos', 'context'] });
    throw error;
  }
}) as typeof sendRequest;
