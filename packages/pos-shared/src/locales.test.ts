import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import { moduleUis } from './module-registry';
import { posCapabilities } from './pos-capabilities';
import { POS_FEATURES } from './pos-features';
import { LABELLED_MODULES, profileDescriptionKey, profileLabelKey } from './pos-modules';
import { featureDisabledText, moduleDisabledText, posFailureKey } from './request-failure';
import { inventoryReasonKey } from './traceability';

type Tree = { [key: string]: string | Tree };
const bundles = { vi, en } as unknown as Record<'vi' | 'en', Tree>;
const PLURAL = /_(zero|one|two|few|many|other)$/;

function leaves(tree: Tree, prefix = ''): string[] {
  return Object.entries(tree).flatMap(([key, value]) =>
    typeof value === 'string' ? [`${prefix}${key}`] : leaves(value, `${prefix}${key}.`),
  );
}

// A key resolves as a leaf or through its plural forms.
function resolves(bundle: Tree, key: string): boolean {
  return leaves(bundle).some((leaf) => leaf === key || leaf.replace(PLURAL, '') === key);
}

function sourceTexts(dir: string): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return name === 'test-support' ? [] : sourceTexts(path);
    return /\.ts$/.test(name) && !/\.test(-cases)?\.ts$/.test(name)
      ? [readFileSync(path, 'utf8')]
      : [];
  });
}

const sources = sourceTexts(import.meta.dirname);

// Keys the source names literally: `t('key')`, `translate('key')`, keys
// chosen by a ternary, and the `labelKey` / `error` keys it hands to the apps.
function literalKeys(): string[] {
  const found = new Set<string>();
  const patterns = [
    /\b(?:t|translate)\(\s*'([^'\n]+)'/g,
    /\?\s*'([a-z]+[A-Z][A-Za-z]*)'\s*:\s*'([a-z]+[A-Z][A-Za-z]*)'/g,
    /\b(?:labelKey|error):\s*'([^'\n]+)'/g,
  ];
  for (const text of sources)
    for (const pattern of patterns)
      for (const match of text.matchAll(pattern))
        for (const key of match.slice(1)) if (key) found.add(key);
  return [...found];
}

// Reasons listed in traceability's refusal sets, read from the source.
function traceReasons(): string[] {
  const text = sources.find((source) => source.includes('const TRACE_REASONS')) ?? '';
  return [...text.matchAll(/const \w+_REASONS = new Set\(\[([^\]]*)\]\)/g)].flatMap((match) =>
    [...(match[1] ?? '').matchAll(/'([^']+)'/g)].map((reason) => reason[1] ?? ''),
  );
}

const refusal = (details: Record<string, unknown>) => ({ status: 409, details });
const key = (value: string) => value;

function resolvedKeys(): string[] {
  const keys = new Set(literalKeys());
  keys.add('traceReason_opening_unreconciled_counts');
  for (const [, label] of posCapabilities) keys.add(label);
  for (const module of moduleUis)
    for (const entry of [...(module.nav ?? []), ...(module.branchSettings ?? [])])
      keys.add(entry.labelKey);
  for (const status of [401, 403, 404, 409, 422, 500, undefined])
    keys.add(posFailureKey(status === undefined ? new Error('offline') : { status }));
  // Off, `edit_lease` loosens the editing locks: the server never refuses with it.
  for (const feature of POS_FEATURES.filter((item) => item !== 'edit_lease'))
    keys.add(featureDisabledText(refusal({ reason: 'feature_disabled', feature }), key) ?? '');
  keys.add(featureDisabledText(refusal({ reason: 'feature_disabled' }), key) ?? '');
  for (const module of [...LABELLED_MODULES, 'unknown.module'])
    keys.add(moduleDisabledText(refusal({ reason: 'module_disabled', module }), key) ?? '');
  for (const module of LABELLED_MODULES)
    for (const part of ['label', 'description', 'off'])
      keys.add(`posModules.${module.replaceAll('.', '_')}.${part}`);
  for (const profile of Object.keys(vi.profiles)) {
    keys.add(profileLabelKey(profile));
    keys.add(profileDescriptionKey(profile));
  }
  for (const reason of traceReasons()) keys.add(inventoryReasonKey(reason) ?? `<${reason}>`);
  return [...keys].sort();
}

describe('shared POS translations', () => {
  it('finds the keys it checks', () => {
    expect(traceReasons().length).toBeGreaterThan(20);
    expect(literalKeys()).toEqual(expect.arrayContaining(['receiptTotal', 'leaseBusy']));
  });

  it.each(['vi', 'en'] as const)('resolves every key the shared logic names in %s', (lng) => {
    expect(resolvedKeys().filter((item) => !resolves(bundles[lng], item))).toEqual([]);
  });

  it('ships the same keys in Vietnamese and English', () => {
    const base = (tree: Tree) => [...new Set(leaves(tree).map((leaf) => leaf.replace(PLURAL, '')))];
    expect(base(bundles.vi).sort()).toEqual(base(bundles.en).sort());
  });
});
