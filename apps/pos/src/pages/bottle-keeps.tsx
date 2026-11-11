import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintPortal } from '../components/receipt-sheet';
import {
  BOTTLE_KEEP_MODULE,
  type BottleKeep,
  useBottleKeep,
  useBottleKeepCommands,
  useBottleKeeps,
} from '../hooks/use-bottle-keeps';
import { useMenu } from '../hooks/use-menu';
import { usePrintRoute } from '../hooks/use-print-jobs';
import { writesLocked } from '../lib/pos-context';
import { createBrowserPrintAdapter } from '../lib/print-adapter';
import { deliverDirect } from '../lib/print-adapters';
import { conflictReason, describeFailure } from '../lib/request-failure';

const printer = createBrowserPrintAdapter();
const LABEL_PAPER = '80mm';
// Photos are shrunk by the server's limit; the device never sends more than this.
const PHOTO_MAX_BYTES = 5 * 1024 * 1024;

function level(value: string): number | null {
  if (!/^\d{1,3}$/.test(value.trim())) return null;
  const number = Number(value);
  return number <= 100 ? number : null;
}

function day(iso: string, language: string) {
  if (!iso) return '';
  return new Date(`${iso}T00:00:00`).toLocaleDateString(language);
}

function photoOf(event: { target: HTMLInputElement }) {
  const file = event.target.files?.[0] ?? null;
  return file && file.size <= PHOTO_MAX_BYTES ? file : null;
}

export function BottleKeepsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <BottleKeeps key={scope} />;
}

function BottleKeeps() {
  const { t, i18n } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const capabilities = data?.capabilities ?? [];
  const enabled = data?.modules?.[BOTTLE_KEEP_MODULE] === true;
  const canKeep =
    capabilities.includes('pos.shift.open') || capabilities.includes('pos.table.serve');
  const canApprove = capabilities.includes('pos.approval.grant');
  const locked = writesLocked(data, selection);
  const [query, setQuery] = useState('');
  const [showAll, setShowAll] = useState(false);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const search = useRef<HTMLInputElement>(null);
  const list = useBottleKeeps(branchId, query, showAll ? 'all' : 'kept', enabled);
  const commands = useBottleKeepCommands(branchId);
  const rows = list.data ?? [];

  useEffect(() => {
    search.current?.focus();
  }, []);

  return (
    <PosPage title={t('bottleKeepsTitle')} description={t('bottleKeepsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.fnb_bottle_keep.off')} />
      ) : (
        <div className="bottle-keeps">
          <div className="page-toolbar">
            <label className="tab-list-search">
              {t('bottleKeepsSearch')}
              <input
                ref={search}
                type="search"
                value={query}
                maxLength={60}
                placeholder={t('bottleKeepsSearchPlaceholder')}
                onChange={(event) => setQuery(event.target.value)}
                onKeyDown={(event) => {
                  if (event.key === 'Enter' && rows.length === 1) setSelectedId(rows[0].id);
                }}
              />
            </label>
            <label className="checkbox-field">
              <input
                type="checkbox"
                checked={showAll}
                onChange={(event) => setShowAll(event.target.checked)}
              />
              {t('bottleKeepsShowClosed')}
            </label>
          </div>
          {canKeep ? (
            <KeepForm
              branchId={branchId}
              disabled={locked}
              onKeep={async (draft) => {
                const kept = await commands.create(draft);
                setSelectedId(kept.id);
              }}
            />
          ) : null}
          {list.isError ? <PageState kind="error" title={describeFailure(list.error, t)} /> : null}
          {list.isSuccess && rows.length === 0 ? (
            <PageState
              kind="empty"
              title={query.trim() ? t('bottleKeepsNoMatch') : t('bottleKeepsEmpty')}
            />
          ) : null}
          {rows.length > 0 ? (
            <table className="tab-list-table" aria-label={t('bottleKeepsList')}>
              <thead>
                <tr>
                  <th scope="col">{t('bottleKeepCode')}</th>
                  <th scope="col">{t('bottleKeepBottle')}</th>
                  <th scope="col">{t('bottleKeepGuest')}</th>
                  <th scope="col" className="numeric">
                    {t('bottleKeepLevel')}
                  </th>
                  <th scope="col">{t('bottleKeepExpires')}</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} aria-selected={row.id === selectedId}>
                    <td>
                      <button
                        type="button"
                        className="link-button"
                        onClick={() => setSelectedId(row.id)}
                      >
                        {row.code}
                      </button>
                    </td>
                    <td>{row.productName}</td>
                    <td>
                      {row.guestName ?? '—'}
                      {row.phone ? <small className="muted"> · {row.phone}</small> : null}
                    </td>
                    <td className="numeric">{row.levelPercent}%</td>
                    <td>
                      {row.status === 'kept'
                        ? day(row.expiresOn, i18n.language)
                        : t(`bottleKeepStatus_${row.status}`)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : null}
          {selectedId ? (
            <BottleDetail
              key={selectedId}
              id={selectedId}
              branchId={branchId}
              registerId={selection.registerId}
              disabled={locked || !canKeep}
              canApprove={canApprove}
              commands={commands}
              onClose={() => setSelectedId(null)}
            />
          ) : null}
        </div>
      )}
    </PosPage>
  );
}

function KeepForm({
  branchId,
  disabled,
  onKeep,
}: {
  branchId: string;
  disabled: boolean;
  onKeep: (draft: {
    variantId: string;
    levelPercent: number;
    guestName: string;
    phone: string;
    note: string;
    photo: File | null;
  }) => Promise<void>;
}) {
  const { t } = useTranslation();
  const menu = useMenu(branchId, true);
  const variants = (menu.data?.items ?? []).flatMap((item) =>
    item.variants.map((variant) => ({
      id: variant.id,
      label: item.variants.length > 1 ? `${item.name} · ${variant.name}` : item.name,
    })),
  );
  const [variantId, setVariantId] = useState('');
  const [levelInput, setLevelInput] = useState('100');
  const [guestName, setGuestName] = useState('');
  const [phone, setPhone] = useState('');
  const [note, setNote] = useState('');
  const [photo, setPhoto] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const levelPercent = level(levelInput);
  const ready =
    variantId !== '' && levelPercent !== null && (guestName.trim() !== '' || phone.trim() !== '');

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (!ready || levelPercent === null || disabled) return;
    setBusy(true);
    setMessage('');
    try {
      await onKeep({ variantId, levelPercent, guestName, phone, note, photo });
      setGuestName('');
      setPhone('');
      setNote('');
      setPhoto(null);
    } catch (failure) {
      setMessage(describeFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  return (
    <details className="bottle-keep-new">
      <summary>{t('bottleKeepNew')}</summary>
      <form className="reservation-form" onSubmit={(event) => void submit(event)}>
        <label>
          {t('bottleKeepBottle')}
          <select
            value={variantId}
            disabled={disabled || busy}
            onChange={(event) => setVariantId(event.target.value)}
            required
          >
            <option value="">{t('bottleKeepPickBottle')}</option>
            {variants.map((variant) => (
              <option key={variant.id} value={variant.id}>
                {variant.label}
              </option>
            ))}
          </select>
        </label>
        <label>
          {t('bottleKeepLevel')}
          <input
            inputMode="numeric"
            value={levelInput}
            aria-invalid={levelPercent === null}
            disabled={disabled || busy}
            onChange={(event) => setLevelInput(event.target.value)}
          />
        </label>
        <label>
          {t('bottleKeepGuest')}
          <input
            value={guestName}
            maxLength={120}
            disabled={disabled || busy}
            onChange={(event) => setGuestName(event.target.value)}
          />
        </label>
        <label>
          {t('bottleKeepPhone')}
          <input
            type="tel"
            value={phone}
            maxLength={20}
            disabled={disabled || busy}
            onChange={(event) => setPhone(event.target.value)}
          />
        </label>
        <label>
          {t('bottleKeepNote')}
          <input
            value={note}
            maxLength={200}
            disabled={disabled || busy}
            onChange={(event) => setNote(event.target.value)}
          />
        </label>
        <label>
          {t('bottleKeepPhoto')}
          <input
            type="file"
            accept="image/*"
            capture="environment"
            disabled={disabled || busy}
            onChange={(event) => setPhoto(photoOf(event))}
          />
        </label>
        <button type="submit" className="primary-button" disabled={disabled || busy || !ready}>
          {t('bottleKeepSave')}
        </button>
        {message ? (
          <p className="error" role="alert">
            {message}
          </p>
        ) : null}
      </form>
    </details>
  );
}

function BottleDetail({
  id,
  branchId,
  registerId,
  disabled,
  canApprove,
  commands,
  onClose,
}: {
  id: string;
  branchId: string;
  registerId: string | null;
  disabled: boolean;
  canApprove: boolean;
  commands: ReturnType<typeof useBottleKeepCommands>;
  onClose: () => void;
}) {
  const { t, i18n } = useTranslation();
  const query = useBottleKeep(id);
  const bottle = query.data ?? null;
  const route = usePrintRoute(branchId, registerId, 'receipt').route;
  const [levelInput, setLevelInput] = useState('');
  const [mlInput, setMlInput] = useState('');
  const [note, setNote] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [photo, setPhoto] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [notice, setNotice] = useState('');
  const [label, setLabel] = useState<PrintDocument | null>(null);
  const nextLevel = level(levelInput);
  const ml = mlInput.trim() === '' ? undefined : Number(mlInput);
  const mlValid = ml === undefined || (Number.isInteger(ml) && ml > 0);
  const open = bottle?.status === 'kept';

  // A browser-printed label prints once its sheet is on the page.
  useEffect(() => {
    if (!label) return;
    void printer.deliver(LABEL_PAPER).then((outcome) => {
      if (!outcome.ok) setMessage(t('bottleKeepLabelFailed'));
      setLabel(null);
    });
  }, [label, t]);

  async function run(action: () => Promise<unknown>, done?: string) {
    setBusy(true);
    setMessage('');
    setNotice('');
    try {
      await action();
      setLevelInput('');
      setMlInput('');
      setNote('');
      setApprovalId('');
      setPhoto(null);
      if (done) setNotice(done);
      await query.refetch();
    } catch (failure) {
      const reason = conflictReason(failure);
      setMessage(
        reason === 'bottle_level_raised'
          ? t('bottleKeepLevelRaised')
          : reason === 'approval_required'
            ? t('bottleKeepApprovalRequired')
            : describeFailure(failure, t),
      );
    } finally {
      setBusy(false);
    }
  }

  async function printLabel(keep: BottleKeep) {
    if (route.kind === 'queue') {
      await commands.label(keep.id, route.printer.id);
      setNotice(t('printQueuedNotice', { printer: route.printer.name }));
      return;
    }
    const { document } = await commands.label(keep.id);
    if (route.kind === 'direct') {
      const outcome = await deliverDirect(route.printer, document);
      if (outcome.ok) return;
      setMessage(t(`printOutcome_${outcome.reason}`, { printer: route.printer.name }));
    }
    setLabel(document);
  }

  if (query.isLoading) return <PageState kind="loading" title={t('waiting')} />;
  if (!bottle) return <PageState kind="error" title={describeFailure(query.error, t)} />;
  return (
    <section
      className="bottle-keep-detail"
      aria-label={t('bottleKeepDetail', { code: bottle.code })}
    >
      <div className="pos-popup-header">
        <h3>
          {bottle.code} · {bottle.productName}
        </h3>
        <button type="button" onClick={onClose}>
          {t('adminClose')}
        </button>
      </div>
      <div className="bottle-keep-summary">
        {bottle.photoUrl ? (
          <img src={bottle.photoUrl} alt={t('bottleKeepPhotoOf', { code: bottle.code })} />
        ) : null}
        <dl>
          <dt>{t('bottleKeepGuest')}</dt>
          <dd>
            {bottle.guestName ?? '—'}
            {bottle.phone ? ` · ${bottle.phone}` : ''}
          </dd>
          <dt>{t('bottleKeepLevel')}</dt>
          <dd>
            <meter min={0} max={100} value={bottle.levelPercent} /> {bottle.levelPercent}%
          </dd>
          <dt>{t('bottleKeepKept')}</dt>
          <dd>
            {day(bottle.keptOn, i18n.language)} → {day(bottle.expiresOn, i18n.language)}
          </dd>
          <dt>{t('bottleKeepState')}</dt>
          <dd>{t(`bottleKeepStatus_${bottle.status}`)}</dd>
          {bottle.note ? (
            <>
              <dt>{t('bottleKeepNote')}</dt>
              <dd>{bottle.note}</dd>
            </>
          ) : null}
        </dl>
      </div>
      {open ? (
        <form
          className="reservation-form"
          aria-label={t('bottleKeepPour')}
          onSubmit={(event) => {
            event.preventDefault();
            if (nextLevel === null || !mlValid) return;
            void run(() => commands.pour(bottle.id, { levelPercent: nextLevel, ml, note, photo }));
          }}
        >
          <label>
            {t('bottleKeepNewLevel')}
            <input
              inputMode="numeric"
              value={levelInput}
              placeholder={String(bottle.levelPercent)}
              disabled={disabled || busy}
              aria-invalid={levelInput !== '' && nextLevel === null}
              onChange={(event) => setLevelInput(event.target.value)}
            />
          </label>
          <label>
            {t('bottleKeepMl')}
            <input
              inputMode="numeric"
              value={mlInput}
              disabled={disabled || busy}
              aria-invalid={!mlValid}
              onChange={(event) => setMlInput(event.target.value)}
            />
          </label>
          <label>
            {t('bottleKeepNote')}
            <input
              value={note}
              maxLength={200}
              disabled={disabled || busy}
              onChange={(event) => setNote(event.target.value)}
            />
          </label>
          <label>
            {t('bottleKeepPhoto')}
            <input
              type="file"
              accept="image/*"
              capture="environment"
              disabled={disabled || busy}
              onChange={(event) => setPhoto(photoOf(event))}
            />
          </label>
          {!canApprove ? (
            <label>
              {t('discountApproval')}
              <input
                value={approvalId}
                maxLength={64}
                disabled={disabled || busy}
                onChange={(event) => setApprovalId(event.target.value)}
              />
            </label>
          ) : null}
          <div className="row">
            <button
              type="submit"
              className="primary-button"
              disabled={disabled || busy || nextLevel === null || !mlValid}
            >
              {t('bottleKeepPour')}
            </button>
            <button
              type="button"
              disabled={
                disabled ||
                busy ||
                nextLevel === null ||
                !note.trim() ||
                (!canApprove && !approvalId.trim())
              }
              title={t('bottleKeepAdjustHint')}
              onClick={() =>
                nextLevel !== null &&
                void run(() =>
                  commands.adjust(bottle, {
                    levelPercent: nextLevel,
                    note,
                    approvalId: approvalId.trim() || undefined,
                  }),
                )
              }
            >
              {t('bottleKeepAdjust')}
            </button>
            <button
              type="button"
              disabled={disabled || busy}
              onClick={() => void run(() => commands.giveBack(bottle.id, note))}
            >
              {t('bottleKeepReturn')}
            </button>
          </div>
        </form>
      ) : null}
      <div className="row">
        <button
          type="button"
          disabled={busy}
          onClick={() => void run(() => printLabel(bottle), undefined)}
        >
          {t('bottleKeepPrintLabel')}
        </button>
      </div>
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {notice ? <p role="status">{notice}</p> : null}
      <h4>{t('bottleKeepHistory')}</h4>
      <ol className="record-list bottle-keep-history">
        {bottle.events.map((event) => (
          <li key={event.id}>
            <strong>{t(`bottleKeepEvent_${event.kind}`)}</strong>{' '}
            {event.levelBefore !== null ? `${event.levelBefore}% → ` : ''}
            {event.levelAfter !== null ? `${event.levelAfter}%` : ''}
            {event.ml ? ` · ${event.ml} ml` : ''}
            <small className="muted">
              {' '}
              · {new Date(event.createdAt).toLocaleString(i18n.language)}
              {event.actor ? ` · ${event.actor}` : ''}
              {event.approvalId ? ` · ${t('bottleKeepApproved')}` : ''}
            </small>
            {event.note ? <div className="muted">{event.note}</div> : null}
          </li>
        ))}
      </ol>
      {label ? <ReceiptPrintPortal document={label} paper={LABEL_PAPER} /> : null}
    </section>
  );
}
