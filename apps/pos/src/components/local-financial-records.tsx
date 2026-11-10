import { formatMoney, parseVndAmount } from '@parkviet/pos-shared/money';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  FINANCIAL_RECOVERY_CHANGED,
  type FinancialRecoveryRecord,
  forgetFinancialRecord,
  scopedFinancialRecords,
} from '../lib/financial-recovery';

function actionOf(record: FinancialRecoveryRecord): string {
  try {
    const parts: unknown = JSON.parse(record.scope);
    return Array.isArray(parts) && typeof parts[3] === 'string' ? parts[3] : '';
  } catch {
    return '';
  }
}

function amountOf(record: FinancialRecoveryRecord): string | null {
  for (const field of ['amount', 'handed_amount', 'received_amount']) {
    const value = record.body[field];
    if (typeof value === 'string' && parseVndAmount(value) !== null) return value;
  }
  return null;
}

// Money commands this browser sent without learning the outcome. After the
// cashier or manager reconciled one by hand, they can clear it here.
export function LocalFinancialRecords({ staffId, storeId }: { staffId: string; storeId: string }) {
  const { t, i18n } = useTranslation();
  const [records, setRecords] = useState<FinancialRecoveryRecord[] | null>(null);
  const [unavailable, setUnavailable] = useState(false);
  const [confirming, setConfirming] = useState<string | null>(null);
  const [error, setError] = useState('');
  const [version, setVersion] = useState(0);

  useEffect(() => {
    const changed = () => setVersion((value) => value + 1);
    window.addEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
    return () => window.removeEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
  }, []);

  useEffect(() => {
    void version;
    let active = true;
    scopedFinancialRecords(staffId, storeId).then(
      (value) => {
        if (!active) return;
        setRecords(value);
        setUnavailable(false);
      },
      () => {
        if (!active) return;
        setRecords(null);
        setUnavailable(true);
      },
    );
    return () => {
      active = false;
    };
  }, [staffId, storeId, version]);

  async function discard(scope: string) {
    setError('');
    try {
      await forgetFinancialRecord(scope);
      setConfirming(null);
    } catch {
      setError(t('financialStorageUnavailable'));
    }
  }

  if (unavailable) {
    return (
      <p className="error" role="status">
        {t('financialStorageWarning')}
      </p>
    );
  }
  if (!records?.length) return null;

  return (
    <section className="page-card local-financial-records" aria-label={t('localRecordsTitle')}>
      <h2>{t('localRecordsTitle')}</h2>
      <p className="muted">{t('localRecordsHint')}</p>
      <ul className="record-list">
        {records.map((record) => {
          const amount = amountOf(record);
          const action = actionOf(record);
          return (
            <li key={record.scope}>
              <span className="record-copy">
                <strong>
                  {t(`financialAction_${action.replaceAll('.', '_')}`, { defaultValue: action })}
                </strong>
                <small>
                  {new Date(record.savedAt).toLocaleString(i18n.language, {
                    timeZone: 'Asia/Ho_Chi_Minh',
                  })}{' '}
                  · {record.path}
                </small>
                {amount ? <span>{formatMoney(amount)}</span> : null}
              </span>
              {confirming === record.scope ? (
                <fieldset className="row local-record-confirm">
                  <legend>{t('localRecordConfirm')}</legend>
                  <button type="button" onClick={() => void discard(record.scope)}>
                    {t('localRecordConfirmYes')}
                  </button>
                  <button type="button" onClick={() => setConfirming(null)}>
                    {t('paymentCancelNo')}
                  </button>
                </fieldset>
              ) : (
                <button type="button" onClick={() => setConfirming(record.scope)}>
                  {t('localRecordReconciled')}
                </button>
              )}
            </li>
          );
        })}
      </ul>
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
