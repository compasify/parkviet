#!/usr/bin/env node
// Checks an app's translations against its source.
//
//   node scripts/check-locales.mjs [appDir] [--unused]
//
// appDir defaults to this app (apps/pos-dashboard). The app's
// src/locales/{vi,en}.json are read together with the bundle shared by
// packages/pos-shared, the way src/i18n.ts merges them. Reports:
//   - keys present in one language but not the other (plural forms such as
//     `_one`/`_other` count as their base key);
//   - keys referenced literally in src (`t('key')`, `translate('key')`,
//     `i18nKey="key"`) that resolve in neither the app nor the shared bundle
//     nor an inline bundle of src/i18n.ts (`section: { key: … }`);
//   - with --unused, app keys no string in src appears to reference. This is a
//     heuristic: dynamic keys are matched through template literals and string
//     prefixes, so review the list before deleting anything.
// Exits with 1 when the first two lists are not empty.
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const SHARED_LOCALES = resolve(here, '../../../packages/pos-shared/src/locales');
const LANGUAGES = ['vi', 'en'];
const PLURAL = /_(zero|one|two|few|many|other)$/;
const SOURCE = /\.(ts|tsx|js|jsx|mjs)$/;

// Leaf keys of a bundle; arrays are leaves (read with returnObjects).
export function leafKeys(value, prefix = '') {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) return [prefix];
  return Object.entries(value).flatMap(([key, child]) =>
    leafKeys(child, prefix ? `${prefix}.${key}` : key),
  );
}

export const baseKey = (key) => key.replace(PLURAL, '');

function readJson(path) {
  try {
    return JSON.parse(readFileSync(path, 'utf8'));
  } catch (error) {
    if (error.code === 'ENOENT') return {};
    throw new Error(`${path}: ${error.message}`);
  }
}

export function loadLocales(appDir) {
  return Object.fromEntries(
    LANGUAGES.map((lng) => [
      lng,
      {
        app: readJson(join(appDir, 'src/locales', `${lng}.json`)),
        shared: readJson(join(SHARED_LOCALES, `${lng}.json`)),
      },
    ]),
  );
}

export function sourceFiles(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return name === 'locales' ? [] : sourceFiles(path);
    return SOURCE.test(name) ? [path] : [];
  });
}

const escapeRegExp = (text) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

// Every string a source file could hand to `t`: plain literals, and template
// literals turned into patterns (each `${…}` matches any text).
export function sourceStrings(files) {
  const literals = new Set();
  const patterns = [];
  const references = [];
  for (const file of files) {
    const text = readFileSync(file, 'utf8');
    for (const match of text.matchAll(/'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)"/g))
      literals.add(match[1] ?? match[2]);
    for (const match of text.matchAll(/`((?:[^`\\]|\\.)*)`/g)) {
      const template = match[1];
      if (!template.includes('${')) {
        literals.add(template);
        continue;
      }
      const parts = template.split(/\$\{[^}]*\}/);
      const head = parts[0];
      const tail = parts.at(-1);
      // A pattern with no stable text around the expression would match every key.
      if (!/[A-Za-z]{2}/.test(head) && !/[A-Za-z]{4}/.test(tail)) continue;
      patterns.push(new RegExp(`^${parts.map(escapeRegExp).join('.+')}$`));
    }
    const call = /(?:\bt|\btranslate|\.t)\(\s*(['"])([^'"\n]+)\1|i18nKey=\{?\s*(['"])([^'"\n]+)\3/g;
    for (const match of text.matchAll(call)) {
      const key = match[2] ?? match[4];
      if (/^[\w.-]+$/.test(key)) references.push({ key, file });
    }
  }
  return { literals, patterns, references };
}

// A key resolves when it is a leaf, a plural base, or a subtree (returnObjects).
function resolves(keys, key) {
  if (keys.has(key)) return true;
  for (const candidate of keys)
    if (baseKey(candidate) === key || candidate.startsWith(`${key}.`)) return true;
  return false;
}

// Keys an app defines inline in src/i18n.ts (shell texts): `section.key`
// counts when the file declares `section: {` and `key:`.
function inlineKeys(path) {
  let text = '';
  try {
    text = readFileSync(path, 'utf8');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  return (key) => {
    const [section, ...rest] = key.split('.');
    if (rest.length !== 1) return false;
    const declares = (name) => new RegExp(`(^|[\\s{,])${escapeRegExp(name)}:`, 'm').test(text);
    return new RegExp(`\\b${escapeRegExp(section)}:\\s*\\{`).test(text) && declares(rest[0]);
  };
}

// Whether a source string reaches a locale key. Literals ending in `.` or `_`
// are prefixes joined with a value; a literal naming a subtree keeps it whole.
export function keyReferenced(key, { literals, patterns }) {
  const base = baseKey(key);
  if (literals.has(key) || literals.has(base)) return true;
  if (patterns.some((pattern) => pattern.test(key) || pattern.test(base))) return true;
  const segments = key.split('.');
  for (let index = 1; index < segments.length; index++)
    if (literals.has(segments.slice(0, index).join('.'))) return true;
  for (const literal of literals)
    if (/[A-Za-z]{2}[._]$/.test(literal) && key.startsWith(literal)) return true;
  return false;
}

export function checkLocales(appDir, { unused = false } = {}) {
  const locales = loadLocales(appDir);
  const appKeys = Object.fromEntries(
    LANGUAGES.map((lng) => [lng, new Set(leafKeys(locales[lng].app).filter(Boolean))]),
  );
  const allKeys = Object.fromEntries(
    LANGUAGES.map((lng) => [
      lng,
      new Set([...appKeys[lng], ...leafKeys(locales[lng].shared).filter(Boolean)]),
    ]),
  );
  const bases = Object.fromEntries(
    LANGUAGES.map((lng) => [lng, new Set([...allKeys[lng]].map(baseKey))]),
  );
  const onlyIn = Object.fromEntries(
    LANGUAGES.map((lng) => [
      lng,
      [...bases[lng]]
        .filter((key) => LANGUAGES.some((other) => other !== lng && !bases[other].has(key)))
        .sort(),
    ]),
  );
  const strings = sourceStrings(sourceFiles(join(appDir, 'src')));
  const inline = inlineKeys(join(appDir, 'src/i18n.ts'));
  const missing = strings.references
    .filter(({ key }) => !inline(key) && LANGUAGES.some((lng) => !resolves(allKeys[lng], key)))
    .map(({ key, file }) => `${key}  (${relative(appDir, file).replaceAll('\\', '/')})`);
  const result = { onlyIn, missing: [...new Set(missing)].sort() };
  if (unused)
    result.unused = [...appKeys.vi].filter((key) => !keyReferenced(key, strings)).sort();
  return result;
}

function main() {
  const args = process.argv.slice(2);
  const appDir = resolve(args.find((arg) => !arg.startsWith('--')) ?? join(here, '..'));
  const result = checkLocales(appDir, { unused: args.includes('--unused') });
  let failed = false;
  const report = (title, list) => {
    if (list.length === 0) return;
    console.log(`${title} (${list.length}):`);
    for (const item of list) console.log(`  ${item}`);
  };
  for (const lng of LANGUAGES) {
    report(`Only in ${lng}`, result.onlyIn[lng]);
    failed ||= result.onlyIn[lng].length > 0;
  }
  report('Referenced in src but missing', result.missing);
  failed ||= result.missing.length > 0;
  if (result.unused) report('Possibly unused app keys', result.unused);
  if (!failed) console.log(`Locales of ${relative(process.cwd(), appDir) || '.'} are consistent.`);
  process.exitCode = failed ? 1 : 0;
}

if (resolve(process.argv[1] ?? '') === fileURLToPath(import.meta.url)) main();
