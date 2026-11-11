import { readdirSync, readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import i18n from '../test-support/i18n';
import { type Schema, type Schemas, validate } from '../test-support/json-schema';
import type { PosWorkspace } from '../types/pos-context';
import type { ReceiptSnapshot } from '../types/print-adapter';
import { type PrintPlace, prebillData, snapshotData } from './data';
import { DEFAULT_TEMPLATES } from './defaults';
import { renderDocument } from './render';
import {
  DOCUMENT_TYPES,
  type PageSettings,
  type PrintJobDocument,
  type PrintPayQr,
  type PrintRow,
  type TemplateConfig,
} from './types';
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

// Golden files written by server/spec/services/spree/pos/print_documents_spec.rb:
// each holds an input and the document the server built from it.
const fixtures = new URL('../../../../server/spec/fixtures/print_documents/', import.meta.url);
const readFixture = <T>(name: string): T =>
  JSON.parse(readFileSync(new URL(name, fixtures), 'utf8')) as T;

type Golden = {
  input: {
    config: TemplateConfig;
    receipt?: ReceiptSnapshot;
    print?: { copy: boolean; copy_number: number } | null;
    workspace?: PosWorkspace;
    place?: PrintPlace;
    now?: string;
    timeZone?: string;
    banner?: string | null;
  };
  document: PrintJobDocument;
};

const names = readdirSync(fixtures).filter((name) => name !== 'schema.json');
const schemas = readFixture<Schemas>('schema.json');
const t = i18n.t.bind(i18n) as (key: string, options?: Record<string, unknown>) => string;

function render({ input }: Golden) {
  if (input.receipt) {
    const banner = input.print?.copy
      ? t('receiptCopyBanner', { number: input.print.copy_number })
      : null;
    return renderDocument(input.config, snapshotData(input.receipt, t), { banner });
  }
  const data = prebillData(
    input.workspace as PosWorkspace,
    input.place as PrintPlace,
    t,
    new Date(input.now as string),
    input.timeZone,
  );
  return renderDocument(input.config, data, { banner: input.banner });
}

const keysOf = (name: string) => Object.keys(schemas[name]?.properties as Schema).sort();

describe('server print document contract', () => {
  it('has golden files to compare', () => {
    expect(names.length).toBeGreaterThanOrEqual(8);
  });

  it.each(names)('renders %s exactly as the server does', (name) => {
    const golden = readFixture<Golden>(name);
    const { version: _version, kind: _kind, ...expected } = golden.document;
    expect(render(golden)).toEqual(expected);
  });

  it.each(names)('%s satisfies the published schema', (name) => {
    const golden = readFixture<Golden>(name);
    expect(validate(golden.document, { $ref: '#/PrintDocument' }, schemas)).toEqual([]);
  });

  it('holds the same labels as the Vietnamese locale', () => {
    const labels = readJson('print_labels.json') as Record<string, string>;
    const raw = (key: string) => i18n.getResource('vi', 'translation', key) as string;
    for (const [key, label] of Object.entries(labels))
      expect([key, label]).toEqual([key, raw(key)]);
  });

  // A key added on one side only fails to compile or fails here.
  it('types the document with exactly the schema properties', () => {
    const document: Record<keyof PrintJobDocument, true> = {
      version: true,
      kind: true,
      documentType: true,
      page: true,
      banners: true,
      header: true,
      meta: true,
      lines: true,
      totals: true,
      payments: true,
      payQr: true,
      notes: true,
      footer: true,
      disclaimer: true,
    };
    const page: Record<keyof PageSettings, true> = {
      margin_mm: true,
      font: true,
      font_size: true,
      line_spacing: true,
      copies: true,
      label: true,
    };
    const row: Record<keyof PrintRow, true> = { label: true, value: true, strong: true };
    const qr: Record<keyof PrintPayQr, true> = { value: true, caption: true, lines: true };
    expect(Object.keys(document).sort()).toEqual(keysOf('PrintDocument'));
    expect(Object.keys(page).sort()).toEqual(keysOf('PrintPage'));
    expect(Object.keys(row).sort()).toEqual(keysOf('PrintRow'));
    expect(Object.keys(qr).sort()).toEqual(keysOf('PrintPayQr'));
  });

  it('refuses what the schema forbids', () => {
    const golden = readFixture<Golden>(names[0] as string);
    const extra = { ...golden.document, surprise: true };
    expect(validate(extra, { $ref: '#/PrintDocument' }, schemas)).toContain(
      '$.surprise: not allowed',
    );
  });
});
