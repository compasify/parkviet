import { formatDocumentTime } from '@parkviet/pos-shared/receipt-template/data';
import {
  DOCUMENT_TYPES,
  type DocumentType,
  type PaperSize,
} from '@parkviet/pos-shared/receipt-template/types';
import {
  MAX_ACTIVE_TEMPLATES,
  MAX_NAME_LENGTH,
} from '@parkviet/pos-shared/receipt-template/validate';
import { Link, useNavigate } from '@tanstack/react-router';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { AdminDialog } from '../../components/admin-dialog';
import { PaperPicker } from '../../components/paper-picker';
import { PosIcon } from '../../components/pos-icon';
import { PageState, PosPage } from '../../components/pos-page';
import { usePosSelection } from '../../components/pos-selection';
import {
  createReceiptTemplate,
  disableReceiptTemplate,
  duplicateReceiptTemplate,
  makeDefaultReceiptTemplate,
  type ReceiptTemplate,
  refreshReceiptTemplates,
  useReceiptTemplates,
} from '../../hooks/use-receipt-templates';
import { administrationAccess } from '../../lib/pos-administration';
import { conflictReason, describeFailure, posFailureKey } from '../../lib/request-failure';
import '../../styles/receipt-templates.css';

// Why the server refused a template change, in the editor's words.
export function templateFailure(error: unknown, t: (key: string) => string): string {
  switch (conflictReason(error)) {
    case 'template_version_conflict':
      return t('receiptTemplates.conflict');
    case 'template_limit_reached':
      return t('receiptTemplates.limitReached');
    case 'template_disabled':
      return t('receiptTemplates.disabledConflict');
    case 'template_default_required':
      return t('receiptTemplates.defaultRequired');
    default:
      return describeFailure(error, t);
  }
}

// Settings → Print templates: the store's templates by document type. The
// templates belong to the store; branches and registers only fill in their
// variables. Readers see the list and previews, never a write control.
export function ReceiptTemplatesPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { context } = usePosSelection();
  const access = administrationAccess(context.data);
  const templates = useReceiptTemplates(access.read, true);
  const [creating, setCreating] = useState(false);
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const rows = templates.data ?? [];
  const zone = context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const activeCount = (type: DocumentType) =>
    rows.filter((row) => row.document_type === type && row.status === 'active').length;

  async function act(
    template: ReceiptTemplate,
    run: (id: string) => Promise<{ data: ReceiptTemplate }>,
    done: string,
    confirm?: string,
  ) {
    if (!access.write || pendingId || (confirm && !window.confirm(confirm))) return;
    setPendingId(template.id);
    setNotice(null);
    try {
      const result = await run(template.id);
      setNotice({ text: t(done, { name: result.data.name }), failed: false });
    } catch (error) {
      setNotice({ text: templateFailure(error, t), failed: true });
    } finally {
      setPendingId(null);
      await refreshReceiptTemplates();
    }
  }

  return (
    <PosPage title={t('receiptTemplates.title')} description={t('receiptTemplates.intro')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !access.read ? (
        <PageState title={t('forbidden')}>
          <p>{t('adminAccessDenied')}</p>
        </PageState>
      ) : (
        <div className="pos-administration rt-page">
          <nav className="admin-branch-nav" aria-label={t('receiptTemplates.navigation')}>
            <Link className="button-link" to="/settings">
              <PosIcon name="back" />
              {t('branchSettingsBack')}
            </Link>
          </nav>
          <section className="page-card admin-content" aria-labelledby="rt-list-heading">
            <div className="section-heading">
              <div>
                <h2 id="rt-list-heading">{t('receiptTemplates.listTitle')}</h2>
                <p>{t('receiptTemplates.listHint')}</p>
              </div>
              {access.write ? (
                <button
                  type="button"
                  className="primary-button"
                  disabled={Boolean(pendingId) || !templates.isSuccess}
                  onClick={() => {
                    setNotice(null);
                    setCreating(true);
                  }}
                >
                  <PosIcon name="plus" />
                  {t('receiptTemplates.create')}
                </button>
              ) : null}
            </div>
            {notice ? (
              <p
                className={notice.failed ? 'error' : 'page-success'}
                role={notice.failed ? 'alert' : 'status'}
              >
                {notice.text}
              </p>
            ) : null}
            {templates.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
            {templates.isError ? (
              <PageState kind="error" title={t(posFailureKey(templates.error))}>
                <p>{describeFailure(templates.error, t)}</p>
                <button type="button" onClick={() => void templates.refetch()}>
                  {t('retry')}
                </button>
              </PageState>
            ) : null}
            {templates.isSuccess
              ? DOCUMENT_TYPES.map((type) => {
                  const group = rows.filter((row) => row.document_type === type);
                  const full = activeCount(type) >= MAX_ACTIVE_TEMPLATES;
                  const typeName = t(`receiptTemplates.type.${type}`);
                  return (
                    <section key={type} className="rt-group" aria-labelledby={`rt-group-${type}`}>
                      <h3 id={`rt-group-${type}`}>{typeName}</h3>
                      {group.length === 0 ? (
                        <p className="muted">{t('receiptTemplates.groupEmpty')}</p>
                      ) : null}
                      <ul
                        className="admin-records"
                        aria-label={t('receiptTemplates.groupList', { type: typeName })}
                      >
                        {group.map((template) => {
                          const active = template.status === 'active';
                          return (
                            <li key={template.id}>
                              <div className="admin-record-copy">
                                <strong>{template.name}</strong>
                                <small>
                                  {t(`receiptPaper_${template.paper}`)}
                                  {` · ${t('receiptTemplates.versionShort', { version: template.current_version })}`}
                                </small>
                                <small>
                                  {template.updated_by
                                    ? t('receiptTemplates.updatedBy', {
                                        time: formatDocumentTime(template.updated_at, zone),
                                        name: template.updated_by.name,
                                      })
                                    : t('receiptTemplates.updatedAt', {
                                        time: formatDocumentTime(template.updated_at, zone),
                                      })}
                                </small>
                              </div>
                              {template.is_default ? (
                                <span className="status-tag rt-default-tag">
                                  {t('receiptTemplates.default')}
                                </span>
                              ) : null}
                              {active ? null : (
                                <span className="status-tag" data-warning="true">
                                  {t('statusDisabled')}
                                </span>
                              )}
                              <div className="admin-record-actions">
                                <Link
                                  className="button-link"
                                  to="/settings/receipt-templates/$templateId"
                                  params={{ templateId: template.id }}
                                  aria-label={t(
                                    access.write && active
                                      ? 'receiptTemplates.editName'
                                      : 'receiptTemplates.viewName',
                                    { name: template.name },
                                  )}
                                >
                                  <PosIcon name={access.write && active ? 'edit' : 'eye'} />
                                  {t(
                                    access.write && active ? 'adminEdit' : 'receiptTemplates.view',
                                  )}
                                </Link>
                                {access.write ? (
                                  <button
                                    type="button"
                                    disabled={Boolean(pendingId) || full}
                                    title={full ? t('receiptTemplates.limitReached') : undefined}
                                    aria-label={t('receiptTemplates.duplicateName', {
                                      name: template.name,
                                    })}
                                    onClick={() =>
                                      void act(
                                        template,
                                        duplicateReceiptTemplate,
                                        'receiptTemplates.duplicated',
                                      )
                                    }
                                  >
                                    {t('receiptTemplates.duplicate')}
                                  </button>
                                ) : null}
                                {access.write && active && !template.is_default ? (
                                  <button
                                    type="button"
                                    disabled={Boolean(pendingId)}
                                    aria-label={t('receiptTemplates.makeDefaultName', {
                                      name: template.name,
                                    })}
                                    onClick={() =>
                                      void act(
                                        template,
                                        makeDefaultReceiptTemplate,
                                        'receiptTemplates.madeDefault',
                                      )
                                    }
                                  >
                                    {t('receiptTemplates.makeDefault')}
                                  </button>
                                ) : null}
                                {access.write && active ? (
                                  <button
                                    type="button"
                                    className="danger-button"
                                    disabled={Boolean(pendingId)}
                                    aria-label={t('receiptTemplates.disableName', {
                                      name: template.name,
                                    })}
                                    onClick={() =>
                                      void act(
                                        template,
                                        disableReceiptTemplate,
                                        'receiptTemplates.disabled',
                                        t('receiptTemplates.confirmDisable', {
                                          name: template.name,
                                        }),
                                      )
                                    }
                                  >
                                    {pendingId === template.id
                                      ? t('waiting')
                                      : t('receiptTemplates.disable')}
                                  </button>
                                ) : null}
                              </div>
                            </li>
                          );
                        })}
                      </ul>
                      {full && access.write ? (
                        <small className="rt-field-note">
                          {t('receiptTemplates.limitNote', { count: MAX_ACTIVE_TEMPLATES })}
                        </small>
                      ) : null}
                    </section>
                  );
                })
              : null}
          </section>
        </div>
      )}
      {creating ? (
        <CreateTemplateDialog
          isFull={(type) => activeCount(type) >= MAX_ACTIVE_TEMPLATES}
          onClose={() => setCreating(false)}
          onCreated={async (template) => {
            await refreshReceiptTemplates();
            await navigate({
              to: '/settings/receipt-templates/$templateId',
              params: { templateId: template.id },
            });
          }}
        />
      ) : null}
    </PosPage>
  );
}

function CreateTemplateDialog({
  isFull,
  onClose,
  onCreated,
}: {
  isFull: (type: DocumentType) => boolean;
  onClose: () => void;
  onCreated: (template: ReceiptTemplate) => Promise<void>;
}) {
  const { t } = useTranslation();
  const firstOpen = DOCUMENT_TYPES.find((type) => !isFull(type)) ?? 'sale';
  const [type, setType] = useState<DocumentType>(firstOpen);
  const [paper, setPaper] = useState<PaperSize>('80mm');
  const [name, setName] = useState(() => t(`receiptTemplates.defaultName.${firstOpen}`));
  const [named, setNamed] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const full = isFull(type);
  const blank = name.trim() === '';

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy || full || blank) return;
    setBusy(true);
    setError('');
    try {
      const result = await createReceiptTemplate({ from_default: type, name: name.trim(), paper });
      await onCreated(result.data);
    } catch (failure) {
      setError(templateFailure(failure, t));
      setBusy(false);
    }
  }

  return (
    <AdminDialog
      id="rt-create"
      title={t('receiptTemplates.createTitle')}
      subtitle={t('receiptTemplates.createHint')}
      busy={busy}
      dirty={named}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={submit}>
          <fieldset className="admin-form-fields" disabled={busy}>
            <label>
              {t('receiptTemplates.documentType')}
              <select
                value={type}
                onChange={(event) => {
                  const next = event.target.value as DocumentType;
                  setType(next);
                  if (!named) setName(t(`receiptTemplates.defaultName.${next}`));
                }}
              >
                {DOCUMENT_TYPES.map((option) => (
                  <option key={option} value={option}>
                    {t(`receiptTemplates.type.${option}`)}
                  </option>
                ))}
              </select>
            </label>
            {full ? (
              <p className="error" role="alert">
                {t('receiptTemplates.limitNote', { count: MAX_ACTIVE_TEMPLATES })}
              </p>
            ) : null}
            <PaperPicker value={paper} onChange={setPaper} />
            <label>
              {t('receiptTemplates.name')}
              <input
                value={name}
                maxLength={MAX_NAME_LENGTH}
                required
                onChange={(event) => {
                  setName(event.target.value);
                  setNamed(true);
                }}
              />
            </label>
            <p className="admin-info">{t('receiptTemplates.fromSuggestion')}</p>
          </fieldset>
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          <div className="topology-dialog-actions">
            <button type="button" onClick={close} disabled={busy}>
              {t('adminCancel')}
            </button>
            <button type="submit" className="primary-button" disabled={busy || full || blank}>
              {busy ? t('waiting') : t('receiptTemplates.createSubmit')}
            </button>
          </div>
        </form>
      )}
    </AdminDialog>
  );
}
