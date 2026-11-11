import type { PrintJob } from '@parkviet/pos-shared/types/print-adapter';
import { Link } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useGrantPrebillReprint,
  usePrintedPrebills,
  usePrintJobAction,
  usePrintJobs,
} from '../hooks/use-print-jobs';
import { abandonIfNeeded } from '../hooks/use-tenders';
import { stuckPrintJob } from '../lib/print-adapters';
import { printRefusal } from '../lib/print-queue-messages';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { usePosSelection } from './pos-selection';

const CANCELABLE: readonly PrintJob['status'][] = ['queued', 'failed'];

// The branch's print queue at the counter: what waits, what failed, and what a
// cashier can do about it. A pre-bill's reprint needs a manager's approval: a
// signed-in manager grants it here, and it then shows for the person working
// the order, who spends it with one press.
export function PrintQueuePanel() {
  const { t } = useTranslation();
  const { selection } = usePosSelection();
  const jobs = usePrintJobs(selection.branchId);
  const prebills = usePrintedPrebills(selection.branchId);
  const action = usePrintJobAction();
  const grant = useGrantPrebillReprint();
  const [error, setError] = useState('');
  const busy = action.isPending || grant.isPending;

  const messageFor = (failure: unknown) => {
    abandonIfNeeded(failure);
    const reason = conflictReason(failure);
    return (
      printRefusal(failure, t) ??
      (reason === 'approval_required'
        ? t('printQueueApprovalRequired')
        : reason === 'print_job_not_cancelable'
          ? t('printQueueNotCancelable')
          : describeFailure(failure, t))
    );
  };

  const run = async (job: PrintJob, kind: 'reprint' | 'cancel') => {
    setError('');
    try {
      await action.mutateAsync({
        job,
        action: kind,
        approvalId: job.reprint?.approval_id ?? undefined,
      });
    } catch (failure) {
      setError(messageFor(failure));
    }
  };

  const approve = async (job: PrintJob) => {
    setError('');
    try {
      await grant.mutateAsync(job);
    } catch (failure) {
      setError(messageFor(failure));
    }
  };

  // A pre-bill can only be reprinted with an approval the reader holds. Without
  // an open order there is nothing to approve, and the server would refuse.
  const reprintControls = (job: PrintJob) => {
    if (job.kind !== 'prebill')
      return (
        <button type="button" disabled={busy} onClick={() => void run(job, 'reprint')}>
          {t('printQueueReprint')}
        </button>
      );
    if (!job.reprint) return null;
    if (job.reprint.approval_id)
      return (
        <button type="button" disabled={busy} onClick={() => void run(job, 'reprint')}>
          {t('printQueueReprint')}
        </button>
      );
    return (
      <>
        <span className="status-tag" data-testid="prebill-needs-approval">
          {t('printQueueNeedsApproval')}
        </span>
        {job.reprint.can_approve ? (
          <button type="button" disabled={busy} onClick={() => void approve(job)}>
            {t('printQueueApprove')}
          </button>
        ) : null}
      </>
    );
  };

  const open = jobs.data ?? [];
  const printed = prebills.data ?? [];
  if (open.length === 0 && printed.length === 0) return null;
  return (
    <section className="print-queue" aria-label={t('printQueueTitle')}>
      <h3>{t('printQueueTitle')}</h3>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {open.length > 0 ? (
        <ul className="record-list">
          {open.map((job) => (
            <li key={job.id} data-testid="print-job">
              <span className="record-copy">
                <strong>{job.label ?? t(`printJobKind_${job.kind}`)}</strong>
                <small>
                  {job.printer_name} · {t('printQueueAttempts', { count: job.attempts })}
                </small>
                {job.last_error ? <small>{job.last_error}</small> : null}
                {stuckPrintJob(job) ? <small>{t('printQueuePrinterUnavailable')}</small> : null}
                <span className="status-tag" data-danger={job.status === 'failed'}>
                  {t(`printJobStatus_${job.status}`)}
                </span>
              </span>
              {/* A job still in line is about to print; reprinting it would print twice. */}
              {job.status === 'failed' ? reprintControls(job) : null}
              {CANCELABLE.includes(job.status) ? (
                <button type="button" disabled={busy} onClick={() => void run(job, 'cancel')}>
                  {t('printQueueCancel')}
                </button>
              ) : null}
            </li>
          ))}
        </ul>
      ) : null}
      {printed.length > 0 ? (
        <>
          <h4>{t('printQueuePrintedPrebills')}</h4>
          <ul className="record-list">
            {printed.map((job) => (
              <li key={job.id} data-testid="printed-prebill">
                <span className="record-copy">
                  <strong>{job.label ?? t('printJobKind_prebill')}</strong>
                  <small>{job.printer_name}</small>
                </span>
                {reprintControls(job)}
              </li>
            ))}
          </ul>
        </>
      ) : null}
    </section>
  );
}

// Says so on the sale screen when a job failed or is stuck, wherever the
// cashier is working.
export function PrintQueueAlert() {
  const { t } = useTranslation();
  const { selection } = usePosSelection();
  const jobs = usePrintJobs(selection.branchId);
  const failed = jobs.data?.filter((job) => job.status === 'failed').length ?? 0;
  const stuck = jobs.data?.filter(stuckPrintJob).length ?? 0;
  if (failed === 0 && stuck === 0) return null;
  return (
    <div className="pos-floating-alerts" style={{ left: 'auto', right: 'var(--pos-s3)' }}>
      <p role="alert" data-testid="print-queue-alert">
        {failed > 0 ? `${t('printQueueFailedAlert', { count: failed })} ` : null}
        {stuck > 0 ? `${t('printQueueStuckAlert', { count: stuck })} ` : null}
        <Link to="/receipts">{t('printQueueOpen')}</Link>
      </p>
    </div>
  );
}
