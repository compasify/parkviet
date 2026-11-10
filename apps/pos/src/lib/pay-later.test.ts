import { snapshotData } from '@parkviet/pos-shared/receipt-template/data';
import { defaultTemplate } from '@parkviet/pos-shared/receipt-template/defaults';
import { renderDocument } from '@parkviet/pos-shared/receipt-template/render';
import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';
import { describe, expect, it, vi } from 'vitest';
import { PrintSheet } from '../components/print-sheet';
import i18n from '../i18n';
import {
  type PayLaterQr,
  payLaterMessage,
  payLaterQr,
  receiptPayLaterQr,
  receiptStoreName,
  sharePayLater,
} from './pay-later';
import type { ReceiptSnapshot } from './print-adapter';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;

const payQr = {
  amount: '200000.0',
  currency: 'VND',
  order_number: 'R250',
  transfer_content: 'TNR250',
  bank_bin: '970436',
  bank_name: 'Vietcombank',
  account_number: '0123456789',
  account_name: 'PARK VIET',
  payload: '00020101021238540010A00000072701240006970436011001234567890208QRIBFTTA5303704',
  image_url:
    'https://img.vietqr.io/image/970436-0123456789-compact2.png?amount=200000&addInfo=TNR250',
};

function sale(credit: Record<string, unknown> | null): ReceiptSnapshot {
  return {
    id: 'posreceipt_1',
    source_type: 'sale',
    number: 'R250',
    branch_id: 'br_1',
    issued_at: '2026-11-07T03:00:00Z',
    issued_late: false,
    disclaimer: null,
    printed: false,
    copy_count: 0,
    document: {
      title: 'PHIẾU BÁN HÀNG',
      store: { name: 'Bếp Cô Ba' },
      branch: { name: 'Nhà' },
      timezone: 'Asia/Ho_Chi_Minh',
      at: '2026-11-07T03:00:00Z',
      currency: 'VND',
      order_number: 'R250',
      lines: [],
      totals: { item_total: '300000.0', total: '300000.0' },
      receipts: [{ method: 'cash', amount: '100000.0', handed: '100000.0', change: '0.0' }],
      paid_total: '100000.0',
      credit,
    },
  } as unknown as ReceiptSnapshot;
}

describe('pay-later QR on the sale receipt', () => {
  it('prints the QR with the amount, account and note under the payments', () => {
    const doc = renderDocument(
      defaultTemplate('sale'),
      snapshotData(sale({ debt: '200000.0', due_on: '2026-11-14', pay_qr: payQr }), t),
    );
    expect(doc.payQr).toEqual({
      value: payQr.payload,
      caption: 'Quét mã để chuyển khoản trả nợ',
      lines: ['Số tiền: 200.000 ₫', 'Vietcombank · 0123456789 · PARK VIET', 'Nội dung CK: TNR250'],
    });

    const html = renderToStaticMarkup(
      createElement(PrintSheet, { document: doc, paper: '80mm', testId: 'sheet' }),
    );
    expect(html).toContain('data-testid="receipt-pay-qr"');
    expect(html).toContain(`data-qr-value="${payQr.payload}"`);
    expect(html).toContain('<svg');
    expect(html).toContain('Nội dung CK: TNR250');
  });

  it('prints nothing without a debt QR, or when the template switched it off', () => {
    const noQr = renderDocument(
      defaultTemplate('sale'),
      snapshotData(sale({ debt: '200000.0', due_on: '2026-11-14' }), t),
    );
    expect(noQr.payQr).toBeNull();
    expect(renderDocument(defaultTemplate('sale'), snapshotData(sale(null), t)).payQr).toBeNull();

    const config = defaultTemplate('sale');
    const off = renderDocument(
      {
        ...config,
        payments: { fields: ['methods', 'debt'], labels: {} },
      },
      snapshotData(sale({ debt: '200000.0', pay_qr: payQr }), t),
    );
    expect(off.payQr).toBeNull();

    const relabelled = renderDocument(
      { ...config, payments: { fields: ['pay_qr'], labels: { pay_qr: 'Quét để trả' } } },
      snapshotData(sale({ debt: '200000.0', pay_qr: payQr }), t),
    );
    expect(relabelled.payQr?.caption).toBe('Quét để trả');
  });

  it('reads the QR off a sale snapshot only, and drops incomplete data', () => {
    expect(receiptPayLaterQr(sale({ debt: '1', pay_qr: payQr }))).toEqual(payQr);
    expect(receiptStoreName(sale(null))).toBe('Bếp Cô Ba');
    expect(
      receiptPayLaterQr({ source_type: 'refund', document: { credit: { pay_qr: payQr } } }),
    ).toBeNull();
    expect(payLaterQr({ ...payQr, payload: '' })).toBeNull();
    expect(payLaterQr(null)).toBeNull();
  });
});

function parsed(value: unknown): PayLaterQr {
  const qr = payLaterQr(value);
  if (!qr) throw new Error('expected a pay-later QR');
  return qr;
}

describe('pay-later message', () => {
  it('says what is owed, where to pay and the note to keep', () => {
    expect(payLaterMessage(parsed(payQr), t, 'Bếp Cô Ba').split('\n')).toEqual([
      'Bếp Cô Ba gửi thông tin thanh toán:',
      'Đơn R250 còn 200.000 ₫.',
      'Chuyển khoản: Vietcombank - STK 0123456789 - PARK VIET',
      'Nội dung: TNR250 (giữ nguyên để cửa hàng tự trừ nợ)',
      `Mã QR: ${payQr.image_url}`,
    ]);
    const bare = payLaterMessage(parsed({ ...payQr, image_url: null }), t);
    expect(bare).not.toContain('Mã QR');
    expect(bare.startsWith('Đơn R250')).toBe(true);
  });

  it('shares through the share sheet, or copies where there is none', async () => {
    const qr = parsed(payQr);
    const share = vi.fn().mockResolvedValue(undefined);
    expect(await sharePayLater(qr, t, null, { share, canShare: () => false })).toBe('shared');
    expect(share).toHaveBeenCalledWith(
      expect.objectContaining({ text: expect.stringContaining('TNR250') }),
    );

    const writeText = vi.fn().mockResolvedValue(undefined);
    const clipboard = { writeText } as unknown as Clipboard;
    expect(await sharePayLater(qr, t, null, { clipboard })).toBe('copied');
    expect(writeText).toHaveBeenCalledWith(expect.stringContaining('STK 0123456789'));

    const cancel = vi.fn().mockRejectedValue(new DOMException('no', 'AbortError'));
    expect(await sharePayLater(qr, t, null, { share: cancel, clipboard })).toBe('cancelled');

    const refuse = vi.fn().mockRejectedValue(new Error('refused'));
    expect(await sharePayLater(qr, t, null, { share: refuse, clipboard })).toBe('copied');
    expect(await sharePayLater(qr, t, null, {})).toBe('failed');
  });
});
