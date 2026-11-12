import {
  formatMoney,
  parsePercentageInput,
  parseVndAmount,
  parseVndInput,
} from '@parkviet/pos-shared/money';
import { useId, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { type ApprovalAsk, askFromFailure } from '../lib/approval-requests';
import type { PosLineItem, PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';
import { PosIcon } from './pos-icon';
import { RemoteApprovalButton } from './remote-approval-button';

type Attempt = (approvalId?: string) => Promise<PosWorkspace>;

export function ItemDiscountEditor({
  workspace,
  line,
  currency,
  disabled,
  disabledReason,
  canApplyDiscount,
  onApply,
  onClear,
}: {
  // The order, for asking the manager's phone instead of typing a code.
  workspace?: PosWorkspace;
  line: PosLineItem;
  currency: string;
  disabled: boolean;
  disabledReason?: string;
  canApplyDiscount: boolean;
  onApply: (input: {
    valueType: 'item_flat' | 'item_percent';
    value: string;
    reason: string;
    approvalId?: string;
  }) => Promise<PosWorkspace>;
  onClear: (approvalId?: string) => Promise<PosWorkspace>;
}) {
  const { t } = useTranslation();
  const current = line.item_discount;
  const initialType = current?.value_type ?? 'flat';
  // Server values are canonical ("20000.0"); show them as plain whole VND.
  const initialValue =
    (initialType === 'flat' ? parseVndAmount(current?.value ?? '0') : current?.value) ??
    current?.value ??
    '0';
  const [type, setType] = useState<'flat' | 'percent'>(initialType);
  const [value, setValue] = useState(initialValue);
  const [reason, setReason] = useState(t('itemDiscountReason'));
  const [approvalId, setApprovalId] = useState('');
  const [error, setError] = useState('');
  // A refusal for want of an approval, and the attempt to make again once granted.
  const [remote, setRemote] = useState<{ ask: ApprovalAsk; retry: Attempt } | null>(null);
  const reasonId = useId();
  const reasonRef = useRef<HTMLInputElement>(null);
  const details = useRef<HTMLDetailsElement>(null);
  const parsed = type === 'percent' ? parsePercentageInput(value) : parseVndInput(value);
  const dirty =
    type !== initialType ||
    parsed !==
      (type === 'percent' ? parsePercentageInput(initialValue) : parseVndAmount(initialValue));
  const locked = disabled || !line.sale_line_id;
  const hasDiscount = Boolean(
    current?.amount && current.amount !== '0.0' && current.amount !== '0',
  );

  // Without a code the person may still try where the manager's phone can be
  // asked: the refusal names what to ask for.
  const needsCode = !canApplyDiscount && !approvalId.trim() && !workspace;

  async function run(action: Attempt, granted?: string) {
    setError('');
    try {
      await action(granted ?? (approvalId.trim() || undefined));
      setRemote(null);
      if (details.current) details.current.open = false;
    } catch (failure) {
      const ask = canApplyDiscount ? null : askFromFailure(failure);
      setRemote(ask ? { ask, retry: action } : null);
      setError(describeFailure(failure, t));
    }
  }

  return (
    <div className="basket-cell-inline">
      <span
        className={hasDiscount ? 'item-discount-amount' : undefined}
        title={current?.labels.join(', ')}
      >
        {formatMoney(hasDiscount ? (current?.amount ?? '0') : '0', currency)}
      </span>
      <details className="item-discount-edit" ref={details}>
        <summary
          className="cell-edit-button"
          aria-label={`${t('itemDiscountColumn')}: ${line.name}`}
          title={disabledReason ?? t('itemDiscountColumn')}
        >
          <PosIcon name="edit" />
        </summary>
        <div className="pos-popup-backdrop">
          <form
            className="item-discount-editor pos-popup-card"
            onSubmit={(event) => {
              event.preventDefault();
              if (locked || parsed === null || !dirty || !reason.trim() || needsCode) return;
              void run((approval) =>
                onApply({
                  valueType: type === 'percent' ? 'item_percent' : 'item_flat',
                  value: parsed,
                  reason: reason.trim(),
                  approvalId: approval,
                }),
              );
            }}
          >
            <div className="pos-popup-header">
              <strong>
                {t('itemDiscountColumn')} · {line.name}
              </strong>
              <span className="item-discount-source" title={current?.labels.join(', ')}>
                {t(
                  current?.source === 'promotion'
                    ? 'itemDiscountPromotion'
                    : current?.source === 'manual'
                      ? 'itemDiscountManual'
                      : 'itemDiscountNone',
                )}
              </span>
            </div>
            <div className="item-discount-inputs">
              <input
                aria-label={t('itemDiscountValueName', { name: line.name })}
                inputMode="decimal"
                value={value}
                maxLength={64}
                disabled={locked}
                onChange={(event) => setValue(event.target.value)}
                aria-invalid={parsed === null}
                title={t('itemDiscountHint')}
              />
              <select
                aria-label={t('itemDiscountTypeName', { name: line.name })}
                value={type}
                disabled={locked}
                onChange={(event) => setType(event.target.value as 'flat' | 'percent')}
              >
                <option value="flat">₫</option>
                <option value="percent">%</option>
              </select>
            </div>
            <div className="clearable-field">
              <label htmlFor={reasonId}>{t('discountReason')}</label>
              <div className="clearable-input">
                <input
                  id={reasonId}
                  ref={reasonRef}
                  value={reason}
                  maxLength={200}
                  disabled={locked}
                  onChange={(event) => setReason(event.target.value)}
                />
                {reason && !locked ? (
                  <button
                    type="button"
                    className="input-clear-button"
                    aria-label={t('discountClear')}
                    onClick={() => {
                      setReason('');
                      reasonRef.current?.focus();
                    }}
                  >
                    <PosIcon name="close" />
                  </button>
                ) : null}
              </div>
            </div>
            {!canApplyDiscount ? (
              <label>
                {t('discountApproval')}
                <input
                  value={approvalId}
                  disabled={locked}
                  onChange={(event) => setApprovalId(event.target.value)}
                />
              </label>
            ) : null}
            {workspace && remote ? (
              <RemoteApprovalButton
                branchId={workspace.branch_id}
                subject={{ workspace_id: workspace.id }}
                ask={remote.ask}
                reason={reason}
                disabled={locked}
                onGranted={(id) => {
                  setApprovalId(id);
                  void run(remote.retry, id);
                }}
              />
            ) : null}
            <div className="row">
              <button
                type="submit"
                className="primary-button"
                disabled={locked || !dirty || parsed === null || !reason.trim() || needsCode}
              >
                {t('save')}
              </button>
              {line.line_discount ? (
                <button
                  type="button"
                  className="item-discount-reset"
                  disabled={locked || needsCode}
                  onClick={() => void run((approval) => onClear(approval))}
                >
                  {t('itemDiscountAutomatic')}
                </button>
              ) : null}
              <button
                type="button"
                onClick={() => {
                  if (details.current) details.current.open = false;
                }}
              >
                {t('adminClose')}
              </button>
            </div>
            {error ? (
              <p className="error" role="alert">
                {error}
              </p>
            ) : null}
          </form>
        </div>
      </details>
      {hasDiscount ? (
        <button
          type="button"
          className="cell-edit-button cell-clear-button"
          title={disabledReason ?? t('discountClear')}
          aria-label={`${t('discountClear')} ${line.name}`}
          disabled={locked || needsCode}
          onClick={() =>
            void run((approval) =>
              line.line_discount
                ? onClear(approval)
                : onApply({
                    valueType: 'item_flat',
                    value: '0',
                    reason: reason.trim() || t('itemDiscountReason'),
                    approvalId: approval,
                  }),
            )
          }
        >
          <PosIcon name="close" />
        </button>
      ) : null}
    </div>
  );
}
