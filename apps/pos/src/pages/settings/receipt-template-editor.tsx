import { Link, useBlocker, useParams } from '@tanstack/react-router';
import { type ReactNode, useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PaperPicker } from '../../components/paper-picker';
import { PosIcon } from '../../components/pos-icon';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import { PrintPortal } from '../../components/print-sheet';
import type { BlockProblems } from '../../components/receipt-template/block-editor';
import {
  BlockList,
  type KeyedBlock,
  keyBlocks,
} from '../../components/receipt-template/block-list';
import { FieldToggles } from '../../components/receipt-template/field-toggles';
import {
  PreviewControls,
  type PreviewSource,
  TemplatePreview,
  usePreviewData,
} from '../../components/receipt-template/template-preview';
import { VersionDrawer } from '../../components/receipt-template/version-drawer';
import {
  type ReceiptTemplate,
  refreshReceiptTemplates,
  restoreReceiptTemplate,
  updateReceiptTemplate,
  useReceiptTemplate,
} from '../../hooks/use-receipt-templates';
import { useBranches, useMemberships, useRegisters } from '../../hooks/use-topology';
import { administrationAccess } from '../../lib/pos-administration';
import { createBrowserPrintAdapter } from '../../lib/print-adapter';
import { DEFAULT_TEMPLATES } from '../../lib/receipt-template/defaults';
import { renderDocument } from '../../lib/receipt-template/render';
import type {
  DocumentType,
  LineColumn,
  PageSettings,
  PaperSize,
  TemplateConfig,
  TextSize,
} from '../../lib/receipt-template/types';
import {
  charsPerLine,
  editableConfig,
  type IssueArea,
  issueTarget,
  LOCKED_COLUMNS,
  LOCKED_TOTALS,
  MAX_NAME_LENGTH,
  SECTION_RULES,
  serverIssues,
  type TemplateIssue,
  UNPRINTED_META,
  validateTemplate,
} from '../../lib/receipt-template/validate';
import { conflictReason, describeFailure, posFailureKey } from '../../lib/request-failure';
import { templateFailure } from './receipt-templates';
import '../../styles/receipt-templates.css';

const adapter = createBrowserPrintAdapter();

type Draft = {
  name: string;
  paper: PaperSize;
  config: TemplateConfig;
  header: KeyedBlock[];
  footer: KeyedBlock[];
};

// Block settings the block editor marks next to their own field.
const BLOCK_FIELDS = ['value', 'label', 'width_pct', 'mm', 'fields'];

type Conflict = {
  current: number;
  action: { kind: 'save' } | { kind: 'restore'; version: number };
};

type SectionId = 'page' | 'header' | 'meta' | 'lines' | 'totals' | 'footer';

// Recorded documents carry the copy banner on every reprint.
const RECORDED: readonly DocumentType[] = ['sale', 'return', 'refund', 'shift_closure'];

const SECTION_OF: Record<IssueArea, SectionId> = {
  name: 'page',
  paper: 'page',
  page: 'page',
  config: 'page',
  header: 'header',
  meta: 'meta',
  lines: 'lines',
  totals: 'totals',
  payments: 'totals',
  footer: 'footer',
};

function draftOf(template: ReceiptTemplate): Draft {
  const config = editableConfig(template.config, template.document_type);
  return {
    name: template.name,
    paper: template.paper,
    config,
    header: keyBlocks(config.header),
    footer: keyBlocks(config.footer),
  };
}

// The template as saved: the edited sections with the blocks in order.
function configOf(draft: Draft): TemplateConfig {
  return {
    ...draft.config,
    header: draft.header.map((item) => item.block),
    footer: draft.footer.map((item) => item.block),
  };
}

const fingerprint = (draft: Draft) =>
  JSON.stringify({ name: draft.name.trim(), paper: draft.paper, config: configOf(draft) });

function Section({
  id,
  title,
  open,
  problems,
  onToggle,
  children,
}: {
  id: SectionId;
  title: string;
  open: boolean;
  problems: number;
  onToggle: (id: SectionId, open: boolean) => void;
  children: ReactNode;
}) {
  const { t } = useTranslation();
  return (
    <details
      className="rt-section"
      open={open}
      data-section={id}
      data-invalid={problems > 0 || undefined}
      onToggle={(event) => {
        const next = event.currentTarget.open;
        if (next !== open) onToggle(id, next);
      }}
    >
      <summary>
        <span>{title}</span>
        {problems > 0 ? (
          <span className="status-tag" data-danger="true">
            {t('receiptTemplates.problemCount', { count: problems })}
          </span>
        ) : null}
      </summary>
      <div className="rt-section-body">{children}</div>
    </details>
  );
}

export function ReceiptTemplateEditorPage() {
  const { t } = useTranslation();
  const { context } = usePosSelection();
  const access = administrationAccess(context.data);
  const templateId = useParams({ strict: false }).templateId ?? '';
  const query = useReceiptTemplate(templateId, access.read);
  const template = query.data;
  return (
    <PosPage
      title={
        template
          ? `${t('receiptTemplates.editorTitle')} · ${template.name}`
          : t('receiptTemplates.editorTitle')
      }
      description={t('receiptTemplates.editorIntro')}
    >
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !access.read ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <div className="pos-administration rt-page">
          <nav className="admin-branch-nav" aria-label={t('receiptTemplates.navigation')}>
            <Link className="button-link" to="/settings/receipt-templates">
              <PosIcon name="back" />
              {t('receiptTemplates.backToList')}
            </Link>
          </nav>
          {query.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
          {query.isError ? (
            <PageState kind="error" title={t(posFailureKey(query.error))}>
              <p>{describeFailure(query.error, t)}</p>
              <button type="button" onClick={() => void query.refetch()}>
                {t('retry')}
              </button>
            </PageState>
          ) : null}
          {template ? (
            <TemplateEditor
              key={template.id}
              template={template}
              canWrite={access.write}
              reload={async () => (await query.refetch()).data ?? null}
            />
          ) : null}
        </div>
      )}
    </PosPage>
  );
}

function TemplateEditor({
  template: loaded,
  canWrite,
  reload,
}: {
  template: ReceiptTemplate;
  canWrite: boolean;
  reload: () => Promise<ReceiptTemplate | null>;
}) {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const branches = useBranches(true);
  const registers = useRegisters(true);
  const memberships = useMemberships(true);
  // The saved template this draft started from.
  const [base, setBase] = useState(loaded);
  const [draft, setDraft] = useState(() => draftOf(loaded));
  const [savedPrint, setSavedPrint] = useState(() => fingerprint(draftOf(loaded)));
  const [serverProblems, setServerProblems] = useState<TemplateIssue[]>([]);
  // The refused action and the version the server holds now.
  const [conflict, setConflict] = useState<Conflict | null>(null);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const [busy, setBusy] = useState(false);
  const [open, setOpen] = useState<Set<SectionId>>(() => new Set(['page']));
  const [pane, setPane] = useState<'edit' | 'preview'>('edit');
  const [source, setSource] = useState<PreviewSource>('sample');
  const [branchId, setBranchId] = useState('');
  const [registerId, setRegisterId] = useState('');
  const [history, setHistory] = useState(false);
  const [testPrinting, setTestPrinting] = useState(false);

  const type = base.document_type;
  const rules = SECTION_RULES[type];
  const readOnly = !canWrite || base.status !== 'active';
  const config = useMemo(() => configOf(draft), [draft]);
  const dirty = fingerprint(draft) !== savedPrint;
  const zone = context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh';

  const activeBranches = (branches.data?.data ?? []).filter((row) => row.status === 'active');
  // Posted receipts are readable only at branches the staff member works at,
  // whatever their settings access.
  const memberBranchIds = new Set(
    (memberships.data?.data ?? [])
      .filter((row) => row.staff_id === context.data?.staff.id && row.status === 'active')
      .map((row) => row.branch_id),
  );
  const memberBranches = activeBranches.filter((row) => memberBranchIds.has(row.id));
  const branchRows = source === 'latest' ? memberBranches : activeBranches;
  const registerRows = (registers.data?.data ?? []).filter(
    (register) => register.status === 'active',
  );
  const branch =
    branchRows.find((row) => row.id === branchId) ??
    branchRows.find((row) => row.id === selection.branchId) ??
    branchRows[0] ??
    null;
  const register =
    registerRows.find((row) => row.id === registerId && row.branch_id === branch?.id) ?? null;
  const preview = usePreviewData({
    documentType: type,
    source,
    context: context.data,
    branch,
    register,
  });

  const issues = useMemo(
    () => [...serverProblems, ...validateTemplate({ ...draft, config }, type)],
    [serverProblems, draft, config, type],
  );
  const message = (issue: TemplateIssue) =>
    t(`receiptTemplates.errors.${issue.code}`, {
      defaultValue: issue.message ?? t('receiptTemplates.errors.invalid_value'),
    });
  const located = issues.map((issue) => ({ issue, ...issueTarget(issue.pointer) }));
  const problemCount = (section: SectionId) =>
    located.filter((item) => SECTION_OF[item.area] === section).length;
  // `key` is the pointer segment right under the area: `/name`,
  // `/config/page/margin_mm`, `/config/lines/columns/3`.
  const fieldProblem = (area: IssueArea, key: string) => {
    const found = located.find((item) => {
      if (item.area !== area) return false;
      const parts = item.issue.pointer.split('/');
      return (area === 'name' || area === 'paper' ? parts[1] : parts[3]) === key;
    });
    return found ? message(found.issue) : null;
  };
  const blockProblems = (place: 'header' | 'footer') => (index: number) => {
    const problems: BlockProblems = {};
    for (const item of located) {
      if (item.area !== place || item.index !== index) continue;
      const key = item.issue.pointer.split('/')[4] ?? '';
      // Settings without a field of their own are reported on the block.
      problems[BLOCK_FIELDS.includes(key) ? key : ''] ??= message(item.issue);
    }
    return problems;
  };
  const listProblem = (place: 'header' | 'footer') => {
    const found = located.find((item) => item.area === place && item.index === null);
    return found ? message(found.issue) : null;
  };
  // A field section problem names the field by label key or by list position.
  const sectionFieldProblem =
    (section: 'meta' | 'totals' | 'payments') =>
    (field: string): string | null => {
      const fields = (config[section]?.fields ?? []) as string[];
      const found = located.find((item) => {
        if (item.area !== section) return false;
        const [, , , kind, key] = item.issue.pointer.split('/');
        return kind === 'labels'
          ? key === field
          : kind === 'fields' && fields[Number(key)] === field;
      });
      return found ? message(found.issue) : null;
    };

  useBlocker({
    shouldBlockFn: () => dirty && !window.confirm(t('receiptTemplates.leaveUnsaved')),
    enableBeforeUnload: () => dirty,
  });

  const edit = (change: (current: Draft) => Draft) => {
    setDraft(change);
    setServerProblems([]);
  };
  const editConfig = (change: Partial<TemplateConfig>) =>
    edit((current) => ({ ...current, config: { ...current.config, ...change } }));
  const editPage = (change: Partial<PageSettings>) =>
    edit((current) => ({
      ...current,
      config: { ...current.config, page: { ...current.config.page, ...change } },
    }));

  const load = (template: ReceiptTemplate) => {
    const next = draftOf(template);
    setBase(template);
    setDraft(next);
    setSavedPrint(fingerprint(next));
    setServerProblems([]);
    setConflict(null);
  };

  const openSections = (list: TemplateIssue[]) =>
    setOpen((current) => {
      const next = new Set(current);
      for (const issue of list) next.add(SECTION_OF[issueTarget(issue.pointer).area]);
      return next;
    });

  async function save(expected = base.current_version) {
    if (busy || readOnly) return;
    const local = validateTemplate({ ...draft, config }, type);
    if (local.length > 0) {
      openSections(local);
      setNotice({ text: t('receiptTemplates.fixProblems'), failed: true });
      return;
    }
    setBusy(true);
    setNotice(null);
    try {
      const result = await updateReceiptTemplate(base.id, {
        expected_version: expected,
        name: draft.name.trim(),
        paper: draft.paper,
        config,
      });
      load(result.data);
      setNotice({
        text: t('receiptTemplates.saved', { version: result.data.current_version }),
        failed: false,
      });
      await refreshReceiptTemplates();
    } catch (error) {
      handleFailure(error, { kind: 'save' });
    } finally {
      setBusy(false);
    }
  }

  function handleFailure(error: unknown, action: Conflict['action']) {
    const problems = serverIssues(error);
    if (problems.length > 0) {
      setServerProblems(problems);
      openSections(problems);
      setNotice({ text: t('receiptTemplates.serverRejected'), failed: true });
      return;
    }
    if (conflictReason(error) === 'template_version_conflict') {
      const details = (error as { details?: { current_version?: unknown } }).details;
      const current = details?.current_version;
      setConflict({
        current: typeof current === 'number' ? current : base.current_version,
        action,
      });
      setNotice(null);
      return;
    }
    setNotice({ text: templateFailure(error, t), failed: true });
  }

  async function reloadLatest() {
    if (dirty && !window.confirm(t('adminDiscard'))) return;
    setBusy(true);
    try {
      const fresh = await reload();
      if (fresh) load(fresh);
      setNotice({ text: t('receiptTemplates.reloaded'), failed: false });
    } catch (error) {
      setNotice({ text: describeFailure(error, t), failed: true });
    } finally {
      setBusy(false);
    }
  }

  // `expected` is given when retrying after a conflict the user accepted.
  async function restoreVersion(version: number, expected?: number) {
    if (busy || readOnly) return;
    if (expected === undefined && dirty && !window.confirm(t('adminDiscard'))) return;
    setBusy(true);
    setNotice(null);
    try {
      const result = await restoreReceiptTemplate(
        base.id,
        version,
        expected ?? base.current_version,
      );
      load(result.data);
      setHistory(false);
      setNotice({
        text: t('receiptTemplates.restored', { version, current: result.data.current_version }),
        failed: false,
      });
      await refreshReceiptTemplates();
    } catch (error) {
      setHistory(false);
      handleFailure(error, { kind: 'restore', version });
    } finally {
      setBusy(false);
    }
  }

  function loadDefaults() {
    const config = editableConfig(DEFAULT_TEMPLATES[type], type);
    edit((current) => ({
      ...current,
      config,
      header: keyBlocks(config.header),
      footer: keyBlocks(config.footer),
    }));
    setNotice({ text: t('receiptTemplates.defaultsLoaded'), failed: false });
  }

  // A test print renders the preview with its worthless-copy banner and
  // records nothing: no print call reaches the server.
  const testDocument = useMemo(
    () => (testPrinting ? renderDocument(config, preview.data, { testPrint: true }) : null),
    [testPrinting, config, preview.data],
  );
  useEffect(() => {
    if (!testPrinting) return;
    if (!document.querySelector('[data-testid="receipt-template-test-print"]')) return;
    void adapter
      .deliver(draft.paper, { title: t('receiptTemplates.testPrintTitle', { name: draft.name }) })
      .then((outcome) => {
        if (!outcome.ok)
          setNotice({
            text: t(outcome.reason === 'blocked' ? 'receiptPrintBlocked' : 'receiptPrintFailed'),
            failed: true,
          });
        setTestPrinting(false);
      });
  }, [testPrinting, draft.paper, draft.name, t]);

  const toggleSection = (id: SectionId, next: boolean) =>
    setOpen((current) => {
      const copy = new Set(current);
      if (next) copy.add(id);
      else copy.delete(id);
      return copy;
    });
  const sectionProps = (id: SectionId) => ({
    id,
    open: open.has(id),
    problems: problemCount(id),
    onToggle: toggleSection,
  });

  const lines = config.lines;
  const columnSet = new Set<string>(lines?.columns ?? []);
  const toggleColumn = (column: LineColumn, on: boolean) => {
    if (!lines || !rules.lines) return;
    const allowed = rules.lines;
    const columns = on
      ? allowed.filter((item) => item === column || columnSet.has(item))
      : lines.columns.filter((item) => item !== column);
    editConfig({ lines: { ...lines, columns } });
  };
  const widthLimit = charsPerLine(draft.paper, config.page.font_size);

  return (
    <div className="rt-editor" data-pane={pane}>
      <div className="rt-toolbar">
        <div className="rt-toolbar-status">
          <strong>{t(`receiptTemplates.type.${type}`)}</strong>
          <small>
            {t('receiptTemplates.versionShort', { version: base.current_version })}
            {base.is_default ? ` · ${t('receiptTemplates.default')}` : ''}
            {base.status !== 'active' ? ` · ${t('statusDisabled')}` : ''}
          </small>
          {dirty ? (
            <span className="status-tag" data-warning="true">
              {t('receiptTemplates.unsaved')}
            </span>
          ) : null}
          {!canWrite ? <span className="status-tag">{t('adminReadAccess')}</span> : null}
        </div>
        <div className="rt-toolbar-actions">
          <button type="button" disabled={testPrinting} onClick={() => setTestPrinting(true)}>
            <PosIcon name="print" />
            {t('receiptTemplates.testPrint')}
          </button>
          {readOnly ? null : (
            <>
              <button type="button" disabled={busy} onClick={() => setHistory(true)}>
                <PosIcon name="list" />
                {t('receiptTemplates.history.open')}
              </button>
              <button type="button" disabled={busy} onClick={loadDefaults}>
                {t('receiptTemplates.loadDefaults')}
              </button>
              <button
                type="button"
                className="primary-button"
                disabled={busy || !dirty}
                onClick={() => void save()}
              >
                <PosIcon name="check" />
                {busy ? t('waiting') : t('save')}
              </button>
            </>
          )}
        </div>
      </div>
      {conflict !== null ? (
        <div className="rt-conflict" role="alert">
          <p>{t('receiptTemplates.conflict')}</p>
          <div className="admin-record-actions">
            <button type="button" disabled={busy} onClick={() => void reloadLatest()}>
              {t('receiptTemplates.conflictReload')}
            </button>
            {conflict.action.kind === 'restore' ? (
              <button
                type="button"
                className="danger-button"
                disabled={busy}
                onClick={() =>
                  conflict.action.kind === 'restore' &&
                  void restoreVersion(conflict.action.version, conflict.current)
                }
              >
                {t('receiptTemplates.conflictRestore', { version: conflict.action.version })}
              </button>
            ) : dirty ? (
              // Overwriting only makes sense while there are changes of one's own.
              <button
                type="button"
                className="danger-button"
                disabled={busy}
                onClick={() => void save(conflict.current)}
              >
                {t('receiptTemplates.conflictOverwrite')}
              </button>
            ) : null}
          </div>
        </div>
      ) : null}
      {notice ? (
        <p
          className={notice.failed ? 'error' : 'page-success'}
          role={notice.failed ? 'alert' : 'status'}
        >
          {notice.text}
        </p>
      ) : null}
      {base.status !== 'active' ? (
        <p className="admin-info">{t('receiptTemplates.disabledReadOnly')}</p>
      ) : null}
      <fieldset className="rt-panes">
        <legend className="visually-hidden">{t('receiptTemplates.panes')}</legend>
        {(['edit', 'preview'] as const).map((value) => (
          <button
            key={value}
            type="button"
            aria-pressed={pane === value}
            onClick={() => setPane(value)}
          >
            {t(`receiptTemplates.pane.${value}`)}
          </button>
        ))}
      </fieldset>
      <div className="rt-columns">
        {/* Disabled while a request runs, so no edit lands between sending and the answer. */}
        <fieldset className="rt-form-pane" disabled={busy} aria-busy={busy || undefined}>
          <Section {...sectionProps('page')} title={t('receiptTemplates.section.page')}>
            <div className="rt-form-grid">
              <label>
                {t('receiptTemplates.name')}
                <input
                  value={draft.name}
                  maxLength={MAX_NAME_LENGTH}
                  disabled={readOnly}
                  aria-invalid={fieldProblem('name', 'name') ? true : undefined}
                  onChange={(event) =>
                    edit((current) => ({ ...current, name: event.target.value }))
                  }
                />
              </label>
              {fieldProblem('name', 'name') ? (
                <small className="rt-error">{fieldProblem('name', 'name')}</small>
              ) : null}
              <PaperPicker
                value={draft.paper}
                disabled={readOnly}
                onChange={(paper) => edit((current) => ({ ...current, paper }))}
              />
              <label>
                {t('receiptTemplates.page.margin')}
                <input
                  type="number"
                  min={0}
                  max={20}
                  step={1}
                  value={config.page.margin_mm}
                  disabled={readOnly}
                  aria-invalid={fieldProblem('page', 'margin_mm') ? true : undefined}
                  onChange={(event) => editPage({ margin_mm: Number(event.target.value) })}
                />
              </label>
              {fieldProblem('page', 'margin_mm') ? (
                <small className="rt-error">{fieldProblem('page', 'margin_mm')}</small>
              ) : null}
              <label>
                {t('receiptTemplates.page.font')}
                <select
                  value={config.page.font}
                  disabled={readOnly}
                  onChange={(event) => editPage({ font: event.target.value as 'sans' | 'mono' })}
                >
                  <option value="sans">{t('receiptTemplates.page.fontSans')}</option>
                  <option value="mono">{t('receiptTemplates.page.fontMono')}</option>
                </select>
              </label>
              <label>
                {t('receiptTemplates.page.fontSize')}
                <select
                  value={config.page.font_size}
                  disabled={readOnly}
                  onChange={(event) => editPage({ font_size: event.target.value as TextSize })}
                >
                  {(['s', 'm', 'l'] as const).map((size) => (
                    <option key={size} value={size}>
                      {t(`receiptTemplates.size.${size}`)}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                {t('receiptTemplates.page.lineSpacing')}
                <input
                  type="number"
                  min={1}
                  max={1.6}
                  step={0.05}
                  value={config.page.line_spacing}
                  disabled={readOnly}
                  aria-invalid={fieldProblem('page', 'line_spacing') ? true : undefined}
                  onChange={(event) => editPage({ line_spacing: Number(event.target.value) })}
                />
              </label>
              {fieldProblem('page', 'line_spacing') ? (
                <small className="rt-error">{fieldProblem('page', 'line_spacing')}</small>
              ) : null}
            </div>
          </Section>

          <Section {...sectionProps('header')} title={t('receiptTemplates.section.header')}>
            <BlockList
              place="header"
              blocks={draft.header}
              data={preview.data}
              paper={draft.paper}
              pageSize={config.page.font_size}
              readOnly={readOnly}
              lockedBefore={[
                ...(RECORDED.includes(type) ? [t('receiptTemplates.lockedCopyBanner')] : []),
                ...(type === 'prebill' ? [t('receiptTemplates.lockedPrebillBanner')] : []),
              ]}
              listProblem={listProblem('header')}
              problemsAt={blockProblems('header')}
              onChange={(header) => edit((current) => ({ ...current, header }))}
            />
          </Section>

          {rules.meta && config.meta ? (
            <Section {...sectionProps('meta')} title={t('receiptTemplates.section.meta')}>
              <FieldToggles
                section="meta"
                documentType={type}
                fields={rules.meta.filter((field) => !UNPRINTED_META.includes(field))}
                value={config.meta}
                readOnly={readOnly}
                invalid={sectionFieldProblem('meta')}
                onChange={(meta) => editConfig({ meta })}
              />
              {type === 'shift_closure' ? (
                <small className="rt-field-note">{t('receiptTemplates.shiftFiguresLocked')}</small>
              ) : null}
            </Section>
          ) : null}

          {rules.lines && lines ? (
            <Section {...sectionProps('lines')} title={t('receiptTemplates.section.lines')}>
              <div className="rt-form-grid">
                <label>
                  {t('receiptTemplates.lines.layout')}
                  <select
                    value={lines.layout}
                    disabled={readOnly}
                    onChange={(event) =>
                      editConfig({
                        lines: { ...lines, layout: event.target.value as 'stacked' | 'table' },
                      })
                    }
                  >
                    <option value="stacked">{t('receiptTemplates.lines.stacked')}</option>
                    <option value="table">{t('receiptTemplates.lines.table')}</option>
                  </select>
                </label>
              </div>
              <fieldset className="rt-checks">
                <legend>{t('receiptTemplates.lines.columns')}</legend>
                {rules.lines.map((column) => {
                  const locked = LOCKED_COLUMNS.includes(column);
                  return (
                    <label
                      key={column}
                      title={locked ? t('receiptTemplates.lockedHint') : undefined}
                    >
                      <input
                        type="checkbox"
                        checked={locked || columnSet.has(column)}
                        disabled={readOnly || locked}
                        onChange={(event) => toggleColumn(column, event.target.checked)}
                      />
                      {t(`receiptTemplates.fields.lines.${column}`)}
                      {locked ? (
                        <small className="rt-locked">{t('receiptTemplates.locked')}</small>
                      ) : null}
                    </label>
                  );
                })}
              </fieldset>
              {fieldProblem('lines', 'columns') ? (
                <small className="rt-error">{fieldProblem('lines', 'columns')}</small>
              ) : null}
              <label>
                <input
                  type="checkbox"
                  checked={lines.show_trace}
                  disabled={readOnly}
                  onChange={(event) =>
                    editConfig({ lines: { ...lines, show_trace: event.target.checked } })
                  }
                />
                {t('receiptTemplates.lines.showTrace')}
              </label>
              <label>
                <input
                  type="checkbox"
                  checked={lines.show_conversion}
                  disabled={readOnly}
                  onChange={(event) =>
                    editConfig({ lines: { ...lines, show_conversion: event.target.checked } })
                  }
                />
                {t('receiptTemplates.lines.showConversion')}
              </label>
            </Section>
          ) : null}

          {rules.totals || rules.payments ? (
            <Section {...sectionProps('totals')} title={t('receiptTemplates.section.totals')}>
              {rules.totals && config.totals ? (
                <>
                  <h4>{t('receiptTemplates.section.totalsOnly')}</h4>
                  <FieldToggles
                    section="totals"
                    documentType={type}
                    fields={rules.totals}
                    locked={LOCKED_TOTALS}
                    value={config.totals}
                    readOnly={readOnly}
                    invalid={sectionFieldProblem('totals')}
                    onChange={(totals) => editConfig({ totals })}
                  />
                </>
              ) : null}
              {rules.payments && config.payments ? (
                <>
                  <h4>{t('receiptTemplates.section.payments')}</h4>
                  <FieldToggles
                    section="payments"
                    documentType={type}
                    fields={rules.payments}
                    value={config.payments}
                    readOnly={readOnly}
                    invalid={sectionFieldProblem('payments')}
                    onChange={(payments) => editConfig({ payments })}
                  />
                </>
              ) : null}
              {type === 'refund' ? (
                <small className="rt-field-note">{t('receiptTemplates.refundAmountLocked')}</small>
              ) : null}
            </Section>
          ) : null}

          <Section {...sectionProps('footer')} title={t('receiptTemplates.section.footer')}>
            <BlockList
              place="footer"
              blocks={draft.footer}
              data={preview.data}
              paper={draft.paper}
              pageSize={config.page.font_size}
              readOnly={readOnly}
              lockedAfter={
                preview.data.disclaimer
                  ? [t('receiptTemplates.lockedDisclaimer', { text: preview.data.disclaimer })]
                  : []
              }
              listProblem={listProblem('footer')}
              problemsAt={blockProblems('footer')}
              onChange={(footer) => edit((current) => ({ ...current, footer }))}
            />
          </Section>
          {located.some((item) => item.area === 'config') ? (
            <p className="error">
              {located
                .filter((item) => item.area === 'config')
                .map((item) => message(item.issue))
                .join(' ')}
            </p>
          ) : null}
        </fieldset>
        <section className="rt-preview-pane" aria-label={t('receiptTemplates.preview.title')}>
          <h2>{t('receiptTemplates.preview.title')}</h2>
          <PreviewControls
            documentType={type}
            source={source}
            status={preview.status}
            branches={branchRows}
            canReadReceipts={memberBranches.length > 0}
            registers={registerRows}
            branchId={branch?.id ?? ''}
            registerId={register?.id ?? ''}
            onSource={setSource}
            onBranch={(id) => {
              setBranchId(id);
              setRegisterId('');
            }}
            onRegister={setRegisterId}
          />
          {widthLimit !== null ? (
            <small className="rt-field-note">
              {t('receiptTemplates.preview.width', { count: widthLimit, paper: draft.paper })}
            </small>
          ) : null}
          <TemplatePreview config={config} data={preview.data} paper={draft.paper} />
        </section>
      </div>
      {testDocument ? (
        <PrintPortal
          document={testDocument}
          paper={draft.paper}
          testId="receipt-template-test-print"
        />
      ) : null}
      {history ? (
        <VersionDrawer
          template={base}
          data={preview.data}
          timeZone={zone}
          busy={busy}
          onRestore={(version) => void restoreVersion(version)}
          onClose={() => setHistory(false)}
        />
      ) : null}
    </div>
  );
}
