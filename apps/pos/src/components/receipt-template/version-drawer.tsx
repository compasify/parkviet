import type { TemplateData } from '@parkviet/pos-shared/receipt-template/data';
import { formatDocumentTime } from '@parkviet/pos-shared/receipt-template/data';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  type ReceiptTemplate,
  useReceiptTemplateVersions,
} from '../../hooks/use-receipt-templates';
import { describeFailure } from '../../lib/request-failure';
import { PosIcon } from '../pos-icon';
import { TemplatePreview } from './template-preview';

// The saved versions of a template, newest first. Each can be previewed with
// the editor's preview data; restoring one saves its config as a new version.
export function VersionDrawer({
  template,
  data,
  timeZone,
  busy,
  onRestore,
  onClose,
}: {
  template: ReceiptTemplate;
  data: TemplateData;
  timeZone: string;
  busy: boolean;
  onRestore: (version: number) => void;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const dialog = useRef<HTMLDialogElement>(null);
  const versions = useReceiptTemplateVersions(template.id, true);
  const [selected, setSelected] = useState<number | null>(null);
  const rows = versions.data?.pages.flatMap((page) => page.data) ?? [];
  const shown = rows.find((row) => row.version === selected) ?? rows[0] ?? null;

  useEffect(() => {
    const element = dialog.current;
    const previous = document.activeElement;
    element?.showModal();
    return () => {
      element?.close();
      if (previous instanceof HTMLElement && previous.isConnected) previous.focus();
    };
  }, []);

  return (
    <dialog
      ref={dialog}
      className="rt-drawer"
      aria-labelledby="rt-versions-title"
      onCancel={(event) => {
        event.preventDefault();
        if (!busy) onClose();
      }}
    >
      <div className="rt-drawer-heading">
        <h2 id="rt-versions-title">
          {t('receiptTemplates.history.title', { name: template.name })}
        </h2>
        <button type="button" aria-label={t('adminClose')} disabled={busy} onClick={onClose}>
          <PosIcon name="close" />
        </button>
      </div>
      {versions.isPending ? <p role="status">{t('waiting')}</p> : null}
      {versions.isError ? (
        <p className="error" role="alert">
          {describeFailure(versions.error, t)}
        </p>
      ) : null}
      <div className="rt-drawer-body">
        <div className="rt-versions-column">
          <ol className="rt-versions" aria-label={t('receiptTemplates.history.list')}>
            {rows.map((row) => {
              const current = row.version === template.current_version;
              const label = t('receiptTemplates.history.version', { version: row.version });
              return (
                <li key={row.version} data-selected={shown?.version === row.version || undefined}>
                  <button
                    type="button"
                    className="rt-version-pick"
                    aria-pressed={shown?.version === row.version}
                    onClick={() => setSelected(row.version)}
                  >
                    <strong>{label}</strong>
                    <small>
                      {formatDocumentTime(row.created_at, timeZone)}
                      {row.created_by ? ` · ${row.created_by.name}` : ''}
                    </small>
                    {current ? (
                      <span className="status-tag">{t('receiptTemplates.history.current')}</span>
                    ) : null}
                  </button>
                  {current ? null : (
                    <button
                      type="button"
                      disabled={busy}
                      aria-label={t('receiptTemplates.history.restoreVersion', {
                        version: row.version,
                      })}
                      onClick={() => onRestore(row.version)}
                    >
                      {t('receiptTemplates.history.restore')}
                    </button>
                  )}
                </li>
              );
            })}
          </ol>
          {versions.hasNextPage ? (
            <button
              type="button"
              className="rt-versions-more"
              disabled={versions.isFetchingNextPage}
              onClick={() => void versions.fetchNextPage()}
            >
              {versions.isFetchingNextPage ? t('waiting') : t('receiptTemplates.history.more')}
            </button>
          ) : null}
        </div>
        {shown ? (
          <section
            className="rt-version-preview"
            aria-label={t('receiptTemplates.history.previewOf', { version: shown.version })}
          >
            <TemplatePreview
              config={shown.config}
              data={data}
              paper={template.paper}
              testId="receipt-template-version-preview"
            />
          </section>
        ) : null}
      </div>
    </dialog>
  );
}
