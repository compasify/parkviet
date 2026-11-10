import { formatMoney } from '@parkviet/pos-shared/money';
import type { PayLaterQr } from './pay-later';
import type { PosReceivableAccount } from './pos-context';
import { STORE_TIMEZONE } from './receivables';

// "Nhắc nợ": a polite message to a customer who owes, listing the open
// orders (oldest due first) and one pay-later VietQR for the whole balance.
// That QR carries the oldest order's `TN<number>` note; the server books a
// transfer with it against that order first, then the customer's other
// debts oldest due first, so one transfer settles the list in order.

type Translate = (key: string, options?: Record<string, unknown>) => string;

// Staff who see contacts unmasked may send reminders (as the server checks).
const SENDERS = ['pos.payment.collect', 'pos.approval.grant', 'pos.credit.manage'];

export function canRemindDebt(capabilities: readonly string[] | undefined): boolean {
  return Boolean(capabilities?.some((capability) => SENDERS.includes(capability)));
}

const fold = (value: string) =>
  value.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/gi, 'd').toLowerCase();

// Search of the customers list by name (accents optional) or phone digits.
// Only what the reader sees is searched: a masked phone shows its last digits.
export function matchesDebtor(account: PosReceivableAccount, query: string): boolean {
  const term = query.trim();
  if (!term) return true;
  if (fold(account.customer.name).includes(fold(term))) return true;
  const digits = term.replace(/\D/g, '');
  return digits.length > 0 && (account.customer.phone ?? '').replace(/\D/g, '').includes(digits);
}

// "2026-11-07T03:00:00Z" as 07/11 in the store's timezone.
export function shortDate(value: string | null | undefined): string {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return date.toLocaleDateString('en-GB', {
    timeZone: STORE_TIMEZONE,
    day: '2-digit',
    month: '2-digit',
  });
}

export function debtReminderMessage(
  account: PosReceivableAccount,
  qr: PayLaterQr | null,
  t: Translate,
  storeName?: string | null,
): string {
  const currency = account.currency;
  const listed = account.open_orders ?? [];
  const hidden = account.orders - listed.length;
  const lines: Array<string | null> = [
    storeName
      ? t('debtReminderGreetingStore', { name: account.customer.name, store: storeName })
      : t('debtReminderGreeting', { name: account.customer.name }),
    t('debtReminderOwed', {
      amount: formatMoney(account.balance, currency),
      count: account.orders,
    }),
    ...listed.map((order) =>
      t('debtReminderOrder', {
        order: order.order_number,
        date: shortDate(order.placed_at),
        amount: formatMoney(order.balance, currency),
      }),
    ),
    hidden > 0 ? t('debtReminderMore', { count: hidden }) : null,
    qr
      ? t('payLaterShareBank', {
          bank: qr.bank_name ?? qr.bank_bin,
          account: qr.account_number,
          name: qr.account_name,
        })
      : null,
    qr ? t('payLaterShareNote', { note: qr.transfer_content }) : null,
    qr?.image_url ? t('payLaterShareLink', { link: qr.image_url }) : null,
    t('debtReminderThanks'),
  ];
  return lines.filter((line): line is string => Boolean(line)).join('\n');
}
