import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { useLatestReceipt } from '../../hooks/use-receipt-templates';
import type { PosBranch, PosContext, PosRegister } from '../../lib/pos-context';
import type { ReceiptSnapshot } from '../../lib/print-adapter';
import { snapshotData, type TemplateData } from '../../lib/receipt-template/data';
import { renderDocument } from '../../lib/receipt-template/render';
import { sampleData, withLogo } from '../../lib/receipt-template/sample-data';
import type { DocumentType, PaperSize, TemplateConfig } from '../../lib/receipt-template/types';
import { PrintSheet } from '../print-sheet';

export type PreviewSource = 'sample' | 'latest';

// Posted documents have receipts to preview with; open-order prints do not.
const RECEIPT_SOURCES: Partial<Record<DocumentType, ReceiptSnapshot['source_type']>> = {
  sale: 'sale',
  return: 'return',
  refund: 'refund',
  shift_closure: 'shift_closure',
};

export type PreviewStatus = 'sample' | 'loading' | 'latest' | 'empty' | 'failed';

// What the preview prints: a sample document at the chosen branch and
// register, or the branch's newest posted receipt of this type. A missing
// or unreadable receipt falls back to the sample.
export function usePreviewData({
  documentType,
  source,
  context,
  branch,
  register,
}: {
  documentType: DocumentType;
  source: PreviewSource;
  context: PosContext | undefined;
  branch: PosBranch | null;
  register: PosRegister | null;
}): { data: TemplateData; status: PreviewStatus } {
  const { t } = useTranslation();
  const sourceType = RECEIPT_SOURCES[documentType] ?? null;
  const wantsLatest = source === 'latest' && sourceType !== null && branch !== null;
  const latest = useLatestReceipt(branch?.id ?? null, sourceType, wantsLatest);
  const place = useMemo(
    () => ({
      storeName: context?.store.name ?? null,
      storeProfile: context?.store.profile ?? null,
      branchName: branch?.name ?? null,
      branchCode: branch?.code ?? null,
      returnWindowDays: branch?.return_window_days ?? null,
      registerName: register?.name ?? null,
      cashier: context?.staff.full_name || context?.staff.email || null,
      timeZone: branch?.timezone ?? context?.store.timezone ?? null,
    }),
    [context, branch, register],
  );
  // The sample's clock is fixed while the editor is open.
  const now = useMemo(() => new Date(), []);
  return useMemo(() => {
    if (wantsLatest && latest.data)
      return { data: withLogo(snapshotData(latest.data, t), place), status: 'latest' };
    const status: PreviewStatus = !wantsLatest
      ? 'sample'
      : latest.isPending
        ? 'loading'
        : latest.isError
          ? 'failed'
          : 'empty';
    return { data: sampleData(documentType, place, t, now), status };
  }, [wantsLatest, latest.data, latest.isPending, latest.isError, documentType, place, t, now]);
}

export function PreviewControls({
  documentType,
  source,
  status,
  branches,
  canReadReceipts,
  registers,
  branchId,
  registerId,
  onSource,
  onBranch,
  onRegister,
}: {
  documentType: DocumentType;
  source: PreviewSource;
  status: PreviewStatus;
  branches: PosBranch[];
  // False when the staff member works at no branch, so no receipt is readable.
  canReadReceipts: boolean;
  registers: PosRegister[];
  branchId: string;
  registerId: string;
  onSource: (source: PreviewSource) => void;
  onBranch: (id: string) => void;
  onRegister: (id: string) => void;
}) {
  const { t } = useTranslation();
  const hasReceipts = RECEIPT_SOURCES[documentType] !== undefined;
  const branchRegisters = registers.filter((register) => register.branch_id === branchId);
  return (
    <div className="rt-preview-controls">
      <label>
        {t('receiptTemplates.preview.source')}
        <select value={source} onChange={(event) => onSource(event.target.value as PreviewSource)}>
          <option value="sample">{t('receiptTemplates.preview.sample')}</option>
          <option value="latest" disabled={!hasReceipts || !canReadReceipts}>
            {t('receiptTemplates.preview.latest')}
          </option>
        </select>
      </label>
      <label>
        {t('branch')}
        <select value={branchId} onChange={(event) => onBranch(event.target.value)}>
          {branches.length === 0 ? (
            <option value="">{t('receiptTemplates.preview.noBranch')}</option>
          ) : null}
          {branches.map((branch) => (
            <option key={branch.id} value={branch.id}>
              {branch.name}
            </option>
          ))}
        </select>
      </label>
      <label>
        {t('receiptTemplates.preview.register')}
        <select
          value={registerId}
          disabled={source === 'latest' && hasReceipts}
          onChange={(event) => onRegister(event.target.value)}
        >
          <option value="">{t('receiptTemplates.preview.noRegister')}</option>
          {branchRegisters.map((register) => (
            <option key={register.id} value={register.id}>
              {register.name}
            </option>
          ))}
        </select>
      </label>
      {!hasReceipts ? (
        <small className="rt-field-note">{t('receiptTemplates.preview.sampleOnly')}</small>
      ) : !canReadReceipts ? (
        <small className="rt-field-note">{t('receiptTemplates.preview.noMembership')}</small>
      ) : source === 'latest' ? (
        <small className="rt-field-note">{t('receiptTemplates.preview.memberBranches')}</small>
      ) : null}
      {status === 'loading' ? <small role="status">{t('waiting')}</small> : null}
      {status === 'empty' ? (
        <small role="status">{t('receiptTemplates.preview.noReceipt')}</small>
      ) : null}
      {status === 'failed' ? (
        <small role="status">{t('receiptTemplates.preview.receiptFailed')}</small>
      ) : null}
    </div>
  );
}

// The document as this template prints it, re-rendered on every change.
export function TemplatePreview({
  config,
  data,
  paper,
  testId = 'receipt-template-preview',
  markOverflow = false,
}: {
  config: TemplateConfig;
  data: TemplateData;
  paper: PaperSize;
  testId?: string;
  // Underline the text a thermal roll would wrap.
  markOverflow?: boolean;
}) {
  const document = useMemo(() => renderDocument(config, data), [config, data]);
  return (
    <div className="receipt-preview rt-preview-sheet">
      <PrintSheet document={document} paper={paper} testId={testId} markOverflow={markOverflow} />
    </div>
  );
}
