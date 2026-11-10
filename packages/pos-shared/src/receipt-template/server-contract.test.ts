import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { DEFAULT_TEMPLATES } from './defaults';
import { DOCUMENT_TYPES } from './types';
import { TEMPLATE_VARIABLES } from './variables';

// The server seeds every store with the same default templates the POS
// falls back to, and validates template text against the same variables.
// Both copies must stay identical.

const serverConfig = new URL('../../../../server/config/pos/', import.meta.url);
const readJson = (path: string): unknown =>
  JSON.parse(readFileSync(new URL(path, serverConfig), 'utf8'));

describe('server receipt template contract', () => {
  it.each(DOCUMENT_TYPES)('ships the same default %s template as the client', (type) => {
    expect(readJson(`receipt_templates/${type}.json`)).toEqual(DEFAULT_TEMPLATES[type]);
  });

  it('accepts exactly the variables the client resolves', () => {
    expect(readJson('receipt_template_variables.json')).toEqual([...TEMPLATE_VARIABLES]);
  });
});
