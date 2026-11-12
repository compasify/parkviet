import { formatMoney } from '@parkviet/pos-shared/money';
import { type PrintPlace, prebillData } from '@parkviet/pos-shared/receipt-template/data';
import { defaultTemplate } from '@parkviet/pos-shared/receipt-template/defaults';
import { renderDocument } from '@parkviet/pos-shared/receipt-template/render';
import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { changeDue, lineAmount } from './offline-sales';
import type { OfflineSnapshot, QueuedSale } from './offline-store';
import type { PosStoreProfile, PosWorkspace } from './pos-context';

type Translate = (key: string, options?: Record<string, unknown>) => string;

// The slip handed over for an offline sale: the pre-bill layout, titled and
// bannered as provisional, numbered OFF-…, with the cash taken. It is not a
// receipt and carries no e-invoice: the server issues those once the sale is
// sent.
export function offlineSlipDocument(
  sale: QueuedSale,
  snapshot: OfflineSnapshot,
  t: Translate,
): PrintDocument {
  const currency = sale.currency;
  const money = (value: string) => formatMoney(value, currency);
  // The pre-bill reads an order; this is the sale as the counter recorded it.
  const workspace = {
    id: sale.offlineId,
    totals: { currency, item_total: sale.total, total: sale.total },
    line_items: sale.lines.map((line, index) => ({
      id: `${sale.offlineId}-${index}`,
      name: line.name,
      quantity: line.quantity,
      unit_price: line.unit_price,
      amount: lineAmount(line),
      note: line.note,
      modifiers: (line.modifier_names ?? []).map((name) => ({ name, quantity: 1 })),
    })),
  } as unknown as PosWorkspace;
  const place: PrintPlace = {
    storeName: snapshot.store.name,
    storeProfile: (snapshot.store.profile ?? null) as PosStoreProfile | null,
    branchName: snapshot.branch.name,
    branchCode: snapshot.branch.code,
    registerName: snapshot.register.name,
  };
  const data = prebillData(
    workspace,
    place,
    t,
    new Date(sale.soldAt),
    snapshot.branch.timezone || 'Asia/Ho_Chi_Minh',
  );
  const change = changeDue(sale.total, sale.handedAmount) ?? '0';
  return renderDocument(defaultTemplate('prebill'), {
    ...data,
    title: t('offlineSlipTitle'),
    number: sale.provisionalNumber,
    banner: t('offlineSlipBanner'),
    cashier: snapshot.staff.name,
    meta: [
      ...data.meta,
      { field: null, label: t('offlineSlipNumber'), value: sale.provisionalNumber },
    ],
    payments: [
      { field: null, label: t('offlineSlipCash'), value: money(sale.handedAmount) },
      { field: null, label: t('offlineSlipChange'), value: money(change), strong: true },
    ],
    notes: [t('offlineSlipNote')],
  });
}
