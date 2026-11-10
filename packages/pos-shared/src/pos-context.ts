import { normalizeFeatures } from './pos-features';
import {
  normalizeModules,
  normalizeModuleUsage,
  normalizeOnboarding,
  normalizeProfile,
} from './pos-modules';
import type { PosContext, PosSelection } from './types/pos-context';

export const emptySelection: PosSelection = { branchId: null, registerId: null };

// Normalize optional settings without depending on any session implementation.
export function normalizeContext(context: PosContext): PosContext {
  return {
    ...context,
    features: normalizeFeatures(context.features),
    modules: normalizeModules(context.modules),
    module_usage: normalizeModuleUsage(context.module_usage),
    profile: normalizeProfile(context.profile),
    onboarding: normalizeOnboarding(context.onboarding),
  };
}

export function writesLocked(context: PosContext | undefined, selection: PosSelection) {
  if (!context) return true;
  const branch = context.branches.find((item) => item.id === selection.branchId);
  const register = context.registers.find((item) => item.id === selection.registerId);
  if (branch?.status === 'disabled' || register?.status === 'disabled') return true;
  return Boolean(context.shift) && !context.capabilities.includes('pos.shift.open');
}
