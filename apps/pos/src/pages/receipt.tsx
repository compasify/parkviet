import { useQuery } from '@tanstack/react-query';
import { useSearch } from '@tanstack/react-router';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { PrintQueuePanel } from '../components/print-queue-panel';
import { ReceiptPrintPanel } from '../components/receipt-print-panel';
import { useSession } from '../hooks/use-session';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { session } from '../lib/app-session';
import { formatDocumentTime, type ReceiptSnapshot } from '../lib/print-adapter';
import { conflictReason, describeFailure } from '../lib/request-failure';

async function read<T>(path: string, params?: Record<string, string | undefined>) {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// A new search (or the menu link without one) starts from a clean page.
export function ReceiptPage() {
  const search = useSearch({ from: '/authed/receipts' });
  return <Receipts key={`${search.source ?? ''}:${search.receiptId ?? ''}`} />;
}

// Receipts of posted documents: look one up by its source or by number,
// preview it on a roll (58/80mm) or a sheet (A4/A5/A6), and print. Printing
// itself (original vs. "BẢN SAO") lives in ReceiptPrintPanel.
function Receipts() {
  const { t } = useTranslation();
  const search = useSearch({ from: '/authed/receipts' });
  const { context, selection } = usePosSelection();
  const snapshot = useSession();
  const [selectedId, setSelectedId] = useState<string | null>(search.receiptId ?? null);
  const [number, setNumber] = useState('');
  const [submitted, setSubmitted] = useState('');
  const [busy, setBusy] = useState(false);
  const authed = snapshot.status === 'authenticated';
  const branch = context.data?.branches.find((row) => row.id === selection.branchId);
  const zone = branch?.timezone ?? context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh';

  const bySource = useQuery({
    queryKey: ['pos', 'receipt-source', snapshot.generation, search.source ?? null],
    enabled: authed && Boolean(search.source) && !selectedId,
    retry: false,
    queryFn: async () =>
      (await read<{ data: ReceiptSnapshot }>('/pos/receipts/lookup', { source_id: search.source }))
        .data,
  });
  const byId = useQuery({
    queryKey: ['pos', 'receipt', snapshot.generation, selectedId],
    enabled: authed && Boolean(selectedId),
    retry: false,
    queryFn: async () =>
      (await read<{ data: ReceiptSnapshot }>(`/pos/receipts/${selectedId}`)).data,
  });
  const results = useQuery({
    queryKey: ['pos', 'receipts', snapshot.generation, selection.branchId, submitted],
    enabled: authed && Boolean(selection.branchId) && submitted !== '',
    queryFn: async () =>
      (
        await read<{ data: ReceiptSnapshot[] }>('/pos/receipts', {
          branch_id: selection.branchId ?? undefined,
          number: submitted,
        })
      ).data,
  });
  const receipt = (selectedId ? byId.data : bySource.data) ?? null;
  const loadError = selectedId ? byId.error : bySource.error;

  const submit = (event: FormEvent) => {
    event.preventDefault();
    setSubmitted(number.trim());
  };

  return (
    <PosPage title={t('receiptsTitle')} description={t('receiptsDescription')}>
      <form className="row receipt-search" onSubmit={submit}>
        <label>
          {t('receiptsSearchNumber')}
          <input
            value={number}
            onChange={(event) => setNumber(event.target.value)}
            maxLength={64}
          />
        </label>
        <button type="submit" disabled={!selection.branchId}>
          {t('receiptsSearch')}
        </button>
      </form>
      {results.data ? (
        results.data.length === 0 ? (
          <p className="muted">{t('receiptsNone')}</p>
        ) : (
          <ul className="record-list" aria-label={t('receiptsResults')}>
            {results.data.map((row) => (
              <li key={row.id}>
                <button type="button" disabled={busy} onClick={() => setSelectedId(row.id)}>
                  {row.number} · {t(`receiptType_${row.source_type}`)} ·{' '}
                  {formatDocumentTime(row.issued_at, zone)}
                </button>
              </li>
            ))}
          </ul>
        )
      ) : null}
      {loadError ? (
        <p className="error" role="alert">
          {conflictReason(loadError) === 'receipt_unavailable'
            ? t('receiptUnavailable')
            : describeFailure(loadError, t)}
        </p>
      ) : null}
      {receipt ? (
        <ReceiptPrintPanel
          key={receipt.id}
          receipt={receipt}
          onBusyChange={setBusy}
          refreshing={(selectedId ? byId : bySource).isFetching}
        />
      ) : null}
      <PrintQueuePanel />
    </PosPage>
  );
}
