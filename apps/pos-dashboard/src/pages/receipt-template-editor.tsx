import { DEFAULT_TEMPLATES } from '@parkviet/pos-shared/receipt-template/defaults'
import { MAX_COPIES, renderDocument } from '@parkviet/pos-shared/receipt-template/render'
import type {
  DocumentType,
  LineColumn,
  PageSettings,
  PaperSize,
  TemplateConfig,
} from '@parkviet/pos-shared/receipt-template/types'
import {
  COPIES_TYPES,
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
} from '@parkviet/pos-shared/receipt-template/validate'
import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import { useAuth, useStore } from '@spree/dashboard-core'
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
  Badge,
  Button,
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  Input,
  Label,
} from '@spree/dashboard-ui'
import { Link, useBlocker, useParams } from '@tanstack/react-router'
import { ArrowLeft, Check as CheckIcon, History, Printer } from 'lucide-react'
import { type ReactNode, useCallback, useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import type { BlockProblems } from '../components/receipt-template/block-editor'
import { BlockList, type KeyedBlock, keyBlocks } from '../components/receipt-template/block-list'
import { Check, Choice, Notice, PageState, Problem } from '../components/receipt-template/controls'
import { FieldToggles } from '../components/receipt-template/field-toggles'
import { PaperPicker } from '../components/receipt-template/paper-picker'
import {
  PreviewControls,
  type PreviewSource,
  ReceiptFrame,
  TemplatePreview,
  usePreviewData,
} from '../components/receipt-template/template-preview'
import { VersionDrawer } from '../components/receipt-template/version-drawer'
import { useBranchSelection } from '../hooks/use-branch-selection'
import { usePosContext } from '../hooks/use-pos-context'
import {
  type ReceiptTemplate,
  refreshReceiptTemplates,
  restoreReceiptTemplate,
  updateReceiptTemplate,
  useReceiptTemplate,
} from '../hooks/use-receipt-templates'
import { useBranches, useMemberships, useRegisters } from '../hooks/use-topology'
import {
  clearEditorDraft,
  editorDraftKey,
  readEditorDraft,
  sessionDraftStorage,
  writeEditorDraft,
} from '../lib/editor-draft'
import { templateFailure } from './receipt-templates'

type Draft = {
  name: string
  paper: PaperSize
  config: TemplateConfig
  header: KeyedBlock[]
  footer: KeyedBlock[]
}
const BLOCK_FIELDS = [
  'value',
  'label',
  'width_pct',
  'mm',
  'fields',
  'field',
  'caption',
  'parties',
  'labels',
]
type Conflict = { current: number; action: { kind: 'save' } | { kind: 'restore'; version: number } }
type SectionId = 'page' | 'header' | 'meta' | 'lines' | 'totals' | 'footer'
const RECORDED: readonly DocumentType[] = ['sale', 'return', 'refund', 'shift_closure']
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
}
function buildDraft(
  name: string,
  paper: PaperSize,
  source: TemplateConfig,
  type: DocumentType,
): Draft {
  const config = editableConfig(source, type)
  return { name, paper, config, header: keyBlocks(config.header), footer: keyBlocks(config.footer) }
}
function draftOf(template: ReceiptTemplate): Draft {
  return buildDraft(template.name, template.paper, template.config, template.document_type)
}
// What survives a forced sign-out: the editable fields only, re-keyed and
// re-normalized on restore exactly like server data.
type StoredDraft = { name: string; paper: PaperSize; config: TemplateConfig }
const storedDraftOf = (draft: Draft): StoredDraft => ({
  name: draft.name,
  paper: draft.paper,
  config: configOf(draft),
})
const parseStoredDraft =
  (type: DocumentType) =>
  (value: unknown): Draft | null => {
    if (value === null || typeof value !== 'object') return null
    const { name, paper, config } = value as Partial<Record<keyof StoredDraft, unknown>>
    if (typeof name !== 'string' || typeof paper !== 'string') return null
    if (config === null || typeof config !== 'object' || Array.isArray(config)) return null
    // An unknown paper size is kept and reported by validateTemplate.
    return buildDraft(name, paper as PaperSize, config as TemplateConfig, type)
  }
function configOf(draft: Draft): TemplateConfig {
  return {
    ...draft.config,
    header: draft.header.map((item) => item.block),
    footer: draft.footer.map((item) => item.block),
  }
}
const fingerprint = (draft: Draft) =>
  JSON.stringify({ name: draft.name.trim(), paper: draft.paper, config: configOf(draft) })

function Section({
  id,
  title,
  problems,
  children,
}: {
  id: SectionId
  title: string
  problems: number
  children: ReactNode
}) {
  const { t } = useTranslation('pos')
  return (
    <AccordionItem value={id} data-section={id} data-invalid={problems > 0 || undefined}>
      <AccordionTrigger>
        {title}
        {problems > 0 ? (
          <Badge variant="destructive">
            {t('receiptTemplates.problemCount', { count: problems })}
          </Badge>
        ) : null}
      </AccordionTrigger>
      <AccordionContent className="grid gap-4">{children}</AccordionContent>
    </AccordionItem>
  )
}

export function ReceiptTemplateEditorPage() {
  const { t } = useTranslation('pos')
  const { storeId } = useStore()
  const context = usePosContext()
  const access = context.data?.administration ?? { read: false, write: false }
  const templateId = useParams({ strict: false }).templateId ?? ''
  const query = useReceiptTemplate(templateId, access.read)
  const template = query.data
  return (
    <div className="mx-auto grid w-full max-w-[1600px] gap-5 p-4 md:p-6">
      <header className="grid gap-2">
        <Button asChild variant="ghost" className="w-fit">
          <Link to="/$storeId/settings/receipt-templates" params={{ storeId }}>
            <ArrowLeft />
            {t('receiptTemplates.backToList')}
          </Link>
        </Button>
        <h1 className="text-2xl font-semibold">
          {template
            ? `${t('receiptTemplates.editorTitle')} · ${template.name}`
            : t('receiptTemplates.editorTitle')}
        </h1>
        <p className="text-muted-foreground">{t('receiptTemplates.editorIntro')}</p>
      </header>
      {context.isPending ? (
        <PageState title={t('contextWaiting')} />
      ) : context.isError ? (
        <PageState
          title={t(posFailureKey(context.error))}
          error={describeFailure(context.error, t)}
          retry={() => void context.refetch()}
          retryLabel={t('retry')}
        />
      ) : !access.read ? (
        <PageState title={t('forbidden')} error={t('adminAccessDenied')} />
      ) : (
        <>
          {query.isPending ? <PageState title={t('waiting')} /> : null}
          {query.isError ? (
            <PageState
              title={t(posFailureKey(query.error))}
              error={describeFailure(query.error, t)}
              retry={() => void query.refetch()}
              retryLabel={t('retry')}
            />
          ) : null}
          {template ? (
            <TemplateEditor
              key={`${storeId}-${template.id}`}
              template={template}
              canWrite={access.write}
              reload={async () => (await query.refetch()).data ?? null}
            />
          ) : null}
        </>
      )}
    </div>
  )
}

function TemplateEditor({
  template: loaded,
  canWrite,
  reload,
}: {
  template: ReceiptTemplate
  canWrite: boolean
  reload: () => Promise<ReceiptTemplate | null>
}) {
  const { t } = useTranslation('pos')
  const context = usePosContext()
  const branches = useBranches(true)
  const registers = useRegisters(true)
  const memberships = useMemberships(true)
  const { selection } = useBranchSelection(branches.data?.data ?? [])
  const { storeId } = useStore()
  const { user } = useAuth()
  const draftKey = editorDraftKey('receipt-template', String(user?.id ?? ''), storeId, loaded.id)
  // A draft left by an expired session is restored only when it was based on
  // the version the server still has; otherwise it is discarded.
  const [restored] = useState(() =>
    canWrite && loaded.status === 'active'
      ? readEditorDraft(
          sessionDraftStorage(),
          draftKey,
          loaded.current_version,
          parseStoredDraft(loaded.document_type),
        )
      : null,
  )
  const [base, setBase] = useState(loaded)
  const [draft, setDraft] = useState(() => restored ?? draftOf(loaded))
  const [savedPrint, setSavedPrint] = useState(() => fingerprint(draftOf(loaded)))
  const [serverProblems, setServerProblems] = useState<TemplateIssue[]>([])
  const [conflict, setConflict] = useState<Conflict | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(() =>
    restored ? { text: t('receiptTemplates.draftRestored'), failed: false } : null,
  )
  const [busy, setBusy] = useState(false)
  const [open, setOpen] = useState<string[]>(['page'])
  const [pane, setPane] = useState<'edit' | 'preview'>('edit')
  const [source, setSource] = useState<PreviewSource>('sample')
  const [branchId, setBranchId] = useState('')
  const [registerId, setRegisterId] = useState('')
  const [history, setHistory] = useState(false)
  const [testPrinting, setTestPrinting] = useState(false)
  const type = base.document_type
  const rules = SECTION_RULES[type]
  const readOnly = !canWrite || base.status !== 'active'
  const config = useMemo(() => configOf(draft), [draft])
  const dirty = fingerprint(draft) !== savedPrint
  const zone = context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh'
  const activeBranches = (branches.data?.data ?? []).filter((row) => row.status === 'active')
  const memberBranchIds = new Set(
    (memberships.data?.data ?? [])
      .filter((row) => row.staff_id === context.data?.staff.id && row.status === 'active')
      .map((row) => row.branch_id),
  )
  const memberBranches = activeBranches.filter((row) => memberBranchIds.has(row.id))
  const branchRows = source === 'latest' ? memberBranches : activeBranches
  const registerRows = (registers.data?.data ?? []).filter(
    (register) => register.status === 'active',
  )
  const branch =
    branchRows.find((row) => row.id === branchId) ??
    branchRows.find((row) => row.id === selection.branchId) ??
    branchRows[0] ??
    null
  const register =
    registerRows.find((row) => row.id === registerId && row.branch_id === branch?.id) ?? null
  const preview = usePreviewData({
    documentType: type,
    source,
    context: context.data,
    branch,
    register,
  })
  const issues = useMemo(
    () => [...serverProblems, ...validateTemplate({ ...draft, config }, type)],
    [serverProblems, draft, config, type],
  )
  const message = (issue: TemplateIssue) =>
    t(`receiptTemplates.errors.${issue.code}`, {
      defaultValue: issue.message ?? t('receiptTemplates.errors.invalid_value'),
    })
  const located = issues.map((issue) => ({ issue, ...issueTarget(issue.pointer) }))
  const problemCount = (section: SectionId) =>
    located.filter((item) => SECTION_OF[item.area] === section).length
  const fieldProblem = (area: IssueArea, key: string) => {
    const found = located.find((item) => {
      if (item.area !== area) return false
      const parts = item.issue.pointer.split('/')
      return (area === 'name' || area === 'paper' ? parts[1] : parts[3]) === key
    })
    return found ? message(found.issue) : null
  }
  const blockProblems = (place: 'header' | 'footer') => (index: number) => {
    const problems: BlockProblems = {}
    for (const item of located) {
      if (item.area !== place || item.index !== index) continue
      const key = item.issue.pointer.split('/')[4] ?? ''
      problems[BLOCK_FIELDS.includes(key) ? key : ''] ??= message(item.issue)
    }
    return problems
  }
  const listProblem = (place: 'header' | 'footer') => {
    const found = located.find((item) => item.area === place && item.index === null)
    return found ? message(found.issue) : null
  }
  const sectionFieldProblem =
    (section: 'meta' | 'totals' | 'payments') =>
    (field: string): string | null => {
      const fields = (config[section]?.fields ?? []) as string[]
      const found = located.find((item) => {
        if (item.area !== section) return false
        const [, , , kind, key] = item.issue.pointer.split('/')
        return kind === 'labels'
          ? key === field
          : kind === 'fields' && fields[Number(key)] === field
      })
      return found ? message(found.issue) : null
    }
  // Keep unsaved work across a forced sign-out. Unmounting never clears it:
  // session expiry unmounts the editor without a navigation to block. Saving,
  // reloading or restoring makes the draft clean, which clears it.
  useEffect(() => {
    const storage = sessionDraftStorage()
    if (dirty && !readOnly)
      writeEditorDraft(storage, draftKey, base.current_version, storedDraftOf(draft))
    else clearEditorDraft(storage, draftKey)
  }, [dirty, readOnly, draft, draftKey, base.current_version])
  useBlocker({
    shouldBlockFn: () => {
      if (!dirty) return false
      if (!window.confirm(t('receiptTemplates.leaveUnsaved'))) return true
      // Leaving was confirmed: the edits are knowingly discarded.
      clearEditorDraft(sessionDraftStorage(), draftKey)
      return false
    },
    enableBeforeUnload: () => dirty,
  })
  const edit = (change: (current: Draft) => Draft) => {
    setDraft(change)
    setServerProblems([])
  }
  const editConfig = (change: Partial<TemplateConfig>) =>
    edit((current) => ({ ...current, config: { ...current.config, ...change } }))
  const editPage = (change: Partial<PageSettings>) =>
    edit((current) => ({
      ...current,
      config: { ...current.config, page: { ...current.config.page, ...change } },
    }))
  const load = (template: ReceiptTemplate) => {
    const next = draftOf(template)
    setBase(template)
    setDraft(next)
    setSavedPrint(fingerprint(next))
    setServerProblems([])
    setConflict(null)
  }
  const openSections = (list: TemplateIssue[]) =>
    setOpen((current) => [
      ...new Set([...current, ...list.map((issue) => SECTION_OF[issueTarget(issue.pointer).area])]),
    ])
  function handleFailure(error: unknown, action: Conflict['action']) {
    const problems = serverIssues(error)
    if (problems.length > 0) {
      setServerProblems(problems)
      openSections(problems)
      setNotice({ text: t('receiptTemplates.serverRejected'), failed: true })
      return
    }
    if (conflictReason(error) === 'template_version_conflict') {
      const current = (error as { details?: { current_version?: unknown } }).details
        ?.current_version
      setConflict({ current: typeof current === 'number' ? current : base.current_version, action })
      setNotice(null)
      return
    }
    setNotice({ text: templateFailure(error, t), failed: true })
  }
  async function save(expected = base.current_version) {
    if (busy || readOnly) return
    const local = validateTemplate({ ...draft, config }, type)
    if (local.length > 0) {
      openSections(local)
      setNotice({ text: t('receiptTemplates.fixProblems'), failed: true })
      return
    }
    setBusy(true)
    setNotice(null)
    try {
      const result = await updateReceiptTemplate(base.id, {
        expected_version: expected,
        name: draft.name.trim(),
        paper: draft.paper,
        config,
      })
      load(result.data)
      setNotice({
        text: t('receiptTemplates.saved', { version: result.data.current_version }),
        failed: false,
      })
      await refreshReceiptTemplates()
    } catch (error) {
      handleFailure(error, { kind: 'save' })
    } finally {
      setBusy(false)
    }
  }
  async function reloadLatest() {
    if (dirty && !window.confirm(t('adminDiscard'))) return
    setBusy(true)
    try {
      const fresh = await reload()
      if (fresh) {
        load(fresh)
        setNotice({ text: t('receiptTemplates.reloaded'), failed: false })
      }
    } catch (error) {
      setNotice({ text: describeFailure(error, t), failed: true })
    } finally {
      setBusy(false)
    }
  }
  async function restoreVersion(version: number, expected?: number) {
    if (busy || readOnly) return
    if (expected === undefined && dirty && !window.confirm(t('adminDiscard'))) return
    setBusy(true)
    setNotice(null)
    try {
      const result = await restoreReceiptTemplate(
        base.id,
        version,
        expected ?? base.current_version,
      )
      load(result.data)
      setHistory(false)
      setNotice({
        text: t('receiptTemplates.restored', { version, current: result.data.current_version }),
        failed: false,
      })
      await refreshReceiptTemplates()
    } catch (error) {
      setHistory(false)
      handleFailure(error, { kind: 'restore', version })
    } finally {
      setBusy(false)
    }
  }
  function loadDefaults() {
    const config = editableConfig(DEFAULT_TEMPLATES[type], type)
    edit((current) => ({
      ...current,
      config,
      header: keyBlocks(config.header),
      footer: keyBlocks(config.footer),
    }))
    setNotice({ text: t('receiptTemplates.defaultsLoaded'), failed: false })
  }
  const testDocument = useMemo(
    () => (testPrinting ? renderDocument(config, preview.data, { testPrint: true }) : null),
    [testPrinting, config, preview.data],
  )
  const printReady = useCallback(
    (frame: HTMLIFrameElement) => {
      try {
        if (!frame.contentWindow) throw new Error('Print frame unavailable')
        frame.contentWindow.focus()
        frame.contentWindow.print()
      } catch {
        setNotice({ text: t('receiptPrintFailed'), failed: true })
      } finally {
        setTestPrinting(false)
      }
    },
    [t],
  )
  const sectionProps = (id: SectionId) => ({ id, problems: problemCount(id) })
  const lines = config.lines
  const columnSet = new Set<string>(lines?.columns ?? [])
  const toggleColumn = (column: LineColumn, on: boolean) => {
    if (!lines || !rules.lines) return
    const columns = on
      ? rules.lines.filter((item) => item === column || columnSet.has(item))
      : lines.columns.filter((item) => item !== column)
    editConfig({ lines: { ...lines, columns } })
  }
  const widthLimit = charsPerLine(draft.paper, config.page.font_size)
  return (
    <div className="grid gap-4" data-pane={pane}>
      <Card>
        <CardContent className="flex flex-wrap items-center justify-between gap-4 py-4">
          <div className="grid gap-1">
            <strong>{t(`receiptTemplates.type.${type}`)}</strong>
            <small className="text-muted-foreground">
              {t('receiptTemplates.versionShort', { version: base.current_version })}
              {base.is_default ? ` · ${t('receiptTemplates.default')}` : ''}
              {base.status !== 'active' ? ` · ${t('statusDisabled')}` : ''}
            </small>
            <div className="flex gap-2">
              {dirty ? <Badge variant="outline">{t('receiptTemplates.unsaved')}</Badge> : null}
              {!canWrite ? <Badge variant="secondary">{t('adminReadAccess')}</Badge> : null}
            </div>
          </div>
          <div className="flex flex-wrap gap-2">
            <Button
              type="button"
              variant="outline"
              disabled={testPrinting}
              onClick={() => setTestPrinting(true)}
            >
              <Printer />
              {t('receiptTemplates.testPrint')}
            </Button>
            {!readOnly ? (
              <>
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => setHistory(true)}
                >
                  <History />
                  {t('receiptTemplates.history.open')}
                </Button>
                <Button type="button" variant="outline" disabled={busy} onClick={loadDefaults}>
                  {t('receiptTemplates.loadDefaults')}
                </Button>
                <Button type="button" disabled={busy || !dirty} onClick={() => void save()}>
                  <CheckIcon />
                  {busy ? t('waiting') : t('save')}
                </Button>
              </>
            ) : null}
          </div>
        </CardContent>
      </Card>
      {conflict ? (
        <div
          role="alert"
          className="grid gap-3 rounded-lg border border-destructive bg-destructive/5 p-4"
        >
          <p>{t('receiptTemplates.conflict')}</p>
          <div className="flex flex-wrap gap-2">
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => void reloadLatest()}
            >
              {t('receiptTemplates.conflictReload')}
            </Button>
            {conflict.action.kind === 'restore' ? (
              <Button
                type="button"
                variant="destructive"
                disabled={busy}
                onClick={() => {
                  if (conflict.action.kind === 'restore')
                    void restoreVersion(conflict.action.version, conflict.current)
                }}
              >
                {t('receiptTemplates.conflictRestore', { version: conflict.action.version })}
              </Button>
            ) : dirty ? (
              <Button
                type="button"
                variant="destructive"
                disabled={busy}
                onClick={() => void save(conflict.current)}
              >
                {t('receiptTemplates.conflictOverwrite')}
              </Button>
            ) : null}
          </div>
        </div>
      ) : null}
      {notice ? <Notice {...notice} /> : null}
      {base.status !== 'active' ? (
        <p className="text-sm text-muted-foreground">{t('receiptTemplates.disabledReadOnly')}</p>
      ) : null}
      <fieldset className="flex gap-2 lg:hidden">
        <legend className="sr-only">{t('receiptTemplates.panes')}</legend>
        {(['edit', 'preview'] as const).map((value) => (
          <Button
            key={value}
            type="button"
            variant={pane === value ? 'default' : 'outline'}
            aria-pressed={pane === value}
            onClick={() => setPane(value)}
          >
            {t(`receiptTemplates.pane.${value}`)}
          </Button>
        ))}
      </fieldset>
      <div className="grid min-w-0 items-start gap-5 lg:grid-cols-[minmax(0,1fr)_minmax(320px,0.8fr)]">
        <fieldset
          className={`${pane === 'preview' ? 'hidden lg:block' : ''} min-w-0 rounded-xl border bg-card`}
          disabled={busy}
          aria-busy={busy || undefined}
        >
          <Accordion multiple value={open} onValueChange={(value) => setOpen(value as string[])}>
            <Section {...sectionProps('page')} title={t('receiptTemplates.section.page')}>
              <div className="grid gap-3">
                <Label htmlFor="rt-template-name">{t('receiptTemplates.name')}</Label>
                <Input
                  id="rt-template-name"
                  value={draft.name}
                  maxLength={MAX_NAME_LENGTH}
                  disabled={readOnly}
                  aria-invalid={Boolean(fieldProblem('name', 'name'))}
                  onChange={(event) =>
                    edit((current) => ({ ...current, name: event.target.value }))
                  }
                />
                <Problem>{fieldProblem('name', 'name')}</Problem>
                <PaperPicker
                  value={draft.paper}
                  disabled={readOnly || busy}
                  onChange={(paper) => edit((current) => ({ ...current, paper }))}
                />
                <Problem>{fieldProblem('paper', 'paper')}</Problem>
                <Label htmlFor="rt-margin">{t('receiptTemplates.page.margin')}</Label>
                <Input
                  id="rt-margin"
                  type="number"
                  min={0}
                  max={20}
                  step={1}
                  value={config.page.margin_mm}
                  disabled={readOnly}
                  aria-invalid={Boolean(fieldProblem('page', 'margin_mm'))}
                  aria-describedby="rt-margin-hint"
                  onChange={(event) => editPage({ margin_mm: Number(event.target.value) })}
                />
                <small id="rt-margin-hint" className="text-muted-foreground">
                  {t('receiptTemplates.page.marginHint')}
                </small>
                <Problem>{fieldProblem('page', 'margin_mm')}</Problem>
                <div className="grid gap-3 sm:grid-cols-2">
                  <Choice
                    label={t('receiptTemplates.page.font')}
                    value={config.page.font}
                    disabled={readOnly || busy}
                    options={[
                      { value: 'sans', label: t('receiptTemplates.page.fontSans') },
                      { value: 'mono', label: t('receiptTemplates.page.fontMono') },
                    ]}
                    onChange={(font) => editPage({ font })}
                  />
                  <Choice
                    label={t('receiptTemplates.page.fontSize')}
                    value={config.page.font_size}
                    disabled={readOnly || busy}
                    options={(['s', 'm', 'l'] as const).map((value) => ({
                      value,
                      label: t(`receiptTemplates.size.${value}`),
                    }))}
                    onChange={(font_size) => editPage({ font_size })}
                  />
                </div>
                <Label htmlFor="rt-spacing">{t('receiptTemplates.page.lineSpacing')}</Label>
                <Input
                  id="rt-spacing"
                  type="number"
                  min={1}
                  max={1.6}
                  step={0.05}
                  value={config.page.line_spacing}
                  disabled={readOnly}
                  aria-invalid={Boolean(fieldProblem('page', 'line_spacing'))}
                  onChange={(event) => editPage({ line_spacing: Number(event.target.value) })}
                />
                <Problem>{fieldProblem('page', 'line_spacing')}</Problem>
                {COPIES_TYPES.includes(type) ? (
                  <>
                    <Choice
                      label={t('receiptTemplates.page.copies')}
                      value={String(config.page.copies ?? 1)}
                      disabled={readOnly || busy}
                      invalid={Boolean(fieldProblem('page', 'copies'))}
                      describedBy="rt-copies-hint"
                      options={Array.from({ length: MAX_COPIES }, (_, index) => ({
                        value: String(index + 1),
                        label: t('receiptTemplates.page.copiesCount', { count: index + 1 }),
                      }))}
                      onChange={(copies) => editPage({ copies: Number(copies) })}
                    />
                    <small id="rt-copies-hint" className="text-muted-foreground">
                      {t('receiptTemplates.page.copiesHint')}
                    </small>
                  </>
                ) : null}
                <Problem>{fieldProblem('page', 'copies')}</Problem>
              </div>
            </Section>
            <Section {...sectionProps('header')} title={t('receiptTemplates.section.header')}>
              <BlockList
                place="header"
                blocks={draft.header}
                data={preview.data}
                documentType={type}
                paper={draft.paper}
                pageSize={config.page.font_size}
                readOnly={readOnly || busy}
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
                  readOnly={readOnly || busy}
                  invalid={sectionFieldProblem('meta')}
                  onChange={(meta) => editConfig({ meta })}
                />
                {type === 'shift_closure' ? (
                  <small className="text-muted-foreground">
                    {t('receiptTemplates.shiftFiguresLocked')}
                  </small>
                ) : null}
              </Section>
            ) : null}
            {rules.lines && lines ? (
              <Section {...sectionProps('lines')} title={t('receiptTemplates.section.lines')}>
                <Choice
                  label={t('receiptTemplates.lines.layout')}
                  value={lines.layout}
                  disabled={readOnly || busy}
                  options={[
                    { value: 'stacked', label: t('receiptTemplates.lines.stacked') },
                    { value: 'table', label: t('receiptTemplates.lines.table') },
                  ]}
                  onChange={(layout) => editConfig({ lines: { ...lines, layout } })}
                />
                <fieldset className="grid gap-2">
                  <legend className="mb-2 font-medium">
                    {t('receiptTemplates.lines.columns')}
                  </legend>
                  {rules.lines.map((column) => {
                    const locked = LOCKED_COLUMNS.includes(column)
                    return (
                      <Check
                        key={column}
                        checked={locked || columnSet.has(column)}
                        disabled={readOnly || busy || locked}
                        onChange={(on) => toggleColumn(column, on)}
                      >
                        {t(`receiptTemplates.fields.lines.${column}`)}
                        {locked ? (
                          <small className="ml-2 text-muted-foreground">
                            {t('receiptTemplates.locked')}
                          </small>
                        ) : null}
                      </Check>
                    )
                  })}
                </fieldset>
                <Problem>{fieldProblem('lines', 'columns')}</Problem>
                <Check
                  checked={lines.show_trace}
                  disabled={readOnly || busy}
                  onChange={(show_trace) => editConfig({ lines: { ...lines, show_trace } })}
                >
                  {t('receiptTemplates.lines.showTrace')}
                </Check>
                <Check
                  checked={lines.show_conversion}
                  disabled={readOnly || busy}
                  onChange={(show_conversion) =>
                    editConfig({ lines: { ...lines, show_conversion } })
                  }
                >
                  {t('receiptTemplates.lines.showConversion')}
                </Check>
              </Section>
            ) : null}
            {rules.totals || rules.payments ? (
              <Section {...sectionProps('totals')} title={t('receiptTemplates.section.totals')}>
                {rules.totals && config.totals ? (
                  <>
                    <h3 className="font-medium">{t('receiptTemplates.section.totalsOnly')}</h3>
                    <FieldToggles
                      section="totals"
                      documentType={type}
                      fields={rules.totals}
                      locked={LOCKED_TOTALS}
                      value={config.totals}
                      readOnly={readOnly || busy}
                      invalid={sectionFieldProblem('totals')}
                      onChange={(totals) => editConfig({ totals })}
                    />
                  </>
                ) : null}
                {rules.payments && config.payments ? (
                  <>
                    <h3 className="font-medium">{t('receiptTemplates.section.payments')}</h3>
                    <FieldToggles
                      section="payments"
                      documentType={type}
                      fields={rules.payments}
                      value={config.payments}
                      readOnly={readOnly || busy}
                      invalid={sectionFieldProblem('payments')}
                      onChange={(payments) => editConfig({ payments })}
                    />
                  </>
                ) : null}
                {type === 'refund' ? (
                  <small className="text-muted-foreground">
                    {t('receiptTemplates.refundAmountLocked')}
                  </small>
                ) : null}
              </Section>
            ) : null}
            <Section {...sectionProps('footer')} title={t('receiptTemplates.section.footer')}>
              <BlockList
                place="footer"
                blocks={draft.footer}
                data={preview.data}
                documentType={type}
                paper={draft.paper}
                pageSize={config.page.font_size}
                readOnly={readOnly || busy}
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
          </Accordion>
          {located.some((item) => item.area === 'config') ? (
            <p className="p-4 text-destructive">
              {located
                .filter((item) => item.area === 'config')
                .map((item) => message(item.issue))
                .join(' ')}
            </p>
          ) : null}
        </fieldset>
        <Card className={`${pane === 'edit' ? 'hidden lg:flex' : ''} min-w-0 lg:sticky lg:top-4`}>
          <CardHeader>
            <CardTitle>{t('receiptTemplates.preview.title')}</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4">
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
                setBranchId(id)
                setRegisterId('')
              }}
              onRegister={setRegisterId}
            />
            {widthLimit !== null ? (
              <small className="text-muted-foreground">
                {t('receiptTemplates.preview.width', { count: widthLimit, paper: draft.paper })}{' '}
                {t('receiptTemplates.preview.overflow')}
              </small>
            ) : null}
            <TemplatePreview config={config} data={preview.data} paper={draft.paper} markOverflow />
          </CardContent>
        </Card>
      </div>
      {testDocument ? (
        <div className="pointer-events-none fixed -left-[10000px] top-0" aria-hidden="true">
          <ReceiptFrame
            document={testDocument}
            paper={draft.paper}
            title={t('receiptTemplates.testPrintTitle', { name: draft.name })}
            testId="receipt-template-test-print"
            onReady={printReady}
          />
        </div>
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
  )
}
