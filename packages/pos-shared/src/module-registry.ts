// UI of the POS modules: which existing entry points each module owns. The
// pages stay in `pages/` and `components/`; a module only declares where its
// setup screens are reachable from, so a branch with the module off does not
// offer them. Nothing here touches selling, receipts or returns.
//
// Module keys match the server's (`GET /pos/business_profiles`). A key the
// server sends that no entry declares changes nothing on screen.
import { moduleEnabled, moduleInUse, type PosModules, type PosModuleUsage } from './pos-modules';
import { canOpenInventory } from './traceability';

// What a module scope needs: the context of the selected branch, or the same
// shape with the modules of another branch (settings of a branch by URL).
export type ModuleScope = {
  modules?: PosModules | null;
  module_usage?: PosModuleUsage | null;
  capabilities?: string[];
  administration?: { read: boolean; write: boolean };
};

// A page in the header (user) menu.
export type NavEntry = {
  id: 'inventory';
  to: '/inventory';
  labelKey: string;
  // Stays reachable with the module off while the store still has the
  // module's data (`module_usage`): receiving stock for SKUs tracked before.
  keepWhileInUse?: boolean;
  allowed: (scope: ModuleScope) => boolean;
};

// A page or a field of a branch's settings.
export type BranchSettingsEntry = {
  id: 'label-formats' | 'lot-selection';
  kind: 'page' | 'field';
  labelKey: string;
  allowed: (scope: ModuleScope) => boolean;
};

export type SkuEditorArea = 'units' | 'measured' | 'traceability';

export type PosModuleUi = {
  key: string; // trùng key server
  nav?: NavEntry[]; // mục trong user menu
  branchSettings?: BranchSettingsEntry[]; // mục trong Cấu hình → chi nhánh
  skuEditor?: SkuEditorArea; // vùng trên variant-unit-editor
};

// Same rule as `administrationAccess`: branch capabilities never grant it.
const readsSettings = (scope: ModuleScope) => scope.administration?.read === true;

// Sale unit and conversion ratio in the SKU editor.
export const unitsUi: PosModuleUi = { key: 'retail.units', skuEditor: 'units' };

// Scale label formats of a branch and the label code of a SKU.
export const measuredUi: PosModuleUi = {
  key: 'retail.measured',
  branchSettings: [
    { id: 'label-formats', kind: 'page', labelKey: 'labelFormatsTitle', allowed: readsSettings },
  ],
  skuEditor: 'measured',
};

// The traceable stock page, the branch's lot picking and the SKU's tracked mode.
export const traceabilityUi: PosModuleUi = {
  key: 'retail.traceability',
  nav: [
    {
      id: 'inventory',
      to: '/inventory',
      labelKey: 'inventoryNav',
      keepWhileInUse: true,
      allowed: (scope) => canOpenInventory(scope.capabilities),
    },
  ],
  branchSettings: [
    { id: 'lot-selection', kind: 'field', labelKey: 'adminLotSelection', allowed: readsSettings },
  ],
  skuEditor: 'traceability',
};

export const moduleUis: PosModuleUi[] = [unitsUi, measuredUi, traceabilityUi];

// Menu entries of the modules: the module is on (or its data is still in
// use, where the entry says so) and the staff may open the page.
export function visibleNav(scope: ModuleScope | undefined): NavEntry[] {
  if (!scope) return [];
  return moduleUis.flatMap((module) =>
    (module.nav ?? []).filter(
      (entry) =>
        (moduleEnabled(scope.modules, module.key) ||
          (entry.keepWhileInUse === true && moduleInUse(scope, module.key))) &&
        entry.allowed(scope),
    ),
  );
}

export function navVisible(scope: ModuleScope | undefined, id: NavEntry['id']): boolean {
  return visibleNav(scope).some((entry) => entry.id === id);
}

// Branch settings entries of the modules on at that branch, for staff who may
// read the settings.
export function visibleBranchSettings(scope: ModuleScope | undefined): BranchSettingsEntry[] {
  if (!scope) return [];
  return moduleUis.flatMap((module) =>
    moduleEnabled(scope.modules, module.key)
      ? (module.branchSettings ?? []).filter((entry) => entry.allowed(scope))
      : [],
  );
}

// Whether a module-owned settings entry is offered. Entries no module owns
// (assortment, features…) are not gated here.
export function branchSettingVisible(
  scope: ModuleScope | undefined,
  id: BranchSettingsEntry['id'],
): boolean {
  return visibleBranchSettings(scope).some((entry) => entry.id === id);
}

// Module that owns a settings entry, for its "branch has not turned on …" note.
export function branchSettingModule(id: BranchSettingsEntry['id']): string | null {
  return (
    moduleUis.find((module) => module.branchSettings?.some((entry) => entry.id === id))?.key ?? null
  );
}

// Areas of the SKU editor whose module is on at the branch.
export function skuEditorAreas(modules: PosModules | null | undefined): Set<SkuEditorArea> {
  return new Set(
    moduleUis.flatMap((module) =>
      module.skuEditor && moduleEnabled(modules, module.key) ? [module.skuEditor] : [],
    ),
  );
}
