import { connectivity } from './connectivity';
import { emitOfflineChanged, offlineDb } from './offline-store';
import { queryClient } from './query-client';
import { conflictReason, failureStatus } from './request-failure';
import {
  browserSessionChannel,
  createSessionCoordinator,
  SessionSuperseded,
} from './session-coordinator';
import { clearIntents } from './uncertain-intents';
import { clearLayout } from './workspace-storage';

export const session = createSessionCoordinator({
  origin: window.location.origin,
  channel: browserSessionChannel(),
  onCleared: (explicitLogout) => {
    queryClient.clear();
    clearLayout();
    if (explicitLogout) {
      clearIntents();
      // Signed out on purpose: nobody sells offline as this cashier any more.
      // Sales already queued stay until this cashier sends them.
      void offlineDb()
        .putSnapshot(null)
        .then(emitOfflineChanged, () => undefined);
    }
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
    // No answer at all: find out whether the server is out of reach.
    if (failureStatus(error) === undefined && !(error instanceof SessionSuperseded))
      connectivity.reportNetworkFailure();
    throw error;
  }
}) as typeof sendRequest;
