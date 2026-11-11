import { formatMoney } from '@parkviet/pos-shared/money';
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSession } from '../hooks/use-session';
import { session } from '../lib/app-session';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import { coverLines, type TablePlacement } from '../lib/table-courses';

export type BuffetTier = {
  id: string;
  name: string;
  duration_minutes: number;
  round_item_limit: number | null;
  items: { product_id: string; product_name?: string; max_per_round: number | null }[];
};

function normalizeTiers(value: unknown): BuffetTier[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((row) => {
    const tier = row as Partial<BuffetTier> | null;
    return tier && typeof tier.id === 'string' && typeof tier.name === 'string'
      ? [
          {
            id: tier.id,
            name: tier.name,
            duration_minutes: Number(tier.duration_minutes) || 0,
            round_item_limit: tier.round_item_limit ?? null,
            items: Array.isArray(tier.items) ? tier.items : [],
          },
        ]
      : [];
  });
}

export function useBuffetTiers(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'buffet-tiers', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    staleTime: 60_000,
    queryFn: async () => {
      const result = await session.request<{ data: unknown }>('GET', '/pos/buffet_tiers', {
        params: { branch_id: branchId ?? undefined },
      });
      return normalizeTiers(result.data);
    },
  });
}

// Buffet tickets of a table: one cover line per guest of a tier, and the
// cover the next free dishes are eaten on.
export function BuffetTierPicker({
  workspace,
  branchId,
  placement,
  onPlacement,
  onAddCover,
  disabled,
}: {
  workspace: PosWorkspace;
  branchId: string | null;
  placement: TablePlacement;
  onPlacement: (next: TablePlacement) => void;
  onAddCover: (tierId: string, guests: number) => Promise<unknown>;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  const tiers = useBuffetTiers(branchId, true);
  const covers = coverLines(workspace);
  const [tierId, setTierId] = useState('');
  const [guests, setGuests] = useState(2);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const rows = tiers.data ?? [];
  if (rows.length === 0 && covers.length === 0) return null;
  const chosen = rows.some((row) => row.id === tierId) ? tierId : (rows[0]?.id ?? '');
  return (
    <section className="buffet-tier-picker" aria-label={t('buffetTitle')}>
      {rows.length > 0 ? (
        <form
          className="row"
          onSubmit={(event) => {
            event.preventDefault();
            if (!chosen) return;
            setBusy(true);
            setMessage('');
            void onAddCover(chosen, guests)
              .catch((error) => {
                const reason = conflictReason(error);
                setMessage(
                  reason
                    ? t(`buffetFailure_${reason}`, { defaultValue: t(posFailureKey(error)) })
                    : t(posFailureKey(error)),
                );
              })
              .finally(() => setBusy(false));
          }}
        >
          <label>
            {t('buffetTier')}
            <select
              value={chosen}
              disabled={disabled}
              onChange={(event) => setTierId(event.target.value)}
            >
              {rows.map((row) => (
                <option key={row.id} value={row.id}>
                  {row.name}
                </option>
              ))}
            </select>
          </label>
          <label>
            {t('buffetGuests')}
            <input
              type="number"
              min={1}
              max={999}
              value={guests}
              disabled={disabled}
              onChange={(event) => setGuests(Math.max(1, Number(event.target.value) || 1))}
            />
          </label>
          <button type="submit" disabled={disabled || busy || !chosen}>
            {busy ? t('waiting') : t('buffetAddCover')}
          </button>
        </form>
      ) : null}
      {covers.length > 0 ? (
        <label>
          {t('buffetCoverFor')}
          <select
            value={placement.buffetCoverLineId ?? ''}
            disabled={disabled}
            onChange={(event) =>
              onPlacement({ ...placement, buffetCoverLineId: event.target.value || null })
            }
          >
            <option value="">{t('buffetCoverNone')}</option>
            {covers.map((line) => (
              <option key={line.sale_line_id} value={line.sale_line_id ?? ''}>
                {`${line.name} × ${line.quantity} · ${formatMoney(line.amount)}`}
              </option>
            ))}
          </select>
        </label>
      ) : null}
      {message ? (
        <p className="workspace-hint" role="status">
          {message}
        </p>
      ) : null}
    </section>
  );
}
