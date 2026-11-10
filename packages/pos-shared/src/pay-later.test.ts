import { describe, expect, it } from 'vitest';
import { payLaterDetails, payLaterMessage, payLaterQr, receiptPayLaterQr } from './pay-later';
import i18n from './test-support/i18n';

const t = (key: string, options?: Record<string, unknown>) => i18n.t(key, options ?? {}) as string;
const qr = {
  amount: '200000.0',
  currency: 'VND',
  order_number: 'R250',
  transfer_content: 'TNR250',
  bank_bin: '970436',
  bank_name: 'Vietcombank',
  account_number: '0123456789',
  account_name: 'PARK VIET',
  payload: '000201010212',
  image_url: 'https://img.vietqr.io/qr.png',
};

describe('pure pay-later data and messages', () => {
  it('reads complete QR data and rejects incomplete or non-sale snapshots', () => {
    expect(payLaterQr(qr)).toEqual(qr);
    expect(payLaterQr({ ...qr, payload: '' })).toBeNull();
    expect(payLaterQr(null)).toBeNull();
    expect(
      receiptPayLaterQr({ source_type: 'sale', document: { credit: { pay_qr: qr } } }),
    ).toEqual(qr);
    expect(
      receiptPayLaterQr({ source_type: 'refund', document: { credit: { pay_qr: qr } } }),
    ).toBeNull();
  });

  it('formats printable bank details without a browser', () => {
    expect(payLaterDetails(qr, t)).toEqual([
      'Số tiền: 200.000 ₫',
      'Vietcombank · 0123456789 · PARK VIET',
      'Nội dung CK: TNR250',
    ]);
  });

  it('formats the customer message and omits an absent image link', () => {
    expect(payLaterMessage(qr, t, 'Bếp Cô Ba').split('\n')).toEqual([
      'Bếp Cô Ba gửi thông tin thanh toán:',
      'Đơn R250 còn 200.000 ₫.',
      'Chuyển khoản: Vietcombank - STK 0123456789 - PARK VIET',
      'Nội dung: TNR250 (giữ nguyên để cửa hàng tự trừ nợ)',
      `Mã QR: ${qr.image_url}`,
    ]);
    expect(payLaterMessage({ ...qr, image_url: null }, t)).not.toContain('Mã QR');
  });
});
