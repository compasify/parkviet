import { isPaperSize } from '../print-adapter';
import type { DocumentType, PaperSize } from './types';

// Which template a print uses. A posted receipt reprints with the template,
// version and paper of its original print unless the cashier picks another
// template, which then prints with its current version and paper. Before the
// first print this device's last used template of the document type comes
// first, then the store default.

export type ListedTemplate = {
  id: string;
  document_type: DocumentType;
  name: string;
  paper: PaperSize;
  status: 'active' | 'disabled';
  is_default: boolean;
  current_version: number;
};

// The layout the server recorded for a print; all null before templates.
export type PrintLayout = {
  template_id: string | null;
  template_version: number | null;
  paper: PaperSize | null;
};

export type PrintChoice = {
  key: string;
  templateId: string;
  version: number;
  paper: PaperSize;
  // Unknown until loaded when the original's template is no longer listed.
  name: string | null;
  original: boolean;
};

export const ORIGINAL_CHOICE = 'original';
export const DEFAULT_PAPER: PaperSize = '80mm';

const paperOf = (value: unknown): PaperSize | null => (isPaperSize(value) ? value : null);

// The original's template and version, when the print recorded them.
export function originalLayout(
  layout: PrintLayout | null | undefined,
): { templateId: string; version: number; paper: PaperSize | null } | null {
  const version = layout?.template_version;
  if (!layout?.template_id || typeof version !== 'number' || !Number.isInteger(version))
    return null;
  return { templateId: layout.template_id, version, paper: paperOf(layout.paper) };
}

// The original first (labelled as such), then every other active template
// of the document type, default first.
export function printChoices(
  templates: readonly ListedTemplate[],
  documentType: DocumentType,
  original: PrintLayout | null = null,
): PrintChoice[] {
  const listed = templates
    .filter((template) => template.document_type === documentType && template.status === 'active')
    .sort((a, b) => Number(b.is_default) - Number(a.is_default));
  const source = originalLayout(original);
  const choices: PrintChoice[] = [];
  if (source) {
    const known = listed.find((template) => template.id === source.templateId);
    choices.push({
      key: ORIGINAL_CHOICE,
      templateId: source.templateId,
      version: source.version,
      paper: source.paper ?? paperOf(known?.paper) ?? DEFAULT_PAPER,
      name: known?.name ?? null,
      original: true,
    });
  }
  for (const template of listed) {
    if (template.id === source?.templateId) continue;
    choices.push({
      key: template.id,
      templateId: template.id,
      version: template.current_version,
      paper: paperOf(template.paper) ?? DEFAULT_PAPER,
      name: template.name,
      original: false,
    });
  }
  return choices;
}

// The choice a print starts from: the original, else the remembered
// template if it is still offered, else the default, else the first.
export function initialChoice(
  choices: readonly PrintChoice[],
  templates: readonly ListedTemplate[],
  remembered: string | null = null,
): string | null {
  if (choices.length === 0) return null;
  const original = choices.find((choice) => choice.original);
  if (original) return original.key;
  if (remembered && choices.some((choice) => choice.key === remembered)) return remembered;
  const preferred = templates.find(
    (template) => template.is_default && choices.some((choice) => choice.key === template.id),
  );
  return preferred?.id ?? choices[0].key;
}

export const rememberedTemplateKey = (documentType: DocumentType) =>
  `parkviet-pos:receipt-template:${documentType}`;
// Paper was chosen per device before templates carried it.
export const LEGACY_PAPER_KEYS = ['parkviet-pos:receipt-paper', 'parkviet-pos:ticket-paper'];

export function rememberedTemplate(documentType: DocumentType): string | null {
  try {
    return window.localStorage.getItem(rememberedTemplateKey(documentType));
  } catch {
    return null;
  }
}

export function rememberTemplate(documentType: DocumentType, templateId: string) {
  try {
    window.localStorage.setItem(rememberedTemplateKey(documentType), templateId);
    for (const key of LEGACY_PAPER_KEYS) window.localStorage.removeItem(key);
  } catch {
    // A preference only: the print itself is recorded on the server.
  }
}
