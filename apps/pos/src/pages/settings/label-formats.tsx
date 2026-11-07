import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { LabelFormatEditor } from '../../components/label-format-editor';
import { PosIcon } from '../../components/pos-icon';
import { PageState } from '../../components/pos-page';
import { disableLabelFormat, useLabelFormats } from '../../hooks/use-branch-catalog';
import type { LabelFormat } from '../../lib/label-format';
import { queryClient } from '../../lib/query-client';
import { describeFailure, posFailureKey } from '../../lib/request-failure';
import { BranchSettingsFrame, type BranchSettingsScope } from './branch-settings';

export function LabelFormatsPage() {
  return (
    <BranchSettingsFrame section="labels">
      {(scope) => <LabelFormats key={scope.branch.id} {...scope} />}
    </BranchSettingsFrame>
  );
}

function LabelFormats({ branch, access }: BranchSettingsScope) {
  const { t } = useTranslation();
  const formats = useLabelFormats(branch.id, access.read);
  const [editor, setEditor] = useState<{ format?: LabelFormat } | null>(null);
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  const rows = formats.data ?? [];

  const refresh = () => queryClient.invalidateQueries({ queryKey: ['pos', 'label-formats'] });

  async function disable(format: LabelFormat) {
    if (
      !access.write ||
      pendingId ||
      !window.confirm(t('labelFormatConfirmDisable', { name: format.name }))
    )
      return;
    setPendingId(format.id);
    setNotice(null);
    try {
      await disableLabelFormat(branch.id, format.id);
      setNotice({ text: t('labelFormatDisabled', { name: format.name }), failed: false });
    } catch (error) {
      setNotice({ text: describeFailure(error, t), failed: true });
    } finally {
      setPendingId(null);
      await refresh();
    }
  }

  return (
    <section className="page-card admin-content" aria-labelledby="label-formats-heading">
      <div className="section-heading">
        <div>
          <h2 id="label-formats-heading">{t('labelFormatsTitle')}</h2>
          <p>{t('labelFormatsHint')}</p>
        </div>
        {access.write ? (
          <button
            type="button"
            className="primary-button"
            disabled={Boolean(pendingId)}
            onClick={() => {
              setNotice(null);
              setEditor({});
            }}
          >
            <PosIcon name="plus" />
            {t('labelFormatCreate')}
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
      {formats.isPending ? <PageState kind="loading" title={t('waiting')} /> : null}
      {formats.isError ? (
        <PageState kind="error" title={t(posFailureKey(formats.error))}>
          <p>{describeFailure(formats.error, t)}</p>
          <button type="button" onClick={() => void formats.refetch()}>
            {t('retry')}
          </button>
        </PageState>
      ) : null}
      {formats.isSuccess && rows.length === 0 ? (
        <PageState title={t('labelFormatsEmpty')}>
          <p>{t('labelFormatsEmptyHint')}</p>
        </PageState>
      ) : null}
      <ul className="admin-records" aria-label={t('labelFormatList')}>
        {rows.map((format) => {
          const active = format.status === 'active';
          return (
            <li key={format.id}>
              <div className="admin-record-copy">
                <strong>{format.name}</strong>
                <small>
                  {t('labelFormatSummary', {
                    prefix: format.prefix,
                    item: format.item_code_length,
                    value: format.value_length,
                  })}
                </small>
                <small>
                  {t(`labelFormatKind_${format.kind}`)}
                  {format.kind === 'weight' && format.value_unit_code
                    ? ` · ${format.value_unit_code}`
                    : ` · ${t('labelFormatToleranceShort', { tolerance: format.price_tolerance })}`}
                  {` · ${t('labelFormatDecimalsShort', { decimals: format.value_decimals })}`}
                  {` · ${t('labelFormatVersion', { version: format.version })}`}
                </small>
              </div>
              <span className="status-tag" data-warning={!active}>
                {t(active ? 'statusActive' : 'statusDisabled')}
              </span>
              {access.write && active ? (
                <div className="admin-record-actions">
                  <button
                    type="button"
                    disabled={Boolean(pendingId)}
                    aria-label={t('adminEditName', { name: format.name })}
                    onClick={() => {
                      setNotice(null);
                      setEditor({ format });
                    }}
                  >
                    {t('adminEdit')}
                  </button>
                  <button
                    type="button"
                    className="danger-button"
                    disabled={Boolean(pendingId)}
                    aria-label={t('labelFormatDisableFor', { name: format.name })}
                    onClick={() => void disable(format)}
                  >
                    {pendingId === format.id ? t('waiting') : t('adminDisable')}
                  </button>
                </div>
              ) : null}
            </li>
          );
        })}
      </ul>
      {editor ? (
        <LabelFormatEditor
          branchId={branch.id}
          format={editor.format}
          onSaved={async (saved) => {
            setNotice({ text: t('labelFormatSaved', { name: saved.name }), failed: false });
            await refresh();
          }}
          onClose={() => setEditor(null)}
        />
      ) : null}
    </section>
  );
}
