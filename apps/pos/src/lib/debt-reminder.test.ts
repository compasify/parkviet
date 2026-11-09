import { describe, expect, it, vi } from 'vitest';
import i18n from '../i18n';
import { canRemindDebt, debtReminderMessage, matchesDebtor, shortDate } from './debt-reminder';
import { copyMessage, payLaterQr, shareMessage } from './pay-later';
import type { PosReceivableAccount } from './pos-context';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

const qrData = {
  amount: '300000.0',
  currency: 'VND',
  order_number: 'R100',
  transfer_content: 'TNR100',
  bank_bin: '970436',
  bank_name: 'Vietcombank',
  account_number: '0123456789',
  account_name: 'PARK VIET',
  payload: '00020101021238540010A00000072701240006970436011001234567890208QRIBFTTA5303704',
  image_url:
    'https://img.vietqr.io/image/970436-0123456789-compact2.png?amount=300000&addInfo=TNR100',
};

function account(overrides: Partial<PosReceivableAccount> = {}): PosReceivableAccount {
  return {
    credit_account_id: 'poscredit_1',
    currency: 'VND',
    customer: { id: 'poscus_1', name: 'Chị Lan', phone: '0901234567', address: '1205 S1.02' },
    orders: 2,
    credit_limit: '2000000.0',
    account_status: 'active',
    balance: '300000.0',
    overdue: '0.0',
    current: '300000.0',
    days_1_30: '0.0',
    days_31_60: '0.0',
    days_61_90: '0.0',
    days_over_90: '0.0',
    open_orders: [
      {
        order_id: 'or_1',
        order_number: 'R100',
        placed_at: '2026-11-02T03:00:00Z',
        due_on: '2026-11-09',
        balance: '100000.0',
      },
      {
        order_id: 'or_2',
        order_number: 'R101',
        placed_at: '2026-11-05T18:30:00Z',
        due_on: '2026-11-13',
        balance: '200000.0',
      },
    ],
    pay_later: qrData,
    ...overrides,
  };
}

describe('debt reminder message', () => {
  it('greets, lists every open order and gives one QR note for the total', () => {
    const qr = payLaterQr(qrData);
    expect(debtReminderMessage(account(), qr, t, 'Bếp Cô Ba').split('\n')).toEqual([
      'Chào Chị Lan, Bếp Cô Ba xin phép nhắc nhẹ ạ:',
      'Anh/chị còn 300.000 ₫ chưa thanh toán (2 đơn):',
      '- R100 ngày 02/11: 100.000 ₫',
      // Placed late evening UTC is the next day in Vietnam.
      '- R101 ngày 06/11: 200.000 ₫',
      'Chuyển khoản: Vietcombank - STK 0123456789 - PARK VIET',
      'Nội dung: TNR100 (giữ nguyên để cửa hàng tự trừ nợ)',
      `Mã QR: ${qrData.image_url}`,
      'Anh/chị chuyển khoản giúp cửa hàng nhé. Cảm ơn anh/chị nhiều ạ!',
    ]);
  });

  it('counts orders left off the list, and has no bank lines without a QR', () => {
    const text = debtReminderMessage(account({ orders: 25 }), null, t);
    expect(text.startsWith('Chào Chị Lan, cửa hàng xin phép nhắc nhẹ ạ:')).toBe(true);
    expect(text).toContain('(25 đơn)');
    expect(text).toContain('- và 23 đơn khác');
    expect(text).not.toContain('Chuyển khoản');
    expect(text).not.toContain('Mã QR');
  });

  it('shares with the QR picture or copies the text', async () => {
    const qr = payLaterQr(qrData);
    const share = vi.fn().mockResolvedValue(undefined);
    expect(await shareMessage('hello', qr, 'Nhắc', { share, canShare: () => false })).toBe(
      'shared',
    );
    expect(share).toHaveBeenCalledWith({ title: 'Nhắc', text: 'hello' });

    const writeText = vi.fn().mockResolvedValue(undefined);
    const clipboard = { writeText } as unknown as Clipboard;
    expect(await copyMessage('hello', { clipboard })).toBe('copied');
    expect(writeText).toHaveBeenCalledWith('hello');
    expect(await copyMessage('hello', {})).toBe('failed');
  });
});

describe('customers who owe', () => {
  it('searches by name without accents or by visible phone digits', () => {
    expect(matchesDebtor(account(), 'lan')).toBe(true);
    expect(matchesDebtor(account(), 'chi lan')).toBe(true);
    expect(matchesDebtor(account(), '0901')).toBe(true);
    expect(matchesDebtor(account(), 'Minh')).toBe(false);
    const masked = account({ customer: { id: 'c', name: 'Chị Lan', phone: '•••••••567' } });
    expect(matchesDebtor(masked, '0901')).toBe(false);
    expect(matchesDebtor(masked, '567')).toBe(true);
    expect(matchesDebtor(masked, '  ')).toBe(true);
  });

  it('lets only staff who see contacts send reminders', () => {
    expect(canRemindDebt(['pos.payment.collect'])).toBe(true);
    expect(canRemindDebt(['pos.credit.manage'])).toBe(true);
    expect(canRemindDebt(['pos.shift.open'])).toBe(false);
    expect(canRemindDebt(undefined)).toBe(false);
    expect(shortDate(null)).toBe('');
  });
});
