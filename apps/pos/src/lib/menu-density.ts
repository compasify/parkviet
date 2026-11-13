// How tightly the menu tiles of the table-service order screen are packed:
// a choice of this device, like the floor surface.
export const MENU_DENSITIES = ['airy', 'regular', 'dense'] as const;

export type MenuDensity = (typeof MENU_DENSITIES)[number];

export const DEFAULT_MENU_DENSITY: MenuDensity = 'regular';

export const MENU_DENSITY_KEY = 'parkviet-pos:menu-density';

export function isMenuDensity(value: unknown): value is MenuDensity {
  return MENU_DENSITIES.includes(value as MenuDensity);
}

export function savedMenuDensity(): MenuDensity {
  try {
    const saved = window.localStorage.getItem(MENU_DENSITY_KEY);
    return isMenuDensity(saved) ? saved : DEFAULT_MENU_DENSITY;
  } catch {
    // Storage blocked (private mode, policy): the default still works.
    return DEFAULT_MENU_DENSITY;
  }
}

export function saveMenuDensity(density: MenuDensity) {
  try {
    window.localStorage.setItem(MENU_DENSITY_KEY, density);
  } catch {
    // Not remembered on this device; the choice still applies until reload.
  }
}
