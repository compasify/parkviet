import type { PosFinancialAttempt, PosWorkspace } from '../pos-context';
import type { ReceiptSnapshot } from '../print-adapter';
import {
  type PrintPlace,
  paymentTicketData,
  prebillData,
  snapshotData,
  type TemplateData,
} from './data';
import type { DocumentType } from './types';

// Made-up documents for the template editor's preview: one per document
// type, printed where the editor says (real store details from the POS
// context, the chosen branch and register). The figures are fixed sample
// values, never a real order.

type Translate = (key: string, options?: Record<string, unknown>) => string;

export type SamplePlace = PrintPlace & { cashier?: string | null; timeZone?: string | null };

// The titles the server prints on posted documents.
const TITLES = {
  sale: 'PHIẾU BÁN HÀNG',
  return: 'PHIẾU TRẢ HÀNG',
  refund: 'PHIẾU HOÀN TIỀN',
  shift_closure: 'PHIẾU ĐÓNG CA',
} as const;

const DISCLAIMER = 'Phiếu bán hàng POS — không phải hóa đơn điện tử';
const SOURCE_TYPES = ['sale', 'return', 'refund', 'shift_closure'] as const;
type SourceType = (typeof SOURCE_TYPES)[number];

const SAMPLE_NUMBERS: Record<SourceType, string> = {
  sale: 'R100245',
  return: 'TH000031',
  refund: 'HT000012',
  shift_closure: 'DC000087',
};

const isSourceType = (type: DocumentType): type is SourceType =>
  (SOURCE_TYPES as readonly string[]).includes(type);

function snapshotDocument(type: SourceType, place: SamplePlace, at: string, t: Translate) {
  const profile = place.storeProfile;
  const base = {
    title: TITLES[type],
    store: {
      name: place.storeName ?? null,
      address: profile?.address ?? null,
      contact_phone: profile?.contact_phone ?? null,
      customer_support_email: profile?.customer_support_email ?? null,
      url: profile?.url ?? null,
      facebook: profile?.facebook ?? null,
      instagram: profile?.instagram ?? null,
    },
    branch: {
      name: place.branchName ?? null,
      code: place.branchCode ?? null,
      return_window_days: place.returnWindowDays ?? null,
    },
    register: place.registerName ?? null,
    timezone: place.timeZone ?? 'Asia/Ho_Chi_Minh',
    at,
    currency: 'VND',
    cashier: place.cashier ?? t('receiptTemplates.sample.cashier'),
    customer: {
      name: t('receiptTemplates.sample.customer'),
      phone: '090***4567',
      address: t('receiptTemplates.sample.address'),
    },
  };
  switch (type) {
    case 'sale':
      return {
        ...base,
        order_number: SAMPLE_NUMBERS.sale,
        lines: [
          {
            name: t('receiptTemplates.sample.itemCoffee'),
            sku: 'CF-250',
            quantity: 2,
            sale_quantity: '2',
            sale_unit: t('receiptTemplates.sample.unitPack'),
            unit_price: '65000.0',
            amount: '130000.0',
            discount: '-10000.0',
            net_amount: '120000.0',
            trace: [{ lot_code: 'L2611', expiry_on: '2027-05-01' }],
          },
          {
            name: t('receiptTemplates.sample.itemMilk'),
            sku: 'SUA-1L',
            quantity: 24,
            sale_quantity: '1',
            sale_unit: t('receiptTemplates.sample.unitCase'),
            conversion: t('receiptTemplates.sample.conversion'),
            unit_price: '480000.0',
            amount: '480000.0',
            net_amount: '480000.0',
          },
        ],
        totals: {
          item_total: '610000.0',
          discount_total: '-10000.0',
          additional_tax_total: '0.0',
          included_tax_total: '44444.0',
          total: '600000.0',
        },
        receipts: [{ method: 'cash', amount: '600000.0', handed: '700000.0', change: '100000.0' }],
        paid_total: '600000.0',
      };
    case 'return':
      return {
        ...base,
        order_number: SAMPLE_NUMBERS.sale,
        return_number: SAMPLE_NUMBERS.return,
        lines: [
          {
            name: t('receiptTemplates.sample.itemCoffee'),
            sku: 'CF-250',
            quantity: '1',
            amount: '60000.0',
            condition: 'resellable',
          },
        ],
        entitlement_posted: true,
        entitlement_total: '60000.0',
        credit_note_amount: '0.0',
        refund_entitlement: '60000.0',
        reason: t('receiptTemplates.sample.reason'),
      };
    case 'refund':
      return {
        ...base,
        order_number: SAMPLE_NUMBERS.sale,
        return_number: SAMPLE_NUMBERS.return,
        method: 'bank',
        amount: '60000.0',
        reference: 'FT26110812345',
      };
    case 'shift_closure':
      return {
        ...base,
        customer: null,
        opened_at: new Date(Date.parse(at) - 8 * 3600 * 1000).toISOString(),
        closer: place.cashier ?? t('receiptTemplates.sample.cashier'),
        opening_float: '1000000.0',
        inflow_total: '5600000.0',
        outflow_total: '200000.0',
        expected: '6400000.0',
        counted: '6400000.0',
        variance: '0.0',
      };
  }
}

// Only the fields the pre-bill and payment ticket read; the rest of an open
// order does not reach a print.
function sampleWorkspace(t: Translate): PosWorkspace {
  return {
    id: 'sample',
    order_id: SAMPLE_NUMBERS.sale,
    customer: {
      name: t('receiptTemplates.sample.customer'),
      address: t('receiptTemplates.sample.address'),
    },
    line_items: [
      {
        name: t('receiptTemplates.sample.itemCoffee'),
        sku: 'CF-250',
        quantity: 2,
        sale_quantity: '2',
        sale_unit: t('receiptTemplates.sample.unitPack'),
        price: '65000.0',
        unit_price: '65000.0',
        amount: '130000.0',
        item_discount: { amount: '-10000.0' },
        item_net_amount: '120000.0',
      },
      {
        name: t('receiptTemplates.sample.itemMilk'),
        sku: 'SUA-1L',
        quantity: 1,
        sale_quantity: '1',
        sale_unit: t('receiptTemplates.sample.unitCase'),
        price: '480000.0',
        unit_price: '480000.0',
        amount: '480000.0',
        item_net_amount: '480000.0',
      },
    ],
    totals: {
      currency: 'VND',
      item_total: '610000.0',
      discount_total: '-10000.0',
      additional_tax_total: '0.0',
      total: '600000.0',
    },
    financial: { allocated: '0.0', remaining: '600000.0' },
  } as unknown as PosWorkspace;
}

const SAMPLE_ATTEMPTS = [
  { kind: 'cash', amount: '600000.0', currency: 'VND' },
] as unknown as PosFinancialAttempt[];

// The sample document of a type, printed at `place` at `now`.
export function sampleData(
  type: DocumentType,
  place: SamplePlace,
  t: Translate,
  now: Date = new Date(),
): TemplateData {
  const zone = place.timeZone || 'Asia/Ho_Chi_Minh';
  if (type === 'prebill') return prebillData(sampleWorkspace(t), place, t, now, zone);
  if (type === 'payment_ticket')
    return paymentTicketData(
      {
        workspace: sampleWorkspace(t),
        attempts: SAMPLE_ATTEMPTS,
        handed: '700000.0',
        change: '100000.0',
        names: { ...place, cashier: place.cashier ?? t('receiptTemplates.sample.cashier') },
      },
      t,
      now,
      zone,
    );
  const source: SourceType = isSourceType(type) ? type : 'sale';
  const receipt = {
    id: 'sample',
    source_type: source,
    number: SAMPLE_NUMBERS[source],
    branch_id: 'sample',
    issued_at: now.toISOString(),
    issued_late: false,
    disclaimer: DISCLAIMER,
    printed: false,
    copy_count: 0,
    document: snapshotDocument(source, place, now.toISOString(), t),
  } satisfies ReceiptSnapshot;
  return withLogo(snapshotData(receipt, t), place);
}

// A posted receipt as the preview shows it. Snapshots keep no logo, so the
// preview shows the store's current one.
export function withLogo(data: TemplateData, place: SamplePlace): TemplateData {
  const logoUrl = place.storeProfile?.logo_url || null;
  return logoUrl ? { ...data, store: { ...data.store, logoUrl } } : data;
}
