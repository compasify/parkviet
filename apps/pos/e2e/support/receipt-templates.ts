import type { Route } from '@playwright/test';
import { DEFAULT_TEMPLATES } from '@parkviet/pos-shared/receipt-template/defaults';
import type { DocumentType, PaperSize, TemplateConfig } from '@parkviet/pos-shared/receipt-template/types';

// In-memory print templates of the store for mocked POS runs, answering the
// reads the counter makes (`GET /pos/receipt_templates`, one template at a
// version) and choosing the layout a receipt print records the way
// `Spree::Pos::ReceiptPrint.layout_for!` does. Presentation fixtures only.

export type TemplateSeed = {
  id: string;
  type: DocumentType;
  name: string;
  paper: PaperSize;
  isDefault?: boolean;
  // A footer text line that tells the versions apart on the printed sheet.
  footer?: string;
  marginMm?: number;
  // Prints made by the first press of a sale receipt.
  copies?: number;
};

export type PrintLayout = {
  template_id: string | null;
  template_version: number | null;
  paper: string | null;
};

type MockTemplate = {
  id: string;
  document_type: DocumentType;
  name: string;
  paper: PaperSize;
  status: 'active' | 'disabled';
  is_default: boolean;
  versions: TemplateConfig[];
};

const clone = <T>(value: T): T => JSON.parse(JSON.stringify(value)) as T;

function configOf(type: DocumentType, footer?: string, marginMm?: number, copies?: number): TemplateConfig {
  const config = clone(DEFAULT_TEMPLATES[type]);
  if (footer) config.footer = [...config.footer, { type: 'text', value: footer, align: 'center' }];
  if (marginMm !== undefined) config.page = { ...config.page, margin_mm: marginMm };
  if (copies !== undefined) config.page = { ...config.page, copies };
  return config;
}

export function receiptTemplateApi(seeds: TemplateSeed[]) {
  const templates: MockTemplate[] = seeds.map((seed) => ({
    id: seed.id,
    document_type: seed.type,
    name: seed.name,
    paper: seed.paper,
    status: 'active',
    is_default: seed.isDefault ?? false,
    versions: [configOf(seed.type, seed.footer, seed.marginMm, seed.copies)],
  }));
  const state = { failing: false, versionReads: [] as string[] };
  const toPos = (template: MockTemplate, version = template.versions.length) => ({
    id: template.id,
    document_type: template.document_type,
    name: template.name,
    paper: template.paper,
    status: template.status,
    is_default: template.is_default,
    current_version: template.versions.length,
    version,
    config: template.versions[version - 1],
    updated_by: null,
    created_at: '2026-11-08T02:00:00Z',
    updated_at: '2026-11-08T02:00:00Z',
  });
  const find = (id: string) => templates.find((template) => template.id === id);

  return {
    state,
    // Another device saves a new version with this footer line.
    revise(id: string, footer: string) {
      const template = find(id);
      if (!template) throw new Error(`no template ${id}`);
      template.versions.push(configOf(template.document_type, footer));
    },
    // Disabled; the default of its type moves to `successor`.
    disable(id: string, successor?: string) {
      const template = find(id);
      if (!template) throw new Error(`no template ${id}`);
      template.status = 'disabled';
      if (template.is_default && successor) {
        template.is_default = false;
        const next = find(successor);
        if (next) next.is_default = true;
      }
    },
    // Answers a template read; false when `path` is not one.
    async handle(route: Route, path: string, url: URL, method: string): Promise<boolean> {
      const match = /^\/pos\/receipt_templates(?:\/([^/]+))?$/.exec(path);
      if (!match || method !== 'GET') return false;
      if (state.failing) {
        await route.fulfill({ status: 500, json: { error: { code: 'server_error', message: 'Boom' } } });
        return true;
      }
      const [, id] = match;
      if (!id) {
        await route.fulfill({
          json: { data: templates.filter((template) => template.status === 'active').map((template) => toPos(template)) },
        });
        return true;
      }
      const template = find(id);
      const version = Number(url.searchParams.get('version') ?? template?.versions.length);
      if (!template || !template.versions[version - 1]) {
        await route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'Not found' } } });
        return true;
      }
      if (url.searchParams.has('version')) state.versionReads.push(`${id}@${version}`);
      await route.fulfill({ json: { data: toPos(template, version) } });
      return true;
    },
    // The layout a print of a `documentType` receipt records; null when the
    // request is refused (422 on the server).
    layoutFor(documentType: DocumentType, original: PrintLayout | null, body: Record<string, unknown>): PrintLayout | null {
      const requested = typeof body.receipt_template_id === 'string' ? body.receipt_template_id : null;
      if (requested) {
        const template = find(requested);
        if (!template || template.document_type !== documentType) return null;
        if (template.status === 'disabled' && requested !== original?.template_id) return null;
        const same = requested === original?.template_id;
        const version = body.template_version
          ? Number(body.template_version)
          : same
            ? original?.template_version ?? null
            : template.versions.length;
        if (!version || !template.versions[version - 1]) return null;
        const paper = typeof body.paper === 'string' ? body.paper : same ? original?.paper ?? null : template.paper;
        return { template_id: requested, template_version: version, paper };
      }
      if (original?.template_id) return original;
      const fallback = templates.find(
        (template) => template.document_type === documentType && template.status === 'active' && template.is_default,
      );
      if (!fallback) return { template_id: null, template_version: null, paper: null };
      return { template_id: fallback.id, template_version: fallback.versions.length, paper: fallback.paper };
    },
  };
}

export type ReceiptTemplateApi = ReturnType<typeof receiptTemplateApi>;

// The prints of one receipt as the server keeps them: number 0 is the
// original, every later one a numbered copy, each with its layout.
export function printLedger(api: ReceiptTemplateApi, documentType: DocumentType) {
  const prints: Array<{ id: string; copy_number: number; body: Record<string, unknown> } & PrintLayout> = [];
  const original = (): PrintLayout | null => {
    const first = prints[0];
    return first?.template_id
      ? { template_id: first.template_id, template_version: first.template_version, paper: first.paper }
      : null;
  };
  return {
    prints,
    // The print fields of the receipt as `ReceiptSnapshot#to_pos` renders them.
    receiptFields() {
      return {
        printed: prints.length > 0,
        copy_count: Math.max(prints.length - 1, 0),
        original_print: original(),
      };
    },
    // Records a print; null when the layout is refused.
    record(body: Record<string, unknown>) {
      const layout = api.layoutFor(documentType, original(), body);
      if (!layout) return null;
      const copyNumber = prints.length;
      const row = { id: `posprint_${copyNumber + 1}`, copy_number: copyNumber, body, ...layout };
      prints.push(row);
      return {
        id: row.id,
        copy: copyNumber > 0,
        copy_number: copyNumber,
        label: copyNumber > 0 ? 'BẢN SAO' : null,
        printed_at: '2026-11-08T03:05:00Z',
        ...layout,
      };
    },
  };
}
