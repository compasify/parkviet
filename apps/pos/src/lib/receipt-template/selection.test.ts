import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  initialChoice,
  LEGACY_PAPER_KEYS,
  type ListedTemplate,
  ORIGINAL_CHOICE,
  originalLayout,
  printChoices,
  rememberedTemplate,
  rememberedTemplateKey,
  rememberTemplate,
} from './selection';

const template = (
  overrides: Partial<ListedTemplate> & Pick<ListedTemplate, 'id'>,
): ListedTemplate => ({
  document_type: 'sale',
  name: overrides.id,
  paper: '80mm',
  status: 'active',
  is_default: false,
  current_version: 1,
  ...overrides,
});

const k80 = template({
  id: 'postpl_a',
  name: 'Bán hàng K80',
  is_default: true,
  current_version: 3,
});
const a4 = template({ id: 'postpl_b', name: 'Bán hàng A4', paper: 'a4', current_version: 2 });
const prebill = template({ id: 'postpl_c', document_type: 'prebill', is_default: true });
const off = template({ id: 'postpl_d', status: 'disabled' });

describe('print choices', () => {
  it('offers the active templates of the document type, default first, at their current version', () => {
    const choices = printChoices([a4, prebill, off, k80], 'sale');
    expect(choices).toEqual([
      {
        key: 'postpl_a',
        templateId: 'postpl_a',
        version: 3,
        paper: '80mm',
        name: 'Bán hàng K80',
        original: false,
      },
      {
        key: 'postpl_b',
        templateId: 'postpl_b',
        version: 2,
        paper: 'a4',
        name: 'Bán hàng A4',
        original: false,
      },
    ]);
  });

  it('puts the original first with its own version and paper, in place of its template', () => {
    const choices = printChoices([k80, a4], 'sale', {
      template_id: 'postpl_a',
      template_version: 1,
      paper: '58mm',
    });
    expect(choices.map((choice) => [choice.key, choice.version, choice.paper])).toEqual([
      [ORIGINAL_CHOICE, 1, '58mm'],
      ['postpl_b', 2, 'a4'],
    ]);
    expect(choices[0]).toMatchObject({ name: 'Bán hàng K80', original: true });
  });

  it('keeps an original whose template was disabled since, name unknown until loaded', () => {
    const choices = printChoices([k80], 'sale', {
      template_id: 'postpl_d',
      template_version: 4,
      paper: 'a5',
    });
    expect(choices[0]).toEqual({
      key: ORIGINAL_CHOICE,
      templateId: 'postpl_d',
      version: 4,
      paper: 'a5',
      name: null,
      original: true,
    });
    expect(choices).toHaveLength(2);
  });

  it('ignores an original recorded before templates existed', () => {
    expect(originalLayout({ template_id: null, template_version: null, paper: null })).toBeNull();
    expect(
      printChoices([k80], 'sale', { template_id: null, template_version: null, paper: null }),
    ).toHaveLength(1);
  });

  it('starts from the original, then the remembered template, then the default', () => {
    const fresh = printChoices([k80, a4], 'sale');
    expect(initialChoice(fresh, [k80, a4])).toBe('postpl_a');
    expect(initialChoice(fresh, [k80, a4], 'postpl_b')).toBe('postpl_b');
    // A remembered template that is no longer offered is ignored.
    expect(initialChoice(fresh, [k80, a4], 'postpl_d')).toBe('postpl_a');
    const reprint = printChoices([k80, a4], 'sale', {
      template_id: 'postpl_b',
      template_version: 1,
      paper: 'a4',
    });
    expect(initialChoice(reprint, [k80, a4], 'postpl_a')).toBe(ORIGINAL_CHOICE);
    expect(initialChoice([], [])).toBeNull();
  });
});

describe('remembered template', () => {
  beforeEach(() => {
    const store = new Map<string, string>();
    vi.stubGlobal('window', {
      localStorage: {
        getItem: (key: string) => store.get(key) ?? null,
        setItem: (key: string, value: string) => store.set(key, value),
        removeItem: (key: string) => store.delete(key),
      },
    });
  });
  afterEach(() => vi.unstubAllGlobals());

  it('remembers the last template per document type and drops the old paper preferences', () => {
    for (const key of LEGACY_PAPER_KEYS) window.localStorage.setItem(key, '58mm');
    rememberTemplate('sale', 'postpl_b');
    expect(window.localStorage.getItem(rememberedTemplateKey('sale'))).toBe('postpl_b');
    expect(rememberedTemplate('sale')).toBe('postpl_b');
    expect(rememberedTemplate('return')).toBeNull();
    for (const key of LEGACY_PAPER_KEYS) expect(window.localStorage.getItem(key)).toBeNull();
  });
});
